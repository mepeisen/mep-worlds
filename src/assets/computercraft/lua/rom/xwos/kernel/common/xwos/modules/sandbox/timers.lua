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
local M = {}

local kernel -- xwos.kernel#xwos.kernel

-----------------------
-- injects the kernel
-- @function [parent=#xwos.modules.sandbox.timers] setKernel
-- @param xwos.kernel#xwos.kernel k the kernel
M.setKernel = function(k)
    kernel = k
end -- function setKernel

-------------------------------
-- creates a new timer
-- @function [parent=#xwos.modules.sandbox.timers] new
-- @param #number id the timer number
-- @param xwos.processes#xwos.process proc
-- @return #xwos.timer
M.new = function(id, proc)
    --------------------------------
    -- timer type
    -- @type xwos.timer
    local R = {}
    
    --------------------------------
    -- @field [parent=#xwos.timer] #number id the timer id
    R.id = id
    
    --------------------------------
    -- @field [parent=#xwos.timer] #number id the timer id
    R.proc = proc
    
    --------------------------------
    -- Remove the timer from timer table
    -- @function [parent=#xwos.timer] remove
    R.remove = function()
        M[R.id] = nil
    end -- function remove
    
    -- TODO remove discarded timers on process termination
    
    -- store timer
    M[R.id] = R
                    
    return R
end -- function new

return M