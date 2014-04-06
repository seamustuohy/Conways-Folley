module(..., package.seeall)


function onCreate(params)
    view = View {
        scene = scene,
        layout = {
            VBoxLayout {
                align = {"center", "center"},
                padding = {10, 10, 10, 10},
            }
        },
        children = {{
            Button {
                name = "startButton",
                text = "New Game",
                onClick = onStartClick,
            },
            Button {
                name = "quitButton",
                text = "Quit",
                onClick = onQuitClick,
            },
        }},
    }
	print("I am working")
end

function onStartClick(e)
    SceneManager:openScene("scenes/game_menu", {animation = "fade"})
end

function onQuitClick(e)
   os.exit(0)
end
