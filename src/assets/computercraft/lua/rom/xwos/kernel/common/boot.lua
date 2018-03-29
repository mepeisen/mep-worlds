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

local M = {}

local error = error
local cclite = cclite
local setfenv = setfenv
local getfenv = getfenv
local pcall = pcall
local pairs = pairs
local fsexists = fs.exists

local osvs = os.version()
local osvIter = string.gmatch(osvs, "%S+")
local osn = osvIter()
local osv = osvIter()


local arg0 = shell.getRunningProgram()
local isunsecure = false
local iscclite = false
local kernelRoot = "/rom/xwos"
if arg0:sub(0, 4) ~= "rom/" then
    isunsecure = true
    kernelRoot = "/xwos" -- TODO get path from arg0, relative to start script
end -- if not rom
if cclite~=nil then
    iscclite = true
end -- if not rom

local kernelpaths = { "", kernelRoot.."/kernel/common" }
local kernels = {}
kernels["CraftOS"] = {}
kernels["CraftOS"]["1.8"] = kernelRoot.."/kernel/1/8"
kernels["CraftOS"]["1.7"] = kernelRoot.."/kernel/1/7"
kernelpaths[1] = kernels[osn][osv]

-- prepare first sandboxing for kernel
local old2 = getfenv(2)
local old1 = getfenv(1)
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
for k, v in pairs(oldGlob) do
    newGlob[k] = v
end -- for _G

-- TODO CCLite does not have require??? Or is it a 1.7 ccraft problem?
if oldGlob.require == nil and cclite ~= nil then
    local oldload = loadfile
    oldGlob.require = function(path)
        local res, err = oldload(path..".lua")
        if res then
            return res()
        else -- if res
            error(err)
        end -- if not res
    end -- function require
    oldGlob.debug = {
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
    newGlob.require = oldGlob.require
    newGlob.debug = oldGlob.debug
end -- if not require





function M.version()
    return "0.0.3" -- TODO manipulate through maven build
end -- function version

function M.isUnsecure()
    return isunsecure
end -- function isUnsecure

function M.isCclite()
    return iscclite
end -- function isCclite

function M.injectKernelPath(path)
    table.insert(kernelpaths, kernelRoot..'/'..path)
end -- function injectKernelPath

function M.isUnknownHostOst()
    -- check if valid operating system
    if kernels[osn] == nil or kernels[osn][osv] == nil then
        return true
    end -- if valid
    return false
end -- function isUnknownHostOs

function M.isvalidConsole()
end -- function isValidConsole

function M.version()
    return "0.0.3" -- TODO manipulate through maven build
end -- function version

function M.runSandbox(func, ...)
    local oldfenv = getfenv(1)
    setfenv(1, newGlob)
    setfenv(func, newGlob)
    local state, err = pcall(func, ...)
    setfenv(1, oldfenv)
    
    if not state then
        error(err)
    end
end -- function runSandbox

function M.require(path)
    oldGlob.require(path)
end -- function require

function M.krequire(path)
    for k,v in pairs(kernelpaths) do
        local p = v.."/"..path
        local f = p..".lua"
        if fsexists(f) then
            return oldGlob.require(p)
        end -- if
    end -- for kernelpaths
    error("file "..path.." not found")
end -- function krequire

function M.kernelpaths()
    return kernelpaths
end -- function kernelpaths

function M.oldglob()
    return oldGlob
end -- function oldglob

function M.kernelRoot()
    return kernelRoot
end -- function kernelRoot

return M