local common = require("docscripts")

local verbose, path = common.parseargs({...})

local data = common.loadDirectory(path)

local peripherals = {}

local plugins = {}

function plugins.pnames(pname, peripheral)
    return pname
end

function plugins.methods(pname, peripheral)
    mnames = {}
    if peripheral.methods then
        for mname, method in pairs(peripheral.methods) do
            table.insert(mnames, mname)
        end
    end
    return mnames
end

function plugins.defaulted(pname, peripheral)
    defaults = {}
    if peripheral.methods then
        for mname, method in pairs(peripheral.methods) do
            if method.arguements then
                for k,v in ipairs(method.arguments) do
                    if v.default then
                        table.insert(defaults, v.default)
                    end
                end
            end
        end
    end
    return defaults
end


for k, v in pairs(plugins) do
    common.clog(9, k)
    for pname, peripheral in pairs(data) do
    result = v(pname, peripheral)
    if type(result) == "string" then
        common.clog(6, result)
    elseif type(result) == "table" then
        for k,v in ipairs(result) do
            common.clog(6, v)
        end
    end
end
end