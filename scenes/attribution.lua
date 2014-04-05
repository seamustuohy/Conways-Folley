-- main_scene.lua
module(..., package.seeall)

function onCreate(params)
    layer = Layer {
        scene = scene,
    }
    sprite = Sprite {
        texture = "assets/images/attribution/horiz_black.png",
        pos = {0, 0},
        layer = layer,
    }
end
