# W.I.P

# RoChat
**RoChat** is a LuaU script I decided to make because I felt like roblox's native chat was lacking in some aspects.

```lua
------------------------------------------------------------------------
-- ooooooooo.               .oooooo.   oooo                      .    --
-- `888   `Y88.            d8P'  `Y8b  `888                    .o8    --
--  888   .d88'  .ooooo.  888           888 .oo.    .oooo.   .o888oo  --
--  888ooo88P'  d88' `88b 888           888P"Y88b  `P  )88b    888    --
--  888`88b.    888   888 888           888   888   .oP"888    888    --
--  888  `88b.  888   888 `88b    ooo   888   888  d8(  888    888 .  --
-- o888o  o888o `Y8bod8P'  `Y8bood8P'  o888o o888o `Y888""8o   "888"  --
------------------------------------------------------------------------

getgenv().ROCHAT_Config = {
    WSS = "wss://WS-Server.eeeeeevbr.repl.co",
    Version = "v1",
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/Ro-Chat/Chat/main/Loader.lua"))()
```

# TODO
 - [ ] Webhosting
 - [ ] UI
  - [ ] Drawing library
  - [ ] Custom chatbar
     - [ ] File browser
     - [ ] Emoji browser
     - [ ] Autocorrect
  - [ ] Context menu
     - [ ] Better UI
     - [x] Reactions
     - [x] Delete message
     - [x] Edit message
     - [x] Clipboard
 - [ ] Plugins

# Documentation
 ### v1
 * [Emoji](/Documentation/v1/Emojis.md)
