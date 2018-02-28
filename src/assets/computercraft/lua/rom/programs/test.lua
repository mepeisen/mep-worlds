term.clear()

local b = getfenv(1)
local env = {}
for k, v in pairs(b) do
  env[k] = v
end
print(b.require)
print(b)
print(_G)

local function foo(t)
  for k, v in pairs(t) do
    write(k)
    write(" ")
  end
  print()
  print()
end
foo(b)
foo(_G)

env.require = function()
    print("FOO called")
end
setfenv(1, env)

local function abc()
  require("test2")
end

abc()

return nil