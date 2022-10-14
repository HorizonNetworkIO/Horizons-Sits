function HZNSits:SaveData()
    if (!file.Exists("hznsits", "DATA")) then
        HZNSits:Log("Setting up data for first time use...")

        file.CreateDir("hznsits")

        file.Write("hznsits/rooms.txt", "")
    end

    local roomData = {}
    for k,v in ipairs(HZNSits.rooms) do
        table.insert(roomData, {
            position = v.position,
            angle = v.angle,
        })
    end

    if (#roomData > 0) then
        local jsonData = util.TableToJSON(roomData)
        file.Write("hznsits/rooms.txt", jsonData)
    end

    HZNSits:Log("Data Saved!")
end

function HZNSits:LoadData()
    if (!file.Exists("hznsits", "DATA")) then
        HZNSits:Log("No data found!")
        HZNSits:SaveData()
        return
    end

    local jsonData = file.Read("hznsits/rooms.txt", "DATA")
    if (!jsonData) then
        HZNSits:Log("No data found!")
        HZNSits:SaveData()
        return
    end

    local roomData = util.JSONToTable(jsonData)
    if (!roomData) then
        HZNSits:Log("No data found!")
        HZNSits:SaveData()
        return
    end

    for k,v in ipairs(roomData) do
        local room = HZNSits:AddRoom(v.position, v.angle)
        HZNSits:Log("Added room #" .. k) 
    end

    HZNSits:Log("Data Loaded!")
end