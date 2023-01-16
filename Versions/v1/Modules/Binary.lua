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

return setmetatable(Binary, binaryMT);
