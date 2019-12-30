--This script reformats all the JSON files in the Engine_Documentation directory
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

--== Reformat JSON files ==--

ANSI.setGraphicsMode(0, 37) --Light grey output
print("")
print("Documentation JSON files reformatting script (ReformatJSON.lua) by Rami Sabbagh (RamiLego4Game)")
print("Using specification 2019-11-17")
print("")

ANSI.setGraphicsMode(0, 1, 34) --Blue output
print("Refromatting the JSON files.")
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

local newFormat = {
    pretty = true,
    indent = "\t",
    align_keys = false,
    array_newline = false
}

local function indexDirectory(path)
    print("Reformatting JSON files in \""..path:sub(1,-2).."\".")
    for item in lfs.dir(path) do
        if item ~= "." and item ~= ".." then
            if isDirectory(path..item) then
                indexDirectory(path..item.."/")
            elseif item:sub(-5,-1) == ".json" then
                local jsonFile = assert(io.open(path..item, "r"))
                local jsonData = assert(jsonFile:read("*a"))
                assert(jsonFile:close())

                currentFile = path..item

                local data = JSON:decode(jsonData)
                jsonData = JSON:encode(data, _, newFormat)

                jsonFile = assert(io.open(path..item, "w"))
                jsonFile:write(jsonData)
                jsonFile:close()
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
print("The documentation JSON files has been reformatted successfully in "..executionTime.."s.")
print("")

ANSI.setGraphicsMode(0, 1, 37) --White output