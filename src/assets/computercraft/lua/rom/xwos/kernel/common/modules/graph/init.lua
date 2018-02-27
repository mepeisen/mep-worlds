-----------------------
-- @module xwoskernel
-- @type graph
local M = {}

---------------------------------
-- @function [parent=#graph] preboot
-- @param xwoskernel#xwos k
M.preboot = function(k)
  k.debug("preboot graph")
end

---------------------------------
-- @function [parent=#graph] boot
-- @param xwoskernel#xwos k
M.boot = function(k)
  k.debug("boot graph")
end

return M