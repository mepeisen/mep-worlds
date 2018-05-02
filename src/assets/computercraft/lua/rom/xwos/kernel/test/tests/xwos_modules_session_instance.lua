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

TestXwosModulesSessionInstance = {}

function TestXwosModulesSessionInstance:setUp()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    -- add kernel common path
    cmr.addcp(boot.kernelRoot().."/kernel/common")
    
    cmr.load("xwos.modules.session.instance")
    -- kernelmock
    cmr.class('kernelmock')
        .ctor(function(self, clazz, privates)
            self.secdata = {}
            self.saveCalled = false
            self.modules = { instances = { session = { save = function() self.saveCalled = true end }}}
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

function TestXwosModulesSessionInstance:tearDown()
    _CMR = nil
end -- tearDown

-- testing instance creation
function TestXwosModulesSessionInstance:testNew()
    local kernel = _CMR.new('kernelmock')
    local obj = _CMR.new('xwos.modules.session.instance', kernel, 4711) -- xwos.modules.session.instance#xwos.modules.session.instance
    lu.assertEquals(obj:id(), 4711)
    lu.assertFalse(obj:isPersistent())
    lu.assertNil(obj:user())
end -- testNew



-- testing non persistent
function TestXwosModulesSessionInstance:testNPSetUser()
    local kernel = _CMR.new('kernelmock')
    local obj = _CMR.new('xwos.modules.session.instance', kernel, 4711) -- xwos.modules.session.instance#xwos.modules.session.instance
    local user = { name = function() return "FOO" end }
    obj:setUser(user)
    
    lu.assertEquals(obj:user(), user)
    lu.assertEquals(kernel.secdata, {})
end -- testNPSetUser

-- testing non persistent
function TestXwosModulesSessionInstance:testNPSetPersistent()
    local kernel = _CMR.new('kernelmock')
    local obj = _CMR.new('xwos.modules.session.instance', kernel, 4711) -- xwos.modules.session.instance#xwos.modules.session.instance
    local user = { name = function() return "FOO" end }
    obj:setUser(user)
    obj:setPersistent(false)
    
    lu.assertEquals(obj:user(), user)
    lu.assertEquals(kernel.secdata, {})
end -- testNPSetPersistent

-- testing persistent
function TestXwosModulesSessionInstance:testPSetUser()
    local kernel = _CMR.new('kernelmock')
    local obj = _CMR.new('xwos.modules.session.instance', kernel, 4711) -- xwos.modules.session.instance#xwos.modules.session.instance
    local user = { name = function() return "FOO" end }
    obj:setPersistent(true)
    lu.assertTrue(kernel.saveCalled)
    
    lu.assertEquals(kernel.secdata, {})
    
    obj:setUser(user)
    
    lu.assertEquals(obj:user(), user)
    lu.assertTrue(obj:isPersistent())
    
    obj:save()
    local f = {}
    f["core/session/4711.dat"] = "{\n  username = \"FOO\",\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testPSetUser

-- testing persistent
function TestXwosModulesSessionInstance:testLoadNil()
    local kernel = _CMR.new('kernelmock')
    local obj = _CMR.new('xwos.modules.session.instance', kernel, 4711) -- xwos.modules.session.instance#xwos.modules.session.instance
    obj:load()
    lu.assertTrue(obj:isPersistent())
    lu.assertNil(obj:user())
end -- testLoadNil

-- testing persistent
function TestXwosModulesSessionInstance:testLoad()
    local kernel = _CMR.new('kernelmock')
    local obj = _CMR.new('xwos.modules.session.instance', kernel, 4711) -- xwos.modules.session.instance#xwos.modules.session.instance
    local user = { name = function() return "FOO" end }
    kernel.modules.instances.user = { profile = function(s, name) if name == "FOO" then return user else return nil end end }
    
    kernel.secdata["core/session/4711.dat"] = "{\n  username = \"FOO\",\n}"
    
    obj:load()
    
    lu.assertTrue(obj:isPersistent())
    lu.assertEquals(obj:user(), user)
end -- testLoad
