-- module: preferred audio device selection
local m = {}

-- Return the configured preferred input device name.
local function preferredInputName()
    return m.config.inputDeviceName
end

local function preferredOutputName()
    return m.config.outputDeviceName
end

-- When the preferred input device is connected, keep macOS pointed at it even
-- if another app or device change moved the default elsewhere.
local function ensurePreferredInput()
    local deviceName = preferredInputName()
    if deviceName == nil or deviceName == '' then
        return
    end

    local targetDevice = hs.audiodevice.findInputByName(deviceName)
    if targetDevice == nil then
        hsm.log.d('preferred input unavailable: ' .. deviceName)
        return
    end

    local currentDevice = hs.audiodevice.defaultInputDevice()
    if currentDevice ~= nil and currentDevice:uid() == targetDevice:uid() then
        return
    end

    local currentName = currentDevice and currentDevice:name() or 'None'
    local success = targetDevice:setDefaultInputDevice()

    if success then
        hsm.log.i('default input set to ' .. deviceName .. ' (was ' .. currentName .. ')')
    else
        hsm.log.e('failed to set default input to ' .. deviceName)
    end
end

-- Apply the same preference logic to the default audio output device.
local function ensurePreferredOutput()
    local deviceName = preferredOutputName()
    if deviceName == nil or deviceName == '' then
        return
    end

    local targetDevice = hs.audiodevice.findOutputByName(deviceName)
    if targetDevice == nil then
        hsm.log.d('preferred output unavailable: ' .. deviceName)
        return
    end

    local currentDevice = hs.audiodevice.defaultOutputDevice()
    if currentDevice ~= nil and currentDevice:uid() == targetDevice:uid() then
        return
    end

    local currentName = currentDevice and currentDevice:name() or 'None'
    local success = targetDevice:setDefaultOutputDevice()

    if success then
        hsm.log.i('default output set to ' .. deviceName .. ' (was ' .. currentName .. ')')
    else
        hsm.log.e('failed to set default output to ' .. deviceName)
    end
end

-- Reconcile both defaults together so a single device change event can correct
-- input and output drift in one pass.
local function ensurePreferredAudioDevices()
    ensurePreferredInput()
    ensurePreferredOutput()
end

-- Audio device change events can arrive in bursts, so delay reconciliation
-- slightly and collapse repeated events into one update.
local function schedulePreferredAudioDeviceCheck()
    if m.syncTimer ~= nil then
        m.syncTimer:stop()
    end

    m.syncTimer = hs.timer.doAfter(0.5, function()
        m.syncTimer = nil
        ensurePreferredAudioDevices()
    end)
end

-- The system-level watcher is global, so this module owns the callback while it
-- is running and re-checks the preferred devices only for relevant events.
local function audioDeviceChanged(eventName)
    hsm.log.d('audio device changed: ' .. eventName)

    if eventName == 'dIn ' or eventName == 'dOut' or eventName == 'dev#' then
        schedulePreferredAudioDeviceCheck()
    end
end

function m.start()
    -- Re-apply preferences on startup in case Hammerspoon loads after the audio
    -- devices have already been connected.
    hs.audiodevice.watcher.setCallback(audioDeviceChanged)
    hs.audiodevice.watcher.start()
    schedulePreferredAudioDeviceCheck()
end

function m.stop()
    if m.syncTimer ~= nil then
        m.syncTimer:stop()
        m.syncTimer = nil
    end

    hs.audiodevice.watcher.stop()
    hs.audiodevice.watcher.setCallback(nil)
end

return m
