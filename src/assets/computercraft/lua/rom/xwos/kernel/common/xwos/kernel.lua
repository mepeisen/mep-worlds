--    Copyright Martin Eisengardt 2018 xworlds.eu
--    
--    This file is part of xwos.
--
--    xwos is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    xwos is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with xwos.  If not, see <http://www.gnu.org/licenses/>.

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
    local moses = krequire('xwos/extensions/moses/moses_min.lua')
    table = {}
    for k,v in origpairs(origTable) do
        table[k] = v
    end -- for table
    table.clear = moses.clear
    table.each = moses.each
    table.eachi = moses.eachi
    table.at = moses.at
    table.count = moses.count
    table.countf = moses.countf
    table.cycle = moses.cycle
    table.map = moses.map
    table.reduce = moses.reduce
    table.reduceby = moses.reduceby
    table.reduceRight = moses.reduceRight
    table.mapReduce = moses.mapReduce
    table.mapReduceRight = moses.mapReduceRight
    table.include = moses.include
    table.detect = moses.detect
    table.where = moses.where
    table.findWhere = moses.findWhere
    table.select = moses.select
    table.reject = moses.reject
    table.all = moses.all
    table.invoke = moses.invoke
    table.pluck = moses.pluck
    table.max = moses.max
    table.min = moses.min
    table.shuffle = moses.shuffle
    table.same = moses.same
    table.sort = moses.sort
    table.sortBy = moses.sortBy
    table.groupBy = moses.groupBy
    table.countBy = moses.countBy
    table.size = moses.size
    table.containsKey = moses.containsKey
    table.sameKeys = moses.sameKeys
    table.sample = moses.sample
    table.sampleProb = moses.sampleProb
    table.toArray = moses.toArray
    table.find = moses.find
    table.reverse = moses.reverse
    table.fill = moses.fill
    table.selectWhile = moses.selectWhile
    table.dropWhile = moses.dropWhile
    table.sortedIndex = moses.sortedIndex
    table.indexOf = moses.indexOf
    table.lastIndexOf = moses.lastIndexOf
    table.findIndex = moses.findIndex
    table.findLastIndex = moses.findLastIndex
    table.addTop = moses.addTop
    table.push = moses.push
    table.pop = moses.pop
    table.unshift = moses.unshift
    table.pull = moses.pull
    table.removeRange = moses.removeRange
    table.chunk = moses.chunk
    table.slice = moses.slice
    table.first = moses.first
    table.initial = moses.initial
    table.last = moses.last
    table.rest = moses.rest
    table.nth = moses.nth
    table.compact = moses.compact
    table.flattern = moses.flattern
    table.difference = moses.difference
    table.union = moses.union
    table.intersection = moses.intersection
    table.symmetricDifference = moses.symmetricDifference
    table.unique = moses.unique
    table.isunique = moses.isunique
    table.zip = moses.zip
    table.append = moses.append
    table.interleave = moses.interleave
    table.interpose = moses.interpose
    table.range = moses.range
    table.rep = moses.rep
    table.partition = moses.partition
    table.sliding = moses.sliding
    table.permutation = moses.permutation
    table.invert = moses.invert
    table.concat = moses.concat
    -- TODO functions: noop, identity, constant, memoize, once, before, after, compose, pipe, complement, juxtapose,
    -- TODO wrap, times, bind, bind2, bindn, bindAll, uniqueId, iterator, array, flip, over, overEvery, overSome,
    -- TODO overArgs, partial, partialRight, curry, time, keys, values, kvpairs, toObj, property, propertyOf,
    -- TODO toBoolean, extend, functions, clone, tap, has, pick, omit, template, isEqual, result, isTable, isCallable,
    -- TODO isArray, isIterable, isEmpty, isString, isFunction, isNil, isNumber, isNaN, isFinite, isBoolean, isInteger,
    -- TODO chain, obj:value, import
    
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
    
    --------------------------------
    -- @field [parent=#xwos.kernel] #global nenv the new environment for processes
    M.nenv = {}
    M.debug("preparing sandbox for root process", M.nenv)
    local nenvmt = {
        __index = function(table, key)
            local e = origGetfenv(0)
            if (e == M.nenv) then return nil end
            return e[key]
        end -- function __index
    }
    origsetmeta(M.nenv, nenvmt)
    origSetfenv(nenvmt.__index, M.nenv)
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
    M.oldfenv = wrapfenv(oldGlob, M.nenv, {
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
    local nenv = {}
    M.debug("preparing new environment for root process", nenv)
    for k,v in origpairs(M.oldGlob) do
        nenv[k] = v
    end -- for oldGlob
    nenv.print = function(...) -- TODO remove
        M.oldGlob.print("->", ...)
    end -- function print
    
    M.debug("creating root process")
    local proc = M.processes.new(nil, M, nenv, M.envFactories) -- TODO factories from root profile (per profile factories)
    local startupData = M.readSecureData('core/startup.dat', "/rom/xwos/kernel/common/xwos/testsleep.lua") -- TODO startup script
    M.debug("spawning thread with startup script " .. startupData)
    proc.spawn(startupData)
    proc.join(nil)
    
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
    
    table = origTable
    
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

return M
