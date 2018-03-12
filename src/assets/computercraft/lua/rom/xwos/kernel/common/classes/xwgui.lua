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
-- gui utility
-- @type xwgui
local xwgui = {}

------------------------
-- create new gui
-- @function [parent=#xwgui] create
-- @param term#term term the underlying terminal
-- @return #xwgui gui tooling
function xwgui.create(term)
    local R = {}
    setmetatable(R, {__index=xwgui})
    ------------------------
    -- @field [parent=#xwgui] term#term term target terminal
    R.term = term
    return R
end -- function create

------------------------
-- returns the terminal size
-- @function [parent=#xwgui] size
-- @param #xwgui self self
-- @return #number width, height
function xwgui:size()
    return self.term.getSize()
end -- function size

------------------------
-- returns the terminal width
-- @function [parent=#xwgui] width
-- @param #xwgui self self
-- @return #number width
function xwgui:width()
    local x, y = self.term.getSize()
    return x
end -- function width

------------------------
-- returns the terminal height
-- @function [parent=#xwgui] height
-- @param #xwgui self self
-- @return #number height
function xwgui:height()
    local x, y = self.term.getSize()
    return y
end -- function height

------------------------
-- returns the position inside parent
-- @function [parent=#xwgui] pos
-- @param #xwgui self self
-- @return #number x, y
function xwgui:pos()
    return 0, 0
end -- function pos

------------------------
-- returns the x position inside parent
-- @function [parent=#xwgui] x
-- @param #xwgui self self
-- @return #number x
function xwgui:x()
    return 0
end -- function x

------------------------
-- returns the y position inside parent
-- @function [parent=#xwgui] y
-- @param #xwgui self self
-- @return #number y
function xwgui:y()
    return 0
end -- function y

return xwgui