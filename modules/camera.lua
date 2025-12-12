-- module: camera activity event triggering
local m = {}

function toggleFocus()
    local anyCameraInUse = false
    for k, camera in pairs(hs.camera.allCameras()) do
        -- Check if camera object is valid before accessing its properties
        local camera_name = "Unknown"
        local is_in_use = false

        local success, name = pcall(function() return camera:name() end)
        if success and name then
            camera_name = name
        else
            hsm.log.d('Skipping invalid camera object')
            goto continue
        end

        local success, in_use = pcall(function() return camera:isInUse() end)
        if success then
            is_in_use = in_use
        else
            hsm.log.d('Could not check if camera is in use: ' .. camera_name)
            goto continue
        end

        hsm.log.d(string.format('Checking camera %s, is in use: %s', camera_name, is_in_use))
        if is_in_use then
            anyCameraInUse = true
            break
        end

        ::continue::
    end
    hsm.log.d(string.format('Any camera in use: %s', anyCameraInUse))


    if anyCameraInUse then
        hs.shortcuts.run('Start Video Call Focus')
    else
        hs.shortcuts.run('Stop Video Call Focus')
    end
end

function m.start()
    -- existing cameras
    for k, camera in pairs(hs.camera.allCameras()) do
        -- Check if camera object is valid before setting up watchers
        local success, camera_name = pcall(function() return camera:name() end)
        if not success or not camera_name then
            hsm.log.d('Skipping invalid camera object in start()')
            goto continue
        end

        -- stop old watcher
        local success, is_running = pcall(function() return camera:isPropertyWatcherRunning() end)
        if success and is_running then
            pcall(function() camera:stopPropertyWatcher() end)
        end

        local success = pcall(function()
            camera:setPropertyWatcherCallback(function(camera, property, scope, element)
                local success, name = pcall(function() return camera:name() end)
                local camera_name = success and name or "Unknown"
                hsm.log.d("camera watcher call back triggered for " .. camera_name)
                toggleFocus()
            end)
            camera:startPropertyWatcher()
        end)

        if success then
            hsm.log.d("started camera watcher for " .. camera_name)
        else
            hsm.log.d("failed to start camera watcher for " .. camera_name)
        end

        ::continue::
    end

    -- new cameras
    hs.camera.setWatcherCallback(function(camera, state)
        hsm.log.d('Camera change callback triggered ' .. state)
        toggleFocus()
    end)
    hs.camera.startWatcher()
end

function m.stop()
    for k, camera in pairs(hs.camera.allCameras()) do
        -- Check if camera object is valid before stopping watcher
        local success, camera_name = pcall(function() return camera:name() end)
        if not success or not camera_name then
            hsm.log.d('Skipping invalid camera object in stop()')
            goto continue
        end

        local success, is_running = pcall(function() return camera:isPropertyWatcherRunning() end)
        if success and is_running then
            pcall(function() camera:stopPropertyWatcher() end)
            hsm.log.d("stopped camera watcher for " .. camera_name)
        end

        ::continue::
    end
end

return m
