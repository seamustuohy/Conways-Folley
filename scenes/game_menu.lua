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
	
	players_button = Button {
	   text = "2",
	   onClick = onPlayerClick,
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
   player_num = players_button:getText()
   SceneManager:openScene("scenes/game", {animation = "fade", board_size=size, player_num=player_num})
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

function onPlayerClick(e)
   num = tonumber(players_button:getText())
   if num  >= 5 then
	  players_button:setText("2")
   else
	  new = tostring(num + 1)
	  players_button:setText(new)
   end
end
