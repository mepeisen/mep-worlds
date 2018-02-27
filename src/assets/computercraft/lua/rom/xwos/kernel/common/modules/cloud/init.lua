-----------------------
-- @module xwoskernel
-- @type cloud
local M = {}

---------------------------------
-- @function [parent=#cloud] preboot
-- @param xwoskernel#xwos k
M.preboot = function(k)
  k.debug("preboot cloud")
end

---------------------------------
-- @function [parent=#cloud] boot
-- @param xwoskernel#xwos k
M.boot = function(k)
  k.debug("boot cloud")
end

return M