--Local requirements
local utils = require "lib.utils"
local garden = require "lib.garden"
local root = require "lib.cell"

local conway = {}
		
conway.logging = 1
log = {
   --Core debugging
   debug = function (...)
	  if conway.logging >= 5 then
		 print(...) end end,
   --TraceRoute
   name = function (...)
	  if conway.logging >= 6 then
		 print(...) end end,
   --Things are broken
   error = function (...)
	  if conway.logging >= 2 then
		 print(...) end end,
}

function conway:onCreate(boardSize)
   assert(boardSize)
   conway.boardSize = boardSize
   conway.board = {}
end

--Runs all cells through a growth pattern
function conway:init_board(start_garden)
--   print("Next Generation")
   local x, y
   for x = 1, self.boardSize, 1 do
	  if not self.board[x] then
		 self.board[x] = {}
	  end
	  for y = 1, self.boardSize, 1 do
		 if not self.board[x][y] then
			local soil, id, alive
			if start_garden[x] and start_garden[x][y] then
			   soil, id, alive = unpack(start_garden[x][y])
			else
			   soil, id, alive = unpack(start_garden.default)
			end
--			print("setting garden", soil, id, alive)
			self:build_cell(x, y, soil, id, alive)
		 end
	  end
   end
end

--[[
   Cell properties:
   * id (str): The type of plant / object it is (eg. violet, earth, rock)
   * alive (str [dead|alive]): If there is a plant alive or dead in the cell.
   * age (int): The ammount of turns the cell has been alive for in a row.
   * adult (bool): If the plant is an adult or a child.
   * soil (str): The type of soil in the cell. [barren|fertile|snow]
]]--

--! @name cell
--! @param x, y (int): The x and y coords of the cell on the board
--! @param soil (str): The type of soil for the cell
--! @param id (str): the id of the cell to place.
--! @param alive (str): if the cell is alive or dead.
--! @brief Takes basic cell info and creates a generic cell from that info.
function conway:build_cell(x, y, soil, id, alive)
   log.name("setCell")
   if not self.board[x] then
	  self.board[x] = {}
   end
   if not self.board[x][y] then
	  self.board[x][y] = {}
   end
   self.board[x][y] = root:new(soil, id, alive)
end

function conway:get_cell(x, y)
   log.name("get cell")
   if self.board[x] then
	  if self.board[x][y] then
		 return self.board[x][y]
	  end
   end
   log.error("Cell is out of bounds")
end

function conway:neighborStats(cell, octet)
   --A table of the eight neibors (or less) of a cell
   log.name("cell:getNeighborhood")
   local cells = 0
   local plants = {}
   local other = 0
   if next(octet) then
	  for _,n in ipairs(octet) do
		 --Get the other plants state from the garden
		 local state = garden[n.id].interact(cell.id, n.alive)
		 cells = cells + state
		 if plants[n.id] then
			plants[n.id] = plants[n.id] + state
		 else
			plants[n.id] = state
		 end
		 if n.id ~= cell.id then
			other = other + state
		 end
	  end
   end
   return cells, plants, other
end

function conway:neighbors(x, y)
   neighbors = {}
   local _x, _y
   for _x = x - 1, x + 1, 1 do
	  for _y = y - 1, y + 1, 1 do
		 if self.board[_x] and self.board[_x][_y] then
			if _x == x and _y == y then
			   --pass
			else
			   table.insert(neighbors, self.board[_x][_y])
			end
		 end
	  end
   end
--   if next(neighbors) then
	  --print("neighbors found", #neighbors)
--   end
   return neighbors
end

function conway:get_env(x, y)
   --get neighbors
   local n_list = conway:neighbors( x, y )
   local cell = self.board[x][y]
   local n_num, hood, other
   n_num, total_num, other_num = conway:neighborStats(cell, n_list)
--   if cell.alive == true then
--	  print(x, y, cell.alive, n_num, hood, other)
--   end
   return cell, n_num, total_num, other_num
end

--iterator
function conway:getAllCells()
   log.name("getAllCells")
   local xi, yi, cell
   xi, yi = next(self.board)
   return function ()
	  if type(yi) == 'table' then
		 ci, cell = next(yi, ci)
		 if ci then
			return xi, ci, cell
		 else
			xi, yi = next(self.board, xi)
			if yi then
			   ci, cell = next(yi, ci)
			   if ci then
				  return xi, ci, cell
			   end
			end
		 end
	  end
   end
end

function conway:deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[conway:deepcopy(orig_key)] = conway:deepcopy(orig_value)
        end
        setmetatable(copy, conway:deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--Runs all cells through a growth pattern
function conway:next_generation()
--   print("Next Generation")
   local x, y
   for x = 1, self.boardSize, 1 do
	  for y = 1, self.boardSize, 1 do
		 self:grow( x, y )
	  end
   end
end

--! Runs a cells growth pattern
function conway:grow(x,y)
   local cell = self:get_cell(x, y)
   local num, hood, other = self:get_env( x, y )
   cell:grow(num, hood, other)
end


return conway
