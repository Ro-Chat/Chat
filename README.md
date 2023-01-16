# RoChat
**RoChat** is a LuaU script I decided to make because I felt like roblox's native chat was lacking in some aspects. **RoChat** will add emojis, file sharing, embeds, and a censor free chat.

## File Sharing
## Emojis
To add an emoji without using any tools you'll have to open the proper profile file in `RoChat/Profiles/` for the version you're using and insert the JSON that you'll create in the emoji list. 

---

### V1 
To make a proper emoji for **V1** you'll have to make a JSON using these formats.

---
* P.S. you'll only need to use Path or Url not both.

For an image you'll need to use the following JSON.
```json
"Emoji_Name": {
	"Type": "Image",
	"Path": "emoji.png",
	"Url": "https://google.com/emoji.png"
}
```
For a video you'll need to convert the GIF or MP4 into images. I'd use [ImageMagick](https://imagemagick.org/) for that make sure to install legacy so you install convert.

`convert PATH_TO_GIF.gif FRAMES_PATH%03d.png`

 ```json
"Emoji_Name": {
	"Type": "Video",
	"Frames": [
	  "frame000.png",
	  "frame001.png",
	  "frame002.png",
	  "frame003.png",
	  "frame004.png",
	  "frame005.png",
	  "frame006.png",
	  "frame007.png",
	],
	"FPS": 20
}
```
## Embeds
To create an embed you'll have to create an XML file in `RoChat/Embeds` and use the following documentation to make an Embed for in chat use.

## Embed XML Documenation

## Button
Creates a **Button** in the embed frame for user input.
### Properties
---
* OnHover `function`: Returns/sets the function for whenever the **Button** is hovered over.
* OnClick `function`: Returns/sets the function for whenever the **Button** is clicked.
* Text `string`: Returns/sets the text for the button.
* Color `color3`: Returns/sets the color button.
* TextColor `color3`: Returns/sets the text color.
* Font `Enum.Font`: Returns/sets the text font.
* TextSize `number`: Returns/sets the text size.
 ```XML
<button color="255, 0, 0">Button Example</button>
```


## TextBox
Creates a **TextBox** in the embed frame for user input.
### Properties
---
* OnHover `function`: Returns/sets the function for whenever the **TextBox** is hovered over.
* OnEnter`function`: Returns/sets the function for whenever enter is pressed.
* Text `string`: Returns/sets the text for the button.
* Color `color3`: Returns/sets the color button.
* TextColor `color3`: Returns/sets the text color.
* Font `Enum.Font`: Returns/sets the text font.
* TextSize `number`: Returns/sets the text size.
 ```XML
<textbox color="255, 0, 0">TextBox Example</textbox>
```

## TextLabel
Creates a **TextLabel** in the embed frame.
### Properties
---
* OnHover `function`: Returns/sets the function for whenever the **TextLabel** is hovered over.
* Text `string`: Returns/sets the text for the button.
* Color `color3`: Returns/sets the color button.
* TextColor `color3`: Returns/sets the text color.
* Font `Enum.Font`: Returns/sets the text font.
* TextSize `number`: Returns/sets the text size.
 ```XML
<textlabel color="255, 0, 0">TextLabel Example</textlabel>
```
## ImageLabel
Creates a **ImageLabel** in the embed frame.
### Properties
---
* OnHover `function`: Returns/sets the function for whenever the **ImageLabel** is hovered over.
* Image`string`: Returns/sets the image for the **ImageLabel**.
* Color `color3`: Returns/sets the color button.
* Font `Enum.Font`: Returns/sets the text font.
 ```XML
<imagelabel color="255, 0, 0"></imagelabel>
```

I will add the other shit later I'm lazy rn
