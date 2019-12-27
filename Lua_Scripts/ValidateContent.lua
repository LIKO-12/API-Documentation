--This script validates that all the JSON files in the Engine-Documentation directory follow the data structure defined in the specification.
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
if not pcall(require, "JSON") then fail("Could not load JSON module, please make sure that the script is executed with the repository being the working directory!") end
local JSON = require("JSON")

--== Validate the files content ==--

ANSI.setGraphicsMode(0, 37) --Light grey output
print("")
print("Documentation files content validation script (ValidateContent.lua) by Rami Sabbagh (RamiLego4Game)")
print("Using specification 2019-11-17")
print("")

ANSI.setGraphicsMode(0, 1, 34) --Blue output
print("Validating the files content.")
print("")

--== Validate Engine_Documentation ==--

local simpleTypes = {"number", "string", "boolean", "nil", "table", "userdata", "function"}
for k,v in ipairs(simpleTypes) do simpleTypes[v] = k end

--Returns true if the type was valid, false otherwise, with reason followed
local function validateType(vtype)
	if type(vtype) == "string" then
		--Check if it's the any type
		if vtype == "any" then return true end

		--Check if it's a simple type
		if simpleTypes[vtype] then return true end

		--Otherwise it's an invalid type
		return false, "Invalid simple type: "..vtype.."!"

	elseif type(vtype) == "table" then
		local l1 = #vtype
		if l1 == 0 then return false, "The type as a table of types must not be empty!" end
		for k1, v1 in pairs(vtype) do
			if type(k1) ~= "number" or k1 > l1 or k1 < 1 or k1 ~= math.floor(k1) then return false, "The type as a table of types can be only an array of continuous values!" end

			if type(v1) == "string" then
				if v1 == "any" then return false, "The \"any\" type can't be used in a table of types!" end
				if not simpleTypes[v1] then return false, "Invalid simple type: "..vtype.."!" end

			elseif type(v1) == "table" then --Complex type
				--Make sure that it's a valid array
				local l2 = #v1
				if l2 == 0 then return false, "The complex type in the table of types at index #"..k1.." must not be an empty array!" end
				for k2, v2 in pairs(v1) do
					if type(k2) ~= "number" or k2 > l2 or k2 < 1 or k2 ~= math.floor(k2) then return false, "The complex type in the table of types at index #"..k1..": can be only an array of continuous values!" end
					if type(v2) ~= "string" then return false, "The complex type in the table of types at index #"..k1..": has a non-string value!" end
				end

				--Make sure that it's a valid path
				local complexPath = table.concat(v1, "/") .. "/" .. v1[l2] .. ".json"
				if l2 < 2 or v1[l1-1] ~= "objects" or not isFile(complexPath) then return false, "Invalid object path for the complex type in the table of types at index #"..k1.."!" end
			else
				return false, "Invalid type of a type value in the types table at index #"..k1..": "..type(v1)..", it can be only a string or a table!"
			end
		end

		return true --Validated successfully
	else
		return false, "Invalid type of the type value: "..type(vtype)..", it can be only a string or a table!"
	end
end

--Returns true if the version was valid, false otherwise, with reason followed
local function validateVersion(version)
	if type(version) ~= "table" then return false, "The version must be a table, provided: "..type(version).."!" end
	if #version ~= 2 then return false, "The version must be an array (table) with exactly 2 tables in it only!" end

	for k,v in pairs(version) do
		if type(k) ~= "number" or k > 2 or k < 1 or k ~= math.floor(k) or type(v) ~= "table" then return false, "The version must be an array (table) with exactly 2 tables in it only!" end
	end

	if #version[1] ~= 3 then return false, "The category version must be an array of 3 natural numbers!" end
	for k,v in pairs(version[1]) do
		if type(k) ~= "number" or k > 3 or k < 1 or k ~= math.floor(k) or type(v) ~= "number" or v < 0 or v ~= math.floor(v) then
			return false, "The category version must be an array of 3 natural numbers!"
		end
	end

	if #version[2] ~= 3 then return false, "The LIKO-12 version must be an array of 3 natural numbers!" end
	for k,v in pairs(version[2]) do
		if type(k) ~= "number" or k > 3 or k < 1 or k ~= math.floor(k) or type(v) ~= "number" or v < 0 or v ~= math.floor(v) then
			return false, "The LIKO-12 version must be an array of 3 natural numbers!"
		end
	end

	--Validated successfully
	return true
end

--Returns true if the date was valid, false otherwise, with reason followed
local function validateDate(date)
	if type(date) ~= "string" then return false, "The date can be only a string, provided: "..type(date).."" end
	if not date:match("%d%d%d%d%-%d%d%-%d%d") then return false, "Invalid date: "..date.."!" end

	--For the sake of simplicity I'm not going to validate if the month has 31 or 30 days, especially that some years are longer then others by 1 day (in an integer system)...

	local month = tonumber(date:sub(6,7))
	local day = tonumber(date:sub(9,10))

	if month < 1 or month > 12 then return false, "Invalid month ("..month..") in date: "..date.."!" end
	if day < 1 or day > 31 then return false, "Invalid day ("..day..") in date: "..date.."!" end

	return true
end

--Returns true if the value was a simple text string with no control charactes, false otherwise, with reason followed
local function validateSimpleText(text)
	if type(text) ~= "string" then return false, "It must be a string, not a "..type(text).."!" end

	for i=1, #text do
		local c = string.byte(text, i)
		if c < 32 or c == 127 then return false, "Control characters (including new line) are not allowed, found one at "..i.."!" end
	end

	return true
end

--Returns true if the notes was valid, false otherwise, with reason followed
local function validateNotes(notes)
	if type(notes) ~= "table" then return false, "It must be a table, not a "..type(notes).."!" end
	
	local length = #notes
	for k,v in pairs(notes) do
		if type(k) ~= "number" or k < 1 or k > length or k ~= math.floor(k) or type(v) ~= "string" then
			return false, "Notes must be an array of strings with continuous values!"
		end
	end

	return true
end

--Returns true if the field was valid, false otherwise, with reason followed
local function validateField(field)
	--Every field that's been validated is set to nil => This function destroys the data it has been passed
	--Why doing so? Inorder to find any unwanted extra values in the data

	local ok1, reason1 = validateVersion(field.availableSince)
	if not ok1 then return false, "Failed to validate 'availableSince': "..reason1 end
	field.availableSince = nil

	local ok2, reason2 = validateVersion(field.lastUpdatedIn)
	if not ok2 then return false, "Failed to validate 'lastUpdatedIn': "..reason2 end
	field.lastUpdatedIn = nil

	if type(field.shortDescription) ~= "nil" then
		local ok3, reason3 = validateSimpleText(field.shortDescription)
		if not ok3 then return false, "Failed to validate 'shortDescription': "..reason3 end
		field.shortDescription = nil
	end

	if type(field.longDescription) ~= "nil" and type(field.longDescription) ~= "string" then
		return false, "Failed to validate 'longDescription': It must be a string!"
	end
	field.longDescription = nil

	if type(field.notes) ~= "nil" then
		local ok4, reason4 = validateNotes(field.notes)
		if not ok4 then return false, "Failed to validate 'notes': "..reason4 end
		field.notes = nil
	end

	if type(field.extra) ~= "nil" and type(field.extra) ~= "string" then
		return false, "Failed to validate 'extra': It must be a string!"
	end
	field.extra = nil

	local ok5, reason5 = validateType(field.type)
	if not ok5 then return false, "Failed to validate 'type': "..reason5 end
	field.type = nil

	if type(field.protected) ~= "nil" and type(field.protected) ~= "boolean" then
		return false, "Failed to validate 'protected': It must be a boolean!"
	end
	field.protected = nil

	--Reject any extra data in the field
	for k,v in pairs(field) do
		if type(v) ~= "nil" then
			return false, "Invalid data field with the key: "..k.."!"
		end
	end

	--Validated successfully
	return true
end

--Returns true if the arguments were valid, false otherwise, with reason followed
local function validateMethodArguments(arguments)
	--Every field that's been validated is set to nil => This function destroys the data it has been passed
	--Why doing so? Inorder to find any unwanted extra values in the data

	local count = #argumets
	if count == 0 then return false, "It must not be empty when specified!" end
	for k, argument in pairs(arguments) do
		if type(k) ~= "number" or k < 1 or k > count or k ~= math.floor(k) or type(argument) ~= "table" then
			return false, "Invalid arguments entry with the index: "..k.."!"
		end

		if type(argument.default) == "nil" and type(argument.name) == "nil" then
			return false, "The 'name' field must be specified when the 'default' field is not set!"
		end

		if type(argument.name) ~= "nil" then
			local ok1, reason1 = validateSimpleText(argument.name)
			if not ok1 then return false, "Failed to validate 'name' field of the #"..k.." argument: "..reason1 end
			argument.name = nil
		end

		local ok2, reason2 = validateType(argument.type)
		if not ok2 then return false, "Failed to validate 'type' field of the #"..k.." argument: "..reason2 end
		argument.type = nil

		if type(argument.description) ~= "nil" then
			local ok3, reason3 = validateSimpleText(argument.description)
			if not ok3 then return false, "Failed to validate 'description' field of the #"..k.." argument: "..reason3 end
			argument.description = nil
		end

		if type(argument.default) ~= "nil" and type(argument.default) ~= "string" then
			return false, "Failed to validate 'default' field of the #"..k.." argument: It must be a string!"
		end
		argument.default = nil

		--Reject any extra data in the argument
		for k,v in pairs(argument) do
			if type(v) ~= "nil" then
				return false, "Invalid data field with the key: "..k.."!"
			end
		end
	end

	--Validated successfully
	return true
end

--Returns true if the returns were valid, false otherwise, with reason followed
local function validateMethodReturns(returns)
	--Every field that's been validated is set to nil => This function destroys the data it has been passed
	--Why doing so? Inorder to find any unwanted extra values in the data

	local count = #returns
	if count == 0 then return false, "It must not be empty when specified!" end
	for k, ret in pairs(returns) do
		if type(k) ~= "number" or k < 1 or k > count or k ~= math.floor(k) or type(ret) ~= "table" then
			return false, "Invalid returns entry with the index: "..k.."!"
		end

		local ok1, reason1 = validateSimpleText(ret.name)
		if not ok1 then return false, "Failed to validate 'name': "..reason1 end
		ret.name = nil

		local ok2, reason2 = validateType(ret.type)
		if not ok2 then return false, "Failed to validate 'type': "..reason2 end
		ret.type = nil

		if type(ret.description) ~= "nil" then
			local ok3, reason3 = validateSimpleText(ret.description)
			if not ok3 then return false, "Failed to validate 'description': "..reason3 end
			ret.description = nil
		end

		--Reject any extra data in the return
		for k,v in pairs(ret) do
			if type(v) ~= "nil" then
				return false, "Invalid data field with the key: "..k.."!"
			end
		end
	end

	--Validated successfully
	return true
end

--Returns true if the method was valid, false otherwise, with reason followed
local function validateMethod(method)
	--Every field that's been validated is set to nil => This function destroys the data it has been passed
	--Why doing so? Inorder to find any unwanted extra values in the data

	local ok1, reason1 = validateVersion(method.availableSince)
	if not ok1 then return false, "Failed to validate 'availableSince': "..reason1 end
	method.availableSince = nil

	local ok2, reason2 = validateVersion(method.lastUpdatedIn)
	if not ok2 then return false, "Failed to validate 'lastUpdatedIn': "..reason2 end
	method.lastUpdatedIn = nil

	if type(method.shortDescription) ~= "nil" then
		local ok3, reason3 = validateSimpleText(method.shortDescription)
		if not ok3 then return false, "Failed to validate 'shortDescription': "..reason3 end
		method.shortDescription = nil
	end

	if type(method.longDescription) ~= "nil" and type(method.longDescription) ~= "string" then
		return false, "Failed to validate 'longDescription': It must be a string!"
	end
	method.longDescription = nil

	if type(method.notes) ~= "nil" then
		local ok4, reason4 = validateNotes(method.notes)
		if not ok4 then return false, "Failed to validate 'notes': "..reason4 end
		method.notes = nil
	end

	if type(method.extra) ~= "nil" and type(method.extra) ~= "string" then
		return false, "Failed to validate 'extra': It must be a string!"
	end
	method.extra = nil

	if type(method.self) ~= "nil" and type(method.self) ~= "boolean" then
		return false, "Failed to validate 'self': It must be a boolean!"
	end
	method.self = nil

	if type(method.usages) == "table" then
		if type(method.arguments) ~= "nil" or type(method.returns) ~= "nil" then
			return false, "Arguments and returns do not exist in the multi-usage varient!"
		end

		local count = #method.usages
		if count == 0 then return false, "Failed to validate 'usages': It must not be empty!" end
		for k, usage in pairs(method.usages) do
			if type(k) ~= "number" or k < 1 or k > count or k ~= math.floor(k) or type(usage) ~= "table" then
				return false, "Failed to validate 'usages': Invalid array!"
			end

			local ok4, reason4 = validateSimpleText(usage.name)
			if not ok4 then return false, "Failed to validate 'name' in the #"..k.." usage: "..reason4 end
			usage.name = nil

			if type(usage.shortDescription) ~= "nil" then
				local ok5, reason5 = validateSimpleText(usage.shortDescription)
				if not ok5 then return false, "Failed to validate 'shortDescription' in the #"..k.." usage: "..reason5 end
				usage.shortDescription = nil
			end

			if type(usage.longDescription) ~= "nil" and type(usage.longDescription) ~= "string" then
				return false, "Failed to validate 'longDescription' in the #"..k.." usage: It must be a string!"
			end
			usage.longDescription = nil

			if type(usage.note) ~= "nil" then
				local ok6, reason6 = validateSimpleText(usage.note)
				if not ok6 then return false, "Failed to validate 'note' in the #"..k.." usage: "..reason6 end
				usage.note = nil
			end

			if type(usage.notes) ~= "nil" then
				local ok7, reason7 = validateNotes(usage.notes)
				if not ok7 then return false, "Failed to validate 'notes' in the #"..k.." usage: "..reason7 end
				usage.notes = nil
			end

			if type(usage.extra) ~= "nil" and type(usage.extra) ~= "string" then
				return false, "Failed to validate 'extra' in the #"..k.." usage: It must be a string!"
			end
			usage.extra = nil

			if type(usage.arguments) ~= "nil" then
				local ok8, reason8 = validateMethodArguments(usage.arguments)
				if not ok8 then return false, "Failed to validate 'arguments' in the #"..k.." usage: "..reason8 end
				usage.arguments = nil
			end

			if type(usage.returns) ~= "nil" then
				local ok9, reason9 = validateMethodReturns(usage.returns)
				if not ok9 then return false, "Failed to validate 'returns' in the #"..k.." usage: "..reason9 end
				usage.returns = nil
			end

			--Reject any extra data in the usage
			for k,v in pairs(usage) do
				if type(v) ~= "nil" then
					return false, "Invalid data field with the key: "..k.."!"
				end
			end
		end

	elseif type(method.usages) ~= "nil" then
		return false, "Failed to validate 'usages': It must be a table!"
	else
		if type(method.arguments) ~= "nil" then
			local ok10, reason10 = validateMethodArguments(method.arguments)
			if not ok10 then return false, "Failed to validate 'arguments': "..reason10 end
			method.arguments = nil
		end

		if type(method.returns) ~= "nil" then
			local ok11, reason11 = validateMethodReturns(method.returns)
			if not ok11 then return false, "Failed to validate 'returns': "..reason11 end
			method.returns = nil
		end
	end

	--Reject any extra data in the method
	for k,v in pairs(method) do
		if type(v) ~= "nil" then
			return false, "Invalid data field with the key: "..k.."!"
		end
	end

	--Validated successfully
	return true
end

--Returns true if the arguments were valid, false otherwise, with reason followed
local function validateEventsArguments(arguments)
	--Every field that's been validated is set to nil => This function destroys the data it has been passed
	--Why doing so? Inorder to find any unwanted extra values in the data

	local count = #arguments
	if count == 0 then return false, "It must not be empty when specified!" end
	for k, argument in pairs(arguments) do
		if type(k) ~= "number" or k < 1 or k > count or k ~= math.floor(k) or type(argument) ~= "table" then
			return false, "Invalid arguments entry with the index: "..k.."!"
		end

		local ok1, reason1 = validateSimpleText(argument.name)
		if not ok1 then return false, "Failed to validate 'name': "..reason1 end
		argument.name = nil

		local ok2, reason2 = validateType(argument.type)
		if not ok2 then return false, "Failed to validate 'type': "..reason2 end
		argument.type = nil

		if type(argument.description) ~= "nil" then
			local ok3, reason3 = validateSimpleText(argument.description)
			if not ok3 then return false, "Failed to validate 'description': "..reason3 end
			argument.description = nil
		end

		--Reject any extra data in the argument
		for k,v in pairs(argument) do
			if type(v) ~= "nil" then
				return false, "Invalid data field with the key: "..k.."!"
			end
		end
	end

	--Validated successfully
	return true
end

--Returns true if the event was valid, false otherwise, with reason followed
local function validateEvent(event)
	--Every field that's been validated is set to nil => This function destroys the data it has been passed
	--Why doing so? Inorder to find any unwanted extra values in the data

	local ok1, reason1 = validateVersion(event.availableSince)
	if not ok1 then return false, "Failed to validate 'availableSince': "..reason1 end
	event.availableSince = nil

	local ok2, reason2 = validateVersion(event.lastUpdatedIn)
	if not ok2 then return false, "Failed to validate 'lastUpdatedIn': "..reason2 end
	event.lastUpdatedIn = nil

	if type(event.shortDescription) ~= "nil" then
		local ok3, reason3 = validateSimpleText(event.shortDescription)
		if not ok3 then return false, "Failed to validate 'shortDescription': "..reason3 end
		event.shortDescription = nil
	end

	if type(event.longDescription) ~= "nil" and type(event.longDescription) ~= "string" then
		return false, "Failed to validate 'longDescription': It must be a string!"
	end
	event.longDescription = nil

	if type(event.notes) ~= "nil" then
		local ok4, reason4 = validateNotes(event.notes)
		if not ok4 then return false, "Failed to validate 'notes': "..reason4 end
		event.notes = nil
	end

	if type(event.extra) ~= "nil" and type(event.extra) ~= "string" then
		return false, "Failed to validate 'extra': It must be a string!"
	end
	event.extra = nil

	if type(event.arguments) ~= "nil" then
		local ok5, reason5 = validateEventsArguments(event.arguments)
		if not ok5 then return false, "Failed to validate 'arguments': "..reason5 end
		event.arguments = nil
	end

	--Reject any extra data in the event
	for k,v in pairs(event) do
		if type(v) ~= "nil" then
			return false, "Invalid data field with the key: "..k.."!"
		end
	end

	--Validated successfully
	return true
end

--Returns true if the peripheral meta was valid, false otherwise, with reason followed
local function validatePeripheralMeta(meta)
	--Every field that's been validated is set to nil => This function destroys the data it has been passed
	--Why doing so? Inorder to find any unwanted extra values in the data

	if type(meta.version) ~= "table" then return false, "Failed to validate 'version': It must be a table!" end
	local ok1, reason1 = validateVersion({meta.version, {0,0,0}})
	if not ok1 then return false, "Failed to validate 'version': "..reason1 end
	meta.version = nil

	if type(meta.availableSince) ~= "table" then return false, "Failed to validate 'availableSince': It must be a table!" end
	local ok2, reason2 = validateVersion({{0,0,0}, meta.availableSince})
	if not ok2 then return false, "Failed to validate 'availableSince': "..reason2 end
	meta.availableSince = nil

	if type(meta.lastUpdatedIn) ~= "table" then return false, "Failed to validate 'lastUpdatedIn': It must be a table!" end
	local ok3, reason3 = validateVersion({{0,0,0}, meta.lastUpdatedIn})
	if not ok3 then return false, "Failed to validate 'lastUpdatedIn': "..reason3 end
	meta.lastUpdatedIn = nil

	local ok4, reason4 = validateSimpleText(meta.name)
	if not ok4 then return false, "Failed to validate 'name': "..reason4 end
	meta.name = nil

	local ok5, reason5 = validateSimpleText(meta.shortDescription)
	if not ok5 then return false, "Failed to validate 'shortDescription': "..reason5 end
	meta.shortDescription = nil

	if type(meta.fullDescription) ~= "nil" and type(meta.fullDescription) ~= "string" then
		return false, "Failed to validate 'fullDescription': It must be a string!"
	end
	meta.fullDescription = nil

	--Reject any extra data in the peripheral meta
	for k,v in pairs(meta) do
		if type(v) ~= "nil" then
			return false, "Invalid data field with the key: "..k.."!"
		end
	end

	--Validated successfully
	return true
end

--Returns true if the object meta was valid, false otherwise, with reason followed
local function validateObjectMeta(meta)
	--Every field that's been validated is set to nil => This function destroys the data it has been passed
	--Why doing so? Inorder to find any unwanted extra values in the data

	local ok1, reason1 = validateVersion(meta.availableSince)
	if not ok1 then return false, "Failed to validate 'availableSince': "..reason1 end
	meta.availableSince = nil

	local ok2, reason2 = validateVersion(meta.lastUpdatedIn)
	if not ok2 then return false, "Failed to validate 'lastUpdatedIn': "..reason2 end
	meta.lastUpdatedIn = nil

	if type(meta.shortDescription) ~= "nil" then
		local ok3, reason3 = validateSimpleText(meta.shortDescription)
		if not ok3 then return false, "Failed to validate 'shortDescription': "..reason3 end
		meta.shortDescription = nil
	end

	if type(meta.fullDescription) ~= "nil" and type(meta.fullDescription) ~= "string" then
		return false, "Failed to validate 'fullDescription': It must be a string!"
	end
	meta.fullDescription = nil

	if type(meta.notes) ~= "nil" then
		local ok4, reason4 = validateNotes(meta.notes)
		if not ok4 then return false, "Failed to validate 'notes': "..reason4 end
		meta.notes = nil
	end

	if type(meta.extra) ~= "nil" and type(meta.extra) ~= "string" then
		return false, "Failed to validate 'extra': It must be a string!"
	end
	meta.extra = nil

	--Reject any extra data in the object meta
	for k,v in pairs(meta) do
		if type(v) ~= "nil" then
			return false, "Invalid data field with the key: "..k.."!"
		end
	end

	--Validated successfully
	return true
end

--Returns true if the documentation meta was valid, false otherwise, with reason followed
local function validateDocumentationMeta(meta)
	--Every field that's been validated is set to nil => This function destroys the data it has been passed
	--Why doing so? Inorder to find any unwanted extra values in the data

	if type(meta.engineVersion) ~= "table" then return false, "Failed to validate 'engineVersion': It must be a table!" end
	local ok1, reason1 = validateVersion({{0,0,0}, meta.engineVersion})
	if not ok1 then return false, "Failed to validate 'engineVersion': "..reason1 end
	meta.engineVersion = nil

	local ok2, reason2 = validateDate(meta.revisionDate)
	if not ok2 then return false, "Failed to validate 'revisionDate': "..reason2 end
	meta.revisionDate = nil

	if type(meta.revisionNumber) ~= "number" or meta.revisionNumber < 0 or meta.revisionNumber ~= math.floor(meta.revisionNumber) then
		return false, "Failed to validate 'revisionNumber': It must be a natural number!"
	end
	meta.revisionNumber = nil

	local ok3, reason3 = validateDate(meta.specificationDate)
	if not ok3 then return false, "Failed to validate 'specificationDate': "..reason3 end
	meta.specificationDate = nil

	local ok4, reason4 = validateSimpleText(meta.specificationLink)
	if not ok4 then return false, "Failed to validate 'specificationLink': "..reason4 end
	meta.specificationLink = nil

	--Reject any extra data in the documentation meta
	for k,v in pairs(meta) do
		if type(v) ~= "nil" then
			return false, "Invalid data field with the key: "..k.."!"
		end
	end

	--Validated successfully
	return true
end

--== The end of the script ==--

local endClock = os.clock()
local executionTime = endClock - startClock

ANSI.setGraphicsMode(0, 1, 32) --Green output
print("")
print("The documentation files content has been validated successfully in "..executionTime.."s.")
print("")

ANSI.setGraphicsMode(0, 1, 37) --White output