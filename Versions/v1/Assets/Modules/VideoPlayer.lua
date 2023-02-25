local ImageLib = Import("Image")

getgenv().VideoPlayer = VideoPlayer or {
  Videos = {},
  Frames = {},
  MaxVideos = ROCHAT_Config.Profile.Settings.MaxAnimatedEmojis or 2
}


-- Cache emojis
task.spawn(function()
  for EmojiName, Emoji in next, ROCHAT_Config.Profile.Emojis do
    if Emoji.Type == "Video" then
      -- print("Attempting to cache", EmojiName)
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
      -- print("Successfully cached", EmojiName)
      VideoPlayer.Frames[EmojiName] = CachedFrames
    end
  end
end)

function VideoPlayer.Append(self, val)
  table.insert(self.Videos, 1, val)
  -- self.Videos[2] = self.Videos[1] 
  -- self.Videos[1] = val
end

function VideoPlayer.ImagePlay(self, Parent, VideoName, ImageLabel, Images, FPS, MaxHeight)
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

    local Img = ImageLib.new(Frames[1].Buffer)
    local Height = Img.Height

    if Img.Height > MaxHeight then
        Height = Img.Height / 2
        if Height > MaxHeight then
            Height = MaxHeight
        end
    end

    ImageLabel.Size = UDim2.new(0, Img.WidthOffset * Height, 0, Height)

    if Parent.AbsoluteSize.Y < Height then
      Parent.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, Height))
      Parent.Parent.Size = Parent.Parent.Size + UDim2.new(0, 0, 0, Height - 18)
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
          local Img = ImageLib.new(FrameData.Buffer)

          if Img.Height > Height then
            ImageLabel.Size = UDim2.new(0, Img.WidthOffset * Height, 0, Height)
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