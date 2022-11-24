addEvent("changeForRedLights", true)
addEventHandler("changeForRedLights", getRootElement(),
    function (upv1, lastTick)
        if isElement(source) and client and client == source then 
            if upv1 and lastTick then 
                setTrafficLightState("red", "green")
                if getPedOccupiedVehicle(source) then 
                    if exports.see_core:getLevel(source) > 2 then
                        setElementData(source, "char.Money", getElementData(source, "char.Money") - 75000)
                    else
                        setElementData(source, "char.Money", getElementData(source, "char.Money") - 25000)
                    end
                end
            end
        end
    end 
)

addEvent("changeForRedLightsSync", true)
addEventHandler("changeForRedLightsSync", getRootElement(),
    function ()
        setTrafficLightState("red", "green")
    end 
)