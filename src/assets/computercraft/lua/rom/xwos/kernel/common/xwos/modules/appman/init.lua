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

-----------------------
-- @module xwos.modules.appman
_CMR.class("xwos.modules.appman")

local ser = textutils.serialize
local unser = textutils.unserialize
local pairs = pairs
local tins = table.insert

------------------------
-- the object privates
-- @type privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.modules.appman 

.ctor(
------------------------
-- create new module session
-- @function [parent=#intern] __ctor
-- @param #xwos.modules.appman self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
-- @param xwos.kernel#xwos.kernel kernel
function (self, clazz, privates, kernel)
    ---------------
    -- kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    ------------------
    -- the application storages
    -- @field [parent=#privates] #map<#number,xwos.modules.appman.storage#xwos.modules.appman.storage> storages
    privates.storages = {}
    
    ------------------
    -- next storage id being available for new storages
    -- @field [parent=#privates] #number nextStorageId
    privates.nextStorageId = 1
    
    local d = kernel:readSecureData("core/appman.dat")
    if d then
        d = unser(d)
        privates.nextStorageId = d.nextStorageId
        for k,v in pairs(d.storages) do
            local p = _CMR.new("xwos.modules.appman.storage", privates.kernel, v.id)
            privates.storages[v.id] = p
            p:load()
        end -- for storages
    else -- if secure data
        -- TODO pre init default storages
    end -- if secure data
end) -- ctor

------------------------
-- create new filesystem storage for given application folder
-- @function [parent=#xwos.modules.appman] createFsStorage
-- @param #xwos.modules.appman self self
-- @param #string folder
-- @return xwos.modules.appman.storage#xwos.modules.appman.storage

.func("createFsStorage",
------------------------
-- create new storage for given application folder
-- @function [parent=#intern] createStorage
-- @param #xwos.modules.appman self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
-- @param #string folder
-- @return xwos.modules.appman.storage#xwos.modules.appman.storage
function (self, clazz, privates, folder)
    local res = _CMR.new("xwos.modules.appman.fsstorage", privates.kernel, privates.nextStorageId) -- xwos.modules.appman.fsstorage#xwos.modules.appman.fsstorage
    res:setPath(folder)
    privates.storages[privates.nextStorageId] = res
    privates.nextStorageId = privates.nextStorageId + 1
    return res
end) -- createFsStorage

---------------------------------
-- Save applications to secure kernel storage
-- @function [parent=#xwos.modules.appman] save
-- @param #xwos.modules.appman self self

.func("save",
---------------------------------
-- @function [parent=#intern] save
-- @param #xwos.modules.appman self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    local d = { nextStorageId = privates.nextStorageId, storages = {} }
    for k, v in pairs(privates.storages) do
        tins(d.storages, {id = v:id()})
    end -- for instances
    privates.kernel:writeSecureData("core/appman.dat", ser(d))
end) -- function save

---------------------------------
-- Pre-Boot appman module
-- @function [parent=#xwos.modules.appman] preboot
-- @param #xwos.modules.appman self self

.func("preboot",
---------------------------------
-- @function [parent=#intern] preboot
-- @param #xwos.modules.appman self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
function(self, clazz, privates)
    privates.kernel:debug("preboot appman")
end) -- function preboot

---------------------------------
-- Boot appman module
-- @function [parent=#xwos.modules.appman] boot
-- @param #xwos.modules.appman self self

.func("boot",
---------------------------------
-- @function [parent=#intern] boot
-- @param #xwos.modules.appman self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
function(self, clazz, privates)
    privates.kernel:debug("boot appman")
    for k,v in pairs(privates.storages) do
        v:init()
    end -- for storages
end) -- function boot

return nil