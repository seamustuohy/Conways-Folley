--starting garden population format
-- default={<soi l>, <id>, <alive>}
-- [<x-val>][<y-val>]={<soil>, <id>, <alive>}

levels = {
   {--Level 1
	  start_garden = {
		 default={"fertile", "earth", "dead"},
		 [3]={[4]={"fertile", "grass", "alive"}},
		 [5]={[4]={"fertile", "rose", "alive"}},
	  },
	  game = { growth_rate = function(x) return x + 1 end,
			   win = function(x) return false end,
			   can_plant_seed = function(x, y) return true end,},
	  player = { seeds = {violet = 5 } },
   },
   {--Level 2
   },
   {--Level 3
   },
   {--Level 4
   },
   {--Level 5
   },
   {--Level 6
   },
}




return levels
