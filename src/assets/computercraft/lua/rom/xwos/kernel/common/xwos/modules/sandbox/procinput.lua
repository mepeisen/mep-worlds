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
local M = {}

local kernel -- xwos.kernel#xwos.kernel

-- TODO refactor following to some linked stack type
-----------------------
-- @type pinput

----------------------------------
-- @field [parent=#pinput] #pinput prev the previous input
     
-----------------------
-- @field [parent=#pinput] xwos.processes#xwos.process proc the input process

-----------------------
-- @field [parent=#xwos.modules.sandbox.procinput] #pinput current the current process input (front process)
M.current = nil

-----------------------
-- injects the kernel
-- @function [parent=#xwos.modules.sandbox.procinput] setKernel
-- @param xwos.kernel#xwos.kernel k the kernel
M.setKernel = function(k)
    kernel = k
end -- function setKernel

M.acquire = function(proc)
    -- first invocation has no kernel
    if kernel ~= nil and proc ~= nil then
        kernel.debug("[PID"..proc.pid.."] fetching user input (front process)")
    end -- if kernel
    local r = {}
    ---------------------
    -- release input if proc blocks it
    -- @function [parent=#pinput] release
    -- @param xwos.processes#xwos.process proc2 process to release the env
    r.release = function(proc2)
        if r.proc == proc2 then
            kernel.debug("[PID"..proc2.pid.."] releasing user input (front process)")
            M.current = r.prev
            while M.current.proc ~= nil and M.current.proc.procstate == "finished" do
                M.current = M.current.prev
            end -- while finished
            if M.current.proc ~= nil then
                kernel.debug("[PID"..proc2.pid.."] switched user input to "..M.current.proc.pid.." (front process)")
            end -- if proc
        end -- if proc
    end -- function release
    r.prev = M.current
    r.proc = proc
    M.current = r
end -- function acquire

M.acquire(nil)

return M
