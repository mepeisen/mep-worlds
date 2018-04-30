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
-- @module xwos.modules.user
_CMR.class("xwos.modules.user")

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
-- @extends #xwos.modules.user 

.ctor(
------------------------
-- create new module user
-- @function [parent=#intern] __ctor
-- @param #xwos.modules.user self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
-- @param xwos.kernel#xwos.kernel kernel
function (self, clazz, privates, kernel)
    ---------------
    -- kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    ------------------
    -- the known users by name
    -- @field [parent=#privates] #map<#string,xwos.modules.user.profile#xwos.modules.user.profile> profiles
    privates.profiles = {}
    
    ------------------
    -- next id being available for users
    -- @field [parent=#privates] #number nextId
    privates.nextId = 1
    
    local d = kernel:readSecureData("core/user.dat")
    if d then
        d = unser(d)
        privates.nextId = d.nextId
        for k,v in pairs(d.profiles) do
            local p = _CMR.new("xwos.modules.user.profile", v.name, privates.kernel, v.id)
            privates.profiles[v.name] = p
            p:load()
        end -- for profiles
    end -- if secure data
end) -- ctor

------------------------
-- create new profile with given name
-- @function [parent=#privates] createProfile
-- @param #xwos.modules.user self self
-- @param #string name
-- @return xwos.modules.user.profile#xwos.modules.user.profile

.pfunc("createProfile",
------------------------
-- create new profile with given name
-- @function [parent=#xwsecpintern] createProfile
-- @param #xwos.modules.user self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
-- @param #string name
-- @return xwos.modules.user.profile#xwos.modules.user.profile
function (self, clazz, privates, name)
    local res = _CMR.new("xwos.modules.user.profile", name, privates.kernel, privates.nextId)
    privates.profiles[name] = res
    privates.nextId = privates.nextId + 1
    self:save()
    res:save()
    return res
end) -- createProfile

---------------------------------
-- Save security to secure kernel storage
-- @function [parent=#xwos.modules.user] save
-- @param #xwos.modules.user self self

.func("save",
---------------------------------
-- @function [parent=#intern] save
-- @param #xwos.modules.user self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    local d = { nextId = privates.nextId, profiles = {} }
    for k, v in pairs(privates.profiles) do
        tins(d.profiles, {id = v:id(), name = v:name()})
    end -- for profiles
    privates.kernel:writeSecureData("core/user.dat", ser(d))
end) -- function save

---------------------------------
-- Pre-Boot user module
-- @function [parent=#xwos.modules.user] preboot
-- @param #xwos.modules.user self self

.func("preboot",
---------------------------------
-- @function [parent=#intern] preboot
-- @param #xwos.modules.user self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
function(self, clazz, privates)
    privates.kernel:debug("preboot user")
end) -- function preboot

---------------------------------
-- Boot user module
-- @function [parent=#xwos.modules.user] boot
-- @param #xwos.modules.user self self

.func("boot",
---------------------------------
-- @function [parent=#intern] boot
-- @param #xwos.modules.user self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
function(self, clazz, privates)
    privates.kernel:debug("boot user")
end) -- function boot

---------------------------------
-- Returns profile by name
-- @function [parent=#xwos.modules.user] profile
-- @param #xwos.modules.user self self
-- @param #string name
-- @return xwos.modules.user.profile#xwos.modules.user.profile profile instance or nil if not found

.func("profile",
---------------------------------
-- @function [parent=#intern] profile
-- @param #xwos.modules.user self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
-- @param #string name
-- @return xwos.modules.user.profile#xwos.modules.user.profile
function(self, clazz, privates, name)
    return privates.profiles[name]
end) -- function profile

---------------------------------
-- Creates profile if not exists; returns profile if exists
-- @function [parent=#xwos.modules.user] createProfile
-- @param #xwos.modules.user self self
-- @param #string name
-- @return xwos.modules.user.profile#xwos.modules.user.profile profile instance

.func("createProfile",
---------------------------------
-- @function [parent=#intern] createProfile
-- @param #xwos.modules.user self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
-- @param #string name
-- @return xwos.modules.user.profile#xwos.modules.user.profile
function(self, clazz, privates, name)
    local res = privates.profiles[name]
    if res == nil then
        res = privates:createProfile(name)
    end -- if not res
    return res
end) -- function createProfile

return nil