local tuningMarkers = {}
local garageColShape = createColCuboid(390, 2471.5, 15, 29.5, 10, 8.5)

connection = false

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()

		for k, v in ipairs(tuningPositions) do
			tuningMarkers[k] = createMarker(v[1], v[2], v[3] + 1, "cylinder", 3, 61, 122, 188, 100)

			if isElement(tuningMarkers[k]) then
				setElementData(tuningMarkers[k], "tuningPositionId", k, false)
			end
		end
	end
)

addEventHandler("onMarkerHit", getResourceRootElement(),
	function (hitElement)
		local positionId = getElementData(source, "tuningPositionId")

		if positionId then
			if getElementType(hitElement) == "vehicle" then
				local driver = getVehicleController(hitElement)

				if driver then
					if getElementAlpha(source) ~= 0 then
						setElementAlpha(source, 0)

						local vehX, vehY, vehZ = getElementPosition(hitElement)

						setElementFrozen(hitElement, true)
						setElementPosition(hitElement, tuningPositions[positionId][1], tuningPositions[positionId][2], vehZ)
						setElementRotation(hitElement, 0, 0, tuningPositions[positionId][4])

						triggerClientEvent(driver, "toggleTuning", driver, true)
						setElementData(driver, "activeTuningMarker", source, false)
						setElementData(driver, "player.inTuning", positionId)
					end
				end
			end
		end
	end)

addEventHandler("onPlayerQuit", getRootElement(),
    function ()
        triggerEvent("exitTuning", source)
    end
)

addEventHandler("onPlayerWasted", getRootElement(),
    function ()
        triggerEvent("exitTuning", source)
    end
)

addEvent("exitTuning", true)
addEventHandler("exitTuning", getRootElement(),
    function ()
        if isElement(source) then
            local tuningId = getElementData(source, "player.inTuning")

            if tuningId then
                local tuningMarker = tuningMarkers[tuningId]

                if tuningMarker then
                    triggerClientEvent(source, "toggleTuning", source, false)
                    setElementData(source, "player.inTuning", false)

                    --tuningMarker.inUse = false
                    setElementAlpha(tuningMarker, 150)

                    local vehicleElement = getPedOccupiedVehicle(source)
                    if vehicleElement then
                        setElementFrozen(vehicleElement, false)
                    end
                end
            end
        end
    end
)

addEventHandler("onColShapeHit", garageColShape,
	function (hitElement, matchingDimension)
		if getElementType(hitElement) == "player" then
			if matchingDimension then
				if not isGarageOpen(45) then
					setGarageOpen(45, true)
				end
			end
		end
	end)

addEventHandler("onColShapeLeave", garageColShape,
	function (leftElement, matchingDimension)
		if getElementType(leftElement) == "player" then
			if matchingDimension then
				if #getElementsWithinColShape(source, "player") == 0 then
					if isGarageOpen(45) then
						setGarageOpen(45, false)
					end
				end
			end
		end
	end)

addEvent("setVehicleHandling", true)
addEventHandler("setVehicleHandling", getRootElement(),
	function (property, value)
		if isElement(source) then
			if property then
				local vehicle = getPedOccupiedVehicle(source)

				if isElement(vehicle) then
					setVehicleHandling(vehicle, property, value)
				end
			end
		end
	end)

addEvent("previewVariant", true)
addEventHandler("previewVariant", getRootElement(),
	function (variant)
		if isElement(source) then
			if not variant then
				variant = getElementData(source, "vehicle.variant") or 0
			end

			if variant == 0 then
				setVehicleVariant(source, 255, 255)
			else
				setVehicleVariant(source, variant - 1, 255)
			end
		end
	end)

function canTuneVehicle(vehicle, player, notice)
	local ownerId = getElementData(vehicle, "vehicle.owner") or 0
	local groupId = getElementData(vehicle, "vehicle.group") or 0

	if ownerId == 0 and groupId == 0 then
		return true
	end

	if ownerId > 0 then
		if ownerId == getElementData(player, "char.ID") then
			return true
		end
	end

	if groupId > 0 then
		if exports.see_groups:isPlayerInGroup(player, groupId) then
			return true
		end
	end

	if notice then
		exports.see_accounts:showInfo(player, "e", "Nem te vagy a jármű tulajdonosa!")
	end

	return false
end

addEvent("buyVariantTuning", true)
addEventHandler("buyVariantTuning", getRootElement(),
	function (variant, price)
		if client == source and variant and price then
			local vehicle = getPedOccupiedVehicle(client)

			if isElement(vehicle) then
				local vehicleId = getElementData(vehicle, "vehicle.dbID")
				local currVariant = getElementData(vehicle, "vehicle.variant") or 0
				local buyState = "failed"

				if currVariant ~= variant then
					if exports.see_core:takeMoneyEx(client, price, eventName) then
						if variant == 0 then
							setVehicleVariant(vehicle, 255, 255)
							buyState = "successdown"
						else
							setVehicleVariant(vehicle, variant - 1, 255)
							buyState = "success"
						end

						setElementData(vehicle, "vehicle.variant", variant)

						if vehicleId then
							dbExec(connection, "UPDATE vehicles SET variant = ? WHERE vehicleId = ?", variant, vehicleId)
						end
					else
						exports.see_accounts:showInfo(client, "e", "Nincs elég pénzed a kiválasztott tétel megvásárlásához!")
					end
				else
					exports.see_accounts:showInfo(client, "e", "A kiválasztott elem már fel van szerelve!")
				end

				triggerClientEvent(client, "buyVariant", client, buyState)
			end
		end
	end)

addEvent("buySpinnerTuning", true)
addEventHandler("buySpinnerTuning", getRootElement(),
	function (value, r, g, b, sx, sy, sz, tinted, price)
		if client == source and price then
			local vehicle = getPedOccupiedVehicle(client)

			if isElement(vehicle) then
				local vehicleId = getElementData(vehicle, "vehicle.dbID")
				local currSpinner = getElementData(vehicle, "tuningSpinners")
				local newSpinner = {}
				local buyState = "failed"

				if value then
					if tinted then
						newSpinner = {value, sx, sy, sz, r, g, b}
					else
						newSpinner = {value, sx, sy, sz}
					end
				else
					newSpinner = {}
				end

				if currSpinner ~= value then
					local currPP = getElementData(client, "acc.premiumPoints") or 0

					currPP = currPP - price

					if currPP >= 0 then
						setElementData(client, "acc.premiumPoints", currPP)

						if value then
							setElementData(vehicle, "tuningSpinners", newSpinner)
							buyState = "success"
						else
							setElementData(vehicle, "tuningSpinners", false)
							buyState = "successdown"
						end

						if vehicleId then
							dbExec(connection, "UPDATE vehicles SET tuningSpinners = ? WHERE vehicleId = ?", table.concat(newSpinner, ","), vehicleId)
						end
					else
						exports.see_accounts:showInfo(client, "e", "Nincs elég prémium pontod a kiválasztott tétel megvásárlásához!")
					end
				else
					if value then
						exports.see_accounts:showInfo(client, "e", "A kiválasztott elem már fel van szerelve!")
					else
						exports.see_accounts:showInfo(client, "e", "Mégis mit akarsz leszerelni?")
					end
				end

				if value then
					triggerClientEvent(client, "buySpinner", client, buyState, newSpinner)
				else
					triggerClientEvent(client, "buySpinner", client, buyState, false)
				end
			end
		end
	end)

addEvent("buyOpticalTuning", true)
addEventHandler("buyOpticalTuning", getRootElement(),
	function (slot, value, priceType, price)
		if client == source and slot and value and priceType and price then
			local vehicle = getPedOccupiedVehicle(client)

			if isElement(vehicle) then
				local vehicleId = getElementData(vehicle, "vehicle.dbID")

				local ownerId = getElementData(vehicle, "vehicle.owner")
				local charId = getElementData(client, "char.ID")

				local currUpgrade = getVehicleUpgradeOnSlot(vehicle, slot)
				local buyState = "failed"

				if currUpgrade ~= value then
					if value == 0 and ownerId ~= charId then
						exports.see_accounts:showInfo(client, "e", "Csak a jármű tulajdonosa szerelhet le alkatrészt!")
					else
						local currBalance = 0

						if priceType == "premium" then
							currBalance = getElementData(client, "acc.premiumPoints") or 0
						else
							currBalance = getElementData(client, "char.Money") or 0
						end

						currBalance = currBalance - price

						if currBalance >= 0 then
							buyState = "success"

							if priceType == "premium" then
								setElementData(client, "acc.premiumPoints", currBalance)
							else
								exports.see_core:takeMoney(client, price, eventName)
							end

							local currUpgrades = getElementData(vehicle, "vehicle.tuning.Optical") or ""
							local currUpgradesTable = split(currUpgrades, ",")
							local changed = false

							for k, upgrade in pairs(currUpgradesTable) do
								if getVehicleUpgradeSlotName(slot) == getVehicleUpgradeSlotName(upgrade) then
									currUpgradesTable[k] = value
									changed = true
								end
							end

							if not changed then
								currUpgrades = currUpgrades .. tostring(value) .. ","
							else
								currUpgrades = table.concat(currUpgradesTable, ",") .. ","
							end

							if value == 0 then
								removeVehicleUpgrade(vehicle, currUpgrade)
							else
								addVehicleUpgrade(vehicle, value)
							end

							setElementData(vehicle, "vehicle.tuning.Optical", currUpgrades)

							if vehicleId then
								dbExec(connection, "UPDATE vehicles SET tuningOptical = ? WHERE vehicleId = ?", currUpgrades, vehicleId)
							end
						else
							if priceType == "premium" then
								exports.see_accounts:showInfo(client, "e", "Nincs elég prémium pontod a kiválasztott tétel megvásárlásához!")
							else
								exports.see_accounts:showInfo(client, "e", "Nincs elég pénzed a kiválasztott tétel megvásárlásához!")
							end
						end
					end
				else
					exports.see_accounts:showInfo(client, "e", "A kiválasztott elem már fel van szerelve!")
				end

				triggerClientEvent(client, "buyOpticalTuning", client, buyState, value)
			end
		end
	end)

addEvent("buyPaintjob", true)
addEventHandler("buyPaintjob", getRootElement(),
	function (value, priceType, price)
		if source == client and value and price then
			local vehicle = getPedOccupiedVehicle(client)

			if isElement(vehicle) then
				local vehicleId = getElementData(vehicle, "vehicle.dbID")

				local ownerId = getElementData(vehicle, "vehicle.owner")
				local charId = getElementData(client, "char.ID")

				local currPaintjob = getElementData(vehicle, "vehicle.tuning.Paintjob") or 0
				local buyState = "failed"

				if currPaintjob ~= value then
					if value == 0 and ownerId ~= charId then
						exports.see_accounts:showInfo(client, "e", "Csak a jármű tulajdonosa cserélhet paintjobot!")
					else
						local currBalance = 0

						if priceType == "premium" then
							currBalance = getElementData(client, "acc.premiumPoints") or 0
						else
							currBalance = getElementData(client, "char.Money") or 0
						end

						currBalance = currBalance - price

						if currBalance >= 0 then
							buyState = "success"

							if priceType == "premium" then
								setElementData(client, "acc.premiumPoints", currBalance)
							else
								exports.see_core:takeMoney(client, price, eventName)
							end

							setElementData(vehicle, "vehicle.tuning.Paintjob", value)

							if vehicleId then
								dbExec(connection, "UPDATE vehicles SET tuningPaintjob = ? WHERE vehicleId = ?", value, vehicleId)
							end
						else
							if priceType == "premium" then
								exports.see_accounts:showInfo(client, "e", "Nincs elég prémium pontod a kiválasztott tétel megvásárlásához!")
							else
								exports.see_accounts:showInfo(client, "e", "Nincs elég pénzed a kiválasztott tétel megvásárlásához!")
							end
						end
					end
				else
					exports.see_accounts:showInfo(client, "e", "A kiválasztott elem már fel van szerelve!")
				end

				triggerClientEvent(client, "buyPaintjob", client, buyState, value)
			end
		end
	end)

addEvent("buyPlatina", true)
addEventHandler("buyPlatina", getRootElement(),
	function (value, priceType, price)
		if source == client and value and price then
			local vehicle = getPedOccupiedVehicle(client)

			if isElement(vehicle) then
				local vehicleId = getElementData(vehicle, "vehicle.dbID")

				local ownerId = getElementData(vehicle, "vehicle.owner")
				local charId = getElementData(client, "char.ID")

				local currPaintjob = getElementData(vehicle, "vehicle.Tuning.Platina") or 0
				local buyState = "failed"

				if currPaintjob ~= value then
					if value == 0 and ownerId ~= charId then
						exports.see_accounts:showInfo(client, "e", "Csak a jármű tulajdonosa cserélhet paintjobot!")
					else
						local currBalance = 0

						if priceType == "premium" then
							currBalance = getElementData(client, "acc.premiumPoints") or 0
						else
							currBalance = getElementData(client, "char.Money") or 0
						end

						currBalance = currBalance - price

						if currBalance >= 0 then
							buyState = "success"

							if priceType == "premium" then
								setElementData(client, "acc.premiumPoints", currBalance)
							else
								exports.see_core:takeMoney(client, price, eventName)
							end

							setElementData(vehicle, "vehicle.Tuning.Platina", value)

							if vehicleId then
								dbExec(connection, "UPDATE vehicles SET tuningPlatina = ? WHERE vehicleId = ?", value, vehicleId)
							end
						else
							if priceType == "premium" then
								exports.see_accounts:showInfo(client, "e", "Nincs elég prémium pontod a kiválasztott tétel megvásárlásához!")
							else
								exports.see_accounts:showInfo(client, "e", "Nincs elég pénzed a kiválasztott tétel megvásárlásához!")
							end
						end
					end
				else
					exports.see_accounts:showInfo(client, "e", "A kiválasztott elem már fel van szerelve!")
				end

				triggerClientEvent(client, "buyPlatina", client, buyState, value)
			end
		end
	end)

addEvent("buyWheelPaintjob", true)
addEventHandler("buyWheelPaintjob", getRootElement(),
	function (value, priceType, price)
		if source == client and value and price then
			local vehicle = getPedOccupiedVehicle(client)

			if isElement(vehicle) then
				local vehicleId = getElementData(vehicle, "vehicle.dbID")

				local ownerId = getElementData(vehicle, "vehicle.owner")
				local charId = getElementData(client, "char.ID")

				local currPaintjob = getElementData(vehicle, "vehicle.tuning.WheelPaintjob") or 0
				local buyState = "failed"

				if currPaintjob ~= value then
					if value == 0 and ownerId ~= charId then
						exports.see_accounts:showInfo(client, "e", "Csak a jármű tulajdonosa cserélhet kerék paintjobot!")
					else
						local currBalance = 0

						if priceType == "premium" then
							currBalance = getElementData(client, "acc.premiumPoints") or 0
						else
							currBalance = getElementData(client, "char.Money") or 0
						end

						currBalance = currBalance - price

						if currBalance >= 0 then
							buyState = "success"

							if priceType == "premium" then
								setElementData(client, "acc.premiumPoints", currBalance)
							else
								exports.see_core:takeMoney(client, price, eventName)
							end

							setElementData(vehicle, "vehicle.tuning.WheelPaintjob", value)

							if vehicleId then
								dbExec(connection, "UPDATE vehicles SET tuningWheelPaintjob = ? WHERE vehicleId = ?", value, vehicleId)
							end
						else
							if priceType == "premium" then
								exports.see_accounts:showInfo(client, "e", "Nincs elég prémium pontod a kiválasztott tétel megvásárlásához!")
							else
								exports.see_accounts:showInfo(client, "e", "Nincs elég pénzed a kiválasztott tétel megvásárlásához!")
							end
						end
					end
				else
					exports.see_accounts:showInfo(client, "e", "A kiválasztott elem már fel van szerelve!")
				end

				triggerClientEvent(client, "buyWheelPaintjob", client, buyState, value)
			end
		end
	end)

addEvent("buyHeadLight", true)
addEventHandler("buyHeadLight", getRootElement(),
	function (value, priceType, price)
		if source == client and value and price then
			local vehicle = getPedOccupiedVehicle(client)

			if isElement(vehicle) then
				local vehicleId = getElementData(vehicle, "vehicle.dbID")

				local ownerId = getElementData(vehicle, "vehicle.owner")
				local charId = getElementData(client, "char.ID")

				local currPaintjob = getElementData(vehicle, "vehicle.tuning.HeadLight") or 0
				local buyState = "failed"

				if currPaintjob ~= value then
					if value == 0 and ownerId ~= charId then
						exports.see_accounts:showInfo(client, "e", "Csak a jármű tulajdonosa cserélhet fényszórót!")
					else
						local currBalance = 0

						if priceType == "premium" then
							currBalance = getElementData(client, "acc.premiumPoints") or 0
						else
							currBalance = getElementData(client, "char.Money") or 0
						end

						currBalance = currBalance - price

						if currBalance >= 0 then
							buyState = "success"

							if priceType == "premium" then
								setElementData(client, "acc.premiumPoints", currBalance)
							else
								exports.see_core:takeMoney(client, price, eventName)
							end

							setElementData(vehicle, "vehicle.tuning.HeadLight", value)

							if vehicleId then
								dbExec(connection, "UPDATE vehicles SET tuningHeadLight = ? WHERE vehicleId = ?", value, vehicleId)
							end
						else
							if priceType == "premium" then
								exports.see_accounts:showInfo(client, "e", "Nincs elég prémium pontod a kiválasztott tétel megvásárlásához!")
							else
								exports.see_accounts:showInfo(client, "e", "Nincs elég pénzed a kiválasztott tétel megvásárlásához!")
							end
						end
					end
				else
					exports.see_accounts:showInfo(client, "e", "A kiválasztott elem már fel van szerelve!")
				end

				triggerClientEvent(client, "buyHeadLight", client, buyState, value)
			end
		end
	end)

addEvent("buyColor", true)
addEventHandler("buyColor", getRootElement(),
	function (colorId, vehicleColor, vehicleLightColor, priceType, price)
		if source == client and colorId and priceType and price then
			local vehicle = getPedOccupiedVehicle(client)

			if isElement(vehicle) then
				local vehicleId = getElementData(vehicle, "vehicle.dbID")

				local ownerId = getElementData(vehicle, "vehicle.owner")
				local charId = getElementData(client, "char.ID")

				local buyState = "failed"
				local currBalance = 0

				if ownerId ~= charId then
					exports.see_accounts:showInfo(client, "e", "Csak a jármű tulajdonosa festheti át a járművet!")
				else
					if priceType == "premium" then
						currBalance = getElementData(client, "acc.premiumPoints") or 0
					else
						currBalance = getElementData(client, "char.Money") or 0
					end

					currBalance = currBalance - price

					if currBalance >= 0 then
						buyState = "success"

						if priceType == "premium" then
							setElementData(client, "acc.premiumPoints", currBalance)
						else
							exports.see_core:takeMoney(client, price, eventName)
						end

						if colorId <= 4 then
							local color1 = convertRGBToHEX(vehicleColor[1], vehicleColor[2], vehicleColor[3])
							local color2 = convertRGBToHEX(vehicleColor[4], vehicleColor[5], vehicleColor[6])
							local color3 = convertRGBToHEX(vehicleColor[7], vehicleColor[8], vehicleColor[9])
							local color4 = convertRGBToHEX(vehicleColor[10], vehicleColor[11], vehicleColor[12])

							setVehicleColor(vehicle, vehicleColor[1], vehicleColor[2], vehicleColor[3], vehicleColor[4], vehicleColor[5], vehicleColor[6], vehicleColor[7], vehicleColor[8], vehicleColor[9], vehicleColor[10], vehicleColor[11], vehicleColor[12])

							setElementData(vehicle, "vehicleColor", {vehicleColor[1], vehicleColor[2], vehicleColor[3]})

							if vehicleId then
								dbExec(connection, "UPDATE vehicles SET color1 = ?, color2 = ?, color3 = ?, color4 = ? WHERE vehicleId = ?", color1, color2, color3, color4, vehicleId)
							end
						elseif colorId == 5 then
							local headLightColor = convertRGBToHEX(vehicleLightColor[1], vehicleLightColor[2], vehicleLightColor[3])

							setVehicleHeadLightColor(vehicle, vehicleLightColor[1], vehicleLightColor[2], vehicleLightColor[3])

							if vehicleId then
								dbExec(connection, "UPDATE vehicles SET headLightColor = ? WHERE vehicleId = ?", headLightColor, vehicleId)
							end
						elseif colorId >= 7 then
							triggerClientEvent(client, "buySpeedoColor", vehicle, colorId)
							buyState = "speedo"
						end
					else
						if priceType == "premium" then
							exports.see_accounts:showInfo(client, "e", "Nincs elég prémium pontod a kiválasztott tétel megvásárlásához!")
						else
							exports.see_accounts:showInfo(client, "e", "Nincs elég pénzed a kiválasztott tétel megvásárlásához!")
						end
					end
				end

				triggerClientEvent(client, "buyColor", client, buyState, vehicleColor, vehicleLightColor)
			end
		end
	end)

function convertRGBToHEX(r, g, b, a)
	if (r < 0 or r > 255 or g < 0 or g > 255 or b < 0 or b > 255) or (a and (a < 0 or a > 255)) then
		return nil
	end

	if a then
		return string.format("#%.2X%.2X%.2X%.2X", r, g, b, a)
	else
		return string.format("#%.2X%.2X%.2X", r, g, b)
	end
end

addEvent("buyLicensePlate", true)
addEventHandler("buyLicensePlate", getRootElement(),
	function (value, plateText, priceType, price)
		if source == client and value and plateText and priceType and price then
			local vehicle = getPedOccupiedVehicle(client)

			if isElement(vehicle) then
				local vehicleId = getElementData(vehicle, "vehicle.dbID")
				local ownerId = getElementData(vehicle, "vehicle.owner")
				local charId = getElementData(client, "char.ID")

				dbQuery(
					function (qh, thePlayer)
						local result = dbPoll(qh, 0)[1]
						local buyState = "failed"

						if value == "custom" and result.plateState == 1 then
							exports.see_accounts:showInfo(thePlayer, "e", "A kiválasztott rendszám foglalt, kérlek válassz másikat!")
						else
							local currBalance = 0

							if value == "default" and ownerId ~= charId then
								exports.see_accounts:showInfo(thePlayer, "e", "Csak a jármű tulajdonosa cserélheti le a rendszámot!")
							else
								if priceType == "premium" then
									currBalance = getElementData(thePlayer, "acc.premiumPoints") or 0
								else
									currBalance = getElementData(thePlayer, "char.Money") or 0
								end

								currBalance = currBalance - price

								if currBalance >= 0 then
									buyState = "success"

									if priceType == "premium" then
										setElementData(thePlayer, "acc.premiumPoints", currBalance)
									else
										exports.see_core:takeMoney(thePlayer, price, eventName)
									end

									if value == "default" then
										if vehicleId then
											plateText = exports.see_vehicles:encodeDatabaseId(vehicleId)
										else
											plateText = ""
										end
									end

									setVehiclePlateText(vehicle, plateText)

									if vehicleId then
										dbExec(connection, "UPDATE vehicles SET plateText = ? WHERE vehicleId = ?", plateText, vehicleId)
									end
								else
									if priceType == "premium" then
										exports.see_accounts:showInfo(thePlayer, "e", "Nincs elég prémium pontod a kiválasztott tétel megvásárlásához!")
									else
										exports.see_accounts:showInfo(thePlayer, "e", "Nincs elég pénzed a kiválasztott tétel megvásárlásához!")
									end
								end
							end
						end

						triggerClientEvent(thePlayer, "buyLicensePlate", thePlayer, buyState, plateText)
					end,
				{client}, connection, "SELECT COUNT(1) AS plateState FROM vehicles WHERE plateText = ? LIMIT 1", plateText)
			end
		end
	end)

addEvent("buyTuning", true)
addEventHandler("buyTuning", getRootElement(),
	function (selectedMenu, selectedSubMenu, selectionLevel, isTheOriginal)
		if source == client then
			local vehicle = getPedOccupiedVehicle(client)

			if isElement(vehicle) then
				local activeMenu = tuningContainer[selectedMenu].subMenu[selectedSubMenu]
				local priceType = activeMenu.subMenu[selectionLevel].priceType
				local price = activeMenu.subMenu[selectionLevel].price
				local value = activeMenu.subMenu[selectionLevel].value

				local buyState = "failed"
				local currBalance = 0

				if priceType == "premium" then
					currBalance = getElementData(client, "acc.premiumPoints") or 0
				else
					currBalance = getElementData(client, "char.Money") or 0
				end

				currBalance = currBalance - price

				if currBalance >= 0 then
					if isTheOriginal then
						exports.see_accounts:showInfo(client, "e", "A kiválasztott elem már fel van szerelve!")
					else
						buyState = "success"

						if priceType == "premium" then
							setElementData(client, "acc.premiumPoints", currBalance)
						else
							exports.see_core:takeMoney(client, price)
						end

						if activeMenu.serverFunction then
							activeMenu.serverFunction(vehicle, value)
						end

						if selectedMenu == 1 and selectedSubMenu == 8 then
							if value == 0 then
								exports.see_accounts:showInfo(client, "s", "Sikeresen kiürítetted a nitrós palackod.")
							else
								exports.see_accounts:showInfo(client, "s", "Sikeresen megvásároltad a kiválasztott elemet!")
							end
						elseif selectedMenu == 2 and selectedSubMenu == 11 then
							if value == 0 then
								exports.see_accounts:showInfo(client, "s", "Sikeresen leszerelted a neont.")
							else
								exports.see_accounts:showInfo(client, "s", "Sikeresen megvásároltad a kiválasztott neont! ('u' betűvel kapcsolod ki és be)")
							end
						elseif activeMenu.id == "handling" then
							value = getVehicleHandling(vehicle)["handlingFlags"]
						end
					end
				else
					if priceType == "premium" then
						exports.see_accounts:showInfo(client, "e", "Nincs elég prémium pontod a kiválasztott tétel megvásárlásához!")
					else
						exports.see_accounts:showInfo(client, "e", "Nincs elég pénzed a kiválasztott tétel megvásárlásához!")
					end
				end

				triggerClientEvent(client, "buyTuning", client, buyState, activeMenu.id, value)
			end
		end
	end)

function makeTuning(vehicleElement)
    if isElement(vehicleElement) then
        local defaultHandling = getOriginalHandling(getElementModel(vehicleElement))

        -- Collect installed performance tuning values
        local tuningDataValues = {}
        local tuningDataKeys = {
            ["vehicle.tuning.Engine"] = true,
            ["vehicle.tuning.Turbo"] = true,
            ["vehicle.tuning.ECU"] = true,
            ["vehicle.tuning.Transmission"] = true,
            ["vehicle.tuning.Suspension"] = true,
            ["vehicle.tuning.Brakes"] = true,
            ["vehicle.tuning.Tires"] = true,
            ["vehicle.tuning.WeightReduction"] = true
        }

        for dataName in pairs(tuningDataKeys) do
            local dataValue = getElementData(vehicleElement, dataName) or 0

            if dataValue > 0 then
                tuningDataValues[gettok(dataName, 3, ".")] = dataValue
            end
        end

        -- Reset the affected handling properties
        local propertiesToRestore = {}

        for effectName in pairs(tuningDataValues) do
            for propertyName in pairs(tuningEffect[effectName]) do
                propertiesToRestore[propertyName] = true
            end
        end

        for propertyName, propertyValue in pairs(defaultHandling) do
            if propertiesToRestore[propertyName] then
                setVehicleHandling(vehicleElement, propertyName, propertyValue)
            end
        end

        applyHandling(vehicleElement, propertiesToRestore)

        -- Apply the performance tunings
        local currentHandling = getVehicleHandling(vehicleElement)
        local appliedHandling = {}

        for effectName, effectValue in pairs(tuningDataValues) do
            if effectValue ~= 0 then
                for propertyName, propertyValue in pairs(tuningEffect[effectName]) do
                    if currentHandling[propertyName] then
                        if propertyValue[effectValue] then
                            if not appliedHandling[propertyName] then
                                appliedHandling[propertyName] = currentHandling[propertyName]
                            end

                            appliedHandling[propertyName] = appliedHandling[propertyName] + appliedHandling[propertyName] * (propertyValue[effectValue] / 135)
                        end
                    end
                end
            end
        end

        for propertyName, propertyValue in pairs(appliedHandling) do
            setVehicleHandling(vehicleElement, propertyName, propertyValue)
            -- outputDebugString(propertyName .. " -> " .. tostring(propertyValue))
        end

        -- Reset air-ride suspension
        local airRideLevel = getElementData(vehicleElement, "airRideLevel") or 8

        if airRideLevel ~= 8 then
            --local airRideSuspensionLimit = getVehicleSuspensionLimitAffectedByAirRide(vehicleElement, airRideLevel)

            --if currentHandling.suspensionLowerLimit ~= airRideSuspensionLimit then
                local velX, velY, velZ = getElementVelocity(vehicleElement)

                --if airRideSuspensionLimit then
                    setVehicleHandling(vehicleElement, "suspensionLowerLimit", airRideSuspensionLimit)
                    setElementVelocity(vehicleElement, velX, velY, velZ + 0.01)
                --end

                -- outputDebugString("Air-Ride restored after makeTuning function call")
            --end
        end

		local vehicle = vehicleElement
		local currentHandling = getVehicleHandling(vehicle)

		for property, value in pairs(appliedHandling) do
			--[[if property == "engineAcceleration" then
				value = value / 5
				--setVehicleHandling(vehicle, property, tonumber(currentHandling[property]) + value)
				outputDebugString(property .. " -> " .. tostring(value))
			end]]


			if doubleExhaust[getElementModel(vehicle)] then
				setVehicleHandling(vehicle, "modelFlags", 0x00002000)
			end
			if singleExhaust[getElementModel(vehicle)] then
				setVehicleHandling(vehicle, "modelFlags", 0x0)
			end
			if noExhaust[getElementModel(vehicle)] then
				setVehicleHandling(vehicle, "modelFlags", 0x00001000)
			end
		end
    end
end
addEvent("makeTuning", true)
addEventHandler("makeTuning", getRootElement(), makeTuning)

--[[function makeTuning(vehicleElement)
    if isElement(vehicleElement) then
        local defaultHandling = getOriginalHandling(getElementModel(vehicleElement))

        -- Collect installed performance tuning values
        local tuningDataValues = {}
        local tuningDataKeys = {
            ["vehicle.tuning.Engine"] = true,
            ["vehicle.tuning.Turbo"] = true,
            ["vehicle.tuning.ECU"] = true,
            ["vehicle.tuning.Transmission"] = true,
            ["vehicle.tuning.Suspension"] = true,
            ["vehicle.tuning.Brakes"] = true,
            ["vehicle.tuning.Tires"] = true,
            ["vehicle.tuning.WeightReduction"] = true
        }

        for dataName in pairs(tuningDataKeys) do
            local dataValue = getElementData(vehicleElement, dataName) or 0

            if dataValue > 0 then
                tuningDataValues[gettok(dataName, 3, ".")] = dataValue
            end
        end

        -- Reset the affected handling properties
        local propertiesToRestore = {}

        for effectName in pairs(tuningDataValues) do
            for propertyName in pairs(tuningEffect[effectName]) do
                propertiesToRestore[propertyName] = true
            end
        end

        for propertyName, propertyValue in pairs(defaultHandling) do
            if propertiesToRestore[propertyName] then
                setVehicleHandling(vehicleElement, propertyName, propertyValue)
            end
        end

        applyHandling(vehicleElement, propertiesToRestore)

        -- Apply the performance tunings
        local currentHandling = getVehicleHandling(vehicleElement)
        local appliedHandling = {}

        for effectName, effectValue in pairs(tuningDataValues) do
            if effectValue ~= 0 then
                for propertyName, propertyValue in pairs(tuningEffect[effectName]) do
                    if currentHandling[propertyName] then
                        if propertyValue[effectValue] then
                            if not appliedHandling[propertyName] then
                                appliedHandling[propertyName] = currentHandling[propertyName]
                            end

                            appliedHandling[propertyName] = appliedHandling[propertyName] + appliedHandling[propertyName] * (propertyValue[effectValue] / 135)
                        end
                    end
                end
            end
        end

        for propertyName, propertyValue in pairs(appliedHandling) do
            setVehicleHandling(vehicleElement, propertyName, propertyValue)
            -- outputDebugString(propertyName .. " -> " .. tostring(propertyValue))
        end

        -- Reset air-ride suspension
        local airRideLevel = getElementData(vehicleElement, "airRideLevel") or 8

        if airRideLevel ~= 8 then
        	local getVehicleSuspensionLimitAffectedByAirRide = getElementData(vehicleElement, "airRideLevel") or 8
            local airRideSuspensionLimit = getVehicleSuspensionLimitAffectedByAirRide

            if currentHandling.suspensionLowerLimit ~= airRideSuspensionLimit then
                local velX, velY, velZ = getElementVelocity(vehicleElement)

                if airRideSuspensionLimit then
                    setVehicleHandling(vehicleElement, "suspensionLowerLimit", airRideSuspensionLimit)
                    setElementVelocity(vehicleElement, velX, velY, velZ + 0.01)
                end

                -- outputDebugString("Air-Ride restored after makeTuning function call")
            end
        end
    end
end
addEvent("makeTuning", true)
addEventHandler("makeTuning", getRootElement(), makeTuning)]]

addEvent("setAirRide", true)
addEventHandler("setAirRide", getRootElement(),
	function (vehicle, level, players)
		if client == source and isElement(vehicle) and level then
			local originalLimit = getHandlingProperty(vehicle, "suspensionLowerLimit")
			local newLimit = originalLimit + (level - 8) * 0.0175

			setVehicleHandling(vehicle, "suspensionLowerLimit", newLimit)
			setElementData(vehicle, "airRideLevel", level)

			local x, y, z = getElementPosition(vehicle)

			setElementPosition(vehicle, x, y, z + 0.01)
			setElementPosition(vehicle, x, y, z)

			triggerClientEvent(players or getElementsByType("player"), "playAirRideSound", source, vehicle)
		end
	end)

addEvent("setDriveType", true)
addEventHandler("setDriveType", getRootElement(),
	function (driveType)
		if driveType and isElement(source) then
			setElementData(source, "activeDriveType", driveType)
			makeTuning(source)
		end
	end)

addCommandHandler("tuningveh",
	function (sourcePlayer, commandName)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			local currentVeh = getPedOccupiedVehicle(sourcePlayer)

			if currentVeh then
				setElementData(currentVeh, "vehicle.tuning.Engine", 4)
				setElementData(currentVeh, "vehicle.tuning.Turbo", 4)
				setElementData(currentVeh, "vehicle.tuning.ECU", 4)
				setElementData(currentVeh, "vehicle.tuning.Transmission", 4)
				setElementData(currentVeh, "vehicle.tuning.Suspension", 4)
				setElementData(currentVeh, "vehicle.tuning.Brakes", 4)
				setElementData(currentVeh, "vehicle.tuning.Tires", 4)
				--setElementData(currentVeh, "vehicle.tuning.WeightReduction", 4)
				makeTuning(currentVeh)
				outputChatBox("Jármű kifullozva.", sourcePlayer)
			end
		end
	end)

addCommandHandler("removetuning",
	function (sourcePlayer, commandName)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			local currentVeh = getPedOccupiedVehicle(sourcePlayer)

			if currentVeh then
				setElementData(currentVeh, "vehicle.tuning.Engine", 0)
				setElementData(currentVeh, "vehicle.tuning.Turbo", 0)
				setElementData(currentVeh, "vehicle.tuning.ECU", 0)
				setElementData(currentVeh, "vehicle.tuning.Transmission", 0)
				setElementData(currentVeh, "vehicle.tuning.Suspension", 0)
				setElementData(currentVeh, "vehicle.tuning.Brakes", 0)
				setElementData(currentVeh, "vehicle.tuning.Tires", 0)
				setElementData(currentVeh, "vehicle.tuning.WeightReduction", 0)
				makeTuning(currentVeh)
				outputChatBox("Tuningok kiszedve.", sourcePlayer)
			end
		end
	end
)

