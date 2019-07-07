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

local function method2text(text,ident,pname,oname,mname,m)
	text[#text+1] = ""
	text[#text+1] = string.format("%s- %s%s%s",ident,oname,m.self and ":" or ".",mname)
	text[#text+1] = ident..string.rep("-",text[#text]:len()-#ident)
	text[#text+1] = ident.." "..(m.shortDescription or "!!! NO SHORT DESCRIPTION !!!")
	text[#text+1] = ""
	text[#text+1] = string.format("%s - Introduced in %s V%s, LIKO-12 V%s",ident,pname,table.concat(m.availableSince[1],"."),table.concat(m.availableSince[2],"."))
	text[#text+1] = string.format("%s - Last updated in %s V%s, LIKO-12 V%s",ident,pname,table.concat(m.lastUpdatedIn[1],"."),table.concat(m.lastUpdatedIn[2],"."))
	text[#text+1] = ""
	text[#text+1] = ident.." "..(m.fullDescription or "!!! NO FULL DESCRIPTION !!!")
	text[#text+1] = ""
	if m.usages then
		text[#text+1] = ident.." = Usages:"
		for i=1, #m.usages do
			local u = m.usages[i]
			text[#text+1] = ""
			text[#text+1] = string.format("%s  %d. %s",ident,i,u.name)
			text[#text+1] = string.format("%s   %s",ident,u.shortDescription or "!!! NO SHORT DESCIPTION !!!")

		end
	else
		--text[#text+1] = "= Usage:"
	end
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
	text[#text+1] = ""
	text[#text+1] = p.fullDescription or "!!! NO FULL DESCRIPTION !!!"

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

fs.write("D:/documentation.txt",table.concat(text,"\n"))