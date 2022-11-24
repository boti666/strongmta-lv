function getResponsiveMultipler()
	return 1
end

function colRectEx(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
	return createColRectangle(math.min(_ARG_0_, _ARG_2_), math.min(_ARG_1_, _ARG_3_), math.max(_ARG_0_, _ARG_2_) - math.min(_ARG_0_, _ARG_2_), math.max(_ARG_1_, _ARG_3_) - math.min(_ARG_1_, _ARG_3_))
end

availableCols = {
	[colRectEx(1819.9697265625, 864.109375, 1769.7509765625, 821.8154296875)] = true,
	[colRectEx(2036.3916015625, 820.662109375, 2089.1650390625, 864.5185546875)] = true,
	[colRectEx(2079.2109375, 961.77734375, 2036.01953125, 984.326171875)] = true,
	[colRectEx(2078.189453125, 1362.1474609375, 2035.51171875, 1384.8818359375)] = true,
	[colRectEx(2158.7685546875, 2011.162109375, 2115.736328125, 2031.65625)] = true,
	--[colRectEx(2158.2412109375, 2121.1396484375, 2116.3154296875, 2171.62890625)] = true
}

function canAutoCamCapture()
	if getElementModel((getPedOccupiedVehicle(localPlayer))) == 525 or getElementModel((getPedOccupiedVehicle(localPlayer))) == 408 then
		return false
	end
	if getVehicleSirensOn((getPedOccupiedVehicle(localPlayer))) then
		return true
	end
	return false
end
  
function getRotationBetweenPointss(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_)
	return math.deg(math.atan2(_ARG_3_ - _ARG_1_, _ARG_2_ - _ARG_0_)) + 180
end

addEvent("flashTheScreen", true)
addEventHandler("flashTheScreen", getRootElement(),
	function ()
		fadeCamera(false, 0.5, 255, 255, 255) 
		
		setTimer(
			function () 
				fadeCamera(true, 0.5)
			end, 400, 1
		)
	end 
)

local lastTick = 0

local whitelistedVehicles = {
	[416] = true,
	[490] = true, 
	[528] = true, 
	[597] = true, 
	[599] = true,
	[601] = true,
	[598] = true,
	[596] = true,
	[427] = true,
	[445] = false 
}

triggerServerEvent("changeForRedLightsSync", localPlayer)

addEventHandler("onClientColShapeHit", getRootElement(),
	function (hitElement)
		local pedVeh = getPedOccupiedVehicle(localPlayer)
		if availableCols[source] and isPedInVehicle(localPlayer) and hitElement == getPedOccupiedVehicle(localPlayer) and not canAutoCamCapture() and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			if getVehicleType(getPedOccupiedVehicle(localPlayer)) == "Helicopter" or whitelistedVehicles[getElementModel(pedVeh)] then 
				return
			end	
  
			local lightsState = getTrafficLightState()
			local vehicleRotationX, vehicleRotationY, vehicleRotationZ = getElementRotation(getPedOccupiedVehicle(localPlayer))
  
			local upv0 = "N"
			
			if vehicleRotationZ > 45 and vehicleRotationZ <= 135 then 
			  upv0 = "W"
			elseif vehicleRotationZ > 135 and vehicleRotationZ <= 225 then 
			  upv0 = "S"
			elseif vehicleRotationZ > 135 and vehicleRotationZ <= 225 then
			  upv0 = "E"
			end
			  
			local upv1 = false 
  
			if lightsState == 2 then 
				upv1 = true 
			elseif (lightsState == 3 or lightsState == 4) and (upv0 == "N" or upv0 == "S") then
					upv1 = true 
				if (lightsState == 0 or lightsState == 1) and (upv0 == "E" or upv0 == "W") then 
					upv1 = true 
				end 
			else
				upv1 = false
			end
			  
			if upv1 then 
				if getTickCount() - lastTick < 10000 then 
					return
				end
  
				currentTick = getTickCount()
  
				triggerServerEvent("changeForRedLights", localPlayer, upv1, lastTick)
				triggerEvent("flashTheScreen", localPlayer)
				 
				if exports.see_core:getLevel(localPlayer) > 2 then
					outputChatBox("#3d7abc[StrongMTA - Közlekedési lámpák]: #ffffffMivel áthajtottál a #d75959piroson#ffffff, ezért a bűntetésed #d7595975 000$#ffffff.", 255, 255, 255, true)
				else
					outputChatBox("#3d7abc[StrongMTA - Közlekedési lámpák]: #ffffffMivel áthajtottál a #d75959piroson#ffffff, ezért a bűntetésed #d7595925 000$#ffffff.", 255, 255, 255, true)				
				end
			end
		end 
	end
)