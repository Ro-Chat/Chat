function get_attributes(str)
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
                elseif Value:sub(1, 3):lower() == "udim2" then
                    local pos = Value:split("(")[2]:split(")")
                    Value = pos:split(",")
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
    Tags = {},
    Parse = function(self, txt)
        local Data = {}
        local ParentStack = {}
        local ElementCounter = 0
        
        for i = 2, #txt:split("<") do
            local Str = txt:split("<")[i]
            local Element = Str:split(" ")[1] and Str:split(" ")[1]:split(">")[1] or Str:split(" ")[1] or Str:split(">")[1]
            if not Element:match("/") then
                ElementCounter = ElementCounter + 1
                local Attributes = get_attributes(Str)
                Attributes.Text = Str:match(">(.+)") and Str:match(">(.+)"):gsub("\n", "") or Str:match(">(.+)")
                Attributes.Tag = Element
                Attributes.XML = Str
                Attributes.Parent = ParentStack[1]
                Attributes.Children = {}
                Attributes.Remove = function(this)
                    table.remove(self.Tags, this.Order)
                end
                Attributes.Order = #self.Tags + 1
                if ParentStack[1] then
                    table.insert(ParentStack[1].Children, Attributes)
                end
                table.insert(ParentStack, 1, Attributes)
                table.insert(self.Tags, Attributes)
                table.insert(Data, Attributes)
            else
                Element = Element:sub(2, #Element)
                for i,v in next, ParentStack do
                    if v.Tag == Element then
                        table.remove(ParentStack, i)
                        break
                    end
                end
            end
        end
     
        return Data
    end
}

return XML
