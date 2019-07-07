--A single file library for the shared documentation functions.

local JSON = fs.load("C:/Libraries/JSON.lua")()

--An improved JSON error handler
function JSON:onDecodeError(message, text, location)
	local counter = 0
	local charPos = 0
	local line = 0

	if location then
		for i=1, #text do
			local char = text:sub(i,i)
			counter = counter + 1
			charPos = charPos + 1
			if char == "\n" then
				charPos = 0
				line = line + 1
			end
			
			if counter == location then
				break
			end
		end
		
		error("Failed to decode: "..message.."at line #"..line.." char #"..charPos.." byte #"..location)
	else
		error("Failed to decode: "..message..", unknown location.")
	end
end

--Some logging functions
local function log(...)
	local t = table.concat({...}," ")
	cprint(...)
	print(t)
	flip()
end

local function clog(c, ...)
	color(c)
	log(...)
end

local du = {}

function du.loadJSON(path)
	--Make sure the path doesn't end with a /
	path = string.format("%s:/%s",fs.getDrive(path),fs.sanitizePath(path))

	--The loaded content of this directory
	local this = {}

	--The name of this directory
	local thisName = fs.getName(path)..".json"

	--The name of this directory .json file
	local thisJSON = path.."/"..thisName

	--Initialize this table with the content of the directory's .json file
	if fs.exists(thisJSON) then
		local data = fs.read(thisJSON)
		this = JSON:decode(data)
	end

	--Index the content of this directory
	local items = fs.getDirectoryItems(path.."/")
	for i=1, #items do
		local fname = items[i]
		local fpath = path.."/"..fname

		--A nested directory
		if fs.isDirectory(fpath) then
			this[fname] = du.loadJSON(fpath)

		--A sub .JSON file
		elseif fname ~= thisName then
			local data = fs.read(fpath)
			this[fname:sub(1,-6)] = JSON:decode(data)
		end
	end

	return this
end

return du