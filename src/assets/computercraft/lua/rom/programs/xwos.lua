term.clear()

local tArgs = ...

local myver = "0.0.1" -- TODO manipulate through maven build
local osvs = os.version()
local osvIter = string.gmatch(osvs, "%S+")
local osn = osvIter()
local osv = osvIter()

local kernelpaths = { "", "/rom/xwos/kernel/common" }
local kernels = {}
kernels["CraftOS"] = {}
kernels["CraftOS"]["1.8"] = "/rom/xwos/kernel/1_8"

print("** booting XW-OS........")
print("** XW-OS version " .. myver)
print("** Copyright © 2018 by xworlds.eu.")
print("** All rights reserved.")

-- check if already booted
if _G.xwos then
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
local oldGlob = getfenv(1)
if oldGlob ~= _G then
    print()
    print("FAILED... please run XW-OS in startup script or on root console...")
    print("Running inside other operating systems may not be supported...")
    return nil
end -- if not globals

-- create an explicit copy of globals
local newGlob = {}
for k, v in oldGlob.items(oldGlob) do
    newGlob[k] = v
end -- for _G

-- redirect require for kernel loading
-- using functions from oldGlob for security reasons
newGlob.require = function(path)
    for k, v in oldGlob.items(kernelpaths) do
        local target = v .. "/" .. oldGlob.string.gsub(path, "%.", "/")
        local targetFile = target .. ".lua"
        if oldGlob.fs.exists(targetFile) then
            return oldGlob.require(target)
        end -- if file exists
    end -- for kernelpaths
    return nil
end -- function require

local function ex()
    local kernel = require('xwos.kernel')
    
    kernel.boot(myver, kernelpaths, oldGlob, tArgs)
    kernel.startup()
end -- function ex

local function wrap(name)
    if newGlob[name] ~= nil then
        local res = {}
        for k, v in oldGlob.items(newGlob[name]) do
            res[k] = v
        end -- for _G
        newGlob[name] = res
    end -- if exists
end -- function wrap

wrap("table")
wrap("fs")

setfenv(1, newGlob)
local state, err = pcall(ex)
setfenv(1, oldGlob)

if not state then
    error(err)
end

