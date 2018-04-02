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
    
    local objects = {}
    setmetatable(objects, { __mode = 'k' })
    
     -- TODO security: the local functions may have from env...
     -- TODO private singletons: Allowing friend classes to access them
     -- TODO provide some solutions for singletons and inheritance....
     -- TODO utf8 class variants for clean unicode support
    
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
                local res, err = loadfile(path, env)
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
    
    ---------------
    -- removes a path from classpath
    -- TODO security: do not allow invocation from child threads
    -- @function [parent=#classmanager] removecp
    -- @param ... classpath elements to be removed
    -- @return #classmanager self for chaining
    function classmanager.removecp(...)
        for k,v in pairs({...}) do
            for i, v2 in pairs(classpath) do
                if v2 == v then
                    classpath[i] = nil
                end
            end
        end -- for ...
        return classmanager
    end -- function removecp
    
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
    
    local function wrapLocalClazz(name, self, privates, clazz, objclazz)
        local locclazz = {}
        setmetatable(locclazz, {__index = objclazz})
        locclazz.super = function(...)
            local cur = clazz._super
            while cur ~= nil do
                if cur._funcs[name] ~= nil then
                   return cur._funcs[name](self, wrapLocalClazz(name, self, privates, cur, objclazz), privates, ...)
                end -- if superfunc
                cur = cur._super
            end
            return nil -- do nothing if no super method is available
        end
        setfenv(locclazz.super, env)
        return locclazz
    end -- function wrapLocalClazz
    
    local function wrapPLocalClazz(name, self, privates, clazz, objclazz)
        local locclazz = {}
        setmetatable(locclazz, {__index = objclazz})
        locclazz.super = function(...)
            local cur = clazz._super
            while cur ~= nil do
                if cur._privates[name] ~= nil then
                   return cur._privates[name](self, wrapPLocalClazz(name, self, privates, cur, objclazz), privates, ...)
                end -- if superfunc
                cur = cur._super
            end
            return nil -- do nothing if no super method is available
        end
        setfenv(locclazz.super, env)
        return locclazz
    end -- function wrapPLocalClazz
    
    local function addObjMethods(self, privates, index, objclazz, clazz)
        for k,v in pairs(clazz._funcs) do
            if index[k] == nil then
                index[k] = function(self, ...)
                    return clazz._funcs[k](self, wrapLocalClazz(k, self, privates, clazz, objclazz), privates, ...)
                end -- function
                setfenv(index[k], env)
            end -- if not func
        end -- for funcs
        if clazz._super ~= nil then
            addObjMethods(self, privates, index, objclazz, clazz._super)
        end -- if super
    end -- function addObjMethods
    
    local function addPrivateMethods(self, privates, index, objclazz, clazz)
        for k,v in pairs(clazz._privates) do
            index[k] = function(_, ...)
                return clazz._privates[k](self, wrapPLocalClazz(k, self, privates, clazz, objclazz), privates, ...)
            end -- function
            setfenv(index[k], env)
            if clazz._super ~= nil then
                local mt = { __index = {} }
                setmetatable(index, mt)
                addPrivateMethods(self, privates, mt.__index, objclazz, clazz._super)
            end -- if super
        end -- for funcs
    end -- function addPrivateMethods
    
    local function wrapCLocalClazz(self, privates, clazz, objclazz)
        local locclazz = {}
        setmetatable(locclazz, {__index = objclazz})
        locclazz.super = function(...)
            local cur = clazz._super
            while cur ~= nil do
                if cur._ctor ~= nil then
                   return cur._ctor(self, wrapCLocalClazz(self, privates, cur, objclazz), privates, ...)
                end -- if superctor
                cur = cur._super
            end
            return nil -- do nothing if no super method is available
        end
        setfenv(locclazz.super, env)
        return locclazz
    end -- function wrapCLocalClazz
    
    local function invokeCtor(self, privates, objclazz, clazz, ...)
        if clazz._ctor == nil then
            if clazz._super ~= nil then
                invokeCtor(self, privates, objclazz, clazz._super, ...)
            end -- if super
        else -- if not ctor
            clazz._ctor(self, wrapCLocalClazz(self, privates, clazz, objclazz), privates, ...)
        end -- if ctor
    end -- function invokeCtor
    
    local function loadAndDefineClass(name)
        if classes[name] == nil then
            loadClass(name)
        end -- if class
        local clazz = classes[name]
        if not clazz._defined then
            clazz._defined = true
            
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
            
            if clazz._supername ~= nil and clazz._super == nil then
                loadAndDefineClass(clazz._supername)
                clazz._super = classes[clazz._supername]
            end -- if not super
            
            for _, m in pairs(clazz._mixins) do
                local property = m.property
                local mixin = m.mixin
                loadAndDefineClass(mixin)
                local mc = classes[mixin]
                while mc ~= nil do
                    for k,v in pairs(mc._funcs) do
                        if clazz._funcs[k] == nil then
                            clazz.delegate(property, k)
                        end -- if not func
                    end -- for funcs
                    mc = mc._super
                end -- while mc
            end -- for mixins
        end -- if not defined
    end -- function loadClass
    
    local function construct(name, clazz, ...)
        local obj = {}
        local privates = {}
        objects[obj] = {privates = privates, clazz = clazz, annot = {}}
        obj.class = name
        local mt1 = { __index={} }
        setmetatable(obj, mt1)
        local mt2 = { __index={} }
        setmetatable(privates, mt2)
        addObjMethods(obj, privates, mt1.__index, clazz, clazz)
        addPrivateMethods(obj, privates, mt2.__index, clazz, clazz)
        invokeCtor(obj, privates, clazz, clazz, ...)
        
        for k,v in pairs(clazz._mixins) do
            if privates[v.property] == nil then
                privates[v.property] = classmanager.new(v.mixin)
            end -- if not property
        end -- mixins
        return obj
    end -- function construct
    
    ---------------
    -- Retrieves singleton instance
    -- @function [parent=#classmanager] get
    -- @param #string name the class name
    -- @return #table the object instance
    function classmanager.get(name)
        -- TODO private singleton support
        loadAndDefineClass(name)
        
        local clazz = classes[name]
        if not clazz._singleton then
            error("Cannot retrieve non-singleton "..name)
        end -- if not singleton
        
        if clazz._singletonInstance == nil then
            clazz._singletonInstance = construct(name, clazz)
        end -- if not singletonInstance
        
        return clazz._singletonInstance
    end -- function get
    
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
    -- Checks if given class is defined
    -- @function [parent=#classmanager] defined
    -- @param #string name the class name
    function classmanager.defined(name)
        return classes[name] ~= nil
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
        
        -- TODO support field defaults
        
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
            -- defined flag
            -- @field [parent=#clazz] #boolean _defined
            _defined = false,
            
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
            -- the super class (extends)
            -- @field [parent=#clazz] #clazz _super
            _super = nil,
            
            ---------------
            -- the super class name (unresolved)
            -- @field [parent=#clazz] #string _supername
            _supername = nil,
            
            ---------------
            -- the mixins added to this class
            -- @field [parent=#clazz] #table _mixins
            _mixins = {},
            
            ---------------
            -- the friends allowing to query object privates
            -- @field [parent=#clazz] #table _friends
            _friends = {},
            
            ---------------
            -- user variables for class objects
            -- @field [parent=#clazz] #table user
            user = {}
        }
        classes[name] = clazz
        
        ---------------
        -- declare class to be abstract; abstract classes cannot be instantiated directly
        -- @function [parent=#clazz] abstract
        -- @return #clazz self for chaining
        function clazz.abstract()
            clazz._abstract = true
            return clazz
        end -- function abstract
        setfenv(clazz.abstract, env)
        
        ---------------
        -- abstract functions to be overriden by child classes
        -- @function [parent=#clazz] aFunc
        -- @param ... name of the functions to be abstract
        -- @return #clazz self for chaining
        function clazz.aFunc(...)
            for k, name in pairs({...}) do
                clazz.func(name, function(self, clazz, privates, ...)
                    error("method not supported")
                end)
            end -- for ...
            return clazz
        end -- function aFunc
        setfenv(clazz.aFunc, env)
        
        ---------------
        -- delegate functions directly to private object
        -- @function [parent=#clazz] delegate
        -- @param #string property private property
        -- @param ... name of the functions to be delegated
        -- @return #clazz self for chaining
        function clazz.delegate(property, ...)
            for _, name in pairs({...}) do
                clazz.func(name, function(self, clazz, privates, ...)
                    local prop = privates[property]
                    return prop[name](prop, ...)
                end)
            end -- for ...
            return clazz
        end -- function delegate
        setfenv(clazz.delegate, env)
        
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
        setfenv(clazz.getPstat, env)

        ---------------
        -- Class inheritance (public class mixins).
        -- Mixins are added to the private variables.
        -- All public methods of mixins are merged to the main object by delegators.
        -- If a method already exists it will not be merged.
        -- Mixins can be initialized by direct initialization and setting inside constructors.
        -- If a mixin is not initialized in ctor it will be created automatically with no arguments given to constructor.
        -- @function [parent=#clazz] mixin
        -- @param #string property property name for given mixin
        -- @param #string mixin the mixin to add to this class
        -- @return #clazz self for chaining
        function clazz.mixin(property, mixin)
            tinsert(clazz._mixins, {
                property = property,
                mixin = mixin
            })
            return clazz
        end -- function mixin
        setfenv(clazz.mixin, env)

        ---------------
        -- friend classes allowing to access THIS object privates through method privates.
        -- @function [parent=#clazz] friends
        -- @param ... one or multiple classes being allowed to access object privates
        -- @return #clazz self for chaining
        function clazz.friends(...)
            for _, v in pairs({...}) do
                clazz._friends[v] = true
            end -- for friends
            return clazz
        end -- function friends
        setfenv(clazz.friends, env)

        ---------------
        -- Receive object privates for given object; throws error if this class is not a friend of target class
        -- @function [parent=#clazz] privates
        -- @param #table object to query the privates
        -- @return #table object privates
        function clazz.privates(object)
            local desc = objects[object]
            if desc ~= nil then
                if not desc.clazz._friends[clazz._name] then
                    error(clazz._name..' is not allowed to access '..desc.clazz._name..' privates')
                end -- if not friend
                return desc.privates
            end -- if desc
            error('Error getting object descriptor')
        end -- function friends
        setfenv(clazz.privates, env)
        
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

        ---------------
        -- Adding a private mixin (annotation) to any other object; only accessible by getAnnot method
        -- @function [parent=#clazz] annot
        -- @param #table target the target object to add the annotation
        -- @param #string name the class to instantiate
        -- @param ... constructor arguments for annotation class
        -- @return #table the instantiated mixin object as returned by method getAnnot
        function clazz.annot(target, name, ...)
            local desc = objects[target]
            if desc ~= nil then
                if desc.annot[clazz._name] == nil then
                    desc.annot[clazz._name] = {}
                end -- if annot
                local obj = classmanager.new(name, ...)
                desc.annot[clazz._name][name] = obj
                return obj
            end -- if desc
            error('Error getting object descriptor')
        end -- function annot
        setfenv(clazz.annot, env)
        
        ---------------
        -- Returning a private mixin (annotation) added by annot
        -- @function [parent=#clazz] getAnnot
        -- @param #table target the target object to query the annotation from
        -- @param #string name the class of the annotation
        -- @return #table the annotation object
        function clazz.getAnnot(target, name)
            local desc = objects[target]
            if desc ~= nil then
                if desc.annot[clazz._name] == nil then
                    return nil
                end -- if annot
                return desc.annot[clazz._name][name]
            end -- if desc
            error('Error getting object descriptor')
        end -- function getAnnot
        setfenv(clazz.getAnnot, env)
        
        ---------------
        -- Clears a mixin (annotation)
        -- @function [parent=#clazz] clearAnnot
        -- @param #table target the target object to remove the annotation
        -- @param #string name the class of the annotation
        -- @return #table the (removed) annotation object
        function clazz.clearAnnot(target, name)
            local desc = objects[target]
            if desc ~= nil then
                local old = nil
                if desc.annot[clazz._name] ~= nil then
                    old = desc.annot[clazz._name][name]
                    desc.annot[clazz._name][name] = nil
                end -- if annot
                return old
            end -- if desc
            error('Error getting object descriptor')
        end -- function clearAnnot
        setfenv(clazz.clearAnnot, env)
        
        return clazz
    end -- function class
    
    setfenv(errClass, env)
    setfenv(loadClassFile, env)
    setfenv(loadClass, env)
    setfenv(addObjMethods, env)
    setfenv(addPrivateMethods, env)
    setfenv(invokeCtor, env)
    setfenv(loadAndDefineClass, env)
    setfenv(construct, env)
    setfenv(wrapCLocalClazz, env)
    setfenv(wrapLocalClazz, env)
    setfenv(wrapPLocalClazz, env)
    setfenv(classmanager.require, env)
    setfenv(classmanager.addcp, env)
    setfenv(classmanager.get, env)
    setfenv(classmanager.new, env)
    setfenv(classmanager.load, env)
    setfenv(classmanager.findPackages, env)
    setfenv(classmanager.findClasses, env)
    setfenv(classmanager.defined, env)
    setfenv(classmanager.class, env)
    
    return classmanager
end -- function create
