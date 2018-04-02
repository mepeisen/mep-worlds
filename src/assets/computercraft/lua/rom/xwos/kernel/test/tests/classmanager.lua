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

TestClassmanager = {}

-- tests a simple class with object creation
function TestClassmanager:testSimple()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
    local obj = cmr.new('Foo')
    lu.assertNotNil(obj)
end -- testSimple

-- tests error throwing on unknown classes
function TestClassmanager:testUnkown()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    lu.assertErrorMsgContains("class Foo not found", cmr.new, 'Foo')
end -- testUnkown

-- tests loading simple class from classpath
function TestClassmanager:testSimpleCp()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    cmr.addcp(boot.kernelRoot()..'/kernel/test/tests/classmanager')
    cmr.new('SimpleClass')
    _CMR = nil
end -- testSimpleCp

-- tests cmr require
function TestClassmanager:testRequire()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    cmr.addcp(boot.kernelRoot()..'/kernel/test/tests/classmanager')
    cmr.require('SimpleClassInvalid')
    lu.assertNotNil(cmr.new('SOMEOTHERCLASS:-(')) -- only works if SimpleClassInvalid was really loaded
    _CMR = nil
end -- testRequire

-- tests errors if class file does not declare needed class
function TestClassmanager:testSimpleCp2()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    cmr.addcp(boot.kernelRoot()..'/kernel/test/tests/classmanager')
    lu.assertErrorMsgContains("SimpleClassInvalid did not declare class SimpleClassInvalid", cmr.new, 'SimpleClassInvalid')
    _CMR = nil
end -- testSimpleCp2

-- tests class lists
function TestClassmanager:testList()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    cmr.addcp(boot.kernelRoot()..'/kernel/test')
    local res = {}
    for k,v in pairs(cmr.findClasses("tests.classmanager")) do table.insert(res, k) end
    lu.assertItemsEquals(res, {
        "tests.classmanager.SimpleClass",
        "tests.classmanager.SimpleClassInvalid"
        })
    _CMR = nil
end -- testList

-- tests class lists
function TestClassmanager:testList2()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    cmr.addcp(boot.kernelRoot()..'/kernel/test')
    local res = {}
    for k,v in pairs(cmr.findPackages("tests")) do table.insert(res, k) end
    lu.assertItemsEquals(res, {
        "tests.classmanager",
        "tests.classmanager2"
        })
    _CMR = nil
end -- testList

-- tests simple singleton
function TestClassmanager:testSingleton()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo').singleton(false)
    lu.assertErrorMsgContains("Cannot create new instance of singleton Foo", cmr.new, 'Foo')
    local obj = cmr.get('Foo')
    lu.assertNotNil(obj)
    lu.assertErrorMsgContains("Cannot create new instance of singleton Foo", cmr.new, 'Foo')
end -- testSingleton

-- tests simple abstract class
function TestClassmanager:testAbstract()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo').abstract()
    lu.assertErrorMsgContains("Cannot create new instance of abstract Foo", cmr.new, 'Foo')
end -- testAbstract

-- tests simple abstract class
function TestClassmanager:testAbstract2()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo').aFunc("getFoo")
    local obj = cmr.new('Foo')
    lu.assertErrorMsgContains("method not supported", function() obj:getFoo() end)
end -- testAbstract

-- tests load class
function TestClassmanager:testLoadAll()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    cmr.addcp(boot.kernelRoot()..'/kernel/test/tests')
    lu.assertFalse(cmr.defined('classmanager2.SimpleClass'))
    cmr.loadAll('classmanager2')
    lu.assertTrue(cmr.defined('classmanager2.SimpleClass'))
    _CMR = nil
end -- testLoadAll

-- tests load class
function TestClassmanager:testLoad()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    cmr.addcp(boot.kernelRoot()..'/kernel/test/tests')
    lu.assertFalse(cmr.defined('classmanager2.SimpleClass'))
    cmr.load('classmanager2.SimpleClass')
    lu.assertTrue(cmr.defined('classmanager2.SimpleClass'))
    _CMR = nil
end -- testLoad

-- tests simple non singleton
function TestClassmanager:testNonSingleton()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
    lu.assertErrorMsgContains("Cannot retrieve non-singleton Foo", cmr.get, 'Foo')
end -- testNonSingleton

-- tests public functions with public fields
function TestClassmanager:testPublic()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .func("setBar", function(self, clazz, privates, val) self.bar = val end)
        .func("getBar", function(self, clazz, privates) return self.bar end)
    local obj = cmr.new('Foo')
    lu.assertIsFunction(obj.setBar)
    lu.assertIsFunction(obj.getBar)
    lu.assertIsNil(obj:getBar())
    lu.assertIsNil(obj.bar)
    obj:setBar("BAZ")
    lu.assertEquals(obj:getBar(), "BAZ")
    lu.assertEquals(obj.bar, "BAZ")
end -- testPublic

-- tests private fields
function TestClassmanager:testPrivates()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .func("setBar", function(self, clazz, privates, val) privates.bar = val end)
        .func("getBar", function(self, clazz, privates) return privates.bar end)
    local obj = cmr.new('Foo')
    lu.assertIsFunction(obj.setBar)
    lu.assertIsFunction(obj.getBar)
    lu.assertIsNil(obj:getBar())
    lu.assertIsNil(obj.bar)
    obj:setBar("BAZ")
    lu.assertEquals(obj:getBar(), "BAZ")
    lu.assertNil(obj.bar)
end -- testPrivates

-- tests constructor invocations
function TestClassmanager:testCtor()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .ctor(function(self, clazz, privates, val)
            self.foo = val
            privates.bar = val
         end)
        .func("setBar", function(self, clazz, privates, val)
            self.foo = val
            privates.bar = val
         end)
        .func("getFoo", function(self, clazz, privates) return self.foo end)
        .func("getBar", function(self, clazz, privates) return privates.bar end)
    local obj = cmr.new('Foo', "BAZ")
    lu.assertIsFunction(obj.setBar)
    lu.assertIsFunction(obj.getBar)
    lu.assertEquals(obj:getBar(), "BAZ")
    lu.assertEquals(obj:getFoo(), "BAZ")
    lu.assertIsNil(obj.bar)
    lu.assertEquals(obj.foo, "BAZ")
    obj:setBar("BAZ2")
    lu.assertEquals(obj:getBar(), "BAZ2")
    lu.assertEquals(obj:getFoo(), "BAZ2")
    lu.assertIsNil(obj.bar)
    lu.assertEquals(obj.foo, "BAZ2")
end -- testCtor

-- tests constructor invocations (extensions)
function TestClassmanager:testCtorExtends()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .ctor(function(self, clazz, privates, val)
            self.foo = val
            privates.bar = val
         end)
        .func("setBar", function(self, clazz, privates, val)
            self.foo = val
            privates.bar = val
         end)
        .func("getFoo", function(self, clazz, privates) return self.foo end)
        .func("getBar", function(self, clazz, privates) return privates.bar end)
    cmr.class('Bar').extends('Foo')
        .ctor(function(self, clazz, privates, val)
            clazz.super("FOO"..val)
         end)
    local obj = cmr.new('Bar', "BAZ")
    lu.assertIsFunction(obj.setBar)
    lu.assertIsFunction(obj.getBar)
    lu.assertEquals(obj:getBar(), "FOOBAZ")
    lu.assertEquals(obj:getFoo(), "FOOBAZ")
    lu.assertIsNil(obj.bar)
    lu.assertEquals(obj.foo, "FOOBAZ")
    obj:setBar("BAZ2")
    lu.assertEquals(obj:getBar(), "BAZ2")
    lu.assertEquals(obj:getFoo(), "BAZ2")
    lu.assertIsNil(obj.bar)
    lu.assertEquals(obj.foo, "BAZ2")
end -- testCtor

-- tests private functions (sharing self)
function TestClassmanager:testPrivates2()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .pfunc("setFoo", function(self, clazz, privates, val) self.foo = val end)
        .func("setBar", function(self, clazz, privates, val) privates:setFoo(val) end)
        .func("getBar", function(self, clazz, privates) return self.foo end)
    local obj = cmr.new('Foo')
    lu.assertIsFunction(obj.setBar)
    lu.assertIsFunction(obj.getBar)
    lu.assertIsNil(obj.setFoo)
    lu.assertIsNil(obj:getBar())
    lu.assertIsNil(obj.foo)
    obj:setBar("BAZ")
    lu.assertEquals(obj:getBar(), "BAZ")
    lu.assertEquals(obj.foo, "BAZ")
end -- testPrivates2

-- tests private functions (sharing privates)
function TestClassmanager:testPrivates3()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .pfunc("setFoo", function(self, clazz, privates, val) privates.foo = val end)
        .func("setBar", function(self, clazz, privates, val) privates:setFoo(val) end)
        .func("getBar", function(self, clazz, privates) return privates.foo end)
    local obj = cmr.new('Foo')
    lu.assertIsFunction(obj.setBar)
    lu.assertIsFunction(obj.getBar)
    lu.assertIsNil(obj.setFoo)
    lu.assertIsNil(obj:getBar())
    lu.assertIsNil(obj.foo)
    obj:setBar("BAZ")
    lu.assertEquals(obj:getBar(), "BAZ")
    lu.assertIsNil(obj.foo)
end -- testPrivates3

-- tests static functions
function TestClassmanager:testStatics()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .sfunc("create", function(val) return "FOO"..val end)
    cmr.load('Foo') -- explicit class loading (will define statics)
    lu.assertNotNil(Foo)
    lu.assertNotNil(Foo.create)
    lu.assertEquals(Foo.create("BAR"), "FOOBAR")
    Foo = nil
end -- testStatics

-- tests private static variables
function TestClassmanager:testStatics2()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .pstat("foo", "BAR")
        .func("getFoo", function(self, clazz, privates) return clazz.getPstat("foo")[1] end)
    local obj = cmr.new('Foo')
    lu.assertEquals(obj:getFoo(), "BAR")
end -- testStatics2

-- tests simple class inheritance
function TestClassmanager:testExtends()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .pstat("foo", "BAR")
        .func("getFoo", function(self, clazz, privates) return clazz.getPstat("foo")[1] end)
    cmr.class('Bar').extends('Foo')
    local obj = cmr.new('Bar')
    lu.assertEquals(obj:getFoo(), "BAR")
end -- testExtends

-- tests simple class inheritance with multiple statics
function TestClassmanager:testExtendsSt()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .pstat("foo", "BAR")
        .func("getFoo", function(self, clazz, privates, val) return clazz.getPstat("foo")[val] end)
    cmr.class('Bar').extends('Foo')
        .pstat("foo", "BAZ")
    local obj = cmr.new('Bar')
    lu.assertEquals(obj:getFoo(1), "BAZ")
    lu.assertEquals(obj:getFoo(2), "BAR")
end -- testExtendsSt

-- tests simple class inheritance (override)
function TestClassmanager:testOverride()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .pstat("foo", "BAR")
        .func("getFoo", function(self, clazz, privates) return clazz.getPstat("foo")[1] end)
    cmr.class('Bar').extends('Foo')
        .func("getFoo", function(self, clazz, privates) return "BAZ" end)
    local obj = cmr.new('Bar')
    lu.assertEquals(obj:getFoo(), "BAZ")
end -- testOverride

-- tests simple class inheritance (override)
function TestClassmanager:testOverride2()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .pstat("foo", "BAR")
        .func("getFoo", function(self, clazz, privates) return clazz.getPstat("foo")[1] end)
    cmr.class('Bar').extends('Foo')
        .func("getFoo", function(self, clazz, privates) return clazz.super().."BAZ" end)
    local obj = cmr.new('Bar')
    lu.assertEquals(obj:getFoo(), "BARBAZ")
end -- testOverride2

-- tests simple class inheritance (override two times)
function TestClassmanager:testOverride3()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .pstat("foo", "BAR")
        .func("getFoo", function(self, clazz, privates) return clazz.getPstat("foo")[1] end)
    cmr.class('Bar').extends('Foo')
        .func("getFoo", function(self, clazz, privates) return clazz.super().."BAZ" end)
    cmr.class('Baz').extends('Bar')
        .func("getFoo", function(self, clazz, privates) return clazz.super().."FOO" end)
    local obj = cmr.new('Baz')
    lu.assertEquals(obj:getFoo(), "BARBAZFOO")
end -- testOverride3

-- tests simple class inheritance (override one time but over two super classes)
function TestClassmanager:testOverride4()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .pstat("foo", "BAR")
        .func("getFoo", function(self, clazz, privates) return clazz.getPstat("foo")[1] end)
    cmr.class('Bar').extends('Foo')
    cmr.class('Baz').extends('Bar')
        .func("getFoo", function(self, clazz, privates) return clazz.super().."FOO" end)
    local obj = cmr.new('Baz')
    lu.assertEquals(obj:getFoo(), "BARFOO")
end -- testOverride4

-- tests simple class mixin
function TestClassmanager:testMixin()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .func("getBar", function(self, clazz, privates) return "FOO" end)
        .func("getFoo", function(self, clazz, privates) return self:getBar() end)
    cmr.class('Bar').mixin("foo", "Foo")
        .func("getBar", function(self, clazz, privates) return "BAR" end)
    local obj = cmr.new('Bar')
    lu.assertEquals(obj:getBar(), "BAR")
    lu.assertEquals(obj:getFoo(), "FOO")
end -- testMixin

-- tests friend classes
function TestClassmanager:testFriend()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo').friends('Bar')
        .func("setBar", function(self, clazz, privates, val) privates.bar = val end)
        .func("getBar", function(self, clazz, privates) return privates.bar end)
    cmr.class('Bar')
        .func("getFooBar", function(self, clazz, privates, foo) return clazz.privates(foo).bar end)
    local foo = cmr.new('Foo')
    local bar = cmr.new('Bar')
    foo:setBar("BAZ")
    lu.assertEquals(bar:getFooBar(foo), "BAZ")
end -- testFriend

-- tests friend classes
function TestClassmanager:testFriend1()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Foo')
        .func("setBar", function(self, clazz, privates, val) privates.bar = val end)
        .func("getBar", function(self, clazz, privates) return privates.bar end)
    cmr.class('Bar')
        .func("getFooBar", function(self, clazz, privates, foo) return clazz.privates(foo).bar end)
    local foo = cmr.new('Foo')
    local bar = cmr.new('Bar')
    foo:setBar("BAZ")
    lu.assertErrorMsgContains("Bar is not allowed to access Foo privates", bar.getFooBar, bar, foo)
end -- testFriend1

-- tests friend classes
function TestClassmanager:testAnnot()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    cmr.class('Annot')
        .ctor(function(self, clazz, privates, val) privates.bar = val end)
        .func("setBar", function(self, clazz, privates, val) privates.bar = val end)
        .func("getBar", function(self, clazz, privates) return privates.bar end)
    cmr.class('Foo')
        .func("setBar", function(self, clazz, privates, val) privates.bar = val end)
        .func("getBar", function(self, clazz, privates) return privates.bar end)
    cmr.class('Bar')
        .func("initBar", function(self, clazz, privates, foo)
            foo:setBar("FOO-INIT")
            clazz.annot(foo, 'Annot', 'ANNOT-INIT')
        end)
        .func("setBar", function(self, clazz, privates, foo)
            foo:setBar("FOO-SET")
            clazz.getAnnot(foo, 'Annot'):setBar('ANNOT-SET')
        end)
        .func("clearBar", function(self, clazz, privates, foo)
            foo:setBar("FOO-CLEAR")
            clazz.clearAnnot(foo, 'Annot')
        end)
        .func("getBar", function(self, clazz, privates, foo) return clazz.getAnnot(foo, 'Annot'):getBar() end)
    local foo = cmr.new('Foo')
    local bar = cmr.new('Bar')
    bar:initBar(foo)
    lu.assertEquals(foo:getBar(), "FOO-INIT")
    lu.assertEquals(bar:getBar(foo), "ANNOT-INIT")
    bar:setBar(foo)
    lu.assertEquals(foo:getBar(), "FOO-SET")
    lu.assertEquals(bar:getBar(foo), "ANNOT-SET")
    bar:clearBar(foo)
    lu.assertEquals(foo:getBar(), "FOO-CLEAR")
    lu.assertErrorMsgContains("nil value", function() bar:getBar(foo) end)
end -- testAnnot

