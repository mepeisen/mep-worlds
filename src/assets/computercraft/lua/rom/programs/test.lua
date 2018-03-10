-------------------------------------
-- create a new gui
-- @param term#term term the trminal for output
-- @return #gui the gui
local function crgui(term)
    -------------------------------------
    -- @type gui
    local gui = {}
    
    -------------------------------------
    -- @type guiwininternal
    local windows = {}
    
    -------------------------------------
    -- create a new derived window
    -- @function [parent=#gui] crwin
    -- @param #number x x coordinate
    -- @param #number y y coordinate
    -- @param #number width the window width
    -- @param #number height the window height
    -- @return #guiwin
    function gui.crwin(x, y, width, height)
        -------------------------------------
        -- @type guiwin
        local win = {}
        local twin = window.create(term, x, y, width, height, true)
        
        -------------------------------------
        -- show window
        -- @function [parent=#guiwin] show
        function win.show()
            twin.setVisible(true)
        end -- function show
        
        -------------------------------------
        -- hide window
        -- @function [parent=#guiwin] hide
        function win.hide()
            twin.setVisible(false)
        end -- function hide
        
        return win
    end -- function crwin
    return gui
end -- function crgui

term.clear()

local window1 = window.create(term.current(), 1, 1, 10, 1)
local window2 = window.create(term.current(), 3, 1, 10, 1)
local window3 = window.create(term.current(), 2, 1, 10, 1)

window1.setVisible(false)
window2.setVisible(false)
window3.setVisible(false)

window1.setBackgroundColor(colors.blue)
window1.write("HELLO")
window2.setBackgroundColor(colors.gray)
window2.write("WORLD")
window3.setBackgroundColor(colors.green)
window3.write("!!!!!")

while true do
  window1.setVisible(false)
  window2.setVisible(false)
  window3.setVisible(false)
  sleep(0.5)
  window1.setVisible(true)
  window3.setVisible(true)
  window2.setVisible(true)
  sleep(0.5)
  window3.redraw()
  sleep(0.5)

end