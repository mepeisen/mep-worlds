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

local tArgs = {...}

local myver = "0.0.2" -- TODO manipulate through maven build
local osvs = os.version()
local osvIter = string.gmatch(osvs, "%S+")
local osn = osvIter()
local osv = osvIter()

local kernelpaths = { "", "/rom/xwos/kernel/common" }
local kernels = {}
kernels["CraftOS"] = {}
kernels["CraftOS"]["1.8"] = "/rom/xwos/kernel/1/8"

print("** booting XW-OS........")
print("** XW-OS version " .. myver)
print("** Copyright © 2018 by xworlds.eu.")
print("** All rights reserved.")

-- check if already booted
if xwos then
  print()
  print("FAILED... We are already running XW-OS...")
  return nil
end -- if already booted

-- check if valid operating system
if kernels[osn] == nil or kernels[osn][osv] == nil then
    print()
    print("FAILED... running on unknown operating system or version...")
    print("OS-version we got: " .. osvs)
    print("Currently we require CraftOS at version 1.8")
    return nil
end -- if valid

-- kernel file loader
kernelpaths[1] = kernels[osn][osv]

-- prepare first sandboxing for kernel
local old2 = getfenv(2)
local old1 = getfenv(1)
if old2 ~= _G or old1.require == nil then
    print()
    print("FAILED... please run XW-OS in startup script or on root console...")
    print("Running inside other operating systems may not be supported...")
    return nil
end -- if not globals
local oldGlob = {}
for k, v in pairs(_G) do
    oldGlob[k] = v
end -- for _G
for k, v in pairs(old2) do
    oldGlob[k] = v
end -- for _G
for k, v in pairs(old1) do
    oldGlob[k] = v
end -- for _G

-- create an explicit copy of globals
local newGlob = {}
for k, v in oldGlob.pairs(oldGlob) do
    newGlob[k] = v
end -- for _G

-- redirect require for kernel loading
-- using functions from oldGlob for security reasons
local function krequire(path)
    for k, v in oldGlob.pairs(kernelpaths) do
        local target = v .. "/" .. oldGlob.string.gsub(path, "%.", "/")
        local targetFile = target .. ".lua"
        if oldGlob.fs.exists(targetFile) then
            local res = oldGlob.require(target)
            -- print("loaded file "..target)
            return res
        end -- if file exists
    end -- for kernelpaths
    return nil
end -- function require

setfenv(1, newGlob)
local state, err = pcall(function()
        local kernel = krequire('xwos.kernel') -- xwos.kernel#xwos.kernel
        
        kernel.boot(myver, kernelpaths, krequire, oldGlob, tArgs)
        kernel.startup()
    end -- function ex
)
setfenv(1, old1)

if not state then
    error(err)
end


