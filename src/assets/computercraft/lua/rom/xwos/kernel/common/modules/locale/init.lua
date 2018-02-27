-----------------------
-- @module xwoskernel
-- @type locale
local M = {}

---------------------------------
-- @function [parent=#locale] preboot
-- @param xwoskernel#xwos k
M.preboot = function(k)
  k.debug("preboot locale")
end

---------------------------------
-- @function [parent=#locale] boot
-- @param xwoskernel#xwos k
M.boot = function(k)
  k.debug("boot locale")
end

return M