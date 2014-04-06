local utils = {}

function utils:contains(tbl, value)
	for key, val in pairs(tbl) do
		if value == val then
			return key
		end
	end
	return false
end

return utils
