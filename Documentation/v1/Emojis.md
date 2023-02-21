
# Image
For an image you'll need to use the following JSON.

### Json
* you'll only need to use Path or Url not both.

```json
"Emoji_Name": {
	"Type": "Image",
	"Path": "emoji.png",
	"Url": "https://google.com/emoji.png"
}
```

# GIF
For a video you'll need to convert the GIF or MP4 into images. I'd use [ImageMagick](https://imagemagick.org/) for that make sure to select legacy in the installer so you install convert.
after installing **Magick** make sure to run the convert command like `convert PATH_TO_GIF.gif FRAMES_PATH%03d.png`.
when the convert command has finished you'll need to create a folder for the emoji in `RoChat/Emojis` make sure the name of the folder is the name of the emoji, then you'll have to put the images that the convert command extracted inside of the folder you created.

### Json
 ```json
"Emoji_Name": {
	"Type": "Video",
	"FPS": 20
}
```
