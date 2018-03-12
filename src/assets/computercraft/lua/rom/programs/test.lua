local cmgr = require('/rom/xwos/kernel/common/classmanager')() -- classmanager#classmanager

for _, f in pairs(fs.list("/rom")) do
    print(f)
end -- for fs.list
--
--cmgr.class("foobase").ctor(
--    function(self, clazz, privates, arg0)
--        print("foobase: self", self)
--        print("foobase: privates", privates)
--        for k,v in pairs(clazz) do
--            print("foobase: clazz", k, v)
--        end
--    end -- ctor
--)
--cmgr.class("foo").extends("foobase").ctor(
--    function(self, clazz, privates, arg0)
--        clazz._superctor(self, arg0)
--        print("foo: self", self)
--        print("foo: privates", privates)
--        for k,v in pairs(clazz) do
--            print("foo: clazz", k, v)
--        end
--    end -- ctor
--)
--
--cmgr.new("foo", 123)
