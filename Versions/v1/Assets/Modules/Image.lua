-- local Int = Import("Int")
local String = Import("String")
local Image = {}

function Image.new(data)
   if data:sub(1, 4) == "\137\80\78\71" then
       local Length = Int.from_bytes(data:sub(17, 20))
       local Height = Int.from_bytes(data:sub(21, 24))
       
       local LengthOffset = Length / Height
       local HeightOffset = Height / Length
       
       return {
         Width = Length,
         Height = Height,
         WidthOffset = LengthOffset,
         HeightOffset = HeightOffset,
         Type = "PNG"
       }
   end
   if data:sub(utf8.offset(data, 9), utf8.offset(data, 12)) == "WEBP" then
       local str = String.new(data)
       return {
           Height = str:isub(25, 26, "little"),
           Width = str:isub(27, 28, "little"),
           Type = "WEBP"
       }
   end
   if data:sub(utf8.offset(data, 4), utf8.offset(data, 7)) == "ftyp" then
    local Data = {
        Type = "MP4"
    }
    local str = String.new(data)
    local Address = 0x8

    Data.SubType = str:reader(Address, 4)
    Data.MinorVersion = str:reader(Address, 4, str.isub)

    Data.Freespace = {
        Size = str:reader(Address, 4, str.isub),
    }

    Data.Freespace.Type = str:reader(Address, Data.Freespace - 4)
    Data.Movie = {
        Size = str:reader(Address, 4, str.isub),
        Type = str:reader(Address, 4)
    }
    Data.Movie.Buffer = str:reader(Address, Data.Movie.Size)

    if Data.Movie.Type == "moov" or Data.Movie.Type == "mvhd" then
        
    end
    print(Address)

    return {
        Type = "MP4",
        SubType = str:sub(8, 11),
        MinorVersion = str:sub(12, 15),
    }
   end
   if data:sub(1, 3) == "GIF" then
      local str = String.new(data)
      
      return {
          Type = "GIF",
          Version = str:sub(3, 6),
          Height = str:isub(7, 8, "little"),
          Width = str:isub(9, 10, "little"),
          PackedField = str:bsub(11, 11),
          BackgroundColorIndex = str:isub(12, 12),
          PixelAspectRatio = str:isub(13, 13)
      }
      
   end
   if data:sub(1, 3) == "\255\216\255" then
       local str = String.new(data)
    
       local start_offset = str:find("\255\192", 1) + 5
       
       local Height = str:isub(start_offset, start_offset + 1)
       local Length = str:isub(start_offset + 2, start_offset + 3)
       
       local LengthOffset = Length / Height
       local HeightOffset = Height / Length
       
       return {
         Width = Length,
         Height = Height,
         WidthOffset = LengthOffset,
         HeightOffset = HeightOffset,
         Type = "JPG"
       }
   end
end

return Image
