local get_attributes = function(str)
    local Data = {}
    if #str:split("=\"")>0 then
        for i = 2,#str:split("=\"") do
            if str:split("=\"")[i] then
                local Property = str:split("=\"")[i-1]:split(" ")[#str:split("=\"")[i - 1]:split(" ")]
                Property = Property:sub(1,1):upper() .. Property:sub(2, #Property)
                local Value = str:split("=\"")[i]:split("\"")[1]
                if Value:sub(1, 1) == "[" then
                    Value = loadstring("return {"..Value:sub(2,#Value-1).."}")()
                elseif Value == "false" then
                    Value = false
                elseif Value == "true" then
                    Value = true
                elseif Value:sub(1, 3):lower() == "rgb" then
                    local RGB = Value:split("(")[2]:split(")")[1]
                    Value = {R = RGB:split(",")[1], G = RGB:split(",")[2], B = RGB:split(",")[3]}
                end
                Data[Property] = Value
            end
        end
    end
    return Data
end

local XML = {
    Parse = function(self, txt)
        local Data = {}
        ElementCounter = 0 
        for i = 2,#txt:split("<") do
            local Str = txt:split("<")[i]
            local Element = Str:split(" ")[1] and Str:split(" ")[1]:split(">")[1] or Str:split(" ")[1] or Str:split(">")[1]
            if not Element:match("/") then
                   ElementCounter = ElementCounter + 1
                   local Attributes = get_attributes(Str)
                   Attributes.Text = Str:match(">(.+)") and Str:match(">(.+)"):gsub("\n", "") or Str:match(">(.+)")
                   Attributes.Tag = Element
                   Attributes.XML = Str
                   table.insert(Data, Attributes)
            end
        end
     
        return Data
    end
}

return XML