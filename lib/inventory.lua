local util = require "lib.utils"

inventory = {}

function inventory:contains(item)
   if utils.contains(inventory.current, item) then
	  return true
   else
	  return false
   end
end

function inventory:remove(item)
   if inventory.current[item] > 0 then
	  inventory.current[item] = inventory.current[item] - 1
	  return true
   end
   return false
end


