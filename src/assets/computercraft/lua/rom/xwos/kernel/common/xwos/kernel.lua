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
local origerror = error
local originsert = table.insert
local origprint = print
local origtostring = tostring

local origTable = table
local origString = string

local coFake -- a fake process during kernels boot 
local coKernel -- the kernels boot process

-- TODO currently not allowed in ccraft :-(
-- local origStringMeta = getmetatable("")
--------------------------------
-- local kernel
-- @module xwos.kernel
_CMR.class("xwos.kernel").singleton()

------------------------
-- the object privates
-- @type privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.kernel 

--------------------------------
-- Boot kernel
-- @function [parent=#xwos.kernel] boot
-- @param #xwos.kernel self the kernel object
-- @param #string ver kernel version number
-- @param #table kernelpaths the paths to look for kernel files
-- @param #string kernelRoot root path to kernel
-- @param #function cpfactory factory to create a class manager
-- @param global#global oldGlob
-- @param #table args the command line arguments

.func("boot",
--------------------------------
-- @function [parent=#intern] boot
-- @param #xwos.kernel self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string ver
-- @param #table kernelpaths
-- @param #string kernelRoot
-- @param #function cpfactory
-- @param global#global oldGlob
-- @param #table args
function(self, clazz, privates, ver, kernelpaths, kernelRoot, cpfactory, oldGlob, args)
    local bootSequence = {
        debug = function()
            self.kernelDebug = true
            self:print("activating kernel debug mode...")
        end, -- function debug
        
        trace = function()
            self.traceErrors = true
            self:print("activating kernel error trace...")
        end, -- function debug
        
        eventLog = function()
            self.eventLog = true
            self:print("activating kernel event log...")
        end -- function eventLog
    }

    -------------------------------
    -- the root path to kernel
    -- @field [parent=#xwos.kernel] #string kernelRoot
    self.kernelRoot = kernelRoot

    -------------------------------
    -- true for kernel error tracing; activated through script invocation/argument ("xwos trace")
    -- @field [parent=#xwos.kernel] #boolean traceErrors
    self.traceErrors = false

    -------------------------------
    -- true for kernel debugging; activated through script invocation/argument ("xwos debug")
    -- @field [parent=#xwos.kernel] #boolean kernelDebug
    self.kernelDebug = false

    -------------------------------
    -- true for event logging; activated through script invocation/argument ("xwos eventLog")
    -- @field [parent=#xwos.kernel] #boolean eventLog
    self.eventLog = false
    
    --------------------------------
    -- Require for kernel scripts
    -- @function [parent=#xwos.kernel] cpfactory
    -- @param #table env the environment to use
    self.cpfactory = cpfactory
    
    print("installing extension moses...")
    -- TODO check security
    table = {}
    -- TODO moses "functions" function maybe a security hole if invoked with nil (returning moses library functions with broken fenv???)
    -- TODO moses contains some local functions, may be a security hole because of broken fenv???
    -- TODO support moses aliases
    for k,v in origpairs(origTable) do
        table[k] = v
    end -- for table
    local moses = _CMR.require('xwos.extensions.moses.moses_min')
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
    -- TODO check security
    string = {}
    -- TODO allen contains some local functions, may be a security hole because of broken fenv???
    -- TODO support allen aliases
    -- TODO load special utf8 variant
    for k,v in origpairs(origString) do
        string[k] = v
    end -- for string
    local stringMeta = {}
--    for k,v in origpairs(origStringMeta) do
--        stringMeta[k] = v
--    end -- for string
--    origsetmeta("", stringMeta)
    local allen = _CMR.require('xwos.extensions.allen.allen')
    string.capitalizeFirst = allen.capitalizeFirst
    string.capitalizesEach = allen.capitalizesEach
    string.capitalize = allen.capitalize
    string.lowerFirst = allen.lowerFirst
    string.lowerRange = allen.lower
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
    string.rep2 = allen.rep
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
    -- the paths for including kernel
    -- @field [parent=#xwos.kernel] #table kernelpaths
    self.kernelpaths = kernelpaths
    --------------------------------
    -- the kernel version
    -- @field [parent=#xwos.kernel] #string version
    self.version = ver
    --------------------------------
    -- the built in environment factories (installed from modules)
    -- @field [parent=#xwos.kernel] #table envFactories
    self.envFactories = {}
    --------------------------------
    -- the old globals
    -- @field [parent=#xwos.kernel] global#global oldGlob
    self.oldGlob = oldGlob -- TODO type (global#global) does not work in eclipse?
    self.oldGlob._ENV = nil
    --self.oldGlob.package = nil
    self.oldGlob._G = nil
    self.oldGlob.shell = nil
    self.oldGlob.multishell = nil
    self.oldGlob.table = table
    self.oldGlob.functions = functions
    self.oldGlob.objects = objects
    
    --------------------------------
    -- the command line args invoking the kernel
    -- @field [parent=#xwos.kernel] #table args
    self.args = args or {}
    
    -- parse arguments
    for i, v in origpairs(self.args) do
        if bootSequence[v] ~= nil then
            bootSequence[v]()
        else -- exists
            self:print("Ignoring unknown argument " .. v)
        end -- not exists
    end -- for arg
    
    self:debug("loading process management")
    --------------------------------
    -- the known xwos processes
    -- @field [parent=#xwos.kernel] xwos.kernel.processes#xwos.kernel.processes processes
    self.processes = _CMR.new('xwos.kernel.processes')
    
    self:debug("loading module management")
    --------------------------------
    -- the kernel modules
    -- @field [parent=#xwos.kernel] xwos.kernel.modulesmgr#xwos.kernel.modulesmgr modules
    self.modules = _CMR.new('xwos.kernel.modulesmgr', self)
    
    self:debug("booting modules")
    self.modules:preboot()
    self.modules:boot()
    
    --------------------------------
    -- the new (sandbox) environment for processes
    -- @field [parent=#xwos.kernel] global#global nenv
    self.nenv = {}
    self:debug("preparing sandbox for root process", self.nenv)
    local nenvmt = {
        __index = function(table, key)
            local e = origGetfenv(0)
            if (e == self.nenv) then return nil end
            return e[key]
        end -- function __index
    }
    self:debug("sandbox: set meta")
    origsetmeta(self.nenv, nenvmt)
    self:debug("sandbox: set fenv")
    origSetfenv(nenvmt.__index, self.nenv)
    local function wrapfenv(table, env, blacklist)
        local R = {}
        for k,v in origpairs(table) do
            -- self:debug("sandbox: wrapfenv for", k, v)
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
    self:debug("sandbox: wrapfenv(oldGlob)")
    
    local blacklist = {
        getfenv=true,
        setfenv=true,
        shell={run=true, clearAlias=true, dir=true, getRunningProgram=true},
        package="*",
        bit32={bxor=true},
        redstone={getBundledOutput=true}
    }
    -- hack for cclite emu: no wrap...
    if cclite == nil then
        --------------------------------
        -- the old fenv for global functions
        -- @field [parent=#xwos.kernel] #table oldfenv
        self.oldfenv = wrapfenv(oldGlob, self.nenv, blacklist)
    else
        self.oldfenv = {} -- TODO check why cclite has such problems...
    end -- if cclite
    
    self:debug("boot finished")
end) -- function boot

--------------------------------
-- Startup xwos
-- @function [parent=#xwos.kernel] startup
-- @param #xwos.kernel self the kernel object

.func("startup",
--------------------------------
-- @function [parent=#intern] startup
-- @param #xwos.kernel self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    local nenv = {}
    self:debug("preparing new environment for root process", nenv)
    for k,v in origpairs(self.oldGlob) do
        nenv[k] = v
    end -- for oldGlob
    
    self:debug("creating root process")
    local proc = self.processes:create(nil, self, nenv, self.envFactories) -- TODO factories from root profile (per profile factories)
    local startupData = self:readSecureData("core/startup.dat", "xwos.bootmgr")
    self:debug("spawning thread with startup script", startupData)
    proc:spawnClass(startupData)
    proc:join(nil)
    
    self:debug("cleanup root process sandbox")
    -- cleanup
    local function unwrapfenv(table, old)
        for k,v in origpairs(table) do
            local t = origtype(v)
            if old ~= nil and old[k] ~= nil then
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
    unwrapfenv(self.oldGlob, self.oldfenv)
    
    -- TODO xwos startup script changed environment already...
    -- out cleanup may not work (or is not needed). Review this
    -- uninstall moses
    table = origTable
    functions = nil
    objects = nil
    
    -- uninstall allen
    string = origString
--    origsetmeta("", origStringMeta)
    
    self:debug("last actions before shutdown")
    if proc.result[1] then
        origprint("Good bye...")
    else -- if result
        origprint("ERR: ", proc.result[2])
    end -- if result
end) -- function startup

-------------------------------
-- debug log message
-- @function [parent=#xwos.kernel] debug
-- @param #xwos.kernel self the kernel object
-- @param ... print message arguments

.func("debug",
-------------------------------
-- @function [parent=#intern] debug
-- @param #xwos.kernel self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param ...
function(self, clazz, privates, ...)
    if self.kernelDebug then
        self:print(...)
    end -- if kernelDebug
end) -- function debug

-------------------------------
-- print info message
-- @function [parent=#xwos.kernel] print
-- @param #xwos.kernel self the kernel object
-- @param ... print message arguments

.func("print",
-------------------------------
-- @function [parent=#intern] print
-- @param #xwos.kernel self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param ...
function(self, clazz, privates, ...)
    self.oldGlob.print(...) -- TODO wrap to kernel display
    if (self.kernelDebug) then
        local f = self.oldGlob.fs.open("/core/log/debug-log.txt", self.oldGlob.fs.exists("/core/log/debug-log.txt") and "a" or "w")
        local str = self.oldGlob.os.day().."-"..self.oldGlob.os.time().." "
        for k, v in origpairs({...}) do
            str = str .. origtostring(v) .. " "
        end -- for ...
        f.writeLine(str)
        f.close()
    end -- if kernelDebug
end) -- function print

-------------------------------
-- read data file from secured kernel storage
-- @function [parent=#xwos.kernel] readSecureData
-- @param #xwos.kernel self the kernel object
-- @param #string path the file to read
-- @param #string def optional default data
-- @return #string the file content or parameter def if file does not exist

.func("readSecureData",
-------------------------------
-- @function [parent=#intern] readSecureData
-- @param #xwos.kernel self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @param #string def
-- @return #string
function(self, clazz, privates, path, def)
    local f = "/xwos/private/" .. path
    if not self.oldGlob.fs.exists(f) then
        return def
    end -- if not exists
    local h = self.oldGlob.fs.open(f, "r")
    local res = h.readall()
    h.close()
    return res
end) -- function readSecureData

-------------------------------
-- write data file to secured kernel storage
-- @function [parent=#xwos.kernel] writeSecureData
-- @param #xwos.kernel self the kernel object
-- @param #string path the file to write
-- @param #string data new data

.func("writeSecureData",
-------------------------------
-- @function [parent=#intern] writeSecureData
-- @param #xwos.kernel self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @param #string data
function(self, clazz, privates, path, data)
    local f = "/xwos/private/" .. path
    local h = self.oldGlob.fs.open(f, "w")
    h.write(data)
    h.close()
end -- function readSecureData
)

-------------------------------
-- returns stack trace information
-- @function [parent=#xwos.kernel] trace
-- @param #xwos.kernel self the kernel object
-- @return #list<#traceitem>

-------------------------------
-- a stacktrace item
-- @type traceitem

-------------------------------
-- the filename of this trace item (if known)
-- @field [parent=#traceitem] #string filename

-------------------------------
-- simple function name (if known)
-- @field [parent=#tracitem] #string func

-------------------------------
-- human readable entry
-- @field [parent=#tracitem] #string hr

-------------------------------
-- the line number of this item (if known)
-- @field [parent=#traceitem] #number line

-------------------------------
-- the file path of this item (may not be available)
-- @field [parent=#traceitem] #string path

-------------------------------
-- the type of item.
-- "F" for lua functions.
-- "B" for builtin functions.
-- "M" main script.
-- "C" for cunstructor invocations.
-- "S" for static class functions.
-- "M" for instance object methods.
-- "?" for unknown sources.
-- @field [parent=#traceitem] #string type

-------------------------------
-- class name for class related functions
-- @field [parent=#traceitem] #string clazz

-------------------------------
-- method name for class related functions
-- @field [parent=#traceitem] #string method

.func("trace",
-------------------------------
-- @function [parent=#intern] trace
-- @param #xwos.kernel self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @return #list<#traceitem>
function(self, clazz, privates)
    return self.oldGlob.boot.trace(false)
end -- function trace
)

return nil
