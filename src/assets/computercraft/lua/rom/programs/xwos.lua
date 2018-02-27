--term.clear()
--
--local tArgs = ...
--
--local osvIter = string.gmatch(os.version(), "%S+")
--local osName = osvIter()
--local osVersion = osvIter()
--
--local kernel -- xwoskernel#xwos
--
--local invalidKernel = function()
--    print("boot failed... running on unknown operating system or version...")
--    print("We require CraftOS at version 1.8")
--end
--
--if osName ~= "CraftOS" then
--    invalidKernel()
--    return nil
--end
--
--if osVersion == "1.8" then
--    kernel = require('/rom/xwos/kernel/1_8/xwoskernel')
--end
--
--if kernel == nil then
--    invalidKernel()
--    return nil
--end
--
--kernel.boot(tArgs)
--kernel.startup()

local origGlobal = {}

for k, v in pairs(_G) do
  origGlobal[k] = v
end

_G.print = function(...)
  origGlobal.write("[STDOUT] ")
  origGlobal.print(...)
end

-- remote monitors: http://www.computercraft.info/forums2/index.php?/topic/25973-multiple-monitors-via-wired-network-cables/

-- wrap lua console and wrap programs...

---- global functions
--orig.print = print
--orig.write = write
--orig.load = load
--orig.read = read
--orig.error = error
--orig.printError = printError
---- relevant for sandbox
--orig.dofile = dofile
--orig.loadfile = loadfile
--orig.loadstring = loadstring
--orig.rawset = rawset
--orig.rawget = rawget
--
---- computercraft apis
--orig.redstone = redstone
--orig.rs = rs -- alias for redstone
--orig.rednet = rednet
--orig.fs = fs
--orig.gps = gps
--orig.disk = disk
--orig.http = http
--orig.os = os
--orig.commands = commands
--orig.io = io
--orig.multishell = multishell
--orig.peripheral = peripheral
--orig.settings = settings
--orig.shell = shell
--orig.turtle = turtle
--orig.pocket = pocket
--
---- terminal management
--orig.term = term
--orig.paintutils = paintutils
--orig.textutils = textutils
--orig.window = window
--
---- threads etc.
--orig.parallel = parallel
--orig.setfenv = setfenv
--orig.getfenv = getfenv
--orig.xpcall = xpcall
--orig.pcall = pcall
--orig.coroutine = coroutine
