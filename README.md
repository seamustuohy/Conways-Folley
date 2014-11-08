
This was simply an exploration in Moai to do multi-platform game development. It is abandoned.


# Hard coded paths for assets.

Hanape has a series of hard coded assets.

  * hp/manager/FontManager.lua (font paths)
  * hp/gui/Theme.lua (menu item skins)
  * hp/display/TextLabel.lua (default font)

In order to use these assets you need to add equivilant assets and specify your assets path in the Resource Manager.

```Lua
m = ResourceManager
m:addPath("path/to/assets/folder")
```
