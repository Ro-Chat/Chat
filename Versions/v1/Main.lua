return function(Release)
    local ModulePath = Release and "https://raw.githubusercontent.com/Ro-Chat/Chat/main/Versions/v1/Modules" or "RoChat/Versions/v1/Modules"

    getgenv().Import = function(path)
        local path = ("%s/%s.lua"):format(ModulePath, path)

        local status, result = pcall(function()
            if Release then
                return loadstring(game:HttpGet(path))()
            end
            return loadstring(readfile(path))()
        end)

        if not status then
            error(path, "casued an error", result)
        end

        return result
    end

    local Players = game:GetService("Players")

    local Chat    = Import("Chat")
    local Utility = Import("Utility")

    local Client = Utility:Client({
        Url = ROCHAT_Config.WSS
    })

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
end
