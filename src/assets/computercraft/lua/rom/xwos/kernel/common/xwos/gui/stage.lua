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

.ctor(
------------------------
-- @function [parent=#xwcintern] ctor
-- @param #xwos.gui.text self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param window#windowObject window
function(self, clazz, privates, window, ...)
    privates._window = window
    clazz._superctor(self, privates, ...)
end) -- ctor

.sfunc("create",
------------------------
-- create new stage
-- @function [parent=#xwos.gui.stage] create
-- @param window#windowObject window
function (window, ...)
    return _CMR.new("xwos.gui.stage", window, ...)
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
    local w, h = privates._window.getSize()
    return w
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
    local w, h = self._window.getSize()
    return h
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
    privates._window.reposition(privates._x, privates._y, width, height)
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
    local width, height = privates._window.getSize()
    privates._window.reposition(x, y, width, height)
    privates:redraw()
end) -- function setPos

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
-- @function [parent=#xwcintern] paint
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
    if privates._window ~= nil and privates._visible then
        privates._window.setCursorPos(x, y)
        privates._window.setTextColor(fg)
        privates._window.setBackgroundColor(bg)
        privates._window.write(str)
    end -- if stage and visible
end) -- function str

return nil