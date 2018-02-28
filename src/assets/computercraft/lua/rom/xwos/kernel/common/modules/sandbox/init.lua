-----------------------
-- @module xwos.kernel.sandbox
local M = {}

local kernel -- xwos.kernel#xwos.kernel
local processes = {}
local nextpid = 1
local originsert = table.insert
local origremove = table.removeValue
local origcocreate = coroutine.create
local origcoresume = coroutine.resume
local origyield = coroutine.yield

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
    -- TODO install global context wrappers; build sandbox
    
    proc.procstate = "running"
    local state, err = pcall(func, ...)
    ---------------------------------
    -- @field [parent=#process] #boolean state the state after finishing the process
    proc.state = state
    ---------------------------------
    -- @field [parent=#process] #any err the error returned by function call (if state is false)
    proc.err = err
    origremove(processes, proc)
    
    ---------------------------------
    -- @field [parent=#process] #string the process state; one of "preparing", "running" or "finished"
    proc.procstate = "finished"
end -- function spawn0

---------------------------------
-- spawn a process
-- @function spawn
-- @param #process proc the process to spawn
-- @param #function func the function to be invoked
-- @param ... args function arguments
local function spawn(proc, func, ...)
    kernel.spawnSandbox(spawn0, {}, proc, func, ...)
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
        nextpid = nextpid + 1
        --------------------------------------
        -- An isolated process
        -- @type process
        -- @field [parent=#process] #number pid process identification number
        local proc = { pid = pid }
        
        --------------------------------------
        -- @field [parent=#process] #table env the process start environment
        proc.env = {}
        
        proc.state = true
        proc.procstate = "preparing"
        
        -- save process into table
        originsert(processes, proc)
        
        ------------------------------------------
        -- joins process and awaits it termination
        -- @function [parent=#process] join
        proc.join = function()
            while proc.procstate ~= "finished" do
                origyield()
            end
        end -- function join
        
        -- start co routine
        proc.coroutine = origcocreate(spawn)
        origcoresume(proc.coroutine, proc, func, ...)
        
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