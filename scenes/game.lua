-- main_scene.lua
module(..., package.seeall)

local config = require "config"
local conway = require "lib/conway"
local boards = {Small = 9, Medium = 50, Large = 100}

rules = {
   board = {
	  Small = {
		 cols = 9,
		 rows = 9,
	  },
	  Medium = {
		 cols = 50,
		 rows = 50,
	  },
	  Large = {
		 cols = 100,
		 rows = 100,
	  },
   }
}

player_tiles = {
   
   none = { 1, 7 },
   pOne = { 2, 8 },
   pTwo = { 3, 9 },
   pThree = { 4, 10 },
   pFour = { 5, 11 },
   pFive = { 6, 12 }
}

players = {
   {
	  name = "none",
	  tiles = { 1, 7 }
   },
   {
	  name = "pOne",
	  tiles = { 2, 8 }
   },
   {
	  name = "pTwo",
	  tiles = { 3, 9 }
   },
   {
	  name = "pThree",
	  tiles = { 4, 10 }
   },
   {
	  name = "pFour",
	  tiles = { 5, 11 }
   },
   {
	  name = "pFive",
	  tiles = { 6, 12 }
   }
}

function onCreate(params)
   if params.board_size then
	  board_size = params.board_size
   else
	  board_size = "Medium"
   end
   
    board_layer = Layer {
        scene = scene,
    }
	gui_layer = Layer {
        scene = scene,
    }
	cell_layer = Layer {
        scene = scene,
    }
	newGame(board_size)
end


function newGame(size)

    board = MapSprite {
	   texture = "assets/images/boards/basic.png",
	   layer = board_layer,
	   left = 0, top = 0
	}
	
	--get sprite map
	board:setMapSheets(62, 62, 6, 2)

	--Set up board
	local col, row = rules.board[size].cols, rules.board[size].rows
	local cellH, cellW = 32, 32
	board:setMapSize(col, row, cellH, cellW)

	--fill board with empty cells
	board.grid:fill(get_tile("none", "dead"))
end


function get_tile(name, state)
   --set defaults
   local tile_no = 1
   local tile
   
   --if cell is dead get the dead tile, but don't be picky about it
   if state == "dead" or state == false or state == 0 then
	  tile_no = 2
   end
   
   --identify player and get the correct tile
   for _, i in pairs(players) do
	  if i['name'] == name then
		 tile = i.tiles[tile_no]
	  end
   end
   --return tile for board/cell sprite tile set
   return tile
end
