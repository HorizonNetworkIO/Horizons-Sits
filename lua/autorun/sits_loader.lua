// Steel's Addon Loader
// Fuck off

local AddonSubFolder = "sits"
local AddonName = "HZNSits"
local AddonColor = Color(236, 61, 17)
local DebugAddon = false

HZNSits = {}

function HZNSits:Log(str)
    MsgC(AddonColor, "[" .. AddonName .. "] ", Color(255, 255, 255), str .. "\n")
end

local function loadServerFile(str)
    if CLIENT then return end
    include(str)
    HZNSits:Log("Loaded Server File " .. str)
end

local function loadClientFile(str)
    if SERVER then AddCSLuaFile(str) return end
    include(str)
    HZNSits:Log("Loaded Client File " .. str)
end

local function loadSharedFile(str)
    if SERVER then AddCSLuaFile(str) end
    include(str)
    HZNSits:Log("Loaded Shared File " .. str)
end

local function load()
    local clientFiles = file.Find(AddonSubFolder .. "/cl/*.lua", "LUA")
    local sharedFiles = file.Find(AddonSubFolder .. "/sh/*.lua", "LUA")
    local serverFiles = file.Find(AddonSubFolder .. "/sv/*.lua", "LUA")

    for _, file in pairs(clientFiles) do
        loadClientFile(AddonSubFolder .. "/cl/" .. file)
    end

    for _, file in pairs(sharedFiles) do
        loadSharedFile(AddonSubFolder .. "/sh/" .. file)
    end

    for _, file in pairs(serverFiles) do
        loadServerFile(AddonSubFolder .. "/sv/" .. file)
    end

    HZNSits:Log("Loaded " .. #clientFiles + #sharedFiles + #serverFiles .. " files")

    if (SERVER) then
        -- For debugging
        if (DebugAddon) then
            for k, v in ipairs(player.GetAll()) do
                v:SetNWBool("HZN_IsInRoom", false)
                v:SetNWInt("HZN_RoomID", 0)
            end
            if (player.GetCount() > 0) then
                HZNSits:LoadData()
                HZNSits:SyncRooms()
            end
        else
            HZNSits:LoadData()
        end
    end
end

load()