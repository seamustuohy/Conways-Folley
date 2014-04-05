local modules = require "modules"

MOAISim.setStep ( 1 / 60 )
MOAISim.clearLoopFlags ()
MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_BOOST )
MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_LONG_DELAY )
MOAISim.setBoostThreshold ( 0 )

local config = {
    title = "Conways Folley",
    screenWidth = 480,
    screenHeight = 320,
	attribution = "scenes/attribution",
}

return config
