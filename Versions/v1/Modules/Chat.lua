local EmojiLib = Import("Emoji")

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Chat = {
	Players = {},
    ScrollingFrame = nil,
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
	GetOrder = function(self)
	   local Order = 0
	   for _, Frame in next, self.ScrollingFrame:GetChildren() do
		  if Frame:IsA("Frame") and Frame.LayoutOrder > Order then
			Order = Frame.LayoutOrder
		  end
	   end
	   return Order
	end,
    CreateMessage = function(self, data)
        local ScrollingFrame = self.ScrollingFrame
        local Frame = Instance.new("Frame", ScrollingFrame)
        Frame.LayoutOrder = self:GetOrder()
        Frame.BackgroundTransparency = 1
        Frame.Size = UDim2.new(1, 0, 0, 22)
        
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
    	MessageContent.Size = UDim2.new(0, Frame.AbsoluteSize.X - TextSize.X, 0, 22)
    	MessageContent.CanvasSize = UDim2.new(0, Frame.AbsoluteSize.X - TextSize.X, 0, 22)
    
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
    		
    		--> Set text
    		local RichWord, Word = self.Markdown(Word, Flags)
			
			if RichWord:match("^@") then
    			local Name = RichWord:match("^@([%w%p]+)")
				for i, v in next, self.Players do
					if v.Name == Name then
						local Color = Color3.fromRGB(unpack(v.Color or v.Colour))
						WordLabel.TextColor3 = Color
						Instance.new("UICorner", WordLabel).CornerRadius = UDim.new(0, 3)
						WordLabel.BackgroundTransparency = 0.75
						WordLabel.BackgroundColor3 = Color
					end
				end
    		end

    		WordLabel.Text = RichWord

			WordLabel.TextSize = 18
    		WordLabel.Size = UDim2.new(0, WordLabel.TextBounds.X, 0, WordLabel.TextBounds.Y)

			if Emoji and ROCHAT_Config.Profile.Emojis[Emoji] then
    		    WordLabel:Destroy()
    		    WordLabel = EmojiLib.MakeEmoji(MessageContent, Emoji)
    		end

    		--> Check if word goes outside of the line
    		if WordLabel.AbsolutePosition.X + WordLabel.AbsoluteSize.X + 16 > (MessageContent.AbsoluteSize.X + MessageContent.AbsolutePosition.X) then
    			
    			--> Add another line to the main frame
    			MessageContent = Instance.new("ScrollingFrame", Frame)
    			MessageContent.Position = UDim2.new(0, 8, 0, Lines * 22)
    			
    			Lines = Lines + 1
    			Frame.Size = UDim2.new(1, 0, 0, (Lines * 22))
    			
    			--> Create a new line
    			
    			MessageContent.BackgroundTransparency = 1
    			MessageContent.Size = UDim2.new(1, 0, 0, 22)
    			MessageContent.CanvasSize = UDim2.new(0, 0, 0, 22)
    			
    			UIListLayout = Instance.new("UIListLayout", MessageContent)
    			UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    			UIListLayout.Padding = UDim.new(0, 4)
    			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    			
    			--> Reparent word to new line
    			if WordLabel then
    				WordLabel.Parent = MessageContent
    				WordLabel.LayoutOrder = #MessageContent:GetChildren()
    				-- WordLabel.TextTruncate = Enum.TextTruncate.AtEnd
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

return Chat
