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

------------------------
-- double linked list
-- @module xwos.xwlist
local xwlist = {}
xwlist.__index = xwlist

------------------------
-- list item in double linked list
-- @type xwoslistitem

------------------------
-- @field [parent=#xwoslistitem] #xwoslistitem _prev previous item

------------------------
-- @field [parent=#xwoslistitem] #xwoslistitem _next next item

------------------------
-- @field [parent=#xwoslistitem] #xwos.xwlist _container owning container

------------------------
-- create new list
-- @function [parent=#xwos.xwlist] new
-- @param ... initial objects
-- @return #xwos.xwlist list
function xwlist.create(...)
    return xwlist:new({}, ...)
end -- function create

------------------------
-- create new list
-- @function [parent=#xwos.xwlist] create
-- @param #xwos.xwlist self self
-- @param #xwos.xwlist o (optional) initial object
-- @param ... initial objects
-- @return #xwos.xwlist list
function xwlist:new(o, ...)
    o = o or {}
    setmetatable(o, self)
    ------------------------
    -- @field [parent=#xwos.xwlist] #number length number of elements in list
    o.length = 0
   
    ------------------------
    -- @field [parent=#xwos.xwlist] #table first first element
   
    ------------------------
    -- @field [parent=#xwos.xwlist] #table last last element
    for _, v in ipairs{...} do o:push(v) end
    return o
end -- function create

------------------------
-- add new entry to list end
-- @function [parent=#xwos.xwlist] push
-- @param #xwos.xwlist self self
-- @param #xwoslistitem t object to push
-- @return #xwoslistitem given object (t)
function xwlist:push(t)
    if self.last then
        self.last._next = t
        t._prev = self.last
        self.last = t
    else -- if self.last
        self.first = t
        self.last = t
    end -- if not self.last
    self.length = self.length + 1
    t._container = self
    return t
end -- function push

------------------------
-- add new entry to list beginning
-- @function [parent=#xwos.xwlist] unshift
-- @param #xwos.xwlist self self
-- @param #xwoslistitem t object to unshift
-- @return #xwoslistitem given object (t)
function xwlist:unshift(t)
    if self.first then
        self.first._prev = t
        t._next = self.first
        self.first = t
    else -- if self.first
        self.first = t
        self.last = t
    end -- i f not self.first
    self.length = self.length + 1
    t._container = self
    return t
end -- function unshift

------------------------
-- insert a new entry after an element
-- @function [parent=#xwos.xwlist] insert
-- @param #xwos.xwlist self self
-- @param #xwoslistitem t new entry
-- @param #xwoslistitem after element before new entry
-- @return #xwoslistitem given object (t)
function xwlist:insert(t, after)
    if after then
        if after._next then
            after._next._prev = t
            t._next = after._next
        else -- if after.next
            self.last = t
        end -- if not after.next
        t._prev = after
        after._next = t
        self.length = self.length + 1
    elseif not self.first then
        self.first = t
        self.last = t
    end -- if not after
    t._container = self
    return t
end -- function insert

------------------------
-- pop element from end
-- @function [parent=#xwos.xwlist] pop
-- @param #xwos.xwlist self self
-- @return #xwoslistitem entry
function xwlist:pop()
    if not self.last then return end -- if not last
    
    local ret = self.last
    if ret._prev then
        ret._prev._next = nil
        self.last = ret._prev
        ret._prev = nil
    else -- if ret.prev
        self.first = nil
        self.last = nil
    end -- if not ret.prev
    self.length = self.length - 1
    ret._container = nil
    return ret
end -- function pop

------------------------
-- pop element from beginning
-- @function [parent=#xwos.xwlist] shift
-- @param #xwos.xwlist self self
-- @return #xwoslistitem entry
function xwlist:shift()
    if not self.first then return end -- if not first
    
    local ret = self.first
    if ret._next then
        ret._next._prev = nil
        self.first = ret._next
        ret._next = nil
    else -- if ret.next
        self.first = nil
        self.last = nil
    end -- if not ret.next
    self.length = self.length - 1
    ret._container = nil
    return ret
end -- function shift

------------------------
-- remove given element from list
-- @function [parent=#xwos.xwlist] remove
-- @param #xwos.xwlist self self
-- @param #xwoslistitem t element to remove
function xwlist:remove(t)
    if t._next then
        if t._prev then
            t._next._prev = t._prev
            t._prev._next = t._next
        else -- if t.prev
            t._next._prev = nil
            self._first = t._next
        end -- if not t.prev
    elseif t._prev then
        t._prev._next = nil
        self._last = t._prev
    else --
        self._first = nil
        self._last = nil
    end
    t._next = nil
    t._prev = nil
    t._container = nil
    self.length = self.length - 1
end -- function remove

------------------------
-- iterator function
local function iterate(self, current)
    if not current then
        current = self.first
    elseif current then
        current = current._next
    end
    return current
end -- function iterate

------------------------
-- iterator for elements
-- @function [parent=#xwos.xwlist] iterate
-- @param #xwos.xwlist self self
-- @return #function iterator function
function xwlist:iterate()
    return iterate, self, nil
end -- function iterate

return xwlist