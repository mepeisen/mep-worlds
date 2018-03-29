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

term.clear()
term.setCursorPos(1, 1)

local arg0 = shell.getRunningProgram()
local kernelRoot = "/rom/xwos"
if arg0:sub(0, 4) ~= "rom/" then
    kernelRoot = "/xwos" -- TODO get path from arg0, relative to start script
end -- if not secured

local boot = dofile(kernelRoot.."/kernel/common/boot.lua");

local myver = boot.version()

-- check if already booted
if xwos then
  print()
  print("FAILED... We are already running XW-OS...")
  return nil
end -- if already booted

-- check if valid operating system
if boot.isUnknownHostOst() then
    print()
    print("FAILED... running on unknown operating system or version...")
    print("OS-version we got: " .. osvs)
    print("Currently we require CraftOS at version 1.7/1.8")
    return nil
end -- if valid

print("** testing XW-OS........")
print("** XW-OS version " .. myver)

boot.runSandbox(function()
    boot.injectKernelPath("kernel/test")
    boot.krequire("testsuite")(boot)
end)
