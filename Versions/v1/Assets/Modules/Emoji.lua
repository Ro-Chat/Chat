local ImageLib = Import("Image")
Import("VideoPlayer")

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
        local Height = Img.Height

        if Img.Height > 50 then
            Image.Size = UDim2.new(0, Img.WidthOffset * 50, 0, 50)
            Height = 50
        else
            Image.Size = UDim2.new(0, Img.Width, 0, Img.Height)
        end

        if parent.AbsoluteSize.Y < Height then
            parent.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, Height))
            parent.Parent.Size = parent.Parent.Size + UDim2.new(0, 0, 0, Height - 18)
        end

        writefile("RoChat/Emojis/" .. emoji .. ".png", ImgBuffer)
        Image.Image = GetAsset("RoChat/Emojis/" .. emoji .. ".png")
        task.spawn(function()
            task.wait(0.25)
            delfile("RoChat/Emojis/" .. emoji .. ".png")
        end)

        return Image
    end
    
    if EM.Type == "Video" then

        -- Add spritesheet
        local Image = Instance.new("ImageLabel", parent)

        Image.LayoutOrder = #parent:GetChildren()

        local Frames = not EM.Url and listfiles("RoChat/Emojis/" .. emoji) or {}

        if #Frames == 0 then
            for _, Frame in next, EM.Frames do
                table.insert(Frames, EM.Url .. emoji .. "/" .. Frame)
            end
        end

        Image.BackgroundTransparency = 1

        VideoPlayer:ImagePlay(parent, emoji, Image, Frames, EM.FPS)

        return Image
    end
end

return Emoji