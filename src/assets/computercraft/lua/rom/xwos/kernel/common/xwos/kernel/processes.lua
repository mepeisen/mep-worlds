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

local cocreate = coroutine.create
local coresume = coroutine.resume
local getfenv = getfenv
local setfenv = setfenv
local setmetatable = setmetatable
local type = type
local dofile = dofile
local loadfile = loadfile
local pcall = pcall
local origpackage = package
local print = print
local error = error
local origser = textutils.serialize
local pairs = pairs
local origyield = coroutine.yield
local originsert = table.insert
local origqueue = os.queueEvent

--------------------------------
-- local process environments
-- @module xwos.kernel.processes
_CMR.class("xwos.kernel.processes")

-- TODO iterator function etc.

------------------------
-- the object privates
-- @type xwprocsprivates

------------------------
-- the internal class
-- @type xwprocsintern
-- @extends #xwos.kernel.processes 

.ctor(
------------------------
-- create new process manager
-- @function [parent=#xwprocsintern] __ctor
-- @param #xwos.kernel.processes self self
-- @param classmanager#clazz clazz proc class
-- @param #xwprocsprivates privates
function(self, clazz, privates)
    --------------------------------
    -- next pid to use for new processes
    -- @field [parent=#xwprocsprivates] #number nextPid
    privates.nextPid = 0

    --------------------------------
    -- the known processes
    -- @field [parent=#xwprocsprivates] xwos.xwlist#xwos.xwlist list
    privates.list = _CMR.new("xwos.xwlist")

    --------------------------------
    -- thw processes by id
    -- @field [parent=#xwprocsprivates] #map<#number,xwos.kernel.process#xwos.kernel.process> procs
    privates.procs = {}
end) -- ctor

--------------------------------
-- creates a new process
-- @function [parent=#xwos.kernel.processes] create
-- @param #xwos.kernel.processes self self
-- @param xwos.kernel.process#xwos.kernel.process p the parent process
-- @param xwos.kernel#xwos.kernel k the kernel table
-- @param global#global env the global process environment
-- @param #table factories functions with signature (proc, env) to initialize the new process or environment
-- @return xwos.kernel.process#xwos.kernel.process

.func("create",
--------------------------------
-- @function [parent=#xwprocsintern] create
-- @param #xwos.kernel.processes self
-- @param classmanager#clazz clazz
-- @param #xwprocsprivates privates
-- @param xwos.kernel.process#xwos.kernel.process p
-- @param xwos.kernel#xwos.kernel k
-- @param global#global env
-- @param #table factories
-- @return xwos.kernel.process#xwos.kernel.process
function(self, clazz, privates, p, k, env, factories)
    --------------------------------
    -- kernel reference
    -- @field [parent=#xwprocsprivates] xwos.kernel#xwos.kernel kernel
    privates.kernel = k
    
    local newPid = privates.nextPid
    privates.nextPid = privates.nextPid + 1
    
    local proc = _CMR.new("xwos.kernel.process", privates, p, k, newPid, env, factories)
    privates.list:push(proc)
    privates.procs[newPid] = proc
    return proc
end) -- function new

--------------------------------
-- iterator over all processes
-- @function [parent=#xwos.kernel.processes] iterate
-- @param #xwos.kernel.processes self self
-- @return #function

.func("iterate",
--------------------------------
-- @function [parent=#xwprocsintern] iterate
-- @param #xwos.kernel.processes self
-- @param classmanager#clazz clazz
-- @param #xwprocsprivates privates
-- @return #function
function(self, clazz, privates)
    return privates.list:iterate()
end) -- function new

return nil
