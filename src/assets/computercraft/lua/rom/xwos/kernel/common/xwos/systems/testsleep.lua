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

local function func1()
    print("[1]pid=",pid)
    print("[1]Hello World!")
    sleep(5)
    print("[1]Hello again");
end
local function func2()
    print("[2]pid=",pid)
    sleep(5)
    print("[2]Hello World!")
    sleep(5)
    print("[2]Hello again");
end
print("[0]pid=",pid)
local proc1 = xwos.pmr.createThread()
local proc2 = xwos.pmr.createThread()
proc1.spawn(func1)
proc2.spawn(func2)
proc1.join()
proc2.join()
print("Ending")
