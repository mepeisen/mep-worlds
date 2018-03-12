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

-------------------------------------------
-- @module xwos.xwlist
_CMR.class("xwlist")

------------------------
-- the variable privates
-- @type xwlistprivates

------------------------
-- the internal class
-- @type xwlistintern

------------------------
-- number of elements in list
-- @field [parent=#xwlistprivates] #number _length

------------------------
-- first element
-- @field [parent=#xwlistprivates] #table _first
   
------------------------
-- last element
-- @field [parent=#xwlistprivates] #table _last

------------------------
-- create new list
-- @function [parent=#xwos.xwlist] new
-- @param ... initial objects
-- @return #xwos.xwlist list
-- 
------------------------
-- create new list
-- @function [parent=#xwlistintern] new
-- @param ... initial objects
-- @return #xwos.xwlist list
.sfunc("create", function(...)
    return _CMR.new("xwlist", ...)
end) -- function create

.ctor(
------------------------
-- create new list
-- @function [parent=#xwlistintern] create
-- @param #xwos.xwlist self self
-- @param classmanager#clazz clazz xwlist class
-- @param #xwlistprivates privates
-- @param ... initial objects
-- @return #xwos.xwlist list
function (self, clazz, privates, ...)
    privates._length = 0
    for _, v in ipairs{...} do self:push(v) end
end) -- ctor

------------------------
-- add new entry to list end
-- @function [parent=#xwos.xwlist] push
-- @param #xwos.xwlist self self
-- @param #xwoslistitem t object to push
-- @return #xwoslistitem given object (t)

.func("push",
------------------------
-- add new entry to list end
-- @function [parent=#xwlistintern] push
-- @param #xwos.xwlist self self
-- @param classmanager#clazz clazz xwlist class
-- @param #xwlistprivates privates
-- @param #xwoslistitem t object to push
-- @return #xwoslistitem given object (t)
function (self, clazz, privates, t)
    -- TODO t privates
    if privates._last then
        privates._last._next = t
        t._prev = privates._last
        privates._last = t
    else -- if privates._last
        privates._first = t
        privates._last = t
    end -- if not privates._last
    privates._length = privates._length + 1
    t._container = self
    return t
end) -- function push

------------------------
-- add new entry to list beginning
-- @function [parent=#xwos.xwlist] unshift
-- @param #xwos.xwlist self self
-- @param #xwoslistitem t object to unshift
-- @return #xwoslistitem given object (t)

.func("unshift",
------------------------
-- add new entry to list beginning
-- @function [parent=#xwlistintern] unshift
-- @param #xwos.xwlist self self
-- @param classmanager#clazz clazz xwlist class
-- @param #xwlistprivates privates
-- @param #xwoslistitem t object to unshift
-- @return #xwoslistitem given object (t)
function (self, clazz, privates, t)
    if privates._first then
        privates._first._prev = t
        t._next = privates._first
        privates._first = t
    else -- if privates._first
        privates._first = t
        privates._last = t
    end -- i f not privates._first
    privates._length = privates._length + 1
    t._container = self
    return t
end) -- function unshift

------------------------
-- insert a new entry after an element
-- @function [parent=#xwos.xwlist] insert
-- @param #xwos.xwlist self self
-- @param #xwoslistitem t new entry
-- @param #xwoslistitem after element before new entry
-- @return #xwoslistitem given object (t)

.func("insert",
------------------------
-- insert a new entry after an element
-- @function [parent=#xwlistintern] insert
-- @param #xwos.xwlist self self
-- @param classmanager#clazz clazz xwlist class
-- @param #xwlistprivates privates
-- @param #xwoslistitem t new entry
-- @param #xwoslistitem after element before new entry
-- @return #xwoslistitem given object (t)
function (self, clazz, privates, t, after)
    if after then
        if after._next then
            after._next._prev = t
            t._next = after._next
        else -- if after.next
            privates._last = t
        end -- if not after.next
        t._prev = after
        after._next = t
        privates._length = privates._length + 1
    elseif not privates._first then
        privates._first = t
        privates._last = t
    end -- if not after
    t._container = self
    return t
end) -- function insert

------------------------
-- pop element from end
-- @function [parent=#xwos.xwlist] pop
-- @param #xwos.xwlist self self
-- @return #xwoslistitem entry

.func("pop",
------------------------
-- pop element from end
-- @function [parent=#xwlistintern] pop
-- @param #xwos.xwlist self self
-- @param classmanager#clazz clazz xwlist class
-- @param #xwlistprivates privates
-- @return #xwoslistitem entry
function (self, clazz, privates)
    if not privates._last then return end -- if not last
    
    local ret = privates._last
    if ret._prev then
        ret._prev._next = nil
        privates._last = ret._prev
        ret._prev = nil
    else -- if ret.prev
        privates._first = nil
        privates._last = nil
    end -- if not ret.prev
    privates._length = privates._length - 1
    ret._container = nil
    return ret
end) -- function pop

------------------------
-- pop element from beginning
-- @function [parent=#xwos.xwlist] shift
-- @param #xwos.xwlist self self
-- @return #xwoslistitem entry

.func("shift",
------------------------
-- pop element from beginning
-- @function [parent=#xwlistintern] shift
-- @param #xwos.xwlist self self
-- @param classmanager#clazz clazz xwlist class
-- @param #xwlistprivates privates
-- @return #xwoslistitem entry
function (self, clazz, privates)
    if not privates._first then return end -- if not first
    
    local ret = privates._first
    if ret._next then
        ret._next._prev = nil
        privates._first = ret._next
        ret._next = nil
    else -- if ret.next
        privates._first = nil
        privates._last = nil
    end -- if not ret.next
    privates._length = privates._length - 1
    ret._container = nil
    return ret
end) -- function shift

------------------------
-- remove given element from list
-- @function [parent=#xwos.xwlist] remove
-- @param #xwos.xwlist self self
-- @param #xwoslistitem t element to remove

.func("remove",
------------------------
-- remove given element from list
-- @function [parent=#xwlistintern] remove
-- @param #xwos.xwlist self self
-- @param classmanager#clazz clazz xwlist class
-- @param #xwlistprivates privates
-- @param #xwoslistitem t element to remove
function (self, class, privates, t)
    if t._next then
        if t._prev then
            t._next._prev = t._prev
            t._prev._next = t._next
        else -- if t.prev
            t._next._prev = nil
            privates._first = t._next
        end -- if not t.prev
    elseif t._prev then
        t._prev._next = nil
        privates._last = t._prev
    else --
        privates._first = nil
        privates._last = nil
    end
    t._next = nil
    t._prev = nil
    t._container = nil
    privates._length = privates._length - 1
end) -- function remove

------------------------
-- iterator for elements
-- @function [parent=#xwos.xwlist] iterate
-- @param #xwos.xwlist self self
-- @return #function iterator function

.func("iterate",
------------------------
-- iterator for elements
-- @function [parent=#xwlistintern] iterate
-- @param #xwos.xwlist self self
-- @param classmanager#clazz clazz xwlist class
-- @param #xwlistprivates privates
-- @return #function iterator function
function (self, class, privates)
    ------------------------
    -- iterator function
    -- TODO security (fenv)
    local function iterate(self, current)
        if not current then
            current = privates._first
        elseif current then
            current = current._next
        end
        return current
    end -- function iterate
        
    return iterate, self, nil
end) -- function iterate

return nil