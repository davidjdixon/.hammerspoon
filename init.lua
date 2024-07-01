require('hs.ipc')

local LOGLEVEL = 'info' -- 'nothing', 'error', 'warning', 'info', 'debug', 'verbose'

-- List of modules to load (found in Modules/ dir)
local modules = {
  'spotify',
  'darkmode',
  'location',
  'camera'
}

-- global modules namespace (short for easy console use)
hsm = {}

local config = require('config')
hsm.config = config.global

-- global log
hsm.log = hs.logger.new('Logger', LOGLEVEL)

-- load a module from modules/ dir, and set up a logger for it
local function loadModuleByName(modName)
  hsm[modName] = require('modules.' .. modName)
  hsm[modName].name = modName
  hsm[modName].log = hs.logger.new(modName, LOGLEVEL)
  hsm.log.i(hsm[modName].name .. ': module loaded')
end

-- save the configuration of a module in the module object
local function configModule(mod)
  mod.config = mod.config or {}
  if (config[mod.name]) then
    for k, v in pairs(config[mod.name]) do mod.config[k] = v end
    hsm.log.i(mod.name .. ': module configured')
  end
end

-- start a module
local function startModule(mod)
  if mod.start == nil then return end
  mod.start()
  hsm.log.i(mod.name .. ': module started')
end

-- stop a module
local function stopModule(mod)
  if mod.stop == nil then return end
  mod.stop()
  hsm.log.i(mod.name .. ': module stopped')
end

-- global function to stop modules and reload hammerspoon config
function hs_reload()
  hs.fnutils.each(hsm, stopModule)
  hs.reload()
end

hs.fnutils.each(modules, loadModuleByName)
hs.fnutils.each(hsm, configModule)
hs.fnutils.each(hsm, startModule)

-- load and bind key bindings
local bindings = require('bindings')
bindings.bind()
