term.clear()

local b = getfenv(1)
local env = {}
for k, v in pairs(b) do
  env[k] = v
end
print(b.require)
print()

env.require = function()
    print("FOO called")
end
setfenv(1, env)

local function abc()
  require("test2")
end

abc()

return nil