local screenX, screenY = guiGetScreenSize()
local activeBigStinger = false
local tempWheels = {}
local dummyNames = {"wheel_lf_dummy", "wheel_lb_dummy", "wheel_rf_dummy", "wheel_rb_dummy"}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local txd = engineLoadTXD("files/temp_stinger.txd")
		engineImportTXD(txd, 2892)
		engineImportTXD(txd, 2899)
	end)

addEventHandler("onClientColShapeLeave", getRootElement(),
	function (leftElement)
		if activeBigStinger and leftElement == localPlayer then
			if getElementData(source, "bigStingerCol") then
				activeBigStinger = activeBigStinger - 1

				if activeBigStinger <= 0 then
					activeBigStinger = false

					for i = 1, #tempWheels do
						local obj = tempWheels[i]

						if isElement(obj) then
							destroyElement(obj)
						end
					end

					tempWheels = {}
				end
			end
		end
	end)

addEventHandler("onClientVehicleEnter", getRootElement(),
	function (enterPlayer, seat)
		if enterPlayer == localPlayer and seat == 0 then
			local x, y, z = getElementPosition(source)
			local colshapes = getElementsByType("colshape", getResourceRootElement(), true)

			for i = 1, #colshapes do
				local col = colshapes[i]

				if isElementWithinColShape(source, col) and getElementData(col, "bigStingerCol") then
					activeBigStinger = (activeBigStinger or 0) + 1

					for i = 1, #tempWheels do
						local obj = tempWheels[i]

						if isElement(obj) then
							destroyElement(obj)
						end
					end

					tempWheels = {}
					tempWheels[1] = createObject(1085, x, y, z)
					tempWheels[2] = createObject(1085, x, y, z)
					tempWheels[3] = createObject(1085, x, y, z)
					tempWheels[4] = createObject(1085, x, y, z)

					setElementAlpha(tempWheels[1], 0)
					setElementAlpha(tempWheels[2], 0)
					setElementAlpha(tempWheels[3], 0)
					setElementAlpha(tempWheels[4], 0)
				end
			end
		end
	end)

addEventHandler("onClientColShapeHit", getRootElement(),
	function (hitElement)
		if not isElement(source) then
			return
		end
		
		if hitElement == localPlayer then
			if getElementData(source, "bigStingerCol") then
				if isPedInVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
					local x, y, z = getElementPosition(hitElement)

					activeBigStinger = (activeBigStinger or 0) + 1

					for i = 1, #tempWheels do
						local obj = tempWheels[i]

						if isElement(obj) then
							destroyElement(obj)
						end
					end

					tempWheels = {}
					tempWheels[1] = createObject(1085, x, y, z)
					tempWheels[2] = createObject(1085, x, y, z)
					tempWheels[3] = createObject(1085, x, y, z)
					tempWheels[4] = createObject(1085, x, y, z)

					setElementAlpha(tempWheels[1], 0)
					setElementAlpha(tempWheels[2], 0)
					setElementAlpha(tempWheels[3], 0)
					setElementAlpha(tempWheels[4], 0)
				end
			end
		end

		if getElementData(source, "stingerCol") then
			local currVeh = getPedOccupiedVehicle(localPlayer)

			if currVeh and getPedOccupiedVehicleSeat(localPlayer) == 0 then
				local _, _, vehZ = getElementPosition(hitElement)
				local _, _, spikeZ = getElementPosition(getElementData(source, "stingerCol"))

				if math.abs(vehZ - spikeZ) <= 2 then
					for i = 1, #tempWheels do
						local obj = tempWheels[i]

						if hitElement == obj then
							local wheelstates = {getVehicleWheelStates(currVeh)}

							if wheelstates[i] == 0 then
								wheelstates[i] = 1
								setVehicleWheelStates(currVeh, wheelstates[1], wheelstates[2], wheelstates[3], wheelstates[4])
								triggerServerEvent("syncStingerStates", currVeh, wheelstates)
							end
						end
					end
				end
			end
		end
	end)

addEventHandler("onClientPreRender", getRootElement(),
	function ()
		if activeBigStinger then
			local currVeh = getPedOccupiedVehicle(localPlayer)

			if isElement(currVeh) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
				for i = 1, #tempWheels do
					local obj = tempWheels[i]

					if isElement(obj) then
						local x, y, z = getVehicleComponentPosition(currVeh, dummyNames[i], "world")
						local rx, ry, rz = getVehicleComponentRotation(currVeh, dummyNames[i], "world")

						setElementPosition(obj, x, y, z)
						setElementRotation(obj, rx, ry, rz)
					end
				end
			else
				for i = 1, #tempWheels do
					local obj = tempWheels[i]

					if isElement(obj) then
						destroyElement(obj)
					end
				end

				tempWheels = {}
				activeBigStinger = false
			end
		end
	end)

local nearbyRender = false
local nearbyFont = false
local nearbyList = {}

function nearbyStingers()
	if exports.see_groups:isPlayerHavePermission(localPlayer, "stinger") or getElementData(localPlayer, "acc.adminLevel") >= 1 then
		nearbyRender = not nearbyRender
		nearbyList = {}

		if nearbyRender then
			local objects = getElementsByType("object", getResourceRootElement(), true)

			for i = 1, #objects do
				local obj = objects[i]
				local dat = getElementData(obj, "spikeData")

				if dat then
					table.insert(nearbyList, dat)
				end
			end

			nearbyFont = dxCreateFont("files/fonts/Roboto.ttf", respc(10), false, "antialiased")

			addEventHandler("onClientRender", getRootElement(), renderNearbyStingers)

			outputChatBox("#3d7abc[StrongMTA - Spike]: #FFFFFFKözeli spike mód #3d7abcbekapcsolva#ffffff!", 255, 255, 255, true)
		else
			removeEventHandler("onClientRender", getRootElement(), renderNearbyStingers)

			if isElement(nearbyFont) then
				destroyElement(nearbyFont)
			end

			nearbyFont = nil

			outputChatBox("#3d7abc[StrongMTA - Spike]: #FFFFFFKözeli spike mód #d75959kikapcsolva#ffffff!", 255, 255, 255, true)
		end
	end
end
addCommandHandler("nearbyspikes", nearbyStingers)
addCommandHandler("nearbystingers", nearbyStingers)

addEventHandler("onClientElementStreamIn", getResourceRootElement(),
	function ()
		if nearbyRender then
			local data = getElementData(source, "spikeData")

			if data then
				for i = 1, #nearbyList do
					if nearbyList[i] and nearbyList[i][2] == source then
						return
					end
				end

				table.insert(nearbyList, data)
			end
		end
	end)

addEventHandler("onClientElementStreamOut", getResourceRootElement(),
	function ()
		if nearbyRender then
			local data = getElementData(source, "spikeData")

			if data then
				local temp = {}

				for i = 1, #nearbyList do
					if nearbyList[i] and nearbyList[i][2] ~= source then
						table.insert(temp, nearbyList[i])
					end
				end

				nearbyList = temp
			end
		end
	end)

function renderNearbyStingers()
	local px, py, pz = getElementPosition(localPlayer)
	local cx, cy = getCursorPosition()

	if cx and cy then
		cx = cx * screenX
		cy = cy * screenY
	end

	for i = 1, #nearbyList do
		local dat = nearbyList[i]

		if dat and isElement(dat[2]) and isElementStreamedIn(dat[2]) then
			local tx, ty, tz = getElementPosition(dat[2])
			local dist = getDistanceBetweenPoints3D(tx, ty, tz, px, py, pz)

			if dist <= 10 then
				local x, y = getScreenFromWorldPosition(tx, ty, tz)

				if x and y then
					local x2 = math.floor(x - 100)
					local y2 = math.floor(y - 10)

					dxDrawText("[SPIKE] ID: " .. dat[1] .. " Lerakta: " .. dat[3], x2 + 1, y2 + 1, x2 + 200 + 1, y2 + 20 + 1, tocolor(0, 0, 0), 1, nearbyFont, "center", "center")
					dxDrawText("#3d7abc[SPIKE]#ffffff ID: " .. dat[1] .. " Lerakta: " .. dat[3], x2, y2, x2 + 200, y2 + 20, tocolor(255, 255, 255), 1, nearbyFont, "center", "center", false, false, false, true)
					
					x = x + dxGetTextWidth("[SPIKE] ID: " .. dat[1] .. " Lerakta: " .. dat[3], 1, nearbyFont) / 2 + respc(5)

					if cx and cx >= x and cy >= y - respc(10) and cx <= x + respc(75) and cy <= y + respc(10) then
						if getKeyState("mouse1") then
							triggerServerEvent("deleteStinger", localPlayer, dat[1])
							nearbyList[i] = false
						end

						dxDrawRectangle(x, y - respc(10), respc(75), respc(20), tocolor(215, 89, 89, 200))
					else
						dxDrawRectangle(x, y - respc(10), respc(75), respc(20), tocolor(215, 89, 89, 150))
					end

					dxDrawText("Törlés", x, y - respc(10), x + respc(75), y + respc(10), tocolor(0, 0, 0), 1, nearbyFont, "center", "center")
				end
			end
		end
	end
end