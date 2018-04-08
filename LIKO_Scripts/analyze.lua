
local JSON = require("Libraries.JSON")
local function log(...)
  local t = table.concat({...}," ")
  cprint(...)
  print(t)
  flip()
end

local paths = {}
local decoded = {}
local anadata = {}

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

indexFolder("D:/DOCS/")

color(12) log("Verifying JSON files") color(5)

for id, path in ipairs(paths) do
  local data = fs.read(path)
  log(id.."/"..#paths,path)
  decoded[id] = JSON:decode(data)
end

color(12) log("Collecting variables types") color(5)

local temptypes = {}

local function indexTypes(t)
  for _, v1 in ipairs(t) do
    if type(v1.type) == "table" then
      for _, v2 in ipairs(v1.type) do
        temptypes[v2] = true
      end
    else
      temptypes[v1.type] = true
    end
  end
end

color(5)

for id, data in ipairs(decoded) do
  log(id.."/"..#paths,paths[id])
  if data.Usage then
    for _,usage in ipairs(data.Usage) do
      if usage.args then indexTypes(usage.args) end
      if usage.rets then indexTypes(usage.rets) end
    end
  else
    if data.args then indexTypes(data.args) end
    if data.rets then indexTypes(data.rets) end
  end
end

local types = {}
for k,v in pairs(temptypes) do table.insert(types,k) end
anadata.Types = types

color(12) log("Saving analyze result")

fs.write("D:/analistics.json",JSON:encode_pretty(anadata))