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
-- @module xwos.xwgui.text
-- @extends xwos.xwgui.component#xwos.xwgui.component
local text = xwos.xwgui.component:new()
text.__index = text

-- TODO use stylesheets for fg/bg if nil is given

------------------------
-- the text content; do not manipulate directly without care
-- @field [parent=#xwos.xwgui.text] #string _content the content

------------------------
-- the text foreground; do not manipulate directly without care
-- @field [parent=#xwos.xwgui.text] #number _fg the foreground

------------------------
-- the text content; do not manipulate directly without care
-- @field [parent=#xwos.xwgui.text] #number _bg the background

------------------------
-- the x position; do not manipulate directly without care; instead call the setPos method
-- @field [parent=#xwos.xwgui.container] #number _x the x position

------------------------
-- the y position; do not manipulate directly without care; instead call the setPos method
-- @field [parent=#xwos.xwgui.container] #number _y the y position

------------------------
-- create new text
-- @function [parent=#xwos.xwgui.text] create
-- @param #string content the text content
-- @param #number x the x position
-- @param #number y the y position
-- @param #number fg the foreground
-- @param #number bg the background
-- @return #xwos.xwgui.text the text component
function text.create(content, x, y, fg, bg)
    return text:new({}, content, x, y, fg, bg)
end -- function create

------------------------
-- Creates a new text
-- @function [parent=#xwos.xwgui.text] new
-- @param #xwos.xwgui.text self self
-- @param #table o (optional) object to initialize
-- @param #string content the text content
-- @param #number x the x position
-- @param #number y the y position
-- @param #number fg the foreground
-- @param #number bg the background
-- @return #xwos.xwgui.text new object
function text:new(o, content, x, y, fg, bg)
    o = xwos.xwgui.component:new(o)
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
-- @function [parent=#xwos.xwgui.text] width
-- @param #xwos.xwgui.text self self
-- @return #number width
function text:width()
    return string.len(self._content)
end -- function width

------------------------
-- Returns component height
-- @function [parent=#xwos.xwgui.text] height
-- @param #xwos.xwgui.text self self
-- @return #number height
function text:height()
    return 1
end -- function height

------------------------
-- Changes components size
-- @function [parent=#xwos.xwgui.text] setSize
-- @param #xwos.xwgui.text self self
-- @param #number width
-- @param #number height
-- @return #xwos.xwgui.text self for chaining
function text:setSize(width, height)
    -- TODO support for stripped text (lower size than content length) or text filled with spaces (greater size than content length)
    error("method not supported")
end -- function setSize

------------------------
-- Returns component x position within parent
-- @function [parent=#xwos.xwgui.text] x
-- @param #xwos.xwgui.text self self
-- @return #number x position within parent
function text:x()
    return self._x
end -- function x

------------------------
-- Returns component y position within parent
-- @function [parent=#xwos.xwgui.text] y
-- @param #xwos.xwgui.text self self
-- @return #number y position within parent
function text:y()
    return self._y
end -- function y

------------------------
-- Changes components position within parent
-- @function [parent=#xwos.xwgui.text] setPos
-- @param #xwos.xwgui.text self self
-- @param #number x
-- @param #number y
-- @return #xwos.xwgui.text self for chaining
function text:setPos(x, y)
    self._x = x
    self._y = y
    self:redraw()
    return self
end -- function setPos

------------------------
-- Redraw this single component; should not be invoked directly without care, instead call redraw on root stage
-- @function [parent=#xwos.xwgui.text] paint
-- @param #xwos.xwgui.text self self
-- @return #xwos.xwgui.text self for chaining
function text:paint()
    if self._container ~= nil and self._visible then
        self._container:str(self._x, self._y, self._content, self._fg, self._bg)
    end -- if container and visible
    return self
end -- function paint

return text