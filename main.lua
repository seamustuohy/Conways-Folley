local modules = require "modules"
local config = require "config"

Application:start(config)
SceneManager:openScene(config.attribution)
ResourceManager:addPath("assets")
