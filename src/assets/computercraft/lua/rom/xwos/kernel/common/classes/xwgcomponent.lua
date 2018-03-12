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
-- gui component base class
-- @module xwgcomponent
-- @extends xwos.xwlist#xwoslistitem
local component = {}
component.__index = component

------------------------
-- @field [parent=#xwgcomponent] xwgcontainer#xwgcontainer _container owning container

------------------------
-- @field [parent=#xwgcomponent] #number _visible visible flag; do not change manually, instead invoke show() or hide()

------------------------
-- Creates a new component
-- @function [parent=#xwgcomponent] new
-- @param #xwgcomponent self self
-- @param #table o (optional) object to initialize
-- @return #xwgcomponent new object
function component:new(o)
    o = xwos.xwlist:new(o)
    setmetatable(o, self)
    o._visible = true
    return o
end -- function new

-- abstract function to be overridden

------------------------
-- Returns component width
-- @function [parent=#xwgcomponent] width
-- @param #xwgcomponent self self
-- @return #number width
function component:width()
    error("method not supported")
end -- function width

------------------------
-- Returns component height
-- @function [parent=#xwgcomponent] height
-- @param #xwgcomponent self self
-- @return #number height
function component:height()
    error("method not supported")
end -- function height

------------------------
-- Changes components size
-- @function [parent=#xwgcomponent] setSize
-- @param #xwgcomponent self self
-- @param #number width
-- @param #number height
-- @return #xwgcomponent self for chaining
function component:setSize(width, height)
    error("method not supported")
end -- function setSize

------------------------
-- Returns component x position within parent
-- @function [parent=#xwgcomponent] x
-- @param #xwgcomponent self self
-- @return #number x position within parent
function component:x()
    error("method not supported")
end -- function x

------------------------
-- Returns component y position within parent
-- @function [parent=#xwgcomponent] y
-- @param #xwgcomponent self self
-- @return #number y position within parent
function component:y()
    error("method not supported")
end -- function y

------------------------
-- Changes components position within parent
-- @function [parent=#xwgcomponent] setPos
-- @param #xwgcomponent self self
-- @param #number x
-- @param #number y
-- @return #xwgcomponent self for chaining
function component:setPos(x, y)
    error("method not supported")
end -- function setPos

------------------------
-- Redraw this single component; should not be invoked directly without care, instead call redraw on root stage
-- @function [parent=#xwgcomponent] paint
-- @param #xwgcomponent self self
-- @return #xwgcomponent self for chaining
function component:paint()
    error("method not supported")
end -- function paint

-- default implementations

------------------------
-- Returns component size
-- @function [parent=#xwgcomponent] size
-- @param #xwgcomponent self self
-- @return #number size (width, height)
function component:size()
    return self:width(), self:height()
end -- function size

------------------------
-- Returns component position within parent
-- @function [parent=#xwgcomponent] pos
-- @param #xwgcomponent self self
-- @return #number position (x, y)
function component:pos()
    return self:x(), self:y()
end -- function pos

------------------------
-- show this component
-- @function [parent=#xwgcomponent] show
-- @param #xwgcomponent self self
-- @return #xwgcomponent self for chaining
function component:show()
    if not self._visible then
        self._visible = true
        self:redraw()
    end -- if not visible
end -- function show

------------------------
-- hide this component
-- @function [parent=#xwgcomponent] show
-- @param #xwgcomponent self self
-- @return #xwgcomponent self for chaining
function component:hide()
    if self._visible then
        self._visible = false
        self:redraw()
    end -- if visible
end -- function hide

------------------------
-- Request a redraw on this component; will do nothing if no container is available
-- @function [parent=#xwgcomponent] paint
-- @param #xwgcomponent self self
-- @return #xwgcomponent self for chaining
function component:redraw()
    if self._container ~= nil and self._visible then
        self._container:redraw()
    end -- if container
end -- function redraw

return component