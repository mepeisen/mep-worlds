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

-----------------------
-- @module xwos.modules.sandbox
local M = {}

local kernel -- xwos.kernel#xwos.kernel
local originsert = table.insert

---------------------------------
-- @function [parent=#xwos.modules.sandbox] preboot
-- @param xwos.kernel#xwos.kernel k
M.preboot = function(k)
    k.debug("preboot sandbox")
    kernel = k
    
    -----------------------
    -- process input type with mapping to previous input
    -- @field [parent=#xwos.modules.sandbox] xwos.modules.sandbox.procinput#xwos.modules.sandbox.procinput procinput the input process management
    M.procinput = kernel.require("xwos/modules/sandbox/procinput")
    M.procinput.setKernel(kernel)
    
    -----------------------
    -- timers started from processes
    -- @field [parent=#xwos.modules.sandbox] xwos.modules.sandbox.timers#xwos.modules.sandbox.timers timers the timer management
    M.timers = kernel.require("xwos/modules/sandbox/timers")
    M.timers.setKernel(kernel)
    
    -----------------------
    -- event queue handling
    -- @field [parent=#xwos.modules.sandbox] xwos.modules.sandbox.evqueue#xwos.modules.sandbox.evqueue evqueue event queue management
    M.evqueue = kernel.require("xwos/modules/sandbox/evqueue")
    M.evqueue.setKernel(kernel)

end -- function preboot

----------------------
-- @param xwos.processes#xwos.process proc the underlying process
-- @param #global env the global process environment
local envFactory = function(proc, env)
    kernel.debug("[PID"..proc.pid.."] preparing env", env)
    env.pid = proc.pid

    -- TODO this is partly original code from bios.
    -- we need to redeclare it to get into wrapped os.**** methods
    -- maybe in future we find a solution to not redeclare it here
    local biosRead = function( _sReplaceChar, _tHistory, _fnComplete, _sDefault )
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

    env.read = function( _sReplaceChar, _tHistory, _fnComplete, _sDefault )
        proc.acquireInput()
        local res = {pcall(biosRead, _sReplaceChar,_tHistory,_fnComplete,_sDefault)}
        proc.releaseInput()
        if res[1] then
            return res[2]
        end -- if res
        error(res[2])
    end -- function read
    
    env.sleep = function(nTime)
      kernel.debug("[PID"..proc.pid.."] sleep", nTime, kernel.oldGlob.getfenv(0), kernel.oldGlob.getfenv(env.sleep))
      if nTime ~= nil and type( nTime ) ~= "number" then
          error( "bad argument #1 (expected number, got " .. type( nTime ) .. ")", 2 ) 
      end
      local timer = os.startTimer( nTime or 0 )
      repeat
          local sEvent, param = os.pullEvent( "timer" )
      until param == timer
    end -- function sleep
    
    -- clone os to manipulate it
    env.os = table.clone(env.os)
    env.os.sleep = function(nTime)
      sleep(nTime)
    end -- function os.sleep
    
    env.os.startTimer = function(s)
        kernel.debug("[PID"..proc.pid.."] os.startTimer", s)
        local timer = kernel.oldGlob.os.startTimer(s)
        kernel.modules.instances.sandbox.timers.new(timer, proc)
        return timer
    end -- function os.startTimer
    env.os.pullEventRaw = function(filter)
        kernel.debug("[PID"..proc.pid.."] os.pullEventRaw", filter)
        while true do
            for k,v in kernel.oldGlob.ipairs(proc.evqueue) do
                proc.evqueue[k] = nil
                if filter == nil or v[1]==filter then
                    kernel.debug("[PID"..proc.pid.."] returning event from local event queue", kernel.oldGlob.unpack(v))
                    return kernel.oldGlob.unpack(v)
                else -- if filter
                    kernel.debug("[PID"..proc.pid.."] discard event from local event queue because of filter", kernel.oldGlob.unpack(v))
                end -- if filter
            end -- for evqueue
            
            kernel.debug("[PID"..proc.pid.."] invoke os.pullEventRaw", filter)
            local event = M.evqueue.processEvt(proc.pid, proc, {kernel.oldGlob.os.pullEventRaw()}, filter)
            if event ~= nil then
                return kernel.oldGlob.unpack(event)
            end -- if event
        end -- endless loop
    end -- function os.pullEventRaw
    env.os.pullEvent = function(filter)
        kernel.debug("[PID"..proc.pid.."] os.pullEvent", filter)
        local eventData = {proc.env.os.pullEventRaw(filter)}
        if eventData[1] == "terminate" then
            kernel.oldGlob.error( "Terminated", 0 )
        end
        return kernel.oldGlob.unpack(eventData)
    end -- function os.pullEvent
    ---------------------------------------
    -- operating system access
    -- @type xwos
    -- @field [parent=#global] #xwos xwos predefined operating system accessor
    env.xwos = {}
    ---------------------------------------
    -- debugging output
    -- @function [parent=#xwos] debug
    -- @param #string msg
    env.xwos.debug = function(msg)
        -- TODO find a way to pass variables etc.
        -- check for possible sandbox breaks during tostring
        if kernel.oldGlob.type(msg) ~= "string" then
            error("Wrong argument type (only strings allowed)")
        else -- if not string
            kernel.debug(msg)
        end -- if string
    end -- function debug
    ---------------------------------------
    -- process manager
    -- @type xwos.pmr
    -- @field [parent=#xwos] #xwos.pmr pmr process manager
    env.xwos.pmr = {}
    -- TODO demon child threads (threads to be fnished before process ends)
    -- TODO on terminate main process terminat all child threads
    ---------------------------------------
    -- create a new child thread
    -- @function [parent=#xwos.pmr] createThread
    -- @param #table newenv the environment of the new thread
    -- @return #xwos.pmr.thread
    env.xwos.pmr.createThread = function(newenv)
        local nenv = {}
        for k,v in kernel.oldGlob.pairs(kernel.oldGlob) do
            nenv[k] = v
        end -- for oldGlob
        local function wrap(target, src)
            for k,v in kernel.oldGlob.pairs(src) do
                if kernel.oldGlob.type(v) == "table" and kernel.oldGlob.type(target[k]) == "table" then
                    wrap(v, target[k])
                else -- if tables
                    target[k] = v
                end -- if tables
            end -- for src
        end -- function wrap
        if newenv ~= nil then
            wrap(nenv, newenv)
        end -- if nenv
        local nproc = kernel.processes.new(proc, kernel, env, kernel.envFactories)
        ---------------------------------------
        -- the new thread
        -- @type xwos.pmr.thread
        local R = {}
        ---------------------------------------
        -- join thread and wait for finish
        -- @function [parent=#xwos.pmr.thread] join
        R.join = function()
            nproc.join(proc)
        end -- function join
        ---------------------------------------
        -- terminate thread
        -- @function [parent=#xwos.pmr.thread] terminate
        R.termninate = function()
            nproc.termninate()
        end -- function termninate
        ---------------------------------------
        -- spawn thread and invoke function
        -- @function [parent=#xwos.pmr.thread] spawn
        -- @param #function func the function to invoke
        -- @param ... arguments
        R.spawn = function(func, ...)
            nproc.spawn(func, ...)
        end -- function termninate
        -- TODO do we need this? we are declaring the functions already inside process thread with correct fenv
        kernel.oldGlob.setfenv(R.join, kernel.nenv)
        kernel.oldGlob.setfenv(R.terminate, kernel.nenv)
        kernel.oldGlob.setfenv(R.spawn, kernel.nenv)
        return R
    end -- function createThread
    
    env.dofile = function(_sFile)
        if type( _sFile ) ~= "string" then
            error( "bad argument #1 (expected string, got " .. type( _sFile ) .. ")", 2 )
        end
        local fnFile, e = loadfile( _sFile, kernel.nenv )
        if fnFile then
            return fnFile()
        else
            error( e, 2 )
        end
    end -- dofile
    
    -- TODO do we need this? we are declaring the functions already inside process thread with correct fenv
    kernel.oldGlob.setfenv(biosRead, kernel.nenv)
    kernel.oldGlob.setfenv(env.read, kernel.nenv)
    kernel.oldGlob.setfenv(env.sleep, kernel.nenv)
    kernel.oldGlob.setfenv(env.dofile, kernel.nenv)
    kernel.oldGlob.setfenv(env.os.sleep, kernel.nenv)
    kernel.oldGlob.setfenv(env.os.startTimer, kernel.nenv)
    kernel.oldGlob.setfenv(env.os.pullEventRaw, kernel.nenv)
    kernel.oldGlob.setfenv(env.os.pullEvent, kernel.nenv)
    kernel.oldGlob.setfenv(env.xwos.debug, kernel.nenv)
    kernel.oldGlob.setfenv(env.xwos.pmr.createThread, kernel.nenv)
end -- function envFactory

---------------------------------
-- @function [parent=#xwos.modules.sandbox] boot
-- @param xwos.kernel#xwos.kernel k
M.boot = function(k)
    k.debug("boot sandbox")
    
    kernel.envFactories.sandbox = envFactory
end -- function boot

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
