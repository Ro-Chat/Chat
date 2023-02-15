local Asset = syn and getsynasset or getcustomasset

local Cache = {
    CachedImages = {},
    GetAsset = function(self, Path)
        print(Path)
        if Path:match("^http") then
          writefile("RoChat/Emojis/" .. Path:split("/")[#Path:split("/")], game:HttpGet(Path))
          Path = "RoChat/Emojis/" .. Path:split("/")[#Path:split("/")]
          table.insert(self.CachedImages, Path)
        end
      
        return {
            Asset = Asset(Path),
            Path = Path
        }
    end,
    Clear = function(self)
        for _, Path in next, self.CachedImages do
            delfile(Path)
        end
    end
}

return Cache