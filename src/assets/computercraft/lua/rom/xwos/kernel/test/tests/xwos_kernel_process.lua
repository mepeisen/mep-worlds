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

TestXwosKernelProcess = {}

function TestXwosKernelProcess:setUp()
    local cmr = cmf(boot.newglob()) -- classmanager#classmanager
    _CMR = cmr
    -- add kernel common path
    cmr.addcp(boot.kernelRoot().."/kernel/common")
    
    local moses = cmr.require('xwos.extensions.moses.moses_min')
    table.pop = moses.pop
    
    cmr.load("xwos.kernel.process")
    -- kernelmock
    cmr.class('kernelmock')
        .ctor(function(self, clazz, privates)
            self.dmsg = {}
        end)
        .func('debug', function(self, clazz, privates, ...)
            table.insert(self.dmsg, {...})
        end)
end -- setUp

function TestXwosKernelProcess:tearDown()
    _CMR = nil
    table.pop = nil
end -- tearDown

-- testing process creation
function TestXwosKernelProcess:testNew()
    local pprivates = {}
    local parent = nil
    local kernel = _CMR.new('kernelmock')
    local pid = 4711
    local env = {}
    local factories = {}
    local proc = _CMR.new('xwos.kernel.process', pprivates, parent, kernel, pid, env, factories) -- xwos.kernel.process#xwos.kernel.process
    local expectedEnv = { pid = 4711 }
    lu.assertEquals(kernel.dmsg, {
        {"[PID4711]", "pocstate =", "initializing"},
        {"[PID4711]", "env =", expectedEnv}
    })
    lu.assertFalse(proc:isFinished())
    lu.assertFalse(proc:hasJoined())
    lu.assertNil(proc:popev())
    lu.assertEquals(proc:pid(), pid)
end -- testNew

-- testing aqcuireInput, releaseInput
function TestXwosKernelProcess:testInput()
    local pprivates = {}
    local parent = nil
    local kernel = _CMR.new('kernelmock')
    local pid = 4711
    local env = {}
    local factories = {}
    local proc = _CMR.new('xwos.kernel.process', pprivates, parent, kernel, pid, env, factories) -- xwos.kernel.process#xwos.kernel.process
    local acquireCalled = false
    local releaseCalled = false
    kernel.modules = {instances = {sandbox = {procinput = {
        acquire = function (self, p)
            acquireCalled = true
            lu.assertIs(p, proc)
        end,
        release = function (self, p)
            releaseCalled = true
            lu.assertIs(p, proc)
        end
    }}}}
    proc:acquireInput()
    lu.assertTrue(acquireCalled)
    lu.assertFalse(releaseCalled)
    acquireCalled = false
    proc:releaseInput()
    lu.assertFalse(acquireCalled)
    lu.assertTrue(releaseCalled)
end -- testInput

-- testing process local event queue
function TestXwosKernelProcess:testEvqueue()
    local pprivates = {}
    local parent = nil
    local kernel = _CMR.new('kernelmock')
    local pid = 4711
    local env = {}
    local factories = {}
    local proc = _CMR.new('xwos.kernel.process', pprivates, parent, kernel, pid, env, factories) -- xwos.kernel.process#xwos.kernel.process
    proc:pushev({"FOOEVENT", "1"})
    proc:pushev({"FOOEVENT", "2"})
    proc:pushev({"FOOEVENT", "3"})
    lu.assertEquals(proc:popev(), {"FOOEVENT", "1"});
    lu.assertEquals(proc:popev(), {"FOOEVENT", "2"});
    proc:pushev({"FOOEVENT", "4"})
    lu.assertEquals(proc:popev(), {"FOOEVENT", "3"});
    lu.assertEquals(proc:popev(), {"FOOEVENT", "4"});
    lu.assertNil(proc:popev())
end -- testEvqueue

-- TODO test process lifecycle()

-- TODO test join()

-- TODO test wakeup()

-- TODO test terminate()

-- TODO test remove()

-- TODO test spawnClass()

-- TODO test spawn()

-- TODO test env management
