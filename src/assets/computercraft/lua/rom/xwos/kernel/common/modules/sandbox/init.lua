-----------------------
-- @module xwos.kernel.sandbox
local M = {}

local kernel -- xwos.kernel#xwos.kernel
local processes = {}
local nextpid = 1
local originsert = table.insert
local origsize = table.getn
local origremove = table.removeValue
local origcocreate = coroutine.create
local origcoresume = coroutine.resume
local origyield = coroutine.yield

local timers = {}

---------------------------------
-- @function [parent=#xwos.kernel.sandbox] preboot
-- @param xwos.kernel#xwos.kernel k
M.preboot = function(k)
    k.debug("preboot sandbox")
    kernel = k
end -- function preboot

---------------------------------
-- @function [parent=#xwos.kernel.sandbox] boot
-- @param xwos.kernel#xwos.kernel k
M.boot = function(k)
    k.debug("boot sandbox")
end -- function boot

---------------------------------
-- spawn a process (call from inside secured sandbox)
-- @function spawn0
-- @param #process proc the process to spawn
-- @param #function func the function to be invoked
-- @param ... args function arguments
local function spawn0(proc, func, ...)
    kernel.debug("[PID"..proc.pid.."] called spawn0")
    -- TODO install global context wrappers; build sandbox
    
    kernel.debug("[PID"..proc.pid.."] procstate = running")
    proc.procstate = "running"
    
    kernel.debug("[PID"..proc.pid.."] calling func", func)
    local state, err = pcall(func, ...)
    ---------------------------------
    -- @field [parent=#process] #boolean state the state after finishing the process
    proc.state = state
    kernel.debug("[PID"..proc.pid.."] state = ", state)
    ---------------------------------
    -- @field [parent=#process] #any err the error returned by function call (if state is false)
    proc.err = err
    kernel.debug("[PID"..proc.pid.."] err = ", err)
    origremove(processes, proc)
    
    ---------------------------------
    -- @field [parent=#process] #string the process state; one of "preparing", "running" or "finished"
    kernel.debug("[PID"..proc.pid.."] procstate = finished")
    proc.procstate = "finished"
    kernel.origGlob.os.queueEvent("xwos_terminated", proc.pid)
end -- function spawn0

---------------------------------
-- spawn a process
-- @function spawn
-- @param #process proc the process to spawn
-- @param #function func the function to be invoked
-- @param ... args function arguments
local function spawn(proc, func, ...)
    kernel.debug("[PID"..proc.pid.."] calling spawnSandbox")
    kernel.spawnSandbox(spawn0, proc.env, nil, proc, func, ...) -- TODO whitelist from process builder instead of nil
end -- function spawn

---------------------------------
-- @function [parent=#xwos.kernel.sandbox] createProcess
-- @return xwos.kernel.sandbox#processbuilder new (empty) process builder
M.createProcessBuilder = function()
    ----------------------------------
    -- @type #processbuilder
    local r = {}
    local opts = {}
    
    ----------------------------------
    -- Sets the terminal to receive terminal requests
    -- @function [parent=#processbuilder] terminal
    -- @param #processterm term
    -- @return #processbuilder this for chaining
    r.terminal = function(term)
        opts.terminal = term
        return r
    end -- function terminal
    
    ----------------------------------
    -- Spawns a new process and execute functions within this new process
    -- @function [parent=#processbuilder] buildAndExecute
    -- @param #function func the function to be executed
    -- @param ... the arguments passed to the function
    -- @return #process the new process
    r.buildAndExecute = function(func, ...)
        local pid = nextpid
        kernel.debug("[PID"..pid.."] spawning new process", func, ...)
        nextpid = nextpid + 1
        --------------------------------------
        -- An isolated process
        -- @type process
        -- @field [parent=#process] #number pid process identification number
        local proc = { pid = pid }
        
        --------------------------------------
        -- @type xwosprm
        local prm = {
            --------------------------------------
            -- Returns the current pid
            -- @function [parent=#xwosprm] pid
            -- @return #number
            pid = function()
                return pid
            end
        }
        
        --------------------------------------
        -- @type xwos
        local xwos = {
            --------------------------------------
            -- Returns the process manager
            -- @function [parent=#xwos] prm
            -- @return #xwosprm
            prm = function()
                return prm
            end --  function prm
        }
        
        --------------------------------------
        -- @field [parent=#process] #table evqueue the process local event queue
        proc.evqueue = {}
        
        --------------------------------------
        -- wakeup process in reaction to events on local event queue
        -- @function [parent=#process] wakeup
        proc.wakeup = function()
            -- kernel.origGlob.os.queueEvent("xwos_wakeup", pid)
            if proc.coroutine ~= nil and proc.procstate ~= "finished" then
                kernel.origGlob.coroutine.resume(proc.coroutine)
            end -- if proc
        end -- function wakeup
        
        --------------------------------------
        -- request process to terminate
        -- @function [parent=#process] terminate
        proc.terminate = function()
            kernel.origGlob.queueEvent("xwos_terminate", pid)
        end -- function wakeup
        
        local function processEvt(event, filter)
            if event[1] == nil then
                return nil
            end -- if event
            kernel.debug("[PID"..pid.."] got event ", kernel.origGlob.unpack(event))
            
            if kernel.eventLog then
                local str = kernel.origGlob.os.day() .. "-" .. kernel.origGlob.os.time() " EVENT: ".. kernel.origGlob.textutils.serialize(event)
                local f = kernel.origGlob.fs.open("/core/log/event-log.txt", kernel.origGlob.fs.exists("/core/log/event-log.txt") and "a" or "w")
                f.writeLine(str)
                f.close()
            end -- if eventLog
            
            local consumed = false
            
            if event[1] == "timer" then
                for k, v in kernel.origGlob.pairs(timers) do
                    if v.proc == proc then
                        if filter == nil or event[1]==filter then
                            kernel.debug("[PID"..pid.."] returning event ", kernel.origGlob.unpack(event))
                            return event
                        else -- if filter
                            kernel.debug("[PID"..pid.."] discard event because of filter", kernel.origGlob.unpack(event))
                            consumed = true
                        end -- if filter
                    else -- if proc
                        kernel.debug("[PID"..pid.."] queue event for distribution to pid "..v.proc.pid, kernel.origGlob.unpack(event))
                        originsert(v.proc.evqueue, event)
                        v.proc.wakeup()
                        consumed = true
                    end -- if not proc
                end -- for timers
                -- fallthrough: distribute unknown timer event to all processes
            end -- if timer
            
            if event[1] == "xwos_wakeup" then
                consumed = true
                kernel.debug("[PID"..pid.."] wakeup received")
                if event[2] ~= pid then
                    kernel.debug("[PID"..pid.."] wrong pid, redistribute")
                    kernel.origGlob.os.queueEvent(kernel.origGlob.unpack(event))
                end -- if pid
            end -- if xwos_wakeup
            
            if event[1] == "xwos_terminate" then
                consumed = true
                kernel.debug("[PID"..pid.."] terminate received")
                if event[2] ~= pid then
                    kernel.debug("[PID"..pid.."] wrong pid, redistribute")
                    kernel.origGlob.os.queueEvent(kernel.origGlob.unpack(event))
                else -- if pid
                    error('requesting process termination')
                end -- if pid
            end -- if xwos_terminate
            
            if event[1] == "xwos_terminated" then
                consumed = true
                kernel.debug("[PID"..pid.."] terminated received")
                if filter == "xwos_terminated" then
                    kernel.debug("[PID"..pid.."] returning event ", kernel.origGlob.unpack(event))
                    return event
                end -- if filter
                for k, v in kernel.origGlob.pairs(processes) do
                    if v.pid == event[2] and v.joined > 0 then
                        kernel.debug("[PID"..pid.."] redistributing because at least one process called join")
                        kernel.origGlob.os.queueEvent(kernel.origGlob.unpack(event))
                    end --
                end -- for processes
            end -- if xwos_terminated
            
            -- distribute event to all processes
            if not consumed then
                for k, v in kernel.origGlob.pairs(processes) do
                    if v.procstate ~= "finished" then
                        kernel.debug("[PID"..pid.."] queue event for distribution to all pids "..v.pid, kernel.origGlob.unpack(event))
                        originsert(v.evqueue, event)
                        v.wakeup()
                    end -- if not finished
                end -- for processes
            end -- if consumed
            
            return nil
        end -- function processEvt
        
        --------------------------------------
        -- @type procenv
        -- @field [parent=#process] #procenv env the process start environment
        proc.env = {
            --------------------------------------
            -- @field [parent=#procenv] #xwos xwos
            xwos = xwos,
            sleep = function(nTime)
                kernel.debug("[PID"..pid.."] sleep", nTime)
                proc.env.os.sleep(nTime)
            end, -- function sleep
            os = {
                sleep = function(nTime)
                    kernel.debug("[PID"..pid.."] sleep", nTime)
                    if nTime ~= nil and kernel.origGlob.type( nTime ) ~= "number" then
                        kernel.origGlob.error( "bad argument #1 (expected number, got " .. kernel.origGlob.type( nTime ) .. ")", 2 )
                    end
                    local timer = proc.env.os.startTimer( nTime or 0 )
                    repeat
                        local sEvent, param = proc.env.os.pullEvent( "timer" )
                    until param == timer
                end, -- function sleep
                startTimer = function(s)
                    kernel.debug("[PID"..pid.."] startTimer", s)
                    local timer = kernel.origGlob.os.startTimer(s)
                    originsert(timers, {
                        id = timer,
                        proc = proc
                    })
                    return timer
                end, -- function os.startTimer
                pullEvent = function(filter)
                    kernel.debug("[PID"..pid.."] pullEvent", filter)
                    while true do
                        for k,v in kernel.origGlob.ipairs(proc.evqueue) do
                            local event = proc.evqueue[k]
                            proc.evqueue[k] = nil
                            if filter == nil or event[1]==filter then
                                kernel.debug("[PID"..pid.."] returning event from local event queue", kernel.origGlob.unpack(event))
                                return kernel.origGlob.unpack(event)
                            else -- if filter
                                kernel.debug("[PID"..pid.."] discard event from local event queue because of filter", kernel.origGlob.unpack(event))
                            end -- if filter
                        end -- for evqueue
                        
                        kernel.debug("[PID"..pid.."] invoke os.pullEvent ", filter)
                        local event = processEvt({kernel.origGlob.os.pullEvent()}, filter)
                        if event ~= nil then
                            return kernel.origGlob.unpack(event)
                        end -- if event
                    end -- endless loop
                end -- function os.pullEvent
            }
        }
        
        proc.state = true
        proc.procstate = "preparing"
        
        ------------------------------------------
        -- joins process and awaits it termination
        -- @function [parent=#process] join
        proc.join = function()
            kernel.debug("[PID"..pid.."] joining")
            proc.joined = proc.joined + 1
            while proc.procstate ~= "finished" do
                kernel.debug("[PID"..pid.."] waiting for finished (state="..proc.procstate..")")
                local event = processEvt({origyield()}, "xwos_terminated")
                if event ~= nil and event[2] ~= proc.pid then
                    for k, v in kernel.origGlob.pairs(processes) do
                        if v.pid == event[2] and v.joined > 0 then
                            kernel.debug("[PID"..pid.."] redistributing because at least one process called join")
                            kernel.origGlob.os.queueEvent(kernel.origGlob.unpack(event))
                        end --
                    end -- for processes
                end -- if pid
            end
            kernel.debug("[PID"..pid.."] received finish notification")
            proc.joined = proc.joined - 1
        end -- function join
        ------------------------------------------
        -- @field [parent=#process] #number joined number of processes having called joined
        proc.joined = 0
        
        -- start co routine
        kernel.debug("[PID"..pid.."] calling coroutine.create")
        proc.coroutine = origcocreate(spawn)
        
        -- save process into table
        kernel.debug("[PID"..pid.."] storing process inside process table")
        originsert(processes, proc)
        
        kernel.debug("[PID"..pid.."] calling coroutine.resume")
        local state, err = origcoresume(proc.coroutine, proc, func, ...)
        if not state then
            kernel.debug("[PID"..pid.."] corouting returned with error "..err)
            proc.err = err
            proc.state = state
            proc.procstate = "finished"
        end
        kernel.debug("[PID"..pid.."] returning new process")
        return proc
    end -- function buildAndExecute
    
    return r
end -- function createProcessBuilder

-- TODO possibility to "shutdown" a process

-- TODO type processterm

-- wrap lua console and wrap programs...

---- global functions
--orig.print = print
--orig.write = write
--orig.load = load
--orig.read = read
--orig.error = error
--orig.printError = printError
---- relevant for sandbox
--orig.dofile = dofile
--orig.loadfile = loadfile
--orig.loadstring = loadstring
--orig.rawset = rawset
--orig.rawget = rawget
--
---- computercraft apis
--orig.redstone = redstone
--orig.rs = rs -- alias for redstone
--orig.rednet = rednet
--orig.fs = fs
--orig.gps = gps
--orig.disk = disk
--orig.http = http
--orig.os = os
--orig.commands = commands
--orig.io = io
--orig.multishell = multishell
--orig.peripheral = peripheral
--orig.settings = settings
--orig.shell = shell
--orig.turtle = turtle
--orig.pocket = pocket
--
---- terminal management
--orig.term = term
--orig.paintutils = paintutils
--orig.textutils = textutils
--orig.window = window
--
---- threads etc.
--orig.parallel = parallel
--orig.setfenv = setfenv
--orig.getfenv = getfenv
--orig.xpcall = xpcall
--orig.pcall = pcall
--orig.coroutine = coroutine
--
-- Events:
-- alarm                http://computercraft.info/wiki/Alarm_(event)
-- char                 http://computercraft.info/wiki/Char_(event)
-- disk                 http://computercraft.info/wiki/Disk_(event)
-- disk_eject           http://computercraft.info/wiki/Disk_eject_(event)
-- http_failure         http://computercraft.info/wiki/Http_failure_(event)
-- http_success         http://computercraft.info/wiki/Http_success_(event)
-- key                  http://computercraft.info/wiki/Key_(event)
-- key_up               http://computercraft.info/wiki/Key_up_(event)
-- modem_message        http://computercraft.info/wiki/Modem_message_(event)           http://computercraft.info/wiki/Modem_(API)
-- monitor_resize       http://computercraft.info/wiki/Monitor_resize_(event)
-- monitor_touch        http://computercraft.info/wiki/Monitor_touch_(event)
-- mouse_click          http://computercraft.info/wiki/Mouse_click_(event)
-- mouse_drag           http://computercraft.info/wiki/Mouse_drag_(event)
-- mouse_scroll         http://computercraft.info/wiki/Mouse_scroll_(event)
-- mouse_up             http://computercraft.info/wiki/Mouse_up_(event)
-- paste                http://computercraft.info/wiki/Paste_(event)
-- peripheral           http://computercraft.info/wiki/Peripheral_(event)
-- peripheral_detach    http://computercraft.info/wiki/Peripheral_detach_(event)
-- rednet_message       http://computercraft.info/wiki/Rednet_message_(event)         http://computercraft.info/wiki/Rednet_(API)
-- redstone             http://computercraft.info/wiki/Redstone_(event)
-- task_complete        http://computercraft.info/wiki/Task_complete_(event)
-- term_resize          http://computercraft.info/wiki/Term_resize(Event)             http://computercraft.info/wiki/Term_(API)
-- terminate            http://computercraft.info/wiki/Terminate_(event)
-- timer                http://computercraft.info/wiki/Timer_(event)
-- turtle_inventory     http://computercraft.info/wiki/Turtle_inventory_(event)

return M