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
-- @module xwos.modules.sandbox.timers
_CMR.class("xwos.modules.sandbox.timers")

------------------------
-- the object privates
-- @type privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.modules.sandbox.timers

.ctor(
------------------------
-- create new timer helper
-- @function [parent=#intern] __ctor
-- @param #xwos.modules.sandbox.timers self self
-- @param classmanager#clazz clazz event queue class
-- @param #privates privates
-- @param xwos.kernel#xwos.kernel kernel
function (self, clazz, privates, kernel)
    ---------------
    -- kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    ---------------
    -- known timers
    -- @field [parent=#privates] #map<#number,xwos.kernel.process#xwos.kernel.process> list
    privates.list = {}
end) -- ctor

-------------------------------
-- creates a new timer
-- @function [parent=#xwos.modules.sandbox.timers] create
-- @param #xwos.modules.sandbox.timers self self
-- @param #number id the timer number
-- @param xwos.kernel.process#xwos.kernel.process proc

.func("create",
-------------------------------
-- @function [parent=#intern] create
-- @param #xwos.modules.sandbox.timers self self
-- @param classmanager#clazz clazz event queue class
-- @param #privates privates
-- @param #number id
-- @param xwos.kernel.process#xwos.kernel.process proc
function(self, clazz, privates, id, proc)
    privates.list[id] = proc
end) -- function create

-------------------------------
-- Returns an existing timer process
-- @function [parent=#xwos.modules.sandbox.timers] get
-- @param #xwos.modules.sandbox.timers self self
-- @param #number id the timer number
-- @return xwos.kernel.process#xwos.kernel.process process or nil if timer with given id was not found

.func("get",
-------------------------------
-- @function [parent=#intern] get
-- @param #xwos.modules.sandbox.timers self self
-- @param classmanager#clazz clazz event queue class
-- @param #privates privates
-- @param #number id
-- @return xwos.kernel.process#xwos.kernel.process
function(self, clazz, privates, id)
    return privates.list[id]
end) -- function create

return nil