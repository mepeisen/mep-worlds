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
    kernel.debug("[start] beginning run")
    local installData = kernel.readSecureData('core/install.dat')
    kernel.debug("[start] checking installation")
    if installData == nil then
        kernel.debug("[start] invoking installer")
        M.installer(kernel)
    end -- if not installed
    kernel.debug("[start] beginning thread")
    
    -- TODO
    local function func1()
        kernel.debug("[func1] getfenv")
        local orig = getfenv(0)
        kernel.debug("[func1] creating new")
        local new = table.clone(orig)
        kernel.debug("[func1] injecting print")
        new.print = function(...)
            orig.print("[1] ", ...)
        end
        kernel.debug("[func1] setenv")
        setfenv(1, new)
        kernel.debug("[func1] print")
        print("Hello World!")
        kernel.debug("[func1] sleep")
        --sleep(5)
        kernel.debug("[func1] print")
        print("Hello again");
        kernel.debug("[func1] end")
    end
    local function func2()
        kernel.debug("[func2] getfenv")
        local orig = getfenv(0)
        kernel.debug("[func2] creating new")
        local new = table.clone(orig)
        kernel.debug("[func2] injecting print")
        new.print = function(...)
            orig.print("[2] ", ...)
        end
        kernel.debug("[func2] setenv")
        setfenv(1, new)
        kernel.debug("[func2] sleep")
        --sleep(5)
        kernel.debug("[func2] print")
        print("Hello World!")
        kernel.debug("[func2] sleep")
        --sleep(5)
        kernel.debug("[func2] print")
        print("Hello again");
        kernel.debug("[func2] end")
    end
    kernel.debug("[start] create func1", func1)
    local proc1 = kernel.modules.sandbox.createProcessBuilder().buildAndExecute(func1)
    kernel.debug("[start] create func2", func2)
    local proc2 = kernel.modules.sandbox.createProcessBuilder().buildAndExecute(func2)
    print("Waiting for proc 1")
    proc1.join()
    print("Waiting for proc 2")
    proc2.join()
    print("Ending")
end -- function run

return M
