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

local cmf = boot.krequire('classmanager')

TestXwosXwlist = {}

function TestXwosXwlist:setUp()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    cmr.addcp(unpack(boot.kernelpaths()))
end -- setUp

function TestXwosXwlist:tearDown()
    _CMR = nil
end -- tearDown

-- tests a simple empty list creation
function TestXwosXwlist:testEmpty()
    local list = _CMR.new("xwos.xwlist") -- xwos.xwlist#xwos.xwlist
    lu.assertEquals(0, list:length())
    lu.assertNil(list:first())
    lu.assertNil(list:last())
end -- testEmpty
