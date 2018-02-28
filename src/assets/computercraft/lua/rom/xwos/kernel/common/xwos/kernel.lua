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

-------------------------------
-- true for kernel debugging; activated through script invocation/argument ("xwos debug")
-- @field [parent=#xwos.kernel] #boolean kernelDebug
M.kernelDebug = false

-------------------------------
-- true for computer event logging; activated through script invocation/argument ("xwos eventLog")
-- @field [parent=#xwos.kernel] #boolean eventLog
M.eventLog = false

-------------------------------
-- the original globals; widely used for security reasons and to access original code
-- @field [parent=#xwos.kernel] #xwos.kernel.globals origGlob
M.origGlob = nil

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] bit#bit bit preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] colors#colors colors preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] commands#commands commands preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] coroutine#coroutine coroutine preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] disk#disk disk preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] fs#fs fs preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] gps#gps gps preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] help#help help preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] http#http http preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] io#io io preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] keys#keys keys preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] math#math math preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] monitor#monitor monitor preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] multishell#multishell multishell preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] os#os os preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] paintutils#paintutils paintutils preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] parallel#parallel parallel preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] pocket#pocket pocket preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] peripheral#peripheral peripheral preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] rednet#rednet rednet preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] redstone#redstone redstone preloaded module

-------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] redstone#redstone rs preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] settings#settings settings preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] shell#shell shell preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] string#string string preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] table#table table preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] term#term term preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] textutils#textutils textutils preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] turtle#turtle turtle preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] vector#vector vector preloaded module

------------------------------------------------------------------------------
-- pre loaded module
-- @field[parent = #xwos.kernel.globals] window#window window preloaded module

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] print
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] write
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] xpcall
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] pcall
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] load
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] read
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] error
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] printError
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] dofile
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] loadfile
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] loadstring
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] rawset
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] rawget
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] pairs
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] ipairs
-- @param ...

-------------------------------
-- pre loaded function
-- @function [parent=#xwos.kernel.globals] require
-- @param ...

-- utility functions for bootstrap (arguments to xwos bootup script)
local bootSequence = {
    debug = function()
        M.kernelDebug = true
        M.print("activating kernel debug mode...")
    end, -- function debug
    
    eventLog = function()
        M.eventLog = true
        M.print("activating kernel event log...")
    end -- function eventLog
}

-- helper to load kernel modules from given directory
local loadKernelModules = function(dir)
    M.debug("loading kernel modules from " .. dir)
    for i, v in M.origGlob.pairs(M.origGlob.fs.list(dir)) do
        M.debug("loading kernel module from " .. dir .. "/" .. v)
        M.modules[v] = M.origGlob.require(dir .. "/" .. v)
    end -- for list
end --  function loadKernelModules

local origTable = table

-------------------------------------
-- Creates a new clone; only first level of table will be cloned, no deep clone; no metadata clone
-- @function [parent=#table] clone
-- @param #table src
-- @return #table new copy
table.clone = function(src)
    local r = {}
    for k, v in M.origGlob.pairs(src) do
        r[k] = v
    end -- for src
    return r
end -- function table.clone

-------------------------------------
-- @function [parent=#table] contains
-- @param #table haystack
-- @param #any needle
-- @return #boolean success
table.contains = function(haystack, needle)
    for k, v in M.origGlob.pairs(haystack) do
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
    for k, v in M.origGlob.pairs(haystack) do
        if (v == needle) then
            return k
        end -- if equals
    end -- for haystack
    return nil
end -- function table.indexOf

-------------------------------------
-- @function [parent=#table] removeValue
-- @param #table haystack
-- @param #any needle
-- @return #boolean true if element was found and removed
table.removeValue = function(haystack, needle)
    for k, v in M.origGlob.pairs(haystack) do
        if (v == needle) then
            M.origGlob.table.remove(haystack, k)
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

local function getStackDepth()
    for i=1,50000,1 do -- 50000 should be really enough, default max limit is 256
        local state = M.origGlob.pcall(M.origGlob.getfenv, i + 2)
        if not state then
            return i
        end -- if not state
    end -- for
    return 50000
end  -- function getStackDepth

-------------------------------
-- Boots kernel
-- @function [parent=#xwos.kernel] boot
-- @param #string myVersion the kernels version
-- @param #table kernelPaths paths to search for kernel files
-- @param #table oldGlob the old (original) globals; the startup script redirects require for easy kernel loading
-- @param ... command line arguments
M.boot = function(myVersion, kernelPaths, oldGlob, ...)
    M.origGlob = oldGlob
    
    -- parse arguments
    for i, v in ipairs(arg) do
        if bootSequence[v] ~= nil then
            bootSequence[v]()
        else -- exists
            M.print("Ignoring unknown argument " .. v)
        end -- not exists
    end -- for arg
  
    -- load kernel modules
    for k, v in ipairs(kernelPaths) do
        loadKernelModules(v)
    end -- for kernelPaths
    
    -- load settings with kernel module boot order
    local moduleOrder = require("moduleOrder")
  
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
-- @param #function func to execute
-- @param #table inject injections for env
-- @param ... function arguments
M.spawnSandbox = function(func, inject, ...)
    local orig = M.origGlob.getfenv(1)
    local newGlobal = origTable.clone(orig)
    local stackDepth = getStackDepth()
    
    for k, v in origTable.pairs(inject) do
        newGlobal[k] = v
    end
    
    newGlobal.setfenv = function(f, val)
        M.debug("[sb] called setfenv("..f..",...)")
        local curDepth = getStackDepth()
        M.debug("[sb] getStackDepth returns "..curDepth)
        local limit = curDepth - stackDepth
        
        if f == 0 then
            local prev = newGlobal
            newGlobal = val
            M.origGlob.setfenv(limit, newGlobal) -- does this work? correct value?
            return prev
        end -- if global
        
        if f < 0 then
            error("bad argument #1: level must be non-negative")
        end -- if negative
        if f < limit then
            return M.origGlob.setfenv(f + 1, val)
        end -- if limit
        error("bad argument #1: invalid level")
    end -- function setfenv
    
    newGlobal.getfenv = function(f)
        M.debug("[sb] called getfenv("..f..")")
        if (f == 0) then
            return newGlobal
        end -- if global
        local curDepth = getStackDepth()
        M.debug("[sb] getStackDepth returns "..curDepth)
        local limit = curDepth - stackDepth
        if f < 0 then
            error("bad argument #1: level must be non-negative")
        end -- if negative
        if f < limit then
            return M.origGlob.getfenv(f + 1)
        end -- if limit
        error("bad argument #1: invalid level")
    end -- function getfenv
    
    -- store env and invoke
    M.origGlob.setfenv(1, newGlobal)
    local status, err = M.origGlob.pcall(func, ...)
    
    -- reset globals to saved values
    M.origGlob.setfenv(1, orig)
    if not status then
        error(err)
    end -- if error
end

-------------------------------
-- starts the system
-- @function [parent=#xwos.kernel] startup
M.startup = function()
    local inject = {}
    if M.eventLog then
        local nos = table.clone(origTable.os)
        nos.queueEvent = function(event, ...)
            local str = M.origGlob.os.day() .. "-" .. M.origGlob.os.time() " EVENT,"..event..": ".. M.origGlob.textutils.serialize({...})
            local f = M.origGlob.fs.open("/core/log/event-log.txt", M.origGlob.fs.exists("/core/log/event-log.txt") and "a" or "w")
            f.writeLine(str)
            f.close()
            origTable.os.queueEvent(event, ...)
        end -- function queueEvent
    end -- if eventLog

    local start = require("xwos/startup")
    local proc = M.modules.sandbox.createProcessBuilder().buildAndExecute(start, M)
    proc.join()
    M.print("shutting down...")
end -- function startup

-------------------------------
-- debug log message
-- @function [parent=#xwos.kernel] debug
-- @param ... print message arguments
M.debug = function(...)
    if M.kernelDebug then
        M.print(...)
    end -- if kernelDebug
end -- function debug

-------------------------------
-- print info message
-- @function [parent=#xwos.kernel] print
-- @param ... print message arguments
M.print = function(...)
    M.origGlob.print(...) -- TODO wrap to kernel display
end -- function print

-------------------------------
-- read data file from secured kernel storage
-- @function [parent=#xwos.kernel] readSecureData
-- @param #string path the file to read
-- @return #string the file content or nil if file does not exist
M.readSecureData = function(path)
    local f = "/xwos/" + path
    if not M.origGlob.fs.exists(f) then
        return nil
    end -- if not exists
    local h = M.origGlob.fs.open()
    local res = h.readall()
    h.close()
    return res
end -- function readSecureData


-- TODO remote monitors: http://www.computercraft.info/forums2/index.php?/topic/25973-multiple-monitors-via-wired-network-cables/
-- TODO http://computercraft.info/wiki/Category:Unofficial_APIs
-- TODO http://computercraft.info/wiki/Category:User_Created_Peripherals



return M
