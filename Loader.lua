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
local Status, Release = pcall(function() return debug.getinfo(3) end)
local Path    = Release and "https://raw.githubusercontent.com/Ro-Chat/Chat/main/" or "RoChat/"

Release = Status and Release

if not game:IsLoaded() then 
    repeat task.wait() until game:IsLoaded()
end

if not isfolder("RoChat") then
    local function makeDirectories(dirs)
        makefolder("RoChat")
        for _, subDir in next, dirs do
            if isfolder("RoChat/" .. subDir) then continue end
            makefolder("RoChat/" .. subDir)
        end
    end

    local subDirectories = Release and {"Profiles", "Emojis", "Plugins"} or {"Profiles", "Emojis", "Plugins", "Embeds", "Server", "Versions"}

    makeDirectories(subDirectories)
end

local profilePath = ("RoChat/Profiles/%s_profile.json"):format(ROCHAT_Config.Version)
local versionPath = ("RoChat/Versions/%s"):format(ROCHAT_Config.Version)

if isfile(profilePath) then
    ROCHAT_Config.Profile = HttpService:JSONDecode(readfile(profilePath))
else
    local function makeTemplate(template, vars)
        for Key, Value in next, vars do
            template = template:gsub(("__%s__"):format(Key:upper()), tostring(Value))
        end

        return template
    end
    
    local profileTemplate = ("%s/Assets/Templates/Profile.json"):format(versionPath)
    
    if isfile(profileTemplate) then
        profileTemplate = readfile(profileTemplate)
    else
        profileTemplate = game:HttpGet(("https://raw.githubusercontent.com/Ro-Chat/Chat/main/%s"):format(profileTemplate:sub(8, #profileTemplate)))
    end
    
    local Template = makeTemplate(profileTemplate, {
        Name = Players.LocalPlayer.DisplayName,
        Red = math.random(100, 255),
        Green = math.random(100, 255),
        Blue = math.random(100, 255)
    })
    
    ROCHAT_Config.Profile = HttpService:JSONDecode(Template)
    writefile(profilePath, Template)
end

local mainPath = Path .. "Versions/" .. ROCHAT_Config.Version .. "/Main.lua"

local Headers = HttpService:JSONDecode(Request({
    Method = "GET",
    Url = "https://rocat.000webhostapp.com/headers.php"
}).Body:gsub("\",}", "\"}"))

for Header, Value in next, Headers do
    if Header:lower():match("fingerprint") or Header:lower():match("hwid") then
        loadstring(not Release and readfile(mainPath) or game:HttpGet(mainPath))()(Release, Value)
        break
    end
end
