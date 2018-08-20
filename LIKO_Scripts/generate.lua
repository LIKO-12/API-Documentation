
local JSON = fs.load("C:/Libraries/JSON.lua")()
local function log(c,...)
  color(c)
  local t = table.concat({...}," ")
  cprint(...)
  print(t)
  flip()
end

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

--Path should have a trailing /
local function loadDirectory(path)
  local dirName = fs.getName(path)
  
  local base = {}
  if fs.exists(path..dirName..".json") then
    --log(6,"* Decode: "..path..dirName..".json")
    base = JSON:decode(fs.read(path..dirName..".json"))
  end
  
  for id, name in ipairs(fs.getDirectoryItems(path)) do
    if fs.isFile(path..name) then
      if name:sub(-5,-1) == ".json" then
        --log(5,"* Decode: "..path..name)
        base[name:sub(1,-6)] = JSON:decode(fs.read(path..name))
      end
    else
      base[name] = loadDirectory(path..name.."/")
    end
  end
  
  return base
end

log(12,"Loading JSON...")

local JAPI = loadDirectory("D:/JSON_Source/")

log(12,"Generating Peripherals Markdown...")

fs.newDirectory("D:/MD_Generated/Peripherals/")

for pname, peripheral in pairs(JAPI.Peripherals) do
  log(6,pname)
  fs.newDirectory("D:/MD_Generated/Peripherals/"..pname)
  
  local preadme = "# "..pname.." - The "..peripheral.name.."\n---\n\n"
  
  if not peripheral.availableForGames then
    preadme = preadme.."!> This peripheral is not available for games.\n\n"
  end
  
  preadme = preadme..(peripheral.shortDescription or "!> Short Description is missing !").."\n\n---\n\n"
  preadme = preadme.."* **Version:** "..table.concat(peripheral.version,".").."\n"
  preadme = preadme.."* **Available since LIKO-12:** v"..table.concat(peripheral.availableSince,".").."\n"
  preadme = preadme.."* **Last updated in LIKO-12:** v"..table.concat(peripheral.lastUpdatedIn,".").."\n"
  
  if peripheral.methods then
    local mlist, moslist = {}, {}
    
    for mname, method in pairs(peripheral.methods) do
      local ttable = mname:sub(1,1) == "_" and moslist or mlist
      ttable[#ttable+1] = "* ["..mname.."](/Documentation/Peripherals/"..pname.."/"..mname..".md): "..(method.shortDescription or "**NO DESCRIPTION**")
    end
    
    table.sort(mlist)
    table.sort(moslist)
    
    if #mlist > 0 then
      preadme = preadme.."\n---\n## Methods\n---\n"..table.concat(mlist,"\n").."\n"
    end
    
    if #moslist > 0 then
      preadme = preadme.."\n---\n## OS Methods\n---\n!> Those methods are not available for games.\n"..table.concat(moslist,"\n").."\n"
    end
  end
  
  fs.write("D:/MD_Generated/Peripherals/"..pname.."/README.md",preadme)
end