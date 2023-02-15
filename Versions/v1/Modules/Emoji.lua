local VideoPlayer = Import("VideoPlayer")

local GetAsset = syn and getsynasset or getcustomasset

local Emoji = {
    PlayStack = {},
}

Emoji.MakeEmoji = function(parent, emoji)
    local EM = ROCHAT_Config.Profile.Emojis[emoji]
    
    if EM.Type == "Image" then
        local ImgBuffer = EM.Url and game:HttpGet(EM.Url) or EM.Path and readfile("RoChat/Emojis/" .. EM.Path)
        local Img = ImageLib.new(ImgBuffer)
        local Image = Instance.new("ImageLabel", parent)
        Image.LayoutOrder = #parent:GetChildren()
        
        Image.BackgroundTransparency = 1
        Image.Size = UDim2.new(0, Img.WidthOffset * 22, 0, 22)
        writefile("RoChat/Emojis/" .. emoji .. "_tmp.png", ImgBuffer)
        Image.Image = GetAsset("RoChat/Emojis/" .. emoji .. "_tmp.png")
        task.spawn(function()
            task.wait(0.25)
            delfile("RoChat/Emojis/" .. emoji .. "_tmp.png")
        end)
    end
    
    if EM.Type == "Video" then
        local Image = Instance.new("ImageLabel", parent)

        Image.LayoutOrder = #parent:GetChildren()

        local Frames = EM.Path and listfiles("RoChat/Emojis/" .. emoji) or {}

        if Frames == {} then
            for _, Frame in next, EM.Frames do
                print(EM.Url, Frame)
                table.insert(Frames, EM.Url .. Frame)
            end
        end

        Image.BackgroundTransparency = 1

        VideoPlayer:ImagePlay(Image, Frames, EM.FPS)
    end
end

return Emoji