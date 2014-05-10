cell = {}
cell.defaults = {
   id="earth",
   alive="dead",
   age=0,
   adult=false,
   soil="fertile"
}

--inheritance based: to save memory on cell creation
function cell:new(soil, id, alive)
   local _cell = setmetatable({}, { __index = cell } )
   for i,x in pairs(cell.defaults) do
	  _cell[i] = x
   end
   if soil then _cell.soil = soil  end
   if id then _cell.id = id end
   if alive then _cell.alive = alive  end
   return _cell
end

function cell:destroy()
   self.adult = false
   self.age = 0
   self.alive = "dead"
end

function cell:grow(num, hood, other)
   if garden[cell.id].calculate_life(self, num, hood, other) then
	  self.age = self.age + 1
	  if self.age >= garden[cell.id].mature then
		 self.adult = true
	  end
   end
end

function cell:get_anim()
   if self.alive == "dead" then
	  return "dead"
   elseif self.adult == true then
	  return "adult"
   else
	  return "child"
   end
end


return cell
