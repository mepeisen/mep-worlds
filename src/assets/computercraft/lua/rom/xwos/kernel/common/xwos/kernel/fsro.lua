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

local error = error

--------------------------------
-- Read-only wrapper around filesystem api
-- @module xwos.kernel.fsro
-- @extends xwos.kernel.fschroot
_CMR.class("xwos.kernel.fsro").extends("xwos.kernel.fschroot")

------------------------
-- the object privates
-- @type privates
-- @extends xwos.kernel.fschroot#privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.kernel.fsro 

-------------------------------------------------------------------------------
-- Checks if a path is read-only (i.e. cannot be modified).
-- @function [parent=#xwos.kernel.fsro] isReadOnly
-- @param #xwos.kernel.fsro self self
-- @param #string path 
-- @return #boolean readonly 
.func("isReadOnly",
--------------------------------
-- @function [parent=#intern] isReadOnly
-- @param #xwos.kernel.fsro self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @return #boolean
function(self, clazz, privates, path)
    return true
end) -- function isReadOnly

-------------------------------------------------------------------------------
-- Makes a directory. 
-- @function [parent=#xwos.kernel.fsro] makeDir
-- @param #xwos.kernel.fsro self self
-- @param #string path 
.func("makeDir",
--------------------------------
-- @function [parent=#intern] makeDir
-- @param #xwos.kernel.fsro self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
function(self, clazz, privates, path)
    error(path .. ": Access denied")
end) -- function makeDir

-------------------------------------------------------------------------------
-- Moves a file or directory to a new location.
-- @function [parent=#xwos.kernel.fsro] move
-- @param #xwos.kernel.fsro self self
-- @param #string fromPath
-- @param #string toPath
.func("move",
--------------------------------
-- @function [parent=#intern] move
-- @param #xwos.kernel.fsro self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string fromPath
-- @param #string toPath
function(self, clazz, privates, fromPath, toPath)
    error(fromPath .. ": Access denied")
end) -- function move

-------------------------------------------------------------------------------
-- Copies a file or directory to a new location. 
-- @function [parent=#xwos.kernel.fsro] copy
-- @param #xwos.kernel.fsro self self
-- @param #string fromPath
-- @param #string toPath
.func("copy",
--------------------------------
-- @function [parent=#intern] copy
-- @param #xwos.kernel.fsro self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string fromPath
-- @param #string toPath
function(self, clazz, privates, fromPath, toPath)
    error(toPath .. ": Access denied")
end) -- function copy

-------------------------------------------------------------------------------
-- Deletes a file or directory.
-- @function [parent=#xwos.kernel.fsro] delete
-- @param #xwos.kernel.fsro self self
-- @param #string path
.func("delete",
--------------------------------
-- @function [parent=#intern] delete
-- @param #xwos.kernel.fsro self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
function(self, clazz, privates, path)
    error(path .. ": Access denied")
end) -- function delete

-------------------------------------------------------------------------------
-- Opens a file so it can be read or written.
-- @function [parent=#xwos.kernel.fsro] open
-- @param #xwos.kernel.fsro self self
-- @param #string path
-- @param #string mode 
-- @return #table handle 
.func("open",
--------------------------------
-- @function [parent=#intern] open
-- @param #xwos.kernel.fsro self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
-- @param #string mode 
-- @return #table handle 
function(self, clazz, privates, path, mode)
    if mode == "r" or mode == "rb" then
        return clazz.super(path, mode)
    end -- if mode
    error(path .. ": Access denied")
end) -- function open

return nil
