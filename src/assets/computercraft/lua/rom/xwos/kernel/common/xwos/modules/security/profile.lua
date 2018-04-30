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
local split = string.gmatch
local pairs = pairs

local function addacl(tgt, src)
    for n, val in pairs(src) do
        local cur = tgt
        for v in split(n, "[^%.]+") do
            if cur[v] == nil then
                cur[v] = {}
            end -- if cur
            cur = cur[v]
        end -- split
        cur.VAL = val
    end -- for src
end -- function addacl

local function checkacl(tgt, key, level)
    local cur = tgt
    for v in split(key, "[^%.]+") do
        local l = cur["*"]
        if l ~= nil and (l.VAL == level or (l.VAL == "g" and level == "a")) then
            return true
        end -- if access(*)
        
        if cur[v] == nil then
            return false
        end -- if cur
        
        cur = cur[v]
    end -- for aclKey
    return cur ~=nil and (cur.VAL == level or (cur.VAL == "g" and level == "a"))
end -- function checkacl

-----------------------
-- @module xwos.modules.security.profile
_CMR.class("xwos.modules.security.profile")

------------------------
-- the object privates
-- @type privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.modules.security.profile

.ctor(
------------------------
-- create new security profile
-- @function [parent=#intern] __ctor
-- @param #xwos.modules.security.profile self self
-- @param classmanager#clazz clazz security profile class
-- @param #privates privates
-- @param #string name
-- @param xwos.kernel#xwos.kernel kernel
-- @param #number id
function (self, clazz, privates, name, kernel, id)
    ---------------
    -- profile name
    -- @field [parent=#privates] #string name
    privates.name = name
    
    ---------------
    -- the kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    ---------------
    -- the unique profile id
    -- @field [parent=#privates] #number id
    privates.id = id
    
    ---------------
    -- the acl nodes
    -- @field [parent=#privates] #table acl
    privates.acl = { api = {}, func = {}}
    local d = privates.kernel:readSecureData("core/security/"..privates.id..".dat")
    if d then
        d = unser(d)
        privates.acl = d.acl
    end -- if data
end) -- ctor

---------------------------------
-- Returns profile name
-- @function [parent=#xwos.modules.security.profile] name
-- @param #xwos.modules.security.profile self self
-- @return #string profile name

.func("name",
---------------------------------
-- @function [parent=#intern] name
-- @param #xwos.modules.security.profile self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @return #string
function(self, clazz, privates)
    return privates.name
end) -- function name

---------------------------------
-- Returns profile id
-- @function [parent=#xwos.modules.security.profile] id
-- @param #xwos.modules.security.profile self self
-- @return #number profile id

.func("id",
---------------------------------
-- @function [parent=#intern] id
-- @param #xwos.modules.security.profile self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @return #number
function(self, clazz, privates)
    return privates.id
end) -- function id

-----------------------
-- Sets api access level
-- @function [parent=#xwos.modules.security.profile] setApi
-- @param #xwos.modules.security.profile self self
-- @param #string api
-- @param #string method
-- @param #string level one of "g" (grant) or "a" (access) or "d" (denied)

.func("setApi",
-----------------------
-- @function [parent=#intern] setApi
-- @param #xwos.modules.security.profile self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string api
-- @param #string method
-- @param #string level
function(self, clazz, privates, api, method, level)
    local data = {}
    local key = api
    if method ~= nil then
        key = api.."."..method
    end -- if method
    data[key] = level
    addacl(privates.acl.api, data)
    self:save()
end) -- function setApi

-----------------------
-- Checks if access to given api method is granted
-- @function [parent=#xwos.modules.security.profile] checkApi
-- @param #xwos.modules.security.profile self self
-- @param #string api
-- @param #string method
-- @return #boolean true for granting access and false for disallow access

.func("checkApi",
-----------------------
-- @function [parent=#intern] checkApi
-- @param #xwos.modules.security.profile self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string api
-- @param #string method
-- @return #boolean
function(self, clazz, privates, api, method)
    return self:checkApiLevel(api, method, "a")
end) -- function checkApi

-----------------------
-- Checks if access to given api method is granted
-- @function [parent=#xwos.modules.security.profile] checkApiLevel
-- @param #xwos.modules.security.profile self self
-- @param #string api
-- @param #string method
-- @param #string level
-- @return #boolean true for granting access and false for disallow access

.func("checkApiLevel",
-----------------------
-- @function [parent=#intern] checkApiLevel
-- @param #xwos.modules.security.profile self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string api
-- @param #string method
-- @param #string level
-- @return #boolean
function(self, clazz, privates, api, method, level)
    local key = api
    if method ~= nil then
        key = api.."."..method
    end -- if method
    return checkacl(privates.acl.api, key, level)
end) -- function checkApiLevel

-----------------------
-- Sets access level (removes any existing acl nodes)
-- @function [parent=#xwos.modules.security.profile] setAccess
-- @param #xwos.modules.security.profile self self
-- @param #string aclKey
-- @param #string level one of "g" (grant) or "a" (access) or "d" (denied)

.func("setAccess",
-----------------------
-- @function [parent=#intern] setAccess
-- @param #xwos.modules.security.profile self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string aclKey
-- @param #string level
function(self, clazz, privates, aclKey, level)
    local data = {}
    data[aclKey] = level
    addacl(privates.acl.func, data)
    self:save()
end) -- function setAccess

-----------------------
-- Checks if access to given acl node is granted
-- @function [parent=#xwos.modules.security.profile] checkAccess
-- @param #xwos.modules.security.profile self self
-- @param #string aclKey
-- @return #boolean true for granting access and false for disallow access

.func("checkAccess",
-----------------------
-- @function [parent=#intern] checkAccess
-- @param #xwos.modules.security.profile self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string aclKey
-- @return #boolean
function(self, clazz, privates, aclKey)
    return self:checkAccessLevel(aclKey, "a")
end) -- function checkAccess

-----------------------
-- Checks if access to given acl node is granted
-- @function [parent=#xwos.modules.security.profile] checkAccessLevel
-- @param #xwos.modules.security.profile self self
-- @param #string aclKey
-- @param #string level
-- @return #boolean true for granting access and false for disallow access

.func("checkAccessLevel",
-----------------------
-- @function [parent=#intern] checkAccessLevel
-- @param #xwos.modules.security.profile self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #string aclKey
-- @param #string level
-- @return #boolean
function(self, clazz, privates, aclKey, level)
    return checkacl(privates.acl.func, aclKey, level)
end) -- function checkAccessLevel

---------------------------------
-- Save profile to secure kernel storage
-- @function [parent=#xwos.modules.security.profile] save
-- @param #xwos.modules.security.profile self self

.func("save",
---------------------------------
-- @function [parent=#intern] save
-- @param #xwos.modules.security.profile self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    local data = {
        acl = privates.acl
    }
    privates.kernel:writeSecureData("core/security/"..privates.id..".dat", ser(data))
end) -- function save

return nil