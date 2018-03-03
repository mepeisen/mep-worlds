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