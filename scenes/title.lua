-- main_scene.lua
module(..., package.seeall)
local config = require "config"


function onCreate(params)
    layer = Layer {
        scene = scene,
    }
    attribution = Sprite {
        texture = "assets/images/transitions/main_title.png",
        pos = {0, 0},
        layer = layer,
    }
	local w, h = scale_2_screen({width=640, height=400})
	attribution:setSize(w, h)
end

function onStart(params)
	start_timer()
end

function onResume(params)
	start_timer()
end

function start_timer()
   local timer = MOAITimer.new()
   timer:setSpan(2) --TODO make 180 before showing to anyone for proper attribution.
   timer:setMode(MOAITimer.LOOP)
   timer:setListener(MOAITimer.EVENT_TIMER_LOOP,
					 function()
						SceneManager:openScene("scenes/main_menu", {animation = "fade"})
						timer:stop()
					 end)
   timer:start()
end

function scale_2_screen(image)
   screen = {WIDTH = config.screenWidth, HEIGHT = config.screenHeight}
   local half_width, half_height, scale_diff
   local height_diff = image.height / screen.HEIGHT
   local width_diff = image.width  / screen.WIDTH
   --Find greater offset
   --Scale up the smallest ammount to fit the screen
   if width_diff > height_diff then
	  --As a side note, math is powerful a == b/(b/a)
	  scale_diff = width_diff
   else
	  scale_diff = height_diff
   end
   --Scale uniformly so as not to warp image.
   scaled_width = image.width / scale_diff
   scaled_height = image.height / scale_diff
   
   --Get half sized
   half_width = scaled_width / 2
   half_height = scaled_height / 2
   
   --Return coordinates
--   return half_width, half_height
   return scaled_width, scaled_height
end
