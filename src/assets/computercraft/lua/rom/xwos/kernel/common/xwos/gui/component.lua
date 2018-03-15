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
-- gui component base class
-- @type xwos.gui.component
_CMR.class("xwos.gui.component") -- TODO abstract flag and abstract function support

------------------------
-- the object privates
-- @type xwcprivates

------------------------
-- the internal class
-- @type xwcintern
-- @extends #xwos.gui.component

------------------------
-- owning container
-- @field [parent=#xwcprivates] xwos.gui.container#xwos.gui.container _container

------------------------
-- visible flag; do not change manually, instead invoke show() or hide()
-- @field [parent=#xwcprivates] #boolean _visible

.ctor(
------------------------
-- @function [parent=#xwcintern] width
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
function(self, clazz, privates)
  privates._visible = true
end) -- ctor

-- abstract function to be overridden

------------------------
-- Returns component width
-- @function [parent=#xwos.gui.component] width
-- @param #xwos.gui.component self self
-- @return #number width

.func("width",
------------------------
-- @function [parent=#xwcintern] width
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    error("method not supported")
end) -- function width

------------------------
-- Returns component height
-- @function [parent=#xwos.gui.component] height
-- @param #xwos.gui.component self self
-- @return #number height

.func("height",
------------------------
-- @function [parent=#xwcintern] height
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    error("method not supported")
end) -- function height

------------------------
-- Changes components size
-- @function [parent=#xwos.gui.component] setSize
-- @param #xwos.gui.component self self
-- @param #number width
-- @param #number height
-- @return #xwos.gui.component self for chaining

.func("setSize",
------------------------
-- @function [parent=#xwcintern] setSize
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number width
-- @param #number height
-- @return #xwos.gui.component self for chaining
function (self, clazz, privates, width, height)
    error("method not supported")
end) -- function setSize

------------------------
-- Returns component x position within parent
-- @function [parent=#xwos.gui.component] x
-- @param #xwos.gui.component self self
-- @return #number x position within parent

.func("x",
------------------------
-- @function [parent=#xwcintern] x
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    error("method not supported")
end) -- function x

------------------------
-- Returns component y position within parent
-- @function [parent=#xwos.gui.component] y
-- @param #xwos.gui.component self self
-- @return #number y position within parent

.func("y",
------------------------
-- @function [parent=#xwcintern] y
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    error("method not supported")
end) -- function y

------------------------
-- Changes components position within parent
-- @function [parent=#xwos.gui.component] setPos
-- @param #xwos.gui.component self self
-- @param #number x
-- @param #number y
-- @return #xwos.gui.component self for chaining

.func("setPos",
------------------------
-- @function [parent=#xwcintern] setPos
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number x
-- @param #number y
-- @return #xwos.gui.component self for chaining
function (self, clazz, privates, x, y)
    error("method not supported")
end) -- function setPos

------------------------
-- Redraw this single component; should not be invoked directly without care, instead call redraw on root stage
-- @function [parent=#xwos.gui.component] paint
-- @param #xwos.gui.component self self
-- @return #xwos.gui.component self for chaining

.func("paint",
------------------------
-- @function [parent=#xwcintern] paint
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #xwos.gui.component self for chaining
function (self, clazz, privates)
    error("method not supported")
end) -- function paint

-- default implementations

------------------------
-- Returns the visible flag
-- @function [parent=#xwos.gui.component] isVisible
-- @param #xwos.gui.component self self
-- @return #boolean

.func("isVisible",
------------------------
-- @function [parent=#xwcintern] isVisible
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #boolean
function (self, clazz, privates)
    return privates._visible
end) -- function isVisible

------------------------
-- Returns component size
-- @function [parent=#xwos.gui.component] size
-- @param #xwos.gui.component self self
-- @return #number size (width, height)

.func("size",
------------------------
-- @function [parent=#xwcintern] size
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return self:width(), self:height()
end) -- function size

------------------------
-- Returns component position within parent
-- @function [parent=#xwos.gui.component] pos
-- @param #xwos.gui.component self self
-- @return #number position (x, y)

.func("pos",
------------------------
-- @function [parent=#xwcintern] pos
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return self:x(), self:y()
end) -- function pos

------------------------
-- show this component
-- @function [parent=#xwos.gui.component] show
-- @param #xwos.gui.component self self
-- @return #xwos.gui.component self for chaining

.func("show",
------------------------
-- @function [parent=#xwcintern] show
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #xwos.gui.component self for chaining
function (self, clazz, privates)
    if not privates._visible then
        privates._visible = true
        self:redraw()
    end -- if not visible
    return self
end) -- function show

------------------------
-- hide this component
-- @function [parent=#xwos.gui.component] show
-- @param #xwos.gui.component self self
-- @return #xwos.gui.component self for chaining

.func("hide",
------------------------
-- @function [parent=#xwcintern] hide
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #xwos.gui.component self for chaining
function (self, clazz, privates)
    if privates._visible then
        privates._visible = false
        self:redraw()
    end -- if visible
    return self
end) -- function hide

------------------------
-- Request a redraw on this component; will do nothing if no container is available
-- @function [parent=#xwos.gui.component] paint
-- @param #xwos.gui.component self self
-- @return #xwos.gui.component self for chaining

.func("redraw",
------------------------
-- @function [parent=#xwcintern] paint
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #xwos.gui.component self for chaining
function (self, clazz, privates)
    if self._container ~= nil and privates._visible then
        self._container:redraw()
    end -- if container
end) -- function redraw

return nil