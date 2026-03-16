-- module: camera activity event triggering
local m = {}

-- Resolve the configured Shortcut name for the requested camera state transition.
local function shortcutName(action)
    if m.config.shortcut == nil then
        return nil
    end

    return m.config.shortcut[action]
end

-- Camera usage is the source of truth for focus mode. This helper runs the
-- configured Shortcut and logs failures rather than letting watcher callbacks die.
local function runShortcut(action)
    local name = shortcutName(action)
    if name == nil or name == '' then
        hsm.log.e('missing camera shortcut config for ' .. action)
        return
    end

    local success, err = pcall(function()
        hs.shortcuts.run(name)
    end)

    if success then
        hsm.log.i('camera focus shortcut run: ' .. name)
    else
        hsm.log.e('camera focus shortcut failed: ' .. name .. ' (' .. tostring(err) .. ')')
    end
end

local function cameraName(camera)
    local success, name = pcall(function() return camera:name() end)
    if success and name ~= nil then
        return name
    end

    return 'Unknown'
end

local function cameraUid(camera)
    local success, uid = pcall(function() return camera:uid() end)
    if success and uid ~= nil then
        return uid
    end

    return nil
end

-- Treat "any camera in use" as the single signal that decides whether the
-- video-call focus should be enabled.
local function anyCameraInUse()
    for _, camera in pairs(hs.camera.allCameras()) do
        local name = cameraName(camera)
        local inUseSuccess, inUse = pcall(function() return camera:isInUse() end)

        if not inUseSuccess then
            hsm.log.d('Could not check if camera is in use: ' .. name)
            goto continue
        end

        hsm.log.d(string.format('Checking camera %s, is in use: %s', name, inUse))
        if inUse then
            return true
        end

        ::continue::
    end

    return false
end

-- Reconcile focus mode with the actual hardware state. The force flag is used
-- by startup and periodic safety checks so the Shortcut is re-applied even if
-- our cached state already matches.
local function syncFocusToCameraState(forceShortcut)
    local cameraActive = anyCameraInUse()
    hsm.log.d(string.format('Any camera in use: %s', cameraActive))

    if not forceShortcut and m.lastCameraActive == cameraActive then
        return
    end

    m.lastCameraActive = cameraActive

    if cameraActive then
        runShortcut('start')
    else
        runShortcut('stop')
    end
end

-- Property watchers are attached to individual camera objects, so they must be
-- explicitly stopped and cleared during refresh and module shutdown.
local function stopCameraPropertyWatcher(camera)
    local success, isRunning = pcall(function() return camera:isPropertyWatcherRunning() end)
    if success and isRunning then
        pcall(function() camera:stopPropertyWatcher() end)
    end

    pcall(function() camera:setPropertyWatcherCallback(nil) end)
end

-- Each camera gets its own property watcher so we can react when a device
-- starts or stops being used by another app.
local function startCameraPropertyWatcher(camera)
    local name = cameraName(camera)

    stopCameraPropertyWatcher(camera)

    local success, err = pcall(function()
        camera:setPropertyWatcherCallback(function(changedCamera, property)
            hsm.log.d('camera watcher callback triggered for ' .. cameraName(changedCamera) .. ' (' .. property .. ')')
            syncFocusToCameraState(false)
        end)
        camera:startPropertyWatcher()
    end)

    if success then
        hsm.log.d('started camera watcher for ' .. name)
        return true
    end

    hsm.log.e('failed to start camera watcher for ' .. name .. ': ' .. tostring(err))
    return false
end

-- Keep the per-camera watcher list aligned with the currently attached devices.
local function refreshCameraWatchers()
    local activeCameraUids = {}

    for _, camera in pairs(hs.camera.allCameras()) do
        local uid = cameraUid(camera)
        if uid == nil then
            hsm.log.d('Skipping invalid camera object in refreshCameraWatchers()')
            goto continue
        end

        activeCameraUids[uid] = true

        if m.cameras[uid] == nil then
            if startCameraPropertyWatcher(camera) then
                m.cameras[uid] = camera
            end
        end

        ::continue::
    end

    for uid, camera in pairs(m.cameras) do
        if not activeCameraUids[uid] then
            stopCameraPropertyWatcher(camera)
            m.cameras[uid] = nil
            hsm.log.d('removed camera watcher for uid ' .. uid)
        end
    end
end

function m.start()
    -- Track camera objects by UID so hot-plugged devices can be added/removed
    -- without requiring a full Hammerspoon reload.
    m.cameras = {}
    m.lastCameraActive = nil

    refreshCameraWatchers()

    hs.camera.setWatcherCallback(function(_, state)
        hsm.log.d('Camera change callback triggered ' .. state)
        refreshCameraWatchers()
        syncFocusToCameraState(false)
    end)
    hs.camera.startWatcher()

    -- Periodic reconciliation is a safety net in case macOS misses a watcher
    -- event or the Shortcut state drifts away from the real camera state.
    m.reconcileTimer = hs.timer.doEvery(m.config.safetyCheckMinutes * 60, function()
        hsm.log.d('camera safety check triggered')
        refreshCameraWatchers()
        syncFocusToCameraState(true)
    end)

    syncFocusToCameraState(true)
end

function m.stop()
    if m.reconcileTimer ~= nil then
        m.reconcileTimer:stop()
        m.reconcileTimer = nil
    end

    hs.camera.stopWatcher()
    hs.camera.setWatcherCallback(nil)

    for uid, camera in pairs(m.cameras or {}) do
        stopCameraPropertyWatcher(camera)
        hsm.log.d('stopped camera watcher for uid ' .. uid)
        m.cameras[uid] = nil
    end
end

return m
