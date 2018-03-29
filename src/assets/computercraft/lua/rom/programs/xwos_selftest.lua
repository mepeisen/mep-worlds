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

local arg0 = shell.getRunningProgram()
kernelRoot = "/rom/xwos"
if arg0:sub(0, 4) ~= "rom/" then
    kernelRoot = "/xwos" -- TODO get path from arg0, relative to start script
end -- if not rom

if require == nil then
    local oldload = loadfile
    require = function(path)
        -- print("require "..path)
        local res, err = oldload(path..".lua")
        if res then
            return res()
        else -- if res
            error(err)
        end -- if not res
    end -- function require
    debug = {
        getinfo = function(n)
            -- TODO find a way to detect file and line in cclite
            return {
                source = "@?",
                short_src = "?",
                currentline = -1,
                linedefined = -1,
                what = "C",
                name = "?",
                namewhat = "",
                nups = 0,
                func = nil
            }
        end -- function debug.getinfo
    }
end -- if not require

dofile(kernelRoot..'/kernel/test/testsuite.lua')
