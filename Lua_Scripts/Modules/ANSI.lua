--A simple standalone Lua library for controlling the terminal using the ANSI standard.
--By: Rami Sabbagh (RamiLego4Game)

--Reference: http://ascii-table.com/ansi-escape-sequences.php

local ANSI = {}

--Set the cursor position
--[[Moves the cursor to the specified position (coordinates).
If you do not specify a position, the cursor moves to the home position at the upper-left
corner of the screen (line 0, column 0). This escape sequence works the same way as the
following Cursor Position escape sequence.]]
local fCursorPosition = "\27[%d;%dH"
function ANSI.setCursorPosition(x, y)
	io.write(string.format(fCursorPosition, y, x))
end

--Move the cursor up
--[[Moves the cursor up by the specified number of lines without changing columns. If the
cursor is already on the top line, ANSI.SYS ignores this sequence.]]
local fCursorUp = "\27[%dA"
function ANSI.moveCursorUp(amount)
	io.write(string.format(fCursorUp, amount or 1))
end

--Move the cursor down
--[[Moves the cursor down by the specified number of lines without changing columns. If the
cursor is already on the bottom line, ANSI.SYS ignores this sequence.]]
local fCursorDown = "\27[%dB"
function ANSI.moveCursorDown(amount)
	io.write(string.format(fCursorDown, amount or 1))
end

--Move the cursor forward
--[[Moves the cursor forward by the specified number of columns without changing lines. If
the cursor is already in the rightmost column, ANSI.SYS ignores this sequence.]]
local fCursorForward = "\27[%dC"
function ANSI.moveCursorForward(amount)
	io.write(string.format(fCursorForward, amount or 1))
end

--Move the cursor backward
--[[Moves the cursor back by the specified number of columns without changing lines. If the
cursor is already in the leftmost column, ANSI.SYS ignores this sequence.]]
local fCursorBackward = "\27[%dD"
function ANSI.moveCursorBackward(amount)
	io.write(string.format(fCursorBackward, amount or 1))
end

--Save the cursor position
--[[Saves the current cursor position. You can move the cursor to the saved cursor position
by using the Restore Cursor Position sequence.]]
function ANSI.saveCursorPosition() io.write("\27[s") end

--Restore the cursor position
--[[Returns the cursor to the position stored by the Save Cursor Position sequence.]]
function ANSI.restoreCursorPosition() io.write("\27[u") end

--Erase display
--[[Clears the screen and moves the cursor to the home position (line 0, column 0).]]
function ANSI.eraseDisplay() io.write("\27[2J") end

--Erase line
--[[Clears all characters from the cursor position to the end of the line (including the
character at the cursor position).]]
function ANSI.eraseLine() io.write("\27[K") end

--Sets the graphics mode
--[[Calls the graphics functions specified by the following values. These specified functions
remain active until the next occurrence of this escape sequence. Graphics mode changes
the colors and attributes of text (such as bold and underline) displayed on the screen.]]
--[[
	Text attributes
	0	All attributes off
	1	Bold on
	4	Underscore (on monochrome display adapter only)
	5	Blink on
	7	Reverse video on
	8	Concealed on
	
	Foreground colors
	30	Black
	31	Red
	32	Green
	33	Yellow
	34	Blue
	35	Magenta
	36	Cyan
	37	White
	
	Background colors
	40	Black
	41	Red
	42	Green
	43	Yellow
	44	Blue
	45	Magenta
	46	Cyan
	47	White 
]]
local fSetGraphicsMode = "\27[%sm"
function ANSI.setGraphicsMode(...)
	local modes = {...}
	for k,v in pairs(modes) do modes[k] = tostring(v) end
	io.write(string.format(fSetGraphicsMode, table.concat(modes, ";")))
end

--Set mode
--[[Changes the screen width or type to the mode specified by one of the following values:]]
--[[
	Screen resolution
	0	40 x 25 monochrome (text)
	1	40 x 25 color (text)
	2	80 x 25 monochrome (text)
	3	80 x 25 color (text)
	4	320 x 200 4-color (graphics)
	5	320 x 200 monochrome (graphics)
	6	640 x 200 monochrome (graphics)
	7	Enables line wrapping
	13	320 x 200 color (graphics)
	14	640 x 200 color (16-color graphics)
	15	640 x 350 monochrome (2-color graphics)
	16	640 x 350 color (16-color graphics)
	17	640 x 480 monochrome (2-color graphics)
	18	640 x 480 color (16-color graphics)
	19	320 x 200 color (256-color graphics) 
]]
local fSetMode = "\27[=%dh"
function ANSI.setMode(mode)
	io.write(string.format(fSetMode, mode))
end

--Reset mode
--[[Resets the mode by using the same values that Set Mode uses, except for 7, which
disables line wrapping]]
local fResetMode = "\27[=%dl"
function ANSI.resetMode(mode)
	io.write(string.format(fResetMode, mode))
end

--Set keyboard strings
--[[Redefines a keyboard key to a specified string.]]
local fSetKeyboardStrings = "\27[%sm"
function ANSI.setKeybaordStrings(...)
	local keys = {...}
	for k,v in pairs(keys) do keys[k] = tostring(v) end
	io.write(string.format(fSetKeyboardStrings, table.concat(keys, ";")))
end

return ANSI