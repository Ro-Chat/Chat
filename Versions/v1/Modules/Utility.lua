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
  local Client = {
      WSS               = data.Url,
      Key               = data.Key,
      Client            = WebSocket.connect(data.Url),
      SendFile          = function(self, Name, Bin, Key)
        self:Send({
          Name = Name,
          Bin = encodeb64(not Key and Bin or GCMEncrypt(Bin, Key))
        })
      end,
      CloseConnection   = nil,
      RecieveConnection = nil,
  }

  function Client:Send(value)
      if type(value) == "table" then
        value = Utility:JSON(value)
      end
      value = tostring(value)
      Client.Client:Send(value)
  end

  function Client:OnRecieve(func)
      if Client.RecieveConnection then Client.RecieveConnection:Disconnect() end
      Client.RecieveConnection = Client.Client.OnMessage:Connect(func)
  end

  function Client:OnClose(func)
      if Client.CloseConnection then Client.CloseConnection:Disconnect() end
      Client.CloseConnection = Client.Client.OnClose:Connect(func)
  end

  function Client:Close()
      if Client.RecieveConnection then Client.RecieveConnection:Disconnect() end
      Client.Client:Close()
      if Client.CloseConnection then Client.CloseConnection:Disconnect() end

      Client.RecieveConnection = nil
      Client.CloseConnection = nil
      Client.Client = nil
  end

  Client:Send({
    Type = "Connection",
    SubType = "Join",
    Name = ROCHAT_Config.Profile.Name,
    Color = ROCHAT_Config.Profile.Color or ROCHAT_Config.Profile.Colour,
  })

  return Client
end

return Utility