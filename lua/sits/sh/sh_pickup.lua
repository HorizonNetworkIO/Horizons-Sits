local function freeze_player(ply)
    if SERVER then
        ply:Lock()
    end
    ply:SetMoveType(MOVETYPE_NONE)
    ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

local players_pickup = {}
hook.Add("Think", "HZNSits:ThinkPickup", function()
    for _, group in pairs(players_pickup) do
        if (!IsValid(group.ply) or !IsValid(group.target)) then
            table.remove(players_pickup, _)
            continue
        end
        if group.ply:KeyPressed(IN_RELOAD) then
            if (group.ply:GetActiveWeapon() != nil) then
                if (group.ply:GetActiveWeapon():GetClass() == "weapon_physgun") then
                    group.target:ForcePlayerDrop()
                end
            end

            if SERVER then
                if (group.target:HZN_IsInRoom() and group.target:HZN_GetRoom() != group.ply:HZN_GetRoom()) then // target is in a room, not this room
                    sam.player.send_message(group.ply, "{A} is in a room!", {
                        A = group.target
                    })
                    return
                elseif (group.target:HZN_GetRoom() == group.ply:HZN_GetRoom() and HZNSits:IsSitAdmin(group.ply)) then // target is in room as admin, and ply is sit admin
                    HZNSits:RemovePlayerFromSit(group.target)
                elseif (!group.target:HZN_IsInRoom()) then
                    if (group.ply:HZN_IsInRoom()) then // ply is in room
                        roomid = group.ply:HZN_GetRoom()
                        if (roomid) then
                            HZNSits:AddPlayerToSit(group.target, roomid, true, group.ply)
                        end
                    else
                        roomid = HZNSits:StartSit(group.ply)
                        if (roomid) then
                            HZNSits:AddPlayerToSit(group.target, roomid, true, group.ply)
                            newRoom = true
                        end
                    end
                end
            end
            table.remove(players_pickup, _)
        end
    end
end)

timer.Create("HZNSits:PhygunUpdate", 5, 1, function()
	sam.hook_first("PhysgunPickup", "SAM.CanPhysgunPlayer", function(ply, target)
		if sam.type(target) == "Player" and ply:HasPermission("can_physgun_players") and ply:CanTarget(target) and ply:HZN_OnDuty() then
			freeze_player(target)
            players_pickup[#players_pickup + 1] = {ply=ply, target=target}
			return true
		end
	end)

    hook.Remove("PhysgunDrop", "SAM.PhysgunDrop")

    local right_click_to_freeze = sam.config.get("Physgun.RightClickToFreeze", true)
    local reset_velocity = sam.config.get("Physgun.ResetVelocity", true)
    hook.Add("PhysgunDrop", "HZNSits:PhysgunDrop", function(ply, target)
        if sam.type(target) ~= "Player" then return end

        if sam.config.get("Physgun.Enabled", true) == false then
			return
		end

        for k,v in pairs(players_pickup) do
            if v.target == target then
                table.remove(players_pickup, k)
            end
        end

        if right_click_to_freeze and ply:KeyPressed(IN_ATTACK2) then
            freeze_player(target)

            if SERVER then
                target:sam_set_nwvar("frozen", true)
                target:sam_set_exclusive("frozen")
            end
        else
            if reset_velocity then
                target:SetLocalVelocity(Vector(0, 0, 0))
            end

            if SERVER then
                target:UnLock()
                target:sam_set_nwvar("frozen", false)
                target:sam_set_exclusive(nil)

                if target.sam_has_god_mode then
                    target:GodEnable()
                end

                target.sam_physgun_drop_was_frozen = not target:IsOnGround()
            end

            target:SetMoveType(MOVETYPE_WALK)
            target:SetCollisionGroup(COLLISION_GROUP_PLAYER)

            if target:HZN_IsInRoom() then
                target:SetCollisionGroup(COLLISION_GROUP_WORLD)
            end
        end
    end)
end)