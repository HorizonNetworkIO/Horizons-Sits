HZNSits.PlayersOnDuty = {}

local meta = FindMetaTable("Player")

function meta:HZN_OnDuty()
    if (not HZNSits:IsStaff(self)) then return false end
    return self:GetNWBool("HZN_OnDuty", false)
end

function HZNSits:SetDuty(ply, onduty)
    if (not HZNSits:IsStaff(ply)) then return false end

    HZNSits:Say("You are now " .. (onduty and ("on duty!") or ("off duty! Your duty time is " .. os.date("!%H:%M:%S", HZNSits:GetDutyTime(ply)) .. ".")), ply)

    if (onduty) then
        ply:GodEnable()
        ply.sam_has_god_mode = true
        ply:SetNWBool("HasGodMode", true)

        table.insert(HZNSits.PlayersOnDuty, ply)

        ply:SetNWBool("HZN_OnDuty", true)
        ply:SetNWInt("HZN_LastOnDuty", os.time())
    else
        ply:SetMoveType(MOVETYPE_WALK) // disable nocliping

        local lastOnDuty = ply:GetNWInt("HZN_LastOnDuty", 0)
        local dutyTime = os.difftime(os.time(), lastOnDuty)

        table.RemoveByValue(HZNSits.PlayersOnDuty, ply)

        ply:GodDisable()
        ply:SetNWBool("HasGodMode", false)
        ply.sam_has_god_mode = false

        local reward = HZNSits.DutyReward * (dutyTime/60)

        if reward > 0 then
            ply:addMoney(reward)
            HZNSits:Say("You have been rewarded $" .. reward .. " for your duty time.", ply)
        end

        ply:SetNWBool("HZN_OnDuty", false)
    end
end

function HZNSits:GetDutyTime(ply)
    if (not HZNSits:IsStaff(ply)) then return false end

    local lastOnDuty = ply:GetNWInt("HZN_LastOnDuty", 0)
    local dutyTime = os.difftime(os.time(), lastOnDuty)

    return dutyTime
end

hook.Add("PlayerSay", "HZNSits:PlayerSayDuty", function(ply, text)
    if (string.lower(text) == "!duty") then
        HZNSits:SetDuty(ply, not ply:HZN_OnDuty())
        return ""
    end
end)