local vehBackfires = {}

if fileExists("sourceC.lua") then
	fileDelete("sourceC.lua")
end

local vehicleFireTick = 0
local enabledVehicles = {
	[477] = true,
	[415] = true,
	[506] = true,
	[429] = true,
	[451] = true,
	[587] = true,
	[562] = true,
	[559] = true,
	[494] = true,
	[555] = true,
	[503] = true,
	[602] = true,
	[526] = true,
	[522] = true,
	[445] = true,
	[566] = true,
	[478] = true,
	[540] = true,
	[560] = true,
	[480] = true,
	[516] = true,
	[533] = true,
	[558] = true,
	[438] = true,
	[434] = true,
	[502] = true,
	[429] = true,
	[561] = true,
	[549] = true,
	[426] = true,
	[411] = true
}

function getPositionFromElementOffset(element, x, y, z)
	local m = getElementMatrix(element)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
		   x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
		   x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end


function getElementSpeed(element)
	local vx,vy,vz = getElementVelocity(element)
    return (vx * vx + vy * vy + vz * vz) * 0.5
end

function isHaveBackfire(vehicle)
  return enabledVehicles[getElementModel(vehicle)]
end

addEvent("onBackFire", true)
addEventHandler("onBackFire", getRootElement(), 
	function()
		if isElement(source) then
			if getElementData(source, "vehicle.backfireToggled") then 
				return 
			end
			for k = 1, 2 do 
				local vehX, vehY, vehZ = getElementPosition(source)
				local exhaustX, exhaustY, exhaustZ = getVehicleModelExhaustFumesPosition((getElementModel(source)))
				table.insert(vehBackfires, {
					createEffect("gunflash", vehX, vehY, vehZ),
					source,
					getTickCount(),
					exhaustX, 
					exhaustY, 
					exhaustZ
				})
			end
			if bitAnd(getVehicleHandling(source).modelFlags, 8192) == 8192 then
				for k = 1, 2 do
					local vehX, vehY, vehZ = getElementPosition(source)
					local exhaustX, exhaustY, exhaustZ = getVehicleModelExhaustFumesPosition((getElementModel(source)))
					table.insert(vehBackfires, {
						createEffect("gunflash", vehX, vehY, vehZ),
						source,
						getTickCount(),
						-exhaustX,
						exhaustY,
						exhaustZ
					})
				end
			end
			local sound = playSound3D("sound/backfire.mp3", getElementPosition(source))
			setSoundVolume(sound, 0.7)
			attachElements(sound, source)
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(), 
	function(_ARG_0_)
  		if source == getPedOccupiedVehicle(localPlayer) and (string.find(_ARG_0_, "vehicle.tuning") or _ARG_0_ == "vehicle.backfire") then
			vehicleTuning = 0
			vehicleTuning = vehicleTuning + (getElementData(source, "vehicle.tuning.ECU") or 0)
			vehicleTuning = vehicleTuning + (getElementData(source, "vehicle.tuning.Engine") or 0)
			vehicleTuning = vehicleTuning + (getElementData(source, "vehicle.tuning.Turbo") or 0)
			vehicleTuning = vehicleTuning + (getElementData(source, "vehicle.tuning.Transmission") or 0)
			if getElementData(source, "vehicle.backfire") ~= 1 then
				vehicleTuning = 0
			end
		end
	end
)

function processBackfire()
	for k = 1, #vehBackfires do
    if vehBackfires[k] then
      if isElement(vehBackfires[k][2]) and isElement(vehBackfires[k][1]) then
				setEffectSpeed(vehBackfires[k][1], 0.5)
				setElementPosition(vehBackfires[k][1], getPositionFromElementOffset(vehBackfires[k][2], vehBackfires[k][4], vehBackfires[k][5] + getElementSpeed(vehBackfires[k][2]) * 0.9, vehBackfires[k][6]))
		
				local rot = Vector3(getElementRotation(vehBackfires[k][2]))
				setElementRotation(vehBackfires[k][1], 0, 90, -rot.z - 90)
					
				if getTickCount() - vehBackfires[k][3] > 250 then
					destroyElement(vehBackfires[k][1])
					vehBackfires[k] = nil
				end
			else
				if isElement(vehBackfires[k][1]) then
					destroyElement(vehBackfires[k][1])
				end
				vehBackfires[k] = nil
			end
		end
	end
	if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
		if getPedOccupiedVehicle(localPlayer) ~= vehGearSecond then
			vehGearFirst, vehGearSecond = getVehicleCurrentGear((getPedOccupiedVehicle(localPlayer))), getPedOccupiedVehicle(localPlayer)
			vehicleTuning = 0
			vehicleTuning = vehicleTuning + (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle.tuning.ECU") or 0)
			vehicleTuning = vehicleTuning + (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle.tuning.Engine") or 0)
			vehicleTuning = vehicleTuning + (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle.tuning.Turbo") or 0)
			vehicleTuning = vehicleTuning + (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle.tuning.Transmission") or 0)
			if getElementData(getPedOccupiedVehicle(localPlayer), "vehicle.backfire") ~= 1 then
				vehicleTuning = 0
			end
		end
		if vehicleTuning >= 16 and (getElementModel((getPedOccupiedVehicle(localPlayer))) == 602 or getElementModel((getPedOccupiedVehicle(localPlayer))) == 494 or getElementModel((getPedOccupiedVehicle(localPlayer))) == 434 or getElementModel((getPedOccupiedVehicle(localPlayer))) == 549) and getPedControlState("accelerate") and (getPedControlState("handbrake") or getPedControlState("brake_reverse")) and getTickCount() - vehicleFireTick > 100 then
			vehicleFireTick = getTickCount()
			triggerServerEvent("onBackFire", getPedOccupiedVehicle(localPlayer), getElementsByType("player", getRootElement(), true))
		end
		if vehGearFirst ~= getVehicleCurrentGear((getPedOccupiedVehicle(localPlayer))) then
			vehGearFirst = getVehicleCurrentGear((getPedOccupiedVehicle(localPlayer)))
			if vehicleTuning >= 16 then
				triggerServerEvent("onBackFire", getPedOccupiedVehicle(localPlayer), getElementsByType("player", getRootElement(), true))
			end
		end
	end
end
addEventHandler("onClientRender", getRootElement(), processBackfire)

addEventHandler("onClientElementStreamOut", getRootElement(), 
	function()
		if isElement(vehBackfires[source]) then
			destroyElement(vehBackfires[source])
		end
		vehBackfires[source] = nil
	end
)
addEventHandler("onClientElementDestroy", getRootElement(), 
	function()
		if isElement(vehBackfires[source]) then
			destroyElement(vehBackfires[source])
		end

		vehBackfires[source] = nil
	end
)