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
-- gui component that holds children but does not draw anything from itself; it has no size
-- @module xwos.xwgui.container
-- @extends xwos.xwgui.component#xwos.xwgui.component
local container = xwos.xwgui.component:new()
container.__index = container

------------------------
-- the children; do not manipulate directly without care; instead call the methods add etc.
-- @field [parent=#xwos.xwgui.container] xwos.xwlist#xwos.xwlist _children the containers children

------------------------
-- the x position; do not manipulate directly without care; instead call the setPos method
-- @field [parent=#xwos.xwgui.container] #number _x the x position

------------------------
-- the y position; do not manipulate directly without care; instead call the setPos method
-- @field [parent=#xwos.xwgui.container] #number _y the y position

------------------------
-- create new container
-- @function [parent=#xwos.xwgui.container] create
-- @param ... initial children
-- @return #xwos.xwgui.container container
function container.create(...)
    return container:new({}, ...)
end -- function create

------------------------
-- Creates a new container
-- @function [parent=#xwos.xwgui.container] new
-- @param #xwos.xwgui.container self self
-- @param #table o (optional) object to initialize
-- @param ... optional children
-- @return #xwos.xwgui.container new object
function container:new(o, ...)
    o = xwos.xwgui.component:new(o)
    setmetatable(o, self)
    o._children = xwos.xwlist.create(...)
    return o
end -- function new

-- abstract function to be overridden

-- default implementations

------------------------
-- add new entry to list end
-- @function [parent=#xwos.xwgui.container] push
-- @param #xwos.xwgui.container self self
-- @param #xwos.xwgui.component t object to push
-- @return #xwos.xwgui.component given object (t)
function container:push(t)
    local R = self._children:push(t)
    self:redraw()
    return R
end -- function push

------------------------
-- add new entry to list beginning
-- @function [parent=#xwos.xwgui.container] unshift
-- @param #xwos.xwgui.container self self
-- @param #xwos.xwgui.component t object to unshift
-- @return #xwos.xwgui.component given object (t)
function container:unshift(t)
    local R = self._children:unshift(t)
    self:redraw()
    return R
end -- function unshift

------------------------
-- insert a new entry after an element
-- @function [parent=#xwos.xwgui.container] insert
-- @param #xwos.xwgui.container self self
-- @param #xwos.xwgui.component t new entry
-- @param #xwos.xwgui.component after element before new entry
function container:insert(t, after)
    local R = self._children:insert(t, after)
    self:redraw()
    return R
end -- function insert

------------------------
-- pop element from end
-- @function [parent=#xwos.xwgui.container] pop
-- @param #xwos.xwgui.container self self
-- @return #xwos.xwgui.component entry
function container:pop()
    local R = self._children:pop()
    self:redraw()
    return R
end -- function pop

------------------------
-- pop element from beginning
-- @function [parent=#xwos.xwgui.container] shift
-- @param #xwos.xwgui.container self self
-- @return #xwos.xwgui.component entry
function container:shift()
    local R = self._children:shift()
    self:redraw()
    return R
end -- function shift

------------------------
-- remove given element from list
-- @function [parent=#xwos.xwgui.container] remove
-- @param #xwos.xwgui.container self self
-- @param #xwos.xwgui.component t element to remove
function container:remove(t)
    self._children:remove(t)
    self:redraw()
end -- function remove

------------------------
-- Returns component width
-- @function [parent=#xwos.xwgui.container] width
-- @param #xwos.xwgui.container self self
-- @return #number width
function container:width()
    return 0
end -- function width

------------------------
-- Returns component height
-- @function [parent=#xwos.xwgui.container] height
-- @param #xwos.xwgui.container self self
-- @return #number height
function container:height()
    return 0
end -- function height

------------------------
-- Returns component x position within parent
-- @function [parent=#xwos.xwgui.container] x
-- @param #xwos.xwgui.container self self
-- @return #number x position within parent
function container:x()
    return self._x
end -- function x

------------------------
-- Returns component x position within parent
-- @function [parent=#xwos.xwgui.container] y
-- @param #xwos.xwgui.container self self
-- @return #number y position within parent
function container:y()
    return self._y
end -- function y

------------------------
-- Changes components position within parent
-- @function [parent=#xwos.xwgui.container] setPos
-- @param #xwos.xwgui.container self self
-- @param #number x
-- @param #number y
-- @return #xwos.xwgui.container self for chaining
function container:setPos(x, y)
    self._x = x
    self._y = y
    self:redraw()
    return self
end -- function setPos

------------------------
-- Redraw this single component; should not be invoked directly without care, instead call redraw on root stage
-- @function [parent=#xwos.xwgui.container] paint
-- @param #xwos.xwgui.container self self
-- @return #xwos.xwgui.container self for chaining
function container:paint()
    if self._visible then
        for k,v in self._children:iterate() do
            v:paint()
        end -- for children
    end -- if visible
    return self
end -- function paint

------------------------
-- Paint a string within this container; do not invoke directly; this is meant to be invoked from components
-- @function [parent=#xwos.xwgui.container] str
-- @param #xwos.xwgui.container self self
-- @param #number x the x position of the string
-- @param #number y the y position of the string
-- @param #string str the string to be drawn
-- @param #number fg the foreground color
-- @param #number bg the background color
-- @return #xwos.xwgui.container self for chaining
function container:str(x, y, str, fg, bg)
    if self._container ~= nil and self._visible then
        self._container:str(x + self._x, y + self._y, str, fg, bg)
    end -- if container and visible
    return self
end -- function str

return container