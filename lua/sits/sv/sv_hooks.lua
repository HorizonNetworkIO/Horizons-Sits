-- disable spawning props while in room
hook.Add("PlayerSpawnedProp", "HZNSits:PlayerSpawnProp", function(ply, mdl, ent)
    if (ply:HZN_IsInRoom()) then
        ent:Remove()
    end
end)

-- remove from sit on disconnect
hook.Add("PlayerDisconnected", "HZNSits:PlayerDisconnect", function(ply)
    if (ply:HZN_IsInRoom()) then
        HZNSits:RemovePlayerFromSit(ply)
    end
end)

hook.Add("PlayerInitialSpawn", "HZNSits:PlayerInitialSpawn", function(ply)
    HZNSits:SyncRooms(ply)
end)

hook.Add("PlayerDeath", "HZNSits:PlayerDeath", function(ply)
    if (ply:HZN_IsInRoom()) then        
        timer.Create("HZNSits:Death:"..ply:SteamID(), 0.5, 0, function()
            if (ply:HZN_IsInRoom()) then
                if (ply:IsValid() and ply:Alive()) then
                    HZNSits:TeleportPlayersToRoom(ply:HZN_GetRoom(), ply)
                    timer.Remove("HZNSits:Death:"..ply:SteamID())
                end
            else
                timer.Remove("HZNSits:Death:"..ply:SteamID())
            end
        end)
    end
end)

hook.Add("PlayerChangedTeam", "HZNSits:ChangeTeam", function(ply, oldteam, newteam)
    if (ply:HZN_IsInRoom()) then        
        timer.Create("HZNSits:ChangeTeam:"..ply:SteamID(), 0.5, 0, function()
            if (ply:HZN_IsInRoom()) then
                if (ply:IsValid() and ply:Alive()) then
                    HZNSits:TeleportPlayersToRoom(ply:HZN_GetRoom(), ply)
                    timer.Remove("HZNSits:ChangeTeam:"..ply:SteamID())
                end
            else
                timer.Remove("HZNSits:ChangeTeam:"..ply:SteamID())
            end
        end)
    end
end)

hook.Add("playerUnArrested", "HZNSits:playerUnArrested", function(ply)
    if (!IsValid(ply)) then return end
    if (ply:HZN_IsInRoom()) then        
        timer.Create("HZNSits:UnArrest:"..ply:SteamID(), 0.5, 0, function()
            if (ply:HZN_IsInRoom()) then
                if (ply:IsValid() and ply:Alive()) then
                    HZNSits:TeleportPlayersToRoom(ply:HZN_GetRoom(), ply)
                    timer.Remove("HZNSits:UnArrest:"..ply:SteamID())
                end
            else
                timer.Remove("HZNSits:UnArrest:"..ply:SteamID())
            end
        end)
    end
end)