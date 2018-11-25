
local common = require("common")

local verbose, path = common.parseargs({...})

local data = common.loadDirectory(path)

fs.newDirectory("D:/MD_Generated/Peripherals/")

if verbose then
  common.log("Generating Docs.")
end

local function generateType(t)
  if type(t) == "string" then
    return t
  elseif type(t) == "table" then
    local tc = {}
    for k,v in ipairs(t) do
      if type(v) == "table" then
        tc[k] = "["..table.concat(v,"/").."](/Documentation/"..v[1].."/"..v[2].."/objects/"..v[3].."/)"
      else
        tc[k] = v
      end
    end
    return table.concat(tc,", ")
  end
  
  return "INVALID_TYPE"
end

local function generateArguments(args,multiUsage)
  local adoc = multiUsage and "\n---\n#### Arguments\n---\n\n" or "\n---\n### Arguments\n---\n\n"
  for _, arg in ipairs(args) do
    if arg.name then
      if arg.default then
        adoc = adoc.."* **"..arg.name.." ("..generateType(arg.type)..", nil) (Default:`"..(type(arg.default) == "string" and '"'..arg.default..'"' or tostring(arg.default)).."`):** "..arg.description.."\n"
      else
        adoc = adoc.."* **"..arg.name.." ("..generateType(arg.type).."):** "..arg.description.."\n"
      end
    else
      if type(arg.default) == "string" then
        adoc = adoc.."* **`\""..tostring(arg.default).."\"` ("..generateType(arg.type)..")**\n"
      else
        adoc = adoc.."* **`"..tostring(arg.default).."` ("..generateType(arg.type)..")**\n"
      end
      
      if arg.description then
        adoc = adoc:sub(1,-4)..":** "..arg.description.."\n"
      end
    end
  end
  return adoc.."\n"
end

local function generateReturns(rets,multiUsage)
  local rdoc = multiUsage and "\n---\n#### Returns\n---\n\n" or "\n---\n### Returns\n---\n\n"
  for _, ret in ipairs(rets) do
    if ret.optional then
      rdoc = rdoc.."* **"..ret.name.." ("..generateType(ret.type)..", nil):** "..ret.description.."\n"
    else
      rdoc = rdoc.."* **"..ret.name.." ("..generateType(ret.type).."):** "..ret.description.."\n"
    end
  end
  return rdoc.."\n"
end

local function generateSyntax(mname,usage,pname)
  local sdoc = "```lua\n"
  
  if usage.returns then
    local rets = {}
    for _, ret in ipairs(usage.returns) do rets[#rets + 1] = ret.name end
    sdoc = sdoc.."local "..table.concat(rets,", ").." = "
  end
  
  sdoc = sdoc..pname..(usage.self and ":" or ".")..mname.."("
  
  if usage.arguments then
    local args = {}
    for _, arg in ipairs(usage.arguments) do
      if arg.name then
        args[#args+1] = arg.name
      elseif type(arg.default) == "string" then
        args[#args+1] = '"'..arg.default..'"'
      else
        args[#args+1] = tostring(arg.default)
      end
    end
    sdoc = sdoc..table.concat(args,", ")
  end
  
  sdoc = sdoc..")\n```"
  
  return sdoc
end

local function generateMethod(mname,method,pname)
  local mdoc = "# "..pname..(method.self and ":" or ".")..mname.."\n---\n\n"
  mdoc = mdoc .. (method.longDescription or method.shortDescription or "!> The method description is missing !!"):gsub("_media","../../../_media") .. "\n\n---\n\n"
  
  if method.notes then
    for _, note in ipairs(method.notes) do
      mdoc = mdoc.."?> "..note.."\n\n"
    end
    mdoc = mdoc.."---\n\n"
  elseif method.note then
    mdoc = mdoc.."?> "..method.note.."\n\n---\n\n"
  end
  
  mdoc = mdoc.."* **Available since:** _"..pname..":_ v"..table.concat(method.availableSince[1],".")..", _LIKO-12_: v"..table.concat(method.availableSince[2],".").."\n"
  mdoc = mdoc.."* **Last updated in:** _"..pname..":_ v"..table.concat(method.lastUpdatedIn[1],".")..", _LIKO-12_: v"..table.concat(method.lastUpdatedIn[2],".").."\n"
  
  if method.usages then
    mdoc = mdoc.."\n---\n\n**Usages:**\n\n"
    for unum, usage in ipairs(method.usages) do
      mdoc = mdoc.."---\n\n# "..unum..". "..usage.name.."\n---\n\n"
      if usage.shortDescription or usage.longDescription then
        mdoc = mdoc..(usage.longDescription or usage.shortDescription):gsub("_media","../../../_media").."\n\n---\n\n"
      end
      
      mdoc = mdoc..generateSyntax(mname,usage,pname).."\n\n"
      
      if usage.notes then
        for _, note in ipairs(usage.notes) do
          mdoc = mdoc.."?> "..note.."\n\n"
        end
        mdoc = mdoc.."---\n\n"
      elseif usage.note then
        mdoc = mdoc.."?> "..usage.note.."\n\n---\n\n"
      end
      
      if usage.arguments then
        mdoc = mdoc .. generateArguments(usage.arguments,true)
      end
      
      if usage.returns then
        mdoc = mdoc .. generateReturns(usage.returns,true)
      end
    end
    mdoc = mdoc.."---"
  else
    mdoc = mdoc.."\n---\n\n"..generateSyntax(mname,method,pname).."\n"
    
    if method.arguments then
      mdoc = mdoc .. generateArguments(method.arguments,false)
    end
    
    if method.returns then
      mdoc = mdoc .. generateReturns(method.returns,false)
    end
  end
  
  if method.extra then mdoc = mdoc.."\n---\n\n"..method.extra end
  
  return mdoc
end

for pname, peripheral in pairs(data) do
  common.clog(6,pname)
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
    local mnlist, mosnlist = {}, {}
    
    for mname, method in pairs(peripheral.methods) do
      local ttable = mname:sub(1,1) == "_" and moslist or mlist
      ttable[#ttable+1] = "* ["..mname.."](/Documentation/Peripherals/"..pname.."/"..mname..".md): "..(method.shortDescription or "**NO DESCRIPTION**")
      
      local ntable = mname:sub(1,1) == "_" and mosnlist or mnlist
      ntable[#ntable+1] = mname
      
      --Generate the method documentation
      local mdoc = generateMethod(mname,method,pname)
      
      fs.write("D:/MD_Generated/Peripherals/"..pname.."/"..mname..".md",mdoc)
    end
    
    table.sort(mlist)
    table.sort(moslist)
    
    local psbar = "* ["..pname.."](/Documentation/Peripherals/"..pname.."/)\n"
    
    if #mlist > 0 then
      preadme = preadme.."\n---\n### Methods\n---\n"..table.concat(mlist,"\n").."\n"
      psbar = psbar.."* Methods\n"
      for _,mname in ipairs(mnlist) do
        psbar = psbar.."  * ["..mname.."](/Documentation/Peripherals/"..pname.."/"..mname..".md)\n"
      end
    end
    
    if #moslist > 0 then
      preadme = preadme.."\n---\n### OS Methods\n---\n!> Those methods are not available for games.\n"..table.concat(moslist,"\n").."\n"
      psbar = psbar.."* OS Methods\n"
      for _,mname in ipairs(mosnlist) do
        psbar = psbar.."  * ["..mname.."](/Documentation/Peripherals/"..pname.."/"..mname..".md)\n"
      end
    end
    
    fs.write("D:/MD_Generated/Peripherals/"..pname.."/_sidebar.md",psbar)
  end
  
  fs.write("D:/MD_Generated/Peripherals/"..pname.."/README.md",preadme)
end