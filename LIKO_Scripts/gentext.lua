--Generate the documentation in a .txt format.
local term = require("terminal")
term.execute("reload")

local du = require("doc_utils")

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

clog(7,"Loading the documentation...")
local docs = du.loadJSON("D:/JSON_Source")

clog(7,"Generating the text documentation...")

local function sharpFrame(str)
	local len = #str
	return string.rep("#",len+6)..string.format("\n## %s ##\n",str)..string.rep("#",len+6)
end

--Frame the string with dashes like this:
---------------
--Peripherals--
---------------
local function frame(str)
	local len = #str
	return string.rep("-",len+4)..string.format("\n--%s--\n",str)..string.rep("-",len+4)
end

local function type2string(t)
	if type(t) == "table" then
		for i=1, #t do
			if type(t[i]) == "table" then
				table.remove(t[i],1) --Remove the "Peripherals" prefix
				t[i] = table.concat(t[i],".")
			end
		end
		return table.concat(t, ", ")
	end

	return t
end

local function arguments2text(text,ident,args)
	text[#text+1] = ""
	text[#text+1] = ident.."- Arguments:"
	for i=1, #args do
		local a = args[i]
		if type(a.default) == "string" then a.default = '"'..a.default..'"' end
		if not a.name then --Constant
			text[#text+1] = string.format("%s   * literal (%s): %s",ident,type2string(a.type),tostring(a.default))
		elseif type(a.default) ~= "nil" then --Optional arg
			text[#text+1] = string.format("%s   * [%s] (%s) [%s]: %s",ident,a.name,type2string(a.type),tostring(a.default),a.description or "!!! NO ARG DESC !!!")
		elseif a.name == "..." then --Vararg
			text[#text+1] = string.format("%s   * [%s] (%ss): %s",ident,a.name,type2string(a.type),a.description or "!!! NO ARG DESC !!!")
		else --Required arg
			text[#text+1] = string.format("%s   * <%s> (%s): %s",ident,a.name,type2string(a.type),a.description or "!!! NO ARG DESC !!!")
		end
	end
end

local function returns2text(text,ident,rets)
	text[#text+1] = ""
	text[#text+1] = ident.."- Returns:"
	for i=1, #rets do
		local r = rets[i]
		if r.optional then
			text[#text+1] = string.format("%s   * [%s] (%s): %s",ident,r.name,type2string(r.type),r.description or "!!! NO RET DESC !!!")
		else
			text[#text+1] = string.format("%s   * %s (%s): %s",ident,r.name,type2string(r.type),r.description or "!!! NO RET DESC !!!")
		end
	end
end

local function notes2text(text,ident,notes)
	text[#text+1] = ""
	text[#text+1] = ident.."- Notes:"
	ident = ident.."   "
	for i=1, #notes do
		local n = notes[i]
		text[#text+1] = ident.."* "..(n:gsub("\n","\n"..ident) or n)
	end
end

local function extra2text(text,ident,extra)
	text[#text+1] = ""
	text[#text+1] = ident.."- Extra Info:"
	ident = ident.."   "
	extra = extra:gsub("\n","\n"..ident) or extra
	text[#text+1] = ident..extra
end

local function method2text(text,ident,pname,oname,mname,m)
	text[#text+1] = ""
	text[#text+1] = string.format("%s- %s%s%s",ident,oname,m.self and ":" or ".",mname)
	text[#text+1] = ident..string.rep("-",text[#text]:len()-#ident)
	text[#text+1] = ident.." "..(m.shortDescription or "!!! NO SHORT DESCRIPTION !!!")
	text[#text+1] = ""
	text[#text+1] = string.format("%s - Introduced in %s V%s, LIKO-12 V%s",ident,pname,table.concat(m.availableSince[1],"."),table.concat(m.availableSince[2],"."))
	text[#text+1] = string.format("%s - Last updated in %s V%s, LIKO-12 V%s",ident,pname,table.concat(m.lastUpdatedIn[1],"."),table.concat(m.lastUpdatedIn[2],"."))
	if m.fullDescription then
		text[#text+1] = ""
		text[#text+1] = ident.." "..m.fullDescription
	end
	if m.note then
		text[#text+1] = ""
		text[#text+1] = ident.." - Note: "..(m.note:gsub("\n","\n    "..ident) or m.note)
	elseif m.notes then
		notes2text(text, ident.." ", m.notes)
	end
	if m.usages then
		text[#text+1] = ""
		text[#text+1] = ident.." = Usages:"
		for i=1, #m.usages do
			local u = m.usages[i]
			text[#text+1] = ""
			text[#text+1] = string.format("%s  %d. %s",ident,i,u.name)
			text[#text+1] = string.format("%s   %s",ident,u.shortDescription or "!!! NO SHORT DESCIPTION !!!")
			if u.note then
				text[#text+1] = ""
				text[#text+1] = ident.."   - Note: "..(u.note:gsub("\n","\n     "..ident) or u.note)
			elseif u.notes then
				notes2text(text, ident.."   ", u.notes)
			end
			if u.arguments then
				arguments2text(text, ident.."   ", u.arguments)
			end
			if u.returns then
				returns2text(text, ident.."   ", u.returns)
			end
			if u.extra then extra2text(text, ident.."   ", u.extra) end
		end
	else
		if m.arguments then
			arguments2text(text, ident.." ", m.arguments)
		end
		if m.returns then
			returns2text(text, ident.." ", m.returns)
		end
	end
	if m.extra then extra2text(text, ident.." ", m.extra) end
end

local text = {sharpFrame("Peripherals")}

for pname,p in pairs(docs.Peripherals) do
	text[#text+1] = ""
	text[#text+1] = frame(string.format("%s (%s)",pname,p.name))
	text[#text+1] = p.shortDescription or "!!! NO SHORT DESCRIPTION !!!"
	text[#text+1] = " - Version: V"..table.concat(p.version,".")
	text[#text+1] = " - Introduced in LIKO-12 V"..table.concat(p.availableSince,".")
	text[#text+1] = " - Last updated in LIKO-12 V"..table.concat(p.lastUpdatedIn,".")
	text[#text+1] = p.availableForGames and " - Accessible by games and the operating system." or " - Accessible by the operating system only !"
	if p.fullDescription then
		text[#text+1] = ""
		text[#text+1] = p.fullDescription
	end

	if p.methods then
		text[#text+1] = ""
		text[#text+1] = "=-----=# Methods #=-----="
		for mname, m in pairs(p.methods) do
			method2text(text, "  ", pname, pname, mname, m)
		end
	end

	if p.objects then
		text[#text+1] = ""
		text[#text+1] = "=-----=# Objects #=-----="
		for oname, o in pairs(p.objects) do
			text[#text+1] = ""
			text[#text+1] = string.format(" --=== %s ===--",oname)

			if o.methods then
				text[#text+1] = ""
				text[#text+1] = "  == Methods =="
				for mname, m in pairs(o.methods) do
					method2text(text, "  ", pname, oname, mname, m)
				end
			end
		end
	end
end

--Append changelog
text[#text+1] = ""
text[#text+1] = sharpFrame("Changelog")

local changelog = fs.read("C:/help/whatsnew"):gsub("\r","")
changelog = changelog:gsub("\\%x","") --Clear color tags
changelog = changelog:gsub("\\L","L") --Clear LIKO-12 tags
changelog = changelog:sub(12,-1)
text[#text+1] = changelog

text = table.concat(text,"\n"):gsub("\n","\r\n")
fs.write("D:/documentation.txt",text)