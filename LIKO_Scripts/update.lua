--Load JSON library
local JSON = fs.load("C:/Libraries/JSON.lua")()
local function log(c,...)
  color(c)
  local t = table.concat({...}," ")
  cprint(...)
  print(t)
  flip()
end

--Improve the JSON error message, so it prints which line and which char the error is at.
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

local standardTypes = {number = true, string = true, boolean = true, table = true,any = true,["function"] = true}

local function updateArguments(oldargs)
  local nargs = {}
  
  if not oldargs then return nargs end
  
  for i, old in pairs(oldargs) do
    local new = {}
    
    new.type = old.type
    
    if type(new.type) == "table" then
      if new.type[#new.type] == "nil" then
        new.type[#new.type] = nil
        old.default = old.default or "nil"
      end
      
      if #new.type == 1 then
        new.type = new.type[1]
      end
      
      if type(new.type) == "string" then
        if not standardTypes[new.type] then
          if new.type:lower() == "imagedata" then
            new.type = {{"Peripherals","GPU","imageData"}}
          elseif new.type:lower() == "image" then
            new.type = {{"Peripherals","GPU","image"}}
          elseif new.type:lower() == "quad" then
            new.type = {{"Peripherals","GPU","quad"}}
          elseif new.type:lower() == "spritebatch" then
            new.type = {{"Peripherals","GPU","spriteBatch"}}
          else
            error("NON-STANDARD TYPE: "..new.type)
          end
        end
      end
    elseif not standardTypes[new.type] then
      if new.type:lower() == "imagedata" then
        new.type = {{"Peripherals","GPU","imageData"}}
      elseif new.type:lower() == "image" then
        new.type = {{"Peripherals","GPU","image"}}
      elseif new.type:lower() == "quad" then
        new.type = {{"Peripherals","GPU","quad"}}
      elseif new.type:lower() == "spritebatch" then
        new.type = {{"Peripherals","GPU","spriteBatch"}}
      else
        error("NON-STANDARD TYPE: "..new.type)
      end
    end
    
    if old.value then
      new.default = old.value
      
      if new.type == "number" then
        new.default = tonumber(new.default)
      end
    else
      new.name = old.name
      new.description = old.desc or ""
      
      new.default = old.default
      
      if new.type == "number" then
        new.default = tonumber(new.default)
      end
    end
    
    nargs[i] = new
  end
  
  return nargs
end

local function updateReturns(oldrets)
  local nrets = {}
  
  if not oldrets then return nrets end
  
  for i,old in pairs(oldrets) do
    local new = {}
    
    new.name = old.name
    new.type = old.type
    new.description = old.desc or ""
    new.optional = old.optional
    
    if not standardTypes[new.type] then
      if new.type:lower() == "imagedata" then
        new.type = {{"Peripherals","GPU","imageData"}}
      elseif new.type:lower() == "image" then
        new.type = {{"Peripherals","GPU","image"}}
      elseif new.type:lower() == "quad" then
        new.type = {{"Peripherals","GPU","quad"}}
      elseif new.type:lower() == "spritebatch" then
        new.type = {{"Peripherals","GPU","spriteBatch"}}
      else
        error("NON-STANDARD TYPE: "..new.type)
      end
    end
    
    nrets[i] = new
  end
  
  return nrets
end

local function updateMethod(old,object)
  local new = {}
  
  new.availableSince = {{1,0,0},{0,6,0}}
  new.lastUpdatedIn = {{1,0,0},{0,6,0}}
  new.shortDescription = old.desc or ""
  new.note = old.note
  new.notes = old.notes
  
  if old.Usages or old.Usage or old.usage or old.usages then
    new.usages = {}
    
    for i, usage in pairs(old.Usages or old.Usage or old.usage or old.usages) do
      local nusage = {}
      
      nusage.name = usage.name
      nusage.shortDescription = usage.desc
      nusage.note = usage.note
      nusage.notes = usage.notes
      nusage.self = object
      nusage.arguments = updateArguments(usage.args)
      nusage.returns = updateReturns(usage.rets)
      
      new.usages[i] = nusage
    end
  else
    new.self = object
    new.arguments = updateArguments(old.args)
    new.returns = updateReturns(old.rets)
  end
  
  return new
end

local function updateMethods()
  local path = "D:/JSON_Old/Peripherals/"
  local wpath = "D:/JSON_Updated/Peripherals/"
  
  for _,peripheral in ipairs(fs.getDirectoryItems(path)) do
    log(6,"- ",peripheral)
    
    --Peripheral methods
    local methodsPath = path..peripheral.."/methods/"
    for _,method in ipairs(fs.getDirectoryItems(methodsPath)) do
      log(5,method)
      
      local methodPath = methodsPath..method
      local methodJSON = fs.read(methodPath)
      local methodData = JSON:decode(methodJSON)
      methodData = updateMethod(methodData)
      methodJSON = JSON:encode(methodData,nil,{
        pretty = true,
        indent = "\t",
        align_keys = false,
        array_newline = false
      })
      fs.write(wpath..peripheral.."/methods/"..method,methodJSON)
    end
    
    --Objects methods
    local objectsPath = path..peripheral.."/objects/"
    if fs.exists(objectsPath) then
      for _, objectName in ipairs(fs.getDirectoryItems(objectsPath)) do
        
        log(6,"- ",peripheral," - ",objectName)
        
        local methodsPath = objectsPath..objectName.."/methods/"
        
        for _,method in ipairs(fs.getDirectoryItems(methodsPath)) do
          log(5,method)
          
          local methodPath = methodsPath..method
          local methodJSON = fs.read(methodPath)
          local methodData = JSON:decode(methodJSON)
          methodData = updateMethod(methodData)
          methodJSON = JSON:encode(methodData,nil,{
            pretty = true,
            indent = "\t",
            align_keys = false,
            array_newline = false
          })
          fs.write(wpath..peripheral.."/objects/"..objectName.."/methods/"..method,methodJSON)
        end
      end
    end
  end
end

updateMethods()

color(11) print("Updated successfully.")