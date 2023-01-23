local XML   = Import("XML")
local UI    = Import("UI")
local Image = Import("Image")

local Extra = UI.Extra
local EmbedUI = UI.Embed
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

Embed.new = function(xml)
    local Data = XML:Parse(xml)
    local EmbedData
    print("Embed Debug")
    for i, Tag in next, Data do
        if Tag.Tag == "embed" then
            local Color = Tag.Color or Tag.Colour
            local Size = Tag.Size
            EmbedData = EmbedUI.new({color = Color and Color3.fromRGB(Color.R, Color.G, Color.B) or Color.fromRGB(155, 0, 0)})
            local embed = EmbedData.instance
            if Size then
                if Size[1] + 4 > Embed.ScrollingFrame.AbsoluteSize.Y then
                    Size[1] = Embed.ScrollingFrame.AbsoluteSize.Y - 4
                end

                if Size[2] + 4 > Embed.ScrollingFrame.AbsoluteSize.X then
                    Size[2] = Embed.ScrollingFrame.AbsoluteSize.X - 4
                end

                embed.Size = UDim2.new(unpack(Size))
            end
        end
        if Tag.Tag == "textbutton" or Tag.Tag == "button" then
            Interact.new({
                callback = Tag.Onclick and loadstring("return function() return " .. Tag.Onclick .. " end")() or function() end,
                parent = EmbedData.instance.content,
                order = #EmbedData.instance.content:GetChildren() + 1,
                type = "button",
                color = Tag.Color or Tag.Colour,
                text = Tag.Text
            })
        end
    end
    EmbedData:SetParent(Embed.ScrollingFrame)
end

return Embed