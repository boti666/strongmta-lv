local screenX, screenY = guiGetScreenSize()
local destroyMarker = createMarker(379.22012329102, 2602.8032226563, 16.484375 - 1, "cylinder", 5, 51, 102, 153, 200)

local panelState = false
local panelFont = false
local activeButton = false

addEventHandler("onClientMarkerHit", destroyMarker,
	function (hitPlayer, matchingDimension)
		if hitPlayer == localPlayer and matchingDimension then
			local pedveh = getPedOccupiedVehicle(localPlayer)

			if isElement(pedveh) then
				if getVehicleController(pedveh) == localPlayer then
					panelFont = dxCreateFont(":see_hud/files/fonts/Roboto.ttf", 13, false, "antialiased")
					panelState = true

					setElementFrozen(pedveh, true)
					showCursor(true)
				end
			end
		end
	end)

addEventHandler("onClientMarkerLeave", destroyMarker,
	function (leftPlayer, matchingDimension)
		if leftPlayer == localPlayer then
			if panelState then
				local pedveh = getPedOccupiedVehicle(localPlayer)

				if isElement(pedveh) then
					setElementFrozen(pedveh, false)
				end

				panelState = false
				showCursor(false)

				if isElement(panelFont) then
					destroyElement(panelFont)
				end

				panelFont = nil
			end
		end
	end)

addEventHandler("onClientClick", getRootElement(),
	function (button, state)
		if panelState then
			if activeButton then
				if button == "left" then
					if state == "up" then
						local pedveh = getPedOccupiedVehicle(localPlayer)

						if isElement(pedveh) then
							setElementFrozen(pedveh, false)

							if activeButton == "accept" then
								local vehicleId = getElementData(pedveh, "vehicle.dbID") or false
								if vehicleId then
									local ownerId = getElementData(pedveh, "vehicle.owner") or false
									if ownerId then
										local charId = getElementData(localPlayer, "char.ID") or false
										if charId then
											if tonumber(charId) == tonumber(ownerId) then
												triggerServerEvent("destroyVehicle", localPlayer, pedveh, vehicleId)
											else
												exports.see_hud:showInfobox("e", "Más kocsiját nem zúzathatod be!")
											end
										end
									end
								end
							end
						end

						panelState = false
						showCursor(false)

						if isElement(panelFont) then
							destroyElement(panelFont)
						end

						panelFont = nil
					end
				end
			end
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if panelState then
			local sx, sy = 300, 150
			local x = screenX / 2 - sx / 2
			local y = screenY / 2 - sy / 2
			local buttons = {}

			dxDrawRectangle(x, y, sx, sy, tocolor(0, 0, 0, 200))
			
			dxDrawRectangle(x, y, sx, 35, tocolor(0, 0, 0, 200))
			
			dxDrawText("Strong#3d7abcMTA - #ffffffBezúzás", x + 10, y, 0, y + 35, tocolor(255, 255, 255), 1, panelFont, "left", "center", false, false, false, true)

			dxDrawText("Meguntad a járműved és nincs rá ember, aki megvegye? Mi gondoskodunk róla.", x + 10, y + 45, x + sx - 20, y + sy - 55, tocolor(255, 255, 255), 0.75, panelFont, "center", "center", false, true)

			local oneSize = (sx - 30) / 2

			buttons["accept"] = {x + 10, y + sy - 45, oneSize, 35}

			if activeButton == "accept" then
				dxDrawRectangle(x + 10, y + sy - 45, oneSize, 35, tocolor(61, 122, 188, 225))
			else
				dxDrawRectangle(x + 10, y + sy - 45, oneSize, 35, tocolor(61, 122, 188, 180))
			end

			dxDrawText("Elfogadás", x + 10, y + sy - 45, x + 10 + oneSize, y + sy - 10, tocolor(0, 0, 0), 0.8, panelFont, "center", "center")

			buttons["decline"] = {x + 20 + oneSize, y + sy - 45, oneSize, 35}

			if activeButton == "decline" then
				dxDrawRectangle(x + 20 + oneSize, y + sy - 45, oneSize, 35, tocolor(215, 89, 89, 225))
			else
				dxDrawRectangle(x + 20 + oneSize, y + sy - 45, oneSize, 35, tocolor(215, 89, 89, 180))
			end

			dxDrawText("Elutasítás", x + 20 + oneSize, y + sy - 45, x + 20 + oneSize * 2, y + sy - 10, tocolor(0, 0, 0), 0.8, panelFont, "center", "center")

			local cx, cy = getCursorPosition()

			activeButton = false

			if tonumber(cx) then
				cx = cx * screenX
				cy = cy * screenY

				for k, v in pairs(buttons) do
					if cx >= v[1] and cx <= v[1] + v[3] and cy >= v[2] and cy <= v[2] + v[4] then
						activeButton = k
						break
					end
				end
			end
		end
	end)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		if getElementData(localPlayer, "loggedIn") then
			setTimer(triggerServerEvent, 2000, 1, "loadPlayerVehicles", localPlayer)
		end
	end)

addEventHandler("onClientElementStreamIn", getResourceRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			if getVehicleType(source) == "Helicopter" then
				setHeliBladeCollisionsEnabled(source, false)
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldVal)
		if dataName == "noCollide" then
			if getElementData(source, dataName) then
				setElementCollidableWith(source, localPlayer, false)
			else
				setElementCollidableWith(source, localPlayer, true)
			end
		end
	end)

addEvent("handleParkingProcess", true)
addEventHandler("handleParkingProcess", getRootElement(),
	function (vehicle, positions)
		if isElement(vehicle) then
			if type(positions) == "table" then
				local canPark = true
				local x, y, z = getElementPosition(vehicle)
				local interior = getElementInterior(vehicle)
				local dimension = getElementDimension(vehicle)

				for k, v in pairs(positions) do
					if interior == v.interior and dimension == v.dimension then
						if getDistanceBetweenPoints3D(x, y, z, v.posX, v.posY, v.posZ) <= 5 then
							canPark = false
						end
					end
				end

				if canPark then
					triggerServerEvent("finishParkingProcess", localPlayer, vehicle)
				else
					outputChatBox("#DC143C[StrongMTA]: #FFFFFFEzen a pozíción nem parkolhatod le a járművedet.", 255, 255, 255, true)
				end
			end
		end
	end)