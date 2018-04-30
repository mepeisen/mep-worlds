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
local tins = table.insert

-----------------------
-- @module xwos.modules.security
_CMR.class("xwos.modules.security")

------------------------
-- the object privates
-- @type privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.modules.security 

.ctor(
------------------------
-- create new module security
-- @function [parent=#intern] __ctor
-- @param #xwos.modules.security self self
-- @param classmanager#clazz clazz security class
-- @param #privates privates
-- @param xwos.kernel#xwos.kernel kernel
function (self, clazz, privates, kernel)
    ---------------
    -- kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    ------------------
    -- the known profiles by name
    -- @field [parent=#privates] #map<#string,xwos.modules.security.profile#xwos.modules.security.profile> profiles
    privates.profiles = {}
    
    ------------------
    -- next id being available for profiles
    -- @field [parent=#privates] #number nextId
    privates.nextId = 1
    
    local d = kernel:readSecureData("core/security.dat")
    if d then
        d = unser(d)
        privates.nextId = d.nextId
        for k,v in pairs(d.profiles) do
            local p = _CMR.new("xwos.modules.security.profile", v.name, privates.kernel, v.id)
            privates.profiles[v.name] = p
            p:load()
        end -- for profiles
    else -- if secure data
        local root = privates:createProfile("root")
        root:setApi("*", nil, "g")
        root:setAccess("*", "g")
        local admin = privates:createProfile("admin")
        -- TODO useful grant rights
        root:setApi("*", nil, "a")
        root:setAccess("*", "a")
        local user = privates:createProfile("user")
        -- TODO useful user rights
        local guest = privates:createProfile("guest")
        -- TODO useful guest rights
    end -- if secure data
end) -- ctor

------------------------
-- create new profile with given name
-- @function [parent=#privates] createProfile
-- @param #xwos.modules.security self self
-- @param #string name
-- @return xwos.modules.security.profile#xwos.modules.security.profile

.pfunc("createProfile",
------------------------
-- create new profile with given name
-- @function [parent=#xwsecpintern] createProfile
-- @param #xwos.modules.security self self
-- @param classmanager#clazz clazz security class
-- @param #privates privates
-- @param #string name
-- @return xwos.modules.security.profile#xwos.modules.security.profile
function (self, clazz, privates, name)
    local res = _CMR.new("xwos.modules.security.profile", name, privates.kernel, privates.nextId)
    privates.profiles[name] = res
    privates.nextId = privates.nextId + 1
    self:save()
    res:save()
    return res
end) -- createProfile

---------------------------------
-- Save security to secure kernel storage
-- @function [parent=#xwos.modules.security] save
-- @param #xwos.modules.security self self

.func("save",
---------------------------------
-- @function [parent=#intern] save
-- @param #xwos.modules.security self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    local d = { nextId = privates.nextId, profiles = {} }
    for k, v in pairs(privates.profiles) do
        tins(d.profiles, {id = v:id(), name = v:name()})
    end -- for profiles
    privates.kernel:writeSecureData("core/security.dat", ser(d))
end) -- function save

---------------------------------
-- Pre-Boot sandbox module
-- @function [parent=#xwos.modules.security] preboot
-- @param #xwos.modules.security self self

.func("preboot",
---------------------------------
-- @function [parent=#intern] preboot
-- @param #xwos.modules.security self self
-- @param classmanager#clazz clazz security class
-- @param #privates privates
function(self, clazz, privates)
    privates.kernel:debug("preboot security")
end) -- function preboot

---------------------------------
-- Boot sandbox module
-- @function [parent=#xwos.modules.security] boot
-- @param #xwos.modules.security self self

.func("boot",
---------------------------------
-- @function [parent=#intern] boot
-- @param #xwos.modules.security self self
-- @param classmanager#clazz clazz security class
-- @param #privates privates
function(self, clazz, privates)
    privates.kernel:debug("boot security")
end) -- function boot

---------------------------------
-- Returns profile by name
-- @function [parent=#xwos.modules.security] profile
-- @param #xwos.modules.security self self
-- @param #string name
-- @return xwos.modules.security.profile#xwos.modules.security.profile profile instance or nil if not found

.func("profile",
---------------------------------
-- @function [parent=#intern] profile
-- @param #xwos.modules.security self self
-- @param classmanager#clazz clazz security class
-- @param #privates privates
-- @param #string name
-- @return xwos.modules.security.profile#xwos.modules.security.profile
function(self, clazz, privates, name)
    return privates.profiles[name]
end) -- function profile

---------------------------------
-- Creates profile if not exists; returns profile if exists
-- @function [parent=#xwos.modules.security] createProfile
-- @param #xwos.modules.security self self
-- @param #string name
-- @return xwos.modules.security.profile#xwos.modules.security.profile profile instance

.func("createProfile",
---------------------------------
-- @function [parent=#intern] createProfile
-- @param #xwos.modules.security self self
-- @param classmanager#clazz clazz security class
-- @param #privates privates
-- @param #string name
-- @return xwos.modules.security.profile#xwos.modules.security.profile
function(self, clazz, privates, name)
    local res = privates.profiles[name]
    if res == nil then
        res = privates:createProfile(name)
    end -- if not res
    return res
end) -- function createProfile

return nil