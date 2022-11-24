local connection = exports.see_database:getConnection()

addCommandHandler("protect",
	function (source)
		local pedVehicle = getPedOccupiedVehicle(source)
		local vehicleDatabaseId = getElementData(pedVehicle, "vehicle.dbID") or 0
		if not pedVehicle then
			outputChatBox("#d75959[StrongMTA]: #FFFFFFNem vagy járműben.", source, 255, 255, 255, true)
		else
			if not getElementData(pedVehicle, "isProtected") then 
				setElementData(source, "protectNextStage", "accept")
				outputChatBox("#d75959[StrongMTA]: #FFFFFFA jármű levédése #32b3ef500 PP#FFFFFF-be került. \n#d75959[StrongMTA]: #FFFFFFA prémium összeg levonásra került a felhasználódról.", source, 255, 255, 255, true)
				setElementData(pedVehicle, "isProtected", 1)
				local isProtectedVehicle = getElementData(pedVehicle, "isProtected")
				dbExec(connection, "INSERT INTO vehicles WHERE vehicleId = ?, isProtected = ?",vehicleDatabaseId, isProtectedVehicle)
			else
				outputChatBox("#d75959[StrongMTA]: #FFFFFFA jármű már le van védve.", source, 255, 255, 255, true)
			end
			iprint(pedVehicle)
		end
	end 
)

addCommandHandler("removeprotect",
	function (source)
		local pedVehicle = getPedOccupiedVehicle(source)
		if not getElementData(pedVehicle, "isProtected") then 
			outputChatBox("#d75959[StrongMTA]: #FFFFFFA jármű még nincs levédve.", source, 255, 255, 255, true)
		else
			setElementData(pedVehicle, "isProtected", 0)
			outputChatBox("#d75959[StrongMTA]: #FFFFFFA levédés kivétele sikeres.", source, 255, 255, 255, true)
		end
		
	end 
)