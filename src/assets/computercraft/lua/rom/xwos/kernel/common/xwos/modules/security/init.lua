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