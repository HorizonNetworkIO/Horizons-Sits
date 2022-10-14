local PANEL = {}

local sw = function (x) return (ScrW() * x)/1920 end
local sh = function (x) return (ScrH() * x)/1080 end

local header_size = sh(30)
local player_size = sw(40)

local get_tall = function(pnl)
    return header_size + (sh(player_size) * #pnl.playerPnl) 
end

local get_y_pos = function(pnl, i)
    return (i==1) and header_size or header_size + (sh(player_size) * math.Clamp(i-1, 1, #pnl.playerPnl))
end

function PANEL:Init()
    if (HZNSits.sitpanel and HZNSits.sitpanel != self) then
        self:Remove()
    end

    self.playerPnl = {}
end

function PANEL:Setup()
    self:SetSize(sw(450), get_tall(self))
    self:SetPos(ScrW()/2 - (self:GetWide()/2), sh(80))
end

function PANEL:Paint(w, h)
    draw.RoundedBox(2, 0, 0, self:GetWide(), self:GetTall(), HZNSits.Colors["RoomPanel"])
    draw.RoundedBoxEx(2, 0, 0, self:GetWide(), header_size, HZNSits.Colors["RoomPanelHeader"], true, true, false, false)
    draw.SimpleText("Horizon - Room #" .. (LocalPlayer():HZN_GetRoom()), "HZNSits:B:Small", sw(10), header_size/2, HZNSits.Colors["RoomPanelText"], 0, 1)
end

function PANEL:AddPlayer(ply)
    HZNSits.sitpanel:Setup()

    table.insert(self.playerPnl, vgui.Create("HZN:SitPlayer", self))
    self.playerPnl[#self.playerPnl]:SetPlayer(ply)
    self.playerPnl[#self.playerPnl]:SetSize(self:GetWide(), sh(player_size))
    self.playerPnl[#self.playerPnl]:SetPos(0, get_y_pos(self, #self.playerPnl))
    self:Setup()
end

function PANEL:RemovePlayer(plyId)
    for k,v in ipairs(self.playerPnl) do
        if v.Player == plyId then
            local pnl = table.remove(self.playerPnl, k)
            if (IsValid(pnl)) then
                print("Still Valid")
                pnl:Remove()
            end
        end
    end

    self:Setup()
    
    for k,v in ipairs(self.playerPnl) do
        v:SetPos(0, get_y_pos(self, k))
    end
end

vgui.Register("HZN:SitPanel", PANEL, "DPanel")