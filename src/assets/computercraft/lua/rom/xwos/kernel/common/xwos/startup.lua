--------------------------------
-- Default startup script
-- @module xwos.startup
-- @usage require('xwos/kernel')
return {
    -------------------
    -- Startup processing script
    -- @function [parent=#xwos.startup] run
    -- @param xwos.kernel#xwos.kernel kernel the kernel reference
    run = function(kernel)
        local installData = kernel.readSecureData('core/install.dat')
        -- TODO
        local function func1()
            local origPrint = _G.print
            _G.print = function(...)
                origPrint("[1] ", ...)
            end
            print("Hello World!")
            sleep(5)
            print("Hello again");
        end
        local function func2()
            local origPrint = _G.print
            _G.print = function(...)
                origPrint("[2] ", ...)
            end
            sleep(1)
            print("Hello World!")
            sleep(5)
            print("Hello again");
        end
        local proc1 = kernel.modules.sandbox.createProcessBuilder().buildAndExecute(func1)
        local proc2 = kernel.modules.sandbox.createProcessBuilder().buildAndExecute(func2)
        proc1.join()
        proc2.join()
    end
}