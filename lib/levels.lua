
levels = {
   --starting garden population format
   -- default={<soi l>, <id>, <alive>}
   -- [<x-val>][<y-val>]={<soil>, <id>, <alive>}
   start_garden = {
	  default={"fertile", "earth", "dead"},
	  [3]={[4]={"fertile", "rock", "alive"}},
	  [5]={[4]={"fertile", "violet", "alive"}},
   }
   game = { zoom = 0,
			size = 9,
			touch = {
			   move = false,
			   last = {0,0}},
		  round = 1,
		  speed = 1,
		  growth_rate = function(x) return x * 2 end,
		  win = function(x) return false end,
		  can_plant_seed = function(x, y) return true end,
   }
   player = {
	  name = "",
	  objects = {violet=5},
	  playedCells = {},
	  tiles = { 46, 46 },
	  cellCount = 0,
	  lost = false,
   }
}


