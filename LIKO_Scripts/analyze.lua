local common = require("common")

local data = common.loadDirectory("D:/JSON_Source/Peripherals/")

local peripherals = {}

local plugins = {}

function plugins.pnames(pname, peripheral)
    return pname
end

function plugins.methods(pname, peripheral)
    mnames = {}
    for mname, method in pairs(peripheral) do
        table.append(mnames, mname)
    end
    return mnames
end

function plugins.defaulted(pname, peripheral)
    defaults = {}
    for mname, method in pairs(peripheral) do
        for k,v in ipairs(method.arguments) do
            if v.default then
                table.append(defaults, v.default)
            end
        end
    end
    return defaults
end

for pname, peripheral in pairs(data) do
    for k, v in plugins do
        common.log(k)
        result = v(pname, peripheral)
        if type(result) == "string" then
            common.log(string)
        elseif type(result) == "table" then
            for k,v in ipairs(result) do
                common.log(v)
            end
        end
    end
end