--This script merges the files Engine_Documentation directory except the Media directory into a single .json file
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
print("Documentation merged JSON file generation script (GenerateMergedJSON.lua) by Rami Sabbagh (RamiLego4Game)")
print("Using specification 2019-11-17")
print("")

ANSI.setGraphicsMode(0, 1, 34) --Blue output
print("Loading the JSON files...")
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

local function loadJSONFile(path)
    local jsonFile = assert(io.open(path, "r"))
    local jsonData = assert(jsonFile:read("*a"))
    assert(jsonFile:close())

    return JSON:decode(jsonData)
end

local function indexDirectory(path, folderName)
    print("Loading files in \""..path:sub(1,-2).."\".")
    local folderData = {}

    if isFile(path..folderName..".json") then
        folderData = loadJSONFile(path..folderName..".json")
    end

    for item in lfs.dir(path) do
        if item ~= "." and item ~= ".." and (path ~= "Engine_Documentation/" or item ~= "Media") and item ~= folderName..".json" then
            if isDirectory(path..item) then
                folderData[item] = indexDirectory(path..item.."/", item)
            elseif item:sub(-5,-1) == ".json" then
                folderData[item:sub(1,-6)] = loadJSONFile(path..item)
            elseif item:sub(-3,-1) == ".md" then
                local mdFile = assert(io.open(path..item, "r"))
                folderData[item:sub(1,-4)] = assert(mdFile:read("*a"))
                assert(mdFile:close())
            else
                ANSI.setGraphicsMode(0, 33) --Orange output
                print("Ignored \""..path..item.."\".")
                ANSI.setGraphicsMode(0, 1, 36) --Cyan output
            end
        end
    end

    return folderData
end

local loadedData = indexDirectory("Engine_Documentation/", "Engine_Documentation")

ANSI.setGraphicsMode(0, 1, 34) --Blue output
print("")
print("Writing the merged JSON file...")

local mergedJSON = JSON:encode(loadedData)
local mergedFile = assert(io.open("Engine_Merged.json", "w"))
assert(mergedFile:write(mergedJSON))
assert(mergedFile:close())

local mergedJSONPretty = JSON:encode(loadedData, _, {pretty=true, indent="\t"})
local mergedFilePretty = assert(io.open("Engine_Merged_Pretty.json", "w"))
assert(mergedFilePretty:write(mergedJSONPretty))
assert(mergedFilePretty:close())

--== The end of the script ==--

local endClock = os.clock()
local executionTime = endClock - startClock

ANSI.setGraphicsMode(0, 1, 32) --Green output
print("")
print("The documentation merged JSON file has been generated successfully in "..executionTime.."s.")
print("")

ANSI.setGraphicsMode(0, 1, 37) --White output