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
		  play = { cells_per_turn = 6,
				   turns_per_round = 1, },
		  games = { log =
					   function(x)
						  return 2 * x
					   end,
					exponential =
					   function(x)
						  return 2^x
					   end,
					slow_poke =
					   function(x)
						  return x
					   end,
					calvinball =
					   function(x)
						  return math.random(2^x)+1
					   end,
				  }
		}

cur_template  = { board = {
			   size = "Medium",
			   zoom = 0, },
			touch = {
			   move = false,
			   last = {0,0},
			},
			players = {
			   none = {
				  playedCells = {},
				  tiles = { 46, 46 },
				  cellCount = 0, },
			},
			turn = 'none',
			turns_left = rules.play.turns_per_round,
			round = 1,
			player_names = {},
			speed = 1,
			growth_rate = function(x) return x * 2 end
		  }

--==========================
--       Initialization
--==========================
function onCreate(params)
   current = cur_template
   if params.board_size then
	  board_size = params.board_size
	  current.board.size = board_size
   else
	  board_size = "Medium"
	  current.board.size = board_size
   end

   if params.game_type then
	  if rules.games[params.game_type] then
		 current.growth_rate = rules.games[params.game_type]
	  end
   end
   
   current.board.zoom = rules.board[board_size].cell_size
	--bottom layer
    board_layer = Layer {
        scene = scene,
		touchEnabled = true
    }
	--mid layer
	cell_layer = Layer {
        scene = scene,
    }
	--top layer
	gui_layer = Layer {
        scene = scene,
		touchEnabled = true,
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

	--setup GUI
	init_gui()
	
	--setup conways
	init_conways()


end


function init_gui()
   init_ctrl()
   init_score_board()
   --init_game_info()

    -- If the first argument string, and the texture parameters.
end

function init_ctrl()
   control_panel = View {
	  layer = gui_layer,
	  scene = scene,
	  layout = VBoxLayout {
		 align = {"right", "bottom"},
		 padding = {2, 2, 2, 2},
	  },
   }
   next_button = Button {
	  text = "Next Player",
	  onClick = next_player,
	  parent = control_panel,
   }
   zoom_in_button = Button {
	  text = "Zoom In",
	  onClick = zoom_in,
	  parent = control_panel,
   }
   zoom_out_button = Button {
	  text = "Zoom Out",
	  onClick = zoom_out,
	  parent = control_panel,
   }
   speed_button = Button {
	  text = "Slow",
	  onClick = change_speed,
	  parent = control_panel,
   }
   exit_button = Button {
	  text = "Exit",
	  onClick = exit_game,
	  parent = control_panel,
   }
end

function exit_game(e)
   os.exit(0)
end


function change_speed(e)
   if speed_button:getText() == "Slow" then
	  speed_button:setText("Medium")
	  current.speed = .5
   elseif speed_button:getText() == "Medium" then
	  speed_button:setText("Fast")
	  current.speed = .1
   elseif speed_button:getText() == "Fast" then
	  speed_button:setText("Ultra")
	  current.speed = .05
   elseif speed_button:getText() == "Ultra" then
	  speed_button:setText("Slow")
	  current.speed = 1
   end   
end


function gui_block(x, y)
   if score_background:inside(x, y, 0) then
	  return true
   end
   if next_button:inside(x, y, 0) then
	  return true
   end
   if zoom_in_button:inside(x, y, 0) then
	  return true
   end
   if zoom_out_button:inside(x, y, 0) then
	  return true
   end

end

function init_score_board()
   
   score_board = Group {
	  pos = { 5, 5 },
	  size = { 30, 100 },
	  padding = {15, 15, 15, 15},
	  layer = gui_layer,
   }
   score_background = Graphics {
	  pos = {0,0},
	  parent = score_board,
   }
   local score_label = TextLabel {
		 text = "Player Scores",
		 parent = score_board,
		 pos = {15, 15},
	  }
   score_label:fitSize(13)
   score_label:setColor(0, 0, 0, 1)
 
   for i,name in ipairs(current.player_names) do
	  local set = Group {
		 layout = HBoxLayout {
			align = {"left", "center"},
		 }
	  }
	  --Create padding between items
	  if i == 1 then
		 set:setPos(40, 52)
	  else
		 set:setPos(40, ( i*52 ) )
	  end
	  --print(set:getPos())
	  
	  --make player identifiable
	  set.name = name
	  if i ~= 1 then
		 idx = ( 9 * (i-1) + 1 )
	  else
		 idx = 1
	  end
	  local icon_anims = {
		 {name = "dead", indexes = {idx}, sec = 10},
		 {name = "active", indexes = {idx+1,
									  idx+2,
									  idx+3,
									  idx+2,
									  idx+1,}, sec = 0.25},
		 {name = "inactive", indexes = {idx+1}, sec = 10},
		 {name = "winning", indexes = {idx+4,
									   idx+4,
									   idx+4,
									   idx+5,
									   idx+6,
									   idx+5}, sec = 1.3},
		 {name = "myTurn", indexes = {idx+7}, sec = 10},
				 
	  }
	  icon = SpriteSheet("assets/images/players/icons.png")
	  icon:setTiledSheets(32, 32, 9, 6)
	  icon:setSheetAnims(icon_anims)
	  icon:setLayer(gui_layer)
	  icon:playAnim("active")
	  icon:setParent(set)
	  local player_text = TextLabel {
		 text = name .. ": ___0",
		 parent = set,
		 padding = {5, 5, 5, 5},
	  }
	  player_text:setColor(0, 0, 0, 1)
	  player_text.name = name
	  player_text:fitSize(string.len(player_text.name)+6)
	  set.score = 0
	  set.icon = icon
	  function set:set_score(x)
		 local new_score = name .. ": " .. tostring(x)
		 --print(new_score)
		 player_text:setText(new_score)
		 score_board:resizeForChildren()
		 set.score = x
	  end
	  function set:get_score()
		 return set.score
	  end
	  function set:set_state(x)
		 self.icon:playAnim(x)
	  end
	  set:resizeForChildren()
	  icon:setCenterPos(icon:getLeft(), icon:getBottom())
	  score_board:addChild(set)
   end
   score_board_redraw()
end

function score_board_redraw()
   score_board:resizeForChildren()
   local padding = 10
   score_background:setSize(score_board:getSize())
   c1, c2, c3, c4 = unpack(config.color[3])
   score_background:setPenColor(c1, c2, c3, .5):fillRect()
   c1, c2, c3, c4 = unpack(config.color[4])
   score_background:setPenColor(c1, c2, c3, c4):drawRect()
   --[[
   sbSize = {score_background:getLeft(),
			 score_background:getTop() + padding ,
			 score_background:getRight() + padding ,
			 score_background:getBottom() + padding,
			 score_background:getWidth()/4,}
   score_background:setPenColor(c1, c2, c3, c4):fillRoundRect(sbSize[1],
														  sbSize[2],
														  sbSize[3],
														  sbSize[4],
														  sbSize[5],
														 25)
   
   score_background:setPenColor(c1, c2, c3, c4):drawRoundRect(sbSize[1],
														  sbSize[2],
														  sbSize[3],
														  sbSize[4],
														  sbSize[5],
	  25)]]--
end

function init_game_info()
   return
end

function init_conways()
   local names = {}
   for i,_ in ipairs(current.players) do
	  table.insert(names, i)
   end
   
	--Setup Conway
	conway:init(rules.board[current.board.size].cols, names)
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
	  texture = "assets/images/players/icons.png",
	  layer = board_layer,
	  left = mid_l, top = mid_t
   }
   
   --get sprite map
   board:setMapSheets(32, 32, 9, 6)
   
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
   if can_play_cells == false then
	  return nil
   end
   if gui_block(e.x, e.y) then
	  return nil
   end
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

function zoom_in()
   zoom("in")
end

function zoom_out()
   zoom("out")
end

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
--   print(name, tile)
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
   zero_scores()
   for _x =1,  rules.board[current.board.size].cols, 1 do
	  for _y = 1,  rules.board[current.board.size].rows, 1 do
		 _cell = conway:getCell(_x, _y)
		 board:setTile(_x, _y, get_tile(_cell.player, _cell.alive))
		 if _cell.player ~= "none" then
			mod_score(_cell.player, true)
		 end
	  end
   end
end

function zero_scores()
   for i, child in ipairs(score_board:getChildren()) do
	  if child.score then
		 child:set_score(0)
	  end
   end
end

function mod_score(player, alive)
   if player == "none" then return true end
   local score, child, current
   if alive == true then
	  score = 1
   else
	  score = -1
   end
--   print(player)
   child = score_board:getChildByName(player)
   current = child:get_score()
   child:set_score(current + score)
end


function choose_cell(x,y)
   local cell = conway:getCell( x, y )
   local alive = cell.alive
   local player = cell.player
   if alive == false then
--	  print("cell "..x..","..y.." ON")
	  set_on(x, y, player)
   else
--	  print("cell "..x..","..y.." OFF")
	  set_off(x, y, player)
   end
end

function set_on(x, y, old_cell)    --Check if in the enemy neighborhood
   if not conway:validMove(x, y, current.turn) then
--	  print("Cell is in enemy neighborhood.")
	  return nil
   end
   --Check if the player has tiles left this turn
   if current.players[current.turn]['cellCount'] <= 0 then
--	  print("Player has no tiles left to place.")
	  return nil
   end
   --Mark tile as played
   current.players[current.turn].playedCells[x..":"..y] = old_cell
   --Set tile alive
--   print(x, y, self.currentPlayer['name'], true )
   conway:setCell(x, y, current.turn, true )
   board:setTile(x, y, get_tile(current.turn, true))
   if old_owner ~= current.turn then
	  mod_score(current.turn, true)
   end
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
   if old_owner ~= current.turn then
	  mod_score(current.turn, false)
   end
   local _c = current.players[current.turn]['cellCount']
   current.players[current.turn]['cellCount'] = _c + 1
end

function set_cell(x, y, old_cell, state)
   --Check if in the enemy neighborhood
   if state == true then
	  if not conway:validMove(x, y, current.turn) then
--		 print("Cell is in enemy neighborhood.")
		 return nil
	  end
	  --Check if the player has tiles left this turn
	  if current.players[current.turn]['cellCount'] <= 0 then
--		 print("Player "..current.turn.. " has no tiles left to place.")
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
						 tiles = { 46, 46 } },
					   { name = "Nightman",
						 tiles = { 2, 1 } },
					   { name = "Satan Himself",
						 tiles = { 11, 10 } },
					   { name = "Gaia",
						 tiles = { 20, 19 } },
					   { name = "Pseo...Psei...(fish-god)",
						 tiles = { 29, 28 } },
					   { name = "Purple Nurple",
						 tiles = { 38, 37 } }
   }
   --start at two to skip none player
   for i=2, num+1, 1 do
	  local name = players[i].name
	  current.players[name] = {
		 playedCells = {},
		 cellCount = rules.play.cells_per_turn,
		 tiles = players[i].tiles
	  }
	  table.insert(current.player_names, name)
   end
end

function next_player()
--   print("next_player")
   if current.turns_left <= 0 then
	  next_turn()
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
		 current.turns_left = current.turns_left - 1
		 next_player()
	  else
		 current.players[current.turn]['cellCount'] = rules.play.cells_per_turn
		 if score_board then
			set_player_icons()
		 end
	  end
	  return true
   end
end

function next_turn()
--   print("next gen")
   --Get number of iterations from growth rate function.
   iterations = current.growth_rate(current.round)
   --print(iterations)
   show_life(iterations)
   --prepare next round
   current.round = current.round + 1
   current.turns_left = rules.play.turns_per_round
   set_player_icons()
end

function set_player_icons()
   local i, child
   local winner = nil
   local winning_score = 0
   for i, child in ipairs(score_board:getChildren()) do
	  if child.score then
		 if child.score == 0 then
			child:set_state("dead")
		 elseif winning_score < child.score then
			child:set_state("winning")
			if winner then
			   winner:set_state("active")
			end
			winning_score = child.score
			winner = child
		 elseif winning_score == child.score then
			child:set_state("active")
			if winner then
			   winner:set_state("active")
			end
		 else
			child:set_state("active")
		 end
	  end
   end
   if current.turn ~= "none" then
	  local child = score_board:getChildByName(current.turn)
	  child:set_state("myTurn")
   end
end

function next_generation()
   conway:nextGeneration()
   zero_scores()
   for x,y,cell in conway:getAllCells(conway.board) do
--	  print( x, y, cell.player, cell.alive )
	  board:setTile(x, y, get_tile(cell.player, cell.alive))
	  mod_score(cell.player, true)
   end
end

function game_over()
   local winner = "No one"
   local winning_score = 0
   for i, child in ipairs(score_board:getChildren()) do
	  if child.score then
		 if winning_score < child.score then
			winning_score = child.score
			winner = child.name
			tie = false
		 elseif winning_score == child.score then
			winning_score = child.score
			winner = "No one"
			tie = true
		 end
	  end
   end
   local score_text
   if tie == false then
	  score_text = "With a whopping score of "..winning_score
   else
	  score_text =  "Because ties are for the weak."
   end
   set_fin(winner, score_text)
end

function set_fin(winner, score)
   DIALOG_SIZE = { Application.viewWidth * 0.95, 180}
   SceneManager:openScene("scenes/game_over", {
        animation = "popIn", backAnimation = "popOut",
        size = DIALOG_SIZE,
        type = DialogBox.TYPE_INFO,
        title = winner .. " is the winner!",
        text = score,
        buttons = {"OK"},
        onResult = onDialogResult,
    })
end

function onDialogResult(e)
   os.exit(0)
end

function show_life(iter)
   local timer = MOAITimer.new()
   timer.iter = iter
   timer:setSpan(current.speed)
   timer:setMode(MOAITimer.LOOP)
   timer:setListener(MOAITimer.EVENT_TIMER_LOOP,
					 function(iter)
						timer.iter = timer.iter - 1
						if timer.iter <= 0 then
						   timer:stop()
						   can_play_cells = true
						elseif conway.repeating == true then
						   timer:stop()
						   game_over()
						else
						   next_generation()
						end
					 end)
   can_play_cells = false
   timer:start()
end
