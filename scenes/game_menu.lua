module(..., package.seeall)


--TODO ADD PLAYER CREATION and LEVEL CHOOSING!!!
player_name = "bob"
level = 1

function onCreate(params)
    view = View {
        scene = scene,
        layout = {
            VBoxLayout {
                align = {"center", "center"},
                padding = {2, 2, 2, 2},
            }
        },
	}
	
	size_button = Button {
	   text = "Small",
	   onClick = onSizeClick,
	   parent = view,
	}
    sizelabel = TextLabel {
        text = "Board Size",
        parent = view,
        pos = {size_button:getRight(), 0},
    }
	sizelabel:setTextSize(20)
	sizelabel:fitSize(10)
	size_button.label = sizeLabel
	sizelabel:setColor(1,1,1,1)
	players_button = Button {
	   text = "2",
	   onClick = onPlayerClick,
	   parent = view,
	}
    playerlabel = TextLabel {
        text = "Number of Players",
        parent = view,
        pos = {size_button:getRight(), 0},
    }
	playerlabel:setTextSize(20)
	playerlabel:fitSize(17)
	players_button.label = playerLabel	
	playerlabel:setColor(1,1,1,1)

	game_type_button = Button {
	   text = "Steady",
	   onClick = onGameClick,
	   parent = view,
	}

    gamelabel = TextLabel {
        text = "Type of Game",
        parent = view,
        pos = {size_button:getRight(), 0},
    }
	gamelabel:setTextSize(20)
	gamelabel:fitSize(12)
	game_type_button.label = gameLabel
	gamelabel:setColor(1,1,1,1)
	
	start_button = Button {
	   text = "Start",
	   onClick = onStartClick,
	   parent = view,
	}
end

function onGameClick(e)
   local types = {"Steady", "Exponential", "Slow Poke", "CalvinBall"}
   local text = game_type_button:getText()
   local set = false
   for i,x in ipairs(types) do
	  if x == text and next(types, i) then
		 local _,_type = next(types, i)
		 game_type_button:setText(_type)
		 game_type_button:updateDisplay()
		 set = true
	  end
   end
   if set == false then
	  game_type_button:setText(types[1])
   end
end

function onStartClick(e)
   --Get game type
   local growth_rate
   local game_types = { log = "Steady",
						exponential="Exponential",
					   slow_poke="Slow Poke",
					   calvinball="CalvinBall"}
   local selected = game_type_button:getText()
   for i,x in pairs(game_types) do
	  if x == selected then
		 growth_rate = i
	  end
   end
   size = size_button:getText()
   player_num = players_button:getText()
   SceneManager:openScene("scenes/level/01",
						  {animation = "crossFade",
						   board_size=size,
						   player_num=player_num,
						   game_type=growth_rate,
						   player_name=player_name,
						   level=level,})
   
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
