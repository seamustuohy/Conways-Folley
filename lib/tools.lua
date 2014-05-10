tools = {}

--==========================
--       Hoe
--==========================

tools.hoe = {}

tools.hoe.reactants = {"earth", "violet"}

tools.hoe.can_use = function(current)
   --if not earth then no.
   if utils.contains(self.reactants, current.id ) then
	  return true
   end
   return false
end

tools.hoe.use_tool = function(current)
   --Turn soil into fertilized soil.
   current.soil = "fertile"
   if current.alive == "alive" then
	  current.alive = "dead"
   end
end
