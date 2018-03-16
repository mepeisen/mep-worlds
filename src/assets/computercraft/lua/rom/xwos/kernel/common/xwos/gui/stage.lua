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
-- gui component that works on a ccraft terminal window
-- @type xwos.gui.stage
-- @extends xwos.gui.container#xwos.gui.container
_CMR.class("xwos.gui.stage").extends("xwos.gui.container")

------------------------
-- the object privates
-- @type xwcprivates
-- @extends xwos.gui.container#xwcprivates

------------------------
-- the internal class
-- @type xwcintern
-- @extends #xwos.gui.container

------------------------
-- the terminal window; do not manipulate directly without care
-- @field [parent=#xwcprivates] window#windowObject _window the terminal window

------------------------
-- the width; do not manipulate directly without care; instead call the setSize method
-- @field [parent=#xwcprivates] #number _width

------------------------
-- the height; do not manipulate directly without care; instead call the setSize method
-- @field [parent=#xwcprivates] #number _height

-- TODO fetch window resize events to update inner height/width variables and to redraw 

.ctor(
------------------------
-- @function [parent=#xwcintern] ctor
-- @param #xwos.gui.text self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param window#windowObject window; if numeric, it is interpreted as x coordinate within parent container
-- @param #number y the y coordinate within parent container; if window object is given it is interpreted as a child object
-- @param #number width the width within parent container; if window object is given it is interpreted as a child object
-- @param #number height the height within parent container; if window object is given it is interpreted as a child object
function(self, clazz, privates, window, y, width, height, ...)
    if type(window) == "number" then
        privates._x = window
        privates._y = y or 0
        privates._width = width or 0
        privates._height = height or 0
        clazz._superctor(self, privates, ...)
    else -- if number
        privates._window = window
        clazz._superctor(self, privates, y, width, height, ...)
    end -- if number
end) -- ctor

.sfunc("create",
------------------------
-- create new stage
-- @function [parent=#xwos.gui.stage] create
-- @param window#windowObject window; if numeric, it is interpreted as x coordinate within parent container
-- @param #number y the y coordinate within parent container; if window object is given it is interpreted as a child object
-- @param #number width the width within parent container; if window object is given it is interpreted as a child object
-- @param #number height the height within parent container; if window object is given it is interpreted as a child object
-- @param ...
-- @return #xwos.gui.stage
function (...)
    return _CMR.new("xwos.gui.stage", ...)
end) -- function create

-- abstract function to be overridden

-- default implementations

------------------------
-- Returns component width
-- @function [parent=#xwos.gui.stage] width
-- @param #xwos.gui.stage self self
-- @return #number width

.func("width",
------------------------
-- @function [parent=#xwcintern] width
-- @param #xwos.gui.stage self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return privates._width
end) -- function width

------------------------
-- Returns component height
-- @function [parent=#xwos.gui.stage] height
-- @param #xwos.gui.stage self self
-- @return #number height

.func("height",
------------------------
-- @function [parent=#xwcintern] height
-- @param #xwos.gui.stage self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return privates._height
end) -- function height

------------------------
-- Changes components size
-- @function [parent=#xwos.gui.stage] setSize
-- @param #xwos.gui.stage self self
-- @param #number width
-- @param #number height
-- @return #xwos.gui.stage self for chaining

.func("setSize",
------------------------
-- @function [parent=#xwcintern] setSize
-- @param #xwos.gui.stage self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number width
-- @param #number height
-- @return #xwos.gui.stage
function (self, clazz, privates, width, height)
    privates._width = width
    privates._height = height
    
    -- TODO duplicate code (setPos)
    
    -- generate on demand
    if privates._window == nil then
        if privates._container ~= nil then
            privates._window = privates._container:crwin(privates._x, privates._y, privates._width, privates._height)
            return -- is already has the correct position and size
        else
            return -- we have nothing to do yet; resize without known terminal
        end -- if container
    end -- if not window
    
    -- resize
    if privates._container ~= nil then
        privates._container:movewin(privates._x, privates._y, privates._width, privates._height, privates._window)
    else
        privates._window.reposition(privates._x, privates._y, width, height)
    end -- if container
    self:redraw()
end) -- function setSize

------------------------
-- Returns component x position within parent
-- @function [parent=#xwos.gui.stage] x
-- @param #xwos.gui.stage self self
-- @return #number x position within parent

.func("x",
------------------------
-- @function [parent=#xwcintern] x
-- @param #xwos.gui.stage self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return privates._x
end) -- function x

------------------------
-- Returns component x position within parent
-- @function [parent=#xwos.gui.stage] y
-- @param #xwos.gui.stage self self
-- @return #number y position within parent

.func("y",
------------------------
-- @function [parent=#xwcintern] height
-- @param #xwos.gui.stage self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return privates._y
end) -- function y

------------------------
-- Changes components position within parent
-- @function [parent=#xwos.gui.stage] setPos
-- @param #xwos.gui.stage self self
-- @param #number x
-- @param #number y
-- @return #xwos.gui.stage self for chaining

.func("setPos",
------------------------
-- @function [parent=#xwcintern] setPos
-- @param #xwos.gui.stage self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number x
-- @param #number y
-- @return #xwos.gui.stage
function (self, clazz, privates, x, y)
    privates._x = x
    privates._y = y
    
    -- generate on demand
    if privates._window == nil then
        if privates._container ~= nil then
            privates._window = privates._container:crwin(privates._x, privates._y, privates._width, privates._height)
            return -- is already has the correct position and size
        else
            return -- we have nothing to do yet; resize without known terminal
        end -- if container
    end -- if not window
    
    -- resize
    if privates._container ~= nil then
        privates._container:movewin(privates._x, privates._y, privates._width, privates._height, privates._window)
    else
        privates._window.reposition(privates._x, privates._y, width, height)
    end -- if container
    self:redraw()
end) -- function setPos

------------------------
-- Request a redraw on this component; will do nothing if no container is available
-- @function [parent=#xwos.gui.stage] redraw
-- @param #xwos.gui.stage self self
-- @return #xwos.gui.stage self for chaining

.func("redraw",
------------------------
-- @function [parent=#xwcintern] redraw
-- @param #xwos.gui.stage self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #xwos.gui.stage self for chaining
function (self, clazz, privates)
    if privates._visible then
        -- generate on demand TODO: Duplicate code
        if privates._window == nil then
            if privates._container ~= nil then
                privates._window = privates._container:crwin(privates._x, privates._y, privates._width, privates._height)
            else
                return -- we have nothing to do yet
            end -- if container
        end -- if not window
    
        if self._container ~= nil then
            self._container:redraw()
        else
            self:paint()
        end -- if container
    end -- if visible
end) -- function redraw

------------------------
-- Redraw this single component; should not be invoked directly without care, instead call redraw on root stage
-- @function [parent=#xwos.gui.stage] paint
-- @param #xwos.gui.stage self self
-- @return #xwos.gui.stage self for chaining

.func("paint",
------------------------
-- @function [parent=#xwcintern] paint
-- @param #xwos.gui.stage self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #xwos.gui.stage
function (self, clazz, privates)
    -- generate on demand TODO: Duplicate code
    if privates._window == nil then
        if privates._container ~= nil then
            privates._window = privates._container:crwin(privates._x, privates._y, privates._width, privates._height)
        else
            return -- we have nothing to do yet
        end -- if container
    end -- if not window
        
    privates._window.clear()
    clazz._super._funcs.paint(self, clazz, privates)
end) -- function paint

------------------------
-- Paint a string within this stage; do not invoke directly; this is meant to be invoked from components
-- @function [parent=#xwos.gui.stage] str
-- @param #xwos.gui.stage self self
-- @param #number x the x position of the string
-- @param #number y the y position of the string
-- @param #string str the string to paint
-- @param #number fg the foreground color
-- @param #number bg the background color
-- @return #xwos.gui.stage self for chaining

.func("str",
------------------------
-- @function [parent=#xwcintern] str
-- @param #xwos.gui.stage self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number x
-- @param #number y
-- @param #string str
-- @param #number fg
-- @param #number bg
-- @return #xwos.gui.stage
function (self, clazz, privates, x, y, str, fg, bg)
    -- generate on demand TODO: Duplicate code
    if privates._window == nil then
        if privates._container ~= nil then
            privates._window = privates._container:crwin(privates._x, privates._y, privates._width, privates._height)
        else
            return -- we have nothing to do yet
        end -- if container
    end -- if not window
    
    if privates._visible then
        privates._window.setCursorPos(x, y)
        privates._window.setTextColor(fg)
        privates._window.setBackgroundColor(bg)
        privates._window.write(str)
    end -- if stage and visible
end) -- function str

------------------------
-- Acquire a new windowObject from parent terminal
-- @function [parent=#xwos.gui.stage] crwin
-- @param #xwos.gui.stage self self
-- @param #number x the x position of the window
-- @param #number y the y position of the window
-- @param #number width the width of the window
-- @param #number height the height of the window
-- @return window#windowObject the new window object; maybe nil if parent is not yet known

.func("crwin",
------------------------
-- @function [parent=#xwcintern] crwin
-- @param #xwos.gui.stage self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number x
-- @param #number y
-- @param #number width
-- @param #number height
-- @return window#windowObject
function (self, clazz, privates, x, y, width, height)
    -- generate on demand TODO: Duplicate code
    if privates._window == nil then
        if privates._container ~= nil then
            privates._window = privates._container:crwin(privates._x, privates._y, privates._width, privates._height)
        else
            return -- we have nothing to do yet
        end -- if container
    end -- if not window
    
    return window.create(privates._term, x + privates._x, y + privates._y, width, height, true)
end) -- function crwin

------------------------
-- Move an existing windowObject in parent terminal
-- @function [parent=#xwos.gui.stage] movewin
-- @param #xwos.gui.stage self self
-- @param #number x the new x position of the window
-- @param #number y the new y position of the window
-- @param #number width
-- @param #number height
-- @param window#windowObject win the existing window object

.func("movewin",
------------------------
-- @function [parent=#xwcintern] movewin
-- @param #xwos.gui.stage self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number x
-- @param #number y
-- @param #number width
-- @param #number height
-- @param window#windowObject win
function (self, clazz, privates, x, y, width, height, win)
    win.reposition(x, y, width, height)
end) -- function movewin

return nil