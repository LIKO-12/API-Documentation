local JSON = fs.load("C:/Libraries/JSON.lua")()
local function log(...)
  local t = table.concat({...}," ")
  cprint(...)
  print(t)
  flip()
end

function JSON:onDecodeError(message, text, location)
  local counter, charPos, line = 0,0,0
  
  if location then
    for char in text:gmatch(".") do
      counter, charPos, location = counter + 1,charPos + 1, location -1
      if char == "\n" then charPos, line = 0, line + 1 end
      if location == 0 then break end
    end
    
    error("Failed to decode: "..message.."at line #"..line..", char #"..charPos..", byte #"..location)
  else
    error("Failed to decode: "..message..", unknown location.")
  end
end

local paths = {}
local decoded = {}

local function indexFolder(p)
  local items = fs.getDirectoryItems(p)
  for id,name in ipairs(items) do
    if fs.isFile(p..name) then
      if name:sub(-5,-1) == ".json" then
        table.insert(paths,p..name)
      end
    else
      indexFolder(p..name.."/")
    end
  end
end

indexFolder("D:/JSON_Source/")

color(12) log("Verifying JSON files") color(5)

for id, path in ipairs(paths) do
  local data = fs.read(path)
  log(id.."/"..#paths,path)
  decoded[id] = JSON:decode(data)
end

color(12) log("Verified all JSONs successfully.")