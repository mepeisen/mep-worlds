
local cocreate = coroutine.create
local coresume = coroutine.resume
local origGetfenv = getfenv
local origSetfenv = setfenv
local origsetmeta = setmetatable

--------------------------------
-- local process environments
-- @type xwos.processes
local processes = {}

--------------------------------
-- next pid to use for new processes
local nextPid = 0

--------------------------------
-- creates a new process
-- @function [parent=#xwos.processes] new
-- @param #global env the global process environment
-- @return #xwos.process
function processes.new(env)
    --------------------------------
    -- process type
    -- @type xwos.process
    local R = {}
    
    --------------------------------
    -- @field [parent=#xwos.process] #number pid the process id
    R.pid = nextPid
    nextPid = nextPid + 1
    
    --------------------------------
    -- @field [parent=#xwos.process] #string procstate the process state; "initializing", "running" or "terminated"
    R.procstate = "initializing"
    
    --------------------------------
    -- Remove the process from process table
    -- @function [parent=#xwos.process] remove
    R.remove = function()
        processes[pid] = nil
    end -- function remove
    
    --------------------------------
    -- Spawn the process (invoke function)
    -- @function [parent=#xwos.process] spawn
    -- @param #function func the function to invoke
    -- @param ... the arguments for given function
    R.spawn = function(func, ...)
      local nenv = {}
      local nenvmt = {
          __index = function(table, key)
              if key == "pid" then
                  return R.pid
              end -- if pid
              return env[key]
          end -- function __index
      }
      origsetmeta(nenv, nenvmt)
      origsetmeta(nenvmt.__index, nenvmt)
      local spawn0 = function(...)
          R.procstate = "running"
          origSetfenv(0, nenv)
          local res = {pcall(func(...))}
          --------------------------------
          -- @field [parent=#xwos.process] #table result the return state from process function
          R.result = res
          R.procstate = "finished"
      end -- function spawn0
      --------------------------------
      -- @field [parent=#xwos.process] coroutine#coroutine co the coroutine
      R.co = cocreate(spawn0)
      local res = {coresume(R.co, ...)}
      R.result = res
      if not res[1] then
          R.procstate = "finished"
      end -- if not res
    end -- function spawn
    
    --------------------------------
    -- @field [parent=#xwos.process] #global env the process environment
    R.env = env
    
    processes[pid] = R
    return R
end -- function new

return processes
