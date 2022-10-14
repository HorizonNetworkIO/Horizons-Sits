sam.permissions.add("hzn_sits", nil, "trialmoderator")

function HZNSits:StartSit(admin)
    if (!HZNSits:HasAuthority(admin)) then
        HZNSits:Say("[ERROR] ".. (admin:Nick() or "") .." tried to start a sit but doesn't have authority!", admin)
        return nil
    end
    if (admin:HZN_IsInRoom()) then
        HZNSits:Say("[ERROR] ".. (admin:Nick() or "") .." tried to start a sit but is already in one!", admin)
        return nil
    end

    -- get available room
    local room = HZNSits:GetRandomRoom()
    
    if (!room) then
        HZNSits:Say("[ERROR] No rooms are available!", admin)
        return nil
    end

    -- add player to room
    HZNSits:AddPlayerToSit(admin, room)

    timer.Create("HZNSits:SitStatusUpdate" .. room, 5, 0, function()
        HZNSits:CheckRoomStatus(room)
    end)

    return room
end

util.AddNetworkString("HZNSits:ChangeState")
function HZNSits:AddPlayerToSit(ply, id, silent, caller)
    local room = HZNSits:GetRoom(id)
    if (!room) then
        HZNSits:Log("[ERROR] Room ".. id .." does not exist!")
        HZNSits:Say("[ERROR] ".. (ply:Nick() or "") .." tried to add a player to a room that doesn't exist!", ply)
        return
    end

    if (ply:HZN_IsInRoom()) then 
        if (caller) then
            HZNSits:Say("[ERROR] Player is already in a room!", caller)
        end
        return
    end

    local returnPosition = ply:GetPos()
    local returnAngle = ply:GetAngles()

    ply.sam_tele_pos, ply.sam_tele_ang = returnPosition, returnAngle

    // update room data
    table.insert(room.players, {ply:SteamID64(), returnPosition, returnAngle})
    HZNSits.rooms[id] = room
    ply:SetNWBool("HZN_IsInRoom", true)
    ply:SetNWInt("HZN_RoomID", id)

    // teleport player to room
    HZNSits:TeleportPlayersToRoom(id, ply)

    -- notify the room
    if (!silent) then
        if (ply != player.GetBySteamID64(room.players[1][1])) then
            HZNSits:Say("You have been added to room #" .. id .. "!", ply)
        end
        HZNSits:NotifyRoom(id, ply:Nick() .. " has been added to the room!", ply)
    end

    -- sync room to client
    HZNSits:SyncRooms()

    for k, v in ipairs(room.players) do
        local ply2 = player.GetBySteamID64(v[1])
        if (ply2) then
            net.Start("HZNSits:ChangeState")
                net.WriteBool(true)
                net.WriteString(ply:UserID())
            net.Send(ply2)
            if (ply != ply2) then
                net.Start("HZNSits:ChangeState")
                    net.WriteBool(true)
                    net.WriteString(ply2:UserID())
                net.Send(ply)
            end
        end
    end
end

function HZNSits:RemovePlayerFromSit(ply)
    if (!ply) then
        HZNSits:Log("[ERROR] Tried removing a null player!")
        return
    end

    local id = ply:HZN_GetRoom()

    if (!id) then
        HZNSits:Say("[ERROR] ".. (ply:Nick() or "") .." tried to remove a player from a room that doesn't exist!", ply)
        return
    end

    local room = HZNSits:GetRoom(id)

    if (!room) then
        HZNSits:Say("[ERROR] ".. (ply:Nick() or "") .." tried to remove a player from a room that doesn't exist!", ply)
        return
    end

    -- teleport player back to where they were
    if (ply:IsValid()) then
        HZNSits:ReturnPlayersFromRoom(id, ply)
    end

    -- update room data
    for k, v in ipairs(room.players) do
        if (v[1] == ply:SteamID64()) then
            table.remove(room.players, k)
            break
        end
    end
    HZNSits.rooms[room.id] = room
    ply:SetNWBool("HZN_IsInRoom", false)
    ply:SetNWInt("HZN_RoomID", 0)

    -- notify the room
    HZNSits:Say("You have been removed from room #" .. room.id .. "!", ply)
    HZNSits:NotifyRoom(room.id, ply:Nick() .. " has been removed from the room!", ply)

    -- sync room to server
    HZNSits:SyncRooms()
    
    // notify room
    for k, v in ipairs(room.players) do
        local ply2 = player.GetBySteamID64(v[1])
        if (ply2) then
            net.Start("HZNSits:ChangeState")
                net.WriteBool(false)
                net.WriteString(ply:UserID())
            net.Send(ply2)
        end
    end

    if (ply:IsConnected()) then
        // notify removed player
        net.Start("HZNSits:ChangeState")
            net.WriteBool(false)
            net.WriteString(ply:UserID())
        net.Send(ply)
    end
end

function HZNSits:EndSit(id)
    if (!id) then
        HZNSits:Log("[ERROR] Tried ending a null room")
        return false
    end

    local room = HZNSits:GetRoom(id)

    if (!room) then
        HZNSits:Log("[ERROR] Room #" .. id .. " doesn't exist!")
        return false
    end

    for k,v in ipairs(room.players) do
        local ply = player.GetBySteamID64(v[1])
        if (!ply) then continue end

        ply:SetNWBool("HZN_IsInRoom", false)
        ply:SetNWInt("HZN_RoomID", 0)
    end

    // teleport players back to where they were
    HZNSits:ReturnPlayersFromRoom(id)

    // reset room
    HZNSits:ResetRoom(id)

    return true
end

function HZNSits:IsSitAdmin(ply)
    local id = ply:HZN_GetRoom()
    local room = HZNSits:GetRoom(id)

    if (!room) then return false end

    if (room.players[1][1] == ply:SteamID64()) then
        return true
    end

    return false
end

function HZNSits:StartSitWithPlayer(admin, ply)
    local roomid = HZNSits:StartSit(admin)
    HZNSits:AddPlayerToSit(ply, roomid)
    return roomid
end
