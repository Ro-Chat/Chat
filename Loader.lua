
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
-- Version: 0.0.1  |                                                  --
------------------------------------------------------------------------

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")

local Request = syn.request or http and request
local Release = debug.getinfo(2)
local Path    = Release and "https://raw.githubusercontent.com/Ro-Chat/Chat/main/" or "RoChat/"

-- Directory Structure

function makeDirectories(dirs)
    if not isfolder("RoChat") then
        makefolder("RoChat")
    end
    for i, dir in next, dirs do
        if isfolder("RoChat/" .. dir) then continue end
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
local VersionPath = ("RoChat/Versions/%s"):format(ROCHAT_Config.Version)

function makeTemplate(template, vars)
    for Key, Value in next, vars do
        template = template:gsub(("__%s__"):format(Key:upper()), tostring(Value))
    end
    
    return template
end

if isfile(ProfilePath) then
    ROCHAT_Config.Profile = HttpService:JSONDecode(readfile(ProfilePath))
else
    local ProfileTemplate = ("%s/Assets/Templates/Profile.json"):format(VersionPath)
    
    if isfile(ProfileTemplate) then
        ProfileTemplate = readfile(ProfileTemplate)
    else
        ProfileTemplate = game:HttpGet(("https://raw.githubusercontent.com/Ro-Chat/Chat/main/%s"):format(ProfileTemplate:sub(8, #ProfileTemplate)))
    end
    
    -- print(ProfileTemplate)
    
    local Template = makeTemplate(ProfileTemplate, {
        Name = Players.LocalPlayer.DisplayName,
        Red = math.random(100, 255),
        Green = math.random(100, 255),
        Blue = math.random(100, 255),
        Fingerprint = Fingerprint
    })
    
    -- print(Template)
    
    ROCHAT_Config.Profile = HttpService:JSONDecode(Template)
    writefile(ProfilePath, Template)
end

local MainPath = Path .. "Versions/" .. ROCHAT_Config.Version .. "/Main.lua"

local Headers = HttpService:JSONDecode(Request({
    Method = "GET",
    Url = "https://rocat.000webhostapp.com/headers.php"
}).Body:gsub("\",}", "\"}"))

for Header, Value in next, Headers do
    if Header:lower():match("fingerprint") or Header:lower():match("hwid") then
        getgenv().Fingerprint = Value
        break
    end
end

loadstring(not Release and readfile(MainPath) or game:HttpGet(MainPath))()(Release)
