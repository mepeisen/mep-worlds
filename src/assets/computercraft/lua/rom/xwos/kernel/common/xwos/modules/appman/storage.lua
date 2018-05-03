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
local tins = table.insert
local pairs = pairs

-----------------------
-- @module xwos.modules.appman.storage
_CMR.class("xwos.modules.appman.storage").abstract()

------------------------
-- the object privates
-- @type privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.modules.appman.storage

.ctor(
------------------------
-- create new app storage instance
-- @function [parent=#intern] __ctor
-- @param #xwos.modules.appman.storage self self
-- @param classmanager#clazz clazz session instance class
-- @param #privates privates
-- @param #number id the storage id
-- @param xwos.kernel#xwos.kernel kernel
function (self, clazz, privates, id, kernel)
    ---------------
    -- the kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    ---------------
    -- the unique storage id
    -- @field [parent=#privates] #number id
    privates.id = id
end) -- ctor

---------------------------------
-- Returns instance id
-- @function [parent=#xwos.modules.appman.storage] id
-- @param #xwos.modules.appman.storage self self
-- @return #number storage id

.func("id",
---------------------------------
-- @function [parent=#intern] id
-- @param #xwos.modules.appman.storage self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @return #number
function(self, clazz, privates)
    return privates.id
end) -- function id

-------------------------------------------------------------------------------
-- Returns a list of all the files (including subdirectories but not their contents) contained in a directory, as a numerically indexed table. 
-- @function [parent=#xwos.modules.appman.storage] list
-- @param #xwos.modules.appman.storage self self
-- @param #string path
-- @return #table files 

-------------------------------------------------------------------------------
-- Checks if a path refers to an existing file or directory.
-- @function [parent=#xwos.modules.appman.storage] exists
-- @param #xwos.modules.appman.storage self self
-- @param #string path
-- @return #boolean exists

-------------------------------------------------------------------------------
-- Checks if a path refers to an existing directory. 
-- @function [parent=#xwos.modules.appman.storage] isDir
-- @param #xwos.modules.appman.storage self self
-- @param #string path
-- @return #boolean isDirectory

-------------------------------------------------------------------------------
-- Checks if a path is read-only (i.e. cannot be modified).
-- @function [parent=#xwos.modules.appman.storage] isReadOnly
-- @param #xwos.modules.appman.storage self self
-- @param #string path 
-- @return #boolean readonly 

-------------------------------------------------------------------------------
-- Gets the final component of a pathname. 
-- @function [parent=#xwos.modules.appman.storage] getName
-- @param #xwos.modules.appman.storage self self
-- @param #string path 
-- @return #string name 

-------------------------------------------------------------------------------
-- Gets the storage medium holding a path, or nil if the path does not exist.
-- @function [parent=#xwos.modules.appman.storage] getDrive
-- @param #xwos.modules.appman.storage self self
-- @param #string path 
-- @return #string drive 

-------------------------------------------------------------------------------
-- Gets the size of a file in bytes. 
-- @function [parent=#xwos.modules.appman.storage] getSize
-- @param #xwos.modules.appman.storage self self
-- @param #string path 
-- @return #number size 

-------------------------------------------------------------------------------
-- Gets the remaining space on the drive containing the given directory.
-- @function [parent=#xwos.modules.appman.storage] getFreeSpace
-- @param #xwos.modules.appman.storage self self
-- @param #string path
-- @return #number space 

-------------------------------------------------------------------------------
-- Makes a directory. 
-- @function [parent=#xwos.modules.appman.storage] makeDir
-- @param #xwos.modules.appman.storage self self
-- @param #string path 

-------------------------------------------------------------------------------
-- Moves a file or directory to a new location.
-- @function [parent=#xwos.modules.appman.storage] move
-- @param #xwos.modules.appman.storage self self
-- @param #string fromPath
-- @param #string toPath

-------------------------------------------------------------------------------
-- Copies a file or directory to a new location. 
-- @function [parent=#xwos.modules.appman.storage] copy
-- @param #xwos.modules.appman.storage self self
-- @param #string fromPath
-- @param #string toPath

-------------------------------------------------------------------------------
-- Deletes a file or directory.
-- @function [parent=#xwos.modules.appman.storage] delete
-- @param #xwos.modules.appman.storage self self
-- @param #string path

-------------------------------------------------------------------------------
-- Combines two path components, returning a path consisting of the local path nested inside the base path. 
-- @function [parent=#xwos.modules.appman.storage] combine
-- @param #xwos.modules.appman.storage self self
-- @param #string basePath
-- @param #string localPath
-- @return #string path 

-------------------------------------------------------------------------------
-- Opens a file so it can be read or written.
-- @function [parent=#xwos.modules.appman.storage] open
-- @param #xwos.modules.appman.storage self self
-- @param #string path
-- @param #string mode 
-- @return #table handle 

-------------------------------------------------------------------------------
-- Searches the computer's files using wildcards. Requires version 1.6 or later. 
-- @function [parent=#xwos.modules.appman.storage] find
-- @param #xwos.modules.appman.storage self self
-- @param #string wildcard 
-- @return #table files 

-------------------------------------------------------------------------------
-- Returns the parent directory of path. Requires version 1.63 or later.
-- @function [parent=#xwos.modules.appman.storage] getDir
-- @param #xwos.modules.appman.storage self self
-- @param #string path 
-- @return #string parentDirectory 

-------------------------------------------------------------------------------
-- Returns a list of strings that could be combined with the provided name to produce valid entries in the specified folder. Requires version 1.74 or later. 
-- @function [parent=#xwos.modules.appman.storage] complete
-- @param #xwos.modules.appman.storage self self
-- @param #string partial name
-- @param #string path
-- @param #boolean includeFiles (optional)
-- @param #boolean includeSlashes (optional)
-- @return #table matches 

-- abstract functions from fs api
.aFunc("list", "exists", "isDir", "isReadOnly", "getName", "getDrive", "getSize", "getFreeSpace", "makeDir", "move", "copy", "delete", "combine", "open", "find", "getDir", "complete")

---------------------------------
-- Save storage to secure kernel storage
-- @function [parent=#xwos.modules.appman.storage] save
-- @param #xwos.modules.appman.storage self self
.aFunc("save")

---------------------------------
-- Return filesystem instance
-- @function [parent=#xwos.modules.appman.storage] fs
-- @param #xwos.modules.appman.storage self self
-- @return xwos.kernel.fschroot#xwos.kernel.fschroot filesystem instance to access the storage
.aFunc("fs")

---------------------------------
-- List applications from underlying filesystem
-- @function [parent=#xwos.modules.appman.storage] listApps
-- @param #xwos.modules.appman.storage self self
-- @return #table list of relative folders representing application folders

.func("listApps",
---------------------------------
-- @function [parent=#intern] listApps
-- @param #xwos.modules.appman.storage self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
-- @return #table
function(self, clazz, privates)
    local res = {}
    if self:exists("") then
        for _, g in pairs(self:list("")) do
            if self:isDir(g) then
                for _, a in pairs(self:list(g)) do
                    if self:isDir(g.."/"..a) then
                        for _, v in pairs(self:list(g.."/"..a)) do
                            if self:isDir(g.."/"..a.."/"..v) then
                                if self:exists(g.."/"..a.."/"..v.."/manifest.txt") then
                                    tins(res, g.."/"..a.."/"..v)
                                end -- if manifest
                            end -- if isDir(g.."/"..a.."/"..v)
                        end -- for versions
                    end -- if isDir(g.."/"..a)
                end -- for artifacts
            end -- if isDir(g)
        end -- for groups
    end -- if exists
    return res
end) -- function listApps

return nil