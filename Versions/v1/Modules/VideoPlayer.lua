getgenv().Cache = Import("Cache")
local ImageLib = Import("Image")
getgenv().VideoPlayer = VideoPlayer or {
  Videos = {}
}

function VideoPlayer.Append(self, val)
  self.Videos[2] = self.Videos[1] 
  self.Videos[1] = val
end

function VideoPlayer.ImagePlay(self, ImageLabel, Images, FPS)
   task.spawn(function()
    local Frame = 0
    local Frames = {}

    for _, Frame in next, Images do
      table.insert(Frames, Cache:GetAsset(Frame))
    end

    while true do task.wait((1 / 60) * FPS)
      if Frame == #Frames then
        Frame = 0
      end
      local Asset, Path = Frames[Frame]

      print(Asset, Path)

      local Img = ImageLib.new(readfile(Path))
      Image.Size = UDim2.new(0, Img.WidthOffset * 22, 0, 22)

      Frame = Frame + 1
      ImageLabel.Image = Asset
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