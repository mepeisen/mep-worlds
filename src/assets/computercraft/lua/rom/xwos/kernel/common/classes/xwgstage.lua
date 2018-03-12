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
-- gui component that works on a ccraft terminal window
-- @module xwgstage
-- @extends xwgcontainer#xwgcontainer
local stage = xwgcontainer:new()
local super = xwgcontainer
stage.__index = stage

------------------------
-- the terminal window; do not manipulate directly without care
-- @field [parent=#xwgstage] window#windowObject _window the terminal window

------------------------
-- create new stage
-- @function [parent=#xwgstage] create
-- @param window#window window the terminal window
-- @param ... initial children
-- @return #xwgstage stage
function stage.create(window, ...)
    return stage:new({}, window, ...)
end -- function create

------------------------
-- Creates a new stage
-- @function [parent=#xwgstage] new
-- @param #xwgstage self self
-- @param #table o (optional) object to initialize
-- @param window#window window the terminal window
-- @param ... optional children
-- @return #xwgstage new object
function stage:new(o, window, ...)
    o = xwgcontainer:new(o, ...)
    setmetatable(o, self)
    o._window = window
    return o
end -- function new

-- abstract function to be overridden

-- default implementations

------------------------
-- Returns component width
-- @function [parent=#xwgstage] width
-- @param #xwgstage self self
-- @return #number width
function stage:width()
    local w, h = self._window.getSize()
    return w
end -- function width

------------------------
-- Returns component height
-- @function [parent=#xwgstage] height
-- @param #xwgstage self self
-- @return #number height
function stage:height()
    local w, h = self._window.getSize()
    return h
end -- function height

------------------------
-- Changes components size
-- @function [parent=#xwgstage] setSize
-- @param #xwgstage self self
-- @param #number width
-- @param #number height
-- @return #xwgstage self for chaining

------------------------
-- Returns component x position within parent
-- @function [parent=#xwgstage] x
-- @param #xwgstage self self
-- @return #number x position within parent
function stage:x()
    return self._x
end -- function x

------------------------
-- Returns component x position within parent
-- @function [parent=#xwgstage] y
-- @param #xwgstage self self
-- @return #number y position within parent
function stage:y()
    return self._y
end -- function y

------------------------
-- Changes components position within parent
-- @function [parent=#xwgstage] setPos
-- @param #xwgstage self self
-- @param #number x
-- @param #number y
-- @return #xwgstage self for chaining
function stage:setPos(x, y)
    self._x = x
    self._y = y
    local width, height = self._window.getSize()
    self._window.reposition(x, y, width, height)
    self:redraw()
end -- function setPos

------------------------
-- Redraw this single component; should not be invoked directly without care, instead call redraw on root stage
-- @function [parent=#xwgstage] paint
-- @param #xwgstage self self
-- @return #xwgstage self for chaining
function stage:paint()
    self._window.clear()
    super.paint(self)
end -- function paint

------------------------
-- Paint a string within this stage; do not invoke directly; this is meant to be invoked from components
-- @function [parent=#xwgstage] str
-- @param #xwgstage self self
-- @param #number x the x position of the string
-- @param #number y the y position of the string
-- @param #number fg the foreground color
-- @param #number bg the background color
-- @return #xwgstage self for chaining
function stage:str(x, y, str, fg, bg)
    if self._window ~= nil and self._visible then
        self._window.setCursorPos(x, y)
        self._window.setTextColor(fg)
        self._window.setBackgroundColor(bg)
        self._window.write(str)
    end -- if stage and visible
end -- function str

return stage