term.clear()

local origPrint = print
local env = {}
for k, v in pairs(_G) do
  env[k] = v
end

env.print = function(...)
    origPrint("[1] ", ...)
end

--local function debug(a)
--    for k,v in pairs(a) do
--        print(k, "->", v)
--    end
--end
--print(env.print)

print(env)
print("0:", getfenv(0))
print("1:", getfenv(1))
print("2:", getfenv(2))

local function foo(env)
    setfenv(0, env)
    setfenv(1, env)
    print("0:", getfenv(0))
    print("1:", getfenv(1))
end

local co = coroutine.create(foo)
local co2 = coroutine.create(foo)
coroutine.resume(co, env)
coroutine.resume(co2, env)

print("0:", getfenv(0))

return nil