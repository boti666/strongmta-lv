addCommandHandler("backon",
    function(player,cmd)
        if getElementData(player, "acc.adminLevel") >= 6 then 

            setElementData(getPedOccupiedVehicle(player),"vehicle.backfire",1)
            outputChatBox("Backfire berakva.", player)
        end
    end
)
addCommandHandler("backof",
    function(player,cmd)
        if getElementData(player, "acc.adminLevel") >= 6 then 

            setElementData(getPedOccupiedVehicle(player),"vehicle.backfire",1)
            outputChatBox("Backfire kiszedve.", player)
        end
    end
)

addEvent("onBackFire",true)
addEventHandler("onBackFire",getRootElement(),
    function(player)
        if isElement(source) and getElementType(source) == "vehicle" then
            triggerClientEvent(player, "onBackFire", source)
        end
    end
)
