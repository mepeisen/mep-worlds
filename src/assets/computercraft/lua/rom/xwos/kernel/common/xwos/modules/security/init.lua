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
-- @module xwos.modules.security
_CMR.class("xwos.modules.security")

------------------------
-- the object privates
-- @type xwsecprivates

------------------------
-- the internal class
-- @type xwsecintern
-- @extends #xwos.modules.security 

.ctor(
------------------------
-- create new module security
-- @function [parent=#xwsecintern] __ctor
-- @param #xwos.modules.security self self
-- @param classmanager#clazz clazz security class
-- @param #xwsecprivates privates
-- @param xwos.kernel#xwos.kernel kernel
function (self, clazz, privates, kernel)
    ---------------
    -- kernel reference
    -- @field [parent=#xwsecprivates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    ------------------
    -- the known profiles by name
    -- @field [parent=#xwsecprivates] #map<#string,xwos.modules.security.profile#xwos.modules.security.profile> profiles
    privates.profiles = {}
    privates:createProfile("root")
    privates:createProfile("admin")
    privates:createProfile("user")
    privates:createProfile("guest")
end) -- ctor

------------------------
-- create new profile with given name
-- @function [parent=#xwsecprivates] createProfile
-- @param #xwos.modules.security self self
-- @param #string name
-- @return xwos.modules.security.profile#xwos.modules.security.profile

.pfunc("createProfile",
------------------------
-- create new profile with given name
-- @function [parent=#xwsecpintern] createProfile
-- @param #xwos.modules.security self self
-- @param classmanager#clazz clazz security class
-- @param #xwsecprivates privates
-- @param #string name
-- @return xwos.modules.security.profile#xwos.modules.security.profile
function (self, clazz, privates, name)
    local res = _CMR.new("xwos.modules.security.profile", name)
    privates.profiles[name] = res
    return res
end) -- createProfile

---------------------------------
-- Pre-Boot sandbox module
-- @function [parent=#xwos.modules.security] preboot
-- @param #xwos.modules.security self self

.func("preboot",
---------------------------------
-- @function [parent=#xwsecintern] preboot
-- @param #xwos.modules.security self self
-- @param classmanager#clazz clazz security class
-- @param #xwsecprivates privates
function(self, clazz, privates)
    privates.kernel:debug("preboot security")
end) -- function preboot

---------------------------------
-- Boot sandbox module
-- @function [parent=#xwos.modules.security] boot
-- @param #xwos.modules.security self self

.func("boot",
---------------------------------
-- @function [parent=#xwsecintern] boot
-- @param #xwos.modules.security self self
-- @param classmanager#clazz clazz security class
-- @param #xwsecprivates privates
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
-- @function [parent=#xwsecintern] profile
-- @param #xwos.modules.security self self
-- @param classmanager#clazz clazz security class
-- @param #xwsecprivates privates
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
-- @function [parent=#xwsecintern] createProfile
-- @param #xwos.modules.security self self
-- @param classmanager#clazz clazz security class
-- @param #xwsecprivates privates
-- @param #string name
-- @return xwos.modules.security.profile#xwos.modules.security.profile
function(self, clazz, privates, name)
    -- TODO some meaningful implementation
    local res = privates.profiles[name]
    if res == nil then
        res = privates:createProfile(name)
    end -- if not res
    return res
end) -- function createProfile

return nil