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
# Features
## File Sharing
## Emojis
To add an emoji without using any tools you'll have to open the proper profile file in `RoChat/Profiles/` for the version you're using and insert the JSON that you'll create in the emoji list. 

---

### V1 
To make a proper emoji for **V1** you'll have to make a JSON using these formats.

---

For an image you'll need to use the following JSON.

* you'll only need to use Path or Url not both.

```json
"Emoji_Name": {
	"Type": "Image",
	"Path": "emoji.png",
	"Url": "https://google.com/emoji.png"
}
```
For a video you'll need to convert the GIF or MP4 into images. I'd use [ImageMagick](https://imagemagick.org/) for that make sure to select legacy in the installer so you install convert.

run this command after installing **ImageMagick** `convert PATH_TO_GIF.gif FRAMES_PATH%03d.png`

after extracting the frames from the GIF you'll need to create a folder with the emoji's name in `RoChat/Emojis` then you'll need to put the images inside the directory.

 ```json
"Emoji_Name": {
	"Type": "Video",
	"FPS": 20
}
```
## Embeds
To create an embed you'll have to create an XML file in `RoChat/Embeds` and use the (Embed Documentation)[Documentation/Embed.md]
