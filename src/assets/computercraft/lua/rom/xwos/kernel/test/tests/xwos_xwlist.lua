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

TestXwosXwlist = {}

function TestXwosXwlist:setUp()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    cmr.addcp(unpack(boot.kernelpaths()))
    cmr.class("MyItem").ctor(function(self, clazz, privates, arg) self.value=arg end)
end -- setUp

function TestXwosXwlist:tearDown()
    _CMR = nil
end -- tearDown

local function toArray(list)
    local res = {}
    for v in list:iterate() do
        table.insert(res, v)
    end
    return res
end -- function list

-- tests a simple empty list creation
function TestXwosXwlist:testEmpty()
    local list = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:length(), 0)
    lu.assertNil(list:first())
    lu.assertNil(list:last())
    for _,v in list:iterate() do
        lu.fail("unexpected iterator entry")
    end
end -- testEmpty

-- tests a simple list creation with given items
function TestXwosXwlist:testWithCtorItems()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local list = _CMR.new("xwos.xwlist", item1, item2) -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:length(), 2)
    lu.assertEquals(list:first(), item1)
    lu.assertEquals(list:last(), item2)
    lu.assertEquals(toArray(list), {item1, item2})
end -- testWithCtorItems

-- tests unsifting elements
function TestXwosXwlist:testUnshift()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local item3 = _CMR.new("MyItem", 3)
    local list = _CMR.new("xwos.xwlist", item1, item2) -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:unshift(item3), item3)
    lu.assertEquals(list:length(), 3)
    lu.assertEquals(list:first(), item3)
    lu.assertEquals(list:last(), item2)
    lu.assertEquals(toArray(list), {item3, item1, item2})
end -- testUnshift

-- tests unsifting elements
function TestXwosXwlist:testUnshiftEmpty()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local item3 = _CMR.new("MyItem", 3)
    local list = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:unshift(item2), item2)
    lu.assertEquals(list:unshift(item1), item1)
    lu.assertEquals(list:unshift(item3), item3)
    lu.assertEquals(list:length(), 3)
    lu.assertEquals(list:first(), item3)
    lu.assertEquals(list:last(), item2)
    lu.assertEquals(toArray(list), {item3, item1, item2})
end -- testUnshiftEmpty

-- tests inserting elements
function TestXwosXwlist:testInsertBegin()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local item3 = _CMR.new("MyItem", 3)
    local item4 = _CMR.new("MyItem", 4)
    local list = _CMR.new("xwos.xwlist", item1, item2, item3) -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:insert(item4, nil), item4)
    lu.assertEquals(list:length(), 4)
    lu.assertEquals(list:first(), item4)
    lu.assertEquals(list:last(), item3)
    lu.assertEquals(toArray(list), {item4, item1, item2, item3})
end -- testInsertBegin

-- tests inserting elements
function TestXwosXwlist:testInsertMid()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local item3 = _CMR.new("MyItem", 3)
    local item4 = _CMR.new("MyItem", 4)
    local list = _CMR.new("xwos.xwlist", item1, item2, item3) -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:insert(item4, item2), item4)
    lu.assertEquals(list:length(), 4)
    lu.assertEquals(list:first(), item1)
    lu.assertEquals(list:last(), item3)
    lu.assertEquals(toArray(list), {item1, item2, item4, item3})
end -- testInsertMid

-- tests inserting elements
function TestXwosXwlist:testInsertEnd()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local item3 = _CMR.new("MyItem", 3)
    local item4 = _CMR.new("MyItem", 4)
    local list = _CMR.new("xwos.xwlist", item1, item2, item3) -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:insert(item4, item3), item4)
    lu.assertEquals(list:length(), 4)
    lu.assertEquals(list:first(), item1)
    lu.assertEquals(list:last(), item4)
    lu.assertEquals(toArray(list), {item1, item2, item3, item4})
end -- testInsertEnd

-- tests pop elements
function TestXwosXwlist:testPop()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local item3 = _CMR.new("MyItem", 3)
    local list = _CMR.new("xwos.xwlist", item1, item2, item3) -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:pop(), item3)
    lu.assertEquals(list:length(), 2)
    lu.assertEquals(list:first(), item1)
    lu.assertEquals(list:last(), item2)
    lu.assertEquals(toArray(list), {item1, item2})
    lu.assertEquals(list:pop(), item2)
    lu.assertEquals(list:length(), 1)
    lu.assertEquals(list:first(), item1)
    lu.assertEquals(list:last(), item1)
    lu.assertEquals(toArray(list), {item1})
end -- testPop

-- tests pop elements
function TestXwosXwlist:testPopEmpty()
    local list = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    lu.assertNil(list:pop())
    lu.assertEquals(list:length(), 0)
    lu.assertNil(list:first())
    lu.assertNil(list:last())
    lu.assertEquals(toArray(list), {})
end -- testPopEmpty

-- tests pop elements
function TestXwosXwlist:testPopEmpty2()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local item3 = _CMR.new("MyItem", 3)
    local list = _CMR.new("xwos.xwlist", item1, item2, item3) -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:pop(), item3)
    lu.assertEquals(list:pop(), item2)
    lu.assertEquals(list:pop(), item1)
    lu.assertNil(list:pop())
    lu.assertEquals(list:length(), 0)
    lu.assertNil(list:first())
    lu.assertNil(list:last())
    lu.assertEquals(toArray(list), {})
end -- testPopEmpty2

-- tests shift elements
function TestXwosXwlist:testShift()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local item3 = _CMR.new("MyItem", 3)
    local list = _CMR.new("xwos.xwlist", item1, item2, item3) -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:shift(), item1)
    lu.assertEquals(list:length(), 2)
    lu.assertEquals(list:first(), item2)
    lu.assertEquals(list:last(), item3)
    lu.assertEquals(toArray(list), {item2, item3})
    lu.assertEquals(list:shift(), item2)
    lu.assertEquals(list:length(), 1)
    lu.assertEquals(list:first(), item3)
    lu.assertEquals(list:last(), item3)
    lu.assertEquals(toArray(list), {item3})
end -- testShift

-- tests shift elements
function TestXwosXwlist:testShiftEmpty()
    local list = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    lu.assertNil(list:shift())
    lu.assertEquals(list:length(), 0)
    lu.assertNil(list:first())
    lu.assertNil(list:last())
    lu.assertEquals(toArray(list), {})
end -- testShiftEmpty

-- tests shift elements
function TestXwosXwlist:testShiftEmpty2()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local item3 = _CMR.new("MyItem", 3)
    local list = _CMR.new("xwos.xwlist", item1, item2, item3) -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:shift(), item1)
    lu.assertEquals(list:shift(), item2)
    lu.assertEquals(list:shift(), item3)
    lu.assertNil(list:shift())
    lu.assertEquals(list:length(), 0)
    lu.assertNil(list:first())
    lu.assertNil(list:last())
    lu.assertEquals(toArray(list), {})
end -- testShiftEmpty2

-- tests removing elements
function TestXwosXwlist:testRemoveBegin()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local item3 = _CMR.new("MyItem", 3)
    local item4 = _CMR.new("MyItem", 4)
    local list = _CMR.new("xwos.xwlist", item1, item2, item3, item4) -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:remove(item1), item1)
    lu.assertEquals(list:length(), 3)
    lu.assertEquals(list:first(), item2)
    lu.assertEquals(list:last(), item4)
    lu.assertEquals(toArray(list), {item2, item3, item4})
end -- testRemoveBegin

-- tests removing elements
function TestXwosXwlist:testRemoveMid()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local item3 = _CMR.new("MyItem", 3)
    local item4 = _CMR.new("MyItem", 4)
    local list = _CMR.new("xwos.xwlist", item1, item2, item3, item4) -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:remove(item2), item2)
    lu.assertEquals(list:length(), 3)
    lu.assertEquals(list:first(), item1)
    lu.assertEquals(list:last(), item4)
    lu.assertEquals(toArray(list), {item1, item3, item4})
    lu.assertEquals(list:remove(item3), item3)
    lu.assertEquals(list:length(), 2)
    lu.assertEquals(list:first(), item1)
    lu.assertEquals(list:last(), item4)
    lu.assertEquals(toArray(list), {item1, item4})
end -- testRemoveMid

-- tests removing elements
function TestXwosXwlist:testRemoveEnd()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local item3 = _CMR.new("MyItem", 3)
    local item4 = _CMR.new("MyItem", 4)
    local list = _CMR.new("xwos.xwlist", item1, item2, item3, item4) -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(list:remove(item4), item4)
    lu.assertEquals(list:length(), 3)
    lu.assertEquals(list:first(), item1)
    lu.assertEquals(list:last(), item3)
    lu.assertEquals(toArray(list), {item1, item2, item3})
end -- testRemoveEnd

-- tests duplicate pushing the same element
function TestXwosXwlist:testErrorDupPush()
    local item1 = _CMR.new("MyItem", 1)
    local list = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    list:push(item1)
    lu.assertErrorMsgContains("element already contained in list", function() list:push(item1) end)
end -- testErrorDupPush

-- tests duplicate pushing the same element
function TestXwosXwlist:testErrorDupPush2()
    local item1 = _CMR.new("MyItem", 1)
    local list = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    local list2 = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    list:push(item1)
    lu.assertErrorMsgContains("element already contained in list", function() list2:push(item1) end)
end -- testErrorDupPush2

-- tests duplicate unshifting the same element
function TestXwosXwlist:testErrorDupUnshift()
    local item1 = _CMR.new("MyItem", 1)
    local list = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    list:unshift(item1)
    lu.assertErrorMsgContains("element already contained in list", function() list:unshift(item1) end)
end -- testErrorDupUnshift

-- tests duplicate unshifting the same element
function TestXwosXwlist:testErrorDupUnshift2()
    local item1 = _CMR.new("MyItem", 1)
    local list = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    local list2 = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    list:unshift(item1)
    lu.assertErrorMsgContains("element already contained in list", function() list2:unshift(item1) end)
end -- testErrorDupUnshift2

-- tests duplicate inserting the same element
function TestXwosXwlist:testErrorDupInsert()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local list = _CMR.new("xwos.xwlist", item1) -- xwos.xwlist#xwos.xwlist
    list:insert(item2, item1)
    lu.assertErrorMsgContains("element already contained in list", function() list:insert(item2, item1) end)
end -- testErrorDupUnshift

-- tests duplicate inserting the same element
function TestXwosXwlist:testErrorDupInsert2()
    local item1 = _CMR.new("MyItem", 1)
    local item2 = _CMR.new("MyItem", 2)
    local list = _CMR.new("xwos.xwlist", item1) -- xwos.xwlist#xwos.xwlist
    local list2 = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    lu.assertErrorMsgContains("after not contained in this list", function() list2:insert(item2, item1) end)
end -- testErrorDupUnshift2

-- tests removing unknown
function TestXwosXwlist:testErrorRemoveUnknown()
    local item1 = _CMR.new("MyItem", 1)
    local list = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    lu.assertErrorMsgContains("element not contained in this list", function() list:remove(item1) end)
end -- testErrorRemoveUnknown

-- tests removing unknown
function TestXwosXwlist:testErrorRemoveUnknown2()
    local item1 = _CMR.new("MyItem", 1)
    local list = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    local list2 = _CMR.new("xwos.xwlist", item1) -- xwos.xwlist#xwos.xwlist
    lu.assertErrorMsgContains("element not contained in this list", function() list:remove(item1) end)
    list2:remove(item1)
end -- testErrorRemoveUnknown2
