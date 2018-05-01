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

local setfenv = setfenv
local fscombine = fs.combine
local fsname = fs.getName
local fsdir = fs.getDir
local starts = string.startsWith
local sub = string.sub
local error = error

local function norm(root, l)
    -- fs.combine correctly maps ".." parts etc.
    if l == '' then return root end
    local res = fscombine(root, l)
    if not starts(res, root .. '/') then
        return nil
    end -- if illegal
    return res
end -- function norm

--------------------------------
-- Chroot wrapper around filesystem api
-- @module xwos.kernel.fschroot
_CMR.class("xwos.kernel.fschroot")

------------------------
-- the object privates
-- @type privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.kernel.fschroot 

.ctor(
------------------------
-- create new readonly file system
-- @function [parent=#xwprocsintern] __ctor
-- @param #xwos.kernel.fschroot self self
-- @param classmanager#clazz clazz proc class
-- @param #privates privates
-- @param xwos.kernel#xwos.kernel kernel
-- @param fs#fs fs original filesystem
-- @param #string path path (chroot)
function(self, clazz, privates, kernel, fs, path)
    --------------------------------
    -- the kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    --------------------------------
    -- the original filesystem
    -- @field [parent=#privates] fs#fs fs
    privates.fs = fs
    
    --------------------------------
    -- path (chroot)
    -- @field [parent=#privates] #string path
    privates.path = fscombine(path, '')
end) -- ctor

-------------------------------------------------------------------------------
-- Returns a wrapper object that can be used as fs-api
-- @function [parent=#xwos.kernel.fschroot] wrap
-- @param #xwos.kernel.fschroot self self
-- @param #table env the environment to be used for functions
-- @return fs#fs wrapped 
.func("wrap",
--------------------------------
-- @function [parent=#intern] wrap
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #table env the environment to be used for functions
-- @return fs#fs wrapped 
function(self, clazz, privates, env)
    local res = {}
    res.list = function(...) return self:list(...) end
    res.exists = function(...) return self:exists(...) end
    res.isDir = function(...) return self:isDir(...) end
    res.isReadOnly = function(...) return self:isReadOnly(...) end
    res.getName = function(...) return self:getName(...) end
    res.getDrive = function(...) return self:getDrive(...) end
    res.getSize = function(...) return self:getSize(...) end
    res.getFreeSpace = function(...) return self:getFreeSpace(...) end
    res.makeDir = function(...) return self:makeDir(...) end
    res.move = function(...) return self:move(...) end
    res.copy = function(...) return self:copy(...) end
    res.delete = function(...) return self:delete(...) end
    res.combine = function(...) return self:combine(...) end
    res.open = function(...) return self:open(...) end
    res.find = function(...) return self:find(...) end
    res.getDir = function(...) return self:getDir(...) end
    res.complete = function(...) return self:complete(...) end
    setfenv(res.list, env)
    setfenv(res.exists, env)
    setfenv(res.isDir, env)
    setfenv(res.isReadOnly, env)
    setfenv(res.getName, env)
    setfenv(res.getDrive, env)
    setfenv(res.getSize, env)
    setfenv(res.getFreeSpace, env)
    setfenv(res.makeDir, env)
    setfenv(res.move, env)
    setfenv(res.copy, env)
    setfenv(res.delete, env)
    setfenv(res.combine, env)
    setfenv(res.open, env)
    setfenv(res.find, env)
    setfenv(res.getDir, env)
    setfenv(res.complete, env)
    return res
end) -- function wrap

-------------------------------------------------------------------------------
-- Returns a list of all the files (including subdirectories but not their contents) contained in a directory, as a numerically indexed table. 
-- @function [parent=#xwos.kernel.fschroot] list
-- @param #xwos.kernel.fschroot self self
-- @param #string path
-- @return #table files 
.func("list",
--------------------------------
-- @function [parent=#intern] list
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @return #table
function(self, clazz, privates, path)
    local p = norm(privates.path, path)
    if p == nil then error('/' .. path .. ': ' .. ' Invalid Path') end
    return privates.fs.list(p)
end) -- function list

-------------------------------------------------------------------------------
-- Checks if a path refers to an existing file or directory.
-- @function [parent=#xwos.kernel.fschroot] exists
-- @param #xwos.kernel.fschroot self self
-- @param #string path
-- @return #boolean exists 
.func("exists",
--------------------------------
-- @function [parent=#intern] exists
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @return #boolean
function(self, clazz, privates, path)
    local p = norm(privates.path, path)
    if p == nil then return false end
    return privates.fs.exists(p)
end) -- function exists

-------------------------------------------------------------------------------
-- Checks if a path refers to an existing directory. 
-- @function [parent=#xwos.kernel.fschroot] isDir
-- @param #xwos.kernel.fschroot self self
-- @param #string path
-- @return #boolean isDirectory 
.func("isDir",
--------------------------------
-- @function [parent=#intern] isDir
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @return #boolean
function(self, clazz, privates, path)
    local p = norm(privates.path, path)
    if p == nil then return false end
    return privates.fs.isDir(p)
end) -- function isDir

-------------------------------------------------------------------------------
-- Checks if a path is read-only (i.e. cannot be modified).
-- @function [parent=#xwos.kernel.fschroot] isReadOnly
-- @param #xwos.kernel.fschroot self self
-- @param #string path 
-- @return #boolean readonly 
.func("isReadOnly",
--------------------------------
-- @function [parent=#intern] isReadOnly
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @return #boolean
function(self, clazz, privates, path)
    local p = norm(privates.path, path)
    if p == nil then return false end
    return privates.fs.isReadOnly(p)
end) -- function isReadOnly

-------------------------------------------------------------------------------
-- Gets the final component of a pathname. 
-- @function [parent=#xwos.kernel.fschroot] getName
-- @param #xwos.kernel.fschroot self self
-- @param #string path 
-- @return #string name 
.func("getName",
--------------------------------
-- @function [parent=#intern] getName
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @return #string
function(self, clazz, privates, path)
    return fsname(path)
end) -- function getName

-------------------------------------------------------------------------------
-- Gets the storage medium holding a path, or nil if the path does not exist.
-- @function [parent=#xwos.kernel.fschroot] getDrive
-- @param #xwos.kernel.fschroot self self
-- @param #string path 
-- @return #string drive 
.func("getDrive",
--------------------------------
-- @function [parent=#intern] getDrive
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @return #string
function(self, clazz, privates, path)
    local p = norm(privates.path, path)
    if p == nil then error('/' .. path .. ': ' .. ' Invalid Path') end
    return privates.fs.getDrive(p)
end) -- function getDrive

-------------------------------------------------------------------------------
-- Gets the size of a file in bytes. 
-- @function [parent=#xwos.kernel.fschroot] getSize
-- @param #xwos.kernel.fschroot self self
-- @param #string path 
-- @return #number size 
.func("getSize",
--------------------------------
-- @function [parent=#intern] getSize
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @return #number
function(self, clazz, privates, path)
    local p = norm(privates.path, path)
    if p == nil then error('/' .. path .. ': ' .. ' Invalid Path') end
    return privates.fs.getSize(p)
end) -- function getSize

-------------------------------------------------------------------------------
-- Gets the remaining space on the drive containing the given directory.
-- @function [parent=#xwos.kernel.fschroot] getFreeSpace
-- @param #xwos.kernel.fschroot self self
-- @param #string path
-- @return #number space 
.func("getFreeSpace",
--------------------------------
-- @function [parent=#intern] getFreeSpace
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @return #number
function(self, clazz, privates, path)
    local p = norm(privates.path, path)
    if p == nil then error('/' .. path .. ': ' .. ' Invalid Path') end
    return privates.fs.getFreeSpace(p)
end) -- function getFreeSpace

-------------------------------------------------------------------------------
-- Makes a directory. 
-- @function [parent=#xwos.kernel.fschroot] makeDir
-- @param #xwos.kernel.fschroot self self
-- @param #string path 
.func("makeDir",
--------------------------------
-- @function [parent=#intern] makeDir
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
function(self, clazz, privates, path)
    local p = norm(privates.path, path)
    if p == nil then error('/' .. path .. ': ' .. ' Invalid Path') end
    return privates.fs.makeDir(p)
end) -- function makeDir

-------------------------------------------------------------------------------
-- Moves a file or directory to a new location.
-- @function [parent=#xwos.kernel.fschroot] move
-- @param #xwos.kernel.fschroot self self
-- @param #string fromPath
-- @param #string toPath
.func("move",
--------------------------------
-- @function [parent=#intern] move
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string fromPath
-- @param #string toPath
function(self, clazz, privates, fromPath, toPath)
    local fp = norm(privates.path, fromPath)
    if fp == nil then error('/' .. fromPath .. ': ' .. ' Invalid Path') end
    local tp = norm(privates.path, toPath)
    if tp == nil then error('/' .. toPath .. ': ' .. ' Invalid Path') end
    return privates.fs.move(fp, tp)
end) -- function move

-------------------------------------------------------------------------------
-- Copies a file or directory to a new location. 
-- @function [parent=#xwos.kernel.fschroot] copy
-- @param #xwos.kernel.fschroot self self
-- @param #string fromPath
-- @param #string toPath
.func("copy",
--------------------------------
-- @function [parent=#intern] copy
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string fromPath
-- @param #string toPath
function(self, clazz, privates, fromPath, toPath)
    local fp = norm(privates.path, fromPath)
    if fp == nil then error('/' .. fromPath .. ': ' .. ' Invalid Path') end
    local tp = norm(privates.path, toPath)
    if tp == nil then error('/' .. toPath .. ': ' .. ' Invalid Path') end
    return privates.fs.copy(fp, tp)
end) -- function copy

-------------------------------------------------------------------------------
-- Deletes a file or directory.
-- @function [parent=#xwos.kernel.fschroot] delete
-- @param #xwos.kernel.fschroot self self
-- @param #string path
.func("delete",
--------------------------------
-- @function [parent=#intern] delete
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
function(self, clazz, privates, path)
    local p = norm(privates.path, path)
    if p == nil then error('/' .. path .. ': ' .. ' Invalid Path') end
    return privates.fs.delete(p)
end) -- function delete

-------------------------------------------------------------------------------
-- Combines two path components, returning a path consisting of the local path nested inside the base path. 
-- @function [parent=#xwos.kernel.fschroot] combine
-- @param #xwos.kernel.fschroot self self
-- @param #string basePath
-- @param #string localPath
-- @return #string path 
.func("combine",
--------------------------------
-- @function [parent=#intern] combine
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string basePath
-- @param #string localPath
-- @return #string path 
function(self, clazz, privates, basePath, localPath)
    return fscombine(basePath, localPath)
end) -- function combine

-------------------------------------------------------------------------------
-- Opens a file so it can be read or written.
-- @function [parent=#xwos.kernel.fschroot] open
-- @param #xwos.kernel.fschroot self self
-- @param #string path
-- @param #string mode 
-- @return #table handle 
.func("open",
--------------------------------
-- @function [parent=#intern] open
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @param #string mode 
-- @return #table handle 
function(self, clazz, privates, path, mode)
    local p = norm(privates.path, path)
    if p == nil then error('/' .. path .. ': ' .. ' Invalid Path') end
    return privates.fs.open(p, mode)
end) -- function open

-------------------------------------------------------------------------------
-- Searches the computer's files using wildcards. Requires version 1.6 or later. 
-- @function [parent=#xwos.kernel.fschroot] find
-- @param #xwos.kernel.fschroot self self
-- @param #string wildcard 
-- @return #table files 
.func("find",
--------------------------------
-- @function [parent=#intern] find
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string wildcard 
-- @return #table files 
function(self, clazz, privates, wildcard)
    local p = norm(privates.path, wildcard)
    if p == nil then error('/' .. wildcard .. ': ' .. ' Invalid Path') end
    local res = {}
    for k,v in pairs(privates.fs.find(p)) do
       res[k] = sub(v, #privates.path + 2)
    end
    return res
end) -- function find

-------------------------------------------------------------------------------
-- Returns the parent directory of path. Requires version 1.63 or later.
-- @function [parent=#xwos.kernel.fschroot] getDir
-- @param #xwos.kernel.fschroot self self
-- @param #string path 
-- @return #string parentDirectory 
.func("getDir",
--------------------------------
-- @function [parent=#intern] getDir
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @return #string parentDirectory 
function(self, clazz, privates, path)
    return fsdir(path)
end) -- function getDir

-------------------------------------------------------------------------------
-- Returns a list of strings that could be combined with the provided name to produce valid entries in the specified folder. Requires version 1.74 or later. 
-- @function [parent=#xwos.kernel.fschroot] complete
-- @param #xwos.kernel.fschroot self self
-- @param #string partial name
-- @param #string path
-- @param #boolean includeFiles (optional)
-- @param #boolean includeSlashes (optional)
-- @return #table matches 
.func("complete",
--------------------------------
-- @function [parent=#intern] list
-- @param #xwos.kernel.fschroot self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string partial name
-- @param #string path
-- @param #boolean includeFiles (optional)
-- @param #boolean includeSlashes (optional)
-- @return #table matches 
function(self, clazz, privates, partial, path, includeFiles, includeSlashes)
    local p = norm(privates.path, path)
    if p == nil then error('/' .. path .. ': ' .. ' Invalid Path') end
    return privates.fs.complete(partial, p, includeFiles, includeSlashes)
end) -- function complete

return nil
