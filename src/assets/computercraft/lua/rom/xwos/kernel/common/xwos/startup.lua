--------------------------------
-- Default startup script
-- @module xwos.startup
local M = {}

-------------------
-- The installer
-- @function [parent=#xwos.startup] run
-- @param xwos.kernel#xwos.kernel kernel the kernel reference
M.installer = function(kernel)
    kernel.print()
    kernel.print("starting installer...")
    
    -- TODO start gui on primary terminal
    -- TODO create a wizard
    
end -- function installer

-------------------
-- Startup processing script
-- @function [parent=#xwos.startup] run
-- @param xwos.kernel#xwos.kernel kernel the kernel reference
M.run = function(kernel)
    local installData = kernel.readSecureData('core/install.dat')
    if installData == nil then
        M.installer(kernel)
    end -- if not installed
    
    -- TODO
    local function func1()
        local orig = getfenv(1)
        local new = table.clone(orig)
        new.print = function(...)
            orig.print("[1] ", ...)
        end
        setfenv(1, new)
        print("Hello World!")
        sleep(5)
        print("Hello again");
    end
    local function func2()
        local orig = getfenv(1)
        local new = table.clone(orig)
        new.print = function(...)
            orig.print("[2] ", ...)
        end
        setfenv(1, new)
        sleep(1)
        print("Hello World!")
        sleep(5)
        print("Hello again");
    end
    local proc1 = kernel.modules.sandbox.createProcessBuilder().buildAndExecute(func1)
    local proc2 = kernel.modules.sandbox.createProcessBuilder().buildAndExecute(func2)
    print("Waiting for proc 1")
    proc1.join()
    print("Waiting for proc 2")
    proc2.join()
    print("Ending")
end -- function run

return M
