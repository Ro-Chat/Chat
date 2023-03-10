-- local XML = Import("XML")
local UI  = Import("UI")

local Extra    = UI.Extra
local EmbedUI  = UI.Embed
local Interact = UI.Interact

Extra.Request  = syn and syn.request
Extra.Image    = Image
Extra.GetAsset = syn and getsynasset or getcustomasset

Interact.SendFunction = function(data)
    ROCHAT_Config.Client:Send(data)
end

local Embed = {
    ScrollingFrame = nil
}

Embed.new = function(xml, ScrollingFrame)
    ScrollingFrame = ScrollingFrame or Embed.ScrollingFrame
    local Data = XML:Parse(xml)
    local EmbedData
    local Resize = true

    for i, Tag in next, Data.Tags do

        if Tag.Tag == "embed" then
            local Color = Tag.Attributes.Color or Tag.Attributes.Colour
            local Size = Tag.Attributes.Size
            Resize = Tag.Attributes.Resize or Resize

            EmbedData = EmbedUI.new({color = type(Color) == "userdata" and Color or type(Color) == "table" and Color3.fromRGB(Color.R, Color.G, Color.B) or Color3.fromRGB(155, 0, 0)})

            local embed = EmbedData.instance
            embed.Size = Size or UDim2.new(0, 0, 0, 0)

            -- if Size then
                -- embed.Size = Size
            -- end
        end
        if Tag.Tag == "textbutton" or Tag.Tag == "button" then
            local Obj = Interact.new({
                callback = Tag.Attributes.Onclick and loadstring("return " .. Tag.Attributes.Onclick)() or function() end,
                parent = EmbedData.instance.content,
                order = #EmbedData.instance.content:GetChildren() + 1,
                type = "button",
                color = Tag.Attributes.Color or Tag.Attributes.Colour,
                text = Tag.Text
            })

            if Resize then
                local ObjInstance = Obj.instance
                local EmbedInstance = EmbedData.instance

                if ObjInstance.AbsoluteSize.X + ObjInstance.AbsolutePosition.X + 4 > EmbedInstance.AbsoluteSize.X + EmbedInstance.AbsolutePosition.X - 4 then
                    EmbedInstance.Size = EmbedInstance.Size + UDim2.new(0, (ObjInstance.AbsoluteSize.X + ObjInstance.AbsolutePosition.X + 4) - (EmbedInstance.AbsoluteSize.X + EmbedInstance.AbsolutePosition.X), 0, 0)
                end

                if ObjInstance.AbsoluteSize.Y + ObjInstance.AbsolutePosition.X + 4 > EmbedInstance.AbsoluteSize.X + EmbedInstance.AbsolutePosition.Y - 4 then
                    EmbedInstance.Size = EmbedInstance.Size + UDim2.new(0, (ObjInstance.AbsoluteSize.Y + ObjInstance.AbsolutePosition.X + 4) - (EmbedInstance.AbsoluteSize.X + EmbedInstance.AbsolutePosition.X), 0, 0)
                end
            end
        end
        if Tag.Tag == "textlabel" or Tag.Tag == "label" then
            local Obj = Extra.new({
                type = "label",
                parent = EmbedData.instance.content,
                order = #EmbedData.instance.content:GetChildren() + 1,
                data = {
                    color = Tag.Attributes.Color or Tag.Attributes.Colour,
                    content = Tag.Text,
                    fontsize = Tag.Attributes.Fontsize
                }
            })
            if Resize then
                local ObjInstance = Obj.instance
                local EmbedInstance = EmbedData.instance

                if ObjInstance.AbsoluteSize.X + ObjInstance.AbsolutePosition.X + 4 > EmbedInstance.AbsoluteSize.X + EmbedInstance.AbsolutePosition.X - 4 then
                    EmbedInstance.Size = EmbedInstance.Size + UDim2.new(0, (ObjInstance.AbsoluteSize.X + ObjInstance.AbsolutePosition.X + 4) - (EmbedInstance.AbsoluteSize.X + EmbedInstance.AbsolutePosition.X), 0, 0)
                end
            end
        end
        if Tag.Tag == "imagelabel" or Tag.Tag == "image" then
            local Obj = Extra.new({
                type = "imagelabel",
                parent = EmbedData.instance.content,
                order = #EmbedData.instance.content:GetChildren() + 1,
                data = {
                    color = Tag.Attributes.Color or Tag.Attributes.Colour,
                    url = Tag.Attributes.Image or Tag.Attributes.Src or Tag.Attributes.Url
                }
            })

            if Resize then
                local ObjInstance = Obj.instance
                local EmbedInstance = EmbedData.instance

                if ObjInstance.AbsoluteSize.X + ObjInstance.AbsolutePosition.X + 4 > EmbedInstance.AbsoluteSize.X + EmbedInstance.AbsolutePosition.X - 4 then
                    EmbedInstance.Size = EmbedInstance.Size + UDim2.new(0, (ObjInstance.AbsoluteSize.X + ObjInstance.AbsolutePosition.X + 4) - (EmbedInstance.AbsoluteSize.X + EmbedInstance.AbsolutePosition.X), 0, 0)
                end
            end
        end
    end
    EmbedData:SetParent(ScrollingFrame)

    return EmbedData
end

return Embed