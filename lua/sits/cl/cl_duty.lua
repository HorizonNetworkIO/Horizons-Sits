local meta = FindMetaTable("Player")

function meta:HZN_OnDuty()
    return self:GetNWBool("HZN_OnDuty", false)
end