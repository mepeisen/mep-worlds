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

-----------------------
-- @module xwos.modules.sandbox.procinput
_CMR.class("xwos.modules.sandbox.procinput")

------------------------
-- the object privates
-- @type privates
-- 
------------------------
-- item in process input
-- @type xwpiitem
-- @extends xwos.xwlist#xwoslistitem 

------------------------
-- associated process
-- @field [parent=#xwpiitem] xwos.kernel.process#xwos.kernel.process proc

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.modules.sandbox.procinput

.ctor(
------------------------
-- create new process input helper
-- @function [parent=#intern] __ctor
-- @param #xwos.modules.sandbox.procinput self self
-- @param classmanager#clazz clazz process input class
-- @param #privates privates
-- @param xwos.kernel#xwos.kernel kernel
function (self, clazz, privates, kernel)
    ---------------
    -- kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    ---------------
    -- list of process inputs
    -- @field [parent=#privates] xwos.xwlist#xwos.xwlist
    privates.list = _CMR.new("xwos.xwlist")
end) -- ctor

-----------------------
-- Returns the current process fetching input
-- @function [parent=#xwos.modules.sandbox.procinput] current
-- @param #xwos.modules.sandbox.procinput self
-- @return xwos.kernel.process#xwos.kernel.process the current process or nil if no process ist set

.func("current",
-----------------------
-- @function [parent=#intern] current
-- @param #xwos.modules.sandbox.procinput self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @return xwos.kernel.process#xwos.kernel.process
function(self, clazz, privates)
    local res = privates.list:last() -- #xwpiitem
    if res ~= nil then
        return res.proc
    end -- if res
    return nil
end) -- function current

-----------------------
-- Aquires input for given process
-- @function [parent=#xwos.modules.sandbox.procinput] acquire
-- @param #xwos.modules.sandbox.procinput self
-- @param xwos.kernel.process#xwos.kernel.process process the process to acquire the input

.func("acquire",
-----------------------
-- @function [parent=#intern] acquire
-- @param #xwos.modules.sandbox.procinput self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param xwos.kernel.process#xwos.kernel.process process
function(self, clazz, privates, process)
    process:debug("fetching user input (front process)")
    privates.list:push({proc = process})
end) -- function acquire

-----------------------
-- Release input for given process if it blocks the input (=is current)
-- @function [parent=#xwos.modules.sandbox.procinput] release
-- @param #xwos.modules.sandbox.procinput self
-- @param xwos.kernel.process#xwos.kernel.process process the process to release the input

.func("release",
-----------------------
-- @function [parent=#intern] release
-- @param #xwos.modules.sandbox.procinput self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param xwos.kernel.process#xwos.kernel.process process
function(self, clazz, privates, process)
    local res = privates.list:last() -- #xwpiitem
    if res ~= nil and res.proc == process then
        process:debug("release user input (front process)")
        repeat
            privates.list:pop()
            res = privates.list:last()
        until res == nil or not res.proc:isFinished()
        local npid = "none"
        if res ~= nil then
            npid = res.proc:pid()
        end
        process:debug("switched user input to",npid,"(front process)")
    end -- if res.proc == process
end) -- function acquire

return nil
