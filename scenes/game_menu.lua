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
	}
	size_button = Button {
	   text = "Small",
	   onClick = onSizeClick,
	   parent = view,
	}
	
	start_button = Button {
	   text = "Start",
	   onClick = onStartClick,
	   parent = view,
	}
end

function onStartClick(e)
   size = size_button:getText()
   SceneManager:openScene("scenes/game", {animation = "fade", board_size=size})
end

function onSizeClick(e)
   if size_button:getText() == "Small" then
	  size_button:setText("Medium")
   elseif size_button:getText() == "Medium" then
	  size_button:setText("Large")
   else
	  size_button:setText("Small")
   end
end
