local ImageLib = Import("Image")
Import("VideoPlayer")

local Emoji = {
    CachedEmojis = {},
    PlayStack = {},
}

Emoji.MakeEmoji = function(parent, emoji, maxheight)
    local EM = ROCHAT_Config.Profile.Emojis[emoji]
    
    if EM.Type == "Image" then
        local ImageCache = Emoji.CachedEmojis[emoji] or Cache:GetAsset(EM.Url or ("RoChat/Emojis/" .. EM.Path))
        if not Emoji.CachedEmojis[emoji] then
            Emoji.CachedEmojis[emoji] = ImageCache
        end
        local Img = ImageLib.new(ImageCache.Buffer)
        local Image = Instance.new("ImageLabel", parent)
        Image.LayoutOrder = #parent:GetChildren()
        
        Image.BackgroundTransparency = 1
        local Height = Img.Height
        maxheight = maxheight or 32

        if Img.Height > maxheight then
            Height = Img.Height / 2
            if Height > maxheight then
                Height = maxheight
            end
        end

        Image.Size = UDim2.new(0, Img.WidthOffset * Height, 0, Height)

        if parent.AbsoluteSize.Y < Height then
            parent.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, Height))
            parent.Parent.Size = parent.Parent.Size + UDim2.new(0, 0, 0, Height - 20)
        end

        Image.Image = ImageCache.Asset

        return Image
    end
    
    if EM.Type == "Video" then

        -- Add spritesheet
        local Image = Instance.new("ImageLabel", parent)

        -- task.spawn(function ()
        Image.LayoutOrder = #parent:GetChildren()

        local Frames = not EM.Url and listfiles("RoChat/Emojis/" .. emoji) or {}

        if #Frames == 0 then
            for _, Frame in next, EM.Frames do
                table.insert(Frames, EM.Url .. emoji .. "/" .. Frame)
            end
        end

        Image.BackgroundTransparency = 1

        VideoPlayer:ImagePlay(parent, emoji, Image, Frames, EM.FPS, maxheight or 32)
        -- end)
        return Image
    end
end

return Emoji