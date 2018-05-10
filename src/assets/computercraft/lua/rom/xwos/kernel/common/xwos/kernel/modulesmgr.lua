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

local pairs = pairs
local tcontains = table.contains

-- TODO support custom modules, installed by administrator users

--------------------------------
-- local process environments
-- @module xwos.kernel.modulesmgr
_CMR.class("xwos.kernel.modulesmgr")

------------------------
-- the object privates
-- @type privates

------------------------
-- the internal class
-- @type intern
-- @extends #xwos.kernel.modulesmgr 

.ctor(
------------------------
-- create new modules manager
-- @function [parent=#xwprocsintern] __ctor
-- @param #xwos.kernel.modulesmgr self self
-- @param classmanager#clazz clazz proc class
-- @param #privates privates
-- @param xwos.kernel#xwos.kernel kernel
function(self, clazz, privates, kernel)
    --------------------------------
    -- the kernel reference
    -- @field [parent=#privates] xwos.kernel#xwos.kernel kernel
    privates.kernel = kernel
    
    --------------------------------
    -- the ordering for loading kernel modules
    -- @field [parent=#privates] #list<#string> moduleOrder
    privates.moduleOrder = _CMR.require("moduleOrder")
    
    -------------------------------
    -- the module instances
    -- @type mminstances
    -- @field [parent=#xwos.kernel.modulesmgr] #mminstances instances
    self.instances = {}

    -------------------------------
    -- sandbox kernel module
    -- @field [parent=#mminstances] xwos.modules.sandbox#xwos.modules.sandbox sandbox
    
    -------------------------------
    -- security kernel module
    -- @field [parent=#mminstances] xwos.modules.security#xwos.modules.security security
    
    -------------------------------
    -- user kernel module
    -- @field [parent=#mminstances] xwos.modules.user#xwos.modules.user user
    
    -------------------------------
    -- session kernel module
    -- @field [parent=#mminstances] xwos.modules.session#xwos.modules.session session
    
    -------------------------------
    -- appmanager kernel module
    -- @field [parent=#mminstances] xwos.modules.appman#xwos.modules.appman appman
end) -- ctor

--------------------------------
-- Pre-boot the kernel modules in corresponding order
-- @function [parent=#xwos.kernel.modulesmgr] preboot
-- @param #xwos.kernel.modulesmgr self self

.func("preboot",
--------------------------------
-- @function [parent=#intern] preboot
-- @param #xwos.kernel.modulesmgr self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    for k,v in pairs(_CMR.findPackages("xwos.modules")) do
        privates.kernel:debug("load kernel module", v, "/ class", k)
        self.instances[v] = _CMR.new(k, privates.kernel)
    end -- for modules
  
    for i, v in pairs(privates.moduleOrder) do
        if self.instances[v] ~= nil then
            privates.kernel:debug("preboot kernel module",v)
            self.instances[v]:preboot()
        end -- if exists
    end -- for moduleOrder
    for i, v in pairs(self.instances) do
        if not tcontains(privates.moduleOrder, i) then
            privates.kernel:debug("preboot kernel module",i)
            v:preboot()
        end -- if not contains
    end -- for modules
end) -- function preboot

--------------------------------
-- boot the kernel modules in corresponding order
-- @function [parent=#xwos.kernel.modulesmgr] boot
-- @param #xwos.kernel.modulesmgr self self

.func("boot",
--------------------------------
-- @function [parent=#intern] boot
-- @param #xwos.kernel.modulesmgr self
-- @param classmanager#clazz clazz
-- @param #privates privates
function(self, clazz, privates)
    for i, v in pairs(privates.moduleOrder) do
        if self.instances[v] ~= nil then
            privates.kernel:debug("boot kernel module",v)
            self.instances[v]:boot()
        end -- if exists
    end -- for moduleOrder
    for i, v in pairs(self.instances) do
        if not tcontains(privates.moduleOrder, i) then
            privates.kernel:debug("boot kernel module",i)
            v:boot()
        end -- if not contains
    end -- for modules
end) -- function preboot

return nil
