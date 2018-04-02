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
local tinsert = table.insert
local slines = string.lines
local ssub = string.sub
local startsWith = function(str, starts)
    return (str:find('^'..starts)) and true or false
end

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
newGlob._G = newGlob

local oldload = loadfile
oldGlob.require = function(path)
    local res, err = oldload(path..".lua", newGlob)
    if res then
        return res()
    else -- if res
        error(err)
    end -- if not res
end -- function require
newGlob.require = oldGlob.require





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

function M.newglob()
    return newGlob
end -- function newglob

function M.kernelRoot()
    return kernelRoot
end -- function kernelRoot

function M.trace(asString)
    if oldGlob.cclite ~= nil then
        -- cclite debug traces
        local trace = oldGlob.cclite.traceback()
        local res = {}
        for v in slines(trace) do
            if startsWith(v, " [C]") then
                -- TODO parse "[C]: in function ´pcall´"
                tinsert(res, { hr=v, type="B" })
            elseif startsWith(v, " ") then
                -- TODO parse "test.lua:2: in function ´foo´
                tinsert(res, { hr=v, type="F" })
            end -- if trace
        end -- for lines
        return res
    end -- cclite
    
    -- classic way
    local res = {}
    local level = 1
    while level < 30 do -- TODO configure max depth
        local state, err = pcall(error, "$$$", level + 2)
        if err == "$$$" then break end
        -- TODO parse: "test.lua:15:"
        tinsert(res, { hr=ssub(err, 0, -6), type="F" })
        level = level + 1
    end
    if asString then
        local str = ""
        for _,v in pairs(res) do
            str = str .. "["..v.type.."] "..v.hr .. "\n"
        end
        return str
    end
    return res
end -- function trace

for _,v in pairs(M) do
    if type(v) == "function" then setfenv(v, newGlob) end
end

oldGlob.boot = M

return M