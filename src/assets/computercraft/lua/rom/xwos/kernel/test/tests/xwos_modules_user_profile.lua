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

TestXwosModulesUserProfile = {}

function TestXwosModulesUserProfile:setUp()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    -- add kernel common path
    cmr.addcp(boot.kernelRoot().."/kernel/common")
    
    cmr.load("xwos.modules.user.profile")
    cmr.load("xwos.modules.security")
    cmr.load("xwos.modules.security.profile")
    -- kernelmock
    cmr.class('kernelmock')
        .ctor(function(self, clazz, privates)
            self.secdata = {}
            self.modules = {}
            self.modules.instances = {}
            self.modules.instances.security = cmr.new('xwos.modules.security', self)
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

function TestXwosModulesUserProfile:tearDown()
    _CMR = nil
end -- tearDown

-- testing profile creation
function TestXwosModulesUserProfile:testNew()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    lu.assertEquals(prof:id(), 4711)
    lu.assertEquals(prof:name(), "foo")
    lu.assertEquals(kernel.secdata, {})
    prof:save()
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {},\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testNew



-- testing api checks
function TestXwosModulesUserProfile:testApiGrantAll()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof = kernel.modules.instances.security:createProfile("luaunit")
    sprof:setApi("*", nil, "g")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit")
    
    lu.assertTrue(prof:checkApi("ABC", "DEF")) -- check access
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testApiGrantAll

-- testing api checks
function TestXwosModulesUserProfile:testApiAllowAll()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof = kernel.modules.instances.security:createProfile("luaunit")
    sprof:setApi("*", nil, "a")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit")
    
    lu.assertTrue(prof:checkApi("ABC", "DEF")) -- check access
    lu.assertFalse(prof:checkApiLevel("ABC", "DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testApiAllowAll

-- testing api checks
function TestXwosModulesUserProfile:testApiGrantAllMethods()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof = kernel.modules.instances.security:createProfile("luaunit")
    sprof:setApi("ABC", "*", "g")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit")
    
    lu.assertTrue(prof:checkApi("ABC", "DEF")) -- check access
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "a")) -- check access level
    
    lu.assertTrue(prof:checkApi("ABC", "GHI")) -- check access
    lu.assertTrue(prof:checkApiLevel("ABC", "GHI", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "GHI", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testApiGrantAllMethods

-- testing api checks
function TestXwosModulesUserProfile:testApiAllowAllMethods()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof = kernel.modules.instances.security:createProfile("luaunit")
    sprof:setApi("ABC", "*", "a")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit")
    
    lu.assertTrue(prof:checkApi("ABC", "DEF")) -- check access
    lu.assertFalse(prof:checkApiLevel("ABC", "DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "a")) -- check access level
    
    lu.assertTrue(prof:checkApi("ABC", "GHI")) -- check access
    lu.assertFalse(prof:checkApiLevel("ABC", "GHI", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "GHI", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testApiAllowAllMethods

-- testing api checks
function TestXwosModulesUserProfile:testApiGrantMethod()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof = kernel.modules.instances.security:createProfile("luaunit")
    sprof:setApi("ABC", "DEF", "g")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit")
    
    lu.assertTrue(prof:checkApi("ABC", "DEF")) -- check access
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "a")) -- check access level
    
    lu.assertFalse(prof:checkApi("ABC", "GHI")) -- check access
    lu.assertFalse(prof:checkApiLevel("ABC", "GHI", "g")) -- check grant level
    lu.assertFalse(prof:checkApiLevel("ABC", "GHI", "a")) -- check access level
    
    lu.assertFalse(prof:checkApi("ABC2", "DEF")) -- check access
    lu.assertFalse(prof:checkApiLevel("ABC2", "DEF", "g")) -- check grant level
    lu.assertFalse(prof:checkApiLevel("ABC2", "DEF", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testApiGrantMethod

-- testing api checks
function TestXwosModulesUserProfile:testApiAllowMethod()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof = kernel.modules.instances.security:createProfile("luaunit")
    sprof:setApi("ABC", "DEF", "a")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit")
    
    lu.assertTrue(prof:checkApi("ABC", "DEF")) -- check access
    lu.assertFalse(prof:checkApiLevel("ABC", "DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "a")) -- check access level
    
    lu.assertFalse(prof:checkApi("ABC", "GHI")) -- check access
    lu.assertFalse(prof:checkApiLevel("ABC", "GHI", "g")) -- check grant level
    lu.assertFalse(prof:checkApiLevel("ABC", "GHI", "a")) -- check access level
    
    lu.assertFalse(prof:checkApi("ABC2", "DEF")) -- check access
    lu.assertFalse(prof:checkApiLevel("ABC2", "DEF", "g")) -- check grant level
    lu.assertFalse(prof:checkApiLevel("ABC2", "DEF", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testApiAllowMethod



-- testing function checks
function TestXwosModulesUserProfile:testFuncGrantAll()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof = kernel.modules.instances.security:createProfile("luaunit")
    sprof:setAccess("*", "g")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit")
    
    lu.assertTrue(prof:checkAccess("ABC.DEF")) -- check access
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncGrantAll

-- testing function checks
function TestXwosModulesUserProfile:testFuncAllowAll()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof = kernel.modules.instances.security:createProfile("luaunit")
    sprof:setAccess("*", "a")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit")
    
    lu.assertTrue(prof:checkAccess("ABC.DEF")) -- check access
    lu.assertFalse(prof:checkAccessLevel("ABC.DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncAllowAll

-- testing function checks
function TestXwosModulesUserProfile:testFuncGrantAllMethods()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof = kernel.modules.instances.security:createProfile("luaunit")
    sprof:setAccess("ABC.*", "g")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit")
    
    lu.assertTrue(prof:checkAccess("ABC.DEF")) -- check access
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "a")) -- check access level
    
    lu.assertTrue(prof:checkAccess("ABC.GHI")) -- check access
    lu.assertTrue(prof:checkAccessLevel("ABC.GHI", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.GHI", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncGrantAllMethods

-- testing function checks
function TestXwosModulesUserProfile:testFuncAllowAllMethods()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof = kernel.modules.instances.security:createProfile("luaunit")
    sprof:setAccess("ABC.*", "a")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit")
    
    lu.assertTrue(prof:checkAccess("ABC.DEF")) -- check access
    lu.assertFalse(prof:checkAccessLevel("ABC.DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "a")) -- check access level
    
    lu.assertTrue(prof:checkAccess("ABC.GHI")) -- check access
    lu.assertFalse(prof:checkAccessLevel("ABC.GHI", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.GHI", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncAllowAllMethods

-- testing function checks
function TestXwosModulesUserProfile:testFuncGrantMethod()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof = kernel.modules.instances.security:createProfile("luaunit")
    sprof:setAccess("ABC.DEF", "g")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit")
    
    lu.assertTrue(prof:checkAccess("ABC.DEF")) -- check access
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "a")) -- check access level
    
    lu.assertFalse(prof:checkAccess("ABC.GHI")) -- check access
    lu.assertFalse(prof:checkAccessLevel("ABC.GHI", "g")) -- check grant level
    lu.assertFalse(prof:checkAccessLevel("ABC.GHI", "a")) -- check access level
    
    lu.assertFalse(prof:checkAccess("ABC2.DEF")) -- check access
    lu.assertFalse(prof:checkAccessLevel("ABC2.DEF", "g")) -- check grant level
    lu.assertFalse(prof:checkAccessLevel("ABC2.DEF", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncGrantMethod

-- testing function checks
function TestXwosModulesUserProfile:testFuncAllowMethod()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof = kernel.modules.instances.security:createProfile("luaunit")
    sprof:setAccess("ABC.DEF", "a")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit")
    
    lu.assertTrue(prof:checkAccess("ABC.DEF")) -- check access
    lu.assertFalse(prof:checkAccessLevel("ABC.DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "a")) -- check access level
    
    lu.assertFalse(prof:checkAccess("ABC.GHI")) -- check access
    lu.assertFalse(prof:checkAccessLevel("ABC.GHI", "g")) -- check grant level
    lu.assertFalse(prof:checkAccessLevel("ABC.GHI", "a")) -- check access level
    
    lu.assertFalse(prof:checkAccess("ABC2.DEF")) -- check access
    lu.assertFalse(prof:checkAccessLevel("ABC2.DEF", "g")) -- check grant level
    lu.assertFalse(prof:checkAccessLevel("ABC2.DEF", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncAllowMethod



-- testing function checks
function TestXwosModulesUserProfile:testFuncMulti()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    local sprof1 = kernel.modules.instances.security:createProfile("luaunit1")
    sprof1:setAccess("ABC.DEF", "a")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    local sprof2 = kernel.modules.instances.security:createProfile("luaunit2")
    sprof2:setAccess("ABC.GHI", "g")
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    prof:addAcl("luaunit1")
    prof:addAcl("luaunit2")
    
    lu.assertTrue(prof:checkAccess("ABC.DEF")) -- check access
    lu.assertFalse(prof:checkAccessLevel("ABC.DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "a")) -- check access level
    
    lu.assertTrue(prof:checkAccess("ABC.GHI")) -- check access
    lu.assertTrue(prof:checkAccessLevel("ABC.GHI", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.GHI", "a")) -- check access level
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {\n    luaunit1 = true,\n    luaunit2 = true,\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncMulti



-- testing passwords
function TestXwosModulesUserProfile:testPass()
    local kernel = _CMR.new('kernelmock') -- xwos.kernel#xwos.kernel
    local prof = _CMR.new('xwos.modules.user.profile', "foo", kernel, 4711) -- xwos.modules.user.profile#xwos.modules.user.profile
    kernel.secdata = {} -- clear secured data from automatic security profile generation
    lu.assertFalse(prof:isActive())
    prof:setActive(true)
    lu.assertTrue(prof:isActive())
    
    local f = {}
    f["core/user/4711.dat"] = "{\n  secp = {},\n  active = true,\n}"
    lu.assertEquals(kernel.secdata, f)
    
    lu.assertFalse(prof:checkPassword("foo"))
    prof:setPassword("foo")
    lu.assertTrue(prof:checkPassword("foo"))
    
    f["core/user/4711.dat"] = "{\n  secp = {},\n  active = true,\n  pass = \"foo\",\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testPass