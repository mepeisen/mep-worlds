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
local origString = string
local origStringMeta = getmetatable("")

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
    print("installing extension moses...")
    table = {}
    -- TODO moses "functions" function maybe a security hole if invoked with nil (returning moses library functions with broken fenv???)
    -- TODO moses contains some local functions, may be a security hole because of broken fenv???
    -- TODO support moses aliases
    for k,v in origpairs(origTable) do
        table[k] = v
    end -- for table
    local moses = krequire('/xwos/extensions/moses/moses_min')
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
    table.containsKeys = moses.containsKeys
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
    table.clone = moses.clone
    
    functions={}
    functions.noop = moses.noop
    functions.identity = moses.identity
    functions.constant = moses.constant
    functions.memoize = moses.memoize
    functions.constant = moses.constant
    functions.once = moses.once
    functions.before = moses.before
    functions.after = moses.after
    functions.compose = moses.compose
    functions.pipe = moses.pipe
    functions.complement = moses.complement
    functions.juxtapose = moses.juxtapose
    functions.wrap = moses.wrap
    functions.times = moses.times
    functions.bind = moses.bind
    functions.bind2 = moses.bind2
    functions.bindn = moses.bindn
    functions.bindAll = moses.bindAll
    functions.uniqueId = moses.uniqueId
    functions.iterator = moses.iterator
    functions.array = moses.array
    functions.flip = moses.flip
    functions.over = moses.over
    functions.overEvery = moses.overEvery
    functions.overSome = moses.overSome
    functions.overArgs = moses.overArgs
    functions.partial = moses.partial
    functions.partialRight = moses.partialRight
    functions.curry = moses.curry
    functions.time = moses.time
    
    objects = {}
    objects.keys = moses.keys
    objects.values = moses.values
    objects.kvpairs = moses.kvpairs
    objects.toObj = moses.toObj
    objects.property = moses.property
    objects.propertyOf = moses.propertyOf
    objects.functions = moses.functions
    objects.toBoolean = moses.toBoolean
    objects.extend = moses.extend
    objects.functions = moses.functions
    objects.clone = moses.clone
    objects.tap = moses.tap
    objects.has = moses.has
    objects.pick = moses.pick
    objects.omit = moses.omit
    objects.template = moses.template
    objects.isEqual = moses.isEqual
    objects.result = moses.result
    objects.isTable = moses.isTable
    objects.isCallable = moses.isCallable
    objects.isTable = moses.isTable
    objects.isArray = moses.isArray
    objects.isIterable = moses.isIterable
    objects.isEmpty = moses.isEmpty
    objects.isString = moses.isString
    objects.isFunction = moses.isFunction
    objects.isNil = moses.isNil
    objects.isNumber = moses.isNumber
    objects.isNaN = moses.isNaN
    objects.isFinite = moses.isFinite
    objects.isBoolean = moses.isBoolean
    objects.isInteger = moses.isInteger
    -- TODO chain, obj:value, import
    
    table.contains = function(haystack, needle)
        for k, v in origpairs(haystack) do
            if (v == needle) then
                return true
            end -- if equals
        end -- for haystack
        return false
    end -- function table.contains
    
    print("installing extension allen...")
    string = {}
    -- TODO allen contains some local functions, may be a security hole because of broken fenv???
    -- TODO support allen aliases
    for k,v in origpairs(origString) do
        string[k] = v
    end -- for string
    local stringMeta = {}
    for k,v in origpairs(origStringMeta) do
        stringMeta[k] = v
    end -- for string
    origsetmeta("", stringMeta)
    local allen = krequire('/xwos/extensions/allen/allen')
    string.capitalizeFirst = allen.capitalizeFirst
    string.capitalizesEach = allen.capitalizesEach
    string.capitalize = allen.capitalize
    string.lowerFirst = allen.lowerFirst
    string.lower = allen.lower
    string.isLowerCase = allen.isLowerCase
    string.isUpperCase = allen.isUpperCase
    string.startsLowerCase = allen.startsLowerCase
    string.startsUpperCase = allen.startsUpperCase
    string.swapCase = allen.swapCase
    string.levenshtein = allen.levenshtein
    string.chop = allen.chop
    string.clean = allen.clean
    string.escape = allen.escape
    string.substitute = allen.substitute
    string.includes = allen.includes
    string.chars = allen.chars
    string.isAlpha = allen.isAlpha
    string.isNumeric = allen.isNumeric
    string.index = allen.index
    string.isEmail = allen.isEmail
    string.count = allen.count
    string.insert = allen.insert
    string.isBlank = allen.isBlank
    string.join = allen.join
    string.lines = allen.lines
    string.splice = allen.splice
    string.startsWith = allen.startsWith
    string.endsWith = allen.endsWith
    string.succ = allen.succ
    string.pre = allen.pre
    string.titleize = allen.titleize
    string.camelize = allen.camelize
    string.underscored = allen.underscored
    string.dasherize = allen.dasherize
    string.humanize = allen.humanize
    string.numberFormat = allen.numberFormat
    string.words = allen.words
    string.pad = allen.pad
    string.lpad = allen.lpad
    string.rpad = allen.rpad
    string.lrpad = allen.lrpad
    string.strRight = allen.strRight
    string.strRightBack = allen.strRightBack
    string.strLeft = allen.strLeft
    string.strLeftBack = allen.strLeftBack
    string.toSentence = allen.toSentence
    string.rep = allen.rep
    string.surround = allen.surround
    string.quote = allen.quote
    string.bytes = allen.bytes
    string.byteAt = allen.byteAt
    string.isLuaKeyword = allen.isLuaKeyword
    string.isToken = allen.isToken
    string.isIdentifier = allen.isIdentifier
    string.is = allen.is
    string.statistics = allen.statistics
    
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
    M.oldGlob = oldGlob -- TODO type (global#global) does not work in eclipse?
    M.oldGlob._ENV = nil
    --M.oldGlob.package = nil
    M.oldGlob._G = nil
    M.oldGlob.shell = nil
    M.oldGlob.multishell = nil
    M.oldGlob.table = table
    M.oldGlob.functions = functions
    M.oldGlob.objects = objects
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
    
    -- TODO xwos startup script changed environment already...
    -- out cleanup may not work (or is not needed). Review this
    -- uninstall moses
    table = origTable
    functions = nil
    objects = nil
    
    -- uninstall allen
    string = origString
    origsetmeta("", origStringMeta)
    
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
