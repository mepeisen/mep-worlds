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
-- gui manager
-- @type xwos.gui
_CMR.class("xwos.gui")

------------------------
-- the object privates
-- @type xwguiprivates

------------------------
-- the internal class
-- @type xwguiintern
-- @extends #xwos.gui 

------------------------
-- create new gui
-- @function [parent=#xwos.gui] create
-- @param term#term the terminal window used for output
-- @return #xwos.gui the new gui
.sfunc("create", function(term)
    return _CMR.new("xwos.gui", term)
end) -- function create

.ctor(
------------------------
-- create new gui
-- @function [parent=#xwguiintern] __ctor
-- @param #xwos.gui self self
-- @param classmanager#clazz clazz gui class
-- @param #xwguiprivates privates
-- @param term#term term the underlying terminal
function (self, clazz, privates, term)
    ----------------
    -- the underlying terminal
    -- @field [parent=#xwguiprivates] term#term term
    privates.term = term
end) -- ctor

------------------------
-- returns the terminal size
-- @function [parent=#xwos.gui] size
-- @param #xwos.gui self self
-- @return #number width, height

.func("size",
------------------------
-- @function [parent=#xwguiintern] size
-- @param #xwos.gui self
-- @param classmanager#clazz clazz
-- @param #xwguiprivates privates
-- @return #number
function (self, clazz, privates)
    return privates.term.getSize()
end) -- function size

------------------------
-- returns the terminal width
-- @function [parent=#xwos.gui] width
-- @param #xwos.gui self self
-- @return #number width

.func("width",
------------------------
-- @function [parent=#xwguiintern] width
-- @param #xwos.gui self
-- @param classmanager#clazz clazz
-- @param #xwguiprivates privates
-- @return #number
function (self, clazz, privates)
    local x, y = privates.term.getSize()
    return x
end) -- function width

------------------------
-- returns the terminal height
-- @function [parent=#xwos.gui] height
-- @param #xwos.gui self self
-- @return #number height

.func("height",
------------------------
-- @function [parent=#xwguiintern] height
-- @param #xwos.gui self
-- @param classmanager#clazz clazz
-- @param #xwguiprivates privates
-- @return #number
function (self, clazz, privates)
    local x, y = privates.term.getSize()
    return y
end) -- function height

------------------------
-- returns the position inside parent
-- @function [parent=#xwos.gui] pos
-- @param #xwos.gui self self
-- @return #number x, y

.func("pos",
------------------------
-- @function [parent=#xwguiintern] pos
-- @param #xwos.gui self
-- @param classmanager#clazz clazz
-- @param #xwguiprivates privates
-- @return #number
function (self, clazz, privates)
    return 0, 0
end) -- function pos

------------------------
-- returns the x position inside parent
-- @function [parent=#xwos.gui] x
-- @param #xwos.gui self self
-- @return #number x

.func("x",
------------------------
-- @function [parent=#xwguiintern] x
-- @param #xwos.gui self
-- @param classmanager#clazz clazz
-- @param #xwguiprivates privates
-- @return #number
function (self, clazz, privates)
    return 0
end) -- function x

------------------------
-- returns the y position inside parent
-- @function [parent=#xwos.gui] y
-- @param #xwos.gui self self
-- @return #number y

.func("pos",
------------------------
-- @function [parent=#xwguiintern] y
-- @param #xwos.gui self
-- @param classmanager#clazz clazz
-- @param #xwguiprivates privates
-- @return #number
function (self, clazz, privates)
    return 0
end) -- function y

return nil