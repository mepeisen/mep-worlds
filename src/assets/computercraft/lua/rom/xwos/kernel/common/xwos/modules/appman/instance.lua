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
local pairs = pairs
local strgmatch = string.gmatch
local strgsub = string.gsub
local strstarts = string.startsWith

local function trim(s)
    return strgsub(s, "^%s*(.-)%s*$", "%1")
end -- trim

-----------------------
-- @module xwos.modules.appman.instance
_CMR.class("xwos.modules.appman.instance")

------------------------
-- the object privates
-- @type privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.modules.appman.instance

.ctor(
------------------------
-- create new app installation instance
-- @function [parent=#intern] __ctor
-- @param #xwos.modules.appman.instance self self
-- @param classmanager#clazz clazz session instance class
-- @param #privates privates
-- @param xwos.modules.appman.storage#xwos.modules.appman.storage storage the owning storage
-- @param #string path the installation path of given app
-- @param xwos.kernel#xwos.kernel kernel
-- @param #number id the unique application id
function (self, clazz, privates, storage, path, kernel, id)
    ---------------
    -- the kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    ---------------
    -- the unique app id
    -- @field [parent=#privates] #number id
    privates.id = id
    
    ---------------
    -- the installation path
    -- @field [parent=#privates] #string path
    privates.path = path
    
    ---------------
    -- the owning storage
    -- @field [parent=#privates] xwos.modules.appman.storage#xwos.modules.appman.storage storage
    privates.storage = storage
    
    ---------------
    -- the manifest class
    -- @type manifest
    
    ---------------
    -- human readable app name
    -- @field [parent=#manifest] #string name
    
    ---------------
    -- technical info (group name)
    -- @field [parent=#manifest] #string group
    
    ---------------
    -- technical info (artifact name)
    -- @field [parent=#manifest] #string artifact
    
    ---------------
    -- technical info (version number)
    -- @field [parent=#manifest] #string version
    
    ---------------
    -- author information (name)
    -- @field [parent=#manifest] #string author
    
    ---------------
    -- author information (email)
    -- @field [parent=#manifest] #string email
    
    ---------------
    -- author information (url)
    -- @field [parent=#manifest] #string url
    
    ---------------
    -- dependencies
    -- @field [parent=#manifest] #string dependencies
    
    ---------------
    -- hardware information
    -- @field [parent=#manifest] #string hardware
    
    ---------------
    -- namespace
    -- @field [parent=#manifest] #string namespace
    
    ---------------
    -- main
    -- @field [parent=#manifest] #string main
    
    ---------------
    -- the manifest data
    -- @field [parent=#privates] #manifest manifest
    privates.manifest = {}
    local mf = privates.path .. '/manifest.txt'
    if privates.storage:exists(mf) then
        local h = privates.storage:open(mf, "r")
        local lines = strgmatch(h.readAll(), "[^\r\n]+")
        h.close()
        for s in lines do
            local s2 = trim(s)
            if #s2 > 0 and not strstarts(s2, "#") then
                s2 = strgmatch(s2, "[^=]+")
                privates.manifest[trim(s2())] = trim(s2())
            end -- if not comment
        end -- for lines
    end -- if manifest
end) -- ctor

---------------------------------
-- Returns instance id
-- @function [parent=#xwos.modules.appman.instance] id
-- @param #xwos.modules.appman.instance self self
-- @return #number instance id

.func("id",
---------------------------------
-- @function [parent=#intern] id
-- @param #xwos.modules.appman.instance self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @return #number
function(self, clazz, privates)
    return privates.id
end) -- function id

---------------------------------
-- Returns manifest data
-- @function [parent=#xwos.modules.appman.instance] manifest
-- @param #xwos.modules.appman.instance self self
-- @return #manifest manifest

.func("manifest",
---------------------------------
-- @function [parent=#intern] manifest
-- @param #xwos.modules.appman.instance self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @return #manifest
function(self, clazz, privates)
    return privates.manifest
end) -- function manifest

---------------------------------
-- Returns data file system (read only)
-- @function [parent=#xwos.modules.appman.instance] data
-- @param #xwos.modules.appman.instance self self
-- @return xwos.kernel.fsro#xwos.kernel.fsro readonly filesystem

.func("data",
---------------------------------
-- @function [parent=#intern] data
-- @param #xwos.modules.appman.instance self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @return xwos.kernel.fsro#xwos.kernel.fsro
function(self, clazz, privates)
    return _CMR.new('xwos.kernel.fsro', privates.kernel, privates.storage:wrap({}), privates.path)
end) -- function data

return nil