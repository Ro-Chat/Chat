local Import  = function(path) return loadstring(game:HttpGet(("https://raw.githubusercontent.com/Ro-Chat/Chat/main/v1/Modules/%s.lua"):format(path)))() end
local ImageLib   = Import("Image")
local GetAsset = syn and getsynasset or getcustomasset

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Chat = {
    ScrollingFrame = nil,
    Config = {},
    LoadConfig = function(self)
        if not isfolder("RoChat") then
            makefolder("RoChat")
            makefolder("RoChat/Emojis")
        end
        if not isfile("RoChat/Config.json") then
            local Config = {
                Name = Players.LocalPlayer.Name,
                Color = {math.random(50, 255), math.random(50, 255), math.random(50, 255)},
                Emojis = {
                    troll = {
                        Url = "https://discords.com/_next/image?url=https%3A%2F%2Fcdn.discordapp.com%2Femojis%2F702893572369809409.png%3Fv%3D1&w=64&q=75",
                        Type = "Image"
                    },
                    pepe_cringe = {
                        Path = "pepe_cringe.webm",
                        Type = "Video"
                    }
                },
            }
            writefile("RoChat/Config.json", HttpService:JSONEncode(Config))
            self.Config = Config
            return Config
        end
        local Config = HttpService:JSONDecode(readfile("RoChat/Config.json"))
        self.Config = Config
        return Config
    end,
    Markdown = function(message, flags)
    	local left_string = ""
    	local right_string = ""
    	local old = message
    	
    	if flags.Underline then
    		left_string = left_string .. "<u>"
    		right_string = "</u>" .. right_string
    		message = message:gsub("^__", "")
    		message = message:gsub("__$", "")
    	end
    
    	if flags.Strikethrough then
    		left_string = left_string .. "<s>"
    		right_string = "</s>" .. right_string
    		message = message:gsub("^~~", "")
    		message = message:gsub("~~$", "")
    	end
    	
    	if flags.Italic then
    		left_string = left_string .. "<i>"
    		right_string =  "</i>" .. right_string
    		message = message:gsub("^%*%*", "") or message
    		message = message:gsub("%*%*$", "") or message
    	end
    	
    	if flags.Bold then
    		left_string = left_string .. "<b>"
    		right_string = "</b>" .. right_string
    		message = not message:match("^%*%*") and message:gsub("^%*", "") or message
    		message = not message:match("%*%*$") and message:gsub("%*$", "") or message
    	end
    	
    	return left_string .. message .. right_string, old
    end,
    CreateMessage = function(self, data)
        local ScrollingFrame = self.ScrollingFrame
        local Frame = Instance.new("Frame", ScrollingFrame)
        
        Frame.BackgroundTransparency = 1
        Frame.Size = UDim2.new(1, 0, 0, 18)
        
        local NameTag = Instance.new("TextButton", Frame)
        NameTag.Text = ("[%s]:"):format(data.Name)
        NameTag.Position = UDim2.new(0, 8, 0, 0)
        NameTag.FontFace = Font.fromEnum(Enum.Font.SourceSansBold)
        NameTag.TextSize = 18
        NameTag.BackgroundTransparency = 18
        NameTag.TextColor3 = Color3.fromRGB(unpack(data.Color or data.Colour))
        
        local TextSize = NameTag.TextBounds
        NameTag.Size = UDim2.new(0, TextSize.X, 0, TextSize.Y)
        
        local MessageContent = Instance.new("ScrollingFrame", Frame)
    	MessageContent.BackgroundTransparency = 1
    	MessageContent.Position = UDim2.new(0, 12 + TextSize.x, 0, 0)
    	MessageContent.Size = UDim2.new(0, Frame.AbsoluteSize.X - TextSize.X, 0, 18)
    	MessageContent.CanvasSize = UDim2.new(0, Frame.AbsoluteSize.X - TextSize.X, 0, 18)
    
    	local UIListLayout = Instance.new("UIListLayout", MessageContent)
    	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    	UIListLayout.Padding = UDim.new(0, 4)
    	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local Flags = {
            Italic = false,
            Bold = false,
            Underline = false,
            Strikethrough = false
        }
        
        local Lines = 1
    	for Word in string.gmatch(data.Message, "%s?([%w%p?%w?]+)%s?") do
    		--> Enable Flags
    		if Word:match("^~~") or Word:match("^__~~") or Word:match("^__~~%*") then
    			Flags.Strikethrough = true
    		end
    
    		if Word:match("^%*%*") or Word:match("^__%*%*") or Word:match("^~~%*%*") or Word:match("^__~~%*%*") or Word:match("^__~~%*%*%*") then
    			Flags.Italic = true
    		end
    		
    		if Word:match("^%*") and not Word:match("^%*%*") or (not Word:match("^__%*%*") or Word:match("^__%*%*%*")) and Word:match("^__%*") or Word:match("^%*%*%*") or Word:match("^~~%*") or (Word:match("^__~~%*") and not Word:match("^__~~%*%*")) or Word:match("^__~~%*%*%*") then
    			Flags.Bold = true
    		end
    		
    		if Word:match("^__") then
    			Flags.Underline = true
    		end
    		
    		local Emoji = Word:match(":([%w%p?%w]+):")
    		local WordLabel = Instance.new("TextLabel", MessageContent)
    		
    		WordLabel.RichText = true
    		WordLabel.FontFace = Font.fromEnum(Enum.Font.SourceSans)
    		WordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    		WordLabel.TextXAlignment = Enum.TextXAlignment.Left
    		WordLabel.LayoutOrder = #MessageContent:GetChildren()
    		WordLabel.BackgroundTransparency = 1
    		
    		if Word:match("^@") then
    			local Name = Word:match("^@([%w%p]+)")
    			if Name == data.Name then
    				local Color = Color3.fromRGB(unpack(data.Color))
    				WordLabel.TextColor3 = Color
    				Instance.new("UICorner", WordLabel).CornerRadius = UDim.new(0, 3)
    				WordLabel.BackgroundTransparency = 0.75
    				WordLabel.BackgroundColor3 = Color
    			end
    		end
    		
    		--> Set text
    		local RichWord, Word = self.Markdown(Word, Flags)
    		WordLabel.Text = RichWord
    		
    		--> Check if word goes outside of the line
    		if WordLabel.AbsolutePosition.X + WordLabel.AbsoluteSize.X + 36 > (MessageContent.AbsoluteSize.X + MessageContent.AbsolutePosition.X) then
    			
    			--> Add another line to the main frame
    			MessageContent = Instance.new("ScrollingFrame", Frame)
    			MessageContent.Position = UDim2.new(0, 8, 0, Lines * 18)
    			
    			Lines = Lines + 1
    			Frame.Size = UDim2.new(1, 0, 0, (Lines * 18))
    			
    			--> Create a new line
    			
    			MessageContent.BackgroundTransparency = 1
    			MessageContent.Size = UDim2.new(1, 0, 0, 18)
    			MessageContent.CanvasSize = UDim2.new(0, 0, 0, 18)
    			
    			UIListLayout = Instance.new("UIListLayout", MessageContent)
    			UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    			UIListLayout.Padding = UDim.new(0, 4)
    			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    			
    			--> Reparent word to new line
    			if WordLabel then
    				WordLabel.Parent = MessageContent
    				WordLabel.LayoutOrder = #MessageContent:GetChildren()
    				WordLabel.TextTruncate = Enum.TextTruncate.AtEnd
    			end
    		end
    		WordLabel.TextSize = 18
    		WordLabel.Size = UDim2.new(0, WordLabel.TextBounds.X, 0, WordLabel.TextBounds.Y)
    		
    		if Emoji and self.Config.Emojis[Emoji] then
    		    WordLabel:Destroy()
    		    local EM = self.Config.Emojis[Emoji]
    		    if EM.type == "Image" then
        		    local ImgBuffer = EM.Url and game:HttpGet(EM.Url) or EM.Path and readfile(EM.Path)
        		    local Img = ImageLib.new(ImgBuffer)
        			local Image = Instance.new("ImageLabel", MessageContent)
        			Image.LayoutOrder = #MessageContent:GetChildren()
        			
        			Image.BackgroundTransparency = 1
        			Image.Size = UDim2.new(0, Img.WidthOffset * 18, 0, 18)
        			writefile(Emoji .. ".png", ImgBuffer)
        			Image.Image = GetAsset(Emoji .. ".png")
        			task.spawn(function()
        			    task.wait(0.25)
        			    delfile(Emoji .. ".png")
        			end)
    		    end
			    if EM.type == "Video" then
			        
			    end
    		end
    		
    		if Word:match("__$") then
    			Flags.Underline = false
    		end
    		
    		if Word:match("~~$") or Word:match("~~__$") or Word:match("%*~~__$") then
    			Flags.Strikethrough = false
    		end
    
    		if Word:match("%*$") and not Word:match("%*%*$") or Word:match("%*__$") or Word:match("%*%*%*$") or Word:match("%*~~$") or (Word:match("%*~~__$") and not Word:match("%*%*~~__$")) or Word:match("%*%*%*~~__$") then
    			Flags.Bold = false
    		end
    
    		if Word:match("%*%*$") or Word:match("%*%*__$") or Word:match("%*%*~~$") or Word:match("%*%*~~__$") or Word:match("%*%*%*~~__$") then
    			Flags.Italic = false
    		end
    	end
    end
}

Chat.ScrollingFrame = Players.LocalPlayer.PlayerGui.Chat.Frame.ChatChannelParentFrame.Frame_MessageLogDisplay.Scroller

local Config = Chat:LoadConfig()

Chat:CreateMessage({
    Message = "test *wow* :troll: Emojiojsw dwmdwa jwodojsw dwmdwa jwodojsw dwmdwa jwodojsw dwmdwa jwodojsw dwmdwa jwodojsw dwmdwa jwod",
    Name = "Test",
    Color = {
        100,
        100,
        200
    }
})
