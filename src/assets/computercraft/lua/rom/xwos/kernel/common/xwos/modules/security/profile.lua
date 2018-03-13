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
-- @module xwos.modules.security.profile
_CMR.class("xwos.modules.security.profile")

------------------------
-- the object privates
-- @type xwsecpprivates

------------------------
-- the internal class
-- @type xwsecpintern
-- @extends #xwos.modules.security.profile

.ctor(
------------------------
-- create new security profile
-- @function [parent=#xwsecpintern] __ctor
-- @param #xwos.modules.security.profile self self
-- @param classmanager#clazz clazz security profile class
-- @param #xwsecpprivates privates
-- @param #string name
function (self, clazz, privates, name)
    ---------------
    -- profile name
    -- @field [parent=#xwsecpprivates] #string name
    privates.name = name
end) -- ctor

---------------------------------
-- Returns profile name
-- @function [parent=#xwos.modules.security.profile] name
-- @param #xwos.modules.security.profile self self
-- @return #string profile name

.func("name",
---------------------------------
-- @function [parent=#xwsecpintern] name
-- @param #xwos.modules.security.profile self
-- @param classmanager#clazz clazz
-- @param #xwsecpprivates privates
-- @return string
function(self, clazz, privates)
    return privates.name
end) -- function name

-----------------------
-- Checks if access to given api method is granted
-- @function [parent=#xwos.modules.security.profile] checkApi
-- @param #xwos.modules.security.profile self self
-- @return #string api
-- @return #string method

.func("checkApi",
-----------------------
-- @function [parent=#xwsecpintern] checkApi
-- @param #xwos.modules.security.profile self
-- @param classmanager#clazz clazz
-- @param #xwsecpprivates privates
-- @return #string api
-- @return #string method
function(self, clazz, privates, api, method)
    return true -- TODO some meaningful implementation
end) -- function checkApi

-----------------------
-- Checks if access to given acl node is granted
-- @function [parent=#xwos.modules.security.profile] checkAccess
-- @param #xwos.modules.security.profile self self
-- @return #string aclKey

.func("checkAccess",
-----------------------
-- @function [parent=#xwsecpintern] checkAccess
-- @param #xwos.modules.security.profile self
-- @param classmanager#clazz clazz
-- @param #xwsecpprivates privates
-- @return #string aclKey
function(self, clazz, privates, aclKey)
    return true -- TODO some meaningful implementation
end) -- function checkApi

return nil