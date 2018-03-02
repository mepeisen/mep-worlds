term.clear()

local origPrint = print
local origRead = read
local env = {}
for k, v in pairs(_G) do
  env[k] = v
end

env.print = function(...)
    origPrint("[X]", ...)
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

local function bar()
    read("*")
end

local function foo(pid)
    return function(env)
        env.print = function(...)
            origPrint("["..pid.."]", ...)
        end
        env.read = function(...)
            print("FOO")
            return origRead(...)
        end
        setfenv(0, env)
        setfenv(1, env)
        print("0:", getfenv(0))
        print("1:", getfenv(1))
        if pid == 1 then
            setfenv(bar, env)
            bar()
        end
    end
end

local co = coroutine.create(foo(1))
local co2 = coroutine.create(foo(2))
coroutine.resume(co, env)
coroutine.resume(co2, env)

print("0:", getfenv(0))

return nil