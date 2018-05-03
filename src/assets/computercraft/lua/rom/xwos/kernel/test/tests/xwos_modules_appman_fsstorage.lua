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

TestXwosModulesAppmanFsstorage = {}

function TestXwosModulesAppmanFsstorage:setUp()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    -- add kernel common path
    cmr.addcp(boot.kernelRoot().."/kernel/common")
    
    local allen = cmr.require('xwos.extensions.allen.allen')
    string.startsWith = allen.startsWith
    
    cmr.load("xwos.kernel.fschroot")
    cmr.load("xwos.modules.appman.fsstorage")
    -- kernelmock
    cmr.class('kernelmock')
        .ctor(function(self, clazz, privates)
            self.secdata = {}
            self.oldGlob = _G
        end)
        .func('writeSecureData', function(self, clazz, privates, path, data)
            self.secdata[path] = data
        end)
        .func('readSecureData', function(self, clazz, privates, path, def)
            local res = self.secdata[path]
            if res == nil then
                res = def
            end
            return res
        end)
end -- setUp

function TestXwosModulesAppmanFsstorage:tearDown()
    _CMR = nil
end -- tearDown

-- testing profile creation
function TestXwosModulesAppmanFsstorage:testNew()
    local kernel = _CMR.new('kernelmock')
    local fss = _CMR.new('xwos.modules.appman.fsstorage', 4711, kernel) -- xwos.modules.appman.fsstorage#xwos.modules.appman.fsstorage
    lu.assertEquals(fss:id(), 4711)
end -- testNew



-- testing set path
function TestXwosModulesAppmanFsstorage:testSetPath()
    local kernel = _CMR.new('kernelmock')
    local fss = _CMR.new('xwos.modules.appman.fsstorage', 4711, kernel) -- xwos.modules.appman.fsstorage#xwos.modules.appman.fsstorage
    fss:setPath(boot.kernelRoot().."/kernel/test/tests/fsstorage")
    
    local f = {}
    f["core/appman/fsstorage-4711.dat"] = "{\n  path = \""..boot.kernelRoot().."/kernel/test/tests/fsstorage\",\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testSetPath



-- testing app listings
function TestXwosModulesAppmanFsstorage:testListEmpty()
    local kernel = _CMR.new('kernelmock')
    local fss = _CMR.new('xwos.modules.appman.fsstorage', 4711, kernel) -- xwos.modules.appman.fsstorage#xwos.modules.appman.fsstorage
    fss:setPath(boot.kernelRoot().."/kernel/test/tests/fsstorage/unknown")
    lu.assertEquals(fss:listApps(), {})
end -- testListEmpty

-- testing app listings
function TestXwosModulesAppmanFsstorage:testList1()
    local kernel = _CMR.new('kernelmock')
    local fss = _CMR.new('xwos.modules.appman.fsstorage', 4711, kernel) -- xwos.modules.appman.fsstorage#xwos.modules.appman.fsstorage
    fss:setPath(boot.kernelRoot().."/kernel/test/tests/fsstorage/inv1")
    lu.assertItemsEquals(fss:listApps(), {"group3/app31/version1", "group3/app31/version2", "group3/app33/version1"})
end -- testList1
