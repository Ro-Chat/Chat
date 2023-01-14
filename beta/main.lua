--[[
Chat TODOs:
  0. Stability Fixes (spaces at the begining of chat crashes, \n by itself crashes, seems to be a problem with special characters)
  1. More discord like shit (reactions, embedded messages, code markup ex. ```lua print("egg") ```, edit)
  2. Fix Image positioning
  3. Sprays (TF2, CS:GO, ect)
  4. Admin commands (toggable)
  
  (Most likely impossible TODOs)
  1. Nonplayer Multiplayer (play together in one player games)
  2. Screen share

]]

-- Constants

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local Request = syn and syn.request or http and http.request
local WebSocket = syn and syn.websocket or WebSocket
local GetAsset = syn and getsynasset or getcustomasset
local MessageLogDisplay = LocalPlayer.PlayerGui.Chat.Frame.ChatChannelParentFrame.Frame_MessageLogDisplay

-- Image Library

local Image = loadstring(game:HttpGet("https://pastebin.com/raw/9vdb5LW8"))()

-- UI Library

local UI = loadstring(game:HttpGet("https://pastebin.com/raw/b9hhzxGK"))()

local Embed = UI.Embed
local Interact = UI.Interact
local Extra = UI.Extra

Extra.GetAsset = GetAsset
Extra.Image = Image

local InteractCallbacks = {}

-- Chat Variables

local CustomChatEnabled = true
local Sound = Instance.new("Sound")
Sound.Name = "88y218hd891028hdy"
Sound.Parent = workspace
Sound.Volume = 2
Sound.Looped = false

-- Crypt Shit

local GCMEncrypt = syn and syn.crypt.encrypt or crypt and function(data, key, nonce) return crypt.custom_encrypt(data, key, nonce, "GCM") end
local GCMDecrypt = syn and syn.crypt.decrypt or crypt and function(data, key, nonce) return crypt.custom_decrypt(data, key, nonce, "GCM") end

local decodeb64 = syn and syn.crypt.base64.decode or crypt and crypt.base64decode
local encodeb64 = syn and syn.crypt.base64.encode or crypt and crypt.base64encode

-- Config

local Config = HttpService:JSONDecode(isfile("BallsChat/config.json") and readfile("BallsChat/config.json") or HttpService:JSONEncode({
    WebSocket = {
        Url = "wss://WS-Server.eeeeeevbr.repl.co",
        Key = "Default"
    },
    Chat = {
        Name = LocalPlayer.DisplayName,
        Color = {math.random(100, 255), math.random(100, 255), math.random(100, 255)},
        Id = LocalPlayer.UserId,
        Description = "No description.",
        Prefix = "/",
        JoinMessage = "Hello!",
        Image = encodeb64(Request({
            Method = "GET",
            Url = HttpService:JSONDecode(Request({
                Method = "GET",
                Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. LocalPlayer.UserId .. "&size=48x48&format=Png&isCircular=true"
        }).Body)["data"][1]["imageUrl"]}).Body),
        Emojis = {
            troll = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/7012-transparent-troll.png"
            }).Body),
            dogefucku = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/7966-dogefucku.png"
            }).Body),
            killme = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/9715-killme.png"
            }).Body),
            skull = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/5965-skull-irl.png"
            }).Body),
            f = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/5497-press-f.png"
            }).Body),
            walter = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/4086-mrwhite.png"
            }).Body),
            sus = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/8322-the-rock-reaction.png"
            }).Body),
            sadge = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/4680-crying-kitten.png"
            }).Body),
            blehh = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/3278-blehh-cat.png"
            }).Body),
            watermelon = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/4049-watermelonman.png"
            }).Body),
            shrug = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/5036-shrug.png"
            }).Body),
            nou = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/9596-no-you.png"
            }).Body),
            sunglasses = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/4866-sunglasses.png"
            }).Body),
            kekw = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/8151-kekw.png"
            }).Body),
            ["4k"] = encodeb64(Request({
                Method = "GET",
                Url = "https://cdn3.emoji.gg/emojis/9606-4k-ultra-hd.png"
            }).Body)
        },
    }
}))

-- File Shit

makefolder("BallsChat")
makefolder("BallsChat/Emojis")
makefolder("BallsChat/Cache")
makefolder("BallsChat/Embeds")

-- EA its in the game

local Clients = {}

local Util = {
    Json = function(data)
        return type(data) == "string" and HttpService:JSONDecode(data) or HttpService:JSONEncode(data)
    end,
    WriteCache = function(filename, data)
        writefile("BallsChat/Cache/" .. filename, data)
    end,
    AppendCache = function(filename, data)
        appendfile("BallsChat/Cache/" .. filename, data)
    end,
    UrlImg = function(url)
        local status, img = pcall(function()
            local request = Request({
                Url = url,
                Method = "GET"
            }).Body
            
            local img = Image.new(request)
            
            if img then
                return request
            end
            
            local thumbnail = request:match("<link href=\"([%a%d%p]+)\" rel=\"image_src\"") or request:match("<meta content=\"[%a%d%p]+\" property=\"og:image\"") or request:match("<meta content=\"([%a%d%p]+)\" name=\"twitter:image\"")
            
            return Request({
                Url = thumbnail,
                Method = "GET"
            }).Body
        end)
        
        return status and img or status
    end
}

Config.Chat.JobId = game.JobId
Config.Chat.PlaceId = game.PlaceId


Util.Client = function(url, key)
   local client = {
        Client = WebSocket.connect(url),
        Key = key
   }
   
   client.OnMessage = client.Client.OnMessage
   client.OnClose = client.Client.OnClose
   
   function client:ClientSend(data)
      return client.Client:Send("\0" .. GCMEncrypt(Util.Json(data), client.Key, client.Key))
   end
   
   function client:ServerSend(data)
      return client.Client:Send("\1" .. Util.Json(data))
   end
   
   function client:SendImage(subid, name, data)
     assert(#name < 255, "name is exceeds 255 limit.")
     return client.Client:Send("\2" .. GCMEncrypt((subid == "emoji" and "e") .. string.char(#name) .. name .. encodeb64(data), client.Key, client.Key))
   end
   
   Interact.SendFunction =  function(data)
       return client.Client:Send("\3" .. GCMEncrypt(Util.Json(data), client.Key, client.Key))
   end
   
   function client:RawDecrpyt(data)
    return GCMDecrypt(data, client.Key, client.Key)
   end
   
   function client:Decrypt(data)
      return Util.Json(GCMDecrypt(data, client.Key, client.Key))
   end

   function client:Close()
      return client.Client:Close()
   end
   
   local copy = table.clone(Config.Chat)
   copy.Emojis = {}
   
   client:ClientSend({profile = copy})
   client:ServerSend({profile = copy})
   
   return client
end

Util.saveConfig = function()
    if not isfolder("BallsChat") then
     makefolder("BallsChat")
     makefolder("BallsChat/Emojis")
     makefolder("BallsChat/Cache")
     makefolder("BallsChat/Embeds")
    end
    writefile("BallsChat/config.json", Util.Json(Config))
end
  
-- Initialise files
Util.saveConfig()

local requestStack = {}
-- Create client object
local client = Util.Client(Config.WebSocket.Url, Config.WebSocket.Key)

function CreateEmbed(data)
    
    for i, interact in next, data.interactions do
        interact.id = math.random(1, 65535 * 255)
        interact.data.callback = type(interact.data.callback) == "string" and loadstring("return " ..interact.data.callback)() or interact.data.callback
        InteractCallbacks[tostring(interact.id)] = interact.data.callback
        interact.data.color = interact.data.color and (type(data) == "table" and interact.data.color or {math.floor(interact.data.color.R * 255), math.floor(interact.data.color.G * 255), math.floor(interact.data.color.B * 255)}) or nil
        interact.data.callback = nil
    end
    
    data.color = data.color and (type(data) == "table" and data.color or {math.floor(data.color.R * 255), math.floor(data.color.G * 255), math.floor(data.color.B * 255)}) or nil
    client:ClientSend(data)
end

function Request(data)
    client:ServerSend(data)
    repeat task.wait() until requestStack[#requestStack] and requestStack[#requestStack].data.Url == data.Url
    return {Body = decodeb64(requestStack[#requestStack].response)}
end

Extra.Request = Request

function NormalizeRichText(str)
    local output = str
    
    while true do
        if not output:match("</") then break end
        local t = output:match("<[%a%s%d%p]+>([%a%s%d%p]+)</[%a%s%d%p]+>")
        -- print(t)
        output = output:gsub("<[%a%s%d%p]+>[%a%s%d%p]+</[%a%s%d%p]+>", t)
    end
    
    return output
end

function makeRichChat(msg)
    
    unrich = NormalizeRichText(msg):gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&quot;", "\""):gsub("&apos;", "'"):gsub("&amp;", "&")
    
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = unrich,
		Font = Enum.Font.SourceSansBold,
        Color = Color3.fromRGB(255, 255, 255),
        FontSize = Enum.FontSize.Size18
	})
	
	local textlabel
	
	repeat
	    for i,v in next, MessageLogDisplay.Scroller:GetChildren() do
	       if v:FindFirstChild("TextLabel") and v.TextLabel.Text == unrich then
	           textlabel = v.TextLabel
	           break
	       end
	    end
	until textlabel
	
	textlabel.RichText = true
	textlabel.Text = msg
	
	return textlabel
end

function splitlabel(label, speaker)
    local text = label.Text
    
    for i = 1, #text do
        local Size = TextService:GetTextSize(text:sub(1, i), label.TextSize, label.Font, label.AbsoluteSize)
        if label.AbsolutePosition.X + Size.X > label.Parent.AbsolutePosition.X + label.Parent.AbsoluteSize.X then
            if text:sub(i, #text) == text then
                return label, nil
            end
            
            label.Text = text:sub(1, i - 1)
            local TextBound = label.TextBounds
            label.Size = UDim2.new(0, TextBound.X, 0, TextBound.Y)
            -- print(text:sub(i, #text))
            
            local word = text:sub(i, #text)
            
            local carry = Instance.new("TextLabel", label.Parent)
            carry.RichText = true
            carry.TextColor3 = Color3.fromRGB(255, 255, 255)
			carry.TextStrokeTransparency = 0.75
            
            if word:sub(1, 1) == "@" then
                local data = getData(word:sub(2, #word))
                local everyone = (word:sub(2, #word) == "everyone") or (word:sub(2, #word) == "here" and speaker.JobId == game.JobId and speaker.PlaceId == game.PlaceId);
                
                if (word:sub(2, #word) == Config.Chat.Name) or everyone then
                    carry.Parent.BackgroundColor3 = Color3.fromRGB(Config.Chat.Color[1], Config.Chat.Color[2], Config.Chat.Color[3])
                    carry.Parent.Transparency = 0.5
                    Sound:Play()
                end
                if data then
                    carry.TextColor3 = Color3.fromRGB(data.Color[1], data.Color[2], data.Color[3])
                elseif everyone then
                    carry.TextColor3 = Color3.fromRGB(Config.Chat.Color[1], Config.Chat.Color[2], Config.Chat.Color[3])
                end
            end
         -- local Padding = Instance.new("UIPadding", TextLabel)
            carry.BackgroundTransparency = 1
        
            carry.FontFace = label.FontFace
            carry.Size = UDim2.new(0, 50, 0, 18)
        
            carry.TextSize = label.TextSize
        -- TextLabel.TextWrapped = true
            carry.Text = word
        
            local TextBound = carry.TextBounds
            carry.Size = UDim2.new(0, TextBound.X, 0, TextBound.Y)
            
            return label, carry
        end
    end
end



function makeinvite(placeid, jobid, title)
    if not title then
        title = Config.Chat.Name .. "'s Invite"
    end

    if not jobid then
        local found_server
        local cursor = ""
        
        repeat
            local info = Util.Json(Request({
                Url = ("https://games.roblox.com/v1/games/%d/servers/Public?cursor=%s&sortOrder=Desc&excludeFullGames=false"):format(placeid, cursor),
                Method = "GET"
            }).Body)
            
            local least = math.huge
            local possible_server
            
            for i,v in next, info.data do
                if v.maxPlayers - v.playing > 0 and least > v.maxPlayers - v.playing and v.maxPlayers - v.playing > v.maxPlayers * 0.25 then
                    possible_server = v
                end
            end
            
            found_server = possible_server
            if found_server then break end
            cursor = info.nextPageCursor
            task.wait(0.5)
        until found_server
        jobid = found_server.id
    end
    
    local ImageFrame = Instance.new("Frame")
    local TextButton = Instance.new("TextButton")
    local TextLabel = Instance.new("TextLabel")
    local ImageLabel = Instance.new("ImageLabel")
    
    Instance.new("UICorner", ImageFrame).CornerRadius = UDim.new(0, 4)
    Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 4)
    Instance.new("UICorner", ImageLabel).CornerRadius = UDim.new(0, 2)
     
    ImageFrame.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
    ImageFrame.Size = UDim2.new(0, 240, 0, 61)
    -- ImageFrame.Position = UDim2.new(0, 8, 0, 0)
    
    TextButton.Parent = ImageFrame
    TextButton.BackgroundColor3 = Color3.new(0, 0.588235, 0)
    TextButton.Position = UDim2.new(0.713317752, 0, 0.212863535, 0)
    TextButton.Size = UDim2.new(0, 61, 0, 34)
    TextButton.Font = Enum.Font.SourceSansBold
    TextButton.Text = "Join"
    TextButton.TextColor3 = Color3.new(1, 1, 1)
    TextButton.TextSize = 18
    
    TextButton.MouseButton1Down:Connect(function()
        LocalPlayer:Kick("Joining Server..")
        task.wait(5)
        game:GetService("TeleportService"):TeleportToPlaceInstance(placeid, jobid)
    end)
    
    TextLabel.Parent = ImageFrame
    TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0.262387395, 0, 0.206048682, 0)
    TextLabel.Size = UDim2.new(0, 99, 0, 34)
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.Text = title
    TextLabel.TextColor3 = Color3.new(1, 1, 1)
    TextLabel.TextSize = 18
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    ImageLabel.Parent = ImageFrame
    ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
    ImageLabel.Size = UDim2.new(0, 55, 0, 61)

    local filname = "invite" .. math.random(1, 1000) .. ".jpg"

    Util.WriteCache(filname, Request({
                  Url = Util.Json(Request({Method = "GET", Url = "https://thumbnails.roblox.com/v1/places/gameicons?placeIds=" .. placeid .. "&size=50x50&format=Png&isCircular=false"}).Body).data[1].imageUrl,
                  Method = "GET"
              }).Body)
          
    ImageLabel.Image = GetAsset("BallsChat/Cache/"..filname)
    
    task.spawn(function()
        task.wait(2)
        delfile("BallsChat/Cache/"..filname)
    end)
    
    return ImageFrame, jobid
end

function uiline(label, name_color, words, currentline, maxlines, carry)
    local Frame = Instance.new("Frame", label)
    if carry then
        carry.Parent = Frame
    end
    
    local UIListLayout = Instance.new("UIListLayout", Frame)

    Instance.new("UICorner", Frame)

    UIListLayout.FillDirection = 0
    UIListLayout.Padding = UDim.new(0, 4)

    Frame.Size = UDim2.new(0, Frame.Parent.AbsoluteSize.X, 0, 18)
    Frame.Position = UDim2.new(0, 8, 0, 0)
    -- Frame.CanvasSize = label.Size
    Frame.Transparency = 1
    Frame.ZIndex = -1
    
    local Line = 0 
    local _words = table.clone(words)
    local name
    local speaker
    local add = 0 
    for i, word in next, words do
        local TextLabel = Instance.new("TextLabel", Frame)
        TextLabel.BackgroundTransparency = 1
        TextLabel.RichText = true
        if i == 1 and not carry then
            TextLabel.TextColor3 = Color3.fromRGB(name_color[1], name_color[2], name_color[3])
            name = word:match("^%[([%a%d%p%s]+)%]:")
            speaker = getData(name)
        else
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            if word:sub(1, 7) == "#invite" and Config.Chat.Name == name then
                client:ClientSend({
                    placeid = word:split("/")[2] or game.PlaceId,
                    jobid = word:split("/")[2] and false or game.JobId
                })
            end
            if word:sub(1, 4) == "/emb" and Config.Chat.Name == name then
               local path = word:split(";")[2]
               local data = {}
               if path:match("^https://") or path:match("^http://") then
                  data = Request({
                      Url = path,
                      Method = "GET"
                  }).Body
               else
                   data = readfile("BallsChat/Embeds/".. path)
               end
               print(data)
               CreateEmbed(Util.Json(data))
            end
            if word:sub(1, 1) == "@" then
                local data = getData(word:sub(2, #word))
                local everyone = (word:sub(2, #word) == "everyone") or (word:sub(2, #word) == "here" and speaker.JobId == game.JobId and speaker.PlaceId == game.PlaceId);
                
                if (word:sub(2, #word) == Config.Chat.Name) or everyone then
                    Frame.BackgroundColor3 = Color3.fromRGB(Config.Chat.Color[1], Config.Chat.Color[2], Config.Chat.Color[3])
                    Frame.Transparency = 0.5
                    Sound:Play()
                end
                if data then
                    TextLabel.TextColor3 = Color3.fromRGB(data.Color[1], data.Color[2], data.Color[3])
                elseif everyone then
                    TextLabel.TextColor3 = Color3.fromRGB(Config.Chat.Color[1], Config.Chat.Color[2], Config.Chat.Color[3])
                end
            end
        end
        -- local Padding = Instance.new("UIPadding", TextLabel)
        
        TextLabel.FontFace = label.FontFace
        TextLabel.Size = UDim2.new(0, 50, 0, 18)
        
		TextLabel.TextStrokeTransparency = 0.75
		
        TextLabel.TextSize = label.TextSize
        -- TextLabel.TextWrapped = true
        TextLabel.Text = word
        
        local TextBound = TextLabel.TextBounds
        TextLabel.Size = UDim2.new(0, TextBound.X, 0, TextBound.Y)
        
        if word:match(":[%a%d%p]+:") then
            local emoji = word:match(":([%a%d%p]+):")
            -- print(Config.Chat.Emojis[emoji])
            if Config.Chat.Emojis[emoji] then
                writefile(("BallsChat/Emojis/%s.jpg"):format(emoji), decodeb64(Config.Chat.Emojis[emoji]))
                local ImageLabel = Instance.new("ImageLabel", TextLabel)
                pcall(function()
                    local Img = Image.new(decodeb64(Config.Chat.Emojis[emoji]))
                    ImageLabel.BackgroundTransparency = 1
                    ImageLabel.BorderSizePixel = 0
                    ImageLabel.Size = UDim2.new(0, Img.WidthOffset * 18, 0, 18)
                    ImageLabel.Parent = TextLabel
                    ImageLabel.Image = GetAsset(("BallsChat/Emojis/%s.jpg"):format(emoji))
                    TextLabel.Size = ImageLabel.Size
                    TextLabel.Text = " "
                end)
            end
        end
        
        _words[i] = nil
        if TextLabel.AbsoluteSize.X + TextLabel.AbsolutePosition.X > Frame.AbsolutePosition.X + Frame.AbsoluteSize.X then
            _, carry = splitlabel(TextLabel, speaker)
            if not carry and _ then
                carry = _
            end
            currentline += 1
            return uiline(label, name_color, _words, currentline, maxlines, carry)
        end
    end
    
    label.Parent.Size = UDim2.new(1, 0, 0, (currentline * 18) + add) -- Resize parent to fit chat so there isn't an extra line.
    
    label.Text = ""
    
    UIListLayout:ApplyLayout()
end

function breakApart(label, name_color)
    text = NormalizeRichText(label.Text)
    local ParentFrame = label.Parent
    local Lines = ParentFrame.AbsoluteSize.Y / 18
    local CurrentLine = 1
    local UILayout = Instance.new("UIListLayout", label)
    local words = text:split(" ")
    uiline(label, name_color, words, CurrentLine, Lines)
    -- label:Destroy()
end

function sendImage(data)
    local NameText = "<font color=\"rgb(" .. data.color[1] .. ", " .. data.color[2] .. ", " .. data.color[3] .. ")\">[" .. data.name .. "]:</font> "
    local Size = MessageLogDisplay.AbsoluteSize
    
    data.image = Util.UrlImg(data.image) or data.image
    pcall(function()
        local Img = Image.new(data.image)

        if not Img then
            return false
        end

        local Height, Width = Img.Height, Img.Width
        
        if Size.Y - 18 <= Height then
            Height = Size.Y - 18
            Width = Img.WidthOffset * Height
        end
        
        -- local LineText = ""
        
        -- for i = 1, (Height / 18) + 1 do
            -- LineText = LineText .. "\n_" -- Adding the underscore prevents crashing. 100% something to do with one of my functions or richtext loves special characters.
        -- end
        
        local Label = makeRichChat(NameText .. data.content)
        -- Label.Text = NameText .. data.content 
        breakApart(Label, data.color)
        
        Label.Parent.Size = Label.Parent.Size + UDim2.new(0, 0, 0, Height)
        
        local ImageLabel = Instance.new("ImageLabel", Label)
        local Corner = Instance.new("UICorner", ImageLabel)
        local TextBound = Label.TextBounds
        
        local FileName = "image" .. math.random(1, 255 * 255) .. ".png"
        
        Util.WriteCache(FileName, data.image)
        
        ImageLabel.Image = GetAsset("BallsChat/Cache/" .. FileName)
        ImageLabel.BackgroundTransparency = 1
        ImageLabel.Position = UDim2.new(0, 4, 0, TextBound.Y)
        ImageLabel.Size = UDim2.new(0, Width, 0, Height)

        task.spawn(function()
            task.wait(2)
            delfile("BallsChat/Cache/" .. FileName)
        end)
    end)
    
    return true

end

function customChat(data)
    local msg = "<font color=\"rgb(" .. tostring(math.floor(data.name_color.R * 255)) .. ", " .. tostring(math.floor(data.name_color.G * 255)) .. ", " .. tostring(math.floor(data.name_color.B * 255)) .. ")\">[" .. data.name .. "]:</font> " .. data.content:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("'", "&apos;")
    if msg:match("%s?https://") or msg:match("%s?http://") then
        if sendImage({
                image = msg:match("(https://[%d%a%p]+)%s?") or msg:match("(http://[%d%a%p]+)%s?"),
                color = {math.floor(data.name_color.R * 255), math.floor(data.name_color.G * 255), math.floor(data.name_color.B * 255)},
                content = data.content:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("'", "&apos;"),
                name = data.name
        }) then
            return
        end
    end
    local label = makeRichChat(msg)
    breakApart(label, {math.floor(data.name_color.R * 255), math.floor(data.name_color.G * 255), math.floor(data.name_color.B * 255)})
end

--[[
  Send Structure
  {
      "packets": [],
  }
]]

-- Recieve Structure
--[[
  {
      "from": client's address or "server",
      "packets": [] -- list of packets
  }
]]

--[[
  Encrypted client packet
  {
      "data": ""
  }
]]

--[[
  Join packet
  {
      "profile" : {
          "name": "Zysex",
          "id": 0,
          "description": "lua man",
          "image": base64_profile_image,
          "emojis": [ base64_images ],
      }
  }
]]

--[[
  Chat packet
  {
      "name": {
          "content": "Zysex",
          "color": [0, 255, 0]
      },
      "message": {
          "content": "I am the lua man.",
      }
  }
]]

--[[
  Invite packet
  {
    "placeId": placeid,
    "jobId": jobid,
    "content": {
        "title": "Zysex's basement",
        "body": "You'll never leave.",
        "thumbnail": base64_image -- defaults to place thumbnail
    }
  }
]]

local User = function(data)

    local user = {
            serverEmojis = {},
            requests = {},
            client = client
        }
    
    function user:Request(data)

        local _data =  {
            request = data,
            key = math.random(1, 32 ^ 256)
        }
        
        user.requests[_data.key] = _data
        
        client:ClientSend(_data)
    end

    function user:JoinCode(code)
        client.Key = code
        client:ClientSend({profile = Config.Chat})
        -- client:ServerSend({profile = Config.Chat})
    end

    function user:CreateInvite(content)
        client:ClientSend({
            placeId = game.PlaceId,
            jobId = game.JobId,
            content = content
        })
    end

    function user:SendMessage(message)
        
        if message:match("^%s") then
            message = message:sub(#message:match("^([%s]+)"), #message)
        end
        
        if message:match("%s$") then
            message = message:sub(1, #message - #message:match("([%s]+)$"))
        end
        
        if #message == 0 then
            message = "\1"
        end
        
        client:ClientSend({
            name = {
                content = Config.Chat.Name,
                color = Config.Chat.Color
            },
            message = {
                content = message,
            }
        })
    end

    function user:SaveProfile()
        Util.saveConfig()
    end

    return user
end

local user = User(Config)

local BlockedJobIds = {}

client.OnMessage:Connect(function(data)
  if utf8.codepoint(data, 1, 2) == 0x00 then
      -- Data sent from other clients.
      local data = client:Decrypt(data:sub(2, #data))

      -- Response data
      if data.response then
         local unverified_responses = {}
         
         for key, v in next, users.requests do
             if key == data.key then
                 if v.request == "emoji" then
                    table.insert(unverified_responses, data.response)
                 end
             end
         end
         
         local shared_rate = {}
         
         for i, response in next, unverified_responses do
            if shared_rate[response] then
                shared_rate[response] += (#unverified_responses * 0.01)
            end
            shared_rate[response] = (#unverified_responses * 0.01)
         end
         
         local shared_response = ""
         local old = -1
         
         for response, rate in next, shared_rate do
             if rate > old then
                shared_response = response
                old = rate
             end
         end
         
         print("Most shared response", shared_response, old)
         
      end
      
      -- Request Data
      if data.request then
         if data.request == "emoji" then
             client:ClientSend({
                      response = user.serverEmojis,
                      key = data.key
             })
         end
      end

      -- Invite Data
      if data.placeid and data.jobid then
          local frame, jobid, placeid = makeinvite(data.placeid, data.jobid)
          local label = makeRichChat("e")
          label.Text = ""
          local parent = label
          
          frame.Parent = parent
          parent.Parent.Size = UDim2.new(1, 0, 0, frame.AbsoluteSize.Y)
      end

      -- Chat Data
      if data.message then
          customChat({
              name_color = Color3.fromRGB(data.name.color[1], data.name.color[2], data.name.color[3]),
              content = data.message.content,
              name = data.name.content
          })
      end

      -- Embed message
      if data.interactions and data.extras and data.color then
        local embed = Embed.new({
            color = Color3.fromRGB(data.color[1], data.color[2], data.color[3])
        })
    
        for i, extra in next, data.extras do
           extra.parent = embed.instance.content
           Extra.new(extra)
        end
    
        for i, interact in next, data.interactions do
            interact.parent = embed.instance.content
            Interact.new(interact)
        end
        local label = makeRichChat("e")
        label.Text = ""
        local parent = label
          
        embed:SetParent(label)
        parent.Parent.Size = UDim2.new(1, 0, 0, embed.instance.AbsoluteSize.Y)
        
      end

      -- Pong response
      if data.data and data.pong == Config.Chat.Id and data.data.Id ~= Config.Chat.Id then
        Clients[data.data.Id] = Clients[data.data.Id] or data.data
      end

      -- Join Data
      if data.profile then
        local clone = table.clone(Config.Chat)
        clone.Emojis = nil

        client:ClientSend({
            pong = data.profile.Id,
            data = clone
        })

        if not Clients[data.profile.Id] then
            Clients[data.profile.Id] = Clients[data.profile.Id] or data.profile
            makeRichChat("<font color=\"rgb(".. data.profile.Color[1] ..", ".. data.profile.Color[2] ..", ".. data.profile.Color[3] ..")\">@".. data.profile.Name .. "</font> has joined the server.")
            if data.profile.JoinMessage then
                customChat({
                    name_color = Color3.fromRGB(data.profile.Color[1], data.profile.Color[2], data.profile.Color[3]),
                    content = data.profile.JoinMessage:format(data.profile.Name, data.profile.Id),
                    name = data.profile.Name
                })
            end
        end
      end
  end -- Client shared shit
  if utf8.codepoint(data, 1, 2) == 0x01 then
      -- Server recieved data
      local data = Util.Json(data:sub(utf8.offset(data, 2), #data))
      
      if data.response and data.data then
          requestStack[#requestStack + 1] = data
      end
      
      -- Private message
      if data.message then
          customChat({
              name_color = Color3.fromRGB(data.name.color[1], data.name.color[2], data.name.color[3]),
              content = data.message.content,
              name = data.name.content
          })
      end
      -- Private Invite Data
      if data.jobId and not BlockedJobIds[data.jobId] then
          if data.content.thumbnail then
              Util.WriteCache("invite.jpg", decodeb64(data.content.thumbnail))
          else
              img = Request({
                  Url = Util.Json(Request({Method = "GET", Url = "https://thumbnails.roblox.com/v1/places/gameicons?placeIds=" .. tostring(game.PlaceId) .. "&size=50x50&format=Png&isCircular=false"}).Body).data[1].imageUrl,
                  Method = "GET"
              })
              Util.WriteCache("invite.jpg", img.Body)
          end
          local inviteFunction = Instance.new("BindableFunction")    

          inviteFunction.OnInvoke = function(type)
            if type == "Join" then
                game:GetService("TeleportService"):TeleportToPlaceInstance(data.placeId, data.jobId)
                return
            end
          end
          
          task.spawn(function()
              task.wait(10)
              inviteFunction:Destroy()
          end)
          
          game:GetService("StarterGui"):SetCore("SendNotification", {
              Title = data.content.title,
              Text = data.content.body,
              Icon = GetAsset("BallsChat/Cache/invite.jpg"),
              Callback = inviteFunction,
              Button1 = "Join",
              Button2 = "Block"
          })
      end
  end -- Server only shit
  if utf8.codepoint(data, 1, 2) == 0x02 then
      data = client:RawDecrpyt(data)
      local subid = data:sub(utf8.offset(data, 1), utf8.offset(data, 1))
      if subid == "e" then
        local emoji_name_size = string.byte(data:sub(utf8.offset(data, 2), utf8.offset(data, 3)))
        local emoji_name = data:sub(utf8.offset(data, 3), utf8.offset(data, 2 + emoji_name_size)) -- epic utf8 moment
        local image_data = data:sub(utf8.offset(data, 3 + emoji_name_size), #data)
        Config.Chat.Emojis[emoji_name] = image_data
      end
  end -- Image only shit
  if utf8.codepoint(data, 1, 2) == 0x03 then
      data = client:Decrypt(data:sub(2, #data))
      if InteractCallbacks[tostring(data.id)] then
          InteractCallbacks[tostring(data.id)](data.value)
      end
  end -- Interact only shit
end)

function getData(plr)
    for id, data in next, Clients do
       if data.Name:lower():sub(1, #plr) == plr:lower() then
            return data
        end
    end
end

function getPlayer(plr)
    for id, data in next, Clients do
        if data.Name:lower():sub(1, #plr) == plr:lower() then
            return id
        end
    end
end

LocalPlayer.Chatted:Connect(function(msg)
    
    function runCommand(cmd, func)
        if msg:sub(#Config.Chat.Prefix, #Config.Chat.Prefix + #cmd):lower() == Config.Chat.Prefix .. cmd:lower() then
            local args = msg:split(" ") or {""}
            table.remove(args, 1)
            
            return func(unpack(args))
        end
    end

    runCommand("code", function(key)
        user:JoinCode(key)
    end)
    
    runCommand("name", function(new_name)
        Config.Chat.Name = new_name
    end)
    
    runCommand("share", function(emoji)
        client:SendImage("emoji", emoji, decodeb64(Config.Chat.Emojis[emoji]))
    end)
    
    runCommand("emoji",function(emoji, url)
        if url:match("^file://") then
            Config.Emoji[emoji] = encodeb64(readfile(url:match("^file://([%s%a%d%p]+)")))
            return
        end
        local data = Util.UrlImg(url)
        Config.Emoji[emoji] = encodeb64(data)
    end)
    
    runCommand("save", function()
        Util.saveConfig()
    end)
    
    runCommand("close", function()
        client:Close()
        Util.saveConfig()
    end)
    
    runCommand("pm", function(plr, ...)
        client:ClientSend({
            name = {
                content = Config.Chat.Name,
                color = Config.Chat.Color
            },
            message = {
                content = table.concat({...}, " "),
            },
            reciever = getPlayer(plr)
        })
    end)
    
    runCommand("color", function(r, g, b)
        Config.Chat.Color = {tonumber(r), tonumber(g), tonumber(b)}
    end)
    
    runCommand("invite", function(plr, ...)
        if plr == "all" then
            user:CreateInvite({
                title = Config.Chat.Name .. "'s Invite",
                body = table.concat({...}, " ") or "Join " .. Config.Chat.Name .. "'s server.",
            })
            return
        end
        client:ServerSend({
            jobId = game.JobId,
            placeId = game.PlaceId,
            notification = {
                title = Config.Chat.Name .. "'s Invite",
                body = table.concat({...}, " ") or "Join " .. Config.Chat.Name .. "'s server.",
            },
            reciever = getPlayer(plr)
        })
    end)
    
    runCommand("config",function(option, ...)
        if option == "default" then
           delfile("BallsChat/config.json")
           Config = {
                WebSocket = {
                    Url = "wss://WS-Server.eeeeeevbr.repl.co",
                    Key = "Default"
                },
                Chat = {
                    Name = LocalPlayer.DisplayName,
                    Color = {math.random(100, 255), math.random(100, 255), math.random(100, 255)},
                    Id = LocalPlayer.UserId,
                    Description = "No description.",
                    Prefix = "/",
                    JoinMessage = "Hello!",
                    Image = encodeb64(Request({
                        Method = "GET",
                        Url = HttpService:JSONDecode(Request({
                            Method = "GET",
                            Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. LocalPlayer.UserId .. "&size=48x48&format=Png&isCircular=true"
                    }).Body)["data"][1]["imageUrl"]}).Body),
                    Emojis = {
                        troll = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/7012-transparent-troll.png"
                        }).Body),
                        dogefucku = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/7966-dogefucku.png"
                        }).Body),
                        killme = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/9715-killme.png"
                        }).Body),
                        skull = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/5965-skull-irl.png"
                        }).Body),
                        f = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/5497-press-f.png"
                        }).Body),
                        walter = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/4086-mrwhite.png"
                        }).Body),
                        sus = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/8322-the-rock-reaction.png"
                        }).Body),
                        sadge = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/4680-crying-kitten.png"
                        }).Body),
                        blehh = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/3278-blehh-cat.png"
                        }).Body),
                        watermelon = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/4049-watermelonman.png"
                        }).Body),
                        shrug = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/5036-shrug.png"
                        }).Body),
                        nou = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/9596-no-you.png"
                        }).Body),
                        sunglasses = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/4866-sunglasses.png"
                        }).Body),
                        kekw = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/8151-kekw.png"
                        }).Body),
                        ["4k"] = encodeb64(Request({
                            Method = "GET",
                            Url = "https://cdn3.emoji.gg/emojis/9606-4k-ultra-hd.png"
                        }).Body)
                    },
                }
            }
           Util.saveConfig()
           makeRichChat("Finished reseting config file.")
        end
        if option == "save" then
            Util.saveConfig()
            makeRichChat("Saved config.")
        end
    end)

    runCommand("chat", function()
        CustomChatEnabled = not CustomChatEnabled
    end)
end)



game.OnClose = function()
    client:Close()
    Util.saveConfig()
end

local namecall; namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if self.Name == "SayMessageRequest" and (CustomChatEnabled or args[1]:sub(1, 1) == Config.Chat.Prefix) then
        if args[1]:sub(1, 1) ~= Config.Chat.Prefix then
            user:SendMessage(args[1])
            return
        end
        return
    end
    
    return namecall(self, ...)
end))

local res = syn.request({
    Url = "https://cdn.discordapp.com/attachments/1028846601239797760/1033360402219802624/ping.mp3",
    Method = "GET"
})
Util.WriteCache("ping.mp3", res.Body)
Sound.SoundId = GetAsset("BallsChat/Cache/ping.mp3")
