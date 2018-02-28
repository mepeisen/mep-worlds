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


local sandbox
local ex
local origRequire = require
local origFs = _G.fs
local origStringGsub = _G.string.gsub
local origItems = _G.pairs

ex = function(kernelpaths)
    -- redirect require for kernel loading
    _G.require = function(path)
        print("require "..path)
        for k, v in origItems(kernelpaths) do
            local target = v .. "/" .. origStringGsub(path, "%.", "/")
            local targetFile = target .. ".lua"
            print("searching for "..targetFile)
            if origFs.exists(targetFile) then
                print("origRequire "..target)
                return origRequire(target)
            end -- if file exists
        end -- for kernelpaths
        return nil
    end -- function require
    
    local kernel = _G.require('xwos.kernel')
    
    kernel.boot(myver, kernelpaths, origRequire, sandbox, tArgs)
    kernel.startup()
end -- function ex

sandbox = function(secure, func, ...)
    -- save globals
    local origGlobal = _G
    local newGlobal = {}
    for k, v in origItems(origGlobal) do
        newGlobal[k] = v
    end -- for _G
    print("creating sandbox") -- TODO remove
    
    if secure then
        local function getStackDepth()
            for i=1,50000,1 do -- 50000 should be really enough, default max limit is 256
                local state = pcall(origGlobal.getfenv, i + 2)
                if not state then
                    return i
                end -- if not state
            end -- for
            return 50000
        end  -- function getStackDepth
        
        print("[sb] calling getStackDepth") -- TODO remove
        local stackDepth = getStackDepth()
        print("[sb] getStackDepth returns "..stackDepth) -- TODO remove
    
        newGlobal.setfenv = function(f, val)
            print("[sb] called setfenv("..f..",...)") -- TODO remove
            local curDepth = getStackDepth()
            print("[sb] getStackDepth returns "..curDepth) -- TODO remove
            local limit = curDepth - stackDepth
            
            if f == 0 then
                local prev = newGlobal
                newGlobal = val
                origGlobal.setfenv(limit, newGlobal) -- TODO does this work?
                return prev
            end -- if global
            
            if f < 0 then
                error("bad argument #1: level must be non-negative")
            end -- if negative
            if f < limit then
                return origGlobal.setfenv(f + 1, val)
            end -- if limit
            error("bad argument #1: invalid level")
        end -- function setfenv
        
        newGlobal.getfenv = function(f)
            print("[sb] called getfenv("..f..")") -- TODO remove
            if (f == 0) then
                return newGlobal
            end -- if global
            local curDepth = getStackDepth()
            print("[sb] getStackDepth returns "..curDepth) -- TODO remove
            local limit = curDepth - stackDepth
            if f < 0 then
                error("bad argument #1: level must be non-negative")
            end -- if negative
            if f < limit then
                return origGlobal.getfenv(f + 1)
            end -- if limit
            error("bad argument #1: invalid level")
        end -- function getfenv
    end -- if secure
    
    origGlobal.setfenv(1, newGlobal)
    
    -- call func
    local status, err = pcall(func, ...)
    
    -- reset globals to saved values
    origGlobal.setfenv(1, origGlobal)
    
    if not status then
        error(err)
    end -- if error
end -- function sandbox

sandbox(true, ex, kernelpaths)

-- remote monitors: http://www.computercraft.info/forums2/index.php?/topic/25973-multiple-monitors-via-wired-network-cables/
