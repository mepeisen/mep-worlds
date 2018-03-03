
local cocreate = coroutine.create
local coresume = coroutine.resume
local origGetfenv = getfenv
local origSetfenv = setfenv
local origsetmeta = setmetatable
local origtype = type
local origdofile = dofile
local origpcall = pcall
local origpackage = package
local origser = textutils.serialize
local origpairs = pairs
local origyield = coroutine.yield

local kernel -- xwos.kernel#xwos.kernel

--------------------------------
-- local process environments
-- @type xwos.processes
local processes = {}

--------------------------------
-- next pid to use for new processes
local nextPid = 0

--------------------------------
-- creates a new process
-- @function [parent=#xwos.processes] new
-- @param xwos.kernel#xwos.kernel k the kernel table
-- @param #global env the global process environment
-- @param #table factories functions with signature (proc, env) to initialize the new process or environment
-- @return #xwos.process
processes.new = function(k, env, factories)
    kernel = k
    --------------------------------
    -- process type
    -- @type xwos.process
    local R = {}
    
    --------------------------------
    -- @field [parent=#xwos.process] #number pid the process id
    R.pid = nextPid
    nextPid = nextPid + 1
        
    --------------------------------------
    -- @field [parent=#xwos.process] #table evqueue the process local event queue
    R.evqueue = {}
    
    ------------------------------------------
    -- @field [parent=#xwos.process] #number joined number of processes having called method join
    R.joined = 0
    
    --------------------------------
    -- @field [parent=#xwos.process] #string procstate the process state; "initializing", "running" or "terminated"
    R.procstate = "initializing"
    kernel.debug("[PID"..R.pid.."] pocstate = initializing")
        
    --------------------------------------
    -- acquire input (front process)
    -- @function [parent=#xwos.process] acquireInput
    R.acquireInput = function()
        -- TODO is a stack always good?
        -- switching between processes (alt+tab in windows) is not meant to build a stack of input
        -- a stack of input will represent some kind of modal dialog over other modal dialog where closing one will pop up the previous one
        -- think about it...
        kernel.modules.instances.sandbox.procinput.acquire(R)
    end -- function acquireInput
        
    ------------------------------------------
    -- joins process and awaits it termination
    -- @function [parent=#process] join
    R.join = function()
        local env = origGetfenv(0)
        local cpid = env.pid or 0
        kernel.debug("[PID"..cpid.."] joining "..R.pid)
        R.joined = R.joined + 1
        while R.procstate ~= "finished" do
            kernel.debug("[PID"..cpid.."] waiting for finished of "..R.pid.." (state="..R.procstate..")")
            local event = kernel.modules.instances.sandbox.evqueue.processEvt(cpid, kernel.processes[cpid], {origyield()}, "xwos_terminated")
            if event ~= nil and event[2] ~= R.pid then
                for k, v in kernel.oldGlob.pairs(processes) do
                    if kernel.oldGlob.type(v)=="table" and v.pid == event[2] and v.joined > 0 then
                        kernel.debug("[PID"..cpid.."] redistributing because at least one process called join of "..R.pid)
                        kernel.oldGlob.os.queueEvent(kernel.oldGlob.unpack(event))
                    end --
                end -- for processes
            end -- if pid
        end
        kernel.debug("[PID"..R.pid.."] received finish notification")
        R.joined = R.joined - 1
    end -- function join
        
    --------------------------------------
    -- release input (front process)
    -- @function [parent=#xwos.process] releaseInput
    R.releaseInput = function()
        kernel.modules.instances.sandbox.procinput.current.release(R)
    end -- function acquireInput
        
    --------------------------------------
    -- wakeup process in reaction to events on local event queue
    -- @function [parent=#xwos.process] wakeup
    R.wakeup = function()
        if R.co ~= nil and R.procstate ~= "finished" then
            kernel.debug("[PID"..R.pid.."] wakeup requested")
            kernel.oldGlob.coroutine.resume(R.co)
        end -- if proc
    end -- function wakeup
        
    --------------------------------------
    -- request process to terminate
    -- @function [parent=#xwos.process] terminate
    R.terminate = function()
        kernel.oldGlob.os.queueEvent("xwos_terminate", R.pid)
    end -- function wakeup
    
    --------------------------------
    -- Remove the process from process table
    -- @function [parent=#xwos.process] remove
    R.remove = function()
        kernel.debug("[PID"..R.pid.."] removing from process table")
        processes[R.pid] = nil
    end -- function remove
    
    --------------------------------
    -- Spawn the process (invoke function)
    -- @function [parent=#xwos.process] spawn
    -- @param #function func the function to invoke
    -- @param ... the arguments for given function
    R.spawn = function(func, ...)
        kernel.debug("[PID"..R.pid.."] prepare spawn")
        -- TODO ... may contain functions and objects with metatables; this may cause problems by mxing environments
        -- establish an alternative for IPC (inter process communication)
        local res = {origpcall(origser, {...})}-- this will cause an error if serializing forbidden types (functions etc.)
        if not res[1] then
            kernel.debug("[PID"..R.pid.."] ERR:", res[2])
            kernel.debug("[PID"..R.pid.."] pocstate = finished")
            R.result = res
            R.procstate = "finished"
            return
        end -- if not res
        
        local nenv = {}
        local nenvmt = {
            __index = function(table, key)
                if key == "pid" then
                    return R.pid
                end -- if pid
                return env[key]
            end -- function __index
        }
        origsetmeta(nenv, nenvmt)
        origSetfenv(nenvmt.__index, nenv)
        local spawn0 = function(...)
            kernel.debug("[PID"..R.pid.."] pocstate = running")
            R.procstate = "running"
            origSetfenv(0, nenv)
            origSetfenv(1, nenv)
            for k, v in origpairs(factories) do
                kernel.debug("[PID"..R.pid.."] invoke factory", k, v)
                v(R, nenv)
            end -- for factories
            if origtype(func) == "string" then
                local func2 = function(...)
                    kernel.debug("[PID"..R.pid.."] doFile", func)
                    return origdofile(func, ...)
                end -- function func2
                origSetfenv(func2, nenv)
                --------------------------------
                -- @field [parent=#xwos.process] #table result the return state from process function
                R.result = {origpcall(func2, ...)}
            else -- if string
                kernel.debug("[PID"..R.pid.."] invoke function", func)
                R.result = {origpcall(func, ...)}
            end -- if string
            kernel.debug("[PID"..R.pid.."] pocstate = finished")
            if not R.result[1] then
                kernel.debug("[PID"..R.pid.."] ERR:", R.result[2])
            end -- if not res
            R.procstate = "finished"
        end -- function spawn0
        nenv.getfenv = function(n)
            local t = origtype(n)
            if t == "number" then
                if n == 0 then
                    return nenv
                end -- if 0
            end -- if number
            return origGetfenv(n)
        end -- function get
        nenv.setfenv = function(n, v)
            -- TODO maybe we can compare current fenv with THIS nenv and nenv from kernel;
            -- if matches we deny changing the fenv
            -- if not matches we allow changing because it was loaded inside process
            
            -- do not allow changing fenv at all
            -- simply return current one
            return origGetfenv(n, v)
        end -- function setfenv
        kernel.debug("[PID"..R.pid.."] prepare package")
        nenv.package = {}
        -- taken from bios.lua; must be overriden because of env
        -- TODO maybe we find a better solution than copying all the stuff
        nenv.package.loaded = {
            -- _G = _G,
            bit32 = bit32,
            coroutine = coroutine, -- TODO wrap
            math = math,
            package = nenv.package,
            string = string,
            table = table,
        }
        -- TODO paths
        nenv.package.path = "?;?.lua;?/init.lua;/rom/modules/main/?;/rom/modules/main/?.lua;/rom/modules/main/?/init.lua"
        if turtle then
            nenv.package.path = nenv.package.path..";/rom/modules/turtle/?;/rom/modules/turtle/?.lua;/rom/modules/turtle/?/init.lua"
        elseif command then
            nenv.package.path = nenv.package.path..";/rom/modules/command/?;/rom/modules/command/?.lua;/rom/modules/command/?/init.lua"
        end
        nenv.package.config = "/\n;\n?\n!\n-"
        nenv.package.preload = {}
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
        nenv.package.loaders = {
            loader1,
            loader2
        }
  
        local sentinel = {}
        nenv.require = function( name )
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
        
        kernel.debug("[PID"..R.pid.."] setting new env")
        origSetfenv(spawn0, nenv)
        origSetfenv(loader1, nenv)
        origSetfenv(loader2, nenv)
        origSetfenv(nenv.require, nenv)
        origSetfenv(nenv.getfenv, nenv)
        origSetfenv(nenv.setfenv, nenv)
        --------------------------------
        -- @field [parent=#xwos.process] coroutine#coroutine co the coroutine
        R.co = cocreate(spawn0)
        local res = {coresume(R.co, ...)}
        if not res[1] then
            kernel.debug("[PID"..R.pid.."] ERR:", res[2])
            kernel.debug("[PID"..R.pid.."] pocstate = finished")
            R.result = res
            R.procstate = "finished"
        end -- if not res
    end -- function spawn
    
    --------------------------------
    -- @field [parent=#xwos.process] #global env the process environment
    R.env = env
    
    processes[R.pid] = R
    kernel.debug("[PID"..R.pid.."] returning new process")
    return R
end -- function new

return processes
