local b = getfenv(0)
print(b.require)

local function abc()
  require("foo")
end

abc()

return nil