term.clear()

local origPrint = print
local env = {}
for k, v in pairs(_G) do
  env[k] = v
end

env.print = function(...)
    origPrint("[X]", ...)
end

local readenv = getfenv(read)
setfenv(read, env)
read("*")
setfenv(read, readenv)

return nil