--    Copyright Martin Eisengardt 2018 xworlds.eu
--    
--    This file is part of xwos.
--
--    xwos is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    xwos is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with xwos.  If not, see <http://www.gnu.org/licenses/>.

term.clear()
term.setCursorPos(1,1)

print("** XW-OS installer........")
print("** Copyright © 2018 by xworlds.eu.")
print("** All rights reserved.")

if not http then
    printError( "Installer requires http API" )
    printError( "Set http_enable to true in ComputerCraft.cfg" )
    return
end

local versions = {
    {
      name = "Latest snapshot",
      key = 'y9ijTpkx'
    }
}

-- borrowed from program pastebin
local function get(paste)
    write( "Connecting to pastebin.com... " )
    local response = http.get(
        "https://pastebin.com/raw/"..textutils.urlEncode( paste )
    )
        
    if response then
        print( "Success." )
        
        local sResponse = response.readAll()
        response.close()
        return sResponse
    else
        print( "Failed." )
    end
end

local finish = false
while not finish do
    print()
    print("** available versions:")
    
    for k,v in pairs(versions) do
        print("[",k,"] ",v.name)
    end -- for versions
    
    print("Please select your version (X for exit)")
    write("> ")
    local input = read()
    if input == "x" or input == "X" then
        finish = true
        print("Good bye...")
    elseif versions[tonumber(input)] == nil then
        print("Unknown version ", input)
    else
        finish = true
        local installer = get(versions[tonumber(input)].key)
        loadstring(installer)()
    end
end
