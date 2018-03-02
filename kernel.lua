local origGetfenv = getfenv
local origSetfenv = setfenv

--------------------------------
-- local kernel
-- @type xwos.kernel
local M = {}

--------------------------------
-- @field [parent=#xwos.kernel] #xwos.processes processes the known xwos processes
M.processes = require('xwos/processes')

return M
