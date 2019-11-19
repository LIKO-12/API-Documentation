--This script validates that all the JSON files in the Engine-Documentation directory could be decoded successfully without any errors.
--Specification Implemented: 2019-11-17-Specification.md

--Code author: Rami Sabbagh (RamiLego4Game)

--Extend the package path so it search for the modules in the special directory.
package.path = "./Lua_Scripts/Modules/?.lua;./Lua_Scripts/Modules/?/init.lua;"..package.path

local startClock = os.clock()

--Load ANSI module
if not pcall(require, "ANSI") then print("\27[0;1;31mCould not load the ANSI module, please make sure that the script is executed with the repository being the working directory!\27[0;1;37m") os.exit(1) return end
local ANSI = require("ANSI")

--== Shared functions ==--

local function fail(...)
	local reason = {...}
	for k,v in pairs(reason) do reason[k] = tostring(v) end
	reason = table.concat(reason, " ")
	ANSI.setGraphicsMode(0, 1, 31) --Red output
	print(reason)
	ANSI.setGraphicsMode(0, 1, 37) --White output
	os.exit(1)
end

--== Load external modules ==--

if not pcall(require, "lfs") then fail("Could not load luafilesystem, please make sure it's installed using luarocks first!") end
local lfs = require("lfs")
if not pcall(require, "JSON") then fail("Could not load JSON module, please make sure that the script is executed with the repository being the working directory!") end
local JSON = require("JSON")

--== Validate the JSON files ==--

ANSI.setGraphicsMode(0, 37) --Light grey output
print("")
print("Documentation JSON files validation script (ValidateJSON.lua) by Rami Sabbagh (RamiLego4Game)")
print("Using specification 2019-11-17")
print("")

ANSI.setGraphicsMode(0, 1, 34) --Blue output
print("Validating the JSON files.")
print("")

local function isFile(path)
	local mode, err = lfs.attributes(path, "mode")
	return mode and mode == "file"
end

local function isDirectory(path)
	local mode, err = lfs.attributes(path, "mode")
	return mode and mode == "directory"
end

ANSI.setGraphicsMode(0, 1, 36) --Cyan output

local currentFile

function JSON:onDecodeError(message, text, location, etc)
    if location then
        local lastLine = 0 --The offset of the last newline character before the error position
        local lineNumber = 1 --The number of the line where the decoding error happens
        
        --Count the lines and record the last newline character offset
        for position=1, location do
            local char = text:sub(position, position)
            if char == "\n" then
                lineNumber = lineNumber + 1
                lastLine = position
            elseif char == "\r" then
                lastLine = position
            end
        end

        local nextLine = text:find("\n", lastLine+1) or #text+1 --Find the next new line offset after the error
        local characterPosition = location - lastLine --Calculate the position of the error character in the line
        local line = text:sub(lastLine+1, nextLine-1) --The line where the error happened
        
        ANSI.setGraphicsMode(0, 1, 31) --Red output
        print("Failed to decode \""..currentFile.."\":")
        print("\tReason:\t"..message)
        print("\t(line #"..lineNumber.."   character #"..characterPosition.."   byte #"..location..")")
        print("")
        print("Source line:")
        print("------------")
        print("")
        print(line)
        print(string.rep("~", characterPosition-1).."^")
        print("")
        ANSI.setGraphicsMode(0, 1, 37) --White output
        os.exit(1)
	else
		fail("Failed to decode \""..currentFile.."\":\t"..message.."\tUnkown location...")
	end
end

local function indexDirectory(path)
    print("Validating JSON files in \""..path:sub(1,-2).."\".")
    for item in lfs.dir(path) do
        if item ~= "." and item ~= ".." then
            if isDirectory(path..item) then
                indexDirectory(path..item.."/")
            elseif item:sub(-5,-1) == ".json" then
                local jsonFile = assert(io.open(path..item, "r"))
                local jsonData = assert(jsonFile:read("*a"))
                assert(jsonFile:close())

                currentFile = path..item

                JSON:decode(jsonData)
            end
        end
    end
end

indexDirectory("Engine_Documentation/")

--== The end of the script ==--

local endClock = os.clock()
local executionTime = endClock - startClock

ANSI.setGraphicsMode(0, 1, 32) --Green output
print("")
print("The documentation files structure has been validated successfully in "..executionTime.."s.")
print("")

ANSI.setGraphicsMode(0, 1, 37) --White output