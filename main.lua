local modules = require "modules"
local config = require "config"
local Logger = require("hp/util/Logger")

MOAILogMgr.setLogLevel (MOAILogMgr.LOG_STATUS)
ResourceManager:addPath("assets")
Logger.debug("PINEAPPLE", 4)
Application:start(config)
SceneManager:openScene(config.attribution)
