-- module: camera activity event triggering
local m = {}

function toggleFocus()
    local anyCameraInUse = false
    for k, camera in pairs(hs.camera.allCameras()) do
        hsm.log.d(string.format('Checking camera %s, is in use: %s', camera:name(), camera:isInUse()))
        if camera:isInUse() then
            anyCameraInUse = true
            break
        end
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
        -- stop old watcher
        if camera:isPropertyWatcherRunning() then
            camera:stopPropertyWatcher()
        end

        camera:setPropertyWatcherCallback(function(camera, property, scope, element)
            hsm.log.d("camera watcher call back triggered for " .. camera:name())
            toggleFocus()
        end)
        camera:startPropertyWatcher()
        hsm.log.d("started camera watcher for " .. camera:name())
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
        if camera:isPropertyWatcherRunning() then
            camera:stopPropertyWatcher()
        end
    end
end

return m
