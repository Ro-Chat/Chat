local Import  = function(path) return loadstring(game:HttpGet(("https://raw.githubusercontent.com/Ro-Chat/Chat/main/v1/Modules/%s.lua"):format(path)))() end

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
