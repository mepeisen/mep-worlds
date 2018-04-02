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

return function(boot)
    getfenv(1).boot = boot
    lu = boot.krequire('luaunit/luaunit')
    
    boot.krequire('tests/classmanager')
    boot.krequire('tests/xwos_xwlist')
    
    local junit_stdout = ""
    local junit_stderr = ""
    local junit_test_stdout = ""
    local junit_test_stderr = ""
    local origprint = print
    print = function(...)
        local nLimit = select("#", ... )
        for n = 1, nLimit do
            local s = tostring( select( n, ... ) )
            if n < nLimit then
                s = s .. "\t"
            end
            junit_stdout = junit_stdout ..  s
            junit_test_stdout = junit_test_stdout ..  s
        end
        junit_stdout = junit_stdout .. "\n" 
        junit_test_stdout = junit_test_stdout .. "\n" 
        origprint(...)
    end
    
    local runner = lu.LuaUnit.new()
    runner:setOutputType("junit")
    local origmeta
    local origjunitnew = runner.outputType.new
    runner.outputType.new = function(runner)
            local t = origjunitnew(runner)
            origmeta = getmetatable(t).__index
            return setmetatable( t, {
                __index = {
                    startSuite = function(self)
                        origmeta.startSuite(t)
                    end,
                    
                    startClass = function(self, className)
                        origmeta.startClass(t, className)
                    end,
                    
                    endClass = function(self, className)
                        origmeta.endClass(t, className)
                    end,
                    
                    startTest = function(self, testName)
                        origmeta.startTest(t, testName)
                        junit_test_stdout = ""
                        junit_test_stderr = ""
                    end,
                    
                    endTest = function(self, node)
                        origmeta.endTest(t, node)
                        node.stdout = junit_test_stdout
                        node.stderr = junit_test_stderr
                    end,
                    
                    addStatus = function( self, node )
                        origmeta.addStatus(t, node )
                    end,
                
                    endSuite = function(self)
                        print( '# '..lu.LuaUnit.statusLine(self.result))
                
                        -- XML file writing
                        self.fd:write('<?xml version="1.0" encoding="UTF-8" ?>\n')
                        self.fd:write('<testsuites>\n')
                        self.fd:write(string.format(
                            '    <testsuite name="LuaUnit" id="00001" package="" hostname="localhost" tests="%d" timestamp="%s" time="%0.3f" errors="%d" failures="%d">\n',
                            self.result.runCount, self.result.startIsodate, self.result.duration, self.result.errorCount, self.result.failureCount ))
                        self.fd:write("        <properties>\n")
                        self.fd:write(string.format('            <property name="Lua Version" value="%s"/>\n', _VERSION ) )
                        self.fd:write(string.format('            <property name="LuaUnit Version" value="%s"/>\n', lu.VERSION) )
                        -- XXX please include system name and version if possible
                        self.fd:write("        </properties>\n")
                
                        for i,node in ipairs(self.result.tests) do
                            self.fd:write(string.format('        <testcase classname="%s" name="%s" time="%0.3f">\n',
                                node.className, node.testName, node.duration ) )
                            if node:isNotPassed() then
                                self.fd:write(node:statusXML())
                            end
                            self.fd:write('    <system-out>'..node.stdout:gsub("<", "&lt;")..'</system-out>\n')
                            self.fd:write('    <system-err>'..node.stderr:gsub("<", "&lt;")..'</system-err>\n')
                            self.fd:write('        </testcase>\n')
                        end
                
                        self.fd:write('    <system-out>'..junit_stdout:gsub("<", "&lt;")..'</system-out>\n')
                        self.fd:write('    <system-err>'..junit_stderr:gsub("<", "&lt;")..'</system-err>\n')
                
                        self.fd:write('    </testsuite>\n')
                        self.fd:write('</testsuites>\n')
                        self.fd:close()
                        return self.result.notPassedCount
                    end
                }
            } )
        end
    runner:runSuite("--name", "junit.xml", "--pattern", "Test*")
    
    print = origprint
end
