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

-----------------------
-- @module xwos.modules.user.profile
_CMR.class("xwos.modules.user.profile")

------------------------
-- the object privates
-- @type xwuserpprivates

------------------------
-- the internal class
-- @type xwuserpintern
-- @extends #xwos.modules.user.profile

.ctor(
------------------------
-- create new user profile
-- @function [parent=#xwuserpintern] __ctor
-- @param #xwos.modules.user.profile self self
-- @param classmanager#clazz clazz user profile class
-- @param #xwuserpprivates privates
-- @param #string name
-- @param #number id
-- @param xwos.kernel#xwos.kernel kernel
function (self, clazz, privates, name, kernel, id)
    ---------------
    -- profile name
    -- @field [parent=#xwuserpprivates] #string name
    privates.name = name
    
    ---------------
    -- the kernel reference
    -- @field [parent=#xwuserpprivates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    ---------------
    -- the unique profile id
    -- @field [parent=#xwuserpprivates] #number id
    privates.id = id
    
    ---------------
    -- user password
    -- @field [parent=#xwuserpprivates] #string pass
    
    ---------------
    -- active flag
    -- @field [parent=#xwuserpprivates] #boolean active
    
    ---------------
    -- the security profiles
    -- @field [parent=#xwuserpprivates] #table secp
    privates.secp = {}
    local d = privates.kernel:readSecureData("core/user/"..privates.id..".dat")
    if d then
        d = unser(d)
        privates.secp = d.secp
        privates.pass = d.pass
        privates.active = d.active
    end -- if data
end) -- ctor

---------------------------------
-- Adds a new security profile to user
-- @function [parent=#xwos.modules.user.profile] addAcl
-- @param #xwos.modules.user.profile self self
-- @param #string profile security profile name

.func("addAcl",
---------------------------------
-- @function [parent=#xwuserpintern] addAcl
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
-- @param #string profile
function(self, clazz, privates, profile)
    privates.secp[profile] = true
    self:save()
end) -- function addAcl

---------------------------------
-- Removes an existing security profile from user
-- @function [parent=#xwos.modules.user.profile] removeAcl
-- @param #xwos.modules.user.profile self self
-- @param #string profile security profile name

.func("removeAcl",
---------------------------------
-- @function [parent=#xwuserpintern] removeAcl
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
-- @param #string profile
function(self, clazz, privates, profile)
    privates.secp[profile] = nil
    self:save()
end) -- function addAcl

---------------------------------
-- Returns profile name
-- @function [parent=#xwos.modules.user.profile] name
-- @param #xwos.modules.user.profile self self
-- @return #string profile name

.func("name",
---------------------------------
-- @function [parent=#xwuserpintern] name
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
-- @return #string
function(self, clazz, privates)
    return privates.name
end) -- function name

---------------------------------
-- Returns profile id
-- @function [parent=#xwos.modules.user.profile] id
-- @param #xwos.modules.user.profile self self
-- @return #number profile id

.func("id",
---------------------------------
-- @function [parent=#xwuserpintern] id
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
-- @return #number
function(self, clazz, privates)
    return privates.id
end) -- function id

-----------------------
-- Checks if access to given api method is granted
-- @function [parent=#xwos.modules.user.profile] checkApi
-- @param #xwos.modules.user.profile self self
-- @param #string api
-- @param #string method
-- @return #boolean true for granting access and false for disallow access

.func("checkApi",
-----------------------
-- @function [parent=#xwuserpintern] checkApi
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
-- @param #string api
-- @param #string method
-- @return #boolean
function(self, clazz, privates, api, method)
    for v in pairs(privates.secp) do
        local p = privates.kernel.modules.instances.security:profile(v)
        if p ~= nil and p:checkApi(api, method) then
            return true
        end -- if access
    end -- for secp
    return false
end) -- function checkApi

-----------------------
-- Checks if access to given api method is granted
-- @function [parent=#xwos.modules.user.profile] checkApiLevel
-- @param #xwos.modules.user.profile self self
-- @param #string api
-- @param #string method
-- @param #string level
-- @return #boolean true for granting access and false for disallow access

.func("checkApiLevel",
-----------------------
-- @function [parent=#xwuserpintern] checkApiLevel
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
-- @param #string api
-- @param #string method
-- @param #string level
-- @return #boolean
function(self, clazz, privates, api, method, level)
    for v in pairs(privates.secp) do
        local p = privates.kernel.modules.instances.security:profile(v)
        if p ~= nil and p:checkApiLevel(api, method, level) then
            return true
        end -- if access
    end -- for secp
    return false
end) -- function checkApiLevel

-----------------------
-- Checks if access to given acl node is granted
-- @function [parent=#xwos.modules.user.profile] checkAccess
-- @param #xwos.modules.user.profile self self
-- @param #string aclKey
-- @return #boolean true for granting access and false for disallow access

.func("checkAccess",
-----------------------
-- @function [parent=#xwuserpintern] checkAccess
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
-- @param #string aclKey
-- @return #boolean
function(self, clazz, privates, aclKey)
    for v in pairs(privates.secp) do
        local p = privates.kernel.modules.instances.security:profile(v)
        if p ~= nil and p:checkAccess(aclKey) then
            return true
        end -- if access
    end -- for secp
    return false
end) -- function checkAccess

-----------------------
-- Checks if access to given acl node is granted
-- @function [parent=#xwos.modules.user.profile] checkAccessLevel
-- @param #xwos.modules.user.profile self self
-- @param #string aclKey
-- @param #string level
-- @return #boolean true for granting access and false for disallow access

.func("checkAccessLevel",
-----------------------
-- @function [parent=#xwuserpintern] checkAccessLevel
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
-- @param #string aclKey
-- @param #string level
-- @return #boolean
function(self, clazz, privates, aclKey, level)
    for v in pairs(privates.secp) do
        local p = privates.kernel.modules.instances.security:profile(v)
        if p ~= nil and p:checkAccessLevel(aclKey, level) then
            return true
        end -- if access
    end -- for secp
    return false
end) -- function checkAccessLevel

---------------------------------
-- Save profile to secure kernel storage
-- @function [parent=#xwos.modules.user.profile] save
-- @param #xwos.modules.user.profile self self

.func("save",
---------------------------------
-- @function [parent=#xwuserpintern] save
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
function(self, clazz, privates)
    local data = {
        secp = privates.secp,
        pass = privates.pass,
        active = privates.active
    }
    privates.kernel:writeSecureData("core/user/"..privates.id..".dat", ser(data))
end) -- function save

-----------------------
-- Sets active flag
-- @function [parent=#xwos.modules.user.profile] setActive
-- @param #xwos.modules.user.profile self self
-- @param #boolean flag true to allow logins; false to disallow logins

.func("setActive",
---------------------------------
-- @function [parent=#xwuserpintern] setActive
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
-- @param #boolean flag
function(self, clazz, privates, flag)
    privates.active = flag
    self:save()
end) -- function setActive

-----------------------
-- Checks active flag
-- @function [parent=#xwos.modules.user.profile] isActive
-- @param #xwos.modules.user.profile self self
-- @return #boolean true if logins are allowed; false if user may not login

.func("isActive",
---------------------------------
-- @function [parent=#xwuserpintern] isActive
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
-- @return #boolean
function(self, clazz, privates)
    return privates.active and privates.active or false
end) -- function isActive

-----------------------
-- Sets a new password
-- @function [parent=#xwos.modules.user.profile] setPassword
-- @param #xwos.modules.user.profile self self
-- @param #string newPass the new password to set

.func("setPassword",
---------------------------------
-- @function [parent=#xwuserpintern] setPassword
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
-- @param #string newPass
function(self, clazz, privates, newPass)
    -- TODO password encryption
    privates.pass = newPass
    self:save()
end) -- function setPassword

-----------------------
-- Checks if password match
-- @function [parent=#xwos.modules.user.profile] checkPassword
-- @param #xwos.modules.user.profile self self
-- @param #string pass the password to check
-- @return #boolean true if password matches

.func("checkPassword",
---------------------------------
-- @function [parent=#xwuserpintern] checkPassword
-- @param #xwos.modules.user.profile self
-- @param classmanager#clazz clazz
-- @param #xwuserpprivates privates
-- @param #string pass
-- @return #boolean true if password matches
function(self, clazz, privates, pass)
    return privates.pass == pass
end) -- function checkPassword

return nil