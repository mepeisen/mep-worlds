local function foo()
    --local str = cclite.traceback()
    --print(str)
    
    local level = 1
    while level < 5 do
        local state, err = pcall(error, "@", level + 2)
        if err == "@" then break end
        print(err)
        level = level + 1
    end
end -- foo

local function bar()
    foo()
end -- bar

bar()