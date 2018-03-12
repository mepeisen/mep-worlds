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
-- gui component holding a static text
-- @module xwgtext
-- @extends xwgcomponent#xwgcomponent
local text = xwgcomponent:new()
text.__index = text

-- TODO use stylesheets for fg/bg if nil is given

------------------------
-- the text content; do not manipulate directly without care
-- @field [parent=#xwgtext] #string _content the content

------------------------
-- the text foreground; do not manipulate directly without care
-- @field [parent=#xwgtext] #number _fg the foreground

------------------------
-- the text content; do not manipulate directly without care
-- @field [parent=#xwgtext] #number _bg the background

------------------------
-- the x position; do not manipulate directly without care; instead call the setPos method
-- @field [parent=#xwgcontainer] #number _x the x position

------------------------
-- the y position; do not manipulate directly without care; instead call the setPos method
-- @field [parent=#xwgcontainer] #number _y the y position

------------------------
-- create new text
-- @function [parent=#xwgtext] create
-- @param #string content the text content
-- @param #number x the x position
-- @param #number y the y position
-- @param #number fg the foreground
-- @param #number bg the background
-- @return #xwgtext the text component
function text.create(content, x, y, fg, bg)
    return text:new({}, content, x, y, fg, bg)
end -- function create

------------------------
-- Creates a new text
-- @function [parent=#xwgtext] new
-- @param #xwgtext self self
-- @param #table o (optional) object to initialize
-- @param #string content the text content
-- @param #number x the x position
-- @param #number y the y position
-- @param #number fg the foreground
-- @param #number bg the background
-- @return #xwgtext new object
function text:new(o, content, x, y, fg, bg)
    o = xwgcomponent:new(o)
    setmetatable(o, self)
    o._content = content
    o._fg = fg
    o._bg = bg
    o._x = x
    o._y = y
    return o
end -- function new

-- abstract function to be overridden

-- default implementations

------------------------
-- Returns component width
-- @function [parent=#xwgtext] width
-- @param #xwgtext self self
-- @return #number width
function text:width()
    return string.len(self._content)
end -- function width

------------------------
-- Returns component height
-- @function [parent=#xwgtext] height
-- @param #xwgtext self self
-- @return #number height
function text:height()
    return 1
end -- function height

------------------------
-- Changes components size
-- @function [parent=#xwgtext] setSize
-- @param #xwgtext self self
-- @param #number width
-- @param #number height
-- @return #xwgtext self for chaining
function text:setSize(width, height)
    -- TODO support for stripped text (lower size than content length) or text filled with spaces (greater size than content length)
    error("method not supported")
end -- function setSize

------------------------
-- Returns component x position within parent
-- @function [parent=#xwgtext] x
-- @param #xwgtext self self
-- @return #number x position within parent
function text:x()
    return self._x
end -- function x

------------------------
-- Returns component y position within parent
-- @function [parent=#xwgtext] y
-- @param #xwgtext self self
-- @return #number y position within parent
function text:y()
    return self._y
end -- function y

------------------------
-- Changes components position within parent
-- @function [parent=#xwgtext] setPos
-- @param #xwgtext self self
-- @param #number x
-- @param #number y
-- @return #xwgtext self for chaining
function text:setPos(x, y)
    self._x = x
    self._y = y
    self:redraw()
    return self
end -- function setPos

------------------------
-- Redraw this single component; should not be invoked directly without care, instead call redraw on root stage
-- @function [parent=#xwgtext] paint
-- @param #xwgtext self self
-- @return #xwgtext self for chaining
function text:paint()
    if self._container ~= nil and self._visible then
        self._container:str(self._x, self._y, self._content, self._fg, self._bg)
    end -- if container and visible
    return self
end -- function paint

return text