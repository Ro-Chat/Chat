------------------------------------------------------------------------
-- ooooooooo.               .oooooo.   oooo                      .    --
-- `888   `Y88.            d8P'  `Y8b  `888                    .o8    --
--  888   .d88'  .ooooo.  888           888 .oo.    .oooo.   .o888oo  --
--  888ooo88P'  d88' `88b 888           888P"Y88b  `P  )88b    888    --
--  888`88b.    888   888 888           888   888   .oP"888    888    --
--  888  `88b.  888   888 `88b    ooo   888   888  d8(  888    888 .  --
-- o888o  o888o `Y8bod8P'  `Y8bood8P'  o888o o888o `Y888""8o   "888"  --
--                                                                    --
-- ooooo                                  .o8                         --
-- `888'                                 "888                         --
--  888          .ooooo.   .oooo.    .oooo888   .ooooo.  oooo d8b     --
--  888         d88' `88b `P  )88b  d88' `888  d88' `88b `888""8P     --
--  888         888   888  .oP"888  888   888  888ooo888  888         --
--  888       o 888   888 d8(  888  888   888  888    .o  888         --
-- o888ooooood8 `Y8bod8P' `Y888""8o `Y8bod88P" `Y8bod8P' d888b        --
------------------------------------------------------------------------
-- Version: 0.0.1                                                     --
------------------------------------------------------------------------   

getgenv().ROCHAT_Config = {
    WSS = "wss://WS-Server.eeeeeevbr.repl.co",
    Version = "v1",
 }
 
 local HttpService = game:GetService("HttpService")
 
 local Release = debug.getinfo(2)
 local Path    = Release and "https://raw.githubusercontent.com/Ro-Chat/Chat/main/" or "RoChat/"
 
 -- Directory Structure
 
 function makeDirectories(dirs)
     if not isfolder("RoChat") then
         makefolder("RoChat")
     end
     for i, dir in next, dirs do
         makefolder("RoChat/" .. dir)
     end
 end
 
 makeDirectories({
     "Profiles",
     "Emojis",
     "Versions",
     "Embeds"
 })
 
 local ProfilePath = ("RoChat/Profiles/%s_profile.json"):format(ROCHAT_Config.Version)
 
 if isfile(ProfilePath) then
     ROCHAT_Config.Profile = HttpService:JSONDecode(readfile(ProfilePath))
 else
     if ROCHAT_Config.Version == "v1" then
         local Profile = {
             Name = game.Players.LocalPlayer.DisplayName,
             Color = {math.random(50, 150), math.random(50, 150), math.random(50, 150)},
             Emojis = {
                 troll = {
                     Url = "https://raw.githubusercontent.com/Ro-Chat/Chat/main/Emojis/troll.png",
                     Type = "Image"
                 }
             }
         }
         ROCHAT_Config.Profile = Profile
         writefile(ProfilePath, HttpService:JSONEncode(ROCHAT_Config.Profile))
     end
 end
 
 loadstring(readfile(Path .. "Versions/" .. ROCHAT_Config.Version .. "/Main.lua"))()(Release)