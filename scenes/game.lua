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
   "pOne",
   "pTwo",
   "pThree",
   "pFour",
   "pFive"
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
	board.grid:fill(player_tiles['none'][2])
end


