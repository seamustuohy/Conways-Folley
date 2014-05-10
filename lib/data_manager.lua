module ( "data_manager", package.seeall )

require "lib.savefile_manager"
local config = require "config"

DM = {}

DM.player_name = nil

function DM:get_level(player_name, num)
   self.player_name = player_name
   self:update_data()
   local levels = require "data.levels"
   local current = levels[num]
   local start_garden = current.start_garden
   local game = DM:get_game(current.game)
   local player = DM:get_player(current.player.seeds)
   return start_garden, game, player
end

function DM:get_game(current)
   --Set defaults
   local size = 8
   local cell_size = math.floor ( config.screenHeight / (size + 1) )
   local game =  { size = size,
				   turn = 1,
				   speed = 1,
				   cell_size = cell_size,
				   done = false,
				   growth_rate = function(x) return x * 2 end,}
   for i,x in pairs(current) do
	  game[i] = x
   end
   return game
end

function DM:get_player(seeds)
   --Set defaults
   local player =  { name = self.player_name,
					 seeds = seeds,
					 items = DM:get_items(),
					 speed = 1,}
   return player
end

function DM:update_data()
   assert(self.player_name)
   DM.save = savefiles.get(self.player_name)
end

function DM:get_items()
    return DM.save.items
end

return DM
