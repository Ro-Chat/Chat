local Int = {}

Int.from_bytes = function(bytes, type)
   bytes = type == "little" and bytes:reverse() or bytes
   
   local ret = 0
   local index = 0

   for byte in bytes:gmatch(".") do
       index = index + 1
       ret = ret + byte:byte() * (2 ^ (((utf8.len(bytes) or #bytes) - index) * 8))
   end

   return math.floor(ret)
end


function createbin(val, str)
    if ( val / 2 ) < 1 then
        return (str..math.ceil( val / 2 )):reverse();
    end
    
    val = val / 2;
    str = str..math.ceil(( val - math.floor(val) ));
    return createbin(math.floor(val), str);
end

function ConvertBinary(val)
    return createbin(val, "");
end


local Bit = {}
local bitMT = {__mode = "k", __type="bit",__index = Bit}
local Bit = setmetatable(Bit, bitMT)
Bit.new = function(crumb)
    return {crumb:sub(1, 1), crumb:sub(2, 2)}
end

local Crumb = {}
local crumbMT = {__mode = "k", __type="crumb",__index = Crumb}
local Crumb = setmetatable(Crumb,crumbMT)

Crumb.new = function(nibble)
    return {{crumb = nibble:sub(1,2),bits = Bit.new(nibble:sub(1,2))},{crumb = nibble:sub(3,4),bits = Bit.new(nibble:sub(3,4))}}
end

local Nibble = {}
local nibbleMT = {__mode = "k", __type="nibble", __index = Nibble}
local Nibble = setmetatable(Nibble,nibbleMT)

Nibble.new = function(Byte)
    return {
        {nibble = Byte:sub(1,4), crumbs = Crumb.new(Byte:sub(1,4))},
        {nibble = Byte:sub(5,8), crumbs = Crumb.new(Byte:sub(5,8))}
    }
end

local Bytes = {}
local byteMT = {__mode = "k",__type = "byte",__index = Bytes}
local Bytes = setmetatable(Bytes,byteMT)

function B2D(binary)
    ret = 0
    binary = binary:reverse()
    for i=0, #binary - 1 do
        ret = ret + ( 2 ^ i ) * tonumber(binary:sub(i + 1, i + 1) )
    end
    return ret
end

Bytes.new = function(Binary)
    bytes = {}
    for i=1,#Binary/8 do
      byte = Binary:sub(i*8-8+1%i,i*8)
      table.insert(bytes,{
          byte = byte,
          nibbles = Nibble.new(byte),
          decimal = B2D(byte)
      })
    end
    return bytes
end


local Binary = {}
local binaryMT = {__mode = "k", __type = "binary", __index = Binary,
    __call = function(self, val)
        if type(val) == "string" then
            self.binary = val
            self.bytes = Bytes.new(self.binary)
            self.decimal = B2D(val)
            return self
        end
        self.binary = ConvertBinary(val)
        self.bytes = Bytes.new(self.binary)
        self.decimal = val
        return self
    end;
}

Binary = setmetatable(Binary, binaryMT);

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
        __call = function(self, ...)
            return string.string
        end
    })
end
