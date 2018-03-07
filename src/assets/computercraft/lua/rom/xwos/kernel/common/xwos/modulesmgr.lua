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

local kernel -- xwos.kernel#xwos.kernel
local moduleOrder = {}

--------------------------------
-- local kernel modules
-- @type xwos.modulesmgr
local M = {}

-------------------------------
-- the module instances
-- @type xwos.modulesmgr.instances
-- @field [parent=#xwos.modulesmgr] #xwos.modulesmgr.instances instances
M.instances = {}

-------------------------------
-- sandbox kernel module
-- @field [parent=#xwos.modulesmgr.instances] xwos.modulesmgr.sandbox#xwos.modulesmgr.sandbox sandbox

-------------------------------
-- security kernel module
-- @field [parent=#xwos.modulesmgr.instances] xwos.modulesmgr.security#xwos.modulesmgr.security security

--------------------------------
-- @function [parent=#xwos.modulesmgr] preboot
-- @param xwos.kernel#xwos.kernel k the kernel
M.preboot = function(k)
    kernel = k
    -- load settings with kernel module boot order
    moduleOrder = kernel.require("moduleOrder")
    -- helper to load kernel modules from given directory
    local loadKernelModules = function(dir)
        local path = dir .. "/xwos/modules"
        kernel.debug("loading kernel modules from " .. path)
        if kernel.oldGlob.fs.isDir(path) then
            for i, v in kernel.oldGlob.pairs(kernel.oldGlob.fs.list(path)) do
                print("installing module "..v.."...")
                kernel.debug("loading kernel module from " .. path .. "/" .. v)
                M.instances[v] = kernel.oldGlob.require(path .. "/" .. v)
            end -- for list
        end -- if isdir
    end --  function loadKernelModules
  
    -- load kernel modules
    for k, v in kernel.oldGlob.pairs(kernel.kernelpaths) do
        loadKernelModules(v)
    end -- for kernelpaths

    for i, v in pairs(moduleOrder) do
        if M.instances[v] ~= nil then
            kernel.debug("preboot kernel module",v)
            M.instances[v].preboot(kernel)
        end -- if exists
    end -- for moduleOrder
    for i, v in pairs(M.instances) do
        if not table.contains(moduleOrder, i) then
            kernel.debug("preboot kernel module",v)
            v.preboot(kernel)
        end -- if not contains
    end -- for modules
end -- function preboot

--------------------------------
-- @function [parent=#xwos.modulesmgr] boot
-- @param xwos.kernel#xwos.kernel k the kernel
M.boot = function(k)
    for i, v in pairs(moduleOrder) do
        if M.instances[v] ~= nil then
            kernel.debug("boot kernel module",v)
            M.instances[v].boot(kernel)
        end -- if exists
    end -- for moduleOrder
    for i, v in pairs(M.instances) do
        if not table.contains(moduleOrder, i) then
            kernel.debug("boot kernel module",v)
            v.boot(kernel)
        end -- if not contains
    end -- for modules
end -- function preboot

return M
