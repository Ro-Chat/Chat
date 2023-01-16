local Int = Import("Int")
local Binary = Import("Binary")

local String = {}

String.ImageToLines = function(image_class, font_size)
  return image_class.Height / font_size
end

String.new = function(str)
    local string = {
        string = str,
    }
    
    function string:set(str)
        string.string = str
    end
    
    function string:regex(pattern)
        -- Add regex shit later
    end
    
    function string:isub(sbegin, send, endianness)
        return Int.from_bytes(string.string:sub(utf8.offset(string.string, sbegin), utf8.offset(string.string, send)), endianness)
    end
    
    function string:bsub(sbegin, send, endianness)
       return Binary(Int.from_bytes(string.string:sub(utf8.offset(string.string, sbegin), utf8.offset(string.string, send)), endianness)).binary
    end
    
    function string:sub(sbegin, send)
        return string.string:sub(utf8.offset(string.string, sbegin), utf8.offset(string.string, send))
    end
    
    function string:append(str)
        string.string = string.string .. str
    end
    
    function string:find(str, amount)
        amount = amount or 1
        
        local found_amount = 0
        local positions = {}
        
        for i = 1, #string.string do
            if string.string:sub(i, i + #str - 1) == str then
                found_amount += 1
                table.insert(positions, i)
                if found_amount >= amount then break end
            end
        end
        
        return unpack(positions)
    end
    
    return setmetatable(string, {
        __call = function(self, str)
            if str then
               string.string = str
            end
            return string.string
        end
    })
end
