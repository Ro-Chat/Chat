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

        return Image
    end
    
    if EM.Type == "Video" then

        -- Add spritesheet
        local Image = Instance.new("ImageLabel", parent)

        Image.LayoutOrder = #parent:GetChildren()

        local Frames = EM.Path and listfiles("RoChat/Emojis/" .. emoji) or {}

        if #Frames == 0 then
            for _, Frame in next, EM.Frames do
                table.insert(Frames, EM.Url .. emoji .. "/" .. Frame)
            end
        end

        Image.BackgroundTransparency = 1

        VideoPlayer:ImagePlay(emoji, Image, Frames, EM.FPS)

        return Image
    end
end

return Emoji