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

--------------------------------
-- gui component that holds children but does not draw anything from itself; it has no size
-- @type xwos.gui.container
-- @extends xwos.gui.component#xwos.gui.component
_CMR.class("xwos.gui.container").extends("xwos.gui.component")

------------------------
-- the object privates
-- @type xwcprivates
-- @extends xwos.gui.component#xwcprivates

------------------------
-- the internal class
-- @type xwcintern
-- @extends #xwos.gui.component

------------------------
-- the children; do not manipulate directly without care; instead call the methods add etc.
-- @field [parent=#xwcprivates] xwos.xwlist#xwos.xwlist _children

------------------------
-- the x position; do not manipulate directly without care; instead call the setPos method
-- @field [parent=#xwcprivates] #number _x

------------------------
-- the y position; do not manipulate directly without care; instead call the setPos method
-- @field [parent=#xwcprivates] #number _y

.ctor(
------------------------
-- @function [parent=#xwcintern] width
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number x
-- @param #number y
-- @param ... initial children
function(self, clazz, privates, x, y, ...)
    clazz._superctor(self, privates)
    privates._children = _CMR.new("xwos.xwlist", ...)
    for k in privates._children:iterate() do k._container = self end -- TODO find a better solution; non private field, do not override container (xwlist) etc.
    privates._x = x or 0
    privates._y = y or 0
end) -- ctor

------------------------
-- @function [parent=#xwos.gui.container] create
-- @param #number x
-- @param #number y
-- @param ... initial children
-- @return #xwos.gui.container
.sfunc("create", function(x, y, ...)
    return _CMR.new("xwos.gui.container", x, y, ...)
end) -- function create

-- abstract function to be overridden

-- default implementations

------------------------
-- add new entry to list end
-- @function [parent=#xwos.gui.container] push
-- @param #xwos.gui.container self self
-- @param xwos.gui.component#xwos.gui.component t object to push
-- @return xwos.gui.component#xwos.gui.component given object (t)

.func("push",
------------------------
-- @function [parent=#xwcintern] push
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param xwos.gui.component#xwos.gui.component t
-- @return xwos.gui.component#xwos.gui.component
function (self, clazz, privates, t)
    local R = privates._children:push(t)
    R._container = self -- TODO find a better solution; non private field, do not override container (xwlist) etc.
    self:redraw()
    return R
end) -- function push

------------------------
-- add new entry to list beginning
-- @function [parent=#xwos.gui.container] unshift
-- @param #xwos.gui.container self self
-- @param xwos.gui.component#xwos.gui.component t object to unshift
-- @return xwos.gui.component#xwos.gui.component given object (t)

.func("unshift",
------------------------
-- @function [parent=#xwcintern] unshift
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param xwos.gui.component#xwos.gui.component t
-- @return xwos.gui.component#xwos.gui.component
function (self, clazz, privates, t)
    local R = privates._children:unshift(t)
    R._container = self -- TODO find a better solution; non private field, do not override container (xwlist) etc.
    self:redraw()
    return R
end) -- function unshift

------------------------
-- insert a new entry after an element
-- @function [parent=#xwos.gui.container] insert
-- @param #xwos.gui.container self self
-- @param xwos.gui.component#xwos.gui.component t new entry
-- @param xwos.gui.component#xwos.gui.component after element before new entry
-- @return xwos.gui.component#xwos.gui.component given object (t)

.func("insert",
------------------------
-- @function [parent=#xwcintern] insert
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param xwos.gui.component#xwos.gui.component t
-- @return xwos.gui.component#xwos.gui.component
function (self, clazz, privates, t, after)
    local R = privates._children:insert(t, after)
    R._container = self -- TODO find a better solution; non private field, do not override container (xwlist) etc.
    self:redraw()
    return R
end) -- function insert

------------------------
-- pop element from end
-- @function [parent=#xwos.gui.container] pop
-- @param #xwos.gui.container self self
-- @return xwos.gui.component#xwos.gui.component entry

.func("pop",
------------------------
-- @function [parent=#xwcintern] pop
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return xwos.gui.component#xwos.gui.component
function (self, clazz, privates)
    local R = privates._children:pop()
    R._container = nil -- TODO find a better solution; non private field, do not override container (xwlist) etc.
    self:redraw()
    return R
end) -- function pop

------------------------
-- pop element from beginning
-- @function [parent=#xwos.gui.container] shift
-- @param #xwos.gui.container self self
-- @return xwos.gui.component#xwos.gui.component entry

.func("shift",
------------------------
-- @function [parent=#xwcintern] shift
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return xwos.gui.component#xwos.gui.component
function (self, clazz, privates)
    local R = privates._children:shift()
    R._container = nil -- TODO find a better solution; non private field, do not override container (xwlist) etc.
    self:redraw()
    return R
end) -- function shift

------------------------
-- remove given element from list
-- @function [parent=#xwos.gui.container] remove
-- @param #xwos.gui.container self self
-- @param xwos.gui.component#xwos.gui.component t element to remove
-- @return xwos.gui.component#xwos.gui.component given object (t)

.func("remove",
------------------------
-- @function [parent=#xwcintern] remove
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param xwos.gui.component#xwos.gui.component t
-- @return xwos.gui.component#xwos.gui.component
function (self, clazz, privates, t)
    privates._children:remove(t)
    t._container = self -- TODO find a better solution; non private field, do not override container (xwlist) etc.
    self:redraw()
    return t
end) -- function remove

------------------------
-- Returns component width
-- @function [parent=#xwos.gui.container] width
-- @param #xwos.gui.container self self
-- @return #number width

.func("width",
------------------------
-- @function [parent=#xwcintern] width
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return 0
end) -- function width

------------------------
-- Returns component height
-- @function [parent=#xwos.gui.container] height
-- @param #xwos.gui.container self self
-- @return #number height

.func("height",
------------------------
-- @function [parent=#xwcintern] height
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return 0
end) -- function height

------------------------
-- Returns component x position within parent
-- @function [parent=#xwos.gui.container] x
-- @param #xwos.gui.container self self
-- @return #number x position within parent

.func("x",
------------------------
-- @function [parent=#xwcintern] x
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return privates._x
end) -- function x

------------------------
-- Returns component x position within parent
-- @function [parent=#xwos.gui.container] y
-- @param #xwos.gui.container self self
-- @return #number y position within parent

.func("y",
------------------------
-- @function [parent=#xwcintern] y
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return privates._y
end) -- function y

------------------------
-- Changes components position within parent
-- @function [parent=#xwos.gui.container] setPos
-- @param #xwos.gui.container self self
-- @param #number x
-- @param #number y
-- @return #xwos.gui.container self for chaining

.func("setPos",
------------------------
-- @function [parent=#xwcintern] setPos
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number x
-- @param #number y
-- @return #xwos.gui.container
function (self, clazz, privates, x, y)
    privates._x = x
    privates._y = y
    self:redraw()
    return self
end) -- function setPos

------------------------
-- Redraw this single component; should not be invoked directly without care, instead call redraw on root stage
-- @function [parent=#xwos.gui.container] paint
-- @param #xwos.gui.container self self
-- @return #xwos.gui.container self for chaining

.func("paint",
------------------------
-- @function [parent=#xwcintern] paint
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #xwos.gui.container
function (self, clazz, privates)
    if privates._visible then
        for k in privates._children:iterate() do
            k:paint()
        end -- for children
    end -- if visible
    return self
end) -- function paint

------------------------
-- Paint a string within this container; do not invoke directly; this is meant to be invoked from components
-- @function [parent=#xwos.gui.container] str
-- @param #xwos.gui.container self self
-- @param #number x the x position of the string
-- @param #number y the y position of the string
-- @param #string str the string to be drawn
-- @param #number fg the foreground color
-- @param #number bg the background color
-- @return #xwos.gui.container self for chaining

.func("str",
------------------------
-- @function [parent=#xwcintern] str
-- @param #xwos.gui.container self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number x
-- @param #number y
-- @param #string str
-- @param #number fg
-- @param #number bg
-- @return #xwos.gui.container
function (self, clazz, privates, x, y, str, fg, bg)
    if privates._container ~= nil and privates._visible then
        privates._container:str(x + privates._x, y + privates._y, str, fg, bg)
    end -- if container and visible
    return self
end) -- function str

return nil