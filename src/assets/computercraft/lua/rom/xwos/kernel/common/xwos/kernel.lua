--------------------------------
-- Default Kernel module
-- @module xwos.kernel
local M = {}

-------------------------------
-- @type xwos.kernel.modules

-------------------------------
-- kernel modules
-- @field [parent=#xwos.kernel] #xwos.kernel.modules modules
M.modules = {}

-------------------------------
-- sandbox kernel module
-- @field [parent=#xwos.kernel.modules] xwos.kernel.sandbox#xwos.kernel.sandbox sandbox

local kernelDebug = false
-- save globals for sandboxing
local origGlobal = {}
for k, v in pairs(_G) do
    origGlobal[k] = v
end -- for _G
local kernelPrint = origGlobal.print

-- utility functions for bootstrap (arguments to xwos bootup script)
local bootSequence = {
    debug = function()
        kernelDebug = true
        M.print("activating kernel debug mode...")
    end -- function debug
}

-- helper to load kernel modules from given directory
local loadKernelModules = function(dir)
    M.debug("loading kernel modules from " .. dir)
    for i, v in pairs(origGlobal.fs.list(dir)) do
        M.debug("loading kernel module from " .. dir .. "/" .. v)
        M.modules[v] = origGlobal.require(dir .. "/" .. v)
    end -- for list
end --  function loadKernelModules

local origPairs = _G.pairs
-------------------------------------
-- @function [parent=#table] contains
-- @param #table haystack
-- @param #any needle
-- @return #boolean success
table.contains = function(haystack, needle)
    for k, v in origPairs(haystack) do
        if (v == needle) then
            return true
        end -- if equals
    end -- for haystack
    return false
end -- function table.contains

-------------------------------------
-- @function [parent=#table] indexOf
-- @param #table haystack
-- @param #any needle
-- @return #number index of given element or nil if not found
table.indexOf = function(haystack, needle)
    for k, v in origPairs(haystack) do
        if (v == needle) then
            return k
        end -- if equals
    end -- for haystack
    return nil
end -- function table.indexOf

local origRemove = table.remove
-------------------------------------
-- @function [parent=#table] removeValue
-- @param #table haystack
-- @param #any needle
-- @return #boolean true if element was found and removed
table.removeValue = function(haystack, needle)
    for k, v in origPairs(haystack) do
        if (v == needle) then
            origRemove(haystack, k)
            return true
        end -- if equals
    end -- for haystack
    return false
end -- function table.removeValue

-------------------------------------
-- @function [parent=#table] containsKey
-- @param #table haystack
-- @param #any needle
-- @return #boolean success
table.containsKey = function(haystack, needle)
--    for k, v in pairs(haystack) do
--        if (k == needle) then
--            return true
--        end -- if equals
--    end -- for haystack
--    return false
    return keystack[needle] ~= nil
end -- function table.containsKey

-------------------------------
-- Boots kernel
-- @function [parent=#xwos.kernel] boot
-- @param #string myVersion
-- @param #table kernelPaths
-- @param #function origRequire
-- @param #function sandbox
-- @param ... command line arguments
M.boot = function(myVersion, kernelPaths, origRequire, sandbox, ...)
    -- function for creating a (secure) sandbox
    M.spawnSandbox = sandbox

    -- parse arguments
    for i, v in ipairs(arg) do
        if bootSequence[v] ~= nil then
            bootSequence[v]()
        else -- exists
            print("Ignoring unknown argument " .. v)
        end -- not exists
    end -- for arg
  
    -- load kernel modules
    for k, v in ipairs(kernelPaths) do
        loadKernelModules(v)
    end -- for kernelPaths
    
    -- load settings with kernel module boot order
    local moduleOrder = origRequire("moduleOrder")
  
    -- booting kernel modules
    for i, v in pairs(moduleOrder) do
        if M.modules[v] ~= nil then
            M.modules[v].preboot(M)
        end -- if exists
    end -- for moduleOrder
    for i, v in pairs(M.modules) do
        if not table.contains(moduleOrder, i) then
            v.preboot(M)
        end -- if not contains
    end -- for modules
    
    for i, v in pairs(moduleOrder) do
        if M.modules[v] ~= nil then
            M.modules[v].boot(M)
        end -- if exists
    end -- for moduleOrder
    for i, v in pairs(M.modules) do
        if not table.contains(moduleOrder, i) then
            v.boot(M)
        end -- if not contains
    end -- for modules
end -- function boot

-------------------------------
-- @function [parent=#xwos.kernel] spawnSandbox
-- @param #boolean secure whether to secure getfenv and setfenv
-- @param #function function to execute
-- @param ... function arguments
M.spawnSandbox = nil

-------------------------------
-- starts the system
-- @function [parent=#xwos.kernel] startup
M.startup = function()
    local start = require("xwos/startup")
    local proc = M.modules.sandbox.createProcessBuilder().buildAndExecute(start, M)
    proc.join()
end -- function startup

-------------------------------
-- debug log message
-- @function [parent=#xwos.kernel] debug
-- @param ... print message arguments
M.debug = function(...)
    if kernelDebug then
        M.print(...)
    end -- if kernelDebug
end -- function debug

-------------------------------
-- print info message
-- @function [parent=#xwos.kernel] print
-- @param ... print message arguments
M.print = function(...)
    kernelPrint(...)
end -- function print

-------------------------------
-- read data file from secured kernel storage
-- @function [parent=#xwos.kernel] readSecuredData
-- @param #string path the file to read
-- @return #string the file content or nil if file does not exist
M.readSecureData = function(path)
    -- TODO
end -- function readSecureData

return M
