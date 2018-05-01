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
-- @module xwos.modules.session.instance
_CMR.class("xwos.modules.session.instance")

------------------------
-- the object privates
-- @type privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.modules.session.instance

.ctor(
------------------------
-- create new session
-- @function [parent=#intern] __ctor
-- @param #xwos.modules.session.instance self self
-- @param classmanager#clazz clazz session instance class
-- @param #privates privates
-- @param xwos.kernel#xwos.kernel kernel
-- @param #number id
function (self, clazz, privates, kernel, id)
    ---------------
    -- the kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    ---------------
    -- the unique session id
    -- @field [parent=#privates] #number id
    privates.id = id
    
    ---------------
    -- the associated user
    -- @field [parent=#privates] xwos.modules.user.profile#xwos.modules.user.profile user
    
    ---------------
    -- the username of this session
    -- @field [parent=#privates] #string username
    
    ---------------
    -- the persistent flag
    -- @field [parent=#privates] #boolean persistent
end) -- ctor

---------------------------------
-- Loads session data from secure storage
-- @function [parent=#xwos.modules.session.instance] load
-- @param #xwos.modules.session.instance self self

.func("load",
---------------------------------
-- @function [parent=#intern] load
-- @param #xwos.modules.session.instance self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    local d = privates.kernel:readSecureData("core/session/"..privates.id..".dat")
    if d then
        d = unser(d)
        privates.username = d.username
        privates.user = privates.kernel.modules.instances.user:profile(d.username)
    end -- if data
    privates.persistent = true
end) -- function load

---------------------------------
-- Sets the user name owning this session
-- @function [parent=#xwos.modules.session.instance] setUser
-- @param #xwos.modules.session.instance self self
-- @param xwos.modules.user.profile#xwos.modules.user.profile user

.func("setUser",
---------------------------------
-- @function [parent=#intern] setUser
-- @param #xwos.modules.session.instance self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param xwos.modules.user.profile#xwos.modules.user.profile user
function(self, clazz, privates, user)
    privates.user = user
    privates.username = user:name()
    if self:isPersistent() then
        self:save()
    end -- if persistent
end) -- function setUser

---------------------------------
-- Returns the current user
-- @function [parent=#xwos.modules.session.instance] user
-- @param #xwos.modules.session.instance self self
-- @return xwos.modules.user.profile#xwos.modules.user.profile user or nil if user is not known

.func("user",
---------------------------------
-- @function [parent=#intern] user
-- @param #xwos.modules.session.instance self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @return xwos.modules.user.profile#xwos.modules.user.profile
function(self, clazz, privates, user)
    return privates.user
end) -- function user

---------------------------------
-- Checks if this session is a persistent session
-- @function [parent=#xwos.modules.session.instance] isPersistent
-- @param #xwos.modules.session.instance self self
-- @return #boolean true for persistent sessions

.func("isPersistent",
---------------------------------
-- @function [parent=#intern] isPersistent
-- @param #xwos.modules.session.instance self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @return #boolean
function(self, clazz, privates)
    return privates.persistent
end) -- function isPersistent

---------------------------------
-- Sets persistence flag
-- @function [parent=#xwos.modules.session.instance] setPersistent
-- @param #xwos.modules.session.instance self self
-- @param #boolean flag true for persistent sessions

.func("setPersistent",
---------------------------------
-- @function [parent=#intern] setPersistent
-- @param #xwos.modules.session.instance self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @param #boolean flag
function(self, clazz, privates, flag)
    privates.persistent = flag
    privates.kernel.modules.instances.session:save()
end) -- function setPersistent

---------------------------------
-- Resume a persistent session
-- @function [parent=#xwos.modules.session.instance] resume
-- @param #xwos.modules.session.instance self self

.func("resume",
---------------------------------
-- @function [parent=#intern] resume
-- @param #xwos.modules.session.instance self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    -- TODO
end) -- function resume

---------------------------------
-- Returns session id
-- @function [parent=#xwos.modules.session.instance] id
-- @param #xwos.modules.session.instance self self
-- @return #number session id

.func("id",
---------------------------------
-- @function [parent=#intern] id
-- @param #xwos.modules.session.instance self
-- @param classmanager#clazz clazz
-- @param #privates privates
-- @return #number
function(self, clazz, privates)
    return privates.id
end) -- function id

---------------------------------
-- Save session to secure kernel storage
-- @function [parent=#xwos.modules.session.instance] save
-- @param #xwos.modules.session.instance self self

.func("save",
---------------------------------
-- @function [parent=#intern] save
-- @param #xwos.modules.session.instance self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    local data = {
        username = privates.username
    }
    privates.kernel:writeSecureData("core/session/"..privates.id..".dat", ser(data))
end) -- function save

return nil