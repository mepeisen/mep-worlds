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

local ser = textutils.serialize
local unser = textutils.unserialize

-----------------------
-- @module xwos.modules.appman.fsstorage
-- @extends xwos.modules.appman.storage#xwos.modules.appman.storage
_CMR.class("xwos.modules.appman.fsstorage").extends("xwos.modules.appman.storage")

------------------------
-- the object privates
-- @type privates
-- @extends xwos.modules.appman.storage#privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.modules.appman.fsstorage

.ctor(
------------------------
-- create new app storage instance
-- @function [parent=#intern] __ctor
-- @param #xwos.modules.appman.fsstorage self self
-- @param classmanager#clazz clazz session instance class
-- @param #privates privates
-- @param #number id the storage id
-- @param xwos.kernel#xwos.kernel kernel
function (self, clazz, privates, id, kernel)
    clazz.super(id, kernel)
end) -- ctor

.delegate("fs", "list", "exists", "isDir", "isReadOnly", "getName", "getDrive", "getSize", "getFreeSpace", "makeDir", "move", "copy", "delete", "combine", "open", "find", "getDir", "complete")

---------------------------------
-- Load storage from secure kernel storage
-- @function [parent=#xwos.modules.appman.fsstorage] load
-- @param #xwos.modules.appman.fsstorage self self

.func("load",
---------------------------------
-- @function [parent=#intern] load
-- @param #xwos.modules.appman.fsstorage self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    local d = privates.kernel:readSecureData("core/appman/fsstorage-"..privates.id..".dat")
    if d then
        d = unser(d)
    
        ---------------
        -- the storage path
        -- @field [parent=#privates] #string path
        privates.path = d.path
        
        ---------------
        -- the filesystem to access the apps
        -- @field [parent=#privates] xwos.kernel.fschroot#xwos.kernel.fschroot fs
        privates.fs = _CMR.new('xwos.kernel.fschroot', path)
    end -- if secure data
end) -- function load

---------------------------------
-- Save storage to secure kernel storage
-- @function [parent=#xwos.modules.appman.fsstorage] save
-- @param #xwos.modules.appman.fsstorage self self

.func("save",
---------------------------------
-- @function [parent=#intern] save
-- @param #xwos.modules.appman.fsstorage self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    local d = { path = privates.path }
    privates.kernel:writeSecureData("core/appman/fsstorage-"..privates.id..".dat", ser(d))
end) -- function save

---------------------------------
-- Sets the path to be used
-- @function [parent=#xwos.modules.appman.fsstorage] setPath
-- @param #xwos.modules.appman.fsstorage self self
-- @param #string path

.func("setPath",
---------------------------------
-- @function [parent=#intern] setPath
-- @param #xwos.modules.appman.fsstorage self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string path
function(self, clazz, privates, path)
    privates.path = path
    privates.fs = _CMR.new('xwos.kernel.fschroot', privates.kernel, privates.kernel.oldGlob.fs, path)
    self:save()
end) -- function setPath

return nil