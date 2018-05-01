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

TestXwosKernelFschroot = {}

function TestXwosKernelFschroot:setUp()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    -- add kernel common path
    cmr.addcp(boot.kernelRoot().."/kernel/common")
    
    local allen = cmr.require('xwos.extensions.allen.allen')
    string.startsWith = allen.startsWith
    
    cmr.load("xwos.kernel.fschroot")
end -- setUp

function TestXwosKernelFschroot:tearDown()
    _CMR = nil
    string.startsWith = nil
end -- tearDown

-- testing functions
function TestXwosKernelFschroot:testExists()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests/classmanager") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertTrue(fs2:exists('SimpleClass.lua'))
    lu.assertFalse(fs2:exists('NotFound.lua'))
end -- testExists

-- testing functions
function TestXwosKernelFschroot:testExists2()
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), "classmanager") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertTrue(fs2:exists('SimpleClass.lua'))
    lu.assertFalse(fs2:exists('NotFound.lua'))
end -- testExists2

-- testing functions
function TestXwosKernelFschroot:testExistsEscaped()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests/classmanager") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertTrue(fs2:exists('../classmanager/SimpleClass.lua'))
    lu.assertFalse(fs2:exists('../classmanager'))
    lu.assertFalse(fs2:exists('../classmanager2'))
end -- testExists2

-- testing functions
function TestXwosKernelFschroot:testList()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests/classmanager") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertItemsEquals(fs2:list(''), {'SimpleClass.lua', 'SimpleClassInvalid.lua'})
end -- testList

-- testing functions
function TestXwosKernelFschroot:testList2()
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), "classmanager") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertItemsEquals(fs2:list(''), {'SimpleClass.lua', 'SimpleClassInvalid.lua'})
end -- testList2

-- testing functions
function TestXwosKernelFschroot:testListEscaped()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests/classmanager") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertErrorMsgContains('Invalid Path', function() fs2:list('..') end)
end -- testListEscaped

-- testing functions
function TestXwosKernelFschroot:testIsDir()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertTrue(fs2:isDir('classmanager'))
    lu.assertFalse(fs2:isDir('notfound'))
    lu.assertFalse(fs2:isDir('classmanager/SimpleClass.lua'))
end -- testIsDir

-- testing functions
function TestXwosKernelFschroot:testIsDir2()
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), "tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertTrue(fs2:isDir('classmanager'))
    lu.assertFalse(fs2:isDir('notfound'))
    lu.assertFalse(fs2:isDir('classmanager/SimpleClass.lua'))
end -- testIsDir2

-- testing functions
function TestXwosKernelFschroot:testIsDirEscaped()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertFalse(fs2:isDir('..'))
end -- testIsDirEscaped

-- testing functions
function TestXwosKernelFschroot:testGetName()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:getName('classmanager'), 'classmanager')
    lu.assertEquals(fs2:getName('notfound'), 'notfound')
    lu.assertEquals(fs2:getName('classmanager/SimpleClass.lua'), 'SimpleClass.lua')
end -- testGetName

-- testing functions
function TestXwosKernelFschroot:testGetName2()
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), "tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:getName('classmanager'), 'classmanager')
    lu.assertEquals(fs2:getName('notfound'), 'notfound')
    lu.assertEquals(fs2:getName('classmanager/SimpleClass.lua'), 'SimpleClass.lua')
end -- testGetName2

-- testing functions
function TestXwosKernelFschroot:testGetNameEscaped()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:getName('..'), '..')
end -- testGetNameEscaped

-- testing functions
function TestXwosKernelFschroot:testGetDrive()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:getDrive('classmanager'), 'hdd')
    lu.assertNil(fs2:getDrive('notfound'))
    lu.assertEquals(fs2:getDrive('classmanager/SimpleClass.lua'), 'hdd')
end -- testGetDrive

-- testing functions
function TestXwosKernelFschroot:testGetDrive2()
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), "tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:getDrive('classmanager'), 'hdd')
    lu.assertNil(fs2:getDrive('notfound'))
    lu.assertEquals(fs2:getDrive('classmanager/SimpleClass.lua'), 'hdd')
end -- testGetDrive2

-- testing functions
function TestXwosKernelFschroot:testGetDriveEscaped()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertErrorMsgContains('Invalid Path', function() fs2:getDrive('..') end)
end -- testGetDriveEscaped

-- testing functions
function TestXwosKernelFschroot:testGetSize()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:getSize('classmanager'), 0)
    lu.assertErrorMsgContains("No such file", function() fs2:getSize('notfound') end)
    lu.assertEquals(fs2:getSize('classmanager/SimpleClass.lua'), fs.getSize(boot.kernelRoot().."/kernel/test/tests/classmanager/SimpleClass.lua"))
end -- testGetSize

-- testing functions
function TestXwosKernelFschroot:testGetSize2()
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), "tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:getSize('classmanager'), 0)
    lu.assertErrorMsgContains("No such file", function() fs2:getSize('notfound') end)
    lu.assertEquals(fs2:getSize('classmanager/SimpleClass.lua'), fs.getSize(boot.kernelRoot().."/kernel/test/tests/classmanager/SimpleClass.lua"))
end -- testGetSize2

-- testing functions
function TestXwosKernelFschroot:testGetSizeEscaped()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertErrorMsgContains('Invalid Path', function() fs2:getSize('..') end)
end -- testGetSize

-- testing functions
function TestXwosKernelFschroot:testGetFreeSpace()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:getFreeSpace('classmanager'), math.huge)
    lu.assertEquals(fs2:getFreeSpace('notfound'), math.huge)
    lu.assertEquals(fs2:getFreeSpace('classmanager/SimpleClass.lua'), math.huge)
end -- testGetFreeSpace

-- testing functions
function TestXwosKernelFschroot:testGetFreeSpace2()
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), "tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:getFreeSpace('classmanager'), math.huge)
    lu.assertEquals(fs2:getFreeSpace('notfound'), math.huge)
    lu.assertEquals(fs2:getFreeSpace('classmanager/SimpleClass.lua'), math.huge)
end -- testGetFreeSpace2

-- testing functions
function TestXwosKernelFschroot:testGetFreeSpaceEscaped()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertErrorMsgContains('Invalid Path', function() fs2:getFreeSpace('..') end)
end -- testGetFreeSpaceEscaped

-- testing functions
function TestXwosKernelFschroot:testMakeDir()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit/test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    fs2:makeDir('foo')
    fs2:makeDir('foo/bar')
    lu.assertTrue(fs.isDir('luaunit/test/foo/bar'))
end -- testMakeDir

-- testing functions
function TestXwosKernelFschroot:testMakeDir2()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), 'test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    fs2:makeDir('foo')
    fs2:makeDir('foo/bar')
    lu.assertTrue(fs.isDir('luaunit/test/foo/bar'))
end -- testMakeDir2

-- testing functions
function TestXwosKernelFschroot:testMakeDirEscaped()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit/test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertErrorMsgContains('Invalid Path', function() fs2:makeDir('../foo') end)
end -- testMakeDirEscaped

-- testing functions
function TestXwosKernelFschroot:testMove()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit/test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    fs2:makeDir('foo')
    fs2:makeDir('foo/bar')
    fs2:move('foo', 'baz')
    lu.assertFalse(fs.isDir('luaunit/test/foo/bar'))
    lu.assertTrue(fs.isDir('luaunit/test/baz/bar'))
end -- testMove

-- testing functions
function TestXwosKernelFschroot:testMove2()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), 'test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    fs2:makeDir('foo')
    fs2:makeDir('foo/bar')
    fs2:move('foo', 'baz')
    lu.assertFalse(fs.isDir('luaunit/test/foo/bar'))
    lu.assertTrue(fs.isDir('luaunit/test/baz/bar'))
end -- testMove2

-- testing functions
function TestXwosKernelFschroot:testMoveEscaped()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit/test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    fs2:makeDir('foo')
    fs2:makeDir('foo/bar')
    lu.assertErrorMsgContains('Invalid Path', function() fs2:move('..', 'baz') end)
    lu.assertErrorMsgContains('Invalid Path', function() fs2:move('foo', '..') end)
end -- testMoveEscaped

-- testing functions
function TestXwosKernelFschroot:testCopy()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit/test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    fs2:makeDir('foo')
    fs2:makeDir('foo/bar')
    fs2:copy('foo', 'baz')
    lu.assertTrue(fs.isDir('luaunit/test/foo/bar'))
    lu.assertTrue(fs.isDir('luaunit/test/baz/bar'))
end -- testCopy

-- testing functions
function TestXwosKernelFschroot:testCopy2()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), 'test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    fs2:makeDir('foo')
    fs2:makeDir('foo/bar')
    fs2:copy('foo', 'baz')
    lu.assertTrue(fs.isDir('luaunit/test/foo/bar'))
    lu.assertTrue(fs.isDir('luaunit/test/baz/bar'))
end -- testCopy2

-- testing functions
function TestXwosKernelFschroot:testCopyEscaped()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit/test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    fs2:makeDir('foo')
    fs2:makeDir('foo/bar')
    lu.assertErrorMsgContains('Invalid Path', function() fs2:copy('..', 'baz') end)
    lu.assertErrorMsgContains('Invalid Path', function() fs2:copy('foo', '..') end)
end -- testCopyEscaped

-- testing functions
function TestXwosKernelFschroot:testDelete()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit/test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    fs2:makeDir('foo')
    fs2:makeDir('foo/bar')
    fs2:delete('foo')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
end -- testDelete

-- testing functions
function TestXwosKernelFschroot:testDelete2()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), 'test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    fs2:makeDir('foo')
    fs2:makeDir('foo/bar')
    fs2:delete('foo')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
end -- testDelete2

-- testing functions
function TestXwosKernelFschroot:testDeleteEscaped()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit/test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    fs2:makeDir('foo')
    fs2:makeDir('foo/bar')
    lu.assertErrorMsgContains('Invalid Path', function() fs2:delete('..') end)
end -- testDeleteEscaped

-- testing functions
function TestXwosKernelFschroot:testCombine()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit/test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:combine('foo', 'bar'), 'foo/bar')
end -- testCombine

-- testing functions
function TestXwosKernelFschroot:testCombine2()
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), 'test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:combine('foo', 'bar'), 'foo/bar')
end -- testCombine2

-- testing functions
function TestXwosKernelFschroot:testCombineEscaped()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit/test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:combine('foo', '../..'), '..') -- classic fs behaviour
end -- testCombineEscaped

-- testing functions
function TestXwosKernelFschroot:testOpenRead()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fh = fs2:open('classmanager/SimpleClass.lua', "r")
    local actual = fh.readAll()
    fh.close()
    fh = fs.open(boot.kernelRoot().."/kernel/test/tests/classmanager/SimpleClass.lua", "r")
    local expected = fh.readAll()
    fh.close()
    lu.assertEquals(actual, expected)
end -- testOpenRead

-- testing functions
function TestXwosKernelFschroot:testOpenRead2()
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), "tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fh = fs2:open('classmanager/SimpleClass.lua', "r")
    local actual = fh.readAll()
    fh.close()
    fh = fs.open(boot.kernelRoot().."/kernel/test/tests/classmanager/SimpleClass.lua", "r")
    local expected = fh.readAll()
    fh.close()
    lu.assertEquals(actual, expected)
end -- testOpenRead2

-- testing functions
function TestXwosKernelFschroot:testOpenReadEscaped()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertErrorMsgContains('Invalid Path', function() fs2:open('../foo.txt', 'r') end)
end -- testOpenReadEscaped

-- testing functions
function TestXwosKernelFschroot:testOpenWrite()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit/test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fh = fs2:open('foo.txt', "w")
    fh.write("FOO")
    fh.close()
    fh = fs.open("luaunit/test/foo.txt", "r")
    local actual = fh.readAll()
    fh.close()
    lu.assertEquals(actual, "FOO")
end -- testOpenWrite

-- testing functions
function TestXwosKernelFschroot:testOpenWrite2()
    -- cleanup from previous runs
    if (fs.isDir('luaunit')) then fs.delete('luaunit') end
    
    lu.assertFalse(fs.isDir('luaunit'))
    fs.makeDir('luaunit')
    fs.makeDir('luaunit/test')
    lu.assertFalse(fs.isDir('luaunit/test/foo'))
    
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, 'luaunit') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), 'test') -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fh = fs2:open('foo.txt', "w")
    fh.write("FOO")
    fh.close()
    fh = fs.open("luaunit/test/foo.txt", "r")
    local actual = fh.readAll()
    fh.close()
    lu.assertEquals(actual, "FOO")
end -- testOpenWrite2

-- testing functions
function TestXwosKernelFschroot:testFind()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertItemsEquals(fs2:find("classmanager/*.lua"), {"classmanager/SimpleClass.lua", "classmanager/SimpleClassInvalid.lua"})
end -- testFind

-- testing functions
function TestXwosKernelFschroot:testFind2()
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), "tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertItemsEquals(fs2:find("classmanager/*.lua"), {"classmanager/SimpleClass.lua", "classmanager/SimpleClassInvalid.lua"})
end -- testFind2

-- testing functions
function TestXwosKernelFschroot:testFindEscaped()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertErrorMsgContains('Invalid Path', function() fs2:find('../*') end)
end -- testFindEscaped

-- testing functions
function TestXwosKernelFschroot:testGetDir()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:getDir('classmanager'), '')
    lu.assertEquals(fs2:getDir('notfound'), '')
    lu.assertEquals(fs2:getDir('classmanager/SimpleClass.lua'), 'classmanager')
end -- testGetDir

-- testing functions
function TestXwosKernelFschroot:testGetDir2()
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), "tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:getDir('classmanager'), '')
    lu.assertEquals(fs2:getDir('notfound'), '')
    lu.assertEquals(fs2:getDir('classmanager/SimpleClass.lua'), 'classmanager')
end -- testGetDir2

-- testing functions
function TestXwosKernelFschroot:testGetDirEscaped()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertEquals(fs2:getDir('..'), '')
end -- testGetDirEscaped

-- testing functions
function TestXwosKernelFschroot:testComplete()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertItemsEquals(fs2:complete('S', 'classmanager'), {'impleClass.lua', 'impleClassInvalid.lua'})
    lu.assertItemsEquals(fs2:complete('S', 'classmanager', false), {})
    lu.assertItemsEquals(fs2:complete('c', ''), {'lassmanager/', 'lassmanager', 'lassmanager.lua', 'lassmanager2/', 'lassmanager2'})
    lu.assertItemsEquals(fs2:complete('c', '', false), {'lassmanager/', 'lassmanager', 'lassmanager2', 'lassmanager2/'})
    lu.assertItemsEquals(fs2:complete('c', '', false, false), {'lassmanager/', 'lassmanager2/'})
end -- testComplete

-- testing functions
function TestXwosKernelFschroot:testComplete2()
    local fs1 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs1:wrap(_G), "tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertItemsEquals(fs2:complete('S', 'classmanager'), {'impleClass.lua', 'impleClassInvalid.lua'})
    lu.assertItemsEquals(fs2:complete('S', 'classmanager', false), {})
    lu.assertItemsEquals(fs2:complete('c', ''), {'lassmanager/', 'lassmanager', 'lassmanager.lua', 'lassmanager2/', 'lassmanager2'})
    lu.assertItemsEquals(fs2:complete('c', '', false), {'lassmanager/', 'lassmanager', 'lassmanager2', 'lassmanager2/'})
    lu.assertItemsEquals(fs2:complete('c', '', false, false), {'lassmanager/', 'lassmanager2/'})
end -- testComplete2

-- testing functions
function TestXwosKernelFschroot:testCompleteEscaped()
    local fs2 = _CMR.new('xwos.kernel.fschroot', nil, fs, boot.kernelRoot().."/kernel/test/tests") -- xwos.kernel.fschroot#xwos.kernel.fschroot
    lu.assertErrorMsgContains('Invalid Path', function() fs2:complete('S', '..') end)
end -- testCompleteEscaped
