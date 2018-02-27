-----------------------
-- @module xwoskernel
-- @type hardware
local M = {}

-- TODO support logical displays
-----------------------
-- @param term#term core the physical terminal
local physdisplaydriver = require('physdisplay')
local logdisplaydriver = require('logdisplay')

local displayNative = term.current()
local displayCore = physdisplaydriver.createDisplay(displayNative, true)
local displayKernel = logdisplaydriver.createDisplay()
displayKernel.clone(displayCore) -- initially clone to core display; will be removed during successful startup
local displays = {}
local displaysByName = {}
displays[1] = displayCore
displays[2] = displayKernel
displaysByName.current = 1
displaysByName.core = 1
displaysByName.kernel = 2
local displaynum = 3

---------------------------------
-- @function [parent=#hardware] preboot
-- @param xwoskernel#xwos k
M.preboot = function(k)
  -- redirect kernel output through logical display
  k.print = function(...)
    displayKernel.write(...)
  end
  term.redirect(displayKernel) -- TODO on shutdown reset terminal to current one

  k.debug("preboot hardware")

  -- os.loadAPI("GIF")
  
  local names = peripheral.getNames()
  if names ~= nil then
    for i, name in pairs(names) do
      k.debug("probing hardware on side " .. name)
      local type = peripheral.getType(name)
      k.debug("found hardware " .. type .. " on side " .. name)
      
      if (type == "monitor") then
        local mon = peripheral.wrap(name)
        displays[displaynum] = physdisplaydriver.createDisplay(mon, true)
        displaynum = displaynum + 1
        
--        mon.setTextScale(0.5)
--        local x, y = mon.getSize()
--        local image = GIF.loadGIF("/rom/xwos/kernel/common/modules/hardware/ajax.gif")
--        mon.setBackgroundColor(image[1].transparentCol or image.backgroundCol)
--        mon.clear()
--        
--        parallel.waitForAny(
--                function()
--                        GIF.animateGIF(image, math.floor((x - image.width) / 2) + 1, math.floor((y - image.height) / 2) + 1, mon)
--                end,
--                
--                function()
--                        sleep(10)
--                end
--        )
      end
    end
  end
end

---------------------------------
-- @function [parent=#hardware] boot
-- @param xwoskernel#xwos k
M.boot = function(k)
  k.debug("boot hardware")
end

---------------------------------
-- Returns the display with given number
-- @function [parent=#hardware] getCoreDisplay
-- @return #display the display
M.getCoreDisplay = function()
  return displayCore
end

---------------------------------
-- Returns the number of supported displays
-- @function [parent=#hardware] getDisplayCount
-- @return #number
M.getDisplayCount = function()
  return displaynum - 1
end

---------------------------------
-- returns the display with given number (id)
-- @function [parent=#hardware] getDisplayById
-- @param #number num display number beginning with 1
-- @return #display the display with given number or nil
M.getDisplayById = function(num)
  return displays[num]
end

---------------------------------
-- @function [parent=#hardware] getDisplay
-- @param #string name unique display name to identify the display
-- @return #display the display with given name
M.getDisplay = function(name)
  local num = displaysByName[name]
  if (num ~= nil) then
    return displays[num]
  end
  return nil
end

-- TODO watch for broken displays (gone monitors)



-----------------------
-- Common wrapper around virtual and physical displays; A virtual display is emebedded in some window inside the other displays
-- A physical display is the original computer terminal or a connected monitor.
-- @type display

-------------------------------------------------------------------------------
-- Writes text to the screen, using the current text and background colors.
-- @function [parent=#display] write
-- @param #string text

-------------------------------------------------------------------------------
-- Writes text to the screen using the specified text and background colors. Requires version 1.74 or newer.
-- @function [parent=#display] blit
-- @param #string text
-- @param #string textColors
-- @param #string backgroundColors

-------------------------------------------------------------------------------
-- Clears the entire screen.
-- @function [parent=#display] clear

-------------------------------------------------------------------------------
-- Clears the line the cursor is on.
-- @function [parent=#display] clearLine

-------------------------------------------------------------------------------
-- Returns two arguments containing the x and the y position of the cursor.
-- @function [parent=#display] getCursorPos
-- @return #number x
-- @return #number y
 
-------------------------------------------------------------------------------
-- Sets the cursor's position.
-- @function [parent=#display] setCursorPos
-- @param #number x
-- @param #number y

-------------------------------------------------------------------------------
-- Disables the blinking or turns it on.
-- @function [parent=#display] setCursorBlink
-- @param #boolean bool

-------------------------------------------------------------------------------
-- Returns whether the terminal supports color.
-- @function [parent=#display] isColor
-- @return #boolean

-------------------------------------------------------------------------------
-- Returns two arguments containing the x and the y values stating the size of the screen. (Good for if you're making something to be compatible with both Turtles and Computers.)
-- @function [parent=#display] getSize
-- @return #number x
-- @return #number y
 
-------------------------------------------------------------------------------
-- Scrolls the terminal n lines.
-- @function [parent=#display] scroll
-- @param #number n

-------------------------------------------------------------------------------
-- Redirects terminal output to another terminal object (such as a window or wrapped monitor). Available only to the base term object.
-- @function [parent=#display] redirect
-- @param #table target
-- @return #table previous terminal object 

-------------------------------------------------------------------------------
-- Restore originally redirected terminal
-- @function [parent=#display] restore

-------------------------------------------------------------------------------
-- Sets the text color of the terminal. Limited functionality without an Advanced Computer / Turtle / Monitor.
-- @function [parent=#display] setTextColor
-- @param #number color

-------------------------------------------------------------------------------
-- Returns the current text color of the terminal. Requires version 1.74 or newer.
-- @function [parent=#display] getTextColor
-- @return #number color 

-------------------------------------------------------------------------------
-- Sets the background color of the terminal. Limited functionality without an Advanced Computer / Turtle / Monitor.
-- @function [parent=#display] setBackgroundColor
-- @param #number color

-------------------------------------------------------------------------------
-- Returns the current background color of the terminal. Requires version 1.74 or newer.
-- @function [parent=#display] getBackgroundColor
-- @return #number color

-------------------------------------------------------------------------------
-- Determines whether subsequent renders to the window will be visible.
-- @function [parent=#display] setVisible
-- @param #boolean visibility

-------------------------------------------------------------------------------
-- Checks if display is visible
-- @function [parent=#display] isVisible
-- @return #boolean visibility

-------------------------------------------------------------------------------
-- Redraws the contents of the window. Available only to window objects.
-- @function [parent=#display] redraw

-------------------------------------------------------------------------------
-- Returns the cursor back to its position / state within the window. Available only to window objects.
-- @function [parent=#display] restoreCursor

-------------------------------------------------------------------------------
-- Returns the top left co-ordinate of the window. Available only to window objects.
-- @function [parent=#display] getPosition
-- @return #number x
-- @return #number y 

-------------------------------------------------------------------------------
-- Moves and / or resizes the window. Available only to window objects.
-- @function [parent=#display] reposition
-- @param #number x
-- @param #number y
-- @param #number width optional
-- @param #number height optional

return M