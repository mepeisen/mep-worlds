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

-- TODO refactor following to some linked stack type
-----------------------
-- process input type with mapping to previous input
-- @type procinput
local procinput = nil

local function acquireInput(proc)
    -- first invocation has no kernel
    if kernel ~= nil and pid ~= nil then
        kernel.debug("[PID"..proc.pid.."] fetching user input (front process)")
    end -- if kernel
    local r = {}
    ---------------------
    -- release input if proc blocks it
    -- @function [parent=#procinput] release
    -- @param #process proc process to release the env
    r.release = function(proc2)
        if r.proc == proc2 then
            kernel.debug("[PID"..proc2.pid.."] releasing user input (front process)")
            procinput = r.prev
            while procinput.proc ~= nil and procinput.proc.procstate == "finished" do
                procinput = procinput.prev
            end -- while finished
            if procinput.proc ~= nil then
                kernel.debug("[PID"..proc2.pid.."] switched user input to "..procinput.proc.pid.." (front process)")
            end -- if proc
        end -- if proc
    end -- function release
    ----------------------------------
    -- @field [parent=#procinput] #procinput prev the previous input
    r.prev = procinput
    -----------------------
    -- @field [parent=#procinput] #process proc the input process
    r.proc = proc
    procinput = r
end -- function acquireInput

acquireInput(nil)

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
    
    procinput.release(proc)
    
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
        
        --------------------------------------
        -- acquire input (front process)
        -- @function [parent=#process] acquireInput
        proc.acquireInput = function()
            -- TODO is a stack always good?
            -- switching between processes (alt+tab in windows) is not meant to build a stack of input
            -- a stack of input will represent some kind of modal dialog over other modal dialog where closing one will pop up the previous one
            -- think about it...
            acquireInput(proc)
        end -- function acquireInput
        
        --------------------------------------
        -- release input (front process)
        -- @function [parent=#process] releaseInput
        proc.releaseInput = function()
            procinput.release(proc)
        end -- function acquireInput
        
        local function processEvt(lpid, event, filter)
            if event[1] == nil then
                return nil
            end -- if event
            kernel.debug("[PID"..lpid.."] got event ", kernel.origGlob.unpack(event))
            
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
                            kernel.debug("[PID"..lpid.."] returning event ", kernel.origGlob.unpack(event))
                            return event
                        else -- if filter
                            kernel.debug("[PID"..lpid.."] discard event because of filter", kernel.origGlob.unpack(event))
                            consumed = true
                        end -- if filter
                    else -- if proc
                        kernel.debug("[PID"..lpid.."] queue event for distribution to pid "..v.proc.pid, kernel.origGlob.unpack(event))
                        originsert(v.proc.evqueue, event)
                        v.proc.wakeup()
                        consumed = true
                    end -- if not proc
                end -- for timers
                -- fallthrough: distribute unknown timer event to all processes
            end -- if timer
            
            if event[1] == "xwos_wakeup" then
                consumed = true
                kernel.debug("[PID"..lpid.."] wakeup received")
                if event[2] ~= lpid then
                    kernel.debug("[PID"..lpid.."] wrong pid, redistribute")
                    kernel.origGlob.os.queueEvent(kernel.origGlob.unpack(event))
                end -- if pid
            end -- if xwos_wakeup
            
            if event[1] == "xwos_terminate" then
                consumed = true
                kernel.debug("[PID"..lpid.."] terminate received")
                if event[2] ~= lpid then
                    kernel.debug("[PID"..lpid.."] wrong pid, redistribute")
                    kernel.origGlob.os.queueEvent(kernel.origGlob.unpack(event))
                else -- if pid
                    error('requesting process termination')
                end -- if pid
            end -- if xwos_terminate
            
            if event[1] == "xwos_terminated" then
                consumed = true
                kernel.debug("[PID"..lpid.."] terminated received")
                if filter == "xwos_terminated" then
                    kernel.debug("[PID"..lpid.."] returning event ", kernel.origGlob.unpack(event))
                    return event
                end -- if filter
                for k, v in kernel.origGlob.pairs(processes) do
                    if v.pid == event[2] and v.joined > 0 then
                        kernel.debug("[PID"..lpid.."] redistributing because at least one process called join")
                        kernel.origGlob.os.queueEvent(kernel.origGlob.unpack(event))
                    end --
                end -- for processes
            end -- if xwos_terminated
            
            if event[1] == "char" or event[1] == "key" or event[1] == "paste" or event[1] == "key_up" then
                consumed = true
                kernel.debug("[PID"..lpid.."] user input received")
                if procinput.proc ~= nil then
                    kernel.debug("[PID"..lpid.."] queue event for distribution to user input pid "..procinput.proc.pid)
                    originsert(procinput.proc.evqueue, event)
                    procinput.proc.wakeup()
                else
                    -- TODO what to do with input if no one likes it?
                    -- think about special key bindings fetched from background processes
                    -- currently we silently discard that kind of input
                end -- 
            end -- if char
            
            -- distribute event to all processes
            if not consumed then
                for k, v in kernel.origGlob.pairs(processes) do
                    if v.procstate ~= "finished" then
                        kernel.debug("[PID"..lpid.."] queue event for distribution to all pids "..v.pid, kernel.origGlob.unpack(event))
                        originsert(v.evqueue, event)
                        v.wakeup()
                    end -- if not finished
                end -- for processes
            end -- if consumed
            
            return nil
        end -- function processEvt
        
        -- this is original code from bios.
        -- we need to redeclare it to get into wrapped os.**** methods
        -- maybe in future we find a solution to not redeclare it here
        local function biosRead( _sReplaceChar, _tHistory, _fnComplete, _sDefault )
            if _sReplaceChar ~= nil and type( _sReplaceChar ) ~= "string" then
                error( "bad argument #1 (expected string, got " .. type( _sReplaceChar ) .. ")", 2 ) 
            end
            if _tHistory ~= nil and type( _tHistory ) ~= "table" then
                error( "bad argument #2 (expected table, got " .. type( _tHistory ) .. ")", 2 ) 
            end
            if _fnComplete ~= nil and type( _fnComplete ) ~= "function" then
                error( "bad argument #3 (expected function, got " .. type( _fnComplete ) .. ")", 2 ) 
            end
            if _sDefault ~= nil and type( _sDefault ) ~= "string" then
                error( "bad argument #4 (expected string, got " .. type( _sDefault ) .. ")", 2 ) 
            end
            term.setCursorBlink( true )
        
            local sLine
            if type( _sDefault ) == "string" then
                sLine = _sDefault
            else
                sLine = ""
            end
            local nHistoryPos
            local nPos = #sLine
            if _sReplaceChar then
                _sReplaceChar = string.sub( _sReplaceChar, 1, 1 )
            end
        
            local tCompletions
            local nCompletion
            local function recomplete()
                if _fnComplete and nPos == string.len(sLine) then
                    tCompletions = _fnComplete( sLine )
                    if tCompletions and #tCompletions > 0 then
                        nCompletion = 1
                    else
                        nCompletion = nil
                    end
                else
                    tCompletions = nil
                    nCompletion = nil
                end
            end
        
            local function uncomplete()
                tCompletions = nil
                nCompletion = nil
            end
        
            local w = term.getSize()
            local sx = term.getCursorPos()
        
            local function redraw( _bClear )
                local nScroll = 0
                if sx + nPos >= w then
                    nScroll = (sx + nPos) - w
                end
        
                local cx,cy = term.getCursorPos()
                term.setCursorPos( sx, cy )
                local sReplace = (_bClear and " ") or _sReplaceChar
                if sReplace then
                    term.write( string.rep( sReplace, math.max( string.len(sLine) - nScroll, 0 ) ) )
                else
                    term.write( string.sub( sLine, nScroll + 1 ) )
                end
        
                if nCompletion then
                    local sCompletion = tCompletions[ nCompletion ]
                    local oldText, oldBg
                    if not _bClear then
                        oldText = term.getTextColor()
                        oldBg = term.getBackgroundColor()
                        term.setTextColor( colors.white )
                        term.setBackgroundColor( colors.gray )
                    end
                    if sReplace then
                        term.write( string.rep( sReplace, string.len( sCompletion ) ) )
                    else
                        term.write( sCompletion )
                    end
                    if not _bClear then
                        term.setTextColor( oldText )
                        term.setBackgroundColor( oldBg )
                    end
                end
        
                term.setCursorPos( sx + nPos - nScroll, cy )
            end
            
            local function clear()
                redraw( true )
            end
        
            recomplete()
            redraw()
        
            local function acceptCompletion()
                if nCompletion then
                    -- Clear
                    clear()
        
                    -- Find the common prefix of all the other suggestions which start with the same letter as the current one
                    local sCompletion = tCompletions[ nCompletion ]
                    sLine = sLine .. sCompletion
                    nPos = string.len( sLine )
        
                    -- Redraw
                    recomplete()
                    redraw()
                end
            end
            while true do
                local sEvent, param = os.pullEvent()
                if sEvent == "char" then
                    -- Typed key
                    clear()
                    sLine = string.sub( sLine, 1, nPos ) .. param .. string.sub( sLine, nPos + 1 )
                    nPos = nPos + 1
                    recomplete()
                    redraw()
        
                elseif sEvent == "paste" then
                    -- Pasted text
                    clear()
                    sLine = string.sub( sLine, 1, nPos ) .. param .. string.sub( sLine, nPos + 1 )
                    nPos = nPos + string.len( param )
                    recomplete()
                    redraw()
        
                elseif sEvent == "key" then
                    if param == keys.enter then
                        -- Enter
                        if nCompletion then
                            clear()
                            uncomplete()
                            redraw()
                        end
                        break
                        
                    elseif param == keys.left then
                        -- Left
                        if nPos > 0 then
                            clear()
                            nPos = nPos - 1
                            recomplete()
                            redraw()
                        end
                        
                    elseif param == keys.right then
                        -- Right                
                        if nPos < string.len(sLine) then
                            -- Move right
                            clear()
                            nPos = nPos + 1
                            recomplete()
                            redraw()
                        else
                            -- Accept autocomplete
                            acceptCompletion()
                        end
        
                    elseif param == keys.up or param == keys.down then
                        -- Up or down
                        if nCompletion then
                            -- Cycle completions
                            clear()
                            if param == keys.up then
                                nCompletion = nCompletion - 1
                                if nCompletion < 1 then
                                    nCompletion = #tCompletions
                                end
                            elseif param == keys.down then
                                nCompletion = nCompletion + 1
                                if nCompletion > #tCompletions then
                                    nCompletion = 1
                                end
                            end
                            redraw()
        
                        elseif _tHistory then
                            -- Cycle history
                            clear()
                            if param == keys.up then
                                -- Up
                                if nHistoryPos == nil then
                                    if #_tHistory > 0 then
                                        nHistoryPos = #_tHistory
                                    end
                                elseif nHistoryPos > 1 then
                                    nHistoryPos = nHistoryPos - 1
                                end
                            else
                                -- Down
                                if nHistoryPos == #_tHistory then
                                    nHistoryPos = nil
                                elseif nHistoryPos ~= nil then
                                    nHistoryPos = nHistoryPos + 1
                                end                        
                            end
                            if nHistoryPos then
                                sLine = _tHistory[nHistoryPos]
                                nPos = string.len( sLine ) 
                            else
                                sLine = ""
                                nPos = 0
                            end
                            uncomplete()
                            redraw()
        
                        end
        
                    elseif param == keys.backspace then
                        -- Backspace
                        if nPos > 0 then
                            clear()
                            sLine = string.sub( sLine, 1, nPos - 1 ) .. string.sub( sLine, nPos + 1 )
                            nPos = nPos - 1
                            recomplete()
                            redraw()
                        end
        
                    elseif param == keys.home then
                        -- Home
                        if nPos > 0 then
                            clear()
                            nPos = 0
                            recomplete()
                            redraw()
                        end
        
                    elseif param == keys.delete then
                        -- Delete
                        if nPos < string.len(sLine) then
                            clear()
                            sLine = string.sub( sLine, 1, nPos ) .. string.sub( sLine, nPos + 2 )                
                            recomplete()
                            redraw()
                        end
        
                    elseif param == keys["end"] then
                        -- End
                        if nPos < string.len(sLine ) then
                            clear()
                            nPos = string.len(sLine)
                            recomplete()
                            redraw()
                        end
        
                    elseif param == keys.tab then
                        -- Tab (accept autocomplete)
                        acceptCompletion()
        
                    end
        
                elseif sEvent == "term_resize" then
                    -- Terminal resized
                    w = term.getSize()
                    redraw()
        
                end
            end
        
            local cx, cy = term.getCursorPos()
            term.setCursorBlink( false )
            term.setCursorPos( w + 1, cy )
            print()
            
            return sLine
        end -- function biosRead
        
        --------------------------------------
        -- @type procenv
        -- @field [parent=#process] #procenv env the process start environment
        proc.env = {
            --------------------------------------
            -- @field [parent=#procenv] #xwos xwos
            xwos = xwos,
            print = function(...)
                kernel.origGlob.print(proc.pid, ...)
            end, -- print
            --------------------------------------
            -- sleeps amount of seconds
            -- @function [parent=#procenv] sleep
            -- @param #number nTime number of seconds
            sleep = function(nTime)
                kernel.debug("[PID"..pid.."] sleep", nTime)
                proc.env.os.sleep(nTime)
            end, -- function sleep
            read = function( _sReplaceChar, _tHistory, _fnComplete, _sDefault )
                proc.acquireInput()
                local res = {pcall(biosRead, _sReplaceChar,_tHistory,_fnComplete,_sDefault)}
                proc.releaseInput()
                if res[1] then
                    return res[2]
                end -- if res
                error(res[2])
            end, -- function read
            
            -------------------------------------
            -- @field [parent=#procenv] os#os os the os api
            os = {
                sleep = function(nTime)
                    kernel.debug("[PID"..pid.."] os.sleep", nTime)
                    if nTime ~= nil and kernel.origGlob.type( nTime ) ~= "number" then
                        kernel.origGlob.error( "bad argument #1 (expected number, got " .. kernel.origGlob.type( nTime ) .. ")", 2 )
                    end
                    local timer = proc.env.os.startTimer( nTime or 0 )
                    repeat
                        local sEvent, param = proc.env.os.pullEvent( "timer" )
                    until param == timer
                end, -- function os.sleep
                startTimer = function(s)
                    kernel.debug("[PID"..pid.."] os.startTimer", s)
                    local timer = kernel.origGlob.os.startTimer(s)
                    originsert(timers, {
                        id = timer,
                        proc = proc
                    })
                    return timer
                end, -- function os.startTimer
                pullEventRaw = function(filter)
                    kernel.debug("[PID"..pid.."] os.pullEventRaw", filter)
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
                        
                        kernel.debug("[PID"..pid.."] invoke os.pullEventRaw", filter)
                        local event = processEvt(pid, {kernel.origGlob.os.pullEventRaw()}, filter)
                        if event ~= nil then
                            return kernel.origGlob.unpack(event)
                        end -- if event
                    end -- endless loop
                end, -- function os.pullEventRaw
                pullEvent = function(filter)
                    kernel.debug("[PID"..pid.."] os.pullEvent", filter)
                    local eventData = {proc.env.os.pullEventRaw(filter)}
                    if eventData[1] == "terminate" then
                        kernel.origGlob.error( "Terminated", 0 )
                    end
                end -- function os.pullEvent
            }
        }
        
        proc.state = true
        proc.procstate = "preparing"
        
        ------------------------------------------
        -- joins process and awaits it termination
        -- @function [parent=#process] join
        proc.join = function()
            local cpid = 0
            if _G.xwos ~= nil then
                cpid = _G.xwos.prm().pid()
            end -- if xwos
            kernel.debug("[PID"..cpid.."] joining "..pid)
            proc.joined = proc.joined + 1
            while proc.procstate ~= "finished" do
                kernel.debug("[PID"..cpid.."] waiting for finished of "..pid.." (state="..proc.procstate..")")
                local event = processEvt(cpid, {origyield()}, "xwos_terminated")
                if event ~= nil and event[2] ~= pid then
                    for k, v in kernel.origGlob.pairs(processes) do
                        if v.pid == event[2] and v.joined > 0 then
                            kernel.debug("[PID"..cpid.."] redistributing because at least one process called join of "..pid)
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
        
        if procinput.proc == nil then
            acquireInput(proc)
        end -- if not procinput
        
        print("proc.env.read: ", proc.env.read)
        
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

-- TODO type processterm (terminal wrapper)

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










-- bios.lua from computer craft

-- TODO Check alternatives to getfenv etc. for supporting disable lua 5.2 features
--if _VERSION == "Lua 5.1" then
--    if _CC_DISABLE_LUA51_FEATURES then
--        -- Remove the Lua 5.1 features that will be removed when we update to Lua 5.2, for compatibility testing.
--        -- See "disable_lua51_functions" in ComputerCraft.cfg
--        setfenv = nil
--        getfenv = nil
--        loadstring = nil
--        unpack = nil
--        math.log10 = nil
--        table.maxn = nil
--        bit = nil
--    end
--end
--
--
-- TODO implement in a meaningful context
--function write( sText )
--    if type( sText ) ~= "string" and type( sText ) ~= "number" then
--        error( "bad argument #1 (expected string or number, got " .. type( sText ) .. ")", 2 ) 
--    end
--
--    local w,h = term.getSize()        
--    local x,y = term.getCursorPos()
--    
--    local nLinesPrinted = 0
--    local function newLine()
--        if y + 1 <= h then
--            term.setCursorPos(1, y + 1)
--        else
--            term.setCursorPos(1, h)
--            term.scroll(1)
--        end
--        x, y = term.getCursorPos()
--        nLinesPrinted = nLinesPrinted + 1
--    end
--    
--    -- Print the line with proper word wrapping
--    while string.len(sText) > 0 do
--        local whitespace = string.match( sText, "^[ \t]+" )
--        if whitespace then
--            -- Print whitespace
--            term.write( whitespace )
--            x,y = term.getCursorPos()
--            sText = string.sub( sText, string.len(whitespace) + 1 )
--        end
--        
--        local newline = string.match( sText, "^\n" )
--        if newline then
--            -- Print newlines
--            newLine()
--            sText = string.sub( sText, 2 )
--        end
--        
--        local text = string.match( sText, "^[^ \t\n]+" )
--        if text then
--            sText = string.sub( sText, string.len(text) + 1 )
--            if string.len(text) > w then
--                -- Print a multiline word                
--                while string.len( text ) > 0 do
--                    if x > w then
--                        newLine()
--                    end
--                    term.write( text )
--                    text = string.sub( text, (w-x) + 2 )
--                    x,y = term.getCursorPos()
--                end
--            else
--                -- Print a word normally
--                if x + string.len(text) - 1 > w then
--                    newLine()
--                end
--                term.write( text )
--                x,y = term.getCursorPos()
--            end
--        end
--    end
--    
--    return nLinesPrinted
--end
--
--function print( ... )
--    local nLinesPrinted = 0
--    local nLimit = select("#", ... )
--    for n = 1, nLimit do
--        local s = tostring( select( n, ... ) )
--        if n < nLimit then
--            s = s .. "\t"
--        end
--        nLinesPrinted = nLinesPrinted + write( s )
--    end
--    nLinesPrinted = nLinesPrinted + write( "\n" )
--    return nLinesPrinted
--end
--
--function printError( ... )
--    local oldColour
--    if term.isColour() then
--        oldColour = term.getTextColour()
--        term.setTextColour( colors.red )
--    end
--    print( ... )
--    if term.isColour() then
--        term.setTextColour( oldColour )
--    end
--end
--
--function read( _sReplaceChar, _tHistory, _fnComplete, _sDefault )
--    if _sReplaceChar ~= nil and type( _sReplaceChar ) ~= "string" then
--        error( "bad argument #1 (expected string, got " .. type( _sReplaceChar ) .. ")", 2 ) 
--    end
--    if _tHistory ~= nil and type( _tHistory ) ~= "table" then
--        error( "bad argument #2 (expected table, got " .. type( _tHistory ) .. ")", 2 ) 
--    end
--    if _fnComplete ~= nil and type( _fnComplete ) ~= "function" then
--        error( "bad argument #3 (expected function, got " .. type( _fnComplete ) .. ")", 2 ) 
--    end
--    if _sDefault ~= nil and type( _sDefault ) ~= "string" then
--        error( "bad argument #4 (expected string, got " .. type( _sDefault ) .. ")", 2 ) 
--    end
--    term.setCursorBlink( true )
--
--    local sLine
--    if type( _sDefault ) == "string" then
--        sLine = _sDefault
--    else
--        sLine = ""
--    end
--    local nHistoryPos
--    local nPos = #sLine
--    if _sReplaceChar then
--        _sReplaceChar = string.sub( _sReplaceChar, 1, 1 )
--    end
--
--    local tCompletions
--    local nCompletion
--    local function recomplete()
--        if _fnComplete and nPos == string.len(sLine) then
--            tCompletions = _fnComplete( sLine )
--            if tCompletions and #tCompletions > 0 then
--                nCompletion = 1
--            else
--                nCompletion = nil
--            end
--        else
--            tCompletions = nil
--            nCompletion = nil
--        end
--    end
--
--    local function uncomplete()
--        tCompletions = nil
--        nCompletion = nil
--    end
--
--    local w = term.getSize()
--    local sx = term.getCursorPos()
--
--    local function redraw( _bClear )
--        local nScroll = 0
--        if sx + nPos >= w then
--            nScroll = (sx + nPos) - w
--        end
--
--        local cx,cy = term.getCursorPos()
--        term.setCursorPos( sx, cy )
--        local sReplace = (_bClear and " ") or _sReplaceChar
--        if sReplace then
--            term.write( string.rep( sReplace, math.max( string.len(sLine) - nScroll, 0 ) ) )
--        else
--            term.write( string.sub( sLine, nScroll + 1 ) )
--        end
--
--        if nCompletion then
--            local sCompletion = tCompletions[ nCompletion ]
--            local oldText, oldBg
--            if not _bClear then
--                oldText = term.getTextColor()
--                oldBg = term.getBackgroundColor()
--                term.setTextColor( colors.white )
--                term.setBackgroundColor( colors.gray )
--            end
--            if sReplace then
--                term.write( string.rep( sReplace, string.len( sCompletion ) ) )
--            else
--                term.write( sCompletion )
--            end
--            if not _bClear then
--                term.setTextColor( oldText )
--                term.setBackgroundColor( oldBg )
--            end
--        end
--
--        term.setCursorPos( sx + nPos - nScroll, cy )
--    end
--    
--    local function clear()
--        redraw( true )
--    end
--
--    recomplete()
--    redraw()
--
--    local function acceptCompletion()
--        if nCompletion then
--            -- Clear
--            clear()
--
--            -- Find the common prefix of all the other suggestions which start with the same letter as the current one
--            local sCompletion = tCompletions[ nCompletion ]
--            sLine = sLine .. sCompletion
--            nPos = string.len( sLine )
--
--            -- Redraw
--            recomplete()
--            redraw()
--        end
--    end
--    while true do
--        local sEvent, param = os.pullEvent()
--        if sEvent == "char" then
--            -- Typed key
--            clear()
--            sLine = string.sub( sLine, 1, nPos ) .. param .. string.sub( sLine, nPos + 1 )
--            nPos = nPos + 1
--            recomplete()
--            redraw()
--
--        elseif sEvent == "paste" then
--            -- Pasted text
--            clear()
--            sLine = string.sub( sLine, 1, nPos ) .. param .. string.sub( sLine, nPos + 1 )
--            nPos = nPos + string.len( param )
--            recomplete()
--            redraw()
--
--        elseif sEvent == "key" then
--            if param == keys.enter then
--                -- Enter
--                if nCompletion then
--                    clear()
--                    uncomplete()
--                    redraw()
--                end
--                break
--                
--            elseif param == keys.left then
--                -- Left
--                if nPos > 0 then
--                    clear()
--                    nPos = nPos - 1
--                    recomplete()
--                    redraw()
--                end
--                
--            elseif param == keys.right then
--                -- Right                
--                if nPos < string.len(sLine) then
--                    -- Move right
--                    clear()
--                    nPos = nPos + 1
--                    recomplete()
--                    redraw()
--                else
--                    -- Accept autocomplete
--                    acceptCompletion()
--                end
--
--            elseif param == keys.up or param == keys.down then
--                -- Up or down
--                if nCompletion then
--                    -- Cycle completions
--                    clear()
--                    if param == keys.up then
--                        nCompletion = nCompletion - 1
--                        if nCompletion < 1 then
--                            nCompletion = #tCompletions
--                        end
--                    elseif param == keys.down then
--                        nCompletion = nCompletion + 1
--                        if nCompletion > #tCompletions then
--                            nCompletion = 1
--                        end
--                    end
--                    redraw()
--
--                elseif _tHistory then
--                    -- Cycle history
--                    clear()
--                    if param == keys.up then
--                        -- Up
--                        if nHistoryPos == nil then
--                            if #_tHistory > 0 then
--                                nHistoryPos = #_tHistory
--                            end
--                        elseif nHistoryPos > 1 then
--                            nHistoryPos = nHistoryPos - 1
--                        end
--                    else
--                        -- Down
--                        if nHistoryPos == #_tHistory then
--                            nHistoryPos = nil
--                        elseif nHistoryPos ~= nil then
--                            nHistoryPos = nHistoryPos + 1
--                        end                        
--                    end
--                    if nHistoryPos then
--                        sLine = _tHistory[nHistoryPos]
--                        nPos = string.len( sLine ) 
--                    else
--                        sLine = ""
--                        nPos = 0
--                    end
--                    uncomplete()
--                    redraw()
--
--                end
--
--            elseif param == keys.backspace then
--                -- Backspace
--                if nPos > 0 then
--                    clear()
--                    sLine = string.sub( sLine, 1, nPos - 1 ) .. string.sub( sLine, nPos + 1 )
--                    nPos = nPos - 1
--                    recomplete()
--                    redraw()
--                end
--
--            elseif param == keys.home then
--                -- Home
--                if nPos > 0 then
--                    clear()
--                    nPos = 0
--                    recomplete()
--                    redraw()
--                end
--
--            elseif param == keys.delete then
--                -- Delete
--                if nPos < string.len(sLine) then
--                    clear()
--                    sLine = string.sub( sLine, 1, nPos ) .. string.sub( sLine, nPos + 2 )                
--                    recomplete()
--                    redraw()
--                end
--
--            elseif param == keys["end"] then
--                -- End
--                if nPos < string.len(sLine ) then
--                    clear()
--                    nPos = string.len(sLine)
--                    recomplete()
--                    redraw()
--                end
--
--            elseif param == keys.tab then
--                -- Tab (accept autocomplete)
--                acceptCompletion()
--
--            end
--
--        elseif sEvent == "term_resize" then
--            -- Terminal resized
--            w = term.getSize()
--            redraw()
--
--        end
--    end
--
--    local cx, cy = term.getCursorPos()
--    term.setCursorBlink( false )
--    term.setCursorPos( w + 1, cy )
--    print()
--    
--    return sLine
--end
--
--loadfile = function( _sFile, _tEnv )
--    if type( _sFile ) ~= "string" then
--        error( "bad argument #1 (expected string, got " .. type( _sFile ) .. ")", 2 ) 
--    end
--    if _tEnv ~= nil and type( _tEnv ) ~= "table" then
--        error( "bad argument #2 (expected table, got " .. type( _tEnv ) .. ")", 2 ) 
--    end
--    local file = fs.open( _sFile, "r" )
--    if file then
--        local func, err = load( file.readAll(), fs.getName( _sFile ), "t", _tEnv )
--        file.close()
--        return func, err
--    end
--    return nil, "File not found"
--end
--
--dofile = function( _sFile )
--    if type( _sFile ) ~= "string" then
--        error( "bad argument #1 (expected string, got " .. type( _sFile ) .. ")", 2 ) 
--    end
--    local fnFile, e = loadfile( _sFile, _G )
--    if fnFile then
--        return fnFile()
--    else
--        error( e, 2 )
--    end
--end
--
---- Install the rest of the OS api
--function os.run( _tEnv, _sPath, ... )
--    if type( _tEnv ) ~= "table" then
--        error( "bad argument #1 (expected table, got " .. type( _tEnv ) .. ")", 2 ) 
--    end
--    if type( _sPath ) ~= "string" then
--        error( "bad argument #2 (expected string, got " .. type( _sPath ) .. ")", 2 ) 
--    end
--    local tArgs = table.pack( ... )
--    local tEnv = _tEnv
--    setmetatable( tEnv, { __index = _G } )
--    local fnFile, err = loadfile( _sPath, tEnv )
--    if fnFile then
--        local ok, err = pcall( function()
--            fnFile( table.unpack( tArgs, 1, tArgs.n ) )
--        end )
--        if not ok then
--            if err and err ~= "" then
--                printError( err )
--            end
--            return false
--        end
--        return true
--    end
--    if err and err ~= "" then
--        printError( err )
--    end
--    return false
--end
--
--local tAPIsLoading = {}
--function os.loadAPI( _sPath )
--    if type( _sPath ) ~= "string" then
--        error( "bad argument #1 (expected string, got " .. type( _sPath ) .. ")", 2 ) 
--    end
--    local sName = fs.getName( _sPath )
--    if sName:sub(-4) == ".lua" then
--        sName = sName:sub(1,-5)
--    end
--    if tAPIsLoading[sName] == true then
--        printError( "API "..sName.." is already being loaded" )
--        return false
--    end
--    tAPIsLoading[sName] = true
--
--    local tEnv = {}
--    setmetatable( tEnv, { __index = _G } )
--    local fnAPI, err = loadfile( _sPath, tEnv )
--    if fnAPI then
--        local ok, err = pcall( fnAPI )
--        if not ok then
--            printError( err )
--            tAPIsLoading[sName] = nil
--            return false
--        end
--    else
--        printError( err )
--        tAPIsLoading[sName] = nil
--        return false
--    end
--    
--    local tAPI = {}
--    for k,v in pairs( tEnv ) do
--        if k ~= "_ENV" then
--            tAPI[k] =  v
--        end
--    end
--
--    _G[sName] = tAPI    
--    tAPIsLoading[sName] = nil
--    return true
--end
--
--function os.unloadAPI( _sName )
--    if type( _sName ) ~= "string" then
--        error( "bad argument #1 (expected string, got " .. type( _sName ) .. ")", 2 ) 
--    end
--    if _sName ~= "_G" and type(_G[_sName]) == "table" then
--        _G[_sName] = nil
--    end
--end
--
--function os.sleep( nTime )
--    sleep( nTime )
--end
--
--local nativeShutdown = os.shutdown
--function os.shutdown()
--    nativeShutdown()
--    while true do
--        coroutine.yield()
--    end
--end
--
--local nativeReboot = os.reboot
--function os.reboot()
--    nativeReboot()
--    while true do
--        coroutine.yield()
--    end
--end
--
---- Install the lua part of the HTTP api (if enabled)
--if http then
--    local nativeHTTPRequest = http.request
--
--    local function wrapRequest( _url, _post, _headers, _binary )
--        local ok, err = nativeHTTPRequest( _url, _post, _headers, _binary )
--        if ok then
--            while true do
--                local event, param1, param2, param3 = os.pullEvent()
--                if event == "http_success" and param1 == _url then
--                    return param2
--                elseif event == "http_failure" and param1 == _url then
--                    return nil, param2, param3
--                end
--            end
--        end
--        return nil, err
--    end
--    
--    http.get = function( _url, _headers, _binary)
--        if type( _url ) ~= "string" then
--            error( "bad argument #1 (expected string, got " .. type( _url ) .. ")", 2 ) 
--        end
--        if _headers ~= nil and type( _headers ) ~= "table" then
--            error( "bad argument #2 (expected table, got " .. type( _headers ) .. ")", 2 ) 
--        end
--        if _binary ~= nil and type( _binary ) ~= "boolean" then
--            error( "bad argument #3 (expected boolean, got " .. type( _binary ) .. ")", 2 ) 
--        end
--        return wrapRequest( _url, nil, _headers, _binary)
--    end
--
--    http.post = function( _url, _post, _headers, _binary)
--        if type( _url ) ~= "string" then
--            error( "bad argument #1 (expected string, got " .. type( _url ) .. ")", 2 ) 
--        end
--        if type( _post ) ~= "string" then
--            error( "bad argument #2 (expected string, got " .. type( _post ) .. ")", 2 ) 
--        end
--        if _headers ~= nil and type( _headers ) ~= "table" then
--            error( "bad argument #3 (expected table, got " .. type( _headers ) .. ")", 2 ) 
--        end
--        if _binary ~= nil and type( _binary ) ~= "boolean" then
--            error( "bad argument #4 (expected boolean, got " .. type( _binary ) .. ")", 2 ) 
--        end
--        return wrapRequest( _url, _post or "", _headers, _binary)
--    end
--
--    http.request = function( _url, _post, _headers, _binary )
--        if type( _url ) ~= "string" then
--            error( "bad argument #1 (expected string, got " .. type( _url ) .. ")", 2 ) 
--        end
--        if _post ~= nil and type( _post ) ~= "string" then
--            error( "bad argument #2 (expected string, got " .. type( _post ) .. ")", 2 ) 
--        end
--        if _headers ~= nil and type( _headers ) ~= "table" then
--            error( "bad argument #3 (expected table, got " .. type( _headers ) .. ")", 2 ) 
--        end
--        if _binary ~= nil and type( _binary ) ~= "boolean" then
--            error( "bad argument #4 (expected boolean, got " .. type( _binary ) .. ")", 2 ) 
--        end
--        local ok, err = nativeHTTPRequest( _url, _post, _headers, _binary )
--        if not ok then
--            os.queueEvent( "http_failure", _url, err )
--        end
--        return ok, err
--    end
--    
--    local nativeCheckURL = http.checkURL
--    http.checkURLAsync = nativeCheckURL
--    http.checkURL = function( _url )
--        local ok, err = nativeCheckURL( _url )
--        if not ok then return ok, err end
--    
--        while true do
--            local event, url, ok, err = os.pullEvent( "http_check" )
--            if url == _url then return ok, err end
--        end
--    end
--end
--
---- Install the lua part of the FS api
--local tEmpty = {}
--function fs.complete( sPath, sLocation, bIncludeFiles, bIncludeDirs )
--    if type( sPath ) ~= "string" then
--        error( "bad argument #1 (expected string, got " .. type( sPath ) .. ")", 2 ) 
--    end
--    if type( sLocation ) ~= "string" then
--        error( "bad argument #2 (expected string, got " .. type( sLocation ) .. ")", 2 ) 
--    end
--    if bIncludeFiles ~= nil and type( bIncludeFiles ) ~= "boolean" then
--        error( "bad argument #3 (expected boolean, got " .. type( bIncludeFiles ) .. ")", 2 ) 
--    end
--    if bIncludeDirs ~= nil and type( bIncludeDirs ) ~= "boolean" then
--        error( "bad argument #4 (expected boolean, got " .. type( bIncludeDirs ) .. ")", 2 ) 
--    end
--    bIncludeFiles = (bIncludeFiles ~= false)
--    bIncludeDirs = (bIncludeDirs ~= false)
--    local sDir = sLocation
--    local nStart = 1
--    local nSlash = string.find( sPath, "[/\\]", nStart )
--    if nSlash == 1 then
--        sDir = ""
--        nStart = 2
--    end
--    local sName
--    while not sName do
--        local nSlash = string.find( sPath, "[/\\]", nStart )
--        if nSlash then
--            local sPart = string.sub( sPath, nStart, nSlash - 1 )
--            sDir = fs.combine( sDir, sPart )
--            nStart = nSlash + 1
--        else
--            sName = string.sub( sPath, nStart )
--        end
--    end
--
--    if fs.isDir( sDir ) then
--        local tResults = {}
--        if bIncludeDirs and sPath == "" then
--            table.insert( tResults, "." )
--        end
--        if sDir ~= "" then
--            if sPath == "" then
--                table.insert( tResults, (bIncludeDirs and "..") or "../" )
--            elseif sPath == "." then
--                table.insert( tResults, (bIncludeDirs and ".") or "./" )
--            end
--        end
--        local tFiles = fs.list( sDir )
--        for n=1,#tFiles do
--            local sFile = tFiles[n]
--            if #sFile >= #sName and string.sub( sFile, 1, #sName ) == sName then
--                local bIsDir = fs.isDir( fs.combine( sDir, sFile ) )
--                local sResult = string.sub( sFile, #sName + 1 )
--                if bIsDir then
--                    table.insert( tResults, sResult .. "/" )
--                    if bIncludeDirs and #sResult > 0 then
--                        table.insert( tResults, sResult )
--                    end
--                else
--                    if bIncludeFiles and #sResult > 0 then
--                        table.insert( tResults, sResult )
--                    end
--                end
--            end
--        end
--        return tResults
--    end
--    return tEmpty
--end
--
---- Load APIs
--local bAPIError = false
--local tApis = fs.list( "rom/apis" )
--for n,sFile in ipairs( tApis ) do
--    if string.sub( sFile, 1, 1 ) ~= "." then
--        local sPath = fs.combine( "rom/apis", sFile )
--        if not fs.isDir( sPath ) then
--            if not os.loadAPI( sPath ) then
--                bAPIError = true
--            end
--        end
--    end
--end
--
--if turtle and fs.isDir( "rom/apis/turtle" ) then
--    -- Load turtle APIs
--    local tApis = fs.list( "rom/apis/turtle" )
--    for n,sFile in ipairs( tApis ) do
--        if string.sub( sFile, 1, 1 ) ~= "." then
--            local sPath = fs.combine( "rom/apis/turtle", sFile )
--            if not fs.isDir( sPath ) then
--                if not os.loadAPI( sPath ) then
--                    bAPIError = true
--                end
--            end
--        end
--    end
--end
--
--if pocket and fs.isDir( "rom/apis/pocket" ) then
--    -- Load pocket APIs
--    local tApis = fs.list( "rom/apis/pocket" )
--    for n,sFile in ipairs( tApis ) do
--        if string.sub( sFile, 1, 1 ) ~= "." then
--            local sPath = fs.combine( "rom/apis/pocket", sFile )
--            if not fs.isDir( sPath ) then
--                if not os.loadAPI( sPath ) then
--                    bAPIError = true
--                end
--            end
--        end
--    end
--end
--
--if commands and fs.isDir( "rom/apis/command" ) then
--    -- Load command APIs
--    if os.loadAPI( "rom/apis/command/commands.lua" ) then
--        -- Add a special case-insensitive metatable to the commands api
--        local tCaseInsensitiveMetatable = {
--            __index = function( table, key )
--                local value = rawget( table, key )
--                if value ~= nil then
--                    return value
--                end
--                if type(key) == "string" then
--                    local value = rawget( table, string.lower(key) )
--                    if value ~= nil then
--                        return value
--                    end
--                end
--                return nil
--            end
--        }
--        setmetatable( commands, tCaseInsensitiveMetatable )
--        setmetatable( commands.async, tCaseInsensitiveMetatable )
--
--        -- Add global "exec" function
--        exec = commands.exec
--    else
--        bAPIError = true
--    end
--end
--
--if bAPIError then
--    print( "Press any key to continue" )
--    os.pullEvent( "key" )
--    term.clear()
--    term.setCursorPos( 1,1 )
--end
--
---- Set default settings
--settings.set( "shell.allow_startup", true )
--settings.set( "shell.allow_disk_startup", (commands == nil) )
--settings.set( "shell.autocomplete", true )
--settings.set( "edit.autocomplete", true ) 
--settings.set( "edit.default_extension", "lua" )
--settings.set( "paint.default_extension", "nfp" )
--settings.set( "lua.autocomplete", true )
--settings.set( "list.show_hidden", false )
--if term.isColour() then
--    settings.set( "bios.use_multishell", true )
--end
--if _CC_DEFAULT_SETTINGS then
--    for sPair in string.gmatch( _CC_DEFAULT_SETTINGS, "[^,]+" ) do
--        local sName, sValue = string.match( sPair, "([^=]*)=(.*)" )
--        if sName and sValue then
--            local value
--            if sValue == "true" then
--                value = true
--            elseif sValue == "false" then
--                value = false
--            elseif sValue == "nil" then
--                value = nil
--            elseif tonumber(sValue) then
--                value = tonumber(sValue)
--            else
--                value = sValue
--            end
--            if value ~= nil then
--                settings.set( sName, value )
--            else
--                settings.unset( sName )
--            end
--        end
--    end
--end
--
---- Load user settings
--if fs.exists( ".settings" ) then
--    settings.load( ".settings" )
--end
--
---- Run the shell
--local ok, err = pcall( function()
--    parallel.waitForAny( 
--        function()
--            local sShell
--            if term.isColour() and settings.get( "bios.use_multishell" ) then
--                sShell = "rom/programs/advanced/multishell.lua"
--            else
--                sShell = "rom/programs/shell.lua"
--            end
--            os.run( {}, sShell )
--            os.run( {}, "rom/programs/shutdown.lua" )
--        end,
--        function()
--            rednet.run()
--        end )
--end )
--
---- If the shell errored, let the user read it.
--term.redirect( term.native() )
--if not ok then
--    printError( err )
--    pcall( function()
--        term.setCursorBlink( false )
--        print( "Press any key to continue" )
--        os.pullEvent( "key" )
--    end )
--end
--
---- End
--os.shutdown()
