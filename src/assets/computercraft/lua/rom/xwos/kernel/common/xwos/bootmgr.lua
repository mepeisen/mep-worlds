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
-- a boot manager
-- @module xwos.bootmgr
_CMR.class("xwos.bootmgr")

.func("main",
function(self, clazz, privates)
    print("BOOT MANAGER (in a real sense...)")
    
    _CMR.loadAll("xwos.gui")
    
    local gui = xwos.gui.stage.create(term.current())
    gui:push(
    xwos.gui.frame.create({x = 1, y = 1, width = 10, height = 10},
      xwos.gui.text.create("FOODDDDDDDDDDD", {x = 2, y = 2})
    ))
    gui:redraw()
end) -- function main

