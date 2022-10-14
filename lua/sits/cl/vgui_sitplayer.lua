local PANEL = {}

local sw = function (x) return (ScrW() * x)/1920 end
local sh = function (x) return (ScrH() * x)/1080 end

function PANEL:Init()
    self.Player = nil

    self:SetText("")
    self.plyAvatar = vgui.Create("AvatarImage", self)
    self.plyAvatar:SetSize(sw(30), sh(30))
    self.plyAvatar:SetPos(sw(7), self:GetTall()/2-7)
end

-- on right click
function PANEL:DoRightClick()
    if not self.Player then return end
    local ply = Player(self.Player)
    if !IsValid(ply) then return end
    if !ply:IsPlayer() or ply:IsBot() then return end

    local menu = DermaMenu()
    menu:AddOption("Copy Name", function()
        SetClipboardText(ply:Nick())
    end)
    menu:AddOption("Copy SteamID", function()
        SetClipboardText(ply:SteamID())
    end)
    menu:AddOption("Copy SteamID64", function()
        SetClipboardText(ply:SteamID64())
    end)
    menu:AddOption("Gag", function()
        RunConsoleCommand("sam", "gag", ply:SteamID64())
    end)
    menu:AddOption("Un-Gag", function()
        RunConsoleCommand("sam", "ungag", ply:SteamID64())
    end)
    menu:AddOption("Mute", function()
        RunConsoleCommand("sam", "mute", ply:SteamID64())
    end)
    menu:AddOption("Un-Mute", function()
        RunConsoleCommand("sam", "unmute", ply:SteamID64())
    end)
    menu:AddOption("Freeze", function()
        RunConsoleCommand("sam", "freeze", ply:SteamID64())
    end)
    menu:AddOption("Un-Freeze", function()
        RunConsoleCommand("sam", "unfreeze", ply:SteamID64())
    end)
    menu:AddOption("Bring", function()
        RunConsoleCommand("sam", "bring", ply:SteamID64())
    end)
    menu:AddOption("Open Steam Profile", function()
        if (ply:SteamID64()) then
            gui.OpenURL("http://steamcommunity.com/profiles/"..ply:SteamID64())
        end
    end)
    menu:Open()
end

function PANEL:SetPlayer(ply)
    self.Player = ply:UserID()
    self.plyAvatar:SetPlayer(ply)
end

function PANEL:GetPlayer()
    self.Player = Player(self.Player)
end

function PANEL:Paint(w,h)
    if not self.Player then return end

    local ply = Player(self.Player)
    
    if not ply then return end
    if !IsValid(ply) then return end

    local name = HZNHud.FormatText(ply:Nick(), 12)
    local job = HZNHud.FormatText(team.GetName(ply:Team()), 15)
    local nameSize = select(1, surface.GetTextSize(name))
    local rank = HZNHud.FormatText(ply:sam_getrank(), 15)
    local isFocused = ply:HZN_IsFocused()

    draw.SimpleText(name, "HZNSits:N:Small", sw(50), self:GetTall() / 2, HZNSits.Colors["RoomPanelText"], 0, 1)
    draw.SimpleText(rank .. " / " .. job, "HZNSits:N:Small", self:GetWide() - sw(20), self:GetTall() / 2, HZNSits.Colors["RoomPanelText"], 2, 1)
    draw.RoundedBox(26, sw(65) + nameSize, self:GetTall() / 2 - sh(6), sw(12), sh(12), isFocused and HZNSits.Colors["PlayerFocused"] or HZNSits.Colors["PlayerUnfocused"])
end

vgui.Register("HZN:SitPlayer", PANEL, "DButton")