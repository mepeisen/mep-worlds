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

local gsub = string.gsub
local tinsert = table.insert
local error = error
local pairs = pairs
local fsexists = fs.exists
local fsisdir = fs.isDir
local fslist = fs.list
local loadfile = loadfile
local setfenv = setfenv
local setmetatable = setmetatable
local split = string.gmatch

return function(env)
    ---------------
    -- a class manager for loading classes
    -- @module classmanager
    local classmanager = {}
    local classpath = {}
    env = env or _G
    local classes = {} -- #map<#string,#clazz>
    
     -- TODO security: the local functions may have from env...
    
    ---------------
    -- plain require a file
    -- @function [parent=#classmanager] require
    -- @param #string path the path to file
    -- @return #any the file result
    function classmanager.require(path)
        local file = gsub(path, "%.", "/")
        for k,v in pairs(classpath) do
            local path = v.."/"..file..".lua"
            if fsexists(path) and not fsisdir(path) then
                local res, err = loadfile(path)
                if res then
                    return res()
                else -- if res
                    error(err)
                end -- if not res
            end -- if isfile
        end -- for cp
        error("file "..path.." not found")
    end -- function path
    
    ---------------
    -- adds a path to classpath
    -- TODO security: do not allow invocation from child threads
    -- @function [parent=#classmanager] addcp
    -- @param ... classpath elements to be added
    -- @return #classmanager self for chaining
    function classmanager.addcp(...)
        for k,v in pairs({...}) do
            tinsert(classpath, v)
        end -- for ...
        return classmanager
    end -- function addcp
    
    local function errClass(name, err)
        local errfunc = function()
            error(err)
        end -- function errfunc
        classmanager.class(name).ctor(errfunc)
    end -- error class
    
    local function loadClassFile(name, file, path)
        local res, err = loadfile(path)
        if res then
            setfenv(res, env)
            res()
            if classes[name] == nil then
                err = file.." did not declare class "..name
                errClass(name, err)
                error(err)
            end -- if not class
        else -- if res
            err = "loading "..name.." throws error: "..err
            errClass(name, err)
            error(err)
        end -- if not res
    end -- function loadClassFile
    
    local function loadClass(name)
        local file = gsub(name, "%.", "/")
        for k,v in pairs(classpath) do
            local path1 = v.."/"..file..".lua"
            local path2 = v.."/"..file.."/init.lua"
            if fsexists(path1) and not fsisdir(path1) then
                loadClassFile(name, file, path1)
                return
            elseif fsexists(path2) and not fsisdir(path2) then
                loadClassFile(name, file, path2)
                return
            end -- if isfile
        end -- for cp
        local err = "class "..name.." not found"
        errClass(name, err)
        error(err)
    end -- function loadClass
    
    local function addObjMethods(self, privates, index, objclazz, clazz)
        for k,v in pairs(clazz._funcs) do
            index[k] = function(self, ...)
                return clazz._funcs[k](self, clazz, privates, ...)
            end -- function
            setfenv(index[k], env)
            if clazz._super ~= nil then
                local mt = { __index = {} }
                setmetatable(index, mt)
                addObjMethods(self, privates, mt.__index, clazz, clazz._super)
            end -- if super
        end -- for funcs
    end -- function addObjMethods
    
    local function addPrivateMethods(self, privates, index, objclazz, clazz)
        for k,v in pairs(clazz._privates) do
            index[k] = function(self, ...)
                return clazz._privates[k](self, clazz, privates, ...)
            end -- function
            setfenv(index[k], env)
            if clazz._super ~= nil then
                local mt = { __index = {} }
                setmetatable(index, mt)
                addPrivateMethods(self, privates, mt.__index, clazz, clazz._super)
            end -- if super
        end -- for funcs
    end -- function addPrivateMethods
    
    local function invokeCtor(self, privates, objclazz, clazz, ...)
        if clazz._ctor == nil then
            if clazz._super ~= nil then
                invokeCtor(self, privates, objclazz, clazz._super, ...)
            end -- if super
        else -- if not ctor
            clazz._ctor(self, clazz, privates, ...)
        end -- if ctor
    end -- function invokeCtor
    
    local function loadAndDefineClass(name)
        if classes[name] == nil then
            loadClass(name)
        end -- if class
        local clazz = classes[name]
        if clazz._supername ~= nil and clazz._super == nil then
            loadAndDefineClass(clazz._supername)
            clazz._super = classes[clazz._supername]
            local mt = { __index = clazz._super._funcs }
            setmetatable(clazz._funcs, mt)
            clazz._superctor = function(self, privates, ...)
                invokeCtor(self, privates, clazz._super, clazz._super, ...)
            end -- function
            setfenv(clazz._superctor, env)
            
            local cur = env
            for v in split(name, "[^%.]+") do
                if cur[v] == nil then
                    cur[v] = {}
                end -- if not cur
                cur = cur[v]
            end -- for split
            for k, v in pairs(clazz._statics) do
                cur[k] = v
            end -- for statics
        end -- if not super
    end -- function loadClass
    
    local function construct(name, clazz, ...)
        local obj = {}
        local privates = {}
        obj.class = name
        local mt1 = { __index={} }
        setmetatable(obj, mt1)
        local mt2 = { __index={} }
        setmetatable(privates, mt2)
        addObjMethods(obj, privates, mt1.__index, clazz, clazz)
        addPrivateMethods(obj, privates, mt2.__index, clazz, clazz)
        invokeCtor(obj, privates, clazz, clazz, ...)
        return obj
    end -- function construct
    
    ---------------
    -- Retrieves singleton instance
    -- @function [parent=#classmanager] get
    -- @param #string name the class name
    -- @return #table the object instance
    function classmanager.get(name)
        loadAndDefineClass(name)
        
        local clazz = classes[name]
        if not clazz._singleton then
            error("Cannot retrieve non-singleton "..name)
        end -- if not singleton
        
        if clazz._singletonInstance == nil then
            clazz._singletonInstance = construct(name, clazz)
        end -- if not singletonInstance
        
        return clazz._singletonInstance
    end -- function new
    
    ---------------
    -- create new class instance
    -- @function [parent=#classmanager] new
    -- @param #string name the class name
    -- @param ... optional constructor arguments
    -- @return #table the object instance
    function classmanager.new(name, ...)
        loadAndDefineClass(name)
        
        local clazz = classes[name]
        if clazz._singleton then
            error("Cannot create new instance of singleton "..name)
        end -- if singleton
        if clazz._abstract then
            error("Cannot create new instance of abstract "..name)
        end -- if singleton
        
        return construct(name, clazz, ...)
    end -- function new
    
    ---------------
    -- load class with given name
    -- @function [parent=#classmanager] load
    -- @param #string name the class name
    function classmanager.load(name)
        loadAndDefineClass(name)
    end -- function load
    
    ---------------
    -- load all class within given package
    -- @function [parent=#classmanager] loadAll
    -- @param #string package the package name
    function classmanager.loadAll(package)
        for name in pairs(classmanager.findClasses(package)) do
            loadAndDefineClass(name)
        end -- for class
    end -- function load
    
    ---------------
    -- find packages with given prefix
    -- @function [parent=#classmanager] findPackages
    -- @param #string prefix the package prefix
    -- @return #table the found packages (package names in keys)
    function classmanager.findPackages(prefix)
        local res = {}
        local file = gsub(prefix, "%.", "/")
        for k,v in pairs(classpath) do
            local path = v.."/"..file
            if (fsisdir(path)) then
                for _, f in pairs(fslist(path)) do
                    if fsisdir(path.."/"..f) then
                        res[prefix.."."..f] = f
                    end -- if fs.isdir
                end -- for fs.list
            end -- if isdir
        end -- for co
        return res
    end -- function findPackages
    
    ---------------
    -- find classes within package
    -- @function [parent=#classmanager] findClasses
    -- @param #string package the package name
    -- @return #table the found classes (class names in keys)
    function classmanager.findClasses(package)
        local res = {}
        local file = gsub(package, "%.", "/")
        for k,v in pairs(classpath) do
            local path = v.."/"..file
            if fsisdir(path) then
                for _, f in pairs(fslist(path)) do
                    if f:sub(-4)==".lua" and not fsisdir(path.."/"..f) then
                        res[package.."."..f:sub(0, -5)] = true
                    end -- if not fs.isdir
                end -- for fs.list
            end -- if fs.isdir
        end -- for co
        return res
    end -- function findClasses
    
    ---------------
    -- declares a new class
    -- @function [parent=#classmanager] class
    -- @param #string name the class name
    -- @return #clazz the class instance
    function classmanager.class(name)
        if classes[name] ~= nil then
            -- print(cclite.traceback())
            error("Duplicate class declaration: "..name)
        end -- if classes
        
        -- TODO support field defaults, mixins
        
        ---------------
        -- a local class declaration
        -- @type clazz
        local clazz = {
            ---------------
            -- the instance functions inside class
            -- @field [parent=#clazz] #table _funcs
            _funcs = {},
            
            ---------------
            -- the static functions
            -- @field [parent=#clazz] #table _statics
            _statics = {},
            
            ---------------
            -- the private static variables
            -- @field [parent=#clazz] #table _pstatics
            _pstatics = {},
            
            ---------------
            -- the private instance functions inside class
            -- @field [parent=#clazz] #table _privates
            _privates = {},
            
            ---------------
            -- the constructor function
            -- @field [parent=#clazz] #function _ctor
            _ctor = nil,
            
            ---------------
            -- the class name
            -- @field [parent=#clazz] #string _name
            _name = name,
            
            ---------------
            -- the singleton flag
            -- @field [parent=#clazz] #boolean _singleton
            _singleton = false,
            
            ---------------
            -- the abstract flag
            -- @field [parent=#clazz] #boolean _abstract
            _abstract = false,
            
            ---------------
            -- true if singleton is private (non-visible through api)
            -- @field [parent=#clazz] #boolean _privateSingleton
            _privateSingleton = false,
            
            ---------------
            -- the singleton instance
            -- @field [parent=#clazz] #table _singletonInstance
            _singletonInstance = nil,
            
            ---------------
            -- the super constructor from base class
            -- @field [parent=#clazz] #function _superctor
            _superctor = function() end,
            
            ---------------
            -- the super class (extends)
            -- @field [parent=#clazz] #clazz _super
            _super = nil,
            
            ---------------
            -- the super class name (unresolved)
            -- @field [parent=#clazz] #string _supername
            _supername = nil
        }
        setfenv(clazz._superctor, env)
        classes[name] = clazz
        
        ---------------
        -- declare class to be abstract; abstract classes cannot be instantiated directly
        -- @function [parent=#clazz] abstract
        -- @return #clazz self for chaining
        function clazz.abstract()
            clazz._abstract = true
            return clazz
        end -- function aFunc
        
        ---------------
        -- abstract functions to be overriden by child classes
        -- @function [parent=#clazz] aFunc
        -- @param ... name of the functions to be abstract
        -- @return #clazz self for chaining
        function clazz.aFunc(...)
            for name in pairs({...}) do
                clazz.func(name, function(self, clazz, privates, ...)
                    error("method not supported")
                end)
            end -- for ...
            return clazz
        end -- function aFunc
        
        ---------------
        -- delegate functions directly to private object
        -- @function [parent=#clazz] delegate
        -- @param #string property private property
        -- @param ... name of the functions to be delegated
        -- @return #clazz self for chaining
        function clazz.delegate(property, ...)
            for name in pairs({...}) do
                clazz.func(name, function(self, clazz, privates, ...)
                    local prop = privates[property]
                    return prop[name](prop, ...)
                end)
            end -- for ...
            return clazz
        end -- function delegate
        
        ---------------
        -- declare a singleton
        -- @function [parent=#clazz] singleton
        -- @param #boolean private true for non-visible singletons; defaults to false
        -- @return #clazz self for chaining
        function clazz.singleton(private)
            clazz._singleton = true
            if private ~= nil then
                clazz._privateSingleton = private
            end -- if private
            return clazz
        end -- function ctor
        setfenv(clazz.singleton, env)
        
        ---------------
        -- declare constructor
        -- @function [parent=#clazz] ctor
        -- @param #function func
        -- @return #clazz self for chaining
        function clazz.ctor(func)
            if clazz._ctor ~= nil then
                error("Duplicate constructor declaration for "..name)
            end -- if func
            clazz._ctor = func
            setfenv(func, env)
            return clazz
        end -- function ctor
        setfenv(clazz.ctor, env)
        
        ---------------
        -- declare function
        -- @function [parent=#clazz] func
        -- @param #string name
        -- @param #function func
        -- @return #clazz self for chaining
        function clazz.func(name, func)
            if clazz._funcs[name] ~= nil then
                error("Duplicate function declaration: "..clazz._name.."."..name)
            end -- if func
            clazz._funcs[name] = func
            setfenv(func, env)
            return clazz
        end -- function func
        setfenv(clazz.func, env)
        
        ---------------
        -- declare private function located inside object privates
        -- @function [parent=#clazz] pfunc
        -- @param #string name
        -- @param #function func
        -- @return #clazz self for chaining
        function clazz.pfunc(name, func)
            if clazz._privates[name] ~= nil then
                error("Duplicate private function declaration: "..clazz._name.."."..name)
            end -- if func
            clazz._privates[name] = func
            setfenv(func, env)
            return clazz
        end -- function func
        setfenv(clazz.pfunc, env)
        
        ---------------
        -- declare static function
        -- @function [parent=#clazz] sfunc
        -- @param #string name
        -- @param #function func
        -- @return #clazz self for chaining
        function clazz.sfunc(name, func)
            if clazz._statics[name] ~= nil then
                error("Duplicate static function declaration: "..clazz._name.."."..name)
            end -- if func
            clazz._statics[name] = func
            setfenv(func, env)
            return clazz
        end -- function sfunc
        setfenv(clazz.sfunc, env)
        
        ---------------
        -- declare private static variables
        -- @function [parent=#clazz] pstat
        -- @param #string key
        -- @param #any value
        -- @return #clazz self for chaining
        function clazz.pstat(key, value)
            if clazz._pstatics[key] ~= nil then
                error("Duplicate static variable declaration: "..clazz._name.."."..key)
            end -- if func
            clazz._pstatics[key] = value
            return clazz
        end -- function pstat
        setfenv(clazz.pstat, env)
        
        ---------------
        -- return private static variable
        -- @function [parent=#clazz] getPstat
        -- @param #string key
        -- @return #table any private variable found in this clazz or in super classes
        function clazz.getPstat(key)
            local res = {}
            local cur = clazz -- #clazz
            while cur ~= nil do
                if cur._pstatics[key] ~= nil then
                    tinsert(res, cur._pstatics[key])
                end -- if pstat
                cur = cur._super
            end -- while cur
            return res
        end -- function getPstat
        
        ---------------
        -- class inheritance
        -- @function [parent=#clazz] extends
        -- @param #string name the class to extend
        -- @return #clazz self for chaining
        function clazz.extends(name)
            clazz._supername = name
            return clazz
        end -- function clazz
        setfenv(clazz.extends, env)
        
        return clazz
    end -- function class
    
    setfenv(classmanager.require, env)
    setfenv(classmanager.addcp, env)
    setfenv(errClass, env)
    setfenv(loadClassFile, env)
    setfenv(loadClass, env)
    setfenv(addObjMethods, env)
    setfenv(addPrivateMethods, env)
    setfenv(invokeCtor, env)
    setfenv(loadAndDefineClass, env)
    setfenv(construct, env)
    setfenv(classmanager.get, env)
    setfenv(classmanager.new, env)
    setfenv(classmanager.load, env)
    setfenv(classmanager.findPackages, env)
    setfenv(classmanager.findClasses, env)
    setfenv(classmanager.class, env)
    
    return classmanager
end -- function create
