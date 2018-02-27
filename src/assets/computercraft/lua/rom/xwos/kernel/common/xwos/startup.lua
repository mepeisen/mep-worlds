--------------------------------
-- Default startup script
-- @module xwos.startup
return {
    -------------------
    -- Startup processing script
    -- @function [parent=#xwos.startup] run
    -- @param xwos.kernel#xwos.kernel kernel the kernel reference
    run = function(kernel)
        local installData = kernel.readSecureData('core/install.dat')
        -- TODO
    end
}