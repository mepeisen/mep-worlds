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
local M = {}

local kernel -- xwos.kernel#xwos.kernel

local function crProfile(name)
    -----------------------
    -- Security profile
    -- @type secprofile
    local R = {}
    
    -----------------------
    -- Returns the profile name
    -- @function [parent=#secprofile] name
    -- @return #string profile name
    R.name = function()
        return name
    end -- function name
    
    -----------------------
    -- Checks if access to given api method is granted
    -- @function [parent=#secprofile] checkApi
    -- @return #string api
    -- @return #string method
    R.checkApi = function(api, method)
        return true -- TODO some meaningful implementation
    end -- function checkApi
    
    -----------------------
    -- Checks if access to given acl node is granted
    -- @function [parent=#secprofile] checkAccess
    -- @return #string aclKey
    R.checkAccess = function(aclKey)
        return true -- TODO some meaningful implementation
    end -- function checkAccess
    return R
end -- function crProfile

local profiles = {
    root = crProfile("root"),
    admin = crProfile("admin"),
    user = crProfile("user"),
    guest = crProfile("guest")
}

---------------------------------
-- @function [parent=#xwos.modules.security] preboot
-- @param xwos.kernel#xwos.kernel k
M.preboot = function(k)
    k.debug("preboot security")
    kernel = k
end -- function preboot

---------------------------------
-- @function [parent=#xwos.modules.security] boot
-- @param xwos.kernel#xwos.kernel k
M.boot = function(k)
    k.debug("boot security")
end -- function boot

---------------------------------
-- returns a security profile with given name
-- @function [parent=#xwos.modules.security] profile
-- @param #string name
-- @return #secprofile
M.profile = function(name)
    return profiles[name]
end -- function boot

---------------------------------
-- Creates a new security profile with given name
-- @function [parent=#xwos.modules.security] profile
-- @param #string name
-- @return #secprofile
M.createProfile = function(name)
    -- TODO some meaningful implementation
    local res = profiles[name]
    if res == nil then
        res = crProfile(name)
        profiles[name] = res
    end -- if profile
    return res
end -- function createProfile

return M