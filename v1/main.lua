local Request   = syn and syn.request or http and http.request
local WebSocket = syn and syn.websocket or WebSocket
local GetAsset  = syn and getsynasset or getcustomasset

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")

local GCMEncrypt = syn and syn.crypt.encrypt or crypt and function(data, key, nonce) return crypt.custom_encrypt(data, key, nonce, "GCM") end
local GCMDecrypt = syn and syn.crypt.decrypt or crypt and function(data, key, nonce) return crypt.custom_decrypt(data, key, nonce, "GCM") end

local decodeb64 = syn and syn.crypt.base64.decode or crypt and crypt.base64decode
local encodeb64 = syn and syn.crypt.base64.encode or crypt and crypt.base64encode

local Import = function(path) return loadstring(game:HttpGet("")).Body)() end

local Image = loadstring(game:HttpGet("https://pastebin.com/raw/9vdb5LW8"))()
local UI    = loadstring(game:HttpGet("https://pastebin.com/raw/b9hhzxGK"))()

local Embed    = UI.Embed
local Interact = UI.Interact
local Extra    = UI.Extra

Extra.GetAsset = GetAsset
Extra.Image    = Image
