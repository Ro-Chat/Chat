---- Crypt Library

local GCMEncrypt = syn and syn.crypt.encrypt or crypt and function(data, key, nonce) return crypt.custom_encrypt(data, key, nonce, "GCM") end
local GCMDecrypt = syn and syn.crypt.decrypt or crypt and function(data, key, nonce) return crypt.custom_decrypt(data, key, nonce, "GCM") end
local decodeb64 = syn and syn.crypt.base64.decode or crypt and crypt.base64decode
local encodeb64 = syn and syn.crypt.base64.encode or crypt and crypt.base64encode


---- Services

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")

---- Misc.

local Request   = syn and syn.request or http and http.request
local WebSocket = syn and syn.websocket or WebSocket
local GetAsset  = syn and getsynasset or getcustomasset

---- Imports

local Import  = function(path) return loadstring(game:HttpGet(("https://raw.githubusercontent.com/Ro-Chat/Chat/main/v1/Modules/%s.lua"):format(path))).Body)() end
local Utility = Import("Utility")
local Image   = Import("Image")
local UI      = Import("UI")

local Embed    = UI.Embed
local Interact = UI.Interact
local Extra    = UI.Extra

Extra.GetAsset = GetAsset
Extra.Image    = Image
