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

TestXwosModulesAppmanInstance = {}

function TestXwosModulesAppmanInstance:setUp()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    -- add kernel common path
    cmr.addcp(boot.kernelRoot().."/kernel/common")
    
    local allen = cmr.require('xwos.extensions.allen.allen')
    string.startsWith = allen.startsWith
    
    cmr.load("xwos.modules.appman.instance")
    cmr.load("xwos.kernel.fschroot")
    cmr.load("xwos.kernel.fsro")
    cmr.load("xwos.modules.appman.storage")
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

function TestXwosModulesAppmanInstance:tearDown()
    _CMR = nil
end -- tearDown

-- testing app instance with non existent manifest file
function TestXwosModulesAppmanInstance:testNotFound()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local fss = _CMR.new('xwos.modules.appman.fsstorage', 4711, kernel) -- xwos.modules.appman.fsstorage#xwos.modules.appman.fsstorage
    fss:setPath(boot.kernelRoot().."/kernel/test/tests/fsstorage")
    
    local obj = _CMR.new('xwos.modules.appman.instance', fss, "notfound", kernel) -- xwos.modules.appman.instance#xwos.modules.appman.instance
    
    lu.assertEquals(obj:manifest(), {})
    lu.assertErrorMsgContains("Not a directory", function() obj:data():list("") end)
    -- TODO check cmr building
end -- testNotFound

-- testing app instance with invalid manifest file
function TestXwosModulesAppmanInstance:testInvalid()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local fss = _CMR.new('xwos.modules.appman.fsstorage', 4711, kernel) -- xwos.modules.appman.fsstorage#xwos.modules.appman.fsstorage
    fss:setPath(boot.kernelRoot().."/kernel/test/tests/fsstorage")
    
    local obj = _CMR.new('xwos.modules.appman.instance', fss, "inv1", kernel) -- xwos.modules.appman.instance#xwos.modules.appman.instance
    
    lu.assertItemsEquals(obj:manifest(), {})
    lu.assertErrorMsgContains("Not a directory", function() obj:data():list("") end)
    -- TODO check cmr building
end -- testInvalid

-- testing app instance with valid manifest file
function TestXwosModulesAppmanInstance:testValid()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local fss = _CMR.new('xwos.modules.appman.fsstorage', 4711, kernel) -- xwos.modules.appman.fsstorage#xwos.modules.appman.fsstorage
    fss:setPath(boot.kernelRoot().."/kernel/test/tests/fsstorage")
    
    local obj = _CMR.new('xwos.modules.appman.instance', fss, "app1", kernel) -- xwos.modules.appman.instance#xwos.modules.appman.instance
    
    lu.assertItemsEquals(obj:manifest(), {
        artifact="myapp",
        author="Your name",
        dependencies="XWOS@[0.0.4",
        email="Your mail address",
        group="eu_xworlds_sample",
        hardware="ANY",
        main="eu.xworlds.samples.myapp.main",
        name="My sample application",
        namespace="eu.xworlds.samples.myapp",
        url="http://your-domain/your-app.html",
        version="0.0.1-SNAPSHOT"
    })
    lu.assertEquals(obj:data():list(""), {"foo.txt"})
    -- TODO check cmr building
end -- testValid
