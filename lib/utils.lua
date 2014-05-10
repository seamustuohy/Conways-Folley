local utils = {}

function utils:contains(tbl, value)
	for key, val in pairs(tbl) do
		if value == val then
			return key
		end
	end
	return false
end


function utils:deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[utilsconway:deepcopy(orig_key)] = utils:deepcopy(orig_value)
        end
        setmetatable(copy, utils:deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


return utils
