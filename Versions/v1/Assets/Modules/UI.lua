--[[
    TODOs:
     Interaction:
       Poll widget
       File browser
       


]]

local Extra = {
    Request = nil,
    Image = nil,
    GetAsset = nil
}

Extra.new = function(data)
    local extra = {
        type = data.type,
        parent = data.parent,
        order = data.order,
    }

    if extra.type == "label" then
        extra.instance = Instance.new("TextLabel", extra.parent)
        Instance.new("UICorner", extra.instance).CornerRadius = UDim.new(0, 3)
        extra.instance.BackgroundTransparency = 1
        extra.instance.Text = data.data.content
        extra.instance.LayoutOrder = data.order
        extra.instance.Size = UDim2.new(0, 178, 0, data.data.fontsize and data.data.fontsize + 2 or 16)
        extra.instance.Font = Enum.Font.SourceSansBold
        extra.instance.TextColor3 = data.data.color or Color3.fromRGB(235, 235, 235)
        extra.instance.TextSize = data.data.fontsize or 14
        extra.instance.TextWrapped = true
        extra.instance.TextXAlignment = Enum.TextXAlignment.Left
        extra.instance.TextYAlignment = Enum.TextYAlignment.Top
    end

    if extra.type == "imagelabel" then
        extra.instance = Instance.new("ImageLabel", extra.parent)
        Instance.new("UICorner", extra.instance).CornerRadius = UDim.new(0, 3)
        extra.instance.LayoutOrder = data.order
        local image_data = data.data.content or Extra.Request({
            Url = data.data.url,
            Method = "GET"
        }).Body
        local image_size = Extra.Image.new(image_data)
        local Width, Height = image_size.Width, image_size.Height
        
        if Width > data.parent.AbsoluteSize.X - 8 then
           Width = data.parent.AbsoluteSize.X - 8
           Height = image_size.HeightOffset * Width
        end

        extra.instance.Size = UDim2.new(0, Width, 0, Height)
        local name = ("%d.png"):format(math.random(1, 9999))
        writefile(name, image_data)
        extra.instance.Image = Extra.GetAsset(name)
        task.spawn(function()
            task.wait(1)
            delfile(name)
        end)
    end
    
    extra.instance.LayoutOrder = extra.order or (#extra.parent:GetChildren() - 1)

    return extra
end

getgenv().Interact = Interact or {
    Interactions = {},
    SendFunction = nil,
    Callbacks = {}
}
--[[
   
   Interact will send websocket data allowing the person who sent the interaction to run functions on the person that sent the embed's client using someone using their input.

   Interact Arguments:
     {
        "type": "button/yesno/textbox",
        "data": {
            Button Example
            "content": "Button Example",
            "color": Color3.fromRGB()
            "callback": function(from)
                print(from)
            end
            
            Yesno Exmaple
            "yes": "Button 1",
            "no": "Button 2",
            "callback": function(from, value)
                print(from, value and "yes" or "no")
            end

            Texbox Example
            "content": "Textbox",
            "callback": function(from, value)
                print(from, value)
            end
        }
     }
]]

Interact.new = function(data)
    local interact = {
        id = data.id or math.random(1, 65535 * 255),
        type = data.type,
        parent = data.parent,
        instance = nil,
        callback = data.callback,
        sendfunc = data.sendfunc,
        order = data.order
    }

    if Interact.Interactions[interact.id] then
        interaction.id = math.random(1, 65535 * 255)
    end

    if interact.type == "button" then
        interact.instance = Instance.new("TextButton", interact.parent)
        Instance.new("UICorner", interact.instance).CornerRadius = UDim.new(0, 3)
        interact.instance.BackgroundColor3 = data.color and Color3.fromRGB(data.color.R, data.color.G, data.color.B) or Color3.fromRGB(27, 163, 0)
        interact.instance.Position = data.position and UDim2.new(unpack(data.position)) or UDim2.new(0, 0, 0, 0)
        interact.instance.Size = data.size and UDim2.new(unpack(data.size)) or UDim2.new(0, 179, 0, 22)
        interact.instance.BorderSizePixel = 0
        interact.instance.Font = Enum.Font.SourceSansBold
        interact.instance.Text = data.text
        interact.instance.TextColor3 = Color3.fromRGB(226, 226, 226)
        interact.instance.TextSize = 18
        interact.instance.TextWrapped = true

        if type(data.callback) == "function" then
            Interact.Callbacks[interact.id] = data.callback
        end

        interact.instance.MouseButton1Down:Connect(function()
            Interact.SendFunction({
                Type = "UI",
                SubType = "Interact",
                InteractType = "Button",
                Id = interact.id
            })
        end)
    end

    if interact.type == "textbox" then
        interact.instance = Instance.new("TextBox", interact.parent)
        Instance.new("UICorner", interact.instance).CornerRadius = UDim.new(0, 3)
        interact.instance.BackgroundColor3 =  data.color and Color3.fromRGB(data.color.R, data.color.G, data.color.B) or Color3.new(0.298039, 0.298039, 0.298039)
        interact.instance.Position = data.position and UDim2.new(unpack(data.position)) or UDim2.new(0, 0, 0, 0)
        interact.instance.Size = data.size and UDim2.new(unpack(data.size)) or UDim2.new(0, 179, 0, 24)
        interact.instance.Font = Enum.Font.SourceSansBold
        interact.instance.PlaceholderText = data.text or ""
        interact.instance.TextColor3 = Color3.fromRGB(226, 226, 226)
        interact.instance.TextSize = data.textsize or 15
        interact.instance.ClearTextOnFocus = false
        interact.instance.FocusLost:Connect(function(enter)
            if not enter then return end
            Interact.SendFunction({
                Type = "UI",
                SubType = "Interact",
                InteractType = "TextBox",
                Value = interact.instance.Text,
                Id = interact.id
            })
        end)
    end

    Interact.SendFunction({
        Type = "UI",
        SubType = "CreateInteraction",
        Id = interact.id
    })
    interact.instance.LayoutOrder = interact.order or (#interact.parent:GetChildren() - 1)
    return interact
end

local Embed = {}

Embed.new = function(data)
    local _embed = {
        color = data.color,
    }
    
    local embed = Instance.new("Frame")
    Instance.new("UICorner", embed).CornerRadius = UDim.new(0, 5)

    local cover = Instance.new("Frame")
    local color = Instance.new("Frame")
    Instance.new("UICorner", color).CornerRadius = UDim.new(0, 5)

    local content = Instance.new("ScrollingFrame")
    content.CanvasSize = UDim2.new(0.95, 0, 0.95, 0)

    local UIListLayout = Instance.new("UIListLayout", content)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    embed.Name = "embed"
    embed.BackgroundColor3 = Color3.new(0.184314, 0.192157, 0.211765)
    embed.BorderSizePixel = 0
    embed.Position = UDim2.new(0, 8, 0, 0)
    embed.Size = UDim2.new(0, 196, 0, 136)

    cover.Name = "cover"
    cover.Parent = embed
    cover.BackgroundColor3 = Color3.new(0.184314, 0.192157, 0.211765)
    cover.BorderSizePixel = 0
    cover.Position = UDim2.new(0, 4, 0, 0)
    cover.Size = UDim2.new(0, 4, 1, 0)
    cover.ZIndex = 2

    color.Name = "color"
    color.Parent = embed
    color.BackgroundColor3 = _embed.color
    color.BorderSizePixel = 0
    color.Size = UDim2.new(0, 6, 1, 0)

    content.Name = "content"
    content.Parent = embed
    content.Active = true
    content.BackgroundColor3 = Color3.new(1, 1, 1)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 6
    content.Position = UDim2.new(0, 8, 0, 4)
    content.Size = UDim2.new(0.95, 0, 1, 0)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)

    function _embed:AddChild(instance)
        instance.Parent = content
        return instance
    end

    function _embed:SetParent(parent)
        embed.Parent = parent
        embed.LayoutOrder = #parent:GetChildren()
    end
        
    function _embed:SetColor(color)
        color.BackgroundColor3 = color
    end

    _embed.instance = embed
    return _embed
end

-- File browser button

return {
    Interact = Interact,
    Embed = Embed,
    Extra = Extra
}
