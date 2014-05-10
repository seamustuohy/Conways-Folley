garden = {}

--==========================
--       VIOLET
--==========================

--Create Violet group
garden.violet = {}

--Does a violet grow?
garden.violet.grow = true

--How does a violet calculate its life
garden.violet.calculate_life = garden.basic_calculate_life

--What are the alive vs dead neighbor counts for life
garden.violet.neighbor = { alive = { 2, 3 },
						   dead =  { 3 } }
--What is the art used for a violet.
garden.violet.art = {
   sheet = "",
   tiles = {32, 32, 9, 6},
   anims = {
	  {name = "dead", indexes = {idx}, sec = 10},
	  {name = "child", indexes = {idx}, sec = 10},
	  {name = "adult", indexes = {idx}, sec = 10}
   }
}

--How does a violet interact with others?
garden.violet.interact = garden.basic_interact

--When does a violet mature
garden.violet.mature = 2

--What are the rules for planting.
garden.violet.can_plant_seed = garden.basic_can_plant_seed


--==========================
--       rose
--==========================

--Create rose group
garden.rose = {}

--Does a rose grow?
garden.rose.grow = true

--How does a rose calculate its life
garden.rose.calculate_life = garden.basic_calculate_life

--What are the alive vs dead neighbor counts for life
garden.rose.neighbor = { alive = { 2, 3 },
						   dead =  { 3 } }
--What is the art used for a rose.
garden.rose.art = {
   sheet = "assets/images/plants/rose.png",
   tiles = {32, 32, 5, 1},
   anims = {
	  {name = "dead", indexes = {1}, sec = 10},
	  {name = "child", indexes = {2}, sec = 10},
	  {name = "adult", indexes = {3}, sec = 10}
   }
}

--How does a rose interact with others?
garden.rose.interact = garden.basic_interact

--When does a rose mature
garden.rose.mature = 2

--What are the rules for planting.
garden.rose.can_plant_seed = garden.basic_can_plant_seed

--==========================
--       grass
--==========================

--Create grass group
garden.grass = {}

--Does a grass grow?
garden.grass.grow = true

--How does a grass calculate its life
garden.grass.calculate_life = garden.basic_calculate_life

--What are the alive vs dead neighbor counts for life
garden.grass.neighbor = { alive = { 2, 3 },
						   dead =  { 3 } }
--What is the art used for a grass.
garden.grass.art = {
   sheet = "assets/images/plants/grass.png",
   tiles = {32, 32, 5, 1},
   anims = {
	  {name = "dead", indexes = {1}, sec = 10},
	  {name = "child", indexes = {2}, sec = 10},
	  {name = "adult", indexes = {3}, sec = 10}
   }
}

--How does a grass interact with others?
garden.grass.interact = garden.basic_interact

--When does a grass mature
garden.grass.mature = 2

--What are the rules for planting.
garden.grass.can_plant_seed = garden.basic_can_plant_seed


--==========================
--       ROCK
--==========================

--Create rock group
garden.rock = {}

--Does a rock grow?
garden.rock.grow = false

--How does a rock calculate its life
garden.rock.calculate_life = function() return "rock", false end

--What are the alive vs dead neighbor counts for life
garden.rock.neighbor = { alive={ 0},
						 dead= { 0 }}
--What is the art used for a rock.
garden.rock.art = {
   sheet = "",
   tiles = {32, 32, 9, 6},
   anims = {
	  {name = "dead", indexes = {idx}, sec = 10},
	  {name = "child", indexes = {idx}, sec = 10},
	  {name = "adult", indexes = {idx}, sec = 10}
   }
}

--How does a rock interact with others?
garden.rock.interact = garden.basic_interact


--What are the rules for planting.
garden.rock.can_plant_seed = garden.basic_can_plant_seed



function garden:basic_interact(other, alive)
   if alive then
	  return 1
   else
	  return 0
   end
end

function garden:basic_calucuate_life(cell, total_alive, neighborhood, total_other)
   --[[Takes a cell {id, alive} and a neighborhood table and returns the replacement cell for that position.]]--
   local requirements = { alive={ 2, 3 }, dead= { 3 }}
   --Crete the default dead cell to start with
   local state
   if cell.alive == true then state = "alive" else state = "dead" end
   local req = requirements[state]
   --Living cell conditions
   if state == "alive" then
	  local life = total_alive - total_other
	  if utils:contains( req,  life ) then
		 --It's Alive!
		 log.debug("Cell lived another day with", life, "neighbors")
		 return cell.id, true
	  else
		 --not enough neighbors to live
		 log.debug("id cell died from lonelyness with", life, "neighbors")
--		 log.debug(num, hood, other)
		 return cell.id, false
	  end
   else
	  --dead cell conditions
	  --Set bar at current set (if it has lived before)
	  local count = 0
	  local newCell = cell
	  if cell.id ~= "earth" then
		 if neighborhood[cell.id] then
			count = neighborhood[cell.id]
		 else
			count = 0
		 end
	  end
	  --Get the id with the most cells alive nearby
	  for _id,_count in pairs(neighborhood) do
		 --get greatest sized cell cluster
		 if garden[_id].grow and _count > count then
			newCell = {_id, true}
			count = _count
		 end
	  end
	  --is it enough to create life
	  if utils:contains(req, count) then
		 log.debug("Cell Sprung to life with", life, "neighbors")
		 return newCell.id, true
	  else
--		 print("cell stayed dead")
		 return cell.id, false
	  end
   end
end

function garden:basic_can_plant_seed(x,y)
   --If the board forbids it then NO
   if not game.can_plant_seed(x, y) then
	  return false
   end
   --get current cell
   current = conway.get_cell(x, y)
   --if not raw earth, that is fertile, then no.
   if current.id == "earth" then
	  if current.soil == "fertile" then
		 return true
	  end
   end
   return false
end



return garden
