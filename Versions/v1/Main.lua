return function(Release, Fingerprint)
    local ModulePath = Release and "https://raw.githubusercontent.com/Ro-Chat/Chat/main/Versions/v1/Assets/Modules" or "RoChat/Versions/v1/Assets/Modules"

    getgenv().Import = function(path)
        local path = ("%s/%s.lua"):format(ModulePath, path)
        -- local start = os.clock()

        local status, result = pcall(function()
            if Release then
                return loadstring(game:HttpGet(path))()
            end
            return loadstring(readfile(path))()
        end)

        -- print(path, os.clock() - start)

        if not status then
            warn(path, "caused an error.")
            warn(result)
        end

        return result
    end

    local Request = syn and syn.request or http and http.request or request
    local base64 = {
        encode = syn and syn.crypt.base64.encode or crypt and crypt.base64encode,
        decode = syn and syn.crypt.base64.decode or crypt and crypt.base64decode
    }

    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer

    getgenv().Chat    = Chat or Import("Chat")
    getgenv().Utility = Utility or Import("Utility")
    getgenv().Plugin  = Plugin or Import("Plugin")
    getgenv().Embed   = Embed or Import("Embed")

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

    ROCHAT_Config.Client  = Client
    ROCHAT_Config.Enabled = ROCHAT_Config.Enabled or true

    Chat.ScrollingFrame = Players.LocalPlayer.PlayerGui.Chat.Frame.ChatChannelParentFrame.Frame_MessageLogDisplay.Scroller
    Chat.ChatBar        = Players.LocalPlayer.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar

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
                Client:Send({
                    Type = "UI",
                    SubType = "Chat",
                    Message = Message,
                    Channel = Chat.CurrentChannel
                })
            end

            local function runCommand(command, func)
                if Message:match("^/" .. command) then
                    local Args = Message:split(" ")
                    table.remove(Args, 1)
                    func(unpack(Args))
                end
            end

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

    -- print("Recieve")
    Client:OnRecieve(function(message)
        -- print(message)
        local Data = Utility:JSON(message)
        
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
                    local Counter = countDict(MessageData.Reactions)
                    if Counter == 0 then
                        ReactionFrame.Parent.Size = ReactionFrame.Parent.Size - UDim2.new(0, 0, 0, 28)
                        ReactionFrame:Destroy()
                        return
                    end
                    Frame:Destroy()
                    return
                end
                Reaction[Data.FromId] = nil
                Frame.TextLabel.Text = tostring(ReactionCount - 1)
            end
            if Data.SubType == "React" then
                Chat:CreateReaction(Data)
            end
            if Data.SubType == "Edit" then
                local MessageData = Chat:getMessage(Data.Channel, Data.Id)

                MessageData.Order = MessageData.Frame.LayoutOrder
                MessageData.Message = Data.Message
                MessageData.MessageId = Data.Id
                MessageData.Id = Data.From

                MessageData.Frame:Destroy()

                MessageData.Frame = Chat:CreateMessage(MessageData, Chat.Channels[Data.Channel].ScrollingFrame).Frame
            end
            if Data.SubType == "ChatExtra" then
                -- should change this so the client that sent the url makes the request then sends it to the server instead of the server making the request but whatever lol

                local Message = Chat:getMessage(Data.Channel, Data.MessageId)
                local Extras = Data.Extras
                local Images = Data.Images

                -- table.foreach(Images, print)

                for link, b64 in next, Images do
                    local Buffer = base64.decode(b64)
                    local ImageInfo = ImageLib.new(Buffer)
                    if ImageInfo.Type ~= "MP4" then
                        
                        local ImageLabel = Instance.new("ImageLabel")
                        ImageLabel.BackgroundTransparency = 1
                        -- Change dimensions so they fit into the chat

                        local AbsoluteSize = Chat.ScrollingFrame.AbsoluteSize

                        if ImageInfo.Height > AbsoluteSize.Y then
                            ImageInfo.Height = AbsoluteSize.Y - 4
                            ImageInfo.Width = ImageInfo.WidthOffset * ImageInfo.Height
                        end

                        if ImageInfo.Width > AbsoluteSize.X then
                            ImageInfo.Width = AbsoluteSize.X - 4
                            ImageInfo.Height = ImageInfo.HeightOffset * ImageInfo.Width
                        end

                        ImageLabel.Size = UDim2.new(0, ImageInfo.Width, 0, ImageInfo.Height)

                        -- Make image

                        local Path = ("ROCHAT_IMAGE_%s.%s"):format(math.random(1, 100), ImageInfo.Type)
                        writefile(Path, Buffer)
                        local Cached = Cache:GetAsset(Path)

                        ImageLabel.Image = Cached.Asset
                        
                        task.delay(2, function()
                            Cached:Clear()
                        end)
                        
                        Instance.new("UICorner", ImageLabel).CornerRadius = UDim.new(0, 6)
                        ImageLabel.Parent = Message.Frame
                        ImageLabel.Position = UDim2.new(0, 8, 0, Message.Frame.AbsoluteSize.Y + 4)
                        Message.Frame.Size = Message.Frame.Size + UDim2.new(0, 0, 0, ImageLabel.AbsoluteSize.Y + 4)
                    else
                        -- local Video = Instance.new("VideoFrame")
                    end
                end

                -- too lazy rn lol

                -- for link, data in next, Extras do
                --     -- Build embed XML

                --     local EmbedBuffer = ("<embed color=\"Color3.fromHex('%s')\" resize=\"true\">"):format(data["theme-color"] and data["theme-color"]:sub(1, 1) == "#" and data["theme-color"] or "#585858")

                --     EmbedBuffer = data["og:site_name"] and ("%s\n<label fontsize=\"8\">%s</label>"):format(EmbedBuffer, data["og:site_name"]) or EmbedBuffer
                --     EmbedBuffer = (data["og:title"] or data["title"]) and ("%s\n<label fontsize=\"18\">%s</label>"):format(EmbedBuffer, (data["og:title"] or data["title"])) or EmbedBuffer
                --     EmbedBuffer = data["og:description"] and ("%s\n<label>%s</label>"):format(EmbedBuffer, data["og:description"]) or EmbedBuffer

                --     EmbedBuffer = EmbedBuffer .. "\n</embed>"

                --     print(EmbedBuffer)

                --     -- Make embed based off of XML

                --     local embed = Embed.new(EmbedBuffer, Message.Frame)
                --     local instance = embed.instance
                --     instance.Position = UDim2.new(0, 8, 0, Message.Frame.AbsoluteSize.Y)
                --     Message.Frame.Size = Message.Frame.Size + UDim2.new(0, 0, 0, instance.AbsoluteSize.Y)
                -- end

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

                local ImageBin

                if ROCHAT_Config.Profile.User.Image then
                    ImageBin = readfile(ROCHAT_Config.Profile.User.Image)
                end

                ImageBin = ImageBin or Request({
                    Method = "GET",
                    Url = HttpService:JSONDecode(Request({
                        Method = "GET",
                        Url = ("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%s&size=48x48&format=Png&isCircular=true"):format(LocalPlayer.UserId)
                    }).Body).data[1].imageUrl
                }).Body

                Client:SendFile("PROFILE_IMG", ImageBin)
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
                Chat.Players = Data.Players
                Chat.Ranks = Data.Metadata.Ranks
                Chat.Channels.Default = {
                    Id = -1,
                    Name = "Default",
                    Description = "This is the default chat used by roblox.",
                    Messages = {},
                    ScrollingFrame = Chat.ScrollingFrame,
                    Chat = function(self, Data)
                        return Chat:CreateMessage(Data, self)
                    end
                }

                if Chat.ScrollingFrame.Parent.Parent:FindFirstChild("Channels") then
                    Chat.ScrollingFrame.Parent.Parent:FindFirstChild("Channels"):Destroy()
                    for _, ScrollingFrame in next, Chat.ScrollingFrame.Parent.Parent:GetChildren() do
                        if ScrollingFrame.Name == "ScrollingFrame" then
                            ScrollingFrame:Destroy()
                        end
                    end
                    Chat.CurrentChannel = "Default"
                end

                for _, Channel in next, Data.Channels do
                    if _ == "Default" then continue end
                    Chat.Channels[_] = Chat:CreateChannel(Channel)
                    for i, Message in next, Channel.Messages do
                        Chat:CreateMessage(Message, Channel.ScrollingFrame)
                    end
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
        if Data.Error then
            error(Data.Error)
        end
    end)
end
