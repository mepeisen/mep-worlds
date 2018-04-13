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

_CMR.load("xwos.gui.frame")

--------------------------------
-- gui component displaying a frame
-- @module xwos.gui.frame
-- @extends xwos.gui.component#xwos.gui.component
_CMR.class("xwos.gui.frame").extends("xwos.gui.component")

------------------------
-- the object privates
-- @type xwcprivates
-- @extends xwos.gui.component#xwcprivates

------------------------
-- the internal class
-- @type xwcintern
-- @extends #xwos.gui.frame

-- default stylesheet
.pstat('style', {
    x = 0,
    y = 0,
    width = 2,
    height = 3,
    ffg = colors.lightGray,
    fbg = colors.black,
    bbg = colors.black,
    tl = "\156",
    t = "\140",
    tr = "\148",
    l = "\149",
    r = "\149",
    bl = "\141",
    b = "\140",
    br = "\133",
    m = " "
})

------------------------
-- the text for top frame line
-- @field [parent=#xwcprivates] #string _top

------------------------
-- the text for bottom frame line
-- @field [parent=#xwcprivates] #string _bottom

------------------------
-- the text for mid frame line
-- @field [parent=#xwcprivates] #string _mid

------------------------
-- the window object to draw the frame
-- @field [parent=#xwcprivates] window#windowObject _frame

------------------------
-- the window object to draw the content
-- @field [parent=#xwcprivates] xwos.gui.stage#xwos.gui.stage _content

-- TODO layout for maximum sized frames (use whole terminal), some layout constraints

-- TODO support other styles (request ccraft utf support):
-- ┌─┐  ┍━┑  ┎─┒  ┏━┓    (normal, bold)
-- │ │  │ │  ┃ ┃  ┃ ┃
-- └─┘  ┕━┙  ┖─┚  ┗━┛
--
-- ┌╌┐  ┍╍┑  ┎╌┒  ┏╍┓    (double dashed)
-- ╎ ╎  ╎ ╎  ╏ ╏  ╏ ╏
-- └╌┘  ┕╍┙  ┖╌┚  ┗╍┛
-- 
-- ┌┄┐  ┍┅┑  ┎┄┒  ┏┅┓    (triple dashed)
-- ┆ ┆  ┆ ┆  ┇ ┇  ┇ ┇
-- └┄┘  ┕┅┙  ┖┄┚  ┗┅┛
--
-- ┌┈┐  ┍┉┑  ┎┈┒  ┏┉┓    (quadruple dashed)
-- ┊ ┊  ┊ ┊  ┋ ┋  ┋ ┋
-- └┈┘  ┕┉┙  ┖┈┚  ┗┉┛
-- 
-- ╔═╗  ╓─╖  ╒═╕         (double line)
-- ║ ║  ║ ║  │ │  
-- ╚═╝  ╙─╜  ╘═╛  
-- 
-- ╭─╮                   (rounded)
-- │ │                
-- ╰─╯                
--
-- http://www.utf8-chartable.de/unicode-utf8-table.pl?start=9472&unicodeinhtml=dec

.ctor(
------------------------
-- @function [parent=#xwcintern] ctor
-- @param #xwos.gui.frame self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #table styles
-- @param ... initial objects
function(self, clazz, privates, styles, ...)
    clazz.super(styles)
    
    privates._content = _CMR.new(
        "xwos.gui.stage",
        nil, {
            x = self:x() + 1,
            y = self:y() + 1,
            width = self:width() - 2,
            height = self:height() - 2,
            background = self:getStyle("bbg")
        }
        , ...)
    privates._content._container = self
    privates._top = string.rep(self:getStyle("t"), self:width() - 2, "")
    privates._bottom = string.rep(self:getStyle("b"), self:width() - 2, "")
    privates._mid = string.rep(self:getStyle("m"), self:width() - 2, "")
end) -- ctor

.sfunc("create",
------------------------
-- create new text
-- @function [parent=#xwos.gui.frame] create
-- @param #table styles
-- @param ... initial objects
-- @return #xwos.gui.frame the frame object
function (styles, ...)
    return _CMR.new("xwos.gui.frame", styles, ...)
end) -- function create

-- abstract function to be overridden

-- default implementations

------------------------
-- Returns component width
-- @function [parent=#xwos.gui.frame] width
-- @param #xwos.gui.frame self self
-- @return #number width

.func("width",
------------------------
-- @function [parent=#xwcintern] width
-- @param #xwos.gui.frame self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return self:getStyle("width")
end) -- function width

------------------------
-- Returns component height
-- @function [parent=#xwos.gui.frame] height
-- @param #xwos.gui.frame self self
-- @return #number height

.func("height",
------------------------
-- @function [parent=#xwcintern] height
-- @param #xwos.gui.frame self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return self:getStyle("height")
end) -- function height

------------------------
-- Changes components size
-- @function [parent=#xwos.gui.frame] setSize
-- @param #xwos.gui.frame self self
-- @param #number width
-- @param #number height
-- @return #xwos.gui.frame self for chaining

.func("setSize",
------------------------
-- @function [parent=#xwcintern] setSize
-- @param #xwos.gui.frame self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number width
-- @param #number height
-- @return #xwos.gui.frame
function (self, clazz, privates, width, height)
    self:setStyles({ width = width, height = height})
    privates._content:setSize(width - 2, height - 2) -- invokes redraw
    return self
end) -- function setSize

------------------------
-- Returns component x position within parent
-- @function [parent=#xwos.gui.frame] x
-- @param #xwos.gui.frame self self
-- @return #number x position within parent

.func("x",
------------------------
-- @function [parent=#xwcintern] x
-- @param #xwos.gui.frame self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return self:getStyle("x")
end) -- function x

------------------------
-- Returns component y position within parent
-- @function [parent=#xwos.gui.frame] y
-- @param #xwos.gui.frame self self
-- @return #number y position within parent

.func("y",
------------------------
-- @function [parent=#xwcintern] y
-- @param #xwos.gui.frame self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #number
function (self, clazz, privates)
    return self:getStyle("y")
end) -- function y

------------------------
-- Changes components position within parent
-- @function [parent=#xwos.gui.frame] setPos
-- @param #xwos.gui.frame self self
-- @param #number x
-- @param #number y
-- @return #xwos.gui.frame self for chaining

.func("setPos",
------------------------
-- @function [parent=#xwcintern] setPos
-- @param #xwos.gui.frame self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number x
-- @param #number y
-- @return #xwos.gui.frame
function (self, clazz, privates, x, y)
    self:setStyles({ x = x, y = y})
    privates._content:setPos(x + 1, y + 1) -- invokes redraw...
    return self
end) -- function setPos

------------------------
-- Redraw this single component; should not be invoked directly without care, instead call redraw
-- @function [parent=#xwos.gui.frame] paint
-- @param #xwos.gui.frame self self
-- @return #xwos.gui.frame self for chaining

.func("paint",
------------------------
-- @function [parent=#xwcintern] paint
-- @param #xwos.gui.frame self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @return #xwos.gui.frame
function (self, clazz, privates)
    if self:container() ~= nil and self:isVisible() then
        self:container():str(self:x(), self:y(), self:getStyle("tl"), self:getStyle("ffg"), self:getStyle("fbg"))
        self:container():str(self:x() + 1, self:y(), privates._top, self:getStyle("ffg"), self:getStyle("fbg"))
        self:container():str(self:x() + self:width() - 1, self:y(), self:getStyle("tr"), self:getStyle("ffg"), self:getStyle("fbg"))
        for i=1, self:height() - 1, 1 do
            self:container():str(self:x(), self:y() + i, privates._l, self:getStyle("ffg"), self:getStyle("fbg"))
            self:container():str(self:x() + 1, self:y() + i, privates._mid, colors.black, self:getStyle("bbg"))
            self:container():str(self:x() + self:width() - 1, self:y() + i, self:getStyle("r"), self:getStyle("ffg"), self:getStyle("fbg"))
        end -- for height
        self:container():str(self:x(), self:y() + self:height() - 1, self:getStyle("bl"), self:getStyle("ffg"), self:getStyle("fbg"))
        self:container():str(self:x() + 1, self:y() + self:height() - 1, privates._bottom, self:getStyle("ffg"), self:getStyle("fbg"))
        self:container():str(self:x() + self:width() - 1, self:y() + self:height() - 1, self:getStyle("br"), self:getStyle("ffg"), self:getStyle("fbg"))
        privates._content:paint()
    end -- if container and visible
    return self
end) -- function paint

------------------------
-- add new entry to list end
-- @function [parent=#xwos.gui.frame] push
-- @param #xwos.gui.frame self self
-- @param xwos.gui.component#xwos.gui.component t object to push
-- @return xwos.gui.component#xwos.gui.component given object (t)

------------------------
-- add new entry to list beginning
-- @function [parent=#xwos.gui.frame] unshift
-- @param #xwos.gui.frame self self
-- @param xwos.gui.component#xwos.gui.component t object to unshift
-- @return xwos.gui.component#xwos.gui.component given object (t)

------------------------
-- insert a new entry after an element
-- @function [parent=#xwos.gui.frame] insert
-- @param #xwos.gui.frame self self
-- @param xwos.gui.component#xwos.gui.component t new entry
-- @param xwos.gui.component#xwos.gui.component after element before new entry
-- @return xwos.gui.component#xwos.gui.component given object (t)

------------------------
-- pop element from end
-- @function [parent=#xwos.gui.frame] pop
-- @param #xwos.gui.frame self self
-- @return xwos.gui.component#xwos.gui.component entry

------------------------
-- pop element from beginning
-- @function [parent=#xwos.gui.frame] shift
-- @param #xwos.gui.frame self self
-- @return xwos.gui.component#xwos.gui.component entry

------------------------
-- remove given element from list
-- @function [parent=#xwos.gui.frame] remove
-- @param #xwos.gui.frame self self
-- @param xwos.gui.component#xwos.gui.component t element to remove
-- @return xwos.gui.component#xwos.gui.component given object (t)

.delegate("_content", "push", "unshift", "insert", "pop", "shift", "remove")

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
    if self:container() ~= nil and self:isVisible() then
        self:container():str(x + self:x(), y + self:y(), str, fg, bg)
    end -- if container and visible
    return self
end) -- function str

------------------------
-- Acquire a new windowObject from parent terminal
-- @function [parent=#xwos.gui.frame] crwin
-- @param #xwos.gui.frame self self
-- @param #number x the x position of the window
-- @param #number y the y position of the window
-- @param #number width the width of the window
-- @param #number height the height of the window
-- @return window#windowObject the new window object; maybe nil if parent is not yet known

.func("crwin",
------------------------
-- @function [parent=#xwcintern] crwin
-- @param #xwos.gui.frame self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number x
-- @param #number y
-- @param #number width
-- @param #number height
-- @return window#windowObject
function (self, clazz, privates, x, y, width, height)
    if self:container() ~= nil then
        return self:container():crwin(x + self:x(), y + self:y(), width, height)
    end -- if container
end) -- function crwin

------------------------
-- Move an existing windowObject in parent terminal
-- @function [parent=#xwos.gui.frame] movewin
-- @param #xwos.gui.frame self self
-- @param #number x the new x position of the window
-- @param #number y the new y position of the window
-- @param #number width the new width
-- @param #number height the new height
-- @param window#windowObject win the existing window object

.func("movewin",
------------------------
-- @function [parent=#xwcintern] movewin
-- @param #xwos.gui.frame self
-- @param classmanager#clazz clazz
-- @param #xwcprivates privates
-- @param #number x
-- @param #number y
-- @param #number width
-- @param #number height
-- @param window#windowObject win
function (self, clazz, privates, x, y, width, height, win)
    if self:container() ~= nil then
        self:container():movewin(x + self:x(), y + self:y(), width, height, win)
    end -- if container
end) -- function movewin

-- TODO events (changed colors etc.)

return nil