-----------------------
-- @module xwoskernel
-- @type console
local M = {}

local function create()
    print("new tab "..multishell.launch({}, "rom/programs/lua"))
end

---------------------------------
-- @function [parent=#console] preboot
-- @param xwoskernel#xwos k
M.preboot = function(k)
  k.debug("preboot console")
end

---------------------------------
-- @function [parent=#console] boot
-- @param xwoskernel#xwos k
M.boot = function(k)
  k.debug("boot console")
end

return M