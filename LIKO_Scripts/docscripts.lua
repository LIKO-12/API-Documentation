local JSON = fs.load("C:/Libraries/JSON.lua")()
local term = require("terminal")

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
  
  local errors = {}
  local error

  local base = {}
  if fs.exists(path..dirName..".json") then
    base = JSON:decode(fs.read(path..dirName..".json"))
  end
  
  for id, name in ipairs(fs.getDirectoryItems(path)) do
    if fs.isFile(path..name) then
      if name:sub(-5,-1) == ".json" then
        base[name:sub(1,-6)], error = JSON:decode(fs.read(path..name))
        if error then
          table.insert(errors, error)
        end
      end
    else
      base[name] = loadDirectory(path..name.."/")
    end
  end
  
  return base, errors
end

local function parseargs(args)
  local verbose = false
  local path = "D:/JSON_Source/Peripherals/"
  for key, value in ipairs(args) do
    if value == "-v" or value == "--verbose" then
      verbose = true
    elseif value == "-p" or value == "--path" then
      path = term.resolve(args[key+1])
    end
  end
  return verbose, path
end

return {log = log, clog = clog, loadDirectory = loadDirectory, parseargs = parseargs}