color(6)

local JSON = require("Libraries.JSON")

local function log(...)
  local t = table.concat({...}," ")
  cprint(...)
  print(t)
  flip()
end

log("Reading files list..")
local docs = fs.getDirectoryItems("D:/DOCS/")
local dnames = {}

log("Reading files...")
for id,name in ipairs(docs) do
  docs[id] = fs.read("D:/DOCS/"..name)
  dnames[id] = name
end

log("Decoding...")
color(5)
for id, jdata in ipairs(docs) do
  log(dnames[id])
  docs[id] = JSON:decode(jdata)
end
color(6)

color(12)
log("DONE")