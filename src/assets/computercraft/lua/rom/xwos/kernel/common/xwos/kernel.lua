local origGetfenv = getfenv
local origSetfenv = setfenv
local origsetmeta = setmetatable
local origtype = type
local origpairs = pairs
local origload = load
local origpcall = pcall
local origprint = print
local origtostring = tostring

local origTable = table
table = {}
for k,v in origpairs(origTable) do
    table[k] = v
end -- for table

-------------------------------------
-- Creates a new clone; only first level of table will be cloned, no deep clone; no metadata clone
-- @function [parent=#table] clone
-- @param #table src
-- @return #table new copy
table.clone = function(src)
    local r = {}
    for k, v in origpairs(src) do
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
    for k, v in origpairs(haystack) do
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
    for k, v in origpairs(haystack) do
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
    for k, v in origpairs(haystack) do
        if (v == needle) then
            haystack[k] = nil
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
    return haystack[needle] ~= nil
end -- function table.containsKey

--------------------------------
-- local kernel
-- @type xwos.kernel
local M = {}

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

--------------------------------
-- Boot kernel
-- @function [parent=#xwos.kernel] boot
-- @param #string ver kernel version number
-- @param #table kernelpaths the paths to look for kernel files
-- @param #function krequire require function to include kernel files
-- @param global#global args the command line arguments
M.boot = function(ver, kernelpaths, krequire, oldGlob, args)
    --------------------------------
    -- @field [parent=#xwos.kernel] #table kernelpaths the paths for including kernel
    M.kernelpaths = kernelpaths
    --------------------------------
    -- @field [parent=#xwos.kernel] #string version the kernel version
    M.version = ver
    --------------------------------
    -- @field [parent=#xwos.kernel] #table the built in environment factories (installed from modules)
    M.envFactories = {}
    --------------------------------
    -- @field [parent=#xwos.kernel] global#global oldGlob the old globals
    M.oldGlob = oldGlob -- TODO type (global#global) does not work?
    M.oldGlob._ENV = nil
    --M.oldGlob.package = nil
    M.oldGlob._G = nil
    M.oldGlob.shell = nil
    M.oldGlob.multishell = nil
    --------------------------------
    -- @field [parent=#xwos.kernel] #table args the command line args invoking the kernel
    M.args = args or {}

    -------------------------------
    -- @field [parent=#xwos.kernel] #boolean kernelDebug true for kernel debugging; activated through script invocation/argument ("xwos debug")
    M.kernelDebug = false

    -------------------------------
    -- @field [parent=#xwos.kernel] #boolean eventLog true for event logging; activated through script invocation/argument ("xwos eventLog")
    M.eventLog = false
    
    -- parse arguments
    for i, v in origpairs(M.args) do
        if bootSequence[v] ~= nil then
            bootSequence[v]()
        else -- exists
            M.print("Ignoring unknown argument " .. v)
        end -- not exists
    end -- for arg
    
    --------------------------------
    -- Require for kernel scripts
    -- @function [parent=#xwos.kernel] require
    -- @param #string path the path
    M.require = krequire
    
    M.debug("loading process management")
    --------------------------------
    -- @field [parent=#xwos.kernel] xwos.processes#xwos.processes processes the known xwos processes
    M.processes = M.require('xwos/processes')
    
    M.debug("loading module management")
    --------------------------------
    -- @field [parent=#xwos.kernel] xwos.modulesmgr#xwos.modulesmgr modules the kernel modules
    M.modules = M.require('xwos/modulesmgr')
    
    M.debug("booting modules")
    M.modules.preboot(M)
    M.modules.boot(M)
    
    M.debug("preparing sandbox for root process")
    local nenv = {}
    local nenvmt = {
        __index = function(table, key)
            local e = origGetfenv(0)
            if (e == nenv) then return nil end
            return e[key]
        end -- function __index
    }
    origsetmeta(nenv, nenvmt)
    origSetfenv(nenvmt.__index, nenv)
    local function wrapfenv(table, env, blacklist)
        local R = {}
        for k,v in origpairs(table) do
            local t = origtype(v)
            if t == "function" then
                if blacklist[k] == nil then
                    R[k] = origGetfenv(v)
                    -- print("setfenv", k, R[k])
                    origpcall(origSetfenv, v, env) -- pcall because changing internal functions will fail (silently ingore it)
                end -- if blacklist
            end -- if function
            if t == "table" and blacklist[k] ~= "*" then
                -- print("setfenv table ", k)
                R[k] = wrapfenv(v, env, blacklist[k] or {})
            end -- if table
        end -- for table
        return R
    end -- function wrapfenv
    --------------------------------
    -- @field [parent=#xwos.kernel] #table oldfenv the old fenv for global functions
    M.oldfenv = wrapfenv(oldGlob, nenv, {
        getfenv=true,
        setfenv=true,
        shell={run=true, clearAlias=true, dir=true, getRunningProgram=true},
        package="*",
        bit32={bxor=true},
        redstone={getBundledOutput=true}
    })
    M.debug("boot finished")
end -- function boot

--------------------------------
-- Startup xwos
-- @function [parent=#xwos.kernel] startup
M.startup = function()
    M.debug("preparing new environment for root process")
    local nenv = {}
    for k,v in origpairs(M.oldGlob) do
        nenv[k] = M.oldGlob[k]
    end -- for oldGlob
    nenv.print = function(...)
        M.oldGlob.print("->", ...)
    end -- function print
    
    M.debug("creating root process")
    local proc = M.processes.new(M, nenv, M.envFactories) -- TODO factories from root profile (per profile factories)
    local startupData = M.readSecureData('core/startup.dat', "/rom/xwos/kernel/common/xwos/test.lua") -- TODO startup script
    M.debug("spawning thread with startup script " .. startupData)
    proc.spawn(startupData)
    proc.join()
    
    M.debug("cleanup root process sandbox")
    -- cleanup
    local function unwrapfenv(table, old)
        for k,v in origpairs(table) do
            local t = origtype(v)
            if old[k] ~= nil then
                if t == "function" then
                    -- print("setfenv", k, old[k])
                    origpcall(origSetfenv, v, old[k]) -- pcall because changing internal functions will fail (silently ingore it)
                end -- if function
                if t == "table" then
                    unwrapfenv(v, old[k])
                end -- if table
            end -- if old
        end -- for table
    end -- function unwrapfenv
    unwrapfenv(M.oldGlob, M.oldfenv)
    
    M.debug("last actions before shutdown")
    if proc.result[1] then
        origprint("Good bye...")
    else -- if result
        origprint("ERR: ", proc.result[2])
    end -- if result
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
    M.oldGlob.print(...) -- TODO wrap to kernel display
    if (M.kernelDebug) then
        local f = M.oldGlob.fs.open("/core/log/debug-log.txt", M.oldGlob.fs.exists("/core/log/debug-log.txt") and "a" or "w")
        local str = M.oldGlob.os.day().."-"..M.oldGlob.os.time().." "
        for k, v in origpairs({...}) do
            str = str .. origtostring(v) .. " "
        end -- for ...
        f.writeLine(str)
        f.close()
    end -- if kernelDebug
end -- function print

-------------------------------
-- read data file from secured kernel storage
-- @function [parent=#xwos.kernel] readSecureData
-- @param #string path the file to read
-- @param #string def optional default data
-- @return #string the file content or nil if file does not exist
M.readSecureData = function(path, def)
    local f = "/xwos/private/" .. path
    if not M.oldGlob.fs.exists(f) then
        return def
    end -- if not exists
    local h = M.oldGlob.fs.open(f, "r")
    local res = h.readall()
    h.close()
    return res
end -- function readSecureData

-------------------------------
-- write data file to secured kernel storage
-- @function [parent=#xwos.kernel] writeSecureData
-- @param #string path the file to write
-- @param #string data new data
M.writeSecureData = function(path, data)
    local f = "/xwos/private/" .. path
    local h = M.oldGlob.fs.open(f, "w")
    h.write(data)
    h.close()
end -- function readSecureData

-- TODO remote monitors: http://www.computercraft.info/forums2/index.php?/topic/25973-multiple-monitors-via-wired-network-cables/
-- TODO http://computercraft.info/wiki/Category:Unofficial_APIs
-- TODO http://computercraft.info/wiki/Category:User_Created_Peripherals
-- TODO http://www.computercraft.info/wiki/Category:Peripheral_APIs

return M
