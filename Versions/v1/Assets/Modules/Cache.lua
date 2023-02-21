local Asset = syn and getsynasset or getcustomasset

local Cache = {
    CachedImages = {},
    GetAsset = function(self, Path)
        if Path:match("^http") then
          local FilePath = "RoChat/Emojis/" .. Path:split("/")[#Path:split("/")]
        --   local AssetData = game:HttpGet(Path)
            
          if not isfile(FilePath) then
              writefile(FilePath, game:HttpGet(Path))
          end
          
          Path = FilePath
          
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