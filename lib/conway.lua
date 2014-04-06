--MOAI requirements
local pcall = pcall
local math = math

--Local requirements
local utils = require "lib.utils"

--Global requirements
local viewport = viewport

--lua requirements

local conway = {}
		
conway.logging = 5
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

conway.boardSize = nil
conway.board = {}
--The number of neighbors to determine life
conway.life = { [1]={ 2, 3 },
			  [0]={ 3 } }

conway.defaults = {
   boardSize=16,
}
conway.players = {}
conway.cache = {}

function conway:init(boardSize, players)
   if boardSize then
	  self.boardSize = boardSize
   else
	  self.boardSize = self.defaults['boardSize']
   end
   self:initPlayers(players)
end

function conway:initPlayers(players)
   --Takes a list of names ['bob', 'sam', 'peter']
   if type(players) ~= 'table' then
	  if pcall(function () return players%1==0 end) then
		 players = getPlayers(players)
	  end
   end
   for _, plr in ipairs(players) do
	  table.insert(self.players, plr)
   end
end

function conway:getPlayers(num)
   players = {}
   for _i=0, num, 1 do
	  table.insert( players, conway:getUID() )
   end
   return players
end

function conway:getCell(x, y)
   if self.board[x] then
	  if self.board[x][y] then
		 return self.board[x][y]
	  end
   end
   return {alive=false, player="none"}
end


function conway:setCell(x, y, player, alive)
   if not self.board[x] then
	  self.board[x] = {}
   end
   if not self.board[x][y] then
	  self.board[x][y] = {}
   end
   self.board[x][y] = conway:cell(player, alive)
end

function conway:validMove(x,y,player)
   --The totally simple calculation is if there other cell types  and you are not already in the area you can't play a cell. Otherwise, go ahead.
   local c = self:getCell(x,y)
   local num, cells = self:neighborStats(c, self:neighbors(x,y))
   if cells[player] then
	  return true
   elseif num >= 1 then
	  return false
   else
	  return true
   end
end

function conway:cell(player, alive)
   log.name("conway:cell")
   if not conway.cache[player] then
	  conway.cache[player] = {}
   end
   if alive == false then state = 'dead' else state = 'alive' end
   if not conway.cache[player][state] then
	  conway.cache[player][state] = { ['player']=player,
										['alive']=alive }
   end
   return conway.cache[player][state]
end

function conway:neighborStats(cell, octet)
   --A table of the eight neibors (or less) of a cell
   log.name("cell:getNeighborhood")
   if not cell then cell = self:cell("none", false) end
   local _cells = 0
   local _players = {}
   local _baddies = 0
   if next(octet) then
	  for _,_n in ipairs(octet) do
		 local state
		 if _n.alive == true then state = 1 else state = 0 end
		 _cells = _cells + state
		 if _players[_n.player] then
			_players[_n.player] = _players[_n.player] + state
		 else
			_players[_n.player] = state
		 end
		 if _n.player ~= cell.player then
			_baddies = _baddies + state
		 end
	  end
   end
   return _cells, _players, _baddies
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
   if next(neighbors) then
	  print("neighbors found", #neighbors)
   end
   return neighbors
end

function conway:getEnv(x, y)
   --get neighbors
   local n_list = conway:neighbors( x, y )
   local cell
   if not self.board[x] or not self.board[x][y] then
	  cell = self:cell("none", false)
   else
	  cell = self.board[x][y]
   end
   local n_num, hood, other
   n_num, hood, other = conway:neighborStats(cell, n_list)
   if cell.alive == true then
	  print(x, y, cell.alive, n_num, hood, other)
   end
   return cell, n_num, hood, other
end

--iterator
function conway:getAllCells(board)
   local xi, yi, cell
   xi, yi = next(board)
   return function ()
	  if type(yi) == 'table' then
		 ci, cell = next(yi, ci)
		 if ci then
			return xi, ci, cell
		 else
			xi, yi = next(board, xi)
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

function conway:nextGeneration()
   print("Next Generation")
   local temp_board = self:deepcopy(self.board)
   local x, y, i
   i = 0
   for x = 1, self.boardSize, 1 do
	  for y = 1, self.boardSize, 1 do
		 i = i + 1
		 _cell = self:calculateLife( x, y )
		 if _cell.player ~= "none" then
			if not temp_board[x] then
			   temp_board[x] = {}
			end
			if not temp_board[x][y] then
			   temp_board[x][y] = {}
			end
			temp_board[x][y] = _cell
		 end
	  end
   end
   self.board = temp_board
end


function conway:calculateLife(x,y)
   --[[Takes a cell {player, alive} and a neighborhood table and returns the replacement cell for that position.]]--
   log.name("conway:calculateLife")
   --get envrionment
   local cell, num, hood, other = self:getEnv( x, y )
   
   --Crete the default dead cell to start with
   local state
   if cell.alive == true then state = 1 else state = 0 end
   local _alive = self.life[state]
--   print(cell.alive)
   --Living cell conditions
   if state == 1 then
	  local life = num - other
	  if utils:contains(_alive,  life ) then
		 --It's Alive!
--		 log.debug(num, hood, other)
		 log.debug("player cell lived another day with", life, "neighbors")
		 return self:cell(cell.player, true)
	  else
		 --not enough neighbors to live
--		 log.debug(_alive[1], "needed to live")
		 log.debug("player cell died from lonelyness with", life, "neighbors")
--		 log.debug(num, hood, other)
		 return self:cell(cell.player, false)
	  end
   else --dead cell conditions
	  --Set bar at current set (if it has lived before)
	  local count = 0
	  local newCell = cell
	  if cell.player ~= "none" then
		 if hood[cell.player] then
			count = hood[cell.player]
		 else
			count = 0
		 end
	  end
	  --Get the player with the most cells alive nearby
	  for _player,_count in pairs(hood) do
		 --get greatest sized cell cluster
		 if _count > count then
			newCell = conway:cell(_player, true)
			count = _count
		 end
	  end
	  --is it enough to create life
	  if utils:contains(_alive, count) then
		 log.debug("Cell Sprung to life with", life, "neighbors")
		 return self:cell(newCell.player, true)
	  else
--		 print("cell stayed dead")
		 return self:cell(cell.player, false)
	  end
   end
end


return conway
