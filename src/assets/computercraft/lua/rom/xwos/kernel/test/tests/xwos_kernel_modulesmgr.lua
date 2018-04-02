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

local cmf = boot.krequire('classmanager')

TestXwosKernelModulemgr = {}

function TestXwosKernelModulemgr:setUp()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    table.contains = function(haystack, needle)
        for k, v in pairs(haystack) do
            if (v == needle) then
                return true
            end -- if equals
        end -- for haystack
        return false
    end -- function table.contains
    cmr.addcp(boot.kernelRoot().."/kernel/test/tests/modulesmgr")
    -- load modulesmgr and remove from cp; so that it does not see the regular kernel modules
    cmr.addcp(boot.kernelRoot().."/kernel/common")
    cmr.load("xwos.kernel.modulesmgr")
    cmr.removecp(boot.kernelRoot().."/kernel/common")
    -- kernelmock
    cmr.class('kernelmock')
        .ctor(function(self, clazz, privates)
            self.dmsg = {}
        end)
        .func('debug', function(self, clazz, privates, ...)
            table.insert(self.dmsg, {...})
        end)
end -- setUp

function TestXwosKernelModulemgr:tearDown()
    _CMR = nil
    table.contains = nil
end -- tearDown

-- testing no instances before preBoot
function TestXwosKernelModulemgr:testEmpty()
    local kernel = _CMR.new('kernelmock')
    local mm = _CMR.new('xwos.kernel.modulesmgr', kernel) -- xwos.kernel.modulesmgr#xwos.kernel.modulesmgr
    lu.assertEquals(mm.instances, {})
end -- testEmpty

-- testing the ordering by preboot
function TestXwosKernelModulemgr:testOrder()
    local kernel = _CMR.new('kernelmock')
    local mm = _CMR.new('xwos.kernel.modulesmgr', kernel) -- xwos.kernel.modulesmgr#xwos.kernel.modulesmgr
    mm:preboot()
    mm:boot()
    -- loading in any order
    local loading = {kernel.dmsg[1], kernel.dmsg[2], kernel.dmsg[3], kernel.dmsg[4], kernel.dmsg[5]}
    lu.assertItemsEquals(loading,{
        -- any ordering will be ok
        {"load kernel module", "fifth", "/ class", "xwos.modules.fifth"},
        {"load kernel module", "first", "/ class", "xwos.modules.first"},
        {"load kernel module", "fourth", "/ class", "xwos.modules.fourth"},
        {"load kernel module", "second", "/ class", "xwos.modules.second"},
        {"load kernel module", "third", "/ class", "xwos.modules.third"}
    })
    table.remove(kernel.dmsg, 5)
    table.remove(kernel.dmsg, 4)
    table.remove(kernel.dmsg, 3)
    table.remove(kernel.dmsg, 2)
    table.remove(kernel.dmsg, 1)
    
    lu.assertEquals(kernel.dmsg, {
        -- pre boot for module order
        {"preboot kernel module", "first"},
        {"preboot first"},
        {"preboot kernel module", "second"},
        {"preboot second"},
        {"preboot kernel module", "third"},
        {"preboot third"},
        {"preboot kernel module", "fourth"},
        {"preboot fourth"},
        -- pre boot unknown module
        {"preboot kernel module", "fifth"},
        {"preboot fifth"},
        -- boot for module order
        {"boot kernel module", "first"},
        {"boot first"},
        {"boot kernel module", "second"},
        {"boot second"},
        {"boot kernel module", "third"},
        {"boot third"},
        {"boot kernel module", "fourth"},
        {"boot fourth"},
        -- boot unknown module
        {"boot kernel module", "fifth"},
        {"boot fifth"}
    })
end -- testPreBootOrder
