addEvent("syncSpecialAnim", true)
addEventHandler("syncSpecialAnim", getRootElement(), 
    function ()
        triggerClientEvent("syncSpecialAnim", source)
    end
)

addCommandHandler("variant",
    function(theUser, command, var1)
        local myVeh = getPedOccupiedVehicle(theUser)
        if (myVeh and getVehicleController(myVeh) == theUser) then
            local wasSet = setVehicleVariant(myVeh, var1, 255)
        end
    end
)