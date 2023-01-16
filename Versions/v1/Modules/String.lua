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
                found_amount = found_amount + 1
                table.insert(positions, i)
                if found_amount >= amount then break end
            end
        end
        
        return unpack(positions)
    end
    
    return setmetatable(string, {
    __call = function(self, str)
        if str then
           self.string = str
        end
        return self.string
    end,
  __index = function(self, prop)
     if not prop then return self.string end
     local Property = rawget(self, prop)
     if Property then return Property end
     self.string = tostring(prop)
     
     return self.string
  end,
  __add = function(self, val)
    self.string = self.string .. tostring(val)
    return self.string
  end,
  __sub = function(self, val)
    self.string = self.string:sub(1, utf8.offset(self.string, #self.string - val))
    return self.string
  end,
  __div = function(self, val)
    local result = {}
    for i = 1, #self.string, val do
        table.insert(result, self.string:sub(i, i + val - 1))
    end
    return result
  end,
  __concat = function(self, val)
      self.string = self.string .. val
      return self.string
  end,
  __mul = function(self, val)
      for i = 1, val do
          self.string = self.string .. self.string
      end
      return self.string
  end,
  __pow = function(self, val)
      -- I have a small brain so this is good enough
      for i = 1, val do
          for i = 1, val do
              self.string = self.string .. self.string
          end
          self.string = self.string .. self.string
      end
      return self.string
  end,
  __mod = function(self, val)
    -- Same as divide because why not
    local result = {}
    for i = 1, #self.string, val do
        table.insert(result, self.string:sub(i, i + val - 1))
    end
    return result
  end,
  __tostring = function(self)
      return self.string
  end,
  __len = function(self)
      return #self.string
  end
})
end

return String
