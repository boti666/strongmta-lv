Config = {}

Config.animatedLightsVehicles = {}

Config.customAnimatedVehicles = {
    [602] = {
        leftIndicator = "audi_turn_left_",
        rightIndicator = "audi_turn_right_",
        rear = "shader_rear"
    },

    [485] = {
        leftIndicator = "audi_turn_left_",
        rightIndicator = "audi_turn_right_"
    },
}

for k, v in pairs(Config.customAnimatedVehicles) do
    Config.animatedLightsVehicles[k] = true
end

Config.defaultLightColor = {1, 0.5, 0}
Config.defaultLightBrightness = 0.35

CustomLights = {}

Config.defaultLights = {
    {name = "turn_left", color = { 1, 0.5, 0}},
    {name = "turn_right", color = { 1, 0.5, 0}},
    {name = "rear", color = {0.8, 0.8, 0.8}},
    {name = "brake", color = { 1, 0, 0}},
    {name = "front", color = {1, 1, 1}, noShader = false},
}

Config.defaultStrobes = {
    {name = "strobe_b", brightness = 1, color = {0, 0, 1}},
    {name = "strobe_r", brightness = 1, color = {1, 0, 0}},
    {name = "strobe_w", brightness = 1, color = {1, 1, 1}},
}

Config.turnDisableTime = 1200

Config.defaultTurnLightsInterval = 0.5

function table.copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.copy(orig_key)] = table.copy(orig_value)
        end
        setmetatable(copy, table.copy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function isVehicleMovingBackwards(vehicle)
    if vehicle.velocity.length < 0.05 then
        return false, false
    end

    local direction = vehicle.matrix.forward
    local velocity = vehicle.velocity.normalized

    local dot = direction.x * velocity.x + direction.y * velocity.y
    local det = direction.x * velocity.y - direction.y * velocity.x

    local angle = math.deg(math.atan2(det, dot))
    return math.abs(angle) > 120, true
end

local sendData = {}
local sendTimers = {}

local function slowSend(actionGroup)
    if (sendData[actionGroup]) then
        setElementData(unpack(sendData[actionGroup]))
        sendData[actionGroup] = nil
    end
end

function antiDOSsend(actionGroup, pause, ...)
    if isTimer(sendTimers[actionGroup]) then
        sendData[actionGroup] = {...}
    else
        setElementData(...)
        sendData[actionGroup] = false
        sendTimers[actionGroup] = setTimer(slowSend, pause, 1, actionGroup)
    end
end
