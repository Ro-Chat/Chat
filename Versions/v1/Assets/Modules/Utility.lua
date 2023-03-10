local Utility = {}

local HttpService = game:GetService("HttpService")

local GCMEncrypt = syn and syn.crypt.encrypt or crypt and function(data, key, nonce) return crypt.custom_encrypt(data, key, nonce, "GCM") end
local GCMDecrypt = syn and syn.crypt.decrypt or crypt and function(data, key, nonce) return crypt.custom_decrypt(data, key, nonce, "GCM") end
local decodeb64  = syn and syn.crypt.base64.decode or crypt and crypt.base64decode
local encodeb64  = syn and syn.crypt.base64.encode or crypt and crypt.base64encode

local Request   = syn and syn.request or http and http.request
local WebSocket = syn and syn.websocket or WebSocket

function Utility:JSON(val)
  if type(val) == "string" then
      return HttpService:JSONDecode(val)
  end
  return HttpService:JSONEncode(val)
end

function Utility:Client(data)
  --[[
     Creates a websocket client
  ]]

  if ROCHAT_Config.Client then
    -- ROCHAT_Config.Client:Send({
    --   Type = "Connection",
    --   SubType = "Leave",
    -- })
    pcall(ROCHAT_Config.Client.Close, ROCHAT_Config.Client)
  end

  local Client = {
      WSS               = data.Url,
      Key               = data.Key,
      Client            = WebSocket.connect(data.Url),
      SendFile          = function(self, Name, Bin, Key)
        self:Send({
          Type = "File",
          Name = Name,
          Keyless = not Key,
          Bin = encodeb64(not Key and Bin or GCMEncrypt(Bin, Key))
        })
      end,
      OnRecieve         = function(self, func)
        if self.RecieveConnection then self.RecieveConnection:Disconnect() end
        self.RecieveConnection = self.Client.OnMessage:Connect(func)
      end,
      Send              = function(self, value)
          if type(value) == "table" then
            value = Utility:JSON(value)
          end
          value = tostring(value)
          self.Client:Send(value)
      end,
      OnClose           = function(self, func)
          if self.CloseConnection then self.CloseConnection:Disconnect() end
          self.CloseConnection = self.Client.OnClose:Connect(func)
      end,
      Close = function(self)
          if self.RecieveConnection then self.RecieveConnection:Disconnect() end

          self.RecieveConnection = nil
          self.Client = nil

          self.Client:Close()

          if self.CloseConnection then self.CloseConnection:Disconnect() end
          self.CloseConnection = nil
      end,
      CloseConnection   = nil,
      RecieveConnection = nil,
  }

  Client:Send({
    Type = "Connection",
    SubType = "Join",
    Fingerprint = data.Fingerprint,
    Name = ROCHAT_Config.Profile.User.Name,
    Color = ROCHAT_Config.Profile.User.Color or ROCHAT_Config.Profile.User.Colour,
  })

  return Client
end

return Utility