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

return Int
