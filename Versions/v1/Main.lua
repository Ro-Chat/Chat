return function(Release)
    local ModulePath = Release and "https://raw.githubusercontent.com/Ro-Chat/Chat/main/Versions/v1/Assets/Modules" or "RoChat/Versions/v1/Assets/Modules"

    getgenv().Import = function(path)
        local path = ("%s/%s.lua"):format(ModulePath, path)

        local status, result = pcall(function()
            if Release then
                return loadstring(game:HttpGet(path))()
            end
            return loadstring(readfile(path))()
        end)

        if not status then
            warn(path, "caused an error.")
            warn(result)
        end

        return result
    end

    local Players = game:GetService("Players")

    local Chat    = Import("Chat")
    local Utility = Import("Utility")
    local Embed   = Import("Embed")

    local Client = Utility:Client({
        Url = ROCHAT_Config.WSS
    })

    local function getDataFromId(Id)
        for _, Player in next, Chat.Players do
            if Player.Id == Id then return Player end
        end
    end

    local function countDict(dict)
        local Count = 0
    
        for _ in next, dict do
            Count = Count + 1
        end
    
        return Count
    end

    Client:OnRecieve(function(message)
        local Data = Utility:JSON(message)
        -- print(message)
        if Data.Type == "UI" then
            -- if Data.SubType == "Interact" then
            --     Interact.Callbacks[Data.Id](Data.Value)
            -- end
            -- if Data.SubType == "Create" then
            --     Embed.new(Data.Value)
            -- end
            if Data.SubType == "Destroy" then
                local MessageData = Chat.Messages[Data.Id]
                MessageData.Frame:Destroy()
            end
            if Data.SubType == "RevokeReact" then
                local MessageData = Chat.Messages[Data.MessageId]
                local Reaction = MessageData.Reactions[Data.Reaction]
                local Frame = Reaction[Data.FromId]
                if not Frame then return end
                local ReactionCount = countDict(Reaction)
                if ReactionCount == 1 then
                    MessageData.Reactions[Data.Reaction] = nil
                    local ReactionFrame = Frame.Parent
                    if countDict(MessageData.Reactions) == 0 then
                        ReactionFrame.Parent.Size = ReactionFrame.Parent.Size - UDim2.new(0, 0, 0, 28)
                        ReactionFrame:Destroy()
                        return
                    end
                    Frame:Destroy()
                    return
                end
                Reaction[Data.FromId] = nil
                Frame.TextLabel.Text = ReactionCount
            end
            if Data.SubType == "React" then
                Chat:CreateReaction(Data)
            end
            if Data.SubType == "Edit" then
                local MessageData = Chat.Messages[Data.Id]
                local Order = MessageData.Frame.LayoutOrder

                MessageData.Frame:Destroy()
                MessageData.Order = Order
                MessageData.Message = Data.Message
                MessageData.MessageId = Data.Id
                MessageData.Id = Data.From

                Chat:CreateMessage(MessageData)
            end
            if Data.SubType == "Chat" then
                task.spawn(function()
                    for _, Callback in next, Chat.OnChat.Callbacks do
                        pcall(Callback, getDataFromId(Data.Id), Data)
                    end
                end)
                Chat:CreateMessage(Data)
            end
        end
        if Data.Type == "Connection" then
            if Data.SubType == "Join" then
                table.insert(Chat.Players, Data)
                Chat:CreateMessage({
                    Name = "System",
                    Message = ("@%s connected to the server."):format(Data.Name),
                    Color = {
                        80,
                        80,
                        80
                    }
                })
            end
            if Data.SubType == "Leave" then
                for Idx, Player in next, Chat.Players do
                    if Player.Id == Data.Id then
                        Chat:CreateMessage({
                            Name = "System",
                            Message = ("@%s left the server."):format(Player.Name)
                        })
                        table.remove(Chat.Players, Idx)
                        break
                    end
                end
            end
            if Data.SubType == "Info" then
                ROCHAT_Config.Id = Data.Id
                ROCHAT_Config.Server = {
                    MessageLogs = Data.MessageLogs,
                }
            end
        end
    end)

    ROCHAT_Config.Client = Client
    ROCHAT_Config.Enabled = ROCHAT_Config.Enabled or true

    -- Change this for custom chats
    Chat.ScrollingFrame = Players.LocalPlayer.PlayerGui.Chat.Frame.ChatChannelParentFrame.Frame_MessageLogDisplay.Scroller
    Chat.ChatBar        = Players.LocalPlayer.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar

    -- Chat.ChatBar.TextBounds.TextScaled = false
    -- task.wait(0.2)
    -- Chat.ChatBar.TextBounds.TextScaled = true

    Embed.ScrollingFrame = Chat.ScrollingFrame

    local EnterConnection = getconnections(Chat.ChatBar.FocusLost)[1]
    
    Players.LocalPlayer.Chatted:Connect(function(Message)
        Chat.ChatBar = Players.LocalPlayer.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
        local function runCommand(command, func)
            if Message:match("^/" .. command) then
                local Args = Message:split(" ")
                table.remove(Args, 1)
                func(unpack(Args))
            end
        end
        
        runCommand("enable", function()
            ROCHAT_Config.Enabled = true
            Chat.ChatBar.Text = ""
            EnterConnection:Disable()
            local customConnection;customConnection = Chat.ChatBar.FocusLost:Connect(function(enter)
                if not enter then return end
                local Message = Chat.ChatBar.Text
                if Message == "" then return end
                if Chat.ChatMode == "Edit" then
                    ROCHAT_Config.Client:Send({
                        Type = "UI",
                        SubType = "Edit",
                        Id = Chat.EditingId,
                        Message = Message
                    })
                    Chat.ChatMode = "Chat"
                    Chat.ChatBar.Text = ""
                    return
                end
                if Chat.ChatMode == "Chat" then
                    if Message:sub(1, 1) ~= "/" then
                        -- print(ROCHAT_Config.Profile.User.Name)
                        if not Chat.WhisperTo then
                            Client:Send({
                                Type = "UI",
                                SubType = "Chat",
                                Message = Message,
                            -- Name = ROCHAT_Config.Profile.User.Name,
                            -- Color = ROCHAT_Config.Profile.User.Color
                            })
                        else
                            Client:Send({
                                Type = "UI",
                                SubType = "Chat",
                                To = Chat.WhisperTo,
                                Message = Message
                            })
                        end
                        Chat.ChatBar.Text = ""
                    end
                    local function runCommand(command, func)
                        if Message:match("^/" .. command) then
                            local Args = Message:split(" ")
                            table.remove(Args, 1)
                            func(unpack(Args))
                        end
                    end
                    
                    runCommand("disable", function()
                        ROCHAT_Config.Enabled = false
                        customConnection:Disconnect()
                        Chat.ChatBar.Text = ""
                        EnterConnection:Enable()
                    end)

                    runCommand("redeem", function(key)
                        ROCHAT_Config.Client:Send({
                            Type = "Rank",
                            SubType = "RedeemOwner",
                            Key = key
                        })
                    end)
                end
            end)
        end)
    end)
    if ROCHAT_Config.Enabled then
        EnterConnection:Disable()
        local customConnection;customConnection = Chat.ChatBar.FocusLost:Connect(function(enter)
         Chat.ChatBar = Players.LocalPlayer.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
         if not enter then return end
         local Message = Chat.ChatBar.Text
         if Message == "" then return end
         if Chat.ChatMode == "Edit" then
            ROCHAT_Config.Client:Send({
				Type = "UI",
				SubType = "Edit",
				Id = Chat.EditingId,
				Message = Message
			})
            Chat.ChatMode = "Chat"
            Chat.ChatBar.Text = ""
            return
         end
         if Chat.ChatMode == "Chat" then
            if Message:sub(1, 1) ~= "/" then
                if not Chat.WhisperTo then
                    Client:Send({
                        Type = "UI",
                        SubType = "Chat",
                        Message = Message,
                    -- Name = ROCHAT_Config.Profile.User.Name,
                    -- Color = ROCHAT_Config.Profile.User.Color
                    })
                else
                    Client:Send({
                        Type = "UI",
                        SubType = "Chat",
                        To = Chat.WhisperTo,
                        Message = Message
                    })
                end
                Chat.ChatBar.Text = ""
            end
                local function runCommand(command, func)
                    if Message:match("^/" .. command) then
                        local Args = Message:split(" ")
                        table.remove(Args, 1)
                        func(unpack(Args))
                    end
                end
                
                runCommand("disable", function()
                    ROCHAT_Config.Enabled = false
                    customConnection:Disconnect()
                    Chat.ChatBar.Text = ""
                    EnterConnection:Enable()
                end)

                runCommand("redeem", function(key)
                    ROCHAT_Config.Client:Send({
                        Type = "Rank",
                        SubType = "RedeemOwner",
                        Key = key
                    })
                end)
            end
        end)
    end
end
