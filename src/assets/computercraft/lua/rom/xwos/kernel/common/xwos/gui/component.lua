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
-- @module xwos.gui.component
_CMR.class("xwos.gui.component").abstract()

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
-- component local stylesheet; only contains the styles overridden on this component
-- @field [parent=#xwcprivates] #table _style

-- default stylesheet
.pstat('style', {
    visible = true
})

.ctor(
------------------------
-- @function [parent=#xwcintern] width
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #table styles
function(self, clazz, privates, styles)
  privates._style = styles or {}
end) -- ctor

-- abstract function to be overridden

------------------------
-- Returns component width
-- @function [parent=#xwos.gui.component] width
-- @param #xwos.gui.component self self
-- @return #number width

------------------------
-- Returns component height
-- @function [parent=#xwos.gui.component] height
-- @param #xwos.gui.component self self
-- @return #number height

------------------------
-- Changes components size
-- @function [parent=#xwos.gui.component] setSize
-- @param #xwos.gui.component self self
-- @param #number width
-- @param #number height
-- @return #xwos.gui.component self for chaining

------------------------
-- Returns component x position within parent
-- @function [parent=#xwos.gui.component] x
-- @param #xwos.gui.component self self
-- @return #number x position within parent

------------------------
-- Returns component y position within parent
-- @function [parent=#xwos.gui.component] y
-- @param #xwos.gui.component self self
-- @return #number y position within parent

------------------------
-- Changes components position within parent
-- @function [parent=#xwos.gui.component] setPos
-- @param #xwos.gui.component self self
-- @param #number x
-- @param #number y
-- @return #xwos.gui.component self for chaining

------------------------
-- Redraw this single component; should not be invoked directly without care, instead call redraw on root stage
-- @function [parent=#xwos.gui.component] paint
-- @param #xwos.gui.component self self
-- @return #xwos.gui.component self for chaining

.aFunc("width", "height", "setSize", "x", "y", "setPos", "paint")

-- default implementations

------------------------
-- Returns the style value for given key.
-- Resolves the styles in following order:
-- <ul>
-- <li>Stylesheet from local styles (privates._style); set via constructor or via setStyle/SetStyles methods</li>
-- <li>Default stylesheets from classes; private static "style"</li>
-- <li>Default stylesheets from parent classes; private static "style"</li>
-- </ul>
-- @function [parent=#xwos.gui.component] getStyle
-- @param #xwos.gui.component self self
-- @param #string key
-- @return #any

.func("getStyle",
------------------------
-- @function [parent=#xwcintern] getStyle
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #string key
-- @return #any
function(self, clazz, privates, key)
    local res = privates._style[key]
    if res == nil then
        for k,v in pairs(clazz.getPstat("style")) do
            res = v[key]
            if res ~= nil then
                return res
            end -- if pstat
        end -- for pstat
    end -- if _style
    return res
end) -- function getStyle

------------------------
-- Returns multiple style values for given keys. For more details see method getStyle.
-- @function [parent=#xwos.gui.component] getStyles
-- @param #xwos.gui.component self self
-- @param ... key values to return
-- @return ... style values

.func("getStyles",
------------------------
-- @function [parent=#xwcintern] getStyles
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param ...
-- @return ...
function(self, clazz, privates, ...)
    local res = {}
    for k,v in pairs({...}) do
        table.insert(res, self:getStyle(v))
    end -- for ...
    return unpack(res)
end) -- function getStyles

------------------------
-- Sets style value. Setting a style to nil will force using the default styles.
-- @function [parent=#xwos.gui.component] setStyle
-- @param #xwos.gui.component self self
-- @param #string key
-- @param #any value

.func("setStyle",
------------------------
-- @function [parent=#xwcintern] setStyle
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #string key
-- @param #any value
function(self, clazz, privates, key, value)
    privates._style[key] = value
    self:redraw()
end) -- function getStyle

------------------------
-- Sets style values. Setting a style to nil will force using the default styles.
-- @function [parent=#xwos.gui.component] setStyles
-- @param #xwos.gui.component self self
-- @param #table values

.func("setStyles",
------------------------
-- @function [parent=#xwcintern] setStyles
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #table values
function(self, clazz, privates, values)
    for k,v in pairs(values) do
        privates._style[k] = v
    end -- for values
    self:redraw()
end) -- function setStyles

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
    return self:getStyle("visible")
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
    self:setStyle("visible", true)
    return self
end) -- function show

------------------------
-- hide this component
-- @function [parent=#xwos.gui.component] hide
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
    self:setStyle("visible", false)
    return self
end) -- function hide

------------------------
-- Clears visible style, falling back to defaults
-- @function [parent=#xwos.gui.component] clearVisible
-- @param #xwos.gui.component self self
-- @return #xwos.gui.component self for chaining

.func("clearVisible",
------------------------
-- @function [parent=#xwcintern] clearVisible
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #xwos.gui.component self for chaining
function (self, clazz, privates)
    self:setStyle("visible", nil)
    return self
end) -- function clearVisible

------------------------
-- Request a redraw on this component; will do nothing if no container is available
-- @function [parent=#xwos.gui.component] redraw
-- @param #xwos.gui.component self self
-- @return #xwos.gui.component self for chaining

.func("redraw",
------------------------
-- @function [parent=#xwcintern] redraw
-- @param #xwos.gui.component self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #xwos.gui.component self for chaining
function (self, clazz, privates)
    if self._container ~= nil and self:isVisible() then
        self._container:redraw()
    end -- if container
end) -- function redraw

return nil