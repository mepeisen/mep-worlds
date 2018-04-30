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

local originsert = table.insert
local unpack = unpack
local day = os.day
local time = os.time
local serialize = textutils.serialize
local fsopen = fs.open
local fsexists = fs.exists
local queue = os.queueEvent
local error = os.error

-----------------------
-- @module xwos.modules.sandbox.evqueue
_CMR.class("xwos.modules.sandbox.evqueue")

------------------------
-- the object privates
-- @type privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.modules.sandbox.evqueue

.ctor(
------------------------
-- create new event queue helper
-- @function [parent=#intern] __ctor
-- @param #xwos.modules.sandbox.evqueue self self
-- @param classmanager#clazz clazz event queue class
-- @param #privates privates
-- @param xwos.kernel#xwos.kernel kernel
function (self, clazz, privates, kernel)
    ---------------
    -- kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
end) -- ctor

-----------------------
-- Process and distribute event from event queue (part of pullEvent etc.)
-- @function [parent=#xwos.modules.sandbox.evqueue] processEvt
-- @param #xwos.modules.sandbox.evqueue self
-- @param #number lpid the local pid for logging
-- @param xwos.kernel.process#xwos.kernel.process proc the process invoking this method; may be nil for kernel process
-- @param #table event the event to deliver
-- @param #string filter optional filter passed to pullEvent

.func("processEvt",
-----------------------
-- @function [parent=#intern] processEvt
-- @param #xwos.modules.sandbox.evqueue self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #number lpid
-- @param xwos.kernel.process#xwos.kernel.process proc
-- @param #table event
-- @param #string filter
function(self, clazz, privates, lpid, proc, event, filter)
    if event[1] == nil then
        return nil
    end -- if event
    local sdbg = "[PID"..lpid.."]"
    privates.kernel:debug(sdbg, "got event ", unpack(event))
    
    if privates.kernel.eventLog then
        -- TODO are we able to pass non serializable data through events?
        -- this may cause problems at this point
        local str = day() .. "-" .. time() " EVENT: ".. serialize(event)
        local f = fsopen("/core/log/event-log.txt", fsexists("/core/log/event-log.txt") and "a" or "w")
        f.writeLine(str)
        f.close()
    end -- if eventLog
    
    local consumed = false
    
    if event[1] == "timer" then
        -- TODO Refactoring method invocation
        local timer = privates.kernel.modules.instances.sandbox.timers:get(event[2])
        if timer ~= nil then
            if timer == proc then
                if filter == nil or event[1]==filter then
                    privates.kernel:debug(sdbg, "returning event ", unpack(event))
                    return event
                else -- if filter
                    privates.kernel:debug(sdbg, "discard event because of filter", unpack(event))
                    consumed = true
                end -- if filter
            else -- if proc
                privates.kernel:debug(sdbg, "queue event for distribution to pid", timer:pid(), unpack(event))
                timer:pushev(event)
                timer:wakeup()
                consumed = true
            end -- if not proc
        end -- if timer
        -- fallthrough: distribute unknown timer event to all processes
    end -- if timer
    
    if event[1] == "xwos_wakeup" then
        consumed = true
        privates.kernel:debug(sdbg, "wakeup received")
        if event[2] ~= lpid then
            privates.kernel:debug(sdbg, "wrong pid, redistribute")
            queue(unpack(event))
        end -- if pid
    end -- if xwos_wakeup
    
    if event[1] == "xwos_terminate" then
        consumed = true
        privates.kernel:debug(sdbg, "terminate received")
        if event[2] ~= lpid then
            privates.kernel:debug(sdbg, "wrong pid, redistribute")
            queue(unpack(event))
        else -- if pid
            error('requesting process termination')
        end -- if pid
    end -- if xwos_terminate
    
    if event[1] == "xwos_terminated" then
        consumed = true
        privates.kernel:debug(sdbg, "terminated received")
        if filter == "xwos_terminated" then
            privates.kernel:debug(sdbg, "returning event ", unpack(event))
            return event
        end -- if filter
        -- TODO Refactoring method invocation
        for k, v in privates.kernel.processes:iterate() do
            if v:pid() == event[2] and v:hasJoined() > 0 then
                privates.kernel:debug(sdbg, "redistributing to all other processes because at least one process called join of "..v.pid)
                        
                for k2, v2 in privates.kernel.processes:iterate() do
                    if v2 ~= proc and not v2:isFinished() then
                        privates.kernel:debug(sdbg, "redistributing because at least one process called join of "..v2.pid)
                        v2:pushev(event)
                        v2:wakeup()
                    end --
                end -- for processes
            end --
        end -- for processes
    end -- if xwos_terminated
    
    if event[1] == "char" or event[1] == "key" or event[1] == "paste" or event[1] == "key_up" then
        consumed = true
        privates.kernel:debug(sdbg, "user input received")
        local tproc = privates.kernel.modules.instances.sandbox.procinput:current()
        if tproc ~= nil then
            privates.kernel:debug(sdbg, "queue event for distribution to user input pid "..tproc:pid())
            tproc:pushev(event)
            tproc:wakeup()
        else
            -- TODO what to do with input if no one likes it?
            -- think about special key bindings fetched from background processes
            -- currently we silently discard that kind of input
        end -- 
    end -- if char
    
    -- distribute event to all processes
    if not consumed then
        for k, v in privates.kernel.processes:iterate() do
            if not v:isFinished() then
                privates.kernel:debug(sdbg, "queue event for distribution to all pids ", v:pid(), unpack(event))
                v:pushev(event)
                v:wakeup()
            end -- if not finished
        end -- for processes
    end -- if consumed
    
    return nil
end) -- function processEvt

return nil
