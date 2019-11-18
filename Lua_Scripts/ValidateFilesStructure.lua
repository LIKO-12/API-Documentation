--This script validates that the filesystem is following the structure defined in the specification.
--Specification Implemented: 2019-11-17-Specification.md

--Code author: Rami Sabbagh (RamiLego4Game)

--Extend the package path so it search for the modules in the special directory.
package.path = "./Lua_Scripts/Modules/?.lua;./Lua_Scripts/Modules/?/init.lua;"..package.path

local startClock = os.clock()

--Load ANSI module
if not pcall(require,"ANSI") then print("\27[0;1;31mCould not load the ANSI module, please make sure that the script is executed with the repository being the working directory!\27[0;1;37m") os.exit(1) return end
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

if not pcall(require,"lfs") then fail("Could not load luafilesystem, please make sure it's installed using luarocks first!") end
local lfs = require("lfs")

--== Validate the files structure ==--

ANSI.setGraphicsMode(0, 37) --Light grey output
print("")
print("Documentation files structure validation script (ValidateFilesStructure.lua) by Rami Sabbagh (RamiLego4Game)")
print("Using specification 2019-11-17")
print("")

ANSI.setGraphicsMode(0, 1, 34) --Blue output
print("Validating the files structure.")
print("")

--== Validate Engine_Documentation ==--

local function isFile(path)
	local mode, err = lfs.attributes(path, "mode")
	return mode and mode == "file"
end

local function isDirectory(path)
	local mode, err = lfs.attributes(path, "mode")
	return mode and mode == "directory"
end

ANSI.setGraphicsMode(0, 1, 36) --Cyan output
print("Validating the structure of \"Engine_Documentation\".")

if not isDirectory("Engine_Documentation") then fail("The \"Engine_Documentation\" directory doesn't exist!") end
if not isFile("Engine_Documentation/Engine_Documentation.json") then fail("The \"Engine_Documentation/Engine_Documentation.json\" file doesn't exist!") end
if not isDirectory("Engine_Documentation/Media") then fail("The \"Engine_Documentation/Media\" directory doesn't exist!") end
if not isDirectory("Engine_Documentation/Peripherals") then fail("The \"Engine_Documentation/Peripherals\" directory doesn't exist!") end

--== Validate Engine_Documentation/Peripherals ==--

print("Validating the structure of \"Engine_Documentation/Peripherals\".")

local function validateMethods(dir)
	print("Validating the structure of \""..dir.."\".")
	for method in lfs.dir(dir) do
		if method ~= "." and method ~= ".." then
			if isDirectory(dir..method) then fail("Invalid directory \""..dir..method.."\"!") end
			if method:sub(-5,-1) ~= ".json" then fail("Invalid file \""..dir..method.."\"!") end
		end
	end
end

local function validateEvents(dir)
	print("Validating the structure of \""..dir.."\".")
	for event in lfs.dir(dir) do
		if event ~= "." and event ~= ".." then
			if isDirectory(dir..event) then fail("Invalid directory \""..dir..event.."\"!") end
			if event:sub(-5,-1) ~= ".json" then fail("Invalid file \""..dir..event.."\"!") end
		end
	end
end

local function validateFields(dir)
	print("Validating the structure of \""..dir.."\".")
	for field in lfs.dir(dir) do
		if field ~= "." and field ~= ".." then
			if isDirectory(dir..field) then fail("Invalid directory \""..dir..field.."\"!") end
			if field:sub(-5,-1) ~= ".json" then fail("Invalid file \""..dir..field.."\"!") end
		end
	end
end

local function validateDocuments(dir)
	print("Validating the structure of \""..dir.."\".")
	for document in lfs.dir(dir) do
		if document ~= "." and document ~= ".." then
			if isDirectory(dir..document) then fail("Invalid directory \""..dir..document.."\"!") end
			if document:sub(-3,-1) ~= ".md" then fail("Invalid file \""..dir..document.."\"!") end
		end
	end
end

local function validateObjects(dir)
	print("Validating the structure of \""..dir.."\".")
	for object in lfs.dir(dir) do
		if object ~= "." and object ~= ".." then
			if isFile(dir..object) then fail("Invalid directory \""..dir..object.."\"!") end

			print("Validating the structure of \""..dir..object.."\".")

			if not isFile(dir..object.."/"..object..".json") then fail("The file \""..dir..object.."/"..object..".json\" doesn't exist!") end

			for item in lfs.dir(dir..object) do
				if item ~= "." and item ~= ".." and item ~= object..".json" then
					local itemPath = dir..object.."/"..item

					if isFile(itemPath) then fail("Invalid file \""..itemPath.."\"!") end

					if item == "methods" then
						validateMethods(itemPath.."/")
					elseif item == "fields" then
						validateFields(itemPath.."/")
					elseif item == "documents" then
						validateDocuments(itemPath.."/")
					else
						fail("Unknown directory \""..itemPath.."\"!")
					end
				end
			end
		end
	end
end

local function validatePeripheral(name)
	local dir = "Engine_Documentation/Peripherals/"..name.."/"

	if name:find("%s") then fail("The peripheral name should not contain any whitespace! (\""..name.."\").") end
	if isFile(dir) then fail("Invalid file \""..dir.."\"!") end

	print("Validating the structure of \""..dir:sub(1,-2).."\".")

	if not isFile(dir..name..".json") then fail("The file \""..dir..name..".json\" doesn't exist!") end

	for item in lfs.dir(dir) do
		if item ~= "." and item ~= ".." and item ~= name..".json" then
			if isFile(dir..item) then fail("Invalid file \""..dir..item.."\"!") end

			if item == "methods" then
				validateMethods(dir.."methods/")
			elseif item == "objects" then
				validateObjects(dir.."objects/")
			elseif item == "events" then
				validateEvents(dir.."events/")
			elseif items == "documents" then
				validateDocuments(dir.."documents/")
			else
				fail("Unknown directory \""..dir..name.."\"!")
			end
		end
	end
end

for peripheralName in lfs.dir("Engine_Documentation/Peripherals/") do
	if peripheralName ~= "." and peripheralName ~= ".." then
		validatePeripheral(peripheralName)
	end
end

--== The end of the script ==--

local endClock = os.clock()
local executionTime = endClock - startClock

ANSI.setGraphicsMode(0, 1, 32) --Green output
print("")
print("The documentation files structure has been validated successfully in "..executionTime.."s.")
print("")

ANSI.setGraphicsMode(0, 1, 37) --White output