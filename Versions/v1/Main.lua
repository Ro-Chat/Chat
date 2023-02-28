return function(Release, Fingerprint)
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
        Url = ROCHAT_Config.WSS,
        Fingerprint = Fingerprint
    })

    local function getDataFromId(Id)
        for _, Player in next, Chat.Players do
            table.foreach(Player, print)
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

    -- local function getMessage(channel, id)
    --     for _, Message in next, Chat.Channels[channel].Messages do
    --         if Message.Id == id or Message.MessageId == id then return Message end
    --     end
    -- end

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
                local MessageData = Chat:getMessage(Data.Channel, Data.Id)
                MessageData.Frame:Destroy()
            end
            if Data.SubType == "RevokeReact" then
                local MessageData = Chat:getMessage(Data.Channel, Data.MessageId)
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
                local MessageData = Chat:getMessage(Data.Channel, Data.Id)

                print("Data")
                table.foreach(Data, print)

                MessageData.Order = MessageData.Frame.LayoutOrder
                MessageData.Message = Data.Message
                MessageData.MessageId = Data.Id
                MessageData.Id = Data.From

                print("MessageData")
                table.foreach(MessageData, print)

                MessageData.Frame:Destroy()

                MessageData.Frame = Chat:CreateMessage(MessageData, Chat.Channels[Data.Channel].ScrollingFrame)
            end
            if Data.SubType == "Chat" then
                task.spawn(function()
                    for _, Callback in next, Chat.OnChat.Callbacks do
                        pcall(Callback, getDataFromId(Data.Id), Data)
                    end
                end)
                Chat:CreateMessage(Data, Chat.Channels[Data.Channel].ScrollingFrame)
            end
        end
        if Data.Type == "Connection" then
            if Data.SubType == "Join" then
                Data.Type = nil
                Data.SubType = nil
                table.insert(Chat.Players, Data)
                repeat task.wait() until Chat.Channels["General"] and Chat.Channels["General"].ScrollingFrame
                Chat:CreateMessage({
                    Name = "System",
                    Message = ("@%s connected to the server."):format(Data.Name),
                    Color = {
                        80,
                        80,
                        80
                    }
                }, Chat.Channels["General"].ScrollingFrame)
            end
            if Data.SubType == "Leave" then
                for Idx, Player in next, Chat.Players do
                    if Player.Id == Data.Id then
                        Chat:CreateMessage({
                            Name = "System",
                            Message = ("@%s left the server."):format(Player.Name),
                            Color = {
                                80,
                                80,
                                80
                            }
                        }, Chat.Channels["General"].ScrollingFrame)
                        table.remove(Chat.Players, Idx)
                        break
                    end
                end
            end
            if Data.SubType == "Info" then
                ROCHAT_Config.Id = Data.Id
                ROCHAT_Config.Server = {
                    MessageLogs = Data.MessageLogs,
                    Metadata = Data.Metadata
                }

                Chat.Channels = Data.Channels
                Chat.Ranks = Data.Metadata.Ranks
                Chat.Channels["Default"] = {
                    Id = -1,
                    Name = "Default",
                    Description = "This is the default chat used by roblox.",
                    Messages = {},
                    ScrollingFrame = Chat.ScrollingFrame
                    -- Icon = 
                }

                for _, Channel in next, Data.Channels do
                    if _ == "Default" then continue end
                    Data.Channels[_].ScrollingFrame = Chat:CreateChannel(Channel)
                end
            end
        end
        if Data.Type == "Rank" then
            if Data.SubType == "Set" then
                for _, Rank in next, Chat.Ranks do
                    if Rank.Name == Data.Rank then
                        table.insert(Rank.Fingerprints, Data.Fingerprint)
                    end
                end
            end
            if Data.SubType == "Remove" then
                for _, Rank in next, Chat.Ranks do
                    if Rank.Name == Data.Rank then
                        table.remove(Rank.Fingerprints, table.find(Rank.Fingerprints, Data.Fingerprint))
                    end
                end
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
    local customConnection

    local function getPlayer(name)
        if name == "me" then
            return getDataFromId(ROCHAT_Config.Id)
        end
        for _, Player in next, Chat.Players do
            if Player.Name:match(("^%s"):format(name)) then
                return Player
            end
        end
    end

    function FocusLost(enter)
        if not enter then return end
        if Chat.CurrentChannel == "Default" then
            -- EnterConnection:Disable()
            -- customConnection = Chat.ChatBar.FocusLost:Connect(FocusLost)
            customConnection:Disconnect()
            EnterConnection:Enable()
            return
        end
        local Message = Chat.ChatBar.Text
        if Message == "" then return end
        if Chat.ChatMode == "Edit" then
            ROCHAT_Config.Client:Send({
                Type = "UI",
                SubType = "Edit",
                Id = Chat.EditingId,
                Message = Message,
                Channel = Chat.CurrentChannel
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
                        Channel = Chat.CurrentChannel
                    -- Name = ROCHAT_Config.Profile.User.Name,
                    -- Color = ROCHAT_Config.Profile.User.Color
                    })
                else
                    Client:Send({
                        Type = "UI",
                        SubType = "Chat",
                        To = Chat.WhisperTo,
                        Message = Message,
                    })
                end
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

            runCommand("leave", function()
                ROCHAT_Config.Client:Close()
                ROCHAT_Config.Enabled = false
                customConnection:Disconnect()
                Chat.ChatBar.Text = ""
                EnterConnection:Enable()
            end)

            runCommand("rank", function(mode, who, rank)
                if mode:lower() == "set" then
                    local Player = getPlayer(who)
                    ROCHAT_Config.Client:Send({
                        Type = "Rank",
                        SubType = "Set",
                        Id = Player.Id,
                        Rank = rank
                    })
                    return
                end
                if mode:lower() == "remove" then
                    local Player = getPlayer(who)
                    ROCHAT_Config.Client:Send({
                        Type = "Rank",
                        SubType = "Remove",
                        Id = Player.Id,
                        Rank = rank
                    })
                    return
                end
            end)

            Chat.ChatBar.Text = ""
        end
    end

    local ChannelCheck = coroutine.create(function()
        local Check = true

        while true do task.wait()
            Chat.ChatBar = Players.LocalPlayer.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
            if Chat.CurrentChannel ~= "Default" and Check then
                EnterConnection:Disable()
                customConnection = Chat.ChatBar.FocusLost:Connect(FocusLost)
                Check = false
            elseif not Check and Chat.CurrentChannel == "Default" then
                if customConnection and customConnection.Connected then
                    customConnection:Disconnect()
                end
                EnterConnection:Enable()
                Check = true
            end
        end
    end)

    coroutine.resume(ChannelCheck)

    -- Players.LocalPlayer.Chatted:Connect(function(Message)
    --     local function runCommand(command, func)
    --         if Message:match("^/" .. command) then
    --             local Args = Message:split(" ")
    --             table.remove(Args, 1)
    --             func(unpack(Args))
    --         end
    --     end

    --     -- print(Chat.CurrentChannel)
        
    --     -- runCommand("enable", function()
    --     --     ROCHAT_Config.Enabled = true
    --     --     Chat.ChatBar.Text = ""
    --     --     EnterConnection:Disable()
    --     --     customConnection = Chat.ChatBar.FocusLost:Connect(FocusLost)
    --     -- end)
    -- end)
    -- if ROCHAT_Config.Enabled then
    --     EnterConnection:Disable()
    --     customConnection = Chat.ChatBar.FocusLost:Connect(FocusLost)
    -- end
end
