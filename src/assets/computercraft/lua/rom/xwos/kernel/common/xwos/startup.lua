--------------------------------
-- Default startup script
-- @module xwos.startup
local M = {}

-------------------
-- The installer
-- @function [parent=#xwos.startup] run
-- @param xwos.kernel#xwos.kernel kernel the kernel reference
M.installer = function(kernel)
    local installerData = { lang = nil }
    print()
    print("starting installer...")
    
    kernel.print("read: ", read)
    kernel.print("read0: ", getfenv(0).read)
    kernel.print("read1: ", getfenv(1).read)
    kernel.print("read6: ", getfenv(6).read)
    kernel.print("read7: ", getfenv(7).read)
    kernel.print("read8: ", getfenv(8).read)
    print()
    print("********* XW-OS ********** INSTALLER")
    local langs = {
        "en" -- TODO support language packs
    }
    while installerData.lang == nil do
      print("")
      print("Choose your language:")
      local input = read()
      if table.contains(langs, input) then
          installerData.lang = input
      else -- if contains
          print("Invalid language. Currently supported: ")
          for k, v in pairs(langs) do
              write(v)
              write(" ")
          end -- for langs
          print("")
      end -- if not contains
    end -- while not lang
    
    local admin = {}
    print("")
    print("Enter your administrators email address:")
    admin.mail = read()
    print("")
    print("Enter your administrators login name:")
    admin.login = read()
    while admin.pass == nil do
        print("")
        print("Enter your administrators password:")
        local pass1 = read()
        print("")
        print("Retype your administrators password:")
        local pass2 = read()
        
        if pass1 ~= pass2 then
            print("")
            print("The passwords do not match...")
        else -- if not pass equals
            admin.pass = pass1
        end -- if pass equals
    end -- while not pass
    
    local user = {}
    print("")
    print("Enter your users email address:")
    user.mail = read()
    print("")
    print("Enter your users login name:")
    user.login = read()
    while user.pass == nil do
        print("")
        print("Enter your users password:")
        local pass1 = read()
        print("")
        print("Retype your users password:")
        local pass2 = read()
        
        if pass1 ~= pass2 then
            print("")
            print("The passwords do not match...")
        else -- if not pass equals
            user.pass = pass1
        end -- if pass equals
    end -- while not pass
    
    print("")
    print("")
    print("***** starting installation")
    print("")
    print("Creating root...")
    local proot = kernel.modules.security.createProfile("root")
    print("Creating administrator...")
    local padmin = kernel.modules.security.createProfile("admin")
    print("Creating user...")
    local puser = kernel.modules.security.createProfile("user")
    print("Creating guest (inactive)...")
    local pguest = kernel.modules.security.createProfile("guest")
    
    -- TODO start gui on primary terminal
    -- TODO create a wizard
    
    -- TODO failing installer should set kernel.shutdown = true
    
    kernel.writeSecureData('core/install.dat', textutils.serialize(installerData))
end -- function installer

-------------------
-- The login processing
-- @function [parent=#xwos.startup] run
-- @param #string installData
-- @param xwos.kernel#xwos.kernel kernel the kernel reference
M.login = function(installData, kernel)
    print()
    print("starting login...")
    
    -- for gui see http://harryfelton.web44.net/titanium/guide/download
    -- lua minifier: https://gitlab.com/hbomb79/Titanium/blob/develop/bin/Minify.lua
    
    -- TODO start gui on primary terminal
end -- function installer

-------------------
-- Startup processing script
-- @function [parent=#xwos.startup] run
-- @param xwos.kernel#xwos.kernel kernel the kernel reference
M.run = function(kernel)
    local installData = kernel.readSecureData('core/install.dat')
    kernel.debug("[start] checking installation")
    if installData == nil then
        kernel.debug("[start] starting installer")
        M.installer(kernel)
    end -- if not installed
    
    while not kernel.shutdown do
        kernel.debug("[start] starting login")
        M.login(textutils.unserialize(installData), kernel)
    end -- while not shutdown
end -- function run

return M
