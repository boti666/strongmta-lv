local chargerObjects = {}
local pumpObjects = {}

addEventHandler("onResourceStart", resourceRoot,
    function()
        local id = 0
        for k, v in pairs(chargerPoints) do
            id = id + 1
            local chargerObject = createObject(6929, v[1], v[2], v[3] - 1, 0, 0, v[4])
            setElementData(chargerObject, "charger.Id", id)
            chargerObjects[chargerObject] = true

            local pumpX, pumpY, pumpZ = getPositionFromElementOffset(chargerObject, 0.22, 0.03, 1.70)
            local pumpObject = createObject(7238, pumpX, pumpY, pumpZ, 10, 10, v[4])
            setElementCollisionsEnabled(pumpObject, false)
            setElementData(pumpObject, "pump.Id", id)
            setElementData(pumpObject, "pump.Rotation", {10, 10, v[4]})
            pumpObjects[chargerObject] = pumpObject
        end
    end
)

addEvent("requestObjects", true)
addEventHandler("requestObjects", getRootElement(),
    function()
        triggerLatentClientEvent(source, "receiveObjects", source, chargerObjects, pumpObjects)
    end
)

addEvent("selectPump", true)
addEventHandler("selectPump", getRootElement(),
    function(pumpId)
        pumpId = tonumber(pumpId)
        for k, v in pairs(pumpObjects) do
            if getElementData(v, "pump.Id") == pumpId then
                if isElement(getElementData(v, "pump.User")) then
                    exports.see_accounts:showInfo(source, "e", "Ezt a töltőpisztolyt már használja valaki!")
                    return
                end
                if getElementData(v, "pump.vehicleUsed") then
                    local pumpVehicleUsed = getElementData(v, "pump.vehicleUsed")
                    local vehicleElement = false
                    for k, v in pairs(getElementsByType("vehicle")) do
                        if getElementData(v, "vehicle.dbID") == pumpVehicleUsed then
                            exports.see_accounts:showInfo(source, "e", "Először vedd ki az autóból a töltőpisztolyt!")
                            return
                        end
                    end
                end
                exports.see_boneattach:attachElementToBone(v, source, 12, 0.03, 0.03, 0.03, 35, -90, 0)
                setElementCollisionsEnabled(v, false)
                setElementData(source, "pump.Used", pumpId)
                setElementData(source, "pump.Station", k)
                setElementData(v, "pump.User", source)
                break
            end
        end
    end
)

addEvent("dropPump", true)
addEventHandler("dropPump", getRootElement(),   
    function(pumpId)
        pumpId = tonumber(pumpId)
        for k, v in pairs(pumpObjects) do
            if getElementData(v, "pump.Id") == pumpId then
                exports.see_boneattach:detachElementFromBone(v)
                local pumpX, pumpY, pumpZ = getPositionFromElementOffset(k, 0.22, 0.03, 1.70)
                setElementCollisionsEnabled(v, false)
                setElementPosition(v, pumpX, pumpY, pumpZ)
                setElementRotation(v, unpack(getElementData(v, "pump.Rotation")))
                setElementData(source, "pump.Used", false)
                setElementData(v, "pump.User", false)
                break
            end
        end
    end
)

addEvent("dropVehiclePump", true)
addEventHandler("dropVehiclePump", getRootElement(),
    function(vehicleId)
        vehicleId = tonumber(vehicleId)
        local vehicleElement = false
        local pumpElement = false
        local vehicleElementUsed = false

        for k, v in pairs(getElementsByType("vehicle")) do
            if getElementData(v, "vehicle.dbID") == vehicleId then
                vehicleElement = v
                vehicleElementUsed = getElementData(vehicleElement, "pump.vehicleUsed")
                break
            end
        end

        if isElement(vehicleElement) and vehicleElementUsed then
            for k, v in pairs(pumpObjects) do
                if getElementData(v, "pump.Id") == vehicleElementUsed then
                    pumpElement = v
                    setElementCollisionsEnabled(v, false)
                    break
                end
            end
            if getElementData(vehicleElement, "vehicle.locked") == 1 then
                exports.see_accounts:showInfo(source, "e", "Először nyisd ki az autót!")
                return
            end

            if isElement(vehicleElement) then
                setElementFrozen(vehicleElement, false)
                detachElements(pumpElement, vehicleElement)
                local pumpId = getElementData(vehicleElement, "pump.vehicleUsed")
                setElementData(pumpElement, "pump.vehicleUsed", false)
                setElementData(vehicleElement, "pump.vehicleUsed", false)
                setElementData(pumpElement, "pump.vehicleElement", false)
                triggerEvent("selectPump", source, pumpId)
            end
        end
    end
)

addEvent("selectVehiclePump", true)
addEventHandler("selectVehiclePump", getRootElement(),  
    function(vehicleId)
        vehicleId = tonumber(vehicleId)
        local vehicleElement = false

        for k, v in pairs(getElementsByType("vehicle")) do
            if getElementData(v, "vehicle.dbID") == vehicleId then 
                vehicleElement = v
                break
            end
        end

        if isElement(vehicleElement) then
            setElementFrozen(vehicleElement, true)
            local vehicleElementModel = getElementModel(vehicleElement)
            local pumpX, pumpY, pumpZ = getPositionFromElementOffset(vehicleElement, modelOffsets[vehicleElementModel][1] - 0.2, modelOffsets[vehicleElementModel][2], modelOffsets[vehicleElementModel][3])

            local sourcePumpUsed = getElementData(source, "pump.Used")
            if sourcePumpUsed then
                local pumpElement = false
                for k, v in pairs(pumpObjects) do
                    if getElementData(v, "pump.Id") == sourcePumpUsed then
                        pumpElement = v
                        break
                    end
                end
                if pumpElement then
                    if getElementData(vehicleElement, "pump.vehicleUsed") then
                        exports.see_accounts:showInfo(source, "e", "Ez az autó már töltés alatt áll!")
                        return
                    end
                    if getElementData(vehicleElement, "vehicle.locked") == 1 then
                        exports.see_accounts:showInfo(source, "e", "Először nyisd ki az autót!")
                        return
                    end
                    exports.see_boneattach:detachElementFromBone(pumpElement)
                    setElementCollisionsEnabled(pumpElement, false)
                    attachElements(pumpElement, vehicleElement, modelOffsets[vehicleElementModel][1] - 0.2, modelOffsets[vehicleElementModel][2], modelOffsets[vehicleElementModel][3], 270, 270, 180)
                    setElementData(source, "pump.Used", false)
                    setElementData(pumpElement, "pump.User", false)
                    setElementData(pumpElement, "pump.vehicleElement", vehicleElement)
                    setElementData(pumpElement, "pump.vehicleUsed", getElementData(vehicleElement, "vehicle.dbID"))
                    setElementData(vehicleElement, "pump.vehicleUsed", sourcePumpUsed)
                end
            end
        end
    end
)

setTimer(
    function()
        for k, v in pairs(pumpObjects) do
            pumpVehicle = getElementData(v, "pump.vehicleElement")
            if isElement(pumpVehicle) then
                if ((getElementData(pumpVehicle, "vehicle.fuel") + 0.1) < 49.9) then
                    setElementData(pumpVehicle, "vehicle.fuel", getElementData(pumpVehicle, "vehicle.fuel") + 49.9)
                end
            end
        end
    end, 180000/(100/0.1), 0
)