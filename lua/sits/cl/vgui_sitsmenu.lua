local PANEL = {}

local sw = function (x) return (ScrW() * x)/1920 end
local sh = function (x) return (ScrH() * x)/1080 end

local header_size = sh(30)

function PANEL:Init()
    self.selectedRoom = 0

    self:SetTitle("")

    self:Reset()
end

function PANEL:Setup()
    self:SetSize(sw(350), sh(200))
    self:Center()
    self:MakePopup()
    self:SetTitle("Horizon Sits")
end

function PANEL:Reset()
    self.selectedRoom = 0

    if (self.rooms) then
        self.rooms:Remove()
    end

    if (self.viewRoom) then
        self.viewRoom:Remove()
    end

    self.rooms = vgui.Create("DLL.ScrollPanel", self)
    self.rooms:Dock(FILL)
    self.rooms:DockMargin(5, 5, 5, 5)
    for k,v in ipairs(HZNSits.rooms) do
        local room = vgui.Create("DLL.Button", self.rooms)
        room:SetText("Room #" .. k)
        room:Dock(TOP)
        room:DockMargin(5, 5, 5, 5)
        -- room:SetTextColor((#v.players > 0) and Color(0, 0, 0) or color_white)
        room.DoClick = function()
            self:SetViewRoom(k)
        end
        room.PaintExtra = function(self, w, h)
            DLL.DrawSimpleText("Room #" .. k, "HZNSits:B:Small", w/2, h/2, color_white, 1, 1)
        end
    end

    self:Setup()
end

function PANEL:SetViewRoom(id)
    if (self.rooms) then
        self.rooms:Remove()
    end

    self.viewRoom = vgui.Create("DLL.ScrollPanel", self)
    self.viewRoom:Dock(FILL)
    self.viewRoom:DockMargin(5, 5, 5, 5)

    self.backButton = vgui.Create("DLL.Button", self.viewRoom)
    self.backButton:Dock(TOP)
    self.backButton:DockMargin(5, 5, 5, 5)
    self.backButton.DoClick = function()
        self:Reset()
    end
    function self.backButton:PaintExtra(w, h)
        DLL.DrawSimpleText("Back", "HZNSits:N:Small", w/2, h/2, DLL.Colors.PrimaryText, 1, 1)
    end    

    if (!LocalPlayer():HZN_IsInRoom()) then
        self.joinButton = vgui.Create("DLL.Button", self.viewRoom)
        self.joinButton:Dock(TOP)
        self.joinButton:DockMargin(5, 5, 5, 5)
        self.joinButton.DoClick = function()
            net.Start("HZNSits:JoinSit")
                net.WriteUInt(id, 8)
            net.SendToServer()
        end
        function self.joinButton:PaintExtra(w, h)
            DLL.DrawSimpleText("Join", "HZNSits:N:Small", w/2, h/2, DLL.Colors.PrimaryText, 1, 1)
        end    
    end

    for k,v in ipairs(HZNSits.rooms[id].players) do
        local pl = player.GetBySteamID64(v[1])

        if (!pl) then continue end

        local ply = vgui.Create("DLL.Button", self.viewRoom)
        ply:Dock(TOP)
        ply:DockMargin(5, 5, 5, 5)
        ply.NormalCol = DLL.Colors.Positive
        ply.HoverCol = DLL.OffsetColor(ply.NormalCol, -15)
        ply.PressedCol = DLL.OffsetColor(ply.NormalCol, 15)
        ply.BackgroundCol = ply.NormalCol
        function ply:PaintExtra(w,h)
            DLL.DrawSimpleText(pl:Nick(), "HZNSits:N:Small", w/2, h/2, DLL.Colors.PrimaryText, 1, 1)
        end
    end
end

vgui.Register("HZNSits:SitsFrame", PANEL, "DLL.Frame")

concommand.Add("hznsits_opensits", function()
    if HZNSits.sitsframe then
        HZNSits.sitsframe:Remove()
    end

    HZNSits.sitsframe = vgui.Create("HZNSits:SitsFrame")
end)