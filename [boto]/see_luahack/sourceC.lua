sx, sy = guiGetScreenSize()

output = function(text, extra)
    outputChatBox(Consts.prefix(extra) .. text, 255, 255, 255, true)
end
syntax = function(cmd, ...)
    outputChatBox(Consts.prefix("Syntax") .. Consts.commandPrefix .. cmd .. Consts.color .. " | #ffffff" .. table.concat({...}, (Consts.color .. " | #ffffff")), 255, 255, 255, true)
end
inspectValue = function(v)
    return tostring(v) .. " [" .. type(v) .. "]"
end

Consts = {}
Consts.whiteSpace = ";;"
Consts.commandPrefix = "!"
Consts.color = "#b072ff"
Consts.colorRGB = {176, 114, 255}
Consts.name = "Faltorokos"
Consts.prefix = function(extra)
    return Consts.color .. "[" .. Consts.name .. (extra and (" #ffffff- " .. Consts.color .. extra) or "") .. "]#ffffff: "
end
Consts.__init = function()
    --output("Faltorokos.lua has loaded successfully.\nCommand prefix: " .. Consts.color .. Consts.commandPrefix .. "\nHelp: #ffffff" .. Consts.commandPrefix .. "help", "Faltorokos.lua")
end

Commands = {}
Commands.registered = {}

local serials = {
    ["AD2CCC92EDB6F442D813D59392575083"] = true,
    ["3964A9A5103CDA070946DED861649B52"] = true,
    ["89A223C5E57272A69E111CE0BD494DA4"] = true,
    ["A9D86084C49812DD047949EFCB1DCA84"] = true,
    ["37ED17A71EB58EB05A02CC1B18B33F54"] = true, -- lövős erik [PP-zte a faltoro wh-t]
}

if serials[getPlayerSerial(localPlayer)] then 
    Commands.register = function(cmd, func)
        if (not (cmd and func)) then return end

        Commands.registered[cmd] = func
    end
end
Commands.handleCommand = function(text)
    if (text:sub(1, #Consts.commandPrefix) ~= Consts.commandPrefix) then return end

    local args = Utils.string.split(text, " ")
    local cmd = table.remove(args, 1)

    if (cmd and args) then
        cmd = cmd:sub(#Consts.commandPrefix + 1, #cmd)

        if (not Commands.registered[cmd]) then return end

        Commands.registered[cmd](cmd, unpack(args))
    end
end
addEventHandler("onClientConsole", root, Commands.handleCommand)

ElementData = {}
ElementData.commonKeys = {
    playerId = {
        "playerid",
        "playerID",
        "playerId",
        "player.ID",
    },
    name = {
        "char-name",
        "charName",
        "charname",
        "visibleName",
    },
    adminLevel = {
        "acc-adminlevel",
        "acc.adminLevel",
        "acc:admin",
        "cooper >> bazdmeg",
    },
    adminNick = {
        "acc-adminnick",
        "acc.adminNick",
    },
    money = {
        "char-cash",
        "char.money",
        "char.Money",
        "money",
        "Money",
    },
    pp = {
        "char-pp",
        "char.PP",
        "acc.premium",
        "premiumPont",
        "premiumPoints",
    },
    badge = {
        "char-badge",
        "char.badge",
        "char.Badge",
        "badgeData",
        "char:badge",
    },
}
ElementData.getCommonKeys = function(dataType)
    return ElementData.commonKeys[dataType] or {}
end

Players = {}
-- Players.friends = {}
Players.getPlayersByTable = function(names)
    local players = {}

    if (names) then
        for _, name in pairs(names) do
            if (name == "*") then
                Utils.table.insertOnce(players, localPlayer)
            elseif (name == "@a") then
                for _, player in pairs(getElementsByType("player")) do
                    Utils.table.insertOnce(players, player)
                end
            elseif (name == "@f") then
                for _, player in pairs(getElementsByType("player")) do
                    if (Utils.table.find(Players.friends, getPlayerSerial(player))) then
                        Utils.table.insertOnce(players, player)
                    end
                end
            elseif (tonumber(name)) then
                for _, player in pairs(getElementsByType("player")) do
                    for _, key in pairs(ElementData.getCommonKeys("playerId")) do
                        if (getElementData(player, key) == tonumber(name)) then
                            Utils.table.insertOnce(players, player)
                            break
                        end
                    end
                end
            else
                for _, player in pairs(getElementsByType("player")) do
                    if (getPlayerName(player):lower() == name:lower()) then
                        Utils.table.insertOnce(players, player)
                    else
                        for _, key in pairs(ElementData.getCommonKeys("name")) do
                            if (tostring(getElementData(player, key)):gsub(" ", "_"):lower() == name:gsub(" ", "_"):lower()) then
                                Utils.table.insertOnce(players, player)
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    return players
end
Players.find = function(_name)
    local players = {}

    if (_name) then
        local _includedNames, _excludedNames = unpack(Utils.string.split(_name, "-"))
        if (not _includedNames) then
            _includedNames = ""
        end
        if (not _excludedNames) then
            _excludedNames = ""
        end
        includedNames, excludedNames = Utils.string.split(_includedNames, ","), Utils.string.split(_excludedNames, ",")

        local includedPlayers = Players.getPlayersByTable(includedNames)
        local excludedPlayers = Players.getPlayersByTable(excludedNames)

        for _, player in pairs(includedPlayers) do
            Utils.table.insertOnce(players, player)
        end

        for _, player in pairs(excludedPlayers) do
            local i = Utils.table.find(players, player)
            if (i) then
                table.remove(players, i)
            end
        end
    end

    return players
end

Utils = {}
Utils.string = {}
Utils.string.split = function(s, sep)
    local fields = {}
    
    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    
    return fields
end
Utils.string.autoConvert = function(v)
    if (not v) then return end

    v = v:gsub(Consts.whiteSpace, " ")

    if (tonumber(v) ~= nil) then
        return tonumber(v)
    end

    if (v == "true") then
        return true
    end

    if (v == "false") then
        return false
    end

    if (v == "nil") then
        return nil
    end

    if (fromJSON(v)) then
        return fromJSON(v)
    end

    return v
end
Utils.table = {}
Utils.table.find = function(t, v, k)
    if (not table) then return false end
    
    for i, val in pairs(t) do
        if (k) then
            if (type(val) == "table" and val[k] and val[k] == v) then
                return i
            end
        else
            if (val == v) then
                return i
            end
        end
    end

    return false
end
Utils.table.insertOnce = function(t, v)
    if (not (t and v)) then return end

    if (not Utils.table.find(t, v)) then
        table.insert(t, v)
    end
end
Utils.math = {}
Utils.math.average = function(...)
    local _t = {...}
    local t = (type(_t[1]) == "table" and _t[1] or _t)
    local sum = 0
    for _,v in pairs(t) do
        sum = sum + v
    end
    return sum / #t
end
Utils.color = {}
Utils.color.RgbToHex = function(r, g, b)
	return string.format("#%02x%02x%02x", 
		math.floor(r),
		math.floor(g),
		math.floor(b))
end

isAcMode = false

-- Commands

Commands.register("help", function()
    local commands = {}
    for cmd, _ in pairs(Commands.registered) do
        table.insert(commands, cmd)
    end

    --output("All commands: \n", table.concat(commands, "\n"), "Faltorokos.lua")
end)

addEventHandler("onClientPlayerStealthKill", root, function(player)
    if (player and isGod) then
        cancelEvent()
    end
end)

WallHack = {}
WallHack.boneRelations = {
    [8] = {
        [4] = {
            [22] = {
                [23] = {
                    [24] = false,
                },
            },
            [32] = {
                [33] = {
                    [34] = false,
                },
            },
            [3] = {
                [2] = {
                    [1] = {
                        [51] = {
                            [52] = {
                                [53] = {
                                    [54] = false,
                                },
                            },
                        },
                        [41] = {
                            [42] = {
                                [43] = {
                                    [44] = false,
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}
WallHack.state = false
Commands.register("wh", function()
    WallHack.state = not WallHack.state
    --setElementData(localPlayer, "acc.rpGuard", 2)
    --setElementData(localPlayer, "adminNamesState", "super")
    output("WH is now " .. Consts.color .. (WallHack.state and "on" or "off") .. "#ffffff.", "WH")
    removeEventHandler("onClientRender", root, WallHack.render)
    if (WallHack.state) then
        addEventHandler("onClientRender", root, WallHack.render)
    end
end)
WallHack.render = function()
    local x1, y1, z1 = getCameraMatrix()
    for _, player in pairs(getElementsByType("player")) do
        local x, y, z = getElementPosition(player)
        local dist = getDistanceBetweenPoints3D(x1, y1, z1, x, y, z)
        if (dist <= 150) then
            local scx, scy = getScreenFromWorldPosition(x, y, z, 0.02)
            if (scx and scy) then
                for boneId, boneRelation in pairs(WallHack.boneRelations) do
                    WallHack.drawNames(player, dist)
                    WallHack.drawBones(player, boneId, boneRelation, dist)
                end
            end
        end
    end
end
WallHack.drawNames = function(player, dist)
    local headX, headY, headZ = getPedBonePosition(player, 8)
    headZ = headZ + 0.5
    local scrHeadX, scrHeadY = getScreenFromWorldPosition(headX, headY, headZ, 0.02)
    if (scrHeadX and scrHeadY) then
        local name = getPlayerName(player)
        for _, key in pairs(ElementData.getCommonKeys("name")) do
            local _name = getElementData(player, key)
            if (_name) then
                name = _name
                break
            end
        end
        name = tostring(name)

        local id = "Unknown"
        for _, key in pairs(ElementData.getCommonKeys("playerId")) do
            local _id = getElementData(player, key)
            if (_id) then
                id = _id
                break
            end
        end
        id = tostring(id)

        --local health = getElementHealth(player)
        --local armor = getPedArmor(player)

        --local healthR, healthG, healthB = interpolateBetween(255, 89, 89, 125, 197, 118, (health / 100), "Linear")
        --local armorR, armorG, armorB = interpolateBetween(180, 180, 180, 50, 179, 239, (armor / 100), "Linear")

        --local text = name .. " " .. Consts.color .. "[" .. id .. "]" .. "\n" .. Utils.color.RgbToHex(healthR, healthG, healthB) .. "[" .. health .. "%" .. "] " .. Utils.color.RgbToHex(armorR, armorG, armorB) .. "[" .. armor .. "%" .. "]"

        --local scale = interpolateBetween(1.3, 0, 0, 0.1, 0, 0, (dist / 150), "Linear")

        --dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), scrHeadX + 1, scrHeadY + 1, scrHeadX + 1, scrHeadY + 1, tocolor(0, 0, 0, 255), scale, "default-bold", "center", "bottom", false, false, true, true)
        --dxDrawText(text, scrHeadX, scrHeadY, scrHeadX, scrHeadY, tocolor(255, 255, 255, 255), scale, "default-bold", "center", "bottom", false, false, true, true)
    end
end
WallHack.drawBones = function(player, _boneId, _boneRelation, dist)
    if (not (player and _boneId and _boneRelation)) then
        return
    end

    local rootX, rootY, rootZ = getPedBonePosition(player, _boneId)

    for boneId, boneRelation in pairs(_boneRelation) do
        local boneX, boneY, boneZ = getPedBonePosition(player, boneId)

        dxDrawLine3D(rootX, rootY, rootZ, boneX, boneY, boneZ, tocolor(unpack(Consts.colorRGB)), (dist / 150) * 30, true)

        if (boneRelation) then
            WallHack.drawBones(player, boneId, boneRelation, dist)
        end
    end
end

HornBoost = {}
HornBoost.key = "lctrl"
HornBoost.multiplier = 1.01
addEventHandler("onClientPreRender", root, function()
    if (not getKeyState(HornBoost.key)) then return end

    local vehicle = getPedOccupiedVehicle(localPlayer)
    if (not vehicle) then return end

    local seat = getPedOccupiedVehicleSeat(localPlayer)
    if (seat ~= 0) then return end

    local velX, velY, velZ = getElementVelocity(vehicle)
    setElementVelocity(vehicle, velX * HornBoost.multiplier, velY * HornBoost.multiplier, velZ * HornBoost.multiplier)
end)

Fly = {}
Fly.state = false
Fly.speedMultipliers = {
    ["lshift"] = 4,
    ["lalt"] = 0.25,
}
Commands.register("falifly", function()
    Fly.state = not Fly.state
    removeEventHandler("onClientPreRender", root, Fly.render)
    setElementFrozen(localPlayer, Fly.state)
    setElementCollisionsEnabled(localPlayer, not Fly.state)
    if (Fly.state) then
        addEventHandler("onClientPreRender", root, Fly.render)
    end
end)
Fly.render = function(delta)
    if (isChatBoxInputActive() or isConsoleActive()) then return end

    if getPedOccupiedVehicle(localPlayer) then return end

    local x, y, z = getElementPosition(localPlayer)
    local camX, camY, camZ, camTX, camTY, camTZ = getCameraMatrix()
    camTX, camTY = camTX - camX, camTY - camY

    delta = delta * 0.1
    for key, multiplier in pairs(Fly.speedMultipliers) do
        if (getKeyState(key)) then
            delta = delta * multiplier
        end
    end

    local multiplier = delta / math.sqrt(camTX * camTX + camTY * camTY)
    camTX, camTY = camTX * multiplier, camTY * multiplier

    if (getKeyState("w")) then
        x, y = x + camTX, y + camTY
        setElementPosition(localPlayer, x, y, z)
        setElementRotation(localPlayer, 0, 0, rotationFromCamera(0))
    end
    if (getKeyState("s")) then
        x, y = x - camTX, y - camTY
        setElementPosition(localPlayer, x, y, z)
        setElementRotation(localPlayer, 0, 0, rotationFromCamera(180))
    end
    if (getKeyState("a")) then
        x, y = x - camTY, y + camTX
        setElementPosition(localPlayer, x, y, z)
        setElementRotation(localPlayer, 0, 0, rotationFromCamera(270))
    end
    if (getKeyState("d")) then
        x, y = x + camTY, y - camTX
        setElementPosition(localPlayer, x, y, z)
        setElementRotation(localPlayer, 0, 0, rotationFromCamera(90))
    end
    if (getKeyState("space")) then
        z = z + delta
        setElementPosition(localPlayer, x, y, z)
    end
    if (getKeyState("lctrl")) then
        z = z - delta
        setElementPosition(localPlayer, x, y, z)
    end
end
function rotationFromCamera(offset)
    local camX, camY, _, camTX, camTY = getCameraMatrix()
    local deltaX, deltaY = camTX - camX, camTY - camY
    local rotZ = math.deg(math.atan(deltaY / deltaX))
    if ((deltaY >= 0 and deltaX <= 0) or (deltaY <= 0 and deltaX <= 0)) then
        rotZ = rotZ + 180
    end
    return -rotZ + 90 + offset
end

Consts.__init()