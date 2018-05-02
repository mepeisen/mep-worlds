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
-- @module xwos.modules.session
_CMR.class("xwos.modules.session")

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
-- @extends #xwos.modules.session 

.ctor(
------------------------
-- create new module session
-- @function [parent=#intern] __ctor
-- @param #xwos.modules.session self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
-- @param xwos.kernel#xwos.kernel kernel
function (self, clazz, privates, kernel)
    ---------------
    -- kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    ------------------
    -- the known sessions by id
    -- @field [parent=#privates] #map<#number,xwos.modules.session.instance#xwos.modules.session.instance> instances
    privates.instances = {}
    
    ------------------
    -- next session id being available for new sessions
    -- @field [parent=#privates] #number nextId
    privates.nextId = 1
    
    local d = kernel:readSecureData("core/session.dat")
    if d then
        d = unser(d)
        privates.nextId = d.nextId
        for k,v in pairs(d.psess) do
            local p = _CMR.new("xwos.modules.session.instance", privates.kernel, v.id)
            privates.instances[v.id] = p
            p:load()
        end -- for sessions
    end -- if secure data
end) -- ctor

------------------------
-- create new session
-- @function [parent=#xwos.modules.session] createSession
-- @param #xwos.modules.session self self
-- @return xwos.modules.session.instance#xwos.modules.session.instance

.func("createSession",
------------------------
-- create new profile with given name
-- @function [parent=#intern] createSession
-- @param #xwos.modules.session self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
-- @return xwos.modules.session.instance#xwos.modules.session.instance
function (self, clazz, privates, name)
    local res = _CMR.new("xwos.modules.session.instance", privates.kernel, privates.nextId)
    privates.instances[privates.nextId] = res
    privates.nextId = privates.nextId + 1
    return res
end) -- createSession

---------------------------------
-- Save security to secure kernel storage
-- @function [parent=#xwos.modules.session] save
-- @param #xwos.modules.session self self

.func("save",
---------------------------------
-- @function [parent=#intern] save
-- @param #xwos.modules.session self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    local d = { nextId = privates.nextId, psess = {} }
    for k, v in pairs(privates.instances) do
        if v:isPersistent() then
            tins(d.psess, {id = v:id()})
        end -- if persistent
    end -- for instances
    privates.kernel:writeSecureData("core/session.dat", ser(d))
end) -- function save

---------------------------------
-- Pre-Boot session module
-- @function [parent=#xwos.modules.session] preboot
-- @param #xwos.modules.session self self

.func("preboot",
---------------------------------
-- @function [parent=#intern] preboot
-- @param #xwos.modules.session self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
function(self, clazz, privates)
    privates.kernel:debug("preboot session")
end) -- function preboot

---------------------------------
-- Boot session module
-- @function [parent=#xwos.modules.session] boot
-- @param #xwos.modules.session self self

.func("boot",
---------------------------------
-- @function [parent=#intern] boot
-- @param #xwos.modules.session self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
function(self, clazz, privates)
    privates.kernel:debug("boot session")
    for k,v in pairs(privates.instances) do
        v:resume()
    end -- for instances
end) -- function boot

---------------------------------
-- Returns session by id
-- @function [parent=#xwos.modules.session] session
-- @param #xwos.modules.session self self
-- @param #number id
-- @return xwos.modules.session.instance#xwos.modules.session.instance session instance or nil if not found

.func("session",
---------------------------------
-- @function [parent=#intern] session
-- @param #xwos.modules.session self self
-- @param classmanager#clazz clazz user class
-- @param #privates privates
-- @param #number id
-- @return xwos.modules.session.instance#xwos.modules.session.instance
function(self, clazz, privates, id)
    return privates.instances[id]
end) -- function session

return nil