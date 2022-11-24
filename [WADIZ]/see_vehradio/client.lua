radios         = {}
inStreamRadios = {}

panelOpened    = false

local ytLink   = "https://www.youtube.com/embed/%s?controls=0&autoplay=1"

startRadio = function(vehicle)
    if not radios[vehicle] then return false end

    if radios[vehicle].type == "FM" then
        local path = SETTINGS.STATIONS[radios[vehicle].path][2]
        inStreamRadios[vehicle] = {
            sound = playSound(path)
        }

    elseif radios[vehicle].type == "YT" then
        if getElementData(localPlayer, "radion:off") then
            return
        end
        inStreamRadios[vehicle] = {
            browser = createBrowser(1, 1, false, false)
        }
        addEventHandler("onClientBrowserCreated", inStreamRadios[vehicle].browser, function()
            loadBrowserURL(source, ytLink:format(radios[vehicle].path))
        end)
    end

    return true
end

destroyRadio = function(vehicle)
    if not radios[vehicle] then return false end
    
    if inStreamRadios[vehicle] then
        if radios[vehicle].type == "FM" and isElement(inStreamRadios[vehicle].sound) then
            destroyElement(inStreamRadios[vehicle].sound)
        elseif radios[vehicle].type == "YT" and isElement(inStreamRadios[vehicle].browser) then
            if getElementData(localPlayer, "radion:off") then
                return
            end
            destroyElement(inStreamRadios[vehicle].browser)
        end
        inStreamRadios[vehicle] = nil
    end

    radios[vehicle] = nil
    return true
end

switchStation = function(vehicle, path)
    if not inStreamRadios[vehicle] then return false end

    radios[vehicle].path = path

    if radios[vehicle].type == "FM" and isElement(inStreamRadios[vehicle].sound) then
        destroyElement(inStreamRadios[vehicle].sound)
        inStreamRadios[vehicle].sound = playSound(SETTINGS.STATIONS[path][2])

    elseif radios[vehicle].type == "YT" and isElement(inStreamRadios[vehicle].browser) then
        if getElementData(localPlayer, "radion:off") then
            return
        end
        loadBrowserURL(inStreamRadios[vehicle].browser, ytLink:format(path))
    end
end

addEvent("onEnableRadio", true)
addEventHandler("onEnableRadio", root, function(type, path)
    if radios[source] and radios[source].type == type then
        return switchStation(source, path)
    end
    destroyRadio(source)

    radios[source] = {
        type   = type,
        path   = path
    }

    startRadio(source)
end)

addEvent("onDisableRadio", true)
addEventHandler("onDisableRadio", root, function()
    destroyRadio(source)
end)

getRadioVolume = function(vehicle)
    return getElementData(vehicle, "radio:volume") or 0.75
end

local lastTick = getTickCount()
addEventHandler("onClientRender", root, function()
    local tick = getTickCount()
    if lastTick + 50 > tick then return end
    lastTick = tick

    local px, py, pz = getElementPosition(localPlayer)
    local ownVeh     = getPedOccupiedVehicle(localPlayer)

    for vehicle, v in pairs(inStreamRadios) do
        if isElement(vehicle) then
            local volume   = 0

            if ownVeh == vehicle or not getElementData(vehicle, "vehicle.windowState") then
                if onVolumeChange and vehicle == panelOpened then
                    volume = onVolumeChange
                else
                    local x, y, z  = getElementPosition(vehicle)
                    local distance = getDistanceBetweenPoints3D(px, py, pz, x, y, z)
                    volume         = math.min(1, math.max(0, (1 - distance / SETTINGS.SOUND_RADIUS) * getRadioVolume(vehicle)))
                end
            end
            
            if radios[vehicle].type == "FM" and isElement(v.sound) then
                setSoundVolume(v.sound, volume)
            elseif radios[vehicle].type == "YT" and isElement(v.browser) then
                if getElementData(localPlayer, "radion:off") then
                    return
                end
                setBrowserVolume(v.browser, volume)
            end
        else
            destroyRadio(vehicle)
        end
    end
end)


bindKey(SETTINGS.BIND, "up", function()
    if panelOpened then
        hidePanel()
    else
        showPanel()
    end
end)

addCommandHandler("hangrendszer",
    function(cmd)
        if getElementData(localPlayer, "radion:off") then
            setElementData(localPlayer, "radion:off", false)
            outputChatBox("Sikeresen bekapcsoltad!", 255, 255, 255, true)
        else
            setElementData(localPlayer, "radion:off", true)
            outputChatBox("Sikeresen kikapcsoltad!", 255, 255, 255, true)
        end
    end
)