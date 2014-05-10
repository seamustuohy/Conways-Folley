-- main_scene.lua
module(..., package.seeall)

local config = require "config"
local conway = require "lib.conway"
local garden = require "lib.garden"
local inventory = require "lib.inventory"
local data_manager = require "lib.data_manager"

--==========================
--       Control Ojects
--==========================


local game_display = {
   cell_size = 32,
}

game = {}

touch_type = "none"
active_tool = "none"

--==========================
--       Initialization
--==========================
function onCreate(params)
   print("hello 01")
   game.start_garden,
   game.state,
   game.player = data_manager:get_level(params.player_name,
										params.level)
   board_layer = Layer {
        scene = scene,
		touchEnabled = true
    }
	garden_layer = Layer {
        scene = scene,
		touchEnabled = false,
    }
	gui_layer = Layer {
        scene = scene,
		touchEnabled = true,
    }
	init_scene()
end

--    onStart ... Called at the start of the scene
function onStart()
   init_scene()
end

function init_scene()
   --show_rules(game.rules)
   --setup conways
   init_conways()
   --setup plants
   init_plants()
   --setup board
   create_board()
   --show populated board
   show_board()
   --initialize touch for board.
   set_input()
   --setup GUI
   init_gui()
end

function init_plants()
   game.plants = {}
   local x, y
   for x = 1, game.state.size, 1 do
	  if not game.plants[x] then
		 game.plants[x] = {}
	  end
	  for y = 1, game.state.size, 1 do
		 if not game.plants[x][y] then
			game.plants[x][y] = {}
		 end
	  end
   end
end

function init_game_info()
   return
end

function init_conways()
	--Setup Conway
	conway:onCreate(game.state.size)
	conway:init_board(game.start_garden)
end

--==========================
--       Game Mechanics
--==========================

function choose_cell(x,y)
   local cell = conway:get_cell( x, y )

   if touch_type == "tool" then
	  use_item(x, y, active_tool)
   elseif touch_type == "seed" then
	  local alive = cell.alive
	  if alive == "dead" then
		 --	  print("Planting seed "..x..","..y.." ON")
		 plant_seed(x, y, cell.id)
	  end
   end
end

function plant_seed(x, y, plant_id)
   --Check if you can play this seed here.
   if not garden[plant_id].can_plant_seed(x, y) then
--	  print("You can't plant this seed here.")
	  return nil
   end
   current_cell = conway:get_cell(x, y)
   if current_cell:set_alive() then
	  set_tile(x, y, conway:get_cell(x, y))
   end
end

function use_item(x, y, item)
   --Don't use if it is not in the inventory
   current_cell = conway:get_cell(x, y)
   if not inventory.contains(item) then
	  alert("You don't have that item.")
	  active_tool = "none"
	  return nil
   elseif not tools[item].can_use(current_cell) then
	  alert("That item does nothing there.")
	  return nil
   else
	  inventory.remove(item)
	  tools.use_tool(current_cell)
	  set_tile(x, y, current_cell)
	  active_tool = "none"
	  return true
   end
end

function next_turn()
--   print("next gen")
   --Get number of iterations from growth rate function.
   iterations = current.growth_rate(current.round)
   --print(iterations)
   show_life(iterations)
end

function next_generation()
   conway:next_generation()
   for x,y,cell in conway:getAllCells(conway.board) do
	  set_tile(x, y, current_cell)
   end
end

function show_life(iter)
   local timer = MOAITimer.new()
   timer.iter = iter
   timer:setSpan(game.state.speed)
   timer:setMode(MOAITimer.LOOP)
   timer:setListener(MOAITimer.EVENT_TIMER_LOOP,
					 function(iter)
						if timer.iter <= 0 then
						   timer:stop()
						   can_play_cells = true
						elseif game.state.done ~= false then
						   timer:stop()
						   game_over()
						else
						   timer.iter = timer.iter - 1
						   next_generation()
						end
					 end)
   can_play_cells = false
   timer:start()
end

---========================
--- BOARD
---========================
function create_board()
   print("board Created")
   --defaults
   local size = game.state.size
   local cell_size = game.state.cell_size
   
   local mid_l, mid_t = board_layer:getCenterPos()
   local col, row = size, size
   local cellH = cell_size
   local cellW = cellH
   
   --Get top left that puts center cell in center of the board.
   mid_l = mid_l - (( cellW/2 ) * col )
   mid_t = mid_t - (( cellH/2 ) * row )
   
   game.board = MapSprite {
	  texture = "assets/images/boards/earth.png",
	  layer = board_layer,
	  left = mid_l, top = mid_t
   }
   
   --get sprite map
   local sprite_rows = 9
   local sprite_cols = 18
   local sprite_cell_size = 32
   game.board:setMapSheets(sprite_cell_size,
					  sprite_cell_size,
					  sprite_cols,
					  sprite_rows)
   
   --Set up board
   game.board:setMapSize(col, row, cellH, cellW)
   show_board()
end

function show_board()
   print("GETTING CELLS")
   for x,y,cell in conway:getAllCells() do
	  set_tile(x, y, cell)
   end
end

function set_input()
   game.board:addEventListener("touchDown", board_touch)
   board_layer:addEventListener("touchMove", board_move)
   game.board:addEventListener("touchUp", board_touch)
   board_layer:addEventListener("touchCancel", board_touch)
end

function board_move(e) end
function board_touch(e)
   x,y = get_grid_coords( e.x, e.y )
--   print(x, y, e.x, e.y)
end

function get_grid_coords( x, y )
   local top  = y - game.board:getTop()
   local left = x - game.board:getLeft()
   
   local _y = math.floor( top  / game.state.cell_size) + 1 
   local _x = math.floor( left / game.state.cell_size) + 1 
   
   return _x, _y
end


-- @brief Gets the sprite tile for the requested type and state
function get_tile(name, state)
   --set default to alive
   local tile_no = "alive"
   local tile
   
   --if cell is dead get the dead tile, but don't be picky about it
   if state == "dead" or state == false or state == 0 then
	  tile_type = "dead"
   end
   
   tile = garden[name][art][state]

   return tile
end

function set_tile(x, y, cell)
   set_soil(x, y, cell.soil)
   set_plant(x, y, cell)
end

function set_plant(x, y, cell)
   if cell.id == "earth" then return nil end
   game.plants[x][y] = SpriteSheet(garden[cell.id].art.sheet)
   game.plants[x][y]:setTiledSheets(unpack(garden[cell.id].art.tiles))
   game.plants[x][y]:setSheetAnims(garden[cell.id].art.anims)
   game.plants[x][y]:setLayer(garden_layer)
   game.plants[x][y]:playAnim(cell:get_anim())
   local bt = game.board:getTop()
   local bl = game.board:getLeft()
   _y = bt + (y * game.state.cell_size) - game.state.cell_size
   _x = bl + (x * game.state.cell_size) - game.state.cell_size
--   local plant_size = game.state.cell_size*2
--   game.plants[x][y]:setTileSize(plant_size, plant_size)
   game.plants[x][y]:setPos(_x, _y)
end


function set_soil(x, y, soil)
   local sprt_cols = 18
   local sprt_rows = game.state.size
   local soil_list = {fertile=0, barren=1}
   local soil_board = soil_list[soil]
   local soil_tile =
	  ( x + ( sprt_rows * soil_board )) + ( (y - 1)  * sprt_cols)
   game.board:setTile(x, y, soil_tile)
end

function touch(e)
   if can_play_cells == false then
	  return nil
   end
   if block(e.x, e.y) then
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
   if current.turn ~= "earth" then
	  local child = score_board:getChildByName(current.turn)
	  child:set_state("myTurn")
   end
end





---=================================
----- GUI
----================================



alert = print

function block(x, y)
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
 
   local set = Group {
	  layout = HBoxLayout {
		 align = {"left", "center"},
	  }
   }
   --Create padding between items
   if i == 1 then
	  set:setPos(40, 52)
   else
	  set:setPos(40, ( i * 52 ) )
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

function init_gui()
   init_ctrl()
--   init_score_board()
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
