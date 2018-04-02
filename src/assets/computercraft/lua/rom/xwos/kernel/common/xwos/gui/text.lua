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
-- gui component holding a static, colored text
-- @type xwos.gui.text
-- @extends xwos.gui.component#xwos.gui.component
_CMR.class("xwos.gui.text").extends("xwos.gui.component")

------------------------
-- the object privates
-- @type xwcprivates
-- @extends xwos.gui.component#xwcprivates

------------------------
-- the internal class
-- @type xwcintern
-- @extends #xwos.gui.text

-- default stylesheet
.pstat('style', {
    x = 0,
    y = 0,
    fg = colors.white,
    bg = colors.black
})

------------------------
-- the text content; do not manipulate directly without care
-- @field [parent=#xwcprivates] #string _content 

.ctor(
------------------------
-- @function [parent=#xwcintern] ctor
-- @param #xwos.gui.text self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #string text
-- @param #table styles
function(self, clazz, privates, text, styles)
    clazz.super(styles)
    privates._content = text or ""
end) -- ctor

.sfunc("create",
------------------------
-- create new text
-- @function [parent=#xwos.gui.text] create
-- @param #string content the text content
-- @param #table styles
-- @return #xwos.gui.text the text component
function (content, styles)
    return _CMR.new("xwos.gui.text", content, styles)
end) -- function create

-- abstract function to be overridden

-- default implementations

------------------------
-- Returns component width
-- @function [parent=#xwos.gui.text] width
-- @param #xwos.gui.text self self
-- @return #number width

.func("width",
------------------------
-- @function [parent=#xwcintern] width
-- @param #xwos.gui.text self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    -- TODO styles
    return string.len(privates._content)
end) -- function width

------------------------
-- Returns component height
-- @function [parent=#xwos.gui.text] height
-- @param #xwos.gui.text self self
-- @return #number height

.func("height",
------------------------
-- @function [parent=#xwcintern] height
-- @param #xwos.gui.text self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    -- TODO styles
    return 1
end) -- function height

------------------------
-- Changes components size
-- @function [parent=#xwos.gui.text] setSize
-- @param #xwos.gui.text self self
-- @param #number width
-- @param #number height
-- @return #xwos.gui.text self for chaining

.func("setSize",
------------------------
-- @function [parent=#xwcintern] setSize
-- @param #xwos.gui.text self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number width
-- @param #number height
-- @return #xwos.gui.text
function (self, clazz, privates, width, height)
    -- TODO support for stripped text (lower size than content length) or text filled with spaces (greater size than content length)
    error("method not supported")
end) -- function setSize

------------------------
-- Returns component x position within parent
-- @function [parent=#xwos.gui.text] x
-- @param #xwos.gui.text self self
-- @return #number x position within parent

.func("x",
------------------------
-- @function [parent=#xwcintern] x
-- @param #xwos.gui.text self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return self:getStyle("x")
end) -- function x

------------------------
-- Returns component y position within parent
-- @function [parent=#xwos.gui.text] y
-- @param #xwos.gui.text self self
-- @return #number y position within parent

.func("y",
------------------------
-- @function [parent=#xwcintern] y
-- @param #xwos.gui.text self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return self:getStyle("y")
end) -- function y

------------------------
-- Changes components position within parent
-- @function [parent=#xwos.gui.text] setPos
-- @param #xwos.gui.text self self
-- @param #number x
-- @param #number y
-- @return #xwos.gui.text self for chaining

.func("setPos",
------------------------
-- @function [parent=#xwcintern] setPos
-- @param #xwos.gui.text self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number x
-- @param #number y
-- @return #xwos.gui.text
function (self, clazz, privates, x, y)
    self:setStyles({x = x, y = y})
    return self
end) -- function setPos

------------------------
-- Redraw this single component; should not be invoked directly without care, instead call redraw
-- @function [parent=#xwos.gui.text] paint
-- @param #xwos.gui.text self self
-- @return #xwos.gui.text self for chaining

.func("paint",
------------------------
-- @function [parent=#xwcintern] setPos
-- @param #xwos.gui.text self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #xwos.gui.text
function (self, clazz, privates)
    if self._container ~= nil and self:isVisible() then
        self._container:str(self:x(), self:y(), privates._content, self:getStyle("fg"), self:getStyle("bg"))
    end -- if container and visible
    return self
end) -- function paint

-- TODO get/set for content, events (change content/fg/bg)

return nil