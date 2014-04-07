-- main_scene.lua
module(..., package.seeall)

local config = require "config"
local conway = require "lib/conway"


--==========================
--       Control Ojects
--==========================

rules = { board = { Small = {
					   cols = 10,
					   rows = 10,
					   cell_size = 32,},
					Medium = {
					   cols = 30,
					   rows = 30,
					   cell_size = 32,},
					Large = {
					   cols = 60,
					   rows = 60,
					   cell_size = 32,}
				  },
		  play = { cells_per_turn = 1,
				   cells_per_round = 6, }
		}

current = { board = {
			   size = "Medium",
			   zoom = 0, },
			touch = {
			   move = false,
			   last = {0,0},
			},
			players = {
			   none = {
				  playedCells = {},
				  tiles = { 1, 7 },
				  cellCount = 0, },
			},
			turn = 'none',
			round = rules.play.cells_per_round,
			player_names = {}
		  }

--==========================
--       Initialization
--==========================

function onCreate(params)
   if params.board_size then
	  board_size = params.board_size
	  current.board.size = board_size
   else
	  board_size = "Medium"
	  current.board.size = board_size
   end
   
   current.board.zoom = rules.board[board_size].cell_size
   
    board_layer = Layer {
        scene = scene,
		touchEnabled = true
    }
	gui_layer = Layer {
        scene = scene,
    }
	cell_layer = Layer {
        scene = scene,
    }
	--setup board
	build_board(board_size)

	--setup players and default to two players if none chosen. 
	local player_num
	if params.player_num then
	   player_num = params.player_num
	else
	   player_num = 2
	end
	
	init_players(player_num)
	next_player()
	
	--setup conways
	init_conways()
	

end

function init_conways()
   local names = {}
   for i,_ in ipairs(current.players) do
	  table.insert(names, i)
   end
   
	--Setup Conway
	conway:init(rules.board[current.board.size].cols, names)
	print(conway.boardSize)
	
end

function build_board(size)
   local mid_l, mid_t = board_layer:getCenterPos()
   local col, row = rules.board[size].cols, rules.board[size].rows
   local cellH = rules.board[size].cell_size
   local cellW = cellH
   --Get top left that puts center cell in center of the board.
   mid_l = mid_l - (( cellW/2 ) * col )
   mid_t = mid_t - (( cellH/2 ) * row )
   
   board = MapSprite {
	  texture = "assets/images/boards/basic.png",
	  layer = board_layer,
	  left = mid_l, top = mid_t
   }
   
   --get sprite map
   board:setMapSheets(62, 62, 6, 2)
   
   --Set up board
   board:setMapSize(col, row, cellH, cellW)

   --fill board with empty cells
   board.grid:fill(get_tile("none", "dead"))
   
   board:addEventListener("touchDown", board_touch)
   board_layer:addEventListener("touchMove", board_move)
   board:addEventListener("touchUp", board_touch)
   board_layer:addEventListener("touchCancel", board_touch)
   InputManager:addEventListener("keyDown", get_key)
      
end

--==========================
--       INPUT
--==========================

function board_touch(e)
   local cell
--   print_touch(e)
   --Check if touched down in the same square
   if e.type == "touchUp" then
	  if current.touch.move ~= true then
		 if e.x == current.touch.last[1] and  e.y == current.touch.last[2] then
			x, y = get_grid_coords( e.x, e.y )
			choose_cell(x, y)			
		 end
	  else
		 current.touch.move = false
	  end
   else
	  current.touch.move = false
	  current.touch.last = {e.x, e.y}
   end
--   print(e.x, e.y, e.type)
end

function print_touch(e)
    print("----------------------------------------")
    print("type     = ", e.type)
    print("name     = ", e.target.name)
    print("idx      = ", e.idx)
    print("tapCount = ", e.tapCount)
    print("x        = ", e.x)           -- MEMO:Position of Layer.
    print("y        = ", e.y)           -- MEMO:Position of Layer.
    print("moveX    = ", e.moveX)       -- MEMO:Position of Layer.
    print("moveY    = ", e.moveY)       -- MEMO:Position of Layer.
    print("screenX  = ", e.screenX)
    print("screenY  = ", e.screenY)
end

function get_key(e)
--   print(e.key)
   if e.key == 46 then
	  zoom("in")
   elseif e.key == 44 then
	  zoom("out")
   elseif e.key == 110 then
	  next_player()
   end
end

function board_move(e)
   local menu_size = 200
   local buffer = menu_size + 20
   

   --[[ Movement
	  Right: --> (+,0)
	  Left: <-- (-,0)
	  Up: ^ (0,-)
	  Down: V (0,+)
   ]]--
   
   if e.moveX ~= 0 then
	  current.touch.move = true
	  -- Move Right
	  if e.moveX > 0 then
		 --Left cant be less than right minus a buffer
		 if board:getLeft() <= board_layer:getRight() - buffer then
			board:setRight(board:getRight() + e.moveX)
		 end
	  -- Left
	  elseif e.moveX < 0 then
		 --Right cant be greater than the left side plus a buffer
		 if board:getRight() >= board_layer:getLeft() + buffer then
			board:setLeft(board:getLeft() + e.moveX)
		 end
	  end
   end
   if e.moveY ~= 0 then
	  current.touch.move = true
	  -- Up
	  if e.moveY < 0 then
		 --Bottom can't be above top + buffer
		 if board:getBottom() >= board_layer:getTop() + buffer then
			board:setTop(board:getTop() + e.moveY)
		 end
	  -- Down
	  elseif e.moveY > 0 then
		 --Top can't be beow the bottom minus a buffer
		 if board:getTop() <= board_layer:getBottom() - buffer then
			board:setBottom(board:getBottom() + e.moveY)
		 end
	  end
   end
end


--==========================
--       Board Display
--==========================
 
function zoom(direction)
   --get current position
   local center_l, center_t = board:getCenterPos()

   local col = rules.board[current.board.size].cols
   local row = rules.board[current.board.size].rows
   
   local cellH = current.board.zoom
   local cellW = cellH
   
   if direction == "in" and current.board.zoom < 92 then
	  current.board.zoom = cellH + 10
	  board:setMapSize(col, row, cellW + 10, cellH + 10 )
	  populate_board()
   elseif direction == "out" and current.board.zoom > 22 then
	  current.board.zoom = cellH - 10
	  board:setMapSize(col, row, cellW - 10, cellH - 10 )
	  populate_board()
   end
   board:setCenterPos(center_l, center_t)
end

-- @brief Gets the sprite tile for the requested player and state
function get_tile(name, state)
   --set defaults
   local tile_no = 1
   local tile
   
   --if cell is dead get the dead tile, but don't be picky about it
   if state == "dead" or state == false or state == 0 then
	  tile_no = 2
   end
   
   --identify player and get the correct tile
   for i, _ in pairs(current.players) do
	  if i == name then
		 tile = current.players[i].tiles[tile_no]
	  end
   end
   --return tile for board/cell sprite tile set
   return tile
end

function get_board_info()
   print( "size: " .. board:getSize() )
   print( "position: " .. board:getPos() )
   print( "center: " .. board:getCenterPos() )
   print( "top: " .. board:getTop() )
   print( "left: " .. board:getLeft() )
end

function get_grid_coords( x,y )
--   print("current Coords: ", x,y)
--   get_board_info()
   local top = y - board:getTop()
   local left = x - board:getLeft()
   
   local _y = math.floor ( top / current.board.zoom ) + 1
   local _x = math.floor ( left / current.board.zoom ) + 1
   
   return _x, _y
end


--==========================
--       Game Mechanics
--==========================


-- @brief Iterate over all cells in the board and grab the state of those cells from conways cell table.
function populate_board()
   local _x, _y, _cell
   for _x =1,  rules.board[current.board.size].cols, 1 do
	  for _y = 1,  rules.board[current.board.size].rows, 1 do
		 _cell = conway:getCell(_x, _y)
		 board:setTile(_x, _y, get_tile(_cell.player, _cell.alive))
	  end
   end
end

function choose_cell(x,y)
   local cell = conway:getCell( x, y )
   local alive = cell.alive
   local player = cell.player
   if alive == false then
	  print("cell "..x..","..y.." ON")
	  set_on(x, y, player)
   else
	  print("cell "..x..","..y.." OFF")
	  set_off(x, y, player)
   end
end

function set_on(x, y, old_cell)    --Check if in the enemy neighborhood
   if not conway:validMove(x, y, current.turn) then
	  print("Cell is in enemy neighborhood.")
	  return nil
   end
   --Check if the player has tiles left this turn
   if current.players[current.turn]['cellCount'] <= 0 then
	  print("Player has no tiles left to place.")
	  return nil
   end
   --Mark tile as played
   current.players[current.turn].playedCells[x..":"..y] = old_cell
   --Set tile alive
--   print(x, y, self.currentPlayer['name'], true )
   conway:setCell(x, y, current.turn, true )
   board:setTile(x, y, get_tile(current.turn, true))
   --iterate players cell count down one
   local _c = current.players[current.turn]['cellCount']
   current.players[current.turn]['cellCount'] = _c - 1
end


function set_off(x, y, player)
   local old_owner
   --Check if played this turn
   if not current.players[current.turn].playedCells[x..":"..y] then
	  return nil
   else
	  old_owner = current.players[current.turn].playedCells[x..":"..y]
	  current.players[current.turn].playedCells[x..":"..y] = nil
   end
   --Set tile dead
   conway:setCell(x, y, old_owner, false )
   board:setTile(x, y, get_tile(old_owner, false))
   local _c = current.players[current.turn]['cellCount']
   current.players[current.turn]['cellCount'] = _c + 1
end




function set_cell(x, y, old_cell, state)
   --Check if in the enemy neighborhood
   if state == true then
	  if not conway:validMove(x, y, current.turn) then
		 print("Cell is in enemy neighborhood.")
		 return nil
	  end
	  --Check if the player has tiles left this turn
	  if current.players[current.turn]['cellCount'] <= 0 then
		 print("Player "..current.turn.. " has no tiles left to place.")
		 return nil
	  end
	  --Mark tile as played
	  current.players[current.turn].playedCells[x..":"..y] = old_cell
   else
	  if not current.players[current.turn].playedCells[x..":"..y] then
		 return nil
	  else
		 old_cell = current.players[current.turn].playedCells[x..":"..y]
		 current.players[current.turn].playedCells[x..":"..y] = nil
	  end
   end
   conway:setCell(x, y, current.turn, state)
   local tile = get_tile(current.turn, state)
   board:setTile(x, y, get_tile(current.turn, state))
   local count
   if state == true then
	  count = 1
   else
	  count = -1
   end
   local _c = current.players[current.turn].cellCount
   current.players[current.turn].cellCount = _c - count
end

function init_players(num)
   local   players = { { name = "none",
						 tiles = { 1, 7 } },
					   { name = "pOne",
						 tiles = { 2, 8 } },
					   { name = "pTwo",
						 tiles = { 3, 9 } },
					   { name = "pThree",
						 tiles = { 4, 10 } },
					   { name = "pFour",
						 tiles = { 5, 11 } },
					   { name = "pFive",
						 tiles = { 6, 12 } }
   }
   --start at two to skip none player
   for i=2, num+1, 1 do
	  local name = players[i].name
	  current.players[name] = {
		 playedCells = {},
		 cellCount = rules.play.cells_per_turn,
		 tiles = {i, i+6}
	  }
	  table.insert(current.player_names, name)
   end
end

function next_player()
   print("next_player")
   if current.round <= 0 then
	  next_generation()
	  next_player()
   else
	  local current_index
	  local i,x
	  for i,x in ipairs(current.player_names) do
		 if x == current.turn then
			current_index = i
		 end
	  end
	  _, current.turn = next(current.player_names, current_index)
	  if not current.turn or current.turn == 'none' then
		 current.turn = 'none'
		 current.round = current.round - 1
		 next_player()
	  else
		 current.players[current.turn]['cellCount'] = rules.play.cells_per_turn
	  end
	  return true
   end
end

function next_generation()
   print("next gen")
   current.round = rules.play.cells_per_round
   conway:nextGeneration()
   for x,y,cell in conway:getAllCells(conway.board) do
	  print( x, y, cell.player, cell.alive )
	  board:setTile(x, y, get_tile(cell.player, cell.alive))
   end
end
