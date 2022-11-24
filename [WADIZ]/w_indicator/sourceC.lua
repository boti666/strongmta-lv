local function makeTurnMirrorFront(model, leftLight, rightLight, frontColor, turnColor)
    if not frontColor then
        frontColor = {1, 1, 1}
    end
    if not turnColor then
        turnColor = {1, 0.5, 0}
    end
    CustomLights[model] = {
        stateHandlers = {
            ["turn_left"] = function (anim, state)
                if state then
                    anim.setLightColor(leftLight.name, unpack(turnColor))
                    
                end
                anim.setLightState(leftLight.name, state)
            end,
            ["turn_right"] = function (anim, state)
                if state then
                    anim.setLightColor(rightLight.name, unpack(turnColor))
                end
                anim.setLightState(rightLight.name, state)
            end,
            ["front"] = function (anim, state)
                if not anim.getLightState("turn_left") then
                    if state then
                        anim.setLightColor(leftLight.name, unpack(frontColor))
                    end
                    anim.setLightState(leftLight.name, state)
                end
                if not anim.getLightState("turn_right") then
                    if state then
                        anim.setLightColor(rightLight.name, unpack(frontColor))
                    end
                    anim.setLightState(rightLight.name, state)
                end
            end
        },

        dataHandlers = {
            ["turn_left"] = function (anim, state)
                if not state and anim.getLightState("front") then
                    anim.setLightColor(leftLight.name, unpack(frontColor))
                    anim.setLightState(leftLight.name, true)
                end
            end,
            ["turn_right"] = function (anim, state)
                if not state and anim.getLightState("front") then
                    anim.setLightColor(rightLight.name, unpack(frontColor))
                    anim.setLightState(rightLight.name, true)
                end
            end,
            ["emergency_light"] = function (anim, state)
                if not state and anim.getLightState("front") then
                    anim.setLightColor(leftLight.name, unpack(frontColor))
                    anim.setLightState(leftLight.name, true)
                    anim.setLightColor(rightLight.name, unpack(frontColor))
                    anim.setLightState(rightLight.name, true)
                end
            end
        },

        lights = {
            leftLight,
            rightLight,
        }
    }
   -- iprint(CustomLights)
end

local customMaterialNameVeh = {
    [402] = {
        left = "leftflash",
        right = "rightflash"
    },

    [475] = {
        left = "leftflash",
        right = "rightflash",
        rear = "shader_rear_0",
        brake = "shader_brake_0"
    },

    

    [602] = {
        rear = "shader_rear"
    },

    [445] = {
        left = "leftflash",
        right = "rightflash",
        rear = "shader_rear"
    },

    [527] = {
        left = "leftflash",
        right = "rightflash",
        rear = "shader_rear"
    },

    [405] = {
        left = "leftflash",
        right = "rightflash",
        rear = "shader_rear"
    },

    [547] = {
        left = "leftflash",
        right = "rightflash",
        rear = "zad_xod"
    },

    [566] = {
        left = "leftflash",
        right = "rightflash",
        --rear = "zad_steklo"
    },

    [401] = {
        left = "leftflash",
        right = "rightflash",
        rear = "shader_rear"
    },

    [411] = {
        left = "leftflash",
        right = "rightflash",
        rear = "shader_rear"
    },

    [587] = {
        left = "leftflash",
        right = "rightflash",
    },

    [426] = {
        left = "leftflash",
        right = "rightflash",
        --rear = "chrom11"
    },

    [517] = {
        left = "leftflash",
        right = "rightflash",
        rear = "shader_rear"
    },

    [579] = {
        left = "leftflash",
        right = "rightflash",
       -- rear = "shader_rear"
    }
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k, v in pairs(customMaterialNameVeh) do
            CustomLights[k] = {
                stateHandlers = {
                    ["turn_left"] = function (anim, state)
                        if state then
                            anim.setLightColor(v.left, 1, 0.5, 0)
                            
                        end
                        anim.setLightState(v.left, state)
                    end,
                    ["turn_right"] = function (anim, state)
                        if state then
                            anim.setLightColor(v.right, 1, 0.5, 0)
                        end
                        anim.setLightState(v.right, state)
                    end,
                    ["rear"] = function (anim, state)
                        if v.rear then
                            if state then
                                anim.setLightColor(v.rear, 1, 0.5, 0)
                            end
                            anim.setLightState(v.rear, state)
                        end
                    end

                },

                lights = {
                    {name = v.left, material = v.left, brightness = 0.7, color = {1, 0.5, 0}},
                    {name = v.right, material = v.right, brightness = 0.7, color = {1, 0.5, 0}},
                    {name = "rear", material = v.rear, brightness = 0.7, color = {1, 1, 1}},
                }
            }
        end

        for k, v in pairs(Config.customAnimatedVehicles) do
            CustomLights[k] = {
                init = function (anim)
                    anim.turnLightsInterval = 0.5
                    anim.rearLightsTime = 0.3
                    anim.rearLightsFadeAfter = 0.38
                end,

                stateHandlers = {
                    ["turn_left"] = function (anim, state)
                        if not state then
                            for i = 1, 4 do
                                anim.setLightState(v.leftIndicator..i, state)
                                anim.setLightColor(v.leftIndicator..i, 1, 0.5, 0)
                            end
                        end
                    end,
                    ["turn_right"] = function (anim, state)
                        if not state then
                            for i = 1, 4 do
                                anim.setLightState(v.rightIndicator..i, state)
                                anim.setLightColor(v.rightIndicator..i, 1, 0.5, 0)
                            end
                        end
                    end
                },

                update = function (anim)
                    if not anim.turnLightsState then
                        return
                    end

                    if anim.turnLightsTime < anim.rearLightsTime then
                        local index = math.floor(anim.turnLightsTime / anim.rearLightsTime * 5)

                        if anim.getLightState("turn_left") then
                            anim.setLightState(v.leftIndicator..index, true)
                        end
                        if anim.getLightState("turn_right") then
                            anim.setLightState(v.rightIndicator..index, true)
                        end
                    elseif anim.turnLightsTime > anim.rearLightsFadeAfter then
                        local progress = 1 - (anim.turnLightsTime - anim.rearLightsFadeAfter)/(0.5 - anim.rearLightsFadeAfter)
                        if anim.getLightState("turn_left") then
                            for i = 0, 4 do
                                anim.setLightColor(v.leftIndicator..i, progress, progress * 0.5, 0)
                            end
                        end
                        if anim.getLightState("turn_right") then
                            for i = 0, 4 do
                                anim.setLightColor(v.rightIndicator..i, progress, progress * 0.5, 0)
                            end
                        end
                    end
                end,

                lights = {
                    {name = v.leftIndicator.."1", material = v.leftIndicator.."1",   brightness = 0.7, color = {1, 0.5, 0}},
                    {name = v.leftIndicator.."2", material = v.leftIndicator.."2",   brightness = 0.7, color = {1, 0.5, 0}},
                    {name = v.leftIndicator.."3", material = v.leftIndicator.."3",   brightness = 0.7, color = {1, 0.5, 0}},
                    {name = v.leftIndicator.."4", material = v.leftIndicator.."4",   brightness = 0.7, color = {1, 0.5, 0}},

                    {name = v.rightIndicator.."1", material = v.rightIndicator.."1", brightness = 0.7, color = {1, 0.5, 0}},
                    {name = v.rightIndicator.."2", material = v.rightIndicator.."2", brightness = 0.7, color = {1, 0.5, 0}},
                    {name = v.rightIndicator.."3", material = v.rightIndicator.."3", brightness = 0.7, color = {1, 0.5, 0}},
                    {name = v.rightIndicator.."4", material = v.rightIndicator.."4", brightness = 0.7, color = {1, 0.5, 0}},
                }
            }
        end
    end
)

--main Indicator Code
local vehicleLightsTable = {}

local function loadVehicleLights(vehicle)
    if not isElement(vehicle) then
        return
    end
    
    local customLights = CustomLights[vehicle.model] or {}

    local lightsList = table.copy(Config.defaultLights)
    if type(customLights.lights) == "table" then
        for i, v in ipairs(customLights.lights) do
            table.insert(lightsList, v)
        end
    end

    vehicleLightsTable[vehicle] = {}
    
    for i, light in ipairs(lightsList) do
        local properties = {}
        properties.state = false
        properties.color = light.color or Config.defaultLightColor
        properties.brightness = light.brightness or Config.defaultLightBrightness

        local shader
        if not light.noShader then
            shader = dxCreateShader("files/shader.fx")
            for name, value in pairs(properties) do
                shader:setValue(name, value)
            end

            local material = light.material or "shader_"..light.name.."_*"
            shader:applyToWorldTexture(material, vehicle)

            if light.colorMul then
                shader:setValue("colorMul", light.colorMul)
            end
        end
        
        vehicleLightsTable[vehicle][light.name] = {
            shader     = shader,
            material   = material,
            properties = properties,
        }
    end

    LightsAnim.addVehicle(vehicle)
end

local function unloadVehicleLights(vehicle)
    if not vehicle or not vehicleLightsTable[vehicle] then
        return
    end

    for name, light in pairs(vehicleLightsTable[vehicle]) do
        if isElement(light.shader) then
            destroyElement(light.shader)
        end
    end

    vehicleLightsTable[vehicle] = nil

    LightsAnim.removeVehicle(vehicle)
end

function setVehicleLightProperty(vehicle, lightName, property, value)
    if not isElement(vehicle) or not lightName or not vehicleLightsTable[vehicle] then
        return false
    end
    local light = vehicleLightsTable[vehicle][lightName]
    if not light then
        return false
    end
    
    light.properties[property] = value

    if isElement(light.shader) then
        return light.shader:setValue(property, value)
    end
    return true
end

function getVehicleLightProperty(vehicle, lightName, property)
    if not isElement(vehicle) or not lightName or not vehicleLightsTable[vehicle] then
        return false
    end
    local light = vehicleLightsTable[vehicle][lightName]
    if not light then
        return false
    end
    return light.properties[property]
end

function hasVehicleLight(vehicle, lightName)
    if not isElement(vehicle) or not lightName or not vehicleLightsTable[vehicle] then
        return false
    end
    return not not vehicleLightsTable[vehicle][lightName]
end

addEventHandler("onClientResourceStart", resourceRoot, function ()
    for i, vehicle in ipairs(getElementsByType("vehicle"), getRootElement(), true) do
        if isElementStreamedIn(vehicle) then
            loadVehicleLights(vehicle)
        end
    end
end)

local function handleVehicleCreate()
    if source and source.type == "vehicle" then
        loadVehicleLights(source)
    end
end

local function handleVehicleDestroy()
    if source and source.type == "vehicle" then
        unloadVehicleLights(source)
    end
end
addEventHandler("onClientElementStreamIn", getRootElement(), handleVehicleCreate)
addEventHandler("onClientElementDestroy", getRootElement(), handleVehicleDestroy)
addEventHandler("onClientElementStreamOut", getRootElement(), handleVehicleDestroy)
addEventHandler("onClientVehicleExplode", getRootElement(), handleVehicleDestroy)

--Indicator anim
LightsAnim = {}

local animatedVehicles = {}

local function updateVehicle(vehicle, deltaTime)
    local anim = animatedVehicles[vehicle]
    
    local turnLeftState
    local turnRightState
    if getVehicleLightData(vehicle, "emergency_light") then
        turnLeftState  = true
        turnRightState = true
    else
        turnLeftState  = getVehicleLightData(vehicle, "turn_left")
        turnRightState = getVehicleLightData(vehicle, "turn_right")
    end

    if turnLeftState or turnRightState then
        anim.turnLightsTime = anim.turnLightsTime + deltaTime
        if anim.turnLightsTime > anim.turnLightsInterval then
            anim.turnLightsState = not anim.turnLightsState
            anim.turnLightsTime = 0

            if turnLeftState then
                LightsAnim.setLightState(vehicle, "turn_left", anim.turnLightsState)
            end
            if turnRightState then
                LightsAnim.setLightState(vehicle, "turn_right", anim.turnLightsState)
            end
        end
    else
        anim.turnLightsTime = anim.turnLightsInterval
        anim.turnLightsState = false
    end
    
    local brakeState = false
    local reverseState = false
    
    if vehicle.controller and vehicle.onGround then
        local movingBackwards, movingFast = isVehicleMovingBackwards(vehicle)
        local accelerateState = vehicle.controller:getControlState("accelerate")
        if movingBackwards then
            brakeState = movingFast and accelerateState
            reverseState = true
            LightsAnim.setLightState(vehicle, "brake", brakeState)
            LightsAnim.setLightState(vehicle, "rear", reverseState)
        else
            brakeState = (movingFast or accelerateState) and vehicle.controller:getControlState("brake_reverse")
            LightsAnim.setLightState(vehicle, "brake", brakeState)
            LightsAnim.setLightState(vehicle, "rear", false)
        end
    else
        LightsAnim.setLightState(vehicle, "brake", false)
        LightsAnim.setLightState(vehicle, "rear", false)
    end
    
    if anim.specialAnimActive then
        anim.specialAnimTime = anim.specialAnimTime + deltaTime
    end
    
    local customLights = CustomLights[vehicle.model]
    
    if customLights and customLights.update then
        customLights.update(anim, deltaTime, vehicle)
    end
    
end

function LightsAnim.addVehicle(vehicle)
    if not vehicle then
        return
    end
    
    animatedVehicles[vehicle] = {
        turnLightsTime = 0,
        turnLightsInterval = Config.defaultTurnLightsInterval,
        turnLightsState = false,
        
        specialAnimActive = false,
        specialAnimTime = 0,
        
        setLightState = function (...) return LightsAnim.setLightState(vehicle, ...) end,
        getLightState = function (...) return LightsAnim.getLightState(vehicle, ...) end,
        setLightColor = function (...) return LightsAnim.setLightColor(vehicle, ...) end,
        getLightColor = function (...) return LightsAnim.getLightColor(vehicle, ...) end,
        stopSpecialAnimation = function (...) return LightsAnim.stopSpecialAnimation(vehicle, ...) end,
    }
    
    local customLights = CustomLights[vehicle.model]
    
    if customLights and customLights.init then
        customLights.init(animatedVehicles[vehicle], vehicle)
    end
    
end

function LightsAnim.removeVehicle(vehicle)
    if vehicle and animatedVehicles[vehicle] then
        animatedVehicles[vehicle] = nil
    end
end

function LightsAnim.getVehicleAnim(vehicle)
    if vehicle then
        return animatedVehicles[vehicle]
    end
end

function LightsAnim.setLightState(vehicle, name, state)
    local oldState = getVehicleLightProperty(vehicle, name, "state")
    
    if state ~= oldState then
        local anim = animatedVehicles[vehicle]
        if anim then
            local customLights = CustomLights[vehicle.model]
            if customLights and customLights.stateHandlers and customLights.stateHandlers[name] then
                customLights.stateHandlers[name](anim, state, vehicle)
            end
        end
        setVehicleLightProperty(vehicle, name, "state", state)
    end
end

function LightsAnim.getLightState(vehicle, name)
    return getVehicleLightProperty(vehicle, name, "state")
end

function LightsAnim.setLightColor(vehicle, name, r, g, b)
    if not r or not g or not b then
        return
    end
    
    local oldColor = getVehicleLightProperty(vehicle, name, "color")
    
    if not oldColor or r ~= oldColor[1] or g ~= oldColor[2] or b ~= oldColor[3] then
        setVehicleLightProperty(vehicle, name, "color", {r, g, b})
    end
end

function LightsAnim.getLightColor(vehicle, name)
    return getVehicleLightProperty(vehicle, name, "color")
end

function LightsAnim.startSpecialAnimation(vehicle, callback, data)
    if not vehicle then
        return false
    end
    
    local anim = animatedVehicles[vehicle]
    
    if anim then
        anim.specialAnimTime = 0
        anim.specialAnimActive = true
        if type(callback) == "function" then
            anim.specialAnimCallback = callback
        end
        anim.specialAnimData = data
    end
    return true
end

function LightsAnim.stopSpecialAnimation(vehicle, omitCallback)
    if not vehicle then
        return false
    end
    
    local anim = animatedVehicles[vehicle]
    if anim then
        if not omitCallback and anim.specialAnimCallback then
            anim.specialAnimCallback(vehicle)
        end
        anim.specialAnimTime = 0
        anim.specialAnimActive = false
        anim.specialAnimCallback = nil
        anim.specialAnimParams = nil
    end
    return true
end

function LightsAnim.cancelSpecialAnimation(vehicle)
    return LightsAnim.stopSpecialAnimation(vehicle, true)
end

function LightsAnim.isSpecialAnimationRunning(vehicle)
    if not vehicle then
        return false
    end
    local anim = animatedVehicles[vehicle]
    return not not anim and anim.specialAnimActive
end

addEventHandler("onClientPreRender", getRootElement(), 
    function (deltaTime)
        deltaTime = deltaTime / 1000
        for vehicle in pairs(animatedVehicles) do
            updateVehicle(vehicle, deltaTime)
        end
    end
)

--indicator control
local localLightsData = {}

local leftPressTime = 0
local rightPressTime = 0

local lightDataNames = {
    ["emergency_light"] = true,
    ["turn_left"] = true,
    ["turn_right"] = true,
}

local prevFrontState

local function syncLocalLights()
    if localPlayer.vehicle and localPlayer.vehicle.controller == localPlayer then
        for name, value in pairs(localLightsData) do
            localPlayer.vehicle:setData(name, not not value, true)
        end
    end
end

local function handleLightsDataChange(vehicle, name, value)
    if not value then
        if name == "turn_left" or name == "turn_right" then
            LightsAnim.setLightState(vehicle, name, false)
        elseif name == "emergency_light" then
            LightsAnim.setLightState(vehicle, "turn_left", false)
            LightsAnim.setLightState(vehicle, "turn_right", false)
        end
    end

    local customLights = CustomLights[vehicle.model]
    if customLights and customLights.dataHandlers and customLights.dataHandlers[name] then
        customLights.dataHandlers[name](LightsAnim.getVehicleAnim(vehicle), value, vehicle)
    end
end

function setLocalLightsData(name, value)
    if type(name) ~= "string" then
        return
    end
    local vehicle = localPlayer.vehicle
    if not vehicle then
        return
    end
    if vehicle.controller ~= localPlayer then
        return
    end
    
    localLightsData[name] = value
    antiDOSsend("main_sync", 250, vehicle, name, value)
    handleLightsDataChange(vehicle, name, value)
    
    local vehTrailer = getVehicleTowedByVehicle(vehicle)
    
    if vehTrailer then
        antiDOSsend("main_sync", 250, vehTrailer, name, value)
        handleLightsDataChange(vehTrailer, name, value)
    end
end

function getVehicleLightData(vehicle, name)
    if vehicle.controller == localPlayer then
        return localLightsData[name]
    end
    return vehicle:getData(name)
end

addEventHandler("onClientElementDataChange", getRootElement(), function (dataName, oldValue)
    if source.type ~= "vehicle" or not isElementStreamedIn(source) then
        return
    end
    if not lightDataNames[dataName] then
        return
    end
    if source.controller == localPlayer then
        return
    end
    handleLightsDataChange(source, dataName, source:getData(dataName))
end)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
            if getElementData(v, "turn_left") then
                setLocalLightsData("emergency_light", false)
                setLocalLightsData("turn_right", false)
                setLocalLightsData("turn_left", not localLightsData["turn_left"])
            elseif getElementData(v, "turn_right") then
                setLocalLightsData("emergency_light", false)
                setLocalLightsData("turn_left", false)
                setLocalLightsData("turn_right", not localLightsData["turn_right"])
            elseif getElementData(v, "emergency_light") then
                setLocalLightsData("turn_left", false)
                setLocalLightsData("turn_right", false)
                setLocalLightsData("emergency_light", not localLightsData["emergency_light"])
            end
        end
    end
)

addEventHandler("onClientKey", getRootElement(), function (button, state)
    if not localPlayer.vehicle or localPlayer.vehicle.controller ~= localPlayer then
        return
    end
    
    if isChatBoxInputActive() or isConsoleActive() or isCursorShowing() then
        return
    end
    
    if state then
        if button == "mouse1" then
            setLocalLightsData("emergency_light", false)
            setLocalLightsData("turn_right", false)
            setLocalLightsData("turn_left", not localLightsData["turn_left"])
            cancelEvent()
        elseif button == "mouse2" then
            setLocalLightsData("emergency_light", false)
            setLocalLightsData("turn_left", false)
            setLocalLightsData("turn_right", not localLightsData["turn_right"])
            cancelEvent()
        elseif button == "F6" then
            setLocalLightsData("turn_left", false)
            setLocalLightsData("turn_right", false)
            setLocalLightsData("emergency_light", not localLightsData["emergency_light"])
            cancelEvent()
        end
        return
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function ()
    setTimer(syncLocalLights, 1000, 0)
end)

addEventHandler("onClientPlayerVehicleEnter", localPlayer, function (vehicle, seat)
    if seat == 0 then
        localLightsData = {
            turn_left = vehicle:getData("turn_left"),
            turn_right = vehicle:getData("turn_right"),
            emergency_light = vehicle:getData("emergency_light")
        }
    end
end)

--Indicator sync

local function setVehicleLightsState(vehicle, state)
    if state == "hwd" or state == "head" then
        state = 2
    else
        state = 1
    end
    vehicle.overrideLights = state
end

local function handleVehicleSteamIn(vehicle)
    if not isElement(vehicle) or not Config.animatedLightsVehicles[vehicle.model] then
        return
    end
    local state = vehicle:getData("animatedLightsState")
    LightsAnim.cancelSpecialAnimation(vehicle)
    if state == "hwd" or state == "head" then
        LightsAnim.startSpecialAnimation(vehicle, nil, "enable")
    else
        LightsAnim.startSpecialAnimation(vehicle, nil, "disable")
    end
   -- setVehicleLightsState(vehicle, state)
end

function setLocalLightsState(state)
    if not localPlayer.vehicle then
        return false
    end
    antiDOSsend("lights", 250, localPlayer.vehicle, "animatedLightsState", state)
    return true
end

addEventHandler("onClientElementDataChange", getRootElement(), function (dataName, oldValue)
    if source.type ~= "vehicle" or not isElementStreamedIn(source) then
        return
    end
    if dataName ~= "animatedLightsState" then
        return
    end
    local vehicle = source
    if not Config.animatedLightsVehicles[vehicle.model] then
        return
    end
    local state = vehicle:getData(dataName)

    if oldValue == "off" then
        LightsAnim.startSpecialAnimation(vehicle, function (vehicle)
            setVehicleLightsState(vehicle, vehicle:getData("animatedLightsState"))
        end, "anim_on")
    else
        if state == "head" or state == "hwd" then
            if not LightsAnim.isSpecialAnimationRunning(vehicle) then
                setVehicleLightsState(vehicle, vehicle:getData("animatedLightsState"))
            end
        else
            setVehicleLightsState(vehicle, state)
            if LightsAnim.isSpecialAnimationRunning(vehicle) then
                LightsAnim.cancelSpecialAnimation(vehicle)
                LightsAnim.startSpecialAnimation(vehicle, nil, "disable")
            else
                LightsAnim.startSpecialAnimation(vehicle, nil, "anim_off")
            end
        end
    end
end)

addEventHandler("onClientElementStreamIn", getRootElement(), function ()
    if source.type ~= "vehicle" then
        return
    end
    handleVehicleSteamIn(source)
end)

addEventHandler("onClientResourceStart", resourceRoot, function ()
    for i, vehicle in ipairs(getElementsByType("vehicle"), getRootElement(), true) do
        if isElementStreamedIn(vehicle) then
            handleVehicleSteamIn(vehicle)
        end
    end
end)
