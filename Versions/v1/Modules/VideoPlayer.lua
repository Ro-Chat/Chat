getgenv().VideoPlayer = VideoPlayer or {
  Videos = {}
}

local GetAsset = syn and getsynasset or getcustomasset

function VideoPlayer.Append(self, val)
  self.Videos[2] = self.Videos[1] 
  self.Videos[1] = val
end

function VideoPlayer.ImagePlay(self, ImageLabel, Images, FPS)
   task.spawn(function()
    local Frame = 0
    local Frames = #Images
    while true do task.wait((1 / FPS))
      if Frame == Frames then
        Frame = 0
      end
      Frame = Frame + 1
      ImageLabel.Image = GetAsset("RoChat/Emojis/" .. Images[Frame])
    end
   end)
end

function VideoPlayer.Add(self, Video)
  if self.Videos[1] == Video or self.Videos[2] == Video then return end
  if self.Videos[2] then
      self.Videos[2]:Pause()
  end


  VideoPlayer:Append(Video)
  Video:Play()
end

return VideoPlayer