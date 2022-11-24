local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local CARRIER_DEFAULT_POSITION = {-0.35643125092904, -3.7341625987995, 0.012808443771302, 10.887329101563}

local DOOR_DEFAULT_Z = 0.037999987602234

local JOB_START_POSITIONS = {
	{2844.3974609375, 972.4765625, 10.75},
	{2857.7119140625, 939.37109375, 10.75}
}

local truckerJob = false
local lastJobStart = 0
local startMarkers = {}
local theJob = {}

local loadingBays = {}
local standingLoadingBay = false

local doorMesh = {}
local doorState = {}
local doorAnimation = {}
local doorInAnim = {}
local doorSound = {}
local activeDoorButton = false

local truckPlacedCarrier = {}
local activeTruckTrunk = false
local carrierObject = false
local carringItem = {}

local objectItem = {}
local objectHealth = {}
local currentObjectId = false
local currentObjectHealth = false
local truckPlacedObjects = {}
local truckObjectItem = {}
local totalItemHealth = 0

local Roboto = false
local handFont = false
local lunabarFont = false
local waybill = false

local panelWidth = respc(256)
local panelHeight = respc(25) * 4 + respc(5)
local panelPosX = screenX / 2 - panelWidth / 2
local panelPosY = screenY - panelHeight - respc(70)
local moveDifferenceX = false
local moveDifferenceY = false

local _getElementBoundingBox = getElementBoundingBox

function getElementBoundingBox(element)
	local minX, minY, minZ, maxX, maxY, maxZ = _getElementBoundingBox(element)

	if getElementModel(element) == 1208 then
		return minX + 0.1, minY + 0.1, minZ - 0.45, maxX - 0.1, maxY - 0.1, maxZ - 0.45
	else
		return minX, minY, minZ, maxX, maxY, maxZ
	end
end

function endJob(reset)
	for i = 1, #startMarkers do
		if isElement(startMarkers[i]) then
			destroyElement(startMarkers[i])
		end
	end

	startMarkers = {}

	for i = 1, #JOB_START_POSITIONS do
		local v = JOB_START_POSITIONS[i]

		local markerElement = createMarker(v[1], v[2], v[3], "checkpoint", 3, 61, 122, 188)
		local blipElement = createBlip(v[1], v[2], v[3], 0, 2, 61, 122, 188)

		table.insert(startMarkers, markerElement)
		setElementData(markerElement, "jobStart", true, false)

		table.insert(startMarkers, blipElement)
		setElementData(blipElement, "blipTooltipText", "Munkakezdés")
	end

	exports.see_hud:delJobBlips()

	if theJob.started then
		if not reset then
			local itemPayment = 0

			for i = 1, #loadingBays do
				local v = loadingBays[i]

				if v[9] and v[12] then
					for j = 1, #v[12] do
						local obj = v[12][j]
						local item = objectItem[obj]

						itemPayment = itemPayment + items[item].value * (1 - objectHealth[obj] / 100)
					end

					v[12] = {}
				end
			end

			outputChatBox("#3d7abc[StrongMTA - Áruszállító]: #ffffff", 255, 255, 255, true)
			outputChatBox("   - Fizetés: #3d7abc27000$", 255, 255, 255, true)

			itemPayment = math.floor(itemPayment)

			if itemPayment > 30 then
				outputChatBox("   - Áru sérülés: #d75959-" .. itemPayment .. "$", 255, 255, 255, true)
			end

			local truckPayment = math.floor(2500 * (1 - getElementHealth(theJob.vehicle) / 1000))

			if truckPayment > 50 then
				outputChatBox("   - Teherautó sérülés: #d75959-" .. truckPayment .. "$", 255, 255, 255, true)
			end

			triggerServerEvent("@Í@Äí{€&ł&äđ", localPlayer, 150000 - itemPayment - truckPayment)
		end

		setElementData(localPlayer, "carrierActive", false)
		setElementData(localPlayer, "carringItem", false)

		if isElement(theJob.vehicle) then
			local door = getElementData(theJob.vehicle, "yankeeState") or "close"

			if door == "open" or door == "up" then
				setElementData(theJob.vehicle, "yankeeState", "close")
			elseif door == "down" then
				setElementData(theJob.vehicle, "yankeeState", "up")

				setTimer(
					function (vehicle)
						if isElement(vehicle) then
							setElementData(vehicle, "yankeeState", "close")
						end
					end,
				3100, 1, theJob.vehicle)
			end

			setElementData(theJob.vehicle, "truckPlacedObjects", false)
			setElementData(theJob.vehicle, "jobWithCar", false)
			setElementData(theJob.vehicle, "carrierPlacedInTruck", {unpack(CARRIER_DEFAULT_POSITION)})
		end

		for k in pairs(theJob.objects) do
			if isElement(theJob.objects[k]) then
				destroyElement(theJob.objects[k])
			end
		end

		theJob = {}
	end

	for i = 1, #loadingBays do
		local v = loadingBays[i]

		if v then
			if isElement(v[6]) then
				destroyElement(v[6])
			end

			if isElement(v[7]) then
				destroyElement(v[7])
			end
		end
	end

	loadingBays = {}
	standingLoadingBay = false
	carrierObject = false
	truckObjectItem = {}

	if isElement(Roboto) then
		destroyElement(Roboto)
	end
end

function startTheJob()
	if not truckerJob then
		return
	end

	if getTickCount() - lastJobStart <= 5000 then
		return
	end

	lastJobStart = getTickCount()

	local theVehicle = getPedOccupiedVehicle(localPlayer)

	if not theVehicle then
		exports.see_hud:showInfobox("e", "A munkát csak Vapid Benson típusú kocsival tudod elkezdeni.")
		return
	end

	if getElementModel(theVehicle) ~= TRUCK_MODEL then
		exports.see_hud:showInfobox("e", "A munkát csak Vapid Benson típusú kocsival tudod elkezdeni.")
		return
	end

	if getElementData(theVehicle, "jobWithCar") then
		exports.see_hud:showInfobox("e", "Ezzel a kocsival már valaki dolgozik.")
		return
	end

	endJob(true)
	triggerServerEvent("tryToStartTruckerJob", localPlayer)
end

addEvent("onTruckerJobStarted", true)
addEventHandler("onTruckerJobStarted", localPlayer,
	function (startDestinations, finalDestinations)
		for i = 1, #startMarkers do
			if isElement(startMarkers[i]) then
				destroyElement(startMarkers[i])
			end
		end

		startMarkers = {}

		local pickedCompanies = {}
		local pickableObjects = {}

		for i = 1, #startDestinations do
			local selectedCompanyIndex = startDestinations[i][1]
			local selectedItemIndex = startDestinations[i][2]
			local numOfPickableItems = startDestinations[i][3]

			local selectedCompany = companies[selectedCompanyIndex]
			local selectedItem = items[selectedItemIndex]

			local itemPositionsOriginal = shallowcopy(selectedCompany.itemPositions)

			for j = 1, numOfPickableItems do
				local pickedItemPositionIndex = math.random(1, #itemPositionsOriginal)
				local itemPositionsCopy = shallowcopy(itemPositionsOriginal)

				itemPositionsOriginal = {}

				for k = 1, #itemPositionsCopy do
					if k ~= pickedItemPositionIndex then
						table.insert(itemPositionsOriginal, itemPositionsCopy[k])
					end
				end

				local pickedItemPosition = itemPositionsCopy[pickedItemPositionIndex]
				local objectElement = createObject(selectedItem.model, unpack(pickedItemPosition))

				if isElement(objectElement) then
					local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(objectElement)

					setElementPosition(objectElement, pickedItemPosition[1], pickedItemPosition[2], pickedItemPosition[3] - minZ)
					setElementData(objectElement, "pickableObjectForTruck", selectedItemIndex, false)
					table.insert(pickableObjects, objectElement)

					objectItem[objectElement] = selectedItemIndex
					objectHealth[objectElement] = 100
				end
			end

			exports.see_hud:addJobBlips(selectedCompany.blip)

			table.insert(pickedCompanies, {"BERAKODÁS:", selectedCompany.name, selectedItem.name, selectedItem.fragile == "TÖRÉKENY" or "-"})
			table.insert(loadingBays, {
				selectedCompany.loadingBay[1],
				selectedCompany.loadingBay[2],
				selectedCompany.loadingBay[3],
				selectedCompany.loadingBay[4],
				tocolor(223, 181, 81),
				selectedCompany.loadingBay[6],
				selectedCompany.loadingBay[7],
				selectedCompany.loadingBay[8],
				false,
				false,
				selectedItemIndex
			})
		end

		for i = 1, #finalDestinations do
			local selectedCompanyIndex = finalDestinations[i][1]
			local selectedItemIndex = finalDestinations[i][2]
			local numOfPickableItems = finalDestinations[i][3]

			local selectedCompany = companies[selectedCompanyIndex]
			local selectedItem = items[selectedItemIndex]

			exports.see_hud:addJobBlips(selectedCompany.blip)

			table.insert(pickedCompanies, {"KIRAKODÁS:", selectedCompany.name, selectedItem.name, selectedItem.fragile == "TÖRÉKENY" or "-"})
			table.insert(loadingBays, {
				selectedCompany.loadingBay[1],
				selectedCompany.loadingBay[2],
				selectedCompany.loadingBay[3],
				selectedCompany.loadingBay[4],
				tocolor(255, 255, 255),
				selectedCompany.loadingBay[6],
				selectedCompany.loadingBay[7],
				selectedCompany.loadingBay[8],
				selectedItemIndex,
				numOfPickableItems
			})
		end

		theJob = {}
		theJob.started = true
		theJob.objects = pickableObjects
		theJob.companies = pickedCompanies
		theJob.vehicle = getPedOccupiedVehicle(localPlayer)

		setElementData(theJob.vehicle, "yankeeState", "close")
		setElementData(theJob.vehicle, "truckPlacedObjects", false)
		setElementData(theJob.vehicle, "jobWithCar", localPlayer)

		createLoadingBays()

		if isElement(Roboto) then
			destroyElement(Roboto)
		end

		Roboto = dxCreateFont("files/fonts/Roboto.ttf", respc(17.5), false, "antialiased")

		outputChatBox("#3d7abc[StrongMTA - Áruszállító]: #ffffffElkezdted a munkát!", 255, 255, 255, true)
		outputChatBox("#3d7abc[StrongMTA - Áruszállító]: #ffffffA feladatod az, hogy elszállítsd az árut a #3d7abcdepókból#ffffff.", 255, 255, 255, true)
		outputChatBox("#3d7abc[StrongMTA - Áruszállító]: #ffffffAz utad állomásait a fuvarlevelen láthatod (#598ed7/fuvarlevel#ffffff).", 255, 255, 255, true)
		outputChatBox("#3d7abc[StrongMTA - Áruszállító]: #ffffffA #3d7abcmolnárkocsit#ffffff az autód hátuljában találod. #598ed7Jobb klikk#ffffff rá, a felvételéhez.", 255, 255, 255, true)
	end
)

addEventHandler("onClientPlayerSpawn", localPlayer,
	function ()
		if getElementData(localPlayer, "char.Job") == 2 then
			endJob(true)
		end
	end
)

addEventHandler("onClientMarkerHit", getResourceRootElement(),
	function (hitPlayer)
		if hitPlayer == localPlayer then
			if getElementData(source, "jobStart") then
				startTheJob()
			end
		end
	end
)

addEventHandler("onClientColShapeHit", getResourceRootElement(),
	function (hitElement)
		if hitElement == localPlayer then
			for i = 1, #loadingBays do
				if source == loadingBays[i][7] then
					standingLoadingBay = loadingBays[i]
					break
				end
			end
		end
	end
)

addEventHandler("onClientColShapeLeave", getResourceRootElement(),
	function (leftElement)
		if leftElement == localPlayer then
			if standingLoadingBay then
				if source == standingLoadingBay[7] then
					standingLoadingBay = false
				end
			end
		end
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		truckerJob = false

		if getElementData(localPlayer, "char.Job") == 2 then
			truckerJob = true
			endJob(true)
		end

		local col = engineLoadCOL("files/models/ajto_mesh.col")
		engineReplaceCOL(col, DOOR_MESH_MODEL)
		local txd = engineLoadDFF("files/models/ajto_mesh.dff")
		engineReplaceModel(txd, DOOR_MESH_MODEL)

		local txd = engineLoadTXD("files/models/tolo.txd")
		engineImportTXD(txd, CARRIER_MODEL)
		local col = engineLoadCOL("files/models/tolo.col")
		engineReplaceCOL(col, CARRIER_MODEL)
		local dff = engineLoadDFF("files/models/tolo.dff")
		engineReplaceModel(dff, CARRIER_MODEL)

		for k, v in pairs(getElementsByType("vehicle")) do
			if getElementModel(v) == TRUCK_MODEL then
				if isElementStreamedIn(v) then
					if isElement(doorMesh[v]) then
						destroyElement(doorMesh[v])
					end

					doorMesh[v] = nil
					doorMesh[v] = createObject(DOOR_MESH_MODEL, 0, 0, 0)

					setElementCollidableWith(doorMesh[v], v, false)
				end

				doorState[v] = getElementData(v, "yankeeState") or "close"
				doorInAnim[v] = false

				resetVehicleComponentPosition(v, "boot_dummy")
				resetVehicleComponentRotation(v, "boot_dummy")

				local vehicleX, vehicleY, vehicleZ = getElementPosition(v)
				local componentX, componentY, componentZ = getVehicleComponentPosition(v, "boot_dummy")
				local groundZ = getGroundPosition(vehicleX, vehicleY, vehicleZ) - vehicleZ + 0.025

				if doorState[v] == "open" then
					setVehicleComponentPosition(v, "boot_dummy", componentX, componentY, componentZ)
					setVehicleComponentRotation(v, "boot_dummy", -90, 0, 0)
				elseif doorState[v] == "close" then
				elseif doorState[v] == "down" then
					setVehicleComponentPosition(v, "boot_dummy", componentX, componentY, groundZ)
					setVehicleComponentRotation(v, "boot_dummy", -90, 0, 0)
				elseif doorState[v] == "up" then
					setVehicleComponentPosition(v, "boot_dummy", componentX, componentY, DOOR_DEFAULT_Z)
					setVehicleComponentRotation(v, "boot_dummy", -90, 0, 0)
				end
			end
		end
	end
)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		if theJob.started then
			setElementData(theJob.vehicle, "yankeeState", "close")
			setElementData(theJob.vehicle, "truckPlacedObjects", false)
			setElementData(theJob.vehicle, "jobWithCar", false)
			setElementData(theJob.vehicle, "carrierPlacedInTruck", {unpack(CARRIER_DEFAULT_POSITION)})

			setElementData(localPlayer, "carrierActive", false)
			setElementData(localPlayer, "carringItem", false)
		end
	end
)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if getElementModel(source) == TRUCK_MODEL then
			if source == theJob.vehicle then
				endJob(true)
			end

			if isElement(doorMesh[source]) then
				destroyElement(doorMesh[source])
			end

			if isElement(doorSound[source]) then
				destroyElement(doorSound[source])
			end

			if isElement(truckPlacedCarrier[source]) then
				destroyElement(truckPlacedCarrier[source])
			end

			if truckPlacedObjects[source] then
				for i = 1, #truckPlacedObjects[source] do
					if isElement(truckPlacedObjects[source][i]) then
						destroyElement(truckPlacedObjects[source][i])
					end
				end
			end

			truckPlacedObjects[source] = nil
			truckPlacedCarrier[source] = nil

			doorMesh[source] = nil
			doorState[source] = nil
			doorInAnim[source] = nil
			doorSound[source] = nil
		end
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementModel(source) == TRUCK_MODEL then
			if isElement(doorMesh[source]) then
				destroyElement(doorMesh[source])
			end

			doorMesh[source] = nil
			doorMesh[source] = createObject(DOOR_MESH_MODEL, 0, 0, 0)

			setElementCollidableWith(doorMesh[source], source, false)

			local vehicleX, vehicleY, vehicleZ = getElementPosition(source)
			local componentX, componentY, componentZ = getVehicleComponentPosition(source, "boot_dummy")
			local groundZ = getGroundPosition(vehicleX, vehicleY, vehicleZ) - vehicleZ + 0.025

			doorState[source] = getElementData(source, "yankeeState") or "close"
			doorInAnim[source] = false

			if doorState[source] == "open" then
				setVehicleComponentPosition(source, "boot_dummy", componentX, componentY, componentZ)
				setVehicleComponentRotation(source, "boot_dummy", -90, 0, 0)
			elseif doorState[source] == "close" then
				if isElement(truckPlacedCarrier[source]) then
					destroyElement(truckPlacedCarrier[source])
				end

				resetVehicleComponentPosition(source, "boot_dummy")
				resetVehicleComponentRotation(source, "boot_dummy")
			elseif doorState[source] == "down" then
				setVehicleComponentPosition(source, "boot_dummy", componentX, componentY, groundZ)
				setVehicleComponentRotation(source, "boot_dummy", -90, 0, 0)
			elseif doorState[source] == "up" then
				setVehicleComponentPosition(source, "boot_dummy", componentX, componentY, DOOR_DEFAULT_Z)
				setVehicleComponentRotation(source, "boot_dummy", -90, 0, 0)
			end

			for k, v in pairs(doorAnimation) do
				if v.vehicle == source then
					doorAnimation[k] = nil
				end
			end
		end
	end
)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if getElementModel(source) == TRUCK_MODEL then
			if isElement(doorMesh[source]) then
				destroyElement(doorMesh[source])
			end

			doorMesh[source] = nil
		end
	end
)

addEventHandler("onClientPlayerQuit", getRootElement(),
	function ()
		if carringItem[source] then
			if isElement(carringItem[source]) then
				destroyElement(carringItem[source])
			end

			carringItem[source] = nil
		end
	end
)

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if isPedInVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			local theVeh = getPedOccupiedVehicle(localPlayer)

			if getElementModel(theVeh) == TRUCK_MODEL then
				local state = getElementData(theVeh, "yankeeState") or "close"

				if state ~= "close" then
					local task = getPedSimplestTask(localPlayer)

					if task == "TASK_SIMPLE_CAR_GET_OUT" or task == "TASK_SIMPLE_CAR_CLOSE_DOOR_FROM_OUTSIDE" then
						return
					end

					local keys = {}

					for k, v in pairs(getBoundKeys("accelerate")) do
						table.insert(keys, k)
					end

					for k, v in pairs(getBoundKeys("brake_reverse")) do
						table.insert(keys, k)
					end

					for k, v in pairs(keys) do
						if v == key then
							cancelEvent()

							if press then
								exports.see_hud:showInfobox("e", "Előbb zárd be a teherautó hátsóajtaját!")
							end
						end
					end
				end
			end
		end
	end
)

bindKey("e", "down",
	function ()
		if carringItem[localPlayer] then
			if activeTruckTrunk then
				if isElement(carringItem[localPlayer]) then
					if activeTruckTrunk ~= theJob.vehicle then
						exports.see_hud:showInfobox("e", "Ez nem a te kocsid!")
						return
					end

					local x, y, z = getElementPosition(carringItem[localPlayer])
					local rx, ry, rz = getElementRotation(carringItem[localPlayer])

					local model = getElementModel(carringItem[localPlayer])
					local matrix = getElementMatrix(carringItem[localPlayer])

					local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(carringItem[localPlayer])
					local linePoints = {minX, minY, maxX, minY, minX, maxY, maxX, maxY, minX, 0, maxX, 0, 0, minY, 0, maxY, 0, 0}

					for i = 1, #linePoints, 2 do
						for j = 0, 1 do
							local tx, ty, tz = getPositionFromOffset(matrix, linePoints[i], linePoints[i + 1], minZ + maxZ * j)

							if not isLineOfSightClear(x, y, z, tx, ty, tz, true, true, false, true, true, false, false, carrierObject) then
								exports.see_hud:showInfobox("e", "Ide nem rakhatod le, mert valamivel ütközik a tárgy!")
								return
							end
						end
					end

					triggerServerEvent("attachItemToTruck", localPlayer, model, {x, y, z - 0.2}, {0, 0, rz}, activeTruckTrunk, currentObjectId, currentObjectHealth)
					activeTruckTrunk = false
					destroyElement(carringItem[localPlayer])
				end

				setElementData(localPlayer, "carringItem", false)
				carringItem[localPlayer] = nil
			else
				local playerX, playerY, playerZ = getElementPosition(localPlayer)

				for i = 1, #loadingBays do
					local dat = loadingBays[i]

					if isElementWithinColShape(carringItem[localPlayer], dat[7]) then
						if isElement(carringItem[localPlayer]) then
							local _, _, minZ = getElementBoundingBox(localPlayer)
							local groundZ = getGroundPosition(dat[1], dat[2], dat[8])

							if math.abs(playerZ + minZ - groundZ) >= 1 then
								exports.see_hud:showInfobox("e", "Előbb szállj le a földre!")
								return
							end

							local x, y, z = getElementPosition(carringItem[localPlayer])
							local rx, ry, rz = getElementRotation(carringItem[localPlayer])
							local groundZ = getGroundPosition(x, y, z)

							local matrix = getElementMatrix(carringItem[localPlayer])
							local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(carringItem[localPlayer])
							local linePoints = {minX, minY, maxX, minY, minX, maxY, maxX, maxY, minX, 0, maxX, 0, 0, minY, 0, maxY, 0, 0}

							for i = 1, #linePoints, 2 do
								for j = 0, 1 do
									local tx, ty, tz = getPositionFromOffset(matrix, linePoints[i], linePoints[i + 1], minZ + maxZ * j)

									if not isLineOfSightClear(x, y, z, tx, ty, tz, true, true, false, true, true, false, false, carrierObject) then
										exports.see_hud:showInfobox("e", "Ide nem rakhatod le, mert valamivel ütközik a tárgy!")
										return
									end
								end
							end

							local obj = createObject(getElementModel(carringItem[localPlayer]), x, y, groundZ - minZ, 0, 0, rz)

							if isElement(obj) then
								setElementData(obj, "pickableObjectForTruck", true)

								objectItem[obj] = currentObjectId
								objectHealth[obj] = currentObjectHealth

								table.insert(theJob.objects, obj)

								destroyElement(carringItem[localPlayer])
								setElementData(localPlayer, "carringItem", false)

								if dat[9] then
									if isElementWithinColShape(obj, dat[7]) then
										if dat[9] == currentObjectId then
											dat[11] = (dat[11] or 0) + 1

											if not dat[12] then
												dat[12] = {}
											end

											table.insert(dat[12], obj)
										end
									end
								end
							end
						end

						break
					end
				end

				local itemsDelivered = true

				for i = 1, #loadingBays do
					local dat = loadingBays[i]

					if dat[9] and dat[11] ~= dat[10] then
						itemsDelivered = false
					end
				end

				if itemsDelivered then
					endJob()
				end
			end
		else
			if activeTruckTrunk then
				if carrierObject then
					local matrix = getElementMatrix(carrierObject)
					local x, y, z = getElementPosition(localPlayer)
					local tx, ty, tz = getPositionFromOffset(matrix, 0.2, 0.6, 0.2)

					if not isLineOfSightClear(x, y, z, tx, ty, tz, true, true, false, true, true, false, false, carrierObject) then
						exports.see_hud:showInfobox("e", "Ide nem rakhatod le, mert valamivel ütközik a tárgy!")
						return
					end

					tx, ty, tz = getPositionFromOffset(matrix, -0.3, 0.6, 0.2)

					if not isLineOfSightClear(x, y, z, tx, ty, tz, true, true, false, true, true, false, false, carrierObject) then
						exports.see_hud:showInfobox("e", "Ide nem rakhatod le, mert valamivel ütközik a tárgy!")
						return
					end

					tx, ty, tz = getPositionFromOffset(matrix, 0.3, 0.6, 0.2)

					if not isLineOfSightClear(x, y, z, tx, ty, tz, true, true, false, true, true, false, false, carrierObject) then
						exports.see_hud:showInfobox("e", "Ide nem rakhatod le, mert valamivel ütközik a tárgy!")
						return
					end

					local x, y, z = getElementPosition(carrierObject)
					local rx, ry, rz = getElementRotation(carrierObject)

					carrierObject = false

					setElementData(localPlayer, "carrierActive", false)
					attachRotationAdjusted({x, y, z}, {0, 0, rz}, activeTruckTrunk)

					activeTruckTrunk = false
				end
			end
		end
	end
)

function attachRotationAdjusted(position, rotation, vehicle)
	local frPosX, frPosY, frPosZ = unpack(position)
	local frRotX, frRotY, frRotZ = unpack(rotation)

	local toPosX, toPosY, toPosZ = getElementPosition(vehicle)
	local toRotX, toRotY, toRotZ = getElementRotation(vehicle)

	local offsetPosX = frPosX - toPosX
	local offsetPosY = frPosY - toPosY
	local offsetPosZ = frPosZ - toPosZ

	local offsetRotX = frRotX - toRotX
	local offsetRotY = frRotY - toRotY
	local offsetRotZ = frRotZ - toRotZ

	offsetPosX, offsetPosY, offsetPosZ = applyInverseRotation(offsetPosX, offsetPosY, offsetPosZ, toRotX, toRotY, toRotZ)

	setElementData(vehicle, "carrierPlacedInTruck", {offsetPosX, offsetPosY, offsetPosZ, offsetRotZ})
end

function applyInverseRotation(x, y, z, rx, ry, rz)
	rx = math.rad(rx)
	ry = math.rad(ry)
	rz = math.rad(rz)

	local tempY = y
	y =  math.cos(rx) * tempY + math.sin(rx) * z
	z = -math.sin(rx) * tempY + math.cos(rx) * z

	local tempX = x
	x =  math.cos(ry) * tempX - math.sin(ry) * z
	z =  math.sin(ry) * tempX + math.cos(ry) * z

	tempX = x
	x =  math.cos(rz) * tempX + math.sin(rz) * y
	y = -math.sin(rz) * tempX + math.cos(rz) * y

	return x, y, z
end

function processTruckPlacedObjects(vehicle)
	local vehicleX, vehicleY, vehicleZ = getElementPosition(vehicle)
	local placedObjects = getElementData(vehicle, "truckPlacedObjects")
	local createdObjects = {}

	if placedObjects then
		for i = 1, #placedObjects do
			local dat = placedObjects[i]
			local obj = createObject(dat[1], vehicleX, vehicleY, vehicleZ)

			createdObjects[i] = obj

			attachElements(obj, vehicle, dat[2], dat[3], dat[4], dat[5], dat[6], dat[7])
			setElementCollidableWith(obj, vehicle, false)

			if vehicle == theJob.vehicle then
				setElementData(obj, "objectID", dat[8])
				setElementData(obj, "objectHealth", dat[9])

				truckObjectItem[obj] = dat[8]
			end
		end
	end

	if truckPlacedObjects[vehicle] then
		for i = 1, #truckPlacedObjects[vehicle] do
			if isElement(truckPlacedObjects[vehicle][i]) then
				destroyElement(truckPlacedObjects[vehicle][i])
			end
		end
	end

	truckPlacedObjects[vehicle] = {}

	if placedObjects then
		for i = 1, #createdObjects do
			table.insert(truckPlacedObjects[vehicle], createdObjects[i])
		end
	end
end

addEventHandler("onClientVehicleEnter", getRootElement(),
	function (enterPlayer)
		if enterPlayer == localPlayer then
			local placedObjects = getElementData(source, "truckPlacedObjects") or {}
			local objectCount = 0

			totalItemHealth = 0

			for i = 1, #placedObjects do
				local dat = placedObjects[i]

				if dat and dat[9] then
					objectCount = objectCount + 1
					totalItemHealth = totalItemHealth + dat[9]
				end
			end

			if objectCount > 0 then
				totalItemHealth = totalItemHealth / objectCount
			else
				totalItemHealth = 100
			end
		end
	end
)

addEventHandler("onClientVehicleCollision", getRootElement(),
	function (collider, force)
		if getElementModel(source) == TRUCK_MODEL then
			if source == getPedOccupiedVehicle(localPlayer) then
				if getPedOccupiedVehicleSeat(localPlayer) == 0 then
					if force > 100 then
						local placedObjects = getElementData(source, "truckPlacedObjects") or {}

						for i = 1, #placedObjects do
							local dat = placedObjects[i]

							if dat then
								if items[dat[8]].fragile then
									dat[9] = dat[9] - math.random(5, 15) * (force / 2000) * 2
								else
									dat[9] = dat[9] - math.random(5, 15) * (force / 2000)
								end

								if dat[9] < 0 then
									dat[9] = 0
								end
							end
						end

						setElementData(source, "truckPlacedObjects", placedObjects)
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldVal)
		if source == localPlayer then
			if dataName == "char.Job" then
				truckerJob = false

				for i = 1, #startMarkers do
					if isElement(startMarkers[i]) then
						destroyElement(startMarkers[i])
					end
				end

				if getElementData(localPlayer, "char.Job") == 2 then
					truckerJob = true
					endJob(true)
				end
			end

			if dataName == "carrierObject" then
				carrierObject = getElementData(source, dataName)
			end

			if dataName == "carrierActive" then
				if getElementData(source, dataName) then
					exports.see_controls:toggleControl({"crouch", "sprint", "jump", "aim_weapon", "fire", "enter_exit", "enter_passenger"}, false)
				else
					exports.see_controls:toggleControl({"crouch", "sprint", "jump", "aim_weapon", "fire", "enter_exit", "enter_passenger"}, true)
					carrierObject = false
				end
			end
		end

		if dataName == "truckPlacedObjects" then
			if getElementData(source, "yankeeState") ~= "close" then
				processTruckPlacedObjects(source)
			end

			if source == getPedOccupiedVehicle(localPlayer) then
				local placedObjects = getElementData(source, "truckPlacedObjects") or {}
				local objectCount = 0

				totalItemHealth = 0

				for i = 1, #placedObjects do
					local dat = placedObjects[i]

					if dat and dat[9] then
						objectCount = objectCount + 1
						totalItemHealth = totalItemHealth + dat[9]
					end
				end

				if objectCount > 0 then
					totalItemHealth = totalItemHealth / objectCount
				else
					totalItemHealth = 100
				end
			end
		end

		if dataName == "carringItem" then
			if isElement(carringItem[source]) then
				destroyElement(carringItem[source])
			end

			carringItem[source] = nil

			local itemModel = getElementData(source, dataName)

			if itemModel then
				carringItem[source] = createObject(itemModel, 0, 0, 0)
				setElementCollisionsEnabled(carringItem[source], false)
				attachElements(carringItem[source], source, unpack(offsets[itemModel]))
			end
		end

		if dataName == "carrierPlacedInTruck" then
			local vehicleX, vehicleY, vehicleZ = getElementPosition(source)
			local carrierPosition = getElementData(source, "carrierPlacedInTruck")

			if isElement(truckPlacedCarrier[source]) then
				destroyElement(truckPlacedCarrier[source])
			end

			truckPlacedCarrier[source] = nil

			if carrierPosition then
				truckPlacedCarrier[source] = createObject(CARRIER_MODEL, 0, 0, 0)

				attachElements(truckPlacedCarrier[source], source, carrierPosition[1], carrierPosition[2], carrierPosition[3], 0, 0, carrierPosition[4])
				setObjectScale(truckPlacedCarrier[source], 0.95, 0.975, 0.975)
				setElementCollidableWith(truckPlacedCarrier[source], source, false)

				setElementPosition(source, vehicleX, vehicleY, vehicleZ + 0.001)
			end
		end

		if dataName == "yankeeState" then
			doorState[source] = getElementData(source, "yankeeState")
			doorInAnim[source] = true

			local vehicleX, vehicleY, vehicleZ = getElementPosition(source)
			local componentX, componentY, componentZ = getVehicleComponentPosition(source, "boot_dummy")
			local groundZ = getGroundPosition(vehicleX, vehicleY, vehicleZ) - vehicleZ + 0.025

			local interpolationDetails = {
				startTime = getTickCount(),
				duration = 3000,
				easing = "InOutQuad",
				vehicle = source
			}

			if oldVal == "close" and doorState[source] ~= "close" then
				processTruckPlacedObjects(source)

				if isElement(truckPlacedCarrier[source]) then
					destroyElement(truckPlacedCarrier[source])
				end

				truckPlacedCarrier[source] = nil

				local carrierPosition = getElementData(source, "carrierPlacedInTruck")

				if carrierPosition then
					truckPlacedCarrier[source] = createObject(CARRIER_MODEL, 0, 0, 0)

					attachElements(truckPlacedCarrier[source], source, carrierPosition[1], carrierPosition[2], carrierPosition[3], 0, 0, carrierPosition[4])
					setObjectScale(truckPlacedCarrier[source], 0.95, 0.975, 0.975)

					setElementPosition(source, vehicleX, vehicleY, vehicleZ + 0.001)
				end
			end

			if doorState[source] == "close" then
				if oldVal and oldVal ~= "close" then
					doorSound[source] = playSound3D("files/sounds/close.mp3", vehicleX, vehicleY, vehicleZ)
				end
			else
				doorSound[source] = playSound3D("files/sounds/hydra.mp3", vehicleX, vehicleY, vehicleZ)
			end

			setTimer(
				function (vehicle)
					if vehicle then
						if isElement(doorSound[vehicle]) then
							destroyElement(doorSound[vehicle])
						end

						doorSound[vehicle] = nil
					end
				end,
			2990, 1, source)

			if doorState[source] == "open" then
				interpolationDetails.startPos = {componentX, componentY, componentZ}
				interpolationDetails.startRot = {0, 0, 0}
				interpolationDetails.endPos = {componentX, componentY, componentZ}
				interpolationDetails.endRot = {-90, 0, 0}
			elseif doorState[source] == "close" then
				interpolationDetails.startPos = {componentX, componentY, componentZ}
				interpolationDetails.startRot = {-90, 0, 0}
				interpolationDetails.endPos = {componentX, componentY, componentZ}
				interpolationDetails.endRot = {0, 0, 0}

				setTimer(
					function (vehicle)
						if vehicle then
							if truckPlacedObjects[vehicle] then
								for i = 1, #truckPlacedObjects[vehicle] do
									if isElement(truckPlacedObjects[vehicle][i]) then
										destroyElement(truckPlacedObjects[vehicle][i])
									end
								end
							end

							truckPlacedObjects[vehicle] = {}

							if isElement(truckPlacedCarrier[vehicle]) then
								destroyElement(truckPlacedCarrier[vehicle])
							end

							if vehicle == theJob.vehicle then
								truckObjectItem = {}
							end

							resetVehicleComponentPosition(vehicle, "boot_dummy")
							resetVehicleComponentRotation(vehicle, "boot_dummy")
						end
					end, interpolationDetails.duration + 100, 1, source
				)
			elseif doorState[source] == "down" then
				interpolationDetails.startPos = {componentX, componentY, componentZ}
				interpolationDetails.startRot = {-90, 0, 0}
				interpolationDetails.endPos = {componentX, componentY, groundZ}
				interpolationDetails.endRot = {-90, 0, 0}
			elseif doorState[source] == "up" then
				interpolationDetails.startPos = {componentX, componentY, componentZ}
				interpolationDetails.startRot = {-90, 0, 0}
				interpolationDetails.endPos = {componentX, componentY, DOOR_DEFAULT_Z}
				interpolationDetails.endRot = {-90, 0, 0}
			end

			table.insert(doorAnimation, interpolationDetails)
		end
	end
)

addEventHandler("onClientPreRender", getRootElement(),
	function ()
		local currentTime = getTickCount()

		for k, v in pairs(doorAnimation) do
			if v.startPos and v.endPos then
				if isElement(v.vehicle) then
					local elapsedTime = currentTime - v.startTime
					local progress = elapsedTime / v.duration

					local x, y, z = interpolateBetween(
						v.startPos[1], v.startPos[2], v.startPos[3],
						v.endPos[1], v.endPos[2], v.endPos[3],
						progress, v.easing
					)

					local rx, ry, rz = interpolateBetween(
						v.startRot[1], v.startRot[2], v.startRot[3],
						v.endRot[1], v.endRot[2], v.endRot[3],
						progress, v.easing
					)

					if progress > 1 then
						doorAnimation[k] = nil
						doorInAnim[v.vehicle] = false
					end

					setVehicleComponentPosition(v.vehicle, "boot_dummy", x, y, z)
					setVehicleComponentRotation(v.vehicle, "boot_dummy", rx, ry, rz)
				end
			end
		end
	end
)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
		if button == "left" then
			if state == "down" then
				if theJob.vehicle and isPedInVehicle(localPlayer) then
					if absX >= panelPosX + respc(8) and absX <= panelPosX + panelWidth - respc(8) and absY >= panelPosY + panelHeight - respc(27) and absY <= panelPosY + panelHeight - respc(7) then
						executeCommandHandler("fuvarlevel")
					end
				end

				if activeDoorButton then
					setElementData(activeDoorButton[1], "yankeeState", activeDoorButton[2])
				end
			end
		end

		if state == "down" then
			if theJob.started then
				local camX, camY, camZ = getCameraMatrix()

				local targetX = camX + (worldX - camX) * 200
				local targetY = camY + (worldY - camY) * 200
				local targetZ = camZ + (worldZ - camZ) * 200

				local _, _, _, _, hitElement = processLineOfSight(camX, camY, camZ, targetX, targetY, targetZ, false, false, false, true, false, true, true, true, carrierObject)

				if hitElement then
					clickedElement = hitElement
				end
			end

			if theJob.vehicle then
				local playerX, playerY, playerZ = getElementPosition(localPlayer)

				if clickedElement == truckPlacedCarrier[theJob.vehicle] then
					if not carrierObject then
						if getDistanceBetweenPoints3D(playerX, playerY, playerZ, worldX, worldY, worldZ) < 2 then
							setElementData(localPlayer, "carrierActive", true)
							setElementData(theJob.vehicle, "carrierPlacedInTruck", false)
						end
					end
				elseif clickedElement then
					if carrierObject then
						if getElementData(clickedElement, "pickableObjectForTruck") then
							if getElementData(localPlayer, "carrierActive") then
								if not getElementData(localPlayer, "carringItem") then
									if getDistanceBetweenPoints3D(playerX, playerY, playerZ, worldX, worldY, worldZ) < 2 then
										local objectX, objectY, objectZ = getElementPosition(clickedElement)

										setElementPosition(clickedElement, objectX, objectY, objectZ + 0.1)
										setElementPosition(clickedElement, objectX, objectY, objectZ - 0.1)

										for i = 1, #loadingBays do
											local dat = loadingBays[i]

											if dat[9] then
												if dat[9] == objectItem[clickedElement] then
													if isElementWithinColShape(clickedElement, dat[7]) then
														dat[11] = (dat[11] or 0) - 1

														local placedItems = {}

														for j = 1, #dat[12] do
															if dat[12][j] ~= clickedElement then
																table.insert(placedItems, dat[12][j])
															end
														end

														dat[12] = placedItems
													end
												end
											end
										end

										currentObjectId = objectItem[clickedElement]
										currentObjectHealth = objectHealth[clickedElement]

										for i = 1, #theJob.objects do
											if theJob.objects[i] == clickedElement then
												theJob.objects[i] = nil
											end
										end

										local objectModel = getElementModel(clickedElement)

										if isElement(clickedElement) then
											destroyElement(clickedElement)
										end

										setElementData(localPlayer, "carringItem", objectModel)
										setElementPosition(localPlayer, playerX, playerY, playerZ + 0.001)
									end
								end
							end
						end

						if truckPlacedObjects[theJob.vehicle] then
							if not getElementData(localPlayer, "carringItem") then
								local objectFound = false
								local objectX, objectY, objectZ = getElementPosition(clickedElement)
								local objectModel = getElementModel(clickedElement)
								local remainingObjects = {}

								for i = 1, #truckPlacedObjects[theJob.vehicle] do
									local obj = truckPlacedObjects[theJob.vehicle][i]

									if obj == clickedElement then
										if getDistanceBetweenPoints3D(playerX, playerY, playerZ, objectX, objectY, objectZ) < 2 then
											objectFound = true

											currentObjectId = getElementData(obj, "objectID")
											currentObjectHealth = getElementData(obj, "objectHealth")

											if isElement(clickedElement) then
												destroyElement(clickedElement)
											end

											setElementData(localPlayer, "carringItem", objectModel)
											setElementPosition(localPlayer, playerX, playerY, playerZ + 0.001)
										end
									else
										table.insert(remainingObjects, obj)
									end
								end

								if objectFound then
									local placedObjects = {}

									for i = 1, #remainingObjects do
										local x, y, z, rx, ry, rz = getElementAttachedOffsets(remainingObjects[i])

										table.insert(placedObjects, {
											getElementModel(remainingObjects[i]),
											x, y, z,
											rx, ry, rz,
											getElementData(remainingObjects[i], "objectID"),
											getElementData(remainingObjects[i], "objectHealth")
										})

										if isElement(remainingObjects[i]) then
											destroyElement(remainingObjects[i])
										end
									end

									setElementData(theJob.vehicle, "truckPlacedObjects", placedObjects)
								end
							end
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local vehicles = getElementsByType("vehicle", getRootElement(), true)

		for i = 1, #vehicles do
			local veh = vehicles[i]

			if doorMesh[veh] then
				local componentPosX, componentPosY, componentPosZ = getVehicleComponentPosition(veh, "boot_dummy", "world")
				local componentRotX, componentRotY, componentRotZ = getVehicleComponentRotation(veh, "boot_dummy", "world")

				setElementPosition(doorMesh[veh], componentPosX, componentPosY, componentPosZ)
				setElementRotation(doorMesh[veh], componentRotX, componentRotY, componentRotZ)

				if doorSound[veh] then
					setElementPosition(doorSound[veh], componentPosX, componentPosY, componentPosZ)
				end
			end
		end

		for i = 1, #loadingBays do
			local v = loadingBays[i]

			if v then
				dxDrawMaterialLine3D(v[1] + v[3] / 2, v[2], v[8], v[1] + v[3] / 2, v[2] + v[4], v[8], v[6], v[3], v[5], v[1] + v[3] / 2, v[2] + v[4] / 2, v[8] + 1)
			end
		end

		if isElement(carrierObject) then
			if theJob.vehicle then
				local playerX, playerY, playerZ = getElementPosition(localPlayer)
				local objectX, objectY, objectZ = getElementPosition(carrierObject)
				local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(objectX, objectY, objectZ, objectX, objectY, objectZ - 1.5, false, true, false, false, false)

				activeTruckTrunk = false

				if carringItem[localPlayer] then
					local cameraX, cameraY, cameraZ = getCameraMatrix()

					if isElement(carringItem[localPlayer]) then
						local item = items[currentObjectId]

						if item.picture then
							local objectX, objectY, objectZ = getElementPosition(carringItem[localPlayer])
							local distance = getDistanceBetweenPoints3D(cameraX, cameraY, cameraZ, objectX, objectY, objectZ)

							if distance < 10 then
								if item.picOffset then
									objectZ = objectZ + item.picOffset
								end

								if isLineOfSightClear(cameraX, cameraY, cameraZ, objectX, objectY, objectZ, true, true, false, true, false, true, true, carringItem[localPlayer]) then
									local onScreenX, onScreenY = getScreenFromWorldPosition(objectX, objectY, objectZ)

									if onScreenX and onScreenY then
										local pictureSize = respc(384 / distance * 1.5)

										onScreenX = onScreenX - pictureSize / 2
										onScreenY = onScreenY - pictureSize / 2

										dxDrawImage(onScreenX + 1, onScreenY + 1, pictureSize, pictureSize, item.picture, 0, 0, 0, tocolor(0, 0, 0))
										dxDrawImage(onScreenX, onScreenY, pictureSize, pictureSize, item.picture, 0, 0, 0, item.picColor)
									end
								end
							end
						end
					end
				end

				if hit then
					if hitElement == theJob.vehicle then
						if getElementModel(hitElement) == TRUCK_MODEL then
							local vehicleX, vehicleY, vehicleZ = getElementPosition(hitElement)
							local groundLevelDifference = math.floor(vehicleZ - playerZ)

							if groundLevelDifference == -2 then
								local targetX, targetY, targetZ = getPositionFromElementOffset(hitElement, 0, -2.5, 1)

								if carringItem[localPlayer] then
									objectX, objectY, objectZ = getElementPosition(carringItem[localPlayer])
								end

								if getDistanceBetweenPoints3D(objectX, objectY, objectZ, targetX, targetY, targetZ) < 4 then
									activeTruckTrunk = hitElement

									if carringItem[localPlayer] then
										dxDrawText("A tárgy lerakásához nyomd meg az [E] gombot.", 1, screenY - respc(256) + 1, screenX + 1, screenY - respc(224) + 1, tocolor(0, 0, 0), 0.75, Roboto, "center", "center")
										dxDrawText("A tárgy lerakásához nyomd meg az #3d7abc[E]#ffffff gombot.", 0, screenY - respc(256), screenX, screenY - respc(224), tocolor(255, 255, 255), 0.75, Roboto, "center", "center", false, false, false, true)
									else
										dxDrawText("A molnárkocsi lerakásához nyomd meg az [E] gombot.\nEgy tárgy felvételéhez kattints rá.", 1, screenY - respc(256) + 1, screenX + 1, screenY - respc(224) + 1, tocolor(0, 0, 0), 0.75, Roboto, "center", "center")
										dxDrawText("A molnárkocsi lerakásához nyomd meg az #3d7abc[E]#ffffff gombot.\nEgy tárgy felvételéhez #3d7abckattints rá#ffffff.", 0, screenY - respc(256), screenX, screenY - respc(224), tocolor(255, 255, 255), 0.75, Roboto, "center", "center", false, false, false, true)
									end
								end
							end
						end
					end
				end
			end
		end

		if not isPedInVehicle(localPlayer) then
			if theJob.vehicle then
				if isElementStreamedIn(theJob.vehicle) then
					local relX, relY = getCursorPosition()
					local absX, absY = -1, -1

					if relX then
						absX = relX * screenX
						absY = relY * screenY
					end

					local playerX, playerY, playerZ = getElementPosition(localPlayer)
					local cameraX, cameraY, cameraZ = getCameraMatrix()

					-- Rakodóhelyek
					if standingLoadingBay then
						if standingLoadingBay[9] then
							local item = standingLoadingBay[9]

							local sx = respc(64) + dxGetTextWidth("Kirakodás: " .. items[item].name, 1, Roboto) + respc(50)
							local sy = respc(64)

							local x = screenX / 2 - sx / 2
							local y = screenY - respc(224)

							dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 150))
							dxDrawRectangle(x, y, sy, sy, tocolor(0, 0, 0, 100))

							dxDrawImage(x, y, sy, sy, items[item].mainIcon, 0, 0, 0, items[item].mainIcColor)
							dxDrawText("Kirakodás: #ffffff" .. items[item].name, x + sy, y, x + sx, y + sy, items[item].mainIcColor, 1, Roboto, "center", "center", false, false, false, true)

							dxDrawRectangle(x, y + sy, sx, respc(8), tocolor(0, 0, 0, 225))
							dxDrawRectangle(x, y + sy, sx * ((standingLoadingBay[11] or 0) / standingLoadingBay[10]), respc(8), items[item].mainIcColor)

							dxDrawText("A tárgy lerakásához nyomd meg az [E] gombot.", 1, screenY - respc(256) + 1, screenX + 1, screenY - respc(224) + 1, tocolor(0, 0, 0), 0.75, Roboto, "center", "center")
							dxDrawText("A tárgy lerakásához nyomd meg az #3d7abc[E]#ffffff gombot.", 0, screenY - respc(256), screenX, screenY - respc(224), tocolor(255, 255, 255), 0.75, Roboto, "center", "center", false, false, false, true)
						else
							local item = standingLoadingBay[11]

							local sx = respc(64) + dxGetTextWidth("Berakodás: " .. items[item].name, 1, Roboto) + respc(50)
							local sy = respc(64)

							local x = screenX / 2 - sx / 2
							local y = screenY - respc(224)

							dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 150))
							dxDrawRectangle(x, y, sy, sy, tocolor(0, 0, 0, 100))

							dxDrawImage(x, y, sy, sy, items[item].mainIcon, 0, 0, 0, items[item].mainIcColor)
							dxDrawText("Berakodás: #ffffff" .. items[item].name, x + sy, y, x + sx, y + sy, items[item].mainIcColor, 1, Roboto, "center", "center", false, false, false, true)

							dxDrawText("Egy tárgy felvételéhez kattints rá.", 1, screenY - respc(256) + 1, screenX + 1, screenY - respc(224) + 1, tocolor(0, 0, 0), 0.75, Roboto, "center", "center")
							dxDrawText("Egy tárgy felvételéhez #3d7abckattints rá#ffffff.", 0, screenY - respc(256), screenX, screenY - respc(224), tocolor(255, 255, 255), 0.75, Roboto, "center", "center", false, false, false, true)
						end
					end

					-- Item képek (rakodóhelyen)
					if theJob.objects then
						for k in pairs(theJob.objects) do
							local objectElement = theJob.objects[k]

							if isElement(objectElement) then
								if isElementOnScreen(objectElement) then
									local itemId = objectItem[objectElement]
									local item = items[itemId]

									if item.picture then
										local objectX, objectY, objectZ = getElementPosition(objectElement)
										local distance = getDistanceBetweenPoints3D(cameraX, cameraY, cameraZ, objectX, objectY, objectZ)

										if distance < 10 then
											if item.picOffset then
												objectZ = objectZ + item.picOffset
											end

											if isLineOfSightClear(cameraX, cameraY, cameraZ, objectX, objectY, objectZ, true, true, false, true, false, true, true, objectElement) then
												local onScreenX, onScreenY = getScreenFromWorldPosition(objectX, objectY, objectZ)

												if onScreenX and onScreenY then
													local pictureSize = respc(384 / distance * 1.5)

													onScreenX = onScreenX - pictureSize / 2
													onScreenY = onScreenY - pictureSize / 2

													dxDrawImage(onScreenX + 1, onScreenY + 1, pictureSize, pictureSize, item.picture, 0, 0, 0, tocolor(0, 0, 0))
													dxDrawImage(onScreenX, onScreenY, pictureSize, pictureSize, item.picture, 0, 0, 0, item.picColor)
												end
											end
										end
									end
								end
							else
								theJob.objects[k] = nil
							end
						end
					end

					-- Item képek (teherautóban)
					for objectElement, itemId in pairs(truckObjectItem) do
						if isElement(objectElement) then
							if isElementOnScreen(objectElement) then
								local item = items[itemId]

								if item.picture then
									local objectX, objectY, objectZ = getElementPosition(objectElement)
									local distance = getDistanceBetweenPoints3D(cameraX, cameraY, cameraZ, objectX, objectY, objectZ)

									if distance < 10 then
										if item.picOffset then
											objectZ = objectZ + item.picOffset
										end

										if isLineOfSightClear(cameraX, cameraY, cameraZ, objectX, objectY, objectZ, true, true, false, true, false, true, true, objectElement) then
											local onScreenX, onScreenY = getScreenFromWorldPosition(objectX, objectY, objectZ)

											if onScreenX and onScreenY then
												local pictureSize = respc(384 / distance * 1.5)

												onScreenX = onScreenX - pictureSize / 2
												onScreenY = onScreenY - pictureSize / 2

												dxDrawImage(onScreenX + 1, onScreenY + 1, pictureSize, pictureSize, item.picture, 0, 0, 0, tocolor(0, 0, 0))
												dxDrawImage(onScreenX, onScreenY, pictureSize, pictureSize, item.picture, 0, 0, 0, item.picColor)
											end
										end
									end
								end
							end
						end
					end

					-- Csomagtér ajtó kezelés
					if isElementOnScreen(theJob.vehicle) then
						local componentX, componentY, componentZ = getVehicleComponentPosition(theJob.vehicle, "revlight_l", "world")
						local distance = getDistanceBetweenPoints3D(componentX, componentY, componentZ, playerX, playerY, playerZ)

						if distance <= 3 then
							local distance = getDistanceBetweenPoints3D(componentX, componentY, componentZ, cameraX, cameraY, cameraZ)
							local onScreenX, onScreenY = getScreenFromWorldPosition(componentX, componentY, componentZ - 0.5)

							if onScreenX and onScreenY then
								local door = doorState[theJob.vehicle] or "close"
								local oneSize = respc(256 / distance * 1.5)

								onScreenX = onScreenX - oneSize / 2
								onScreenY = onScreenY - oneSize / 2

								activeDoorButton = false

								if door == "close" then
									local pictureColor = tocolor(61, 122, 188, 150)

									if doorInAnim[theJob.vehicle] then
										pictureColor = tocolor(215, 89, 89, 150)
									else
										if absX >= onScreenX and absX <= onScreenX + oneSize and absY >= onScreenY and absY <= onScreenY + oneSize then
											pictureColor = tocolor(61, 122, 188, 200)
											activeDoorButton = {theJob.vehicle, "open"}
										end
									end

									dxDrawRectangle(onScreenX, onScreenY, oneSize, oneSize, tocolor(0, 0, 0, 150))
									dxDrawImage(onScreenX, onScreenY, oneSize, oneSize, "files/images/open.png", 0, 0, 0, pictureColor)
								elseif door == "open" or door == "up" then
									local pictureColor = tocolor(61, 122, 188, 150)
									local pictureColor2 = tocolor(61, 122, 188, 150)

									if doorInAnim[theJob.vehicle] then
										pictureColor = tocolor(215, 89, 89, 150)
										pictureColor2 = tocolor(215, 89, 89, 150)
									else
										if absX >= onScreenX and absX <= onScreenX + oneSize and absY >= onScreenY and absY <= onScreenY + oneSize then
											pictureColor = tocolor(61, 122, 188, 200)
											activeDoorButton = {theJob.vehicle, "close"}
										else
											if absX >= onScreenX and absX <= onScreenX + oneSize and absY >= onScreenY + oneSize + 5 and absY <= onScreenY + oneSize + 5 + oneSize then
												pictureColor2 = tocolor(61, 122, 188, 200)
												activeDoorButton = {theJob.vehicle, "down"}
											end
										end
									end

									dxDrawRectangle(onScreenX, onScreenY, oneSize, oneSize, tocolor(0, 0, 0, 150))
									dxDrawImage(onScreenX, onScreenY, oneSize, oneSize, "files/images/close.png", 0, 0, 0, pictureColor)

									dxDrawRectangle(onScreenX, onScreenY + oneSize + 5, oneSize, oneSize, tocolor(0, 0, 0, 150))
									dxDrawImage(onScreenX, onScreenY + oneSize + 5, oneSize, oneSize, "files/images/down.png", 0, 0, 0, pictureColor2)
								elseif door == "down" then
									local pictureColor = tocolor(61, 122, 188, 150)

									if doorInAnim[theJob.vehicle] then
										pictureColor = tocolor(215, 89, 89, 150)
									else
										if absX >= onScreenX and absX <= onScreenX + oneSize and absY >= onScreenY and absY <= onScreenY + oneSize then
											pictureColor = tocolor(61, 122, 188, 200)
											activeDoorButton = {theJob.vehicle, "up"}
										end
									end

									dxDrawRectangle(onScreenX, onScreenY, oneSize, oneSize, tocolor(0, 0, 0, 150))
									dxDrawImage(onScreenX, onScreenY, oneSize, oneSize, "files/images/up.png", 0, 0, 0, pictureColor)
								end
							end
						end
					end
				end
			end
		elseif theJob.started then
			local theVehicle = getPedOccupiedVehicle(localPlayer)

			if theVehicle == theJob.vehicle and totalItemHealth then
				local sx, sy = panelWidth, panelHeight
				local x, y = panelPosX, panelPosY

				-- ** Keret
				dxDrawRectangle(x, y, sx, 2, tocolor(0, 0, 0, 200))
				dxDrawRectangle(x, y + sy - 2, sx, 2, tocolor(0, 0, 0, 200))
				dxDrawRectangle(x, y + 2, 2, sy - 4, tocolor(0, 0, 0, 200))
				dxDrawRectangle(x + sx - 2, y + 2, 2, sy - 4, tocolor(0, 0, 0, 200))

				-- ** Háttér
				dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 150))

				-- ** Cím
				dxDrawRectangle(x, y, sx, respc(25), tocolor(0, 0, 0, 200))
				dxDrawText("#3d7abcStrong#FFFFFFMTA - Sérülés", x + respc(5), y, x + sx, y + respc(25), tocolor(255, 255, 255), 0.75, Roboto, "left", "center", false, false, false, true)

				-- ** Content
				dxDrawText("Jármű:", x + respc(2), y + respc(25), x + respc(52), y + respc(25) * 2, tocolor(255, 255, 255), 0.55, Roboto, "center", "center")
				dxDrawText("Áru:", x + respc(2), y + respc(25) * 2, x + respc(52), y + respc(25) * 3, tocolor(255, 255, 255), 0.55, Roboto, "center", "center")

				local barWidth = sx - respc(62)
				local barHeight = respc(10)

				dxDrawRectangle(x + sx - barWidth - respc(7), y + respc(25) + respc(25) / 2 - barHeight / 2, barWidth, barHeight, tocolor(100, 100, 100, 100))
				dxDrawRectangle(x + sx - barWidth - respc(7), y + respc(25) + respc(25) / 2 - barHeight / 2, barWidth * getElementHealth(theVehicle) / 1000, barHeight, tocolor(215, 89, 89, 225))

				dxDrawRectangle(x + sx - barWidth - respc(7), y + respc(25) * 2 + respc(25) / 2 - barHeight / 2, barWidth, barHeight, tocolor(100, 100, 100, 100))
				dxDrawRectangle(x + sx - barWidth - respc(7), y + respc(25) * 2 + respc(25) / 2 - barHeight / 2, barWidth * totalItemHealth / 100, barHeight, tocolor(215, 89, 89, 225))

				-- ** Gombok
				local relX, relY = getCursorPosition()
				local absX, absY = -1, -1

				if relX then
					absX = relX * screenX
					absY = relY * screenY
				end

				-- Panel mozgatás
				if not moveDifferenceX and not moveDifferenceY then
					if absX >= x and absX <= x + sx and absY >= y and absY <= y + respc(25) then
						if not getKeyState("mouse1") then
							moveDifferenceX = absX - panelPosX
							moveDifferenceY = absY - panelPosY
						end
					end
				else
					if getKeyState("mouse1") then
						panelPosX = absX - moveDifferenceX
						panelPosY = absY - moveDifferenceY
					else
						moveDifferenceX = false
						moveDifferenceY = false
					end
				end

				-- Fuvarlevél
				if absX >= x + respc(8) and absX <= x + sx - respc(8) and absY >= y + sy - respc(27) and absY <= y + sy - respc(7) then
					dxDrawRectangle(x + respc(8), y + sy - respc(27), sx - respc(16), respc(20), tocolor(61, 122, 188))
				else
					dxDrawRectangle(x + respc(8), y + sy - respc(27), sx - respc(16), respc(20), tocolor(61, 122, 188, 200))
				end

				dxDrawText("Fuvarlevél megtekintése", x, y + sy - respc(27), x + sx, y + sy - respc(7), tocolor(0, 0, 0), 0.55, Roboto, "center", "center")
			end
		end

		if waybill then
			local relX, relY = getCursorPosition()
			local absX, absY = -1, -1

			if relX then
				absX = relX * screenX
				absY = relY * screenY
			end

			local sx, sy = respc(576), respc(382)
			local x = math.floor(screenX / 2 - sx / 2)
			local y = math.floor(screenY / 2 - sy / 2)

			dxDrawImage(x, y, sx, sy, "files/images/waybill.png")

			local closeAlpha = 180

			if absX >= x + sx - respc(28) and absX <= x + sx - respc(8) and absY >= y + respc(8) and absY <= y + respc(28) then
				closeAlpha = 225
			end

			dxDrawImage(x + sx - respc(28), y + respc(8), respc(20), respc(20), "files/images/closeicon.png", 0, 0, 0, tocolor(255, 255, 255, closeAlpha))

			dxDrawText(waybill.name, x + respc(25), y + respc(65), x + respc(199), y + respc(93), tocolor(0, 84, 166), 0.5, handFont, "center", "center", false, true, false, true)
			dxDrawText(waybill.name, x + respc(25), y + respc(350), x + respc(172), y + respc(350), tocolor(0, 84, 166), 0.5, lunabarFont, "center", "bottom", false, true, false, true)

			dxDrawText("Vapid Benson", x + respc(200), y + respc(65), x + respc(374), y + respc(93), tocolor(0, 84, 166), 0.5, handFont, "center", "center", false, true, false, true)
			dxDrawText(waybill.numberPlate, x + respc(375), y + respc(65), x + respc(550), y + respc(93), tocolor(0, 84, 166), 0.5, handFont, "center", "center", false, true, false, true)

			for i = 1, 4 do
				if waybill.companies[i] then
					local y2 = respc(40) * (i - 1)

					dxDrawText(waybill.companies[i][1], x + respc(25), y + respc(145) + y2 + respc(2), x + respc(199), y + respc(183) + y2 - respc(19), tocolor(0, 84, 166), 0.5, handFont, "center", "center", false, false, false, true)
					dxDrawText(waybill.companies[i][2], x + respc(25), y + respc(145) + y2 + respc(19), x + respc(199), y + respc(183) + y2 - respc(2), tocolor(0, 84, 166), 0.4, handFont, "center", "center", false, false, false, true)
					dxDrawText(waybill.companies[i][3], x + respc(200), y + respc(145) + y2, x + respc(374), y + respc(183) + y2, tocolor(0, 84, 166), 0.5, handFont, "center", "center", false, false, false, true)
					dxDrawText(waybill.companies[i][4], x + respc(375), y + respc(145) + y2, x + respc(550), y + respc(183) + y2, tocolor(0, 84, 166), 0.5, handFont, "center", "center", false, false, false, true)
				end
			end

			if closeAlpha == 225 then
				if getKeyState("mouse1") then
					waybill = false

					if isElement(handFont) then
						destroyElement(handFont)
					end

					if isElement(lunabarFont) then
						destroyElement(lunabarFont)
					end
				end
			end
		end
	end
)

function showWaybill()
	if isElement(handFont) then
		destroyElement(handFont)
	end

	if isElement(lunabarFont) then
		destroyElement(lunabarFont)
	end

	if not waybill and theJob.vehicle then
		handFont = dxCreateFont("files/fonts/hand.otf", respc(26), false, "antialiased")
		lunabarFont = dxCreateFont("files/fonts/lunabar.ttf", respc(34), false, "antialiased")

		waybill = {}
		waybill.name = getElementData(localPlayer, "visibleName"):gsub("_", " ")
		waybill.numberPlate = getVehiclePlateText(theJob.vehicle)
		waybill.companies = theJob.companies
	else
		waybill = false
	end
end
addCommandHandler("fuvarlevel", showWaybill)
addCommandHandler("fuvarlevél", showWaybill)

function createLoadingBays()
	for i = 1, #loadingBays do
		local v = loadingBays[i]

		if v then
			if isElement(v[6]) then
				destroyElement(v[6])
			end

			if isElement(v[7]) then
				destroyElement(v[7])
			end

			v[6] = dxCreateRenderTarget(v[3] * 48, v[4] * 48, true)

			dxSetRenderTarget(v[6])

			for x = 0, v[3] * 2 do
				for y = 0, v[4] * 2 do
					dxDrawImage(x * 24, y * 24, 24, 24, "files/images/stripe.png")
				end
			end

			dxDrawRectangle(0, 0, 8, v[4] * 48, tocolor(255, 255, 255))
			dxDrawRectangle(v[3] * 48 - 8, 0, 8, v[4] * 48, tocolor(255, 255, 255))
			dxDrawRectangle(0, 0, v[3] * 48, 8, tocolor(255, 255, 255))
			dxDrawRectangle(0, v[4] * 48 - 8, v[3] * 48, 8, tocolor(255, 255, 255))

			dxSetRenderTarget()

			v[7] = createColRectangle(v[1], v[2], v[3], v[4])
		end
	end
end
addEventHandler("onClientRestore", getRootElement(), createLoadingBays)

function getPositionFromElementOffset(element, x, y, z)
	local m = getElementMatrix(element)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
		   x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
		   x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end

function getPositionFromOffset(m, x, y, z)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
		   x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
		   x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end
