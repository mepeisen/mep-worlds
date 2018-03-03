-----------------------
-- @module xwos.modules.sandbox.evqueue
local M = {}

local kernel -- xwos.kernel#xwos.kernel

local originsert = table.insert

-----------------------
-- injects the kernel
-- @function [parent=#xwos.modules.sandbox.evqueue] setKernel
-- @param xwos.kernel#xwos.kernel k the kernel
M.setKernel = function(k)
    kernel = k
end -- function setKernel

-----------------------
-- Process and distribute event from event queue (part of pullEvent etc.)
-- @function [parent=#xwos.modules.sandbox.evqueue] processEvt
-- @param #number lpid the local pid for logging
-- @param xwos.process#xwos.process proc the process invoking this method
-- @param #table event the event to deliver
-- @param #string filter optional filter passed to pullEvent
M.processEvt = function(lpid, proc, event, filter)
    if event[1] == nil then
        return nil
    end -- if event
    kernel.debug("[PID"..lpid.."] got event ", kernel.oldGlob.unpack(event))
    
    if kernel.eventLog then
        -- TODO are we able to pass non serializable data through events?
        -- this may cause problems at this point
        local str = kernel.oldGlob.os.day() .. "-" .. kernel.oldGlob.os.time() " EVENT: ".. kernel.oldGlob.textutils.serialize(event)
        local f = kernel.oldGlob.fs.open("/core/log/event-log.txt", kernel.oldGlob.fs.exists("/core/log/event-log.txt") and "a" or "w")
        f.writeLine(str)
        f.close()
    end -- if eventLog
    
    local consumed = false
    
    if event[1] == "timer" then
        local timer = kernel.modules.instances.sandbox.timers[event[2]]
        if timer ~= nil then
            if timer.proc == proc then
                if filter == nil or event[1]==filter then
                    kernel.debug("[PID"..lpid.."] returning event ", kernel.oldGlob.unpack(event))
                    return event
                else -- if filter
                    kernel.debug("[PID"..lpid.."] discard event because of filter", kernel.oldGlob.unpack(event))
                    consumed = true
                end -- if filter
            else -- if proc
                kernel.debug("[PID"..lpid.."] queue event for distribution to pid "..timer.proc.pid, kernel.oldGlob.unpack(event))
                originsert(timer.proc.evqueue, event)
                timer.proc.wakeup()
                consumed = true
            end -- if not proc
        end -- if timer
        -- fallthrough: distribute unknown timer event to all processes
    end -- if timer
    
    if event[1] == "xwos_wakeup" then
        consumed = true
        kernel.debug("[PID"..lpid.."] wakeup received")
        if event[2] ~= lpid then
            kernel.debug("[PID"..lpid.."] wrong pid, redistribute")
            kernel.oldGlob.os.queueEvent(kernel.oldGlob.unpack(event))
        end -- if pid
    end -- if xwos_wakeup
    
    if event[1] == "xwos_terminate" then
        consumed = true
        kernel.debug("[PID"..lpid.."] terminate received")
        if event[2] ~= lpid then
            kernel.debug("[PID"..lpid.."] wrong pid, redistribute")
            kernel.oldGlob.os.queueEvent(kernel.oldGlob.unpack(event))
        else -- if pid
            kernel.oldGlob.error('requesting process termination')
        end -- if pid
    end -- if xwos_terminate
    
    if event[1] == "xwos_terminated" then
        consumed = true
        kernel.debug("[PID"..lpid.."] terminated received")
        if filter == "xwos_terminated" then
            kernel.debug("[PID"..lpid.."] returning event ", kernel.oldGlob.unpack(event))
            return event
        end -- if filter
        for k, v in kernel.oldGlob.pairs(kernel.processes) do
            if kernel.oldGlob.type(v) == "table" and v.pid == event[2] and v.joined > 0 then
                kernel.debug("[PID"..lpid.."] redistributing because at least one process called join")
                kernel.oldGlob.os.queueEvent(kernel.oldGlob.unpack(event))
            end --
        end -- for processes
    end -- if xwos_terminated
    
    if event[1] == "char" or event[1] == "key" or event[1] == "paste" or event[1] == "key_up" then
        consumed = true
        kernel.debug("[PID"..lpid.."] user input received")
        if kernel.modules.instances.sandbox.procinput.current.proc ~= nil then
            kernel.debug("[PID"..lpid.."] queue event for distribution to user input pid "..kernel.modules.instances.sandbox.procinput.current.proc.pid)
            originsert(kernel.modules.instances.sandbox.procinput.current.proc.evqueue, event)
            kernel.modules.instances.sandbox.procinput.current.proc.wakeup()
        else
            -- TODO what to do with input if no one likes it?
            -- think about special key bindings fetched from background processes
            -- currently we silently discard that kind of input
        end -- 
    end -- if char
    
    -- distribute event to all processes
    if not consumed then
        for k, v in kernel.oldGlob.pairs(kernel.processes) do
            if kernel.oldGlob.type(v) == "table" and v.procstate ~= "finished" then
                kernel.debug("[PID"..lpid.."] queue event for distribution to all pids "..v.pid, kernel.oldGlob.unpack(event))
                originsert(v.evqueue, event)
                v.wakeup()
            end -- if not finished
        end -- for processes
    end -- if consumed
    
    return nil
end -- function processEvt

return M
