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
_CMR.class("xwos.xwlist")

------------------------
-- the object privates
-- @type xwlistprivates

------------------------
-- the internal class
-- @type xwlistintern
-- @extends #xwos.xwlist 

------------------------
-- number of elements in list
-- @field [parent=#xwlistprivates] #number _length

------------------------
-- first element
-- @field [parent=#xwlistprivates] #xwoslistitem _first
   
------------------------
-- last element
-- @field [parent=#xwlistprivates] #xwoslistitem _last

------------------------
-- list item
-- @type xwoslistitem

------------------------
-- next element
-- @field [parent=#xwoslistitem] #xwoslistitem _next
   
------------------------
-- prev element
-- @field [parent=#xwoslistitem] #xwoslistitem _prev
   
------------------------
-- container list
-- @field [parent=#xwoslistitem] #xwos.xwlist _container

------------------------
-- create new list
-- @function [parent=#xwos.xwlist] create
-- @param ... initial objects
-- @return #xwos.xwlist list

.sfunc("create",
------------------------
-- @function [parent=#xwlistintern] create
-- @param ...
-- @return #xwos.xwlist
function(...)
    return _CMR.new("xwos.xwlist", ...)
end) -- function create

.ctor(
------------------------
-- create new list
-- @function [parent=#xwlistintern] __ctor
-- @param #xwos.xwlist self self
-- @param classmanager#clazz clazz xwlist class
-- @param #xwlistprivates privates
-- @param ... initial objects
function (self, clazz, privates, ...)
    privates._length = 0
    local l = select('#', ...)
    for i=1, l do
        self:push(select(i, ...))
    end
end) -- ctor

------------------------
-- add new entry to list end
-- @function [parent=#xwos.xwlist] push
-- @param #xwos.xwlist self self
-- @param #xwoslistitem t object to push
-- @return #xwoslistitem given object (t)

.func("push",
------------------------
-- @function [parent=#xwlistintern] push
-- @param #xwos.xwlist self
-- @param classmanager#clazz clazz
-- @param #xwlistprivates privates
-- @param #xwoslistitem t
-- @return #xwoslistitem
function (self, clazz, privates, t)
    local ta = clazz.getAnnot(t, "xwos.xwlistitem")
    if ta ~= nil then
        error("element already contained in list")
    end
    ta = clazz.annot(t, "xwos.xwlistitem")
    if privates._last then
        clazz.getAnnot(privates._last, "xwos.xwlistitem")._next = t
        ta._prev = privates._last
        privates._last = t
    else -- if privates._last
        privates._first = t
        privates._last = t
    end -- if not privates._last
    privates._length = privates._length + 1
    ta._container = self
    return t
end) -- function push

------------------------
-- returns list length
-- @function [parent=#xwos.xwlist] length
-- @param #xwos.xwlist self self
-- @return #number length

.func("length",
------------------------
-- @function [parent=#xwlistintern] length
-- @param #xwos.xwlist self
-- @param classmanager#clazz clazz
-- @param #xwlistprivates privates
-- @return #number
function (self, clazz, privates)
    return privates._length
end) -- function first

------------------------
-- returns first entry
-- @function [parent=#xwos.xwlist] first
-- @param #xwos.xwlist self self
-- @return #xwoslistitem first object

.func("first",
------------------------
-- @function [parent=#xwlistintern] first
-- @param #xwos.xwlist self
-- @param classmanager#clazz clazz
-- @param #xwlistprivates privates
-- @return #xwoslistitem
function (self, clazz, privates)
    return privates._first
end) -- function first

------------------------
-- returns last entry
-- @function [parent=#xwos.xwlist] last
-- @param #xwos.xwlist self self
-- @return #xwoslistitem last object

.func("last",
------------------------
-- @function [parent=#xwlistintern] last
-- @param #xwos.xwlist self
-- @param classmanager#clazz clazz
-- @param #xwlistprivates privates
-- @return #xwoslistitem
function (self, clazz, privates)
    return privates._last
end) -- function first

------------------------
-- add new entry to list beginning
-- @function [parent=#xwos.xwlist] unshift
-- @param #xwos.xwlist self self
-- @param #xwoslistitem t object to unshift
-- @return #xwoslistitem given object (t)

.func("unshift",
------------------------
-- @function [parent=#xwlistintern] unshift
-- @param #xwos.xwlist self
-- @param classmanager#clazz clazz
-- @param #xwlistprivates privates
-- @param #xwoslistitem t
-- @return #xwoslistitem
function (self, clazz, privates, t)
    local ta = clazz.getAnnot(t, "xwos.xwlistitem")
    if ta ~= nil then
        error("element already contained in list")
    end
    ta = clazz.annot(t, "xwos.xwlistitem")
    if privates._first then
        clazz.getAnnot(privates._first, "xwos.xwlistitem")._prev = t
        ta._next = privates._first
        privates._first = t
    else -- if privates._first
        privates._first = t
        privates._last = t
    end -- i f not privates._first
    privates._length = privates._length + 1
    ta._container = self
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
-- @function [parent=#xwlistintern] insert
-- @param #xwos.xwlist self
-- @param classmanager#clazz clazz
-- @param #xwlistprivates privates
-- @param #xwoslistitem t
-- @param #xwoslistitem after
-- @return #xwoslistitem
function (self, clazz, privates, t, after)
    local ta = clazz.getAnnot(t, "xwos.xwlistitem")
    if ta ~= nil then
        error("element already contained in list")
    end
    if after then
        ta = clazz.annot(t, "xwos.xwlistitem")
        local tafter = clazz.getAnnot(after, "xwos.xwlistitem")
        if tafter == nill or tafter._container ~= self then
            error("after not contained in this list")
        end
        if tafter._next then
            clazz.getAnnot(tafter._next, "xwos.xwlistitem")._prev = t
            ta._next = tafter._next
        else -- if after.next
            privates._last = t
        end -- if not after.next
        ta._prev = after
        tafter._next = t
        privates._length = privates._length + 1
        ta._container = self
    elseif not privates._first then
        ta = clazz.annot(t, "xwos.xwlistitem")
        privates._first = t
        privates._last = t
        privates._length = privates._length + 1
        ta._container = self
    else
        self:unshift(t)
    end -- if not after
    return t
end) -- function insert

------------------------
-- pop element from end
-- @function [parent=#xwos.xwlist] pop
-- @param #xwos.xwlist self self
-- @return #xwoslistitem entry

.func("pop",
------------------------
-- @function [parent=#xwlistintern] pop
-- @param #xwos.xwlist self
-- @param classmanager#clazz clazz
-- @param #xwlistprivates privates
-- @return #xwoslistitem
function (self, clazz, privates)
    if not privates._last then return end -- if not last
    
    local ret = privates._last
    local tret = clazz.getAnnot(ret, "xwos.xwlistitem")
    if tret._prev then
        clazz.getAnnot(tret._prev, "xwos.xwlistitem")._next = nil
        privates._last = tret._prev
    else -- if ret.prev
        privates._first = nil
        privates._last = nil
    end -- if not ret.prev
    privates._length = privates._length - 1
    clazz.clearAnnot(ret, "xwos.xwlistitem")
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
-- @param #xwos.xwlist self
-- @param classmanager#clazz clazz
-- @param #xwlistprivates
-- @return #xwoslistitem
function (self, clazz, privates)
    if not privates._first then return end -- if not first
    
    local ret = privates._first
    local tret = clazz.getAnnot(ret, "xwos.xwlistitem")
    if tret._next then
        clazz.getAnnot(tret._next, "xwos.xwlistitem")._prev = nil
        privates._first = tret._next
    else -- if ret.next
        privates._first = nil
        privates._last = nil
    end -- if not ret.next
    privates._length = privates._length - 1
    clazz.clearAnnot(ret, "xwos.xwlistitem")
    return ret
end) -- function shift

------------------------
-- remove given element from list
-- @function [parent=#xwos.xwlist] remove
-- @param #xwos.xwlist self self
-- @param #xwoslistitem t element to remove
-- @param #xwoslistitem the removed element (t)

.func("remove",
------------------------
-- @function [parent=#xwlistintern] remove
-- @param #xwos.xwlist self
-- @param classmanager#clazz clazz
-- @param #xwlistprivates privates
-- @param #xwoslistitem t
-- @return #xwoslistitem
function (self, clazz, privates, t)
    local ta = clazz.getAnnot(t, "xwos.xwlistitem")
    if ta == nil or ta._container ~= self then
        error("element not contained in this list")
    end
    if ta._next then
        if ta._prev then
            clazz.getAnnot(ta._next, "xwos.xwlistitem")._prev = ta._prev
            clazz.getAnnot(ta._prev, "xwos.xwlistitem")._next = ta._next
        else -- if t.prev
            clazz.getAnnot(ta._next, "xwos.xwlistitem")._prev = nil
            privates._first = ta._next
        end -- if not t.prev
    elseif ta._prev then
        clazz.getAnnot(ta._prev, "xwos.xwlistitem")._next = nil
        privates._last = ta._prev
    else --
        privates._first = nil
        privates._last = nil
    end
    clazz.clearAnnot(t, "xwos.xwlistitem")
    privates._length = privates._length - 1
    return t
end) -- function remove

------------------------
-- iterator for elements
-- @function [parent=#xwos.xwlist] iterate
-- @param #xwos.xwlist self self
-- @return #function iterator function

.func("iterate",
------------------------
-- @function [parent=#xwlistintern] iterate
-- @param #xwos.xwlist self
-- @param classmanager#clazz clazz
-- @param #xwlistprivates privates
-- @return #function
function (self, clazz, privates)
    ------------------------
    -- iterator function
    -- TODO security (fenv)
    local function iterate(self, current)
        if not current then
            current = privates._first
        elseif current then
            current = clazz.getAnnot(current, "xwos.xwlistitem")._next
        end
        return current
    end -- function iterate
        
    return iterate, self, nil
end) -- function iterate

_CMR.class("xwos.xwlistitem")

return nil