local ModulePath = debug.getinfo(2) and "https://raw.githubusercontent.com/Ro-Chat/Chat/main/v1/Modules" or "Chat/v1/Modules"

getgenv().Import  = function(path) return loadstring(game:HttpGet(("%s/%s.lua"):format(ModulePath, path)))() end

local Chat = Import("Chat")

Chat.ScrollingFrame = Players.LocalPlayer.PlayerGui.Chat.Frame.ChatChannelParentFrame.Frame_MessageLogDisplay.Scroller

local Config = Chat:LoadConfig()

Chat:CreateMessage({
    Message = "test *wow* :troll: Emojiojsw :pepe_cringe: dwmdwa jwodojsw dwmdwa jwodojsw dwmdwa jwodojsw dwmdwa jwodojsw dwmdwa jwodojsw dwmdwa jwod",
    Name = "Test",
    Color = {
        100,
        100,
        200
    }
})
