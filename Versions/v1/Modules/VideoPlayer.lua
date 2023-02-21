local ImageLib = Import("Image")

getgenv().VideoPlayer = VideoPlayer or {
  Videos = {},
  Frames = {},
  MaxVideos = ROCHAT_Config.Profile.Emojis.MaxAnimatedEmojis or 2
}

function VideoPlayer.Append(self, val)
  table.insert(self.Videos, 1, val)
  -- self.Videos[2] = self.Videos[1] 
  -- self.Videos[1] = val
end

function VideoPlayer.ImagePlay(self, VideoName, ImageLabel, Images, FPS)
  --  task.spawn(function()
    local Frame = 1
    local Frames = {}

    -- print(#Images)
    if not self.Frames[VideoName] then
      for _, Frame in next, Images do
        table.insert(Frames, Cache:GetAsset(Frame))
      end

      self.Frames[VideoName] = Frames
    end

    Frames = self.Frames[VideoName]

    local Img = ImageLib.new(readfile(Frames[1].Path))
    ImageLabel.Size = UDim2.new(0, Img.WidthOffset * 22, 0, 22)

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
          ImageLabel.Size = UDim2.new(0, Img.WidthOffset * 22, 0, 22)

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