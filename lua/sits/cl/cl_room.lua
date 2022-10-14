HZNSits.rooms = HZNSits.rooms or {}

net.Receive("HZNSits:SyncRooms", function()
    HZNSits.rooms = net.ReadTable()
end)

net.Receive("HZNSits:ChangeState", function()
    local addingPlayer = net.ReadBool()
    local plyid = net.ReadString()
    plyid = tonumber(plyid)

    if (addingPlayer) then
        hook.Run("HZNSits:PlayerJoinedSit", plyid)
    else
        hook.Run("HZNSits:PlayerLeftSit", plyid)
    end
end)

net.Receive("HZNSits:AskClientForStatus", function()
    local isFocused = system.HasFocus()
    net.Start("HZNSits:SendStatusToServer")
        net.WriteBool(isFocused)
    net.SendToServer()
end)

concommand.Add("hznsits_addroom", function(ply)
    if !HZNSits:HasAuthority(ply) then return end

    net.Start("HZNSits:EditRoom")
        net.WriteBool(true)
    net.SendToServer()
end)

concommand.Add("hznsits_getrooms", function(ply)
    if !HZNSits:HasAuthority(ply) then return end

    local str = ""

    for k,v in ipairs(HZNSits.rooms) do
        if (k == #HZNSits.rooms) then
            str = str .. k
        else
            str = str .. k .. ", "
        end
    end
end)

concommand.Add("hznsits_removeroom", function(ply, cmd, args)
    if !HZNSits:HasAuthority(ply) then return end
    
    local roomid = tonumber(args[1])

    if !roomid then 
        HZNSits:Say("Invalid room id.")
        return
    end

    net.Start("HZNSits:EditRoom")
        net.WriteBool(false)
        net.WriteUInt(roomid, 8)
    net.SendToServer()
end)