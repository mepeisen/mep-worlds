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
-- @param #xwos.modules.appman.instance self self
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
-- Returns a wrapper object that can be used as fs-api
-- @function [parent=#xwos.modules.appman.storage] wrap
-- @param #xwos.modules.appman.storage self self
-- @param #table env the environment to be used for functions
-- @return fs#fs wrapped 
.func("wrap",
--------------------------------
-- @function [parent=#intern] list
-- @param #xwos.modules.appman.storage self
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
end) -- function list

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

---------------------------------
-- Save storage to secure kernel storage
-- @function [parent=#xwos.modules.appman.storage] save
-- @param #xwos.modules.appman.storage self self

-- abstract functions from fs api
.aFunc("save", "list", "exists", "isDir", "isReadOnly", "getName", "getDrive", "getSize", "getFreeSpace", "makeDir", "move", "copy", "delete", "combine", "open", "find", "getDir", "complete")

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
    for _, g in pairs(self:list("")) do
        for _, a in pairs(self:list(g)) do
            for _, v in pairs(self:list(g.."/"..a)) do
                if self:exists(g.."/"..a.."/"..v.."/manifest.txt") then
                    tins(res, g.."/"..a.."/"..v)
                end -- if manifest
            end -- for versions
        end -- for artifacts
    end -- for groups
    return res
end) -- function listApps

return nil