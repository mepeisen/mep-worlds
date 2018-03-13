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

local cocreate = coroutine.create
local coresume = coroutine.resume
local getfenv = getfenv
local setfenv = setfenv
local setmetatable = setmetatable
local type = type
local dofile = dofile
local loadfile = loadfile
local pcall = pcall
local origpackage = package
local print = print
local error = error
local origser = textutils.serialize
local pairs = pairs
local origyield = coroutine.yield
local originsert = table.insert
local origqueue = os.queueEvent

-- TODO hide xwos.kernel.process constructor (only allow instantiation from xwos.kernel.processes functions) 

--------------------------------
-- local process environments
-- @module xwos.kernel.process
_CMR.class("xwos.kernel.process")

------------------------
-- the object privates
-- @type procprivates

------------------------
-- the internal class
-- @type procintern
-- @extends #xwos.kernel.process

.ctor(
------------------------
-- create new process
-- @function [parent=#procintern] __ctor
-- @param #xwos.kernel.processes self self
-- @param classmanager#clazz clazz proc class
-- @param #procprivates privates
-- @param #xwprocsprivates pprivates
-- @param #xwos.kernel.process p the parent process
-- @param xwos.kernel#xwos.kernel k the kernel table
-- @param #number newPid the new pid to be used by this process
-- @param global#global env the global process environment
-- @param #table factories functions with signature (proc, env) to initialize the new process or environment
function(self, clazz, privates, pprivates, p, k, newPid, env, factories)
    --------------------------------
    -- the debug string for prefixing debug messages
    -- @field [parent=#procprivates] #string dstr
    privates.dstr = "[PID"..newPid.."]"
    
    --------------------------------
    -- the process id
    -- @field [parent=#procprivates] #number pid
    privates.pid = newPid
    
    --------------------------------
    -- the process table
    -- @field [parent=#procprivates] #xwprocsprivates processes
    privates.processes = pprivates
    
    --------------------------------------
    -- the process local event queue
    -- @field [parent=#procprivates] #table evqueue
    privates.evqueue = {}
    
    ------------------------------------------
    -- number of processes having called method join
    -- @field [parent=#procprivates] #number joined 
    privates.joined = 0
    
    --------------------------------
    -- the parent process
    -- @field [parent=#procprivates] #xwos.kernel.process parent
    privates.parent = p
    
    --------------------------------
    -- the kernel reference
    -- @field [parent=#procprivates] xwos.kernel#xwos.kernel kernel
    privates.kernel = k
    
    --------------------------------
    -- the original process environment given to create function
    -- @field [parent=#procprivates] #global origenv
    privates.origenv = env
    
    --------------------------------
    -- functions with signature (proc, env) to initialize the new process or environment
    -- @field [parent=#procprivates] #table factories
    privates.factories = factories
    
    --------------------------------
    -- the process state; "initializing", "running" or "terminated"
    -- @field [parent=#procprivates] #string procstate 
    privates.procstate = "initializing"
    privates:debug("pocstate =", privates.procstate)
    
    --------------------------------
    -- the process environment used globally in this process
    -- @field [parent=#procprivates] global#global env
    privates.env = { pid = privates.pid }
    privates:debug("env =", privates.env)
    
    local nenvmt = {
        __index = function(table, key)
            local res = privates.origenv[key]
            if res == nil then
                if privates.parent ~= nil then
                    -- parent should at least lead to PID 0. PID 0 already should contain all the visible and public globals all processes are allowed to use
                    res = privates.parent.env[key]
                end -- if parent
            end -- if not res (env)
            return res
        end -- function __index
    }
    setmetatable(privates.env, nenvmt)
    setfenv(nenvmt.__index, privates.env)
    
end) -- ctor

-------------------------------
-- checks if process is finished
-- @function [parent=#xwos.kernel.process] isFinished
-- @param #xwos.kernel.process self the process object
-- @return #boolean

.func("isFinished",
-------------------------------
-- @function [parent=#procintern] isFinished
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
-- @return #boolean
function(self, clazz, privates)
    -- TODO
end) -- function isFinished

-------------------------------
-- checks if process has some other processes waiting for termination (joined)
-- @function [parent=#xwos.kernel.process] hasJoined
-- @param #xwos.kernel.process self the process object
-- @return #boolean

.func("hasJoined",
-------------------------------
-- @function [parent=#procintern] hasJoined
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
-- @return #boolean
function(self, clazz, privates)
    -- TODO
end) -- function hasJoined

-------------------------------
-- pop event from event queue
-- @function [parent=#xwos.kernel.process] popev
-- @param #xwos.kernel.process self the process object
-- @return #table event

.func("popev",
-------------------------------
-- @function [parent=#procintern] popev
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
-- @return #table
function(self, clazz, privates)
    -- TODO
end) -- function popev

-------------------------------
-- pop event from event queue
-- @function [parent=#xwos.kernel.process] popev
-- @param #xwos.kernel.process self the process object
-- @param #table event

.func("pushev",
-------------------------------
-- @function [parent=#procintern] pushev
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
-- @param #table
function(self, clazz, privates, event)
    -- TODO
end) -- function pushev

-------------------------------
-- return process pid
-- @function [parent=#xwos.kernel.process] pid
-- @param #xwos.kernel.process self the process object
-- @return #number

.func("pid",
-------------------------------
-- @function [parent=#procintern] pid
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
-- @return #number
function(self, clazz, privates)
    return privates.pid
end) -- function debug

-------------------------------
-- debug log message
-- @function [parent=#xwos.kernel.process] debug
-- @param #xwos.kernel.process self the process object
-- @param ... print message arguments

.func("debug",
-------------------------------
-- @function [parent=#procintern] debug
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
-- @param ...
function(self, clazz, privates, ...)
    privates.kernel:debug(privates.dstr, ...)
end) -- function debug

--------------------------------------
-- acquire input (front process)
-- @function [parent=#xwos.kernel.process] acquireInput
-- @param #xwos.kernel.process self the process object

.func("acquireInput",
--------------------------------------
-- @function [parent=#procintern] acquireInput
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
function(self, clazz, privates)
    -- TODO is a stack always good?
    -- switching between processes (alt+tab in windows) is not meant to build a stack of input
    -- a stack of input will represent some kind of modal dialog over other modal dialog where closing one will pop up the previous one
    -- think about it...
    privates.kernel.modules.instances.sandbox.procinput:acquire(self)
end) -- function acquireInput

------------------------------------------
-- joins process and awaits it termination
-- @function [parent=#xwos.kernel.process] join
-- @param #xwos.kernel.process self the process object
-- @param #xwos.kernel.process cproc calling process

.func("join",
------------------------------------------
-- @function [parent=#procintern] join
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
-- @param #xwos.kernel.process cproc
function(self, clazz, privates, cproc)
    local cpid = "*"
    if cproc ~= nil then
        cpid = cproc.pid
    end -- if cproc
    local sdbg = "[PID"..cpid.."]"
    local dbg = function(...) privates.kernel:debug(sdbg, ...) end
    dbg("joining", privates.pid)
    privates.joined = privates.joined + 1
    while privates.procstate ~= "finished" do
        dbg("waiting for finished of ", privates.pid, " (state=", privates.procstate, ")")
        local event = privates.kernel.modules.instances.sandbox.evqueue:processEvt(cpid, cproc, {origyield()}, "xwos_terminated")
        if event ~= nil and event[2] ~= privates.pid then
            for k, v in privates.processes.list:iterate() do
                if type(v)=="table" and v.pid == event[2] and v.joined > 0 then
                    dbg("redistributing to all other processes because at least one process called join of", privates.pid)
                    
                    for k2, v2 in privates.processes.list:iterate() do
                        if type(v2) == "table" and v2 ~= cproc and v2.procstate~= "finished" then
                            dbg("redistributing because at least one process called join of", privates.pid)
                            v2:pushev(event)
                            v2:wakeup()
                        end --
                    end -- for processes
                end --
            end -- for processes
        end -- if pid
    end
    dbg("received finish notification or", privates.pid)
    privates.joined = privates.joined - 1
end) -- function join
        
--------------------------------------
-- release input (front process)
-- @function [parent=#xwos.kernel.process] releaseInput
-- @param #xwos.kernel.process self the process object

.proc("releaseInput",
--------------------------------------
-- @function [parent=#procintern] releaseInput
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
function(self, clazz, privates)
    privates.kernel.modules.instances.sandbox.procinput:release(self)
end) -- function acquireInput
        
--------------------------------------
-- wakeup process in reaction to events on local event queue
-- @function [parent=#xwos.kernel.process] wakeup
-- @param #xwos.kernel.process self the process object

.proc("wakeup",
--------------------------------------
-- @function [parent=#procintern] wakeup
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
function(self, clazz, privates)
    if privates.co ~= nil and privates.procstate ~= "finished" then
        self:debug("wakeup requested")
        coresume(privates.co)
    end -- if proc
end) -- function wakeup
        
--------------------------------------
-- request process to terminate
-- @function [parent=#xwos.kernel.process] terminate
-- @param #xwos.kernel.process self the process object

.func("terminate",
--------------------------------------
-- @function [parent=#procintern] terminate
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
function(self, clazz, privates)
    origqueue("xwos_terminate", privates.pid)
end) -- function wakeup
    
--------------------------------
-- Remove the process from process table
-- @function [parent=#xwos.kernel.process] remove
-- @param #xwos.kernel.process self the process object

.func("remove",
--------------------------------
-- @function [parent=#procintern] remove
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
function(self, clazz, privates)
    self:debug("removing from process table")
    privates.processes.procs[privates.pid] = nil
    privates.processes.list:remove(self)
end) -- function remove
    
--------------------------------
-- Spawn the process (invoke function)
-- @function [parent=#xwos.kernel.process] spawn
-- @param #xwos.kernel.process self the process object
-- @param #function func the function to invoke
-- @param ... the arguments for given function

.func("spawn",
--------------------------------
-- @function [parent=#procintern] spawn
-- @param #xwos.kernel.process self
-- @param classmanager#clazz clazz
-- @param #procprivates privates
-- @param #function func the function to invoke
-- @param ... the arguments for given function
function(self, clazz, privates, func, ...)
    local env0 = privates.kernel.nenv
    self:debug("prepare spawn")
    -- TODO ... may contain functions and objects with metatables; this may cause problems by mxing environments
    -- establish an alternative for IPC (inter process communication)
    local res = {pcall(origser, {...})}-- this will cause an error if serializing forbidden types (functions etc.)
    if not res[1] then
        self:debug("ERR:", res[2])
        self.result = res
        privates.procstate = "finished"
        self:debug("pocstate", privates.procstate)
        origqueue("xwos_terminated", privates.pid)
        return
    end -- if not res
    
    local spawn0 = function(...)
        privates.procstate = "running"
        self:debug("pocstate", privates.procstate)
        self:debug("using env", privates.env, env0)
        setfenv(0, privates.env)
        for k, v in pairs(privates.factories) do
            self:debug("invoke factory", k, v)
            v(self, privates.env)
        end -- for factories
        if type(func) == "string" then
            local func2 = function(...)
                self:debug("doFile", func)
                local fnFile, e = loadfile(func, privates.kernel.nenv)
                if fnFile then
                    return fnFile()
                else -- if res
                    error( e, 2 )
                end -- if not res
                return dofile(func, ...)
            end -- function func2
            setfenv(func2, privates.kernel.nenv)
            --------------------------------
            -- the return state from process function
            -- @field [parent=#xwos.kernel.process] #table result
            self.result = {pcall(func2, ...)}
        else -- if string
            self:debug("invoke function", func)
            self.result = {pcall(func, ...)}
        end -- if string
        if not self.result[1] then
            self:debug("ERR:", self.result[2])
        end -- if not res
        privates.procstate = "finished"
        self:debug("pocstate", privates.procstate)
        origqueue("xwos_terminated", privates.pid)
    end -- function spawn0
    privates.env.getfenv = function(n)
        -- TODO: Hide kernel.nenv because one may decide to manipulate it to inject variables into other threads :-(
        local t = type(n)
        if t == "number" then
            if n == 0 then
                return privates.kernel.nenv
            end -- if 0
        end -- if number
        return getfenv(n)
    end -- function get
    privates.env.setfenv = function(n, v)
        -- TODO maybe we can compare current fenv with THIS nenv and nenv from kernel;
        -- if matches we deny changing the fenv
        -- if not matches we allow changing because it was loaded inside process
        
        -- for the moment: do not allow changing fenv at all
        -- simply return current one
        return privates.env.getfenv(n, v)
    end -- function setfenv
    
    self:debug("prepare package")
    privates.env.package = {}
    -- taken from bios.lua; must be overriden because of env
    -- TODO maybe we find a better solution than copying all the stuff
    privates.env.package.loaded = {
        -- _G = _G,
        bit32 = bit32,
        coroutine = coroutine, -- TODO wrap with out own process env
        math = math,
        package = privates.env.package,
        string = string,
        table = table,
    }
    -- TODO paths
    privates.env.package.path = "?;?.lua;?/init.lua;/rom/modules/main/?;/rom/modules/main/?.lua;/rom/modules/main/?/init.lua"
    if turtle then
        privates.env.package.path = privates.env.package.path..";/rom/modules/turtle/?;/rom/modules/turtle/?.lua;/rom/modules/turtle/?/init.lua"
    elseif command then
        privates.env.package.path = privates.env.package.path..";/rom/modules/command/?;/rom/modules/command/?.lua;/rom/modules/command/?/init.lua"
    end
    privates.env.package.config = "/\n;\n?\n!\n-"
    privates.env.package.preload = {}
    local loader1 =  function( name )
        if package.preload[name] then
            return package.preload[name]
        else
            return nil, "no field package.preload['" .. name .. "']"
        end
    end -- function loader1
    local loader2 =  function( name )
        local fname = string.gsub(name, "%.", "/")
        local sError = ""
        for pattern in string.gmatch(package.path, "[^;]+") do
            local sPath = string.gsub(pattern, "%?", fname)
            if sPath:sub(1,1) ~= "/" then
                sPath = fs.combine(sDir, sPath)
            end
            if fs.exists(sPath) and not fs.isDir(sPath) then
                local fnFile, sError = loadfile( sPath, nenv ) -- inject our new env
                if fnFile then
                    return fnFile, sPath
                else
                    return nil, sError
                end
            else
                if #sError > 0 then
                    sError = sError .. "\n"
                end
                sError = sError .. "no file '" .. sPath .. "'"
            end
        end
        return nil, sError
    end -- function loader2
    privates.env.package.loaders = {
        loader1,
        loader2
    }

    local sentinel = {}
    privates.env.require = function( name )
        if type( name ) ~= "string" then
            error( "bad argument #1 (expected string, got " .. type( name ) .. ")", 2 )
        end
        if package.loaded[name] == sentinel then
            error("Loop detected requiring '" .. name .. "'", 0)
        end
        if package.loaded[name] then
            return package.loaded[name]
        end
  
        local sError = "Error loading module '" .. name .. "':"
        for n,searcher in ipairs(package.loaders) do
            local loader, err = searcher(name)
            if loader then
                package.loaded[name] = sentinel
                local result = loader( err )
                if result ~= nil then
                    package.loaded[name] = result
                    return result
                else
                    package.loaded[name] = true
                    return true
                end
            else
                sError = sError .. "\n" .. err
            end
        end
        error(sError, 2)
    end -- function require
    
    self:debug("setting new env", env0)
    setfenv(spawn0, env0)
    setfenv(loader1, env0)
    setfenv(loader2, env0)
    setfenv(privates.env.require, env0)
    setfenv(privates.env.getfenv, env0)
    setfenv(privates.env.setfenv, env0)
    --------------------------------
    -- co the coroutine
    -- @field [parent=#procprivates] coroutine#coroutine
    privates.co = cocreate(spawn0)
    local res = {coresume(privates.co, ...)}
    if not res[1] then
        self:debug("ERR:", res[2])
        self.result = res
        privates.procstate = "finished"
        self:debug("pocstate", privates.procstate)
        origqueue("xwos_terminated", privates.pid)
    end -- if not res
end) -- function spawn

return nil
