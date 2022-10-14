surface.CreateFont("HZNSits:N:Small", {font = "Open Sans", size = 18, antialias = true})
surface.CreateFont("HZNSits:B:Small", {font = "Open Sans Bold", size = 17, antialias = true})

function HZNSits:CreateRoomPanel()
    HZNSits.sitpanel = vgui.Create("HZN:SitPanel")
end

hook.Add("HZNSits:PlayerJoinedSit", "HZNSits_PlayerJoined", function(plyId)
    local ply = Player(plyId)
    if (not ply) then return end
    if (HZNSits.sitpanel) then
        HZNSits.sitpanel:AddPlayer(ply)
    else
        HZNSits:CreateRoomPanel()
        HZNSits.sitpanel:AddPlayer(ply)
    end
end)

hook.Add("HZNSits:PlayerLeftSit", "HZNSits_PlayerLeft", function(plyId)
    if (plyId == LocalPlayer():UserID()) then
        if (HZNSits.sitpanel) then
            HZNSits.sitpanel:Remove()   
            HZNSits.sitpanel = nil
        end
    else
        if (HZNSits.sitpanel) then
            HZNSits.sitpanel:RemovePlayer(plyId)
        else
            HZNSits:CreateRoomPanel()
        end
    end
end)