local ImageLib = Import("Image")

getgenv().VideoPlayer = VideoPlayer or {
  Videos = {},
  Frames = {},
  MaxVideos = ROCHAT_Config.Profile.Settings.MaxAnimatedEmojis or 2
}


-- Cache emojis
task.spawn(function()
  for EmojiName, Emoji in next, ROCHAT_Config.Profile.Emojis do
    if EmojiName.Type == "Video" then
      local Frames = not Emoji.Url and listfiles("RoChat/Emojis/" .. EmojiName) or {}

      if #Frames == 0 then
          for _, Frame in next, Emoji.Frames do
              table.insert(Frames, Emoji.Url .. EmojiName .. "/" .. Frame)
          end
      end
      local CachedFrames = {}

      for _, Frame in next, Frames do
        table.insert(CachedFrames, Cache:GetAsset(Frame))
      end

      VideoPlayer.Frames[EmojiName] = CachedFrames
    end
  end
end)

function VideoPlayer.Append(self, val)
  table.insert(self.Videos, 1, val)
  -- self.Videos[2] = self.Videos[1] 
  -- self.Videos[1] = val
end

function VideoPlayer.ImagePlay(self, Parent, VideoName, ImageLabel, Images, FPS)
  --  task.spawn(function()
    local Frame = 1
    local Frames = {}

    -- Cache frames
    if not self.Frames[VideoName] then
      for _, Frame in next, Images do
        table.insert(Frames, Cache:GetAsset(Frame))
      end

      self.Frames[VideoName] = Frames
    end

    Frames = self.Frames[VideoName]

    local Img = ImageLib.new(readfile(Frames[1].Path))
    local LastHeight = Img.Height

    if Img.Height > 50 then
        ImageLabel.Size = UDim2.new(0, Img.WidthOffset * 50, 0, 50)
        LastHeight = 50
    else
        ImageLabel.Size = UDim2.new(0, Img.Width, 0, Img.Height)
    end

    if Parent.AbsoluteSize.Y < LastHeight then
      Parent.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, LastHeight))
      Parent.Parent.Size = Parent.Parent.Size + UDim2.new(0, 0, 0, LastHeight - 18)
    end

    -- Parent.Size = ImageLabel.Size
    -- ImageLabel.Size = UDim2.new(0, Img.WidthOffset * 22, 0, 22)

    local Playing = true

    local VideoData = {
      Pause = function(self)
        Playing = false
      end,
      Play = function(self)
        Playing = true
      end
    }

    ImageLabel.MouseEnter:Connect(function(x, y)
      self:Add(VideoData)
    end)

    task.spawn(function ()
      while true do task.wait(1 / FPS)
        -- if not Playing then break end
        if Frame == 1 or Playing then
          if Frame == #Frames then
            Frame = 1
          end

          local FrameData = Frames[Frame]

          -- if FrameData then
          local Img = ImageLib.new(readfile(FrameData.Path))

          if Img.Height > LastHeight then
            ImageLabel.Size = UDim2.new(0, Img.WidthOffset * LastHeight, 0, LastHeight)
          else
            ImageLabel.Size = UDim2.new(0, Img.Width, 0, Img.Height)
          end

          Frame = Frame + 1
          ImageLabel.Image = FrameData.Asset
          -- end
        end
      end
    end)

    self:Add(VideoData)
end

function VideoPlayer.Add(self, Video)
  -- if self.Videos[1] == Video or self.Videos[2] == Video then return end

  if #self.Videos > self.MaxVideos then
      self.Videos[self.MaxVideos]:Pause()
  end

  VideoPlayer:Append(Video)
  Video:Play()
end

return VideoPlayer