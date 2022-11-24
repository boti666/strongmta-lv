local presentTimers = {}

addEvent("startTaxiClock", true)
addEventHandler("startTaxiClock", getRootElement(),
    function(sourcePlayer, sourceVehicle)
        if not presentTimers[sourceVehicle] then 
            setElementData(sourceVehicle, "veh.TaxiClock", true)

            presentTimers[sourceVehicle] = setTimer(function()
                if isElement(sourceVehicle) then 
                    if getElementData(sourceVehicle, "veh.TaxiClock") then 
                        local kmh = getVehicleSpeed(sourceVehicle)

                        if kmh > 0 then 
                            local current = getElementData(sourceVehicle, "veh.traveledMeter") or 0

                            local getVehicleTax = (getElementData(sourceVehicle, "veh.TaxiMultiplier") or 50) / 10

                            setElementData(sourceVehicle, "veh.traveledMeter", current + ((kmh / 300) * (getVehicleTax)))
                        end
                    end
                else 
                    killTimer(presentTimers[sourceVehicle])
                    presentTimers[sourceVehicle] = false
                end
            end, 1000, 0)
        end
    end
)

addEvent("stopTaxiClock", true)
addEventHandler("stopTaxiClock", getRootElement(),
    function(sourcePlayer, sourceVehicle, tripDistance)
        if presentTimers[sourceVehicle] then 
            killTimer(presentTimers[sourceVehicle])
            presentTimers[sourceVehicle] = false
        end

        if (getElementData(sourceVehicle, "veh.traveledMeter") or 0) > 0 then
            setElementData(sourceVehicle, "veh.PayTax", true)
        end

        local oldTripDistance = getElementData(sourceVehicle, "veh.TaxiClockMeter") or 0

        local distanceToSave = math.floor((oldTripDistance + tripDistance) * 10) / 10

        setElementData(sourceVehicle, "veh.TaxiClockMeter", distanceToSave)
        
        setElementData(sourceVehicle, "veh.TaxiClock", false)
    end
)

addEvent("resetTaxiClock", true);
addEventHandler("resetTaxiClock", getRootElement(),
    function(sourcePlayer, sourceVehicle)
        if isTimer(presentTimers[sourceVehicle]) then 
            killTimer(presentTimers[sourceVehicle])
        end

        presentTimers[sourceVehicle] = false

        setElementData(sourceVehicle, "veh.TaxiClock", false)
        setElementData(sourceVehicle, "veh.traveledMeter", 0)
        setElementData(sourceVehicle, "veh.TaxiClockDouble", false)

        setElementData(sourceVehicle, "veh.PayTax", false)
    end
)

addEvent("setTaxiVehicleTax", true);
addEventHandler("setTaxiVehicleTax", getRootElement(),
    function(sourcePlayer, sourceVehicle, payTax)
        setElementData(sourceVehicle, "veh.TaxiPayTax", tonumber(payTax))
    end
)

addEvent("setTaxiMultiplier", true);
addEventHandler("setTaxiMultiplier", getRootElement(),
    function(sourcePlayer, sourceVehicle, multiplier)
        setElementData(sourceVehicle, "veh.TaxiMultiplier", tonumber(multiplier))
    end
)

addEvent("payTaxiPrice", true)
addEventHandler("payTaxiPrice", getRootElement(),
    function(sourcePlayer, sourceVehicle, vehicleDriver, meterCost, driverPay)
        if sourcePlayer == client and isPedInVehicle(client) then 
            exports.see_core:takeMoney(sourcePlayer, meterCost, "taxiCost")

            local vehicleMoneyDifferent = 10 / 100

            if driverPay then
                driverCost = 0
                factionCost = math.floor(meterCost)
            else
                driverCost = math.floor(meterCost * vehicleMoneyDifferent)
                factionCost = math.floor(meterCost * (1 - vehicleMoneyDifferent))
            end


            if driverCost and driverCost > 0 then
                exports.see_core:giveMoney(vehicleDriver, driverCost, "taxiPayCost")
            end

            setElementData(sourceVehicle, "veh.PayTax", false)

            for k, v in pairs(getElementsByType("player")) do 
                if exports.see_groups:isPlayerInGroup(sourcePlayer, 24) then 
                    --outputChatBox("#FECE01[StrongMTA]: Kifizette a fuvardíjat. Összeg: #7cc576"..driverCost.." $", v, 255, 255, 255, true)
                end
            end

            print("driverCost: " .. driverCost .. " | factionCost: " .. factionCost)
        end
    end
)