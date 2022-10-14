local meta = FindMetaTable("Player")

if SERVER then 
    util.AddNetworkString("HZNSits:Say") 
else
    net.Receive("HZNSits:Say", function()
        local msg = net.ReadString()
        HZNSits:Say(msg)
    end)
end
function HZNSits:Say(msg, ply)
    if (CLIENT) then
        chat.AddText(Color(242, 62, 42), "[Sits] ", Color(255, 255, 255), msg)
    else
        net.Start("HZNSits:Say")
            net.WriteString(msg)
        net.Send(ply)
    end
end

function HZNSits:HasAuthority(ply)
    return ply:IsValid() and ply:IsPlayer() and ply:HasPermission("sit")
end

function meta:HZN_IsInRoom()
    return self:GetNWBool("HZN_IsInRoom", false)
end

function meta:HZN_IsFocused()
    return self:GetNWBool("HZNSits:IsFocused", false)
end

function meta:HZN_GetRoom()
    return self:GetNWInt("HZN_RoomID", 0)
end

function HZNSits:IsStaff(ply)
    return HZNSits.StaffRanks[ply:sam_getrank()]
end
