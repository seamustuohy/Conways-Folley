local modules = require "modules"

MOAISim.setStep ( 1 / 60 )
MOAISim.clearLoopFlags ()
MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_BOOST )
MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_LONG_DELAY )
MOAISim.setBoostThreshold ( 0 )

local config = {
    title = "Conways Folley",
--	screenWidth = 1240,
--	screenHeight = 960,
    screenWidth = MOAIEnvironment.verticalResolution or 960,
    screenHeight = MOAIEnvironment.horizontalResolution or 640,
	attribution = "scenes/attribution",
	color = {
	   {229/255, 153/255, 135/255, 1},
	   {229/255, 210/255, 135/255, 1},
	   {127/255, 95/255, 154/255, 1},
	   {147/255, 63/255, 43/255, 1},
	   {143/255, 127/255, 43/255, 1},
	   {68/255, 31/255, 100/255, 1},},
}

return config
