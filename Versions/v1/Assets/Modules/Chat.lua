local EmojiLib = Import("Emoji")

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Chat = {
	OnChat = {
		Callbacks = {}, 
		Connect = function(self, func)
			table.insert(self.Callbacks, func)
			return {
				Connected = true,
				Idx = #self.Callbacks,
				Disconnect = function(this)
					this.Connected = false
					table.remove(self.Callbacks, this.Idx)
				end,
			}
		end
	},
	Messages = {},
	Players = {},
	WhisperTo = nil,
    ScrollingFrame = nil,
	ChatBar = nil,
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
	CreateReaction = function(self, data)
		print(data)
	end,
	ContextMenuOptions = {
		Edit = function(Data)
			local Message = Data.Message
			ROCHAT_Config.Client:Send({
				Type = "UI",
				SubType = "Edit",
				Id = Data.MessageId,
				Message = Message
			})
		end,
		React = function(Data)
			local ScreenGui = Instance.new("ScreenGui")
			local Frame = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local TextBox = Instance.new("TextBox")
			local UICorner_2 = Instance.new("UICorner")
			local ScrollingFrame = Instance.new("ScrollingFrame")
			local UIGridLayout = Instance.new("UIGridLayout")

			ScreenGui.Parent = CoreGui
			
			local Position = UserInputService:GetMouseLocation()

			Frame.Parent = ScreenGui
			Frame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
			Frame.Position = UDim2.new(0, Position.X - 8, 0, Position.Y - 38)
			Frame.Size = UDim2.new(0, 190, 0, 149)

			UICorner.CornerRadius = UDim.new(0, 6)
			UICorner.Parent = Frame

			TextBox.Parent = Frame
			TextBox.BackgroundColor3 = Color3.fromRGB(122, 122, 122)
			TextBox.Position = UDim2.new(0.042105265, 0, 0.832214773, 0)
			TextBox.Size = UDim2.new(0, 174, 0, 18)
			TextBox.ClearTextOnFocus = false
			TextBox.Font = Enum.Font.SourceSansBold
			TextBox.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
			TextBox.PlaceholderText = "Filter emojis"
			TextBox.Text = ""
			TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
			TextBox.TextSize = 14.000

			UICorner_2.Parent = TextBox

			ScrollingFrame.Parent = Frame
			ScrollingFrame.Active = true
			ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ScrollingFrame.BackgroundTransparency = 1.000
			ScrollingFrame.BorderColor3 = Color3.fromRGB(172, 172, 172)
			ScrollingFrame.Position = UDim2.new(0.042105265, 0, 0.0402684547, 0)
			ScrollingFrame.Size = UDim2.new(0, 174, 0, 119)
			ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 119)

			UIGridLayout.Parent = ScrollingFrame
			UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIGridLayout.CellPadding = UDim2.new(0, 3, 0, 5)
			UIGridLayout.CellSize = UDim2.new(0, 32, 0, 32)

			local Count = 0
			for Name in next, ROCHAT_Config.Profile.Emojis do
				local Label = EmojiLib.MakeEmoji(ScrollingFrame, Name)
				Label.InputBegan:Connect(function(Input)
					if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
					ROCHAT_Config.Client:Send({
						Type = "UI",
						SubType = "React",
						Reaction = Name,
						Id = Data.MessageId
					})
					ScreenGui:Destroy()
				end)
				if Count >= 15 then break end
			end

			Frame.MouseLeave:Connect(function()
				ScreenGui:Destroy()
			end)
		end,
		Destroy = function(Data)
			ROCHAT_Config.Client:Send({
				Type = "UI",
				SubType = "Destroy",
				Id = Data.MessageId
			})
		end,
		Copy = function(Data)
			setclipboard(Data.Message)
		end,
	},
	CreateContextMenu = function(self, Data, x, y)
		local ScreenGui = Instance.new("ScreenGui")
		local Frame = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local ScrollingFrame = Instance.new("ScrollingFrame")
		local UIListLayout = Instance.new("UIListLayout")

		ScreenGui.Parent = CoreGui
		ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

		Frame.Parent = ScreenGui
		Frame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Frame.Position = UDim2.new(0, x, 0, y)
		Frame.Size = UDim2.new(0, 154, 0, 243)

		UICorner.CornerRadius = UDim.new(0, 6)
		UICorner.Parent = Frame

		ScrollingFrame.Parent = Frame
		ScrollingFrame.Active = true
		ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ScrollingFrame.BackgroundTransparency = 1.000
		ScrollingFrame.Size = UDim2.new(0, 154, 0, 243)

		Frame.Size = UDim2.new(0, 154, 0, UIListLayout.AbsoluteContentSize.Y)
		ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, UIListLayout.AbsoluteContentSize.Y)

		UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Frame.Size = UDim2.new(0, 154, 0, UIListLayout.AbsoluteContentSize.Y)
			ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, UIListLayout.AbsoluteContentSize.Y)
		end)

		UIListLayout.Parent = ScrollingFrame
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		for Option, Callback in next, self.ContextMenuOptions do
			local TextButton = Instance.new("TextButton")

			TextButton.Parent = ScrollingFrame
			TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextButton.BackgroundTransparency = 1.000
			TextButton.BorderSizePixel = 0
			TextButton.Size = UDim2.new(0, 154, 0, 30)
			TextButton.Font = Enum.Font.SourceSansBold
			TextButton.TextColor3 = Color3.fromRGB(222, 222, 222)
			TextButton.TextSize = 16
			TextButton.TextStrokeColor3 = Color3.fromRGB(231, 231, 231)
			TextButton.TextStrokeTransparency = 0.790
			TextButton.TextWrapped = true
			TextButton.Text = Option

			TextButton.MouseButton1Down:Connect(function()
				Callback(Data)
				ScreenGui:Destroy()
			end)
		end

		Frame.MouseLeave:Connect(function()
			ScreenGui:Destroy()
		end)
	end,
    CreateMessage = function(self, data)
        local ScrollingFrame = self.ScrollingFrame
        local Frame = Instance.new("Frame", ScrollingFrame)
        Frame.LayoutOrder = data.Order or self:GetOrder()
        Frame.BackgroundTransparency = 1
        Frame.Size = UDim2.new(1, 0, 0, 22)
		Frame.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
			local Position = UserInputService:GetMouseLocation()
			-- Create context menu
			self:CreateContextMenu(data, Position.X - 8, Position.Y - 38)
		end)

		if data.MessageId then 
			self.Messages[data.MessageId] = {
				From = data.Id,
				Message = data.Message,
				Id = data.MessageId,
				Order = Frame.LayoutOrder,
				Frame = Frame
			}
		end
        
        local NameTag = Instance.new("TextButton", Frame)
		if data.To then
	        NameTag.Text = ("[Whisper from %s]:"):format(data.Name)
		else
			NameTag.Text = ("[%s]:"):format(data.Name)
		end
        NameTag.Position = UDim2.new(0, 8, 0, 0)
        NameTag.FontFace = Font.fromEnum(Enum.Font.SourceSansBold)
        NameTag.TextSize = 18
        NameTag.BackgroundTransparency = 18
        NameTag.TextColor3 = Color3.fromRGB(unpack(data.Color or data.Colour))
		NameTag.MouseButton1Down:Connect(function()
			self.ChatBar = Players.LocalPlayer.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
			local PlaceholderText = self.ChatBar.Parent.TextLabel
			PlaceholderText.Text = ""

			local MessageMode = self.ChatBar.Parent.MessageMode
			MessageMode.Size = UDim2.new(1, 0, 1, 0)
			MessageMode.TextColor3 = Color3.fromRGB(unpack(data.Color or data.Colour))
			MessageMode.Text = ("[To %s]"):format(data.Name)

			local TextBounds = MessageMode.TextBounds
			MessageMode.Size = UDim2.new(0, math.ceil(TextBounds.X), 1, 0)

			self.ChatBar.Position = UDim2.new(0, math.ceil(TextBounds.X) + 4, 0, 0)
			self.WhisperTo = data.Id

			local Connection

			Connection = MessageMode:GetPropertyChangedSignal("Text"):Connect(function()
				self.WhisperTo = nil
				Connection:Disconnect()
			end)
		end)

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
    		
    		local Emoji = Word:match("^:([%w%p?%w]+):$")
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
    		if WordLabel.AbsolutePosition.X + WordLabel.AbsoluteSize.X + (Emoji and 32 or 0) > MessageContent.AbsoluteSize.X + MessageContent.AbsolutePosition.X - 18 then
    			
    			--> Add another line to the main frame
				local BeforeLine = MessageContent
    			MessageContent = Instance.new("ScrollingFrame", Frame)
    			MessageContent.Position = UDim2.new(UDim.new(0, 8), BeforeLine.Position.Y + UDim.new(0, BeforeLine.AbsoluteSize.Y))
    			
    			--> Create a new line
    			
    			MessageContent.BackgroundTransparency = 1
    			MessageContent.Size = UDim2.new(1, 0, 0, 18)
    			MessageContent.CanvasSize = UDim2.new(0, 0, 0, 18)

				Lines = Lines + 1
    			Frame.Size = UDim2.new(UDim.new(1, 0), MessageContent.Position.Y + UDim.new(0, MessageContent.AbsoluteSize.Y))
    			
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
