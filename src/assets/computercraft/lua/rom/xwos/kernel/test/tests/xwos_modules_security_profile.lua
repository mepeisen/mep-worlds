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

TestXwosModulesSecurityProfile = {}

function TestXwosModulesSecurityProfile:setUp()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    -- add kernel common path
    cmr.addcp(boot.kernelRoot().."/kernel/common")
    
    cmr.load("xwos.modules.security.profile")
    -- kernelmock
    cmr.class('kernelmock')
        .ctor(function(self, clazz, privates)
            self.secdata = {}
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

function TestXwosModulesSecurityProfile:tearDown()
    _CMR = nil
end -- tearDown

-- testing profile creation
function TestXwosModulesSecurityProfile:testNew()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    lu.assertEquals(prof:id(), 4711)
    lu.assertEquals(prof:name(), "foo")
    lu.assertEquals(kernel.secdata, {})
    prof:save()
    local f = {}
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {},\n    api = {},\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testNew



-- testing api checks
function TestXwosModulesSecurityProfile:testApiGrantAll()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    prof:setApi("*", nil, "g")
    
    lu.assertTrue(prof:checkApi("ABC", "DEF")) -- check access
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "a")) -- check access level
    
    local f = {}
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {},\n    api = {\n      [ \"*\" ] = {\n        VAL = \"g\",\n      },\n    },\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testApiGrantAll

-- testing api checks
function TestXwosModulesSecurityProfile:testApiAllowAll()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    prof:setApi("*", nil, "a")
    
    lu.assertTrue(prof:checkApi("ABC", "DEF")) -- check access
    lu.assertFalse(prof:checkApiLevel("ABC", "DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "a")) -- check access level
    
    local f = {}
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {},\n    api = {\n      [ \"*\" ] = {\n        VAL = \"a\",\n      },\n    },\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testApiAllowAll

-- testing api checks
function TestXwosModulesSecurityProfile:testApiGrantAllMethods()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    prof:setApi("ABC", "*", "g")
    
    lu.assertTrue(prof:checkApi("ABC", "DEF")) -- check access
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "a")) -- check access level
    
    lu.assertTrue(prof:checkApi("ABC", "GHI")) -- check access
    lu.assertTrue(prof:checkApiLevel("ABC", "GHI", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "GHI", "a")) -- check access level
    
    local f = {}
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {},\n    api = {\n      ABC = {\n        [ \"*\" ] = {\n          VAL = \"g\",\n        },\n      },\n    },\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testApiGrantAllMethods

-- testing api checks
function TestXwosModulesSecurityProfile:testApiAllowAllMethods()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    prof:setApi("ABC", "*", "a")
    
    lu.assertTrue(prof:checkApi("ABC", "DEF")) -- check access
    lu.assertFalse(prof:checkApiLevel("ABC", "DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "DEF", "a")) -- check access level
    
    lu.assertTrue(prof:checkApi("ABC", "GHI")) -- check access
    lu.assertFalse(prof:checkApiLevel("ABC", "GHI", "g")) -- check grant level
    lu.assertTrue(prof:checkApiLevel("ABC", "GHI", "a")) -- check access level
    
    local f = {}
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {},\n    api = {\n      ABC = {\n        [ \"*\" ] = {\n          VAL = \"a\",\n        },\n      },\n    },\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testApiAllowAllMethods

-- testing api checks
function TestXwosModulesSecurityProfile:testApiGrantMethod()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    prof:setApi("ABC", "DEF", "g")
    
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
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {},\n    api = {\n      ABC = {\n        DEF = {\n          VAL = \"g\",\n        },\n      },\n    },\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testApiGrantMethod

-- testing api checks
function TestXwosModulesSecurityProfile:testApiAllowMethod()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    prof:setApi("ABC", "DEF", "a")
    
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
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {},\n    api = {\n      ABC = {\n        DEF = {\n          VAL = \"a\",\n        },\n      },\n    },\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testApiAllowMethod



-- testing function checks
function TestXwosModulesSecurityProfile:testFuncGrantAll()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    prof:setAccess("*", "g")
    
    lu.assertTrue(prof:checkAccess("ABC.DEF")) -- check access
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "a")) -- check access level
    
    local f = {}
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {\n      [ \"*\" ] = {\n        VAL = \"g\",\n      },\n    },\n    api = {},\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncGrantAll

-- testing function checks
function TestXwosModulesSecurityProfile:testFuncAllowAll()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    prof:setAccess("*", "a")
    
    lu.assertTrue(prof:checkAccess("ABC.DEF")) -- check access
    lu.assertFalse(prof:checkAccessLevel("ABC.DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "a")) -- check access level
    
    local f = {}
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {\n      [ \"*\" ] = {\n        VAL = \"a\",\n      },\n    },\n    api = {},\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncAllowAll

-- testing function checks
function TestXwosModulesSecurityProfile:testFuncGrantAllMethods()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    prof:setAccess("ABC.*", "g")
    
    lu.assertTrue(prof:checkAccess("ABC.DEF")) -- check access
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "a")) -- check access level
    
    lu.assertTrue(prof:checkAccess("ABC.GHI")) -- check access
    lu.assertTrue(prof:checkAccessLevel("ABC.GHI", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.GHI", "a")) -- check access level
    
    local f = {}
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {\n      ABC = {\n        [ \"*\" ] = {\n          VAL = \"g\",\n        },\n      },\n    },\n    api = {},\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncGrantAllMethods

-- testing function checks
function TestXwosModulesSecurityProfile:testFuncAllowAllMethods()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    prof:setAccess("ABC.*", "a")
    
    lu.assertTrue(prof:checkAccess("ABC.DEF")) -- check access
    lu.assertFalse(prof:checkAccessLevel("ABC.DEF", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.DEF", "a")) -- check access level
    
    lu.assertTrue(prof:checkAccess("ABC.GHI")) -- check access
    lu.assertFalse(prof:checkAccessLevel("ABC.GHI", "g")) -- check grant level
    lu.assertTrue(prof:checkAccessLevel("ABC.GHI", "a")) -- check access level
    
    local f = {}
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {\n      ABC = {\n        [ \"*\" ] = {\n          VAL = \"a\",\n        },\n      },\n    },\n    api = {},\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncAllowAllMethods

-- testing function checks
function TestXwosModulesSecurityProfile:testFuncGrantMethod()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    prof:setAccess("ABC.DEF", "g")
    
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
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {\n      ABC = {\n        DEF = {\n          VAL = \"g\",\n        },\n      },\n    },\n    api = {},\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncGrantMethod

-- testing function checks
function TestXwosModulesSecurityProfile:testFuncAllowMethod()
    local kernel = _CMR.new('kernelmock')
    local prof = _CMR.new('xwos.modules.security.profile', "foo", kernel, 4711) -- xwos.modules.security.profile#xwos.modules.security.profile
    prof:setAccess("ABC.DEF", "a")
    
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
    f["core/security/4711.dat"] = "{\n  acl = {\n    func = {\n      ABC = {\n        DEF = {\n          VAL = \"a\",\n        },\n      },\n    },\n    api = {},\n  },\n}"
    lu.assertEquals(kernel.secdata, f)
end -- testFuncAllowMethod