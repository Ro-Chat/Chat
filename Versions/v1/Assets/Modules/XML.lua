local Identifiers = {
    Table = "{",
    Color = "Color",
    UDim = "UDim",
    Vector = "Vector",
    Enum = "Enum",
    CFrame = "CFrame",
    BrickColor = "BrickColor",
    Region = "Region",
    Ray = "Ray",
    Rect = "Rect",
    Bool = "true|false"
}



local function checkString(value)
    if not value:match("[%a%p]") then return "Number" end
    
    for Name, Identifier in next, Identifiers do
        if Identifier:match("|") then
            for _, Identifier in next, Identifier:split("|") do
                if value:match(("^%s"):format(Identifier)) then
                    return Name
                end
            end
            
        end

        if value:match(("^%s"):format(Identifier)) then
            return Name
        end
    end
    
    return "String"
end

local function get_attributes(str)
    local Data = {}
    if #str:split("=\"")>0 then
        for i = 2,#str:split("=\"") do
            if str:split("=\"")[i] then
                local Property = str:split("=\"")[i-1]:split(" ")[#str:split("=\"")[i - 1]:split(" ")]
                Property = Property:sub(1,1):upper() .. Property:sub(2, #Property) -- Capitalize it because why not
                
                local Value = str:split("=\"")[i]:split("\"")[1]
                local Type = checkString(Value)

                if Type == "String" then
                    Value = "\"" .. Value .. "\""
                end

                print(Type, Property, Value)
                
                Data[Property] = loadstring("return " .. Value)()
            end
        end
    end
    return Data
end

local XML = {
    Parse = function(self, val)
        local Type = type(val)
        if Type == "string" then
            local txt = val
            local Data = {
                Tags = {},
                Find = function(self, tag, Properties)
                    for _, Tag in next, self.Tags do
                        if Properties then
                            for Key, Value in next, Properties do
                                if Tag[Key] == Value and Tag.Tag == tag then
                                    return Tag
                                end
                            end
                        end
                        if Tag.Tag == tag then
                            return Tag
                        end
                    end
                end,
                FindAll = function(self, tag, Properties)
                    local Results = {}
                    for _, Tag in next, self.Tags do
                        if Properties then
                            for Key, Value in next, Properties do
                                if Tag[Key] == Value and Tag.Tag == tag then
                                    table.insert(Results, Tag)
                                end
                            end
                        else
                            if Tag.Tag == tag then
                                table.insert(Results, Tag)
                            end
                        end
                    end
                    
                    return Results
                end
            }
            
            local ParentStack = {}
            -- local ElementCounter = 0
            
            for i = 2, #txt:split("<") do
                -- lol I need to make the child shit actually work
                local Str = txt:split("<")[i]
                local Element = Str:split(" ")[1] and Str:split(" ")[1]:split(">")[1] or Str:split(" ")[1] or Str:split(">")[1]
                
                if not Element:match("<%s?/") then
                    -- ElementCounter = ElementCounter + 1
                    local Tag = {}
                    Tag.Attributes = get_attributes(Str)
                    Tag.Text = Str:match(">(.+)") and Str:match(">(.+)"):gsub("\n", "") or Str:match(">(.+)")
                    Tag.Text = Tag.Text and Tag.Text:gsub("\t", ""):gsub("  ", "")
                    Tag.Tag = Element
                    Tag.XML = Str
                    Tag.Parent = ParentStack[1]
                    Tag.Children = {}
                    Tag.Remove = function(self)
                        table.remove(Data.Tags, self.ID)
                    end
                    Tag.AppendChild = function(self, Tag)
                        table.insert(self.Children, Tag)
                    end
                    Tag.ID = #Data.Tags + 1
                    if ParentStack[1] then
                        table.insert(ParentStack[1].Children, Tag)
                    end
                    table.insert(ParentStack, 1, Tag)
                    -- table.insert(self.Tags, Attribute)
                    table.insert(Data.Tags, Tag)
                end

                if Element:match("<%s?/") or Element:match("/%s?>") then
                    Element = Element:sub(2, #Element)
                    for i, v in next, ParentStack do
                        if v.Tag == Element then
                            table.remove(ParentStack, i)
                            break
                        end
                    end
                end
            end
        
            return Data
        end
        -- assert(Type == "table", ("Value has to be either a string or a table not %s"):format(Type))
        
        -- local Result = ""

        -- for _, Tag in next, val do
        --     for Name, Value in next, Tag.Attributes do
        --         local Str = ("<%s"):format(Value.Tag)

        --         Str = Str .. ("</%s>"):format(Value.Tag)
        --     end
        -- end
    end
}

return XML