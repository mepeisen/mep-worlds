-------------------------------
-- The xwos kernel class
-- @module xwoskernel
-- @type xwos
local M = {}

-------------------------------
-- @type xwoskernelmodules

-------------------------------
-- kernel modules
-- @field [parent=#xwos] #xwoskernelmodules modules
M.modules = {}

-------------------------------
-- cloud kernel module
-- @field [parent=#xwoskernelmodules] #cloud cloud

-------------------------------
-- console kernel module
-- @field [parent=#xwoskernelmodules] #console console

-------------------------------
-- hardware kernel module
-- @field [parent=#xwoskernelmodules] #hardware hardware

-------------------------------
-- locale kernel module
-- @field [parent=#xwoskernelmodules] #locale locale

local myVersion = "0.0.1" -- TODO: setup maven build with version numbers etc.
local kernelDebug = false
local craftosVersion = "1_8"

local modulesDir1 = "/rom/xwos/kernel/"..craftosVersion.."/modules"
local modulesDir2 = "/rom/xwos/kernel/common/modules"
local bootSequence = {
  debug = function()
    kernelDebug = true
    print("activating kernel debug mode...")
  end
}

-- helper to load kernel modules from given directory
local loadKernelModules = function(dir)
  M.debug("loading kernel modules from " .. dir)
  for i, v in pairs(fs.list(dir)) do
    M.debug("loading kernel module from " .. dir .. "/" .. v)
    M.modules[v] = require(dir .. "/" .. v)
  end
end

-------------------------------------
-- @function [parent=#table] contains
-- @param #table haystack
-- @param #any needle
-- @return #boolean success
table.contains = function(haystack, needle)
  for k, v in pairs(haystack) do
    if (v == needle) then
      return true
    end
  end
  return false
end

-------------------------------------
-- @function [parent=#table] containsKey
-- @param #table haystack
-- @param #any needle
-- @return #boolean success
table.containsKey = function(haystack, needle)
  for k, v in pairs(haystack) do
    if (k == needle) then
      return true
    end
  end
  return false
end

-------------------------------
-- Boots kernel
-- @function [parent=#xwos] boot
-- @param ... command line arguments
M.boot = function(...)
  print("booting xwos kernel " .. myVersion)
  
  -- parse arguments
  for i, v in ipairs(arg) do
    if bootSequence[v] ~= nil then
      bootSequence[v]()
    else
      print("Ignoring unknown argument " .. v)
    end
  end
  
  -- load kernel modules
  loadKernelModules(modulesDir1)
  loadKernelModules(modulesDir2)
  
  -- load settings with kernel module boot order
  local h = fs.open("/rom/xwos/kernel/"..craftosVersion.."/module_order.cfg", "r")
  local content = h.readAll()
  local moduleOrder = textutils.unserialize(content)
  h.close()
  
  -- booting kernel modules
  for i, v in pairs(moduleOrder) do
    if M.modules[v] ~= nil then
      M.modules[v].preboot(M)
    end
  end
  for i, v in pairs(M.modules) do
    if not table.contains(moduleOrder, i) then
      v.preboot(M)
    end
  end
  --
  for i, v in pairs(moduleOrder) do
    if M.modules[v] ~= nil then
      M.modules[v].boot(M)
    end
  end
  for i, v in pairs(M.modules) do
    if not table.contains(moduleOrder, i) then
      v.boot(M)
    end
  end
end

-------------------------------
-- starts the system
-- @function [parent=#xwos] startup
M.startup = function()
  -- TODO
end

-------------------------------
-- debug log message
-- @function [parent=#xwos] debug
-- @param ... print message arguments
M.debug = function(...)
  if kernelDebug then
    M.print(...)
  end
end

-------------------------------
-- print info message
-- @function [parent=#xwos] print
-- @param ... print message arguments
M.print = function(...)
  print(...)
end

return M
