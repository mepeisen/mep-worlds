-----------------------
-- @module xwoskernel
-- @type physdisplaydriver
local M = {}

-----------------------
-- Creates a new physical display
-- @param term#term core the physical terminal
-- @param #boolean visibility
-- @return #display
M.createDisplay = function(core, visibility)
    local result = {}
    local visible = visibility
    
    -------------------------------------------------------------------------------
    -- Writes text to the screen, using the current text and background colors.
    -- @function [parent=#display] write
    -- @param #string text
    result.write = function(text)
      core.write(text)
    end
     
    -------------------------------------------------------------------------------
    -- Writes text to the screen using the specified text and background colors. Requires version 1.74 or newer.
    -- @function [parent=#display] blit
    -- @param #string text
    -- @param #string textColors
    -- @param #string backgroundColors
    result.blit = function(text, textColors, backgroundColors)
      core.blit(text, textColors, backgroundColors)
    end
    
    -------------------------------------------------------------------------------
    -- Clears the entire screen.
    -- @function [parent=#display] clear
    result.clear = function()
      core.clear()
    end
    
    -------------------------------------------------------------------------------
    -- Clears the line the cursor is on.
    -- @function [parent=#display] clearLine
    result.clearLine = function()
      core.clearLine()
    end
    
    -------------------------------------------------------------------------------
    -- Returns two arguments containing the x and the y position of the cursor.
    -- @function [parent=#display] getCursorPos
    -- @return #number x
    -- @return #number y
    result.getCursorPos = function()
      return core.getCursorPos()
    end
     
    -------------------------------------------------------------------------------
    -- Sets the cursor's position.
    -- @function [parent=#display] setCursorPos
    -- @param #number x
    -- @param #number y
    result.setCursorPos = function(x, y)
      core.setCursorPos(x, y)
    end
    
    -------------------------------------------------------------------------------
    -- Disables the blinking or turns it on.
    -- @function [parent=#display] setCursorBlink
    -- @param #boolean bool
    result.setCursorBlink = function(bool)
      core.setCursorBlink(bool)
    end
    
    -------------------------------------------------------------------------------
    -- Returns whether the terminal supports color.
    -- @function [parent=#display] isColor
    -- @return #boolean
    result.blit = function()
      return core.isColor
    end
    
    -------------------------------------------------------------------------------
    -- Returns two arguments containing the x and the y values stating the size of the screen. (Good for if you're making something to be compatible with both Turtles and Computers.)
    -- @function [parent=#display] getSize
    -- @return #number x
    -- @return #number y
    result.getSize = function()
      return core.getSize()
    end
     
    -------------------------------------------------------------------------------
    -- Scrolls the terminal n lines.
    -- @function [parent=#display] scroll
    -- @param #number n
    result.scroll = function(n)
      core.scroll(n)
    end
    
    -------------------------------------------------------------------------------
    -- Redirects terminal output to another terminal object (such as a window or wrapped monitor). Available only to the base term object.
    -- @function [parent=#display] redirect
    -- @param #table target
    -- @return #table previous terminal object 
    result.redirect = function(target)
      -- do nothing (not supported on physical displays)
    end
    
    -------------------------------------------------------------------------------
    -- Restore originally redirected terminal
    -- @function [parent=#display] restore
    result.restore = function()
      -- do nothing (not supported on physical displays)
    end
    
    -------------------------------------------------------------------------------
    -- Sets the text color of the terminal. Limited functionality without an Advanced Computer / Turtle / Monitor.
    -- @function [parent=#display] setTextColor
    -- @param #number color
    result.setTextColor = function(color)
      core.setTextColor(color)
    end
    
    -------------------------------------------------------------------------------
    -- Returns the current text color of the terminal. Requires version 1.74 or newer.
    -- @function [parent=#display] getTextColor
    -- @return #number color 
    result.getTextColor = function()
      return core.getTextColor()
    end
    
    -------------------------------------------------------------------------------
    -- Sets the background color of the terminal. Limited functionality without an Advanced Computer / Turtle / Monitor.
    -- @function [parent=#display] setBackgroundColor
    -- @param #number color
    result.setBackgroundColor = function(color)
      core.setBackgroundColor(color)
    end
    
    -------------------------------------------------------------------------------
    -- Returns the current background color of the terminal. Requires version 1.74 or newer.
    -- @function [parent=#display] getBackgroundColor
    -- @return #number color
    result.getBackgroundColor = function()
      return core.getBackgroundColor()
    end
    
    -------------------------------------------------------------------------------
    -- Determines whether subsequent renders to the window will be visible.
    -- @function [parent=#display] setVisible
    -- @param #boolean visibility
    result.setVisible = function(visibility)
      if core.setVisible ~= nil then
        core.setVisible(visibility)
        visible = visibility
      end
    end
    
    -------------------------------------------------------------------------------
    -- Checks if display is visible
    -- @function [parent=#display] isVisible
    -- @return #boolean visibility
    result.isVisible = function()
      return visible
    end
    
    -------------------------------------------------------------------------------
    -- Redraws the contents of the window. Available only to window objects.
    -- @function [parent=#display] redraw
    result.redraw = function()
      if core.redraw ~= nil then
        core.redraw()
      end
    end
    
    -------------------------------------------------------------------------------
    -- Returns the cursor back to its position / state within the window. Available only to window objects.
    -- @function [parent=#display] restoreCursor
    result.restoreCursor = function()
      if core.restoreCursor ~= nil then
        core.restoreCursor()
      end
    end
    
    -------------------------------------------------------------------------------
    -- Returns the top left co-ordinate of the window. Available only to window objects.
    -- @function [parent=#display] getPosition
    -- @return #number x
    -- @return #number y 
    result.getPosition = function()
      if core.getPosition ~= nil then
        return core.getPosition()
      end
      return 0, 0 -- not supported on physical displays (always zero)
    end
    
    -------------------------------------------------------------------------------
    -- Moves and / or resizes the window. Available only to window objects.
    -- @function [parent=#display] reposition
    -- @param #number x
    -- @param #number y
    -- @param #number width optional
    -- @param #number height optional
    result.reposition = function(x, y, width, height)
      if core.reposition ~= nil then
        core.reposition(x, y, width, height)
      end
    end

    -------------------------------------------------------------------------------
    -- Sets the text scale. Available only to monitor objects.
    -- @function [parent=#display] setTextScale
    -- @param #number scale
    result.setTextScale = function(scale)
      if core.setTextScale ~= nil then
        core.setTextScale(scale)
      end
    end
    
    return result
end