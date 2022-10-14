HZNSits.rooms = {}

function HZNSits:AddRoom(position, angle)
    local room = {
        id = #HZNSits.rooms + 1,
        position = position,
        angle = angle,
        players = {},
    }

    table.insert(HZNSits.rooms, room)
    HZNSits:SyncRooms()
    HZNSits:SaveData()

    return room.id
end

function HZNSits:RemoveRoom(id)
    table.remove(HZNSits.rooms, id)
    HZNSits:SyncRooms()
    HZNSits:SaveData()
end

util.AddNetworkString("HZNSits:AskClientForStatus")
util.AddNetworkString("HZNSits:SendStatusToServer")
function HZNSits:CheckRoomStatus(id)
    local room = HZNSits.rooms[id]

    if (!room) then
        HZNSits:Log("[ERROR] Failed to check room's status #" .. id)
        return
    end

    for k,v in ipairs(room.players) do
        local ply = player.GetBySteamID64(v[1])
        if (ply) then
            net.Start("HZNSits:AskClientForStatus")
            net.Send(ply)
        end
    end
end

net.Receive("HZNSits:SendStatusToServer", function(len, ply)
    local isFocused = net.ReadBool()
    ply:SetNWBool("HZNSits:IsFocused", isFocused)
end)

function HZNSits:ResetRoom(id)
    local room = HZNSits.rooms[id]
    
    if (!room) then
        HZNSits:Log("[ERROR] Failed to reset room #" .. id)
        return
    end

    for k, v in ipairs(room.players) do
        local ply = player.GetBySteamID64(v[1])
        if (ply) then
            net.Start("HZNSits:ChangeState")
                net.WriteBool(false)
                net.WriteString(ply:UserID())
            net.Send(ply)
        end
    end

    room.players = {}

    timer.Remove("HZNSits:SitStatusUpdate" .. id)

    HZNSits.rooms[id] = room
    HZNSits:SyncRooms()
end

function HZNSits:GetRoom(id)
    return HZNSits.rooms[id]
end

function HZNSits:SendNetToRoom(id)
    local room = HZNSits:GetRoom(id)

    if (!room) then
        HZNSits:Log("[ERROR] Failed to send net to room #" .. id)
        return
    end

    for k, v in ipairs(room.players) do
        local ply = player.GetBySteamID64(v[1])
        print("Sending net to " .. ply:Nick())
        if (ply) then
            net.Send(ply)
        end
    end
end

function HZNSits:IsRoomReady(id)
    local room = HZNSits:GetRoom(id)

    if room then
        if room.players then
            return #room.players == 0
        end
    end

    return false
end

function HZNSits:InSameRoom(ply1, ply2)
    if (!ply1:HZN_IsInRoom() and !ply2:HZN_IsInRoom()) then
        return true
    elseif (ply1:HZN_IsInRoom() and ply2:HZN_IsInRoom()) then
        return ply1:HZN_GetRoom() == ply2:HZN_GetRoom()
    end

    return false
end

function HZNSits:GetRandomRoom()
    local random = math.random(#HZNSits.rooms)
    local room = HZNSits:GetRoom(random)
    if (room) then
        if (HZNSits:IsRoomReady(random)) then
            return room.id
        else
            return HZNSits:GetRandomRoom()
        end
    else
        HZNSits:Log("No room found!")
        return
    end
end

function HZNSits:TeleportPlayersToRoom(id, ply)
    print("Teleporting players to room #" .. id)

    local room = HZNSits:GetRoom(id)

    if (!room) then
        HZNSits:Log("[HZNSits] Cannot teleport player to room. Room not found!")
        return
    end

    local position = room.position
    local angle = room.angle

    // are we teleporting a player or a table of players?
    if (ply) then
        ply:SetPos(position)
        ply:SetEyeAngles(angle)
        -- no collisions with other players
        ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        if (!HZNSits:IsSitAdmin(ply)) then
            ply:Give("weapon_handcuffed")
            ply:GetWeapon("weapon_handcuffed").GetIsUnbreakable = function() return true end
        end
    else
        for _, plyTbl in pairs(room.players) do
            local ply2 = player.GetBySteamID64(plyTbl[1])
            if (!ply2) then continue end

            ply2:SetPos(position)
            ply2:SetEyeAngles(angle)
            ply2:SetCollisionGroup(COLLISION_GROUP_WEAPON)
            if (!HZNSits:IsSitAdmin(ply)) then
                ply2:Give("weapon_handcuffed")
                ply2:GetWeapon("weapon_handcuffed").GetIsUnbreakable = function() return true end
            end
        end
    end
end

function HZNSits:ReturnPlayersFromRoom(id, ply)
    local room = HZNSits:GetRoom(id)

    // are we returning a single player or a table of players?
    if (ply) then
        for k, v in ipairs(room.players) do
            if (v[1] == ply:SteamID64()) then
                ply:SetPos(v[2])
                ply:SetEyeAngles(v[3])
                ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
                if (ply:GetWeapon("weapon_handcuffed"):IsValid()) then
                    ply:GetWeapon("weapon_handcuffed"):Remove()
                end
                break
            end
        end
    else
        for _, plyTbl in pairs(room.players) do
            local ply2 = player.GetBySteamID64(plyTbl[1])
            if (!ply2) then 
                HZNSits:Log("Cannot return player from room. Player not found: " .. (plyTbl[1] or ""))
                continue
            end
    
            ply2:SetPos(plyTbl[2])
            ply2:SetEyeAngles(plyTbl[3])
            ply2:SetCollisionGroup(COLLISION_GROUP_PLAYER)
            if (ply2:GetWeapon("weapon_handcuffed"):IsValid()) then
                ply2:GetWeapon("weapon_handcuffed"):Remove()
            end
        end
    end
end

function HZNSits:NotifyRoom(id, msg, exception)
    local room = HZNSits:GetRoom(id)

    if (!room) then
        HZNSits:Log("Cannot notify room. Room not found!")
        return
    end

    for k,v in ipairs(room.players) do
        local ply = player.GetBySteamID64(v[1])
        if (!ply) then continue end
        if (ply == exception) then continue end

        HZNSits:Say(msg, ply)
    end
end

util.AddNetworkString("HZNSits:SyncRooms")
function HZNSits:SyncRooms(ply)
    net.Start("HZNSits:SyncRooms")
        net.WriteTable(HZNSits.rooms)
    if (ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

util.AddNetworkString("HZNSits:EditRoom")
net.Receive("HZNSits:EditRoom", function(len, ply)
    if (!HZNSits:HasAuthority(ply)) then return end

    local addRoom = net.ReadBool()

    if (addRoom) then
        local roomid = HZNSits:AddRoom(ply:GetPos(), ply:GetAngles())
        HZNSits:Say("Added room #" .. roomid, ply)
    else
        local roomid = net.ReadUInt(8)
        HZNSits:RemoveRoom(roomid)
        HZNSits:Say("Removed room #" .. roomid, ply)
    end
end)

util.AddNetworkString("HZNSits:JoinSit")
net.Receive("HZNSits:JoinSit", function(len, ply)
    if (!HZNSits:HasAuthority(ply)) then 
        RunConsoleCommand("sam", "banid", ply:SteamID(), "0", "Exploiting Staff Sit System.")
    end

    local roomid = net.ReadUInt(8)

    if (!HZNSits:IsRoomReady(roomid) and ply:HZN_GetRoom() != roomid) then
        HZNSits:AddPlayerToSit(ply, roomid)
    else
        HZNSits:Say("Failed to add player to sit. Room is empty or already in room!", ply)
    end
end)