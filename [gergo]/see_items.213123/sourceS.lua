connection = false

itemsTable = {}
inventoryInUse = {}

local wallNotes = {}
local playerItemObjects = {}

local lastWeaponSerial = 0
local lastTicketSerial = 0

local trackingTimer = {}

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()

		setTimer(processPerishableItems, 1000 * 60, 0)
		setTimer(removeWallNotes, 1000 * 60 * 60 * 5, 0)

		if fileExists("saves.json") then
			local jsonFile = fileOpen("saves.json")
			if jsonFile then
				local fileContent = fileRead(jsonFile, fileGetSize(jsonFile))

				fileClose(jsonFile)

				if fileContent then
					local jsonData = fromJSON(fileContent) or {}

					lastWeaponSerial = tonumber(jsonData.lastWeaponSerial)
					lastTicketSerial = tonumber(jsonData.lastTicketSerial)
				end
			end
		end
	end)

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		for k, v in pairs(getElementsByType("player")) do
			takeAllWeapons(v)
			removeElementData(v, "canisterInHand")
		end

		if fileExists("saves.json") then
			fileDelete("saves.json")
		end

		local jsonFile = fileCreate("saves.json")
		if jsonFile then
			local jsonData = {}

			jsonData.lastWeaponSerial = tonumber(lastWeaponSerial or 0)
			jsonData.lastTicketSerial = tonumber(lastTicketSerial or 0)

			fileWrite(jsonFile, toJSON(jsonData, true, "tabs"))
			fileClose(jsonFile)
		end
	end)

addEventHandler("onElementDestroy", getRootElement(),
	function ()
		if itemsTable[source] then
			itemsTable[source] = nil
		end

		if inventoryInUse[source] then
			inventoryInUse[source] = nil
		end
	end)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "loggedIn" then
			if getElementData(source, dataName) then
				setTimer(triggerEvent, 1000, 1, "requestCache", source)
			end
		end

		if dataName == "canisterInHand" then
			if getElementData(source, "canisterInHand") then
				playerItemObjects[source] = createObject(363, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					exports.see_boneattach:attachElementToBone(playerItemObjects[source], source, 12, 0, 0.025, -0.025, 0, 270, 180)
				end
			else
				if playerItemObjects[source] then
					exports.see_boneattach:detachElementFromBone(playerItemObjects[source])

					if isElement(playerItemObjects[source]) then
						destroyElement(playerItemObjects[source])
					end

					playerItemObjects[source] = nil
				end
			end
		elseif dataName == "usingGrinder" then
			if getElementData(source, "usingGrinder") then
				playerItemObjects[source] = createObject(1636, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					setElementInterior(playerItemObjects[source], getElementInterior(source))
					setElementDimension(playerItemObjects[source], getElementDimension(source))

					exports.see_boneattach:attachElementToBone(playerItemObjects[source], source, 12, 0, 0.05, 0.025, 0, 270, 90)
				end
			else
				if playerItemObjects[source] then
					exports.see_boneattach:detachElementFromBone(playerItemObjects[source])

					if isElement(playerItemObjects[source]) then
						destroyElement(playerItemObjects[source])
					end

					playerItemObjects[source] = nil
				end
			end
		elseif dataName == "fishingRodInHand" then
			if getElementData(source, "fishingRodInHand") then
				playerItemObjects[source] = createObject(2993, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					setElementInterior(playerItemObjects[source], getElementInterior(source))
					setElementDimension(playerItemObjects[source], getElementDimension(source))
					exports.see_boneattach:attachElementToBone(playerItemObjects[source], source, 12, 0.05, 0.05, 0.05, 0, -90, 0)
					setElementData(source, "attachedObject", playerItemObjects[source])
				end
			else
				if playerItemObjects[source] then
					if isElement(playerItemObjects[source]) then
						if getElementModel(playerItemObjects[source]) == 2993 then
							exports.see_boneattach:detachElementFromBone(playerItemObjects[source])
							destroyElement(playerItemObjects[source])
							playerItemObjects[source] = nil
							setElementData(source, "attachedObject", false)
						end
					end
				end
			end
		end
	end)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		if playerItemObjects[source] then
			exports.see_boneattach:detachElementFromBone(playerItemObjects[source])

			if isElement(playerItemObjects[source]) then
				destroyElement(playerItemObjects[source])
			end

			playerItemObjects[source] = nil
		end

		if trackingTimer[source] then
			if isTimer(trackingTimer[source]) then
				killTimer(trackingTimer[source])
			end

			trackingTimer[source] = nil
		end

		if itemsTable[source] then
			for k, v in pairs(itemsTable[source]) do
				if v.itemId == 361 then
					takeItem(source, "dbID", v.dbID)
				end
			end
		end
	end)

addEvent("ä}€[[€ÄŁ", true)
addEventHandler("ä}€[[€ÄŁ", getRootElement(),
	function (casetteMoney)
		if isElement(source) then
			local currentMoney = getElementData(source, "char.Money") or 0

			currentMoney = currentMoney + casetteMoney

			setElementData(source, "char.Money", currentMoney)
			setPedAnimation(source, false)
		end
	end)

function useItem(item, additional, additional2)
	if not source then
		source = sourceElement
	end

	if not isElement(source) then
		return
	end

	if not item or not item.dbID then
		return
	end

	local itemId = item.itemId

	-- ** Láda
	if itemId == 247 then
		local chestItems = {253, 254, 259, 260}
		takeItem(source, "dbID", item.dbID)
		giveItem(source, chestItems[math.random(1, #chestItems)], 1)
	-- * Horgászbot
	elseif itemId == 215 then
		if getElementData(source, "fishingRodInHand") then
			setElementData(source, "fishingRodInHand", false)
			triggerClientEvent(source, "updateInUse", source, "player", item.dbID, false)
			exports.see_chat:localAction(source, "elrak egy horgászbotot.")
		else
			setElementData(source, "fishingRodInHand", item.dbID)
			triggerClientEvent(source, "updateInUse", source, "player", item.dbID, true)
			exports.see_chat:localAction(source, "elővesz egy horgászbotot.")
		end
	-- ** Pénzkazetta
	elseif itemId == 361 then
		if not getElementData(source, "openingMoneyCasette") then
			if hasItem(source, 34) and hasItem(source, 362) then
				if getElementData(source, "currentCraftingPosition") then
					setElementFrozen(source, true)

					setPedAnimation(source, "GANGS", "prtial_gngtlkE", -1, true, false, false, false)

					triggerClientEvent(source, "startMoneyCasetteOpen", source)

					takeItem(source, "dbID", item.dbID)
				else
					exports.see_hud:showInfobox(source, "e", "Csak a megfelelő helyen nyithatod ki a pénzkazettát.")
				end
			else
				exports.see_hud:showInfobox(source, "e", "A pénzkazetta kinyitásához kalapácsra és vésőre lesz szükséged!")
			end
		end
	-- ** Flex
	elseif itemId == 245 then
		local usingGrinder = getElementData(source, "usingGrinder")

		if not usingGrinder then
			if isElement(playerItemObjects[source]) then
				exports.see_boneattach:detachElementFromBone(playerItemObjects[source])
				destroyElement(playerItemObjects[source])
			end

			setElementData(source, "usingGrinder", item.dbID)
			triggerClientEvent(source, "updateInUse", source, "player", item.dbID, true)

			exports.see_chat:localAction(source, "elővesz egy flexet.")
		elseif usingGrinder == item.dbID then
			if isElement(playerItemObjects[source]) then
				exports.see_boneattach:detachElementFromBone(playerItemObjects[source])
				destroyElement(playerItemObjects[source])
			end

			removeElementData(source, "usingGrinder")
			triggerClientEvent(source, "updateInUse", source, "player", item.dbID, false)

			exports.see_chat:localAction(source, "elrak egy flexet.")
		else
			exports.see_hud:showInfobox(source, "e", "Már van egy flex a kezedben.")
		end
	-- ** Mester könyvek
	elseif itemId >= 234 and itemId <= 244 then
		local skillTable = {}
		local itemToStat = {
			[234] = 69,
			[235] = 70,
			[236] = 71,
			[237] = 75,
			[238] = 76,
			[239] = 77,
			[240] = 78,
			[241] = 79,
			[242] = 72,
			[243] = 74,
			[244] = 73
		}

		if getPedStat(source, itemToStat[itemId]) < 1000 then
			setPedStat(source, itemToStat[itemId], 1000)

			for i = 69, 79 do
				table.insert(skillTable, getPedStat(source, i))
			end

			skillTable = table.concat(skillTable, ",")

			if skillTable then
				takeItem(source, "dbID", item.dbID)
				dbExec(connection, "UPDATE characters SET weaponSkills = ? WHERE characterId = ?", skillTable, getElementData(source, "char.ID"))
			end

			exports.see_hud:showInfobox(source, "s", "Sikeresen a kiválasztott fegyver mestere lettél: " .. getItemName(itemId):gsub("A fegyvermester: ", "") .. ".")
		else
			exports.see_hud:showInfobox(source, "e", "A kiválasztott fegyvernek már a mestere vagy!")
		end
	-- ** Instant gyógyítás
	elseif itemId == 190 then
		if not getElementData(source, "isPlayerDeath") and getElementHealth(source) > 0 then
			takeItem(source, "dbID", item.dbID, 1)

			exports.see_damage:helpUpPerson(source)

			setElementData(source, "char.Hunger", 100)
			setElementData(source, "char.Thirst", 100)

			outputChatBox("#dc143c[SeeMTA]: #ffffffA kártya sikeresen meggyógyított.", source, 255, 255, 255, true)
		else
			exports.see_hud:showInfobox(source, "e", "A halálból nincs visszaút..")
		end
	-- ** Instant üzemanyag
	elseif itemId == 189 then
		local pedveh = getPedOccupiedVehicle(source)

		if isElement(pedveh) then
			takeItem(source, "dbID", item.dbID, 1)

			setElementData(pedveh, "vehicle.fuel", exports.see_vehiclepanel:getTheFuelTankSizeOfVehicle(getElementModel(pedveh)))

			outputChatBox("#dc143c[SeeMTA]: #ffffffA kártya sikeresen teletankolta a járművet amiben ülsz.", source, 255, 255, 255, true)
		else
			exports.see_hud:showInfobox(source, "e", "Nem ülsz járműben!")
		end
	-- ** Instant fix
	elseif itemId == 188 then
		local pedveh = getPedOccupiedVehicle(source)

		if isElement(pedveh) then
			takeItem(source, "dbID", item.dbID, 1)

			fixVehicle(pedveh)
			setVehicleDamageProof(pedveh, false)

			for i = 0, 6 do
				removeElementData(pedveh, "panelState:" .. i)
			end

			outputChatBox("#dc143c[SeeMTA]: #ffffffA kártya sikeresen megjavította a járművet amiben ülsz.", source, 255, 255, 255, true)
		else
			exports.see_hud:showInfobox(source, "e", "Nem ülsz járműben!")
		end
	-- ** Benzines kanna
	elseif itemId == 125 then
		local canisterInHand = getElementData(source, "canisterInHand")

		if not canisterInHand then
			if isElement(playerItemObjects[source]) then
				exports.see_boneattach:detachElementFromBone(playerItemObjects[source])
				destroyElement(playerItemObjects[source])
			end

			setElementData(source, "canisterInHand", item.dbID)
			triggerClientEvent(source, "updateInUse", source, "player", item.dbID, true)
		elseif canisterInHand == item.dbID then
			if isElement(playerItemObjects[source]) then
				exports.see_boneattach:detachElementFromBone(playerItemObjects[source])
				destroyElement(playerItemObjects[source])
			end

			removeElementData(source, "canisterInHand")
			triggerClientEvent(source, "updateInUse", source, "player", item.dbID, false)
		else
			exports.see_hud:showInfobox(source, "e", "Már van egy kanna a kezedben.")
		end
	-- ** Hi-Fi
	elseif itemId == 150 then
		exports.see_radio:placeRadio(source, item.dbID)
	-- ** Blueprint
	elseif itemId == 299 then
		local playerRecipes = getElementData(source, "playerRecipes") or {}
		local recipeId = tonumber(item.data1) or 1

		if playerRecipes[recipeId] then
			exports.see_hud:showInfobox(source, "e", "Ezt a receptet már megtanultad.")
		else
			local temp = {}
			playerRecipes[recipeId] = true

			for k, v in pairs(playerRecipes) do
				table.insert(temp, k)
			end

			setElementData(source, "playerRecipes", playerRecipes)
			takeItem(source, "dbID", item.dbID)
			exports.see_hud:showInfobox(source, "s", "Sikeresen megtanultad a kiválasztott receptet. (" .. availableRecipes[recipeId].name .. ")")

			dbExec(connection, "UPDATE characters SET playerRecipes = ? WHERE characterId = ?", table.concat(temp, ","), getElementData(source, "char.ID"))
		end
	-- ** Kártyapakli
	elseif itemId == 205 then
		local cards = {"Ász", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Bubi", "Dáma", "Király"}
		local sign = {"Kőr", "Káró", "Treff", "Pikk"}
		local number = math.random(#cards)
		local snumber = math.random(#sign)

		exports.see_chat:localAction(source, "húz egy lapot a pakliból.")
		exports.see_chat:sendLocalDo(source, "Eredmény: " .. cards[number] .. "-" .. sign[snumber])

		triggerClientEvent(additional2, "playCardSound", source)
	-- ** Dobókocka
	elseif itemId == 204 then
		exports.see_chat:localAction(source, "dob egyet a dobókockával.")
		exports.see_chat:sendLocalDo(source, "Eredmény: " .. math.random(6))

		triggerClientEvent(additional2, "playDiceSound", source)
	-- ** Petárda
	elseif itemId == 165 or itemId == 166 then
		triggerClientEvent(additional2, "playFireworkSound", source, itemId == 165 and "small" or "large")
		takeItem(source, "dbID", item.dbID, 1)
	-- ** Speciális itemek
	elseif specialItems[itemId] and additional then
		if additional2 then
			local model = false

			setElementData(source, "fishingRodInHand", false)

			if isElement(playerItemObjects[source]) then
				exports.see_boneattach:detachElementFromBone(playerItemObjects[source])
				destroyElement(playerItemObjects[source])
			end

			if additional2 == "pizza" then
				playerItemObjects[source] = createObject(2702, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					exports.see_boneattach:attachElementToBone(playerItemObjects[source], source, 12, 0, 0.12, 0.08, 180, 90, 180)
				end
			elseif additional2 == "kebab" then
				playerItemObjects[source] = createObject(2769, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					exports.see_boneattach:attachElementToBone(playerItemObjects[source], source, 12, 0, 0.05, 0.08, 0, 0)
				end
			elseif additional2 == "hamburger" then
				playerItemObjects[source] = createObject(2703, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					exports.see_boneattach:attachElementToBone(playerItemObjects[source], source, 12, 0, 0.08, 0.08, 180, 0)
				end
			elseif additional2 == "beer" then
				playerItemObjects[source] = createObject(1509, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					exports.see_boneattach:attachElementToBone(playerItemObjects[source], source, 11, 0, 0.05, 0.08, 90, 0, 90)
					setObjectScale(itemObjs[playerSource], 0.8)
				end
			elseif additional2 == "wine" then
				playerItemObjects[source] = createObject(1664, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					exports.see_boneattach:attachElementToBone(playerItemObjects[source], source, 11, 0, 0.05, 0.08, 90, 0, 90)
				end
			elseif additional2 == "drink" then
				local model = ({1546, 2647})[math.random(2)]

				playerItemObjects[source] = createObject(model, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					exports.see_boneattach:attachElementToBone(playerItemObjects[source], source, 11, 0, 0.05, 0.08, 90, 0, 90)

					if model == 2647 then
						setObjectScale(playerItemObjects[source], 0.6)
					end
				end
			elseif additional2 == "cigarette" then
				playerItemObjects[source] = createObject(3027, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					exports.see_boneattach:attachElementToBone(playerItemObjects[source], source, 12, 0, 0.04, 0.15, 0, 0, 90)
				end
			end

			if isElement(playerItemObjects[source]) then
				setElementCollisionsEnabled(playerItemObjects[source], false)
				setElementDoubleSided(playerItemObjects[source], true)
				setElementInterior(playerItemObjects[source], getElementInterior(source))
				setElementDimension(playerItemObjects[source], getElementDimension(source))
			end
		end
	end

	triggerClientEvent(source, "movedItemInInv", source, true)
end
addEvent("useItem", true)
addEventHandler("useItem", getRootElement(), useItem)

function giveHealth(element, health)
	health = tonumber(health)

	if health then
		setElementHealth(element, math.min(100, getElementHealth(element) + health))
	end
end

addEvent("useSpecialItem", true)
addEventHandler("useSpecialItem", getRootElement(),
	function (currentItemInUse, currentItemUses)
		if currentItemInUse then
			local itemId = currentItemInUse.itemId
			local specialItem = specialItems[itemId]

			if specialItem then
				if specialItem[1] == "pizza" or specialItem[1] == "kebab" or specialItem[1] == "hamburger" then
					triggerEvent("playAnimation", client, "food")
				elseif specialItem[1] == "beer" or specialItem[1] == "wine" or specialItem[1] == "drink" then
					triggerEvent("playAnimation", client, "drink")
				elseif specialItem[1] == "cigarette" then
					triggerEvent("playAnimation", client, "smoke")
				end

				local slotId = getItemSlotID(source, currentItemInUse.dbID)
				local amount = math.random(7, 20)

				if slotId then
					itemsTable[source][slotId].data1 = currentItemUses

					if perishableItems[itemId] then
						local damage = tonumber(itemsTable[source][slotId].data3) or 0
						local condition = math.floor(100 - damage / perishableItems[itemId] * 100)

						if condition < 20 then
							local loss = 20 - condition * 0.5
							local health = getElementHealth(source) - loss

							amount = 0

							if health <= 0 then
								health = 0
								setElementData(source, "customDeath", "ételmérgezés")
							end

							setElementHealth(source, health)
							triggerClientEvent(source, "rottenEffect", source, damage / perishableItems[itemId])
						end
					end

					if specialItem[1] == "pizza" or specialItem[1] == "kebab" or specialItem[1] == "hamburger" then
						local currentHunger = getElementData(source, "char.Hunger") or 100

						if currentHunger + amount > 100 then
							setElementData(source, "char.Hunger", 100)
						else
							setElementData(source, "char.Hunger", currentHunger + amount)
						end
					elseif specialItem[1] == "beer" or specialItem[1] == "wine" or specialItem[1] == "drink" then
						local currentThirst = getElementData(source, "char.Thirst") or 100

						if currentThirst + amount > 100 then
							setElementData(source, "char.Thirst", 100)
						else
							setElementData(source, "char.Thirst", currentThirst + amount)
						end
					end

					dbExec(connection, "UPDATE items SET data1 = ? WHERE dbID = ?", currentItemUses, itemsTable[source][slotId].dbID)
				end
			end
		end
	end)

addEvent("detachObject", true)
addEventHandler("detachObject", getRootElement(),
	function ()
		if playerItemObjects[source] then
			exports.see_boneattach:detachElementFromBone(playerItemObjects[source])

			if isElement(playerItemObjects[source]) then
				destroyElement(playerItemObjects[source])
			end

			playerItemObjects[source] = nil
		end
	end)

addEvent("playAnimation", true)
addEventHandler("playAnimation", getRootElement(),
	function (typ)
		if typ then
			if typ == "food" then
				setPedAnimation(source, "FOOD", "eat_pizza", 4000, false, true, true, false)
			elseif typ == "drink" then
				setPedAnimation(source, "VENDING", "vend_drink2_p", 1200, false, true, true, false)
			elseif typ == "smoke" then
				setPedAnimation(source, "SMOKING", "M_smkstnd_loop", 4000, false, true, true, false)
			end
		end
	end)

function bodySearchFunction(sourcePlayer, commandName, targetPlayer)
	if getElementData(sourcePlayer, "loggedIn") then
		if not targetPlayer then
			outputChatBox("#ff9900[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", sourcePlayer, 255, 255, 255, true)
		else
			targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				local px, py, pz = getElementPosition(sourcePlayer)
				local pint = getElementInterior(sourcePlayer)
				local pdim = getElementDimension(sourcePlayer)

				local tx, ty, tz = getElementPosition(targetPlayer)
				local tint = getElementInterior(targetPlayer)
				local tdim = getElementDimension(targetPlayer)

				if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 3 and pint == tint and pdim == tdim then
					triggerClientEvent(sourcePlayer, "bodySearchGetDatas",
						sourcePlayer,
						itemsTable[targetPlayer] or {},
						targetName:gsub("_", " "),
						getElementData(targetPlayer, "char.Money") or 0
					)

					exports.see_chat:localAction(sourcePlayer, "megmotozott valakit. ((" .. targetName:gsub("_", " ") .. "))")
				else
					outputChatBox("#dc143c[SeeMTA]: #ffffffA kiválasztott játékos túl messze van tőled!", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end
end
addCommandHandler("frisk", bodySearchFunction)
addCommandHandler("motoz", bodySearchFunction)
addCommandHandler("motozás", bodySearchFunction)

function removeWallNotes()
	local time = getRealTime().timestamp

	for k, v in pairs(wallNotes) do
		if time >= v[9] then
			wallNotes[k] = nil
			triggerLatentClientEvent(getElementsByType("player"), "deleteWallNote", resourceRoot, k)
		end
	end
end

addEvent("requestWallNotes", true)
addEventHandler("requestWallNotes", getRootElement(),
	function ()
		if isElement(source) then
			triggerLatentClientEvent(source, "gotRequestWallNotes", source, wallNotes)
		end
	end)

addEvent("deleteWallNote", true)
addEventHandler("deleteWallNote", getRootElement(),
	function (id)
		if isElement(source) then
			wallNotes[id] = nil
			triggerLatentClientEvent(getElementsByType("player"), "deleteWallNote", source, id)
		end
	end)

addEvent("putNoteOnWall", true)
addEventHandler("putNoteOnWall", getRootElement(),
	function (pixels, x, y, z, int, dim, nx, ny, itemId, title)
		if isElement(source) then
			if pixels and itemId then
				local characterId = getElementData(source, "char.ID")
				local placednotes = 0

				for k, v in pairs(wallNotes) do
					if v[2] == characterId then
						placednotes = placednotes + 1
					end
				end

				if placednotes >= 3 then
					exports.see_hud:showInfobox(source, "e", "Maximum 3 jegyzetet tűzhetsz ki egyszerre!")
				else
					local slot = getItemSlotID(source, itemId)

					if slot then
						local time = getRealTime().timestamp
						local id = 1

						for i = 1, #wallNotes + 1 do
							if not wallNotes[i] then
								id = i
								break
							end
						end

						wallNotes[id] = {pixels, characterId, false, x, y, z, int, dim, time + 60 * 60 * 3, nx, ny, title}

						triggerClientEvent(source, "deleteItem", source, "player", {itemsTable[source][slot].dbID})
						triggerClientEvent(source, "movedItemInInv", source, true)

						dbExec(connection, "DELETE FROM items WHERE dbID = ?", itemsTable[source][slot].dbID)

						itemsTable[source][slot] = nil

						triggerLatentClientEvent(getElementsByType("player"), "addWallNote", source, id, wallNotes[id])

						exports.see_hud:showInfobox(source, "s", "Sikeresen kitűzted! Várj egy kicsit, és megjelenik!")
					end
				end
			else
				exports.see_hud:showInfobox(source, "e", "A jegyzet kitűzése meghiúsult!")
			end
		end
	end)

addEvent("showTheItem", true)
addEventHandler("showTheItem", getRootElement(),
	function (item, nearby)
		if isElement(source) then
			if type(item) == "table" and type(nearby) == "table" then
				triggerLatentClientEvent(nearby, "showTheItem", source, item)
			end
		end
	end)

addEvent("damagePen", true)
addEventHandler("damagePen", getRootElement(),
	function (itemId, damage)
		if isElement(source) then
			itemId = tonumber(itemId)
			damage = tonumber(damage)

			if itemId and damage then
				local slot = getItemSlotID(source, itemId)

				if slot then
					itemsTable[source][slot].data1 = damage

					dbExec(connection, "UPDATE items SET data1 = ? WHERE dbID = ?", damage, itemsTable[source][slot].dbID)

					triggerClientEvent(source, "updateData1", source, "player", itemsTable[source][slot].dbID, damage)
				end
			end
		end
	end)

addEvent("tryToRenameItem", true)
addEventHandler("tryToRenameItem", getRootElement(),
	function (text, renameItemId, nameTagItemId)
		if isElement(source) and text and renameItemId and nameTagItemId then
			local renameSlot = getItemSlotID(source, renameItemId)
			local nametagSlot = getItemSlotID(source, nameTagItemId)
			local success = 0

			if renameSlot then
				itemsTable[source][renameSlot].nameTag = text
				success = success + 1
			end

			if nametagSlot then
				itemsTable[source][nametagSlot] = nil
				success = success + 1
			end

			if success == 2 then
				dbExec(connection, "UPDATE items SET nameTag = ? WHERE dbID = ?", text, renameItemId)
				dbExec(connection, "DELETE FROM items WHERE dbID = ?", nameTagItemId)

				triggerClientEvent(source, "updateNameTag", source, renameItemId, text)
				triggerClientEvent(source, "deleteItem", source, "player", {nameTagItemId})
			else
				exports.see_hud:showInfobox(source, "e", "Az item átnevezése meghiúsult.")
			end
		end
	end)

addEvent("requestCrafting", true)
addEventHandler("requestCrafting", getRootElement(),
	function (selectedRecipe, takeItems, nearbyPlayers)
		if isElement(source) and selectedRecipe then
			if availableRecipes[selectedRecipe] and itemsTable[source] then
				local recipe = availableRecipes[selectedRecipe]
				local deletedItems = {}

				for i = 1, #takeItems do
					local id = takeItems[i]

					if not craftDoNotTakeItems[id] then
						for k, v in pairs(itemsTable[source]) do
							if v.itemId == id then
								table.insert(deletedItems, v.dbID)
								itemsTable[source][v.slot] = nil
								break
							end
						end
					end
				end

				if #deletedItems > 0 then
					triggerClientEvent(source, "deleteItem", source, "player", deletedItems)
					triggerClientEvent(source, "movedItemInInv", source, true)
					dbExec(connection, "DELETE FROM items WHERE dbID IN (" .. table.concat(deletedItems, ",") .. ")")
				end

				triggerLatentClientEvent(source, "requestCrafting", source, selectedRecipe, true)

				if recipe.finalItem[3] and recipe.finalItem[4] then -- fegyverek craftolása random állapottal
					giveItem(source, recipe.finalItem[1], recipe.finalItem[2], false, math.random(recipe.finalItem[3], recipe.finalItem[4]), false, false)
					triggerLatentClientEvent(nearbyPlayers, "crafting3dSound", source, "hammer")
				else
					giveItem(source, recipe.finalItem[1], recipe.finalItem[2])
					triggerLatentClientEvent(nearbyPlayers, "crafting3dSound", source, "crafting")
				end

				setElementFrozen(source, true)
				setPedAnimation(source, "GANGS", "prtial_gngtlkE", 10000, true, false, false, false)
				setTimer(
					function (sourcePlayer)
						if isElement(sourcePlayer) then
							setElementFrozen(sourcePlayer, false)
							setPedAnimation(sourcePlayer, false)
						end
					end,
				10000, 1, source)
			end
		end
	end)

addEvent("weaponOverheat", true)
addEventHandler("weaponOverheat", getRootElement(),
	function (nearby, itemId)
		if isElement(source) and itemId then
			itemId = tonumber(itemId)

			if itemId then
				local slot = getItemSlotID(source, itemId)
				local damage = math.random(5)

				if slot then
					local newAmount = (tonumber(itemsTable[source][slot].data1) or 0) + damage

					if newAmount >= 100 then
						takeAllWeapons(source)

						itemsTable[source][slot] = nil

						dbExec(connection, "DELETE FROM items WHERE dbID = ?", itemsTable[source][slot].dbID)

						triggerClientEvent(source, "unuseAmmo", source)
						triggerClientEvent(source, "deleteItem", source, "player", {itemsTable[source][slot].dbID})
						triggerClientEvent(source, "movedItemInInv", source)
					else
						itemsTable[source][slot].data1 = newAmount

						dbExec(connection, "UPDATE items SET data1 = ? WHERE dbID = ?", newAmount, itemsTable[source][slot].dbID)

						triggerClientEvent(source, "updateData1", source, "player", itemsTable[source][slot].dbID, newAmount)
					end
				end

				triggerLatentClientEvent(nearby, "weaponOverheatSound", source)
			end
		end
	end)

addEvent("reloadPlayerWeapon", true)
addEventHandler("reloadPlayerWeapon", getRootElement(),
	function ()
		if isElement(source) then
			reloadPedWeapon(source)
		end
	end)

addEvent("takeWeapon", true)
addEventHandler("takeWeapon", getRootElement(),
	function ()
		if isElement(source) then
			takeAllWeapons(source)
		end
	end)

addEvent("giveWeapon", true)
addEventHandler("giveWeapon", getRootElement(),
	function (itemId, weaponId, ammo)
		if isElement(source) then
			takeAllWeapons(source)
			giveWeapon(source, weaponId, ammo, true)
			reloadPedWeapon(source)
		end
	end)

addEvent("updateData2", true)
addEventHandler("updateData2", getRootElement(),
	function (element, itemId, newData)
		if itemsTable[element] then
			itemId = tonumber(itemId)

			if itemId and newData then
				local slot = getItemSlotID(element, itemId)

				if slot then
					itemsTable[element][slot].data2 = newData
					dbExec(connection, "UPDATE items SET data2 = ? WHERE dbID = ?", newData, itemsTable[element][slot].dbID)
				end
			end
		end
	end)

addEvent("updateData3", true)
addEventHandler("updateData3", getRootElement(),
	function (element, itemId, newData)
		if itemsTable[element] then
			itemId = tonumber(itemId)

			if itemId and newData then
				local slot = getItemSlotID(element, itemId)

				if slot then
					itemsTable[element][slot].data3 = newData
					dbExec(connection, "UPDATE items SET data3 = ? WHERE dbID = ?", newData, itemsTable[element][slot].dbID)
				end
			end
		end
	end)

addEvent("ticketPerishableEvent", true)
addEventHandler("ticketPerishableEvent", getRootElement(),
	function (itemId)
		if itemsTable[source] then
			itemId = tonumber(itemId)

			if itemId then
				outputDebugString("ticketPerishableEvent")
				-- #d75959[SeeMTA]: #ffffffMivel nem fizetted be a csekket, ezért automatikusan le lett vonva a büntetés 110%-a. (x$)
			end
		end
	end)

addEvent("fishPerishableEvent", true)
addEventHandler("fishPerishableEvent", getRootElement(),
	function (itemId)
		if itemsTable[source] then
			itemId = tonumber(itemId)

			if itemId then
				local ownerType = getElementType(source)
				local slot = getItemSlotID(source, itemId)

				if slot then
					itemsTable[source][slot].itemId = 219

					dbExec(connection, "UPDATE items SET itemId = 219 WHERE dbID = ?", itemsTable[source][slot].dbID)

					if ownerType == "player" then
						triggerClientEvent(source, "updateItemID", source, "player", itemsTable[source][slot].dbID, 219)
						triggerClientEvent(source, "movedItemInInv", source, true)
					end
				end
			end
		end
	end)

function processPerishableItems()
	for element in pairs(itemsTable) do
		if isElement(element) then
			local elementType = getElementType(element)

			if elementType == "vehicle" or elementType == "object" then
				for k, v in pairs(itemsTable[element]) do
					local itemId = v.itemId

					if perishableItems[itemId] then
						local value = (tonumber(v.data3) or 0) + 1

						if value - 1 > perishableItems[itemId] then
							triggerEvent("updateData3", element, element, v.dbID, perishableItems[itemId])
						end

						if value <= perishableItems[itemId] then
							triggerEvent("updateData3", element, element, v.dbID, value)
						elseif perishableEvent[itemId] then
							triggerEvent(perishableEvent[itemId], element, v.dbID)
						end
					end
				end
			end
		else
			itemsTable[element] = nil
		end
	end

	-- for k, v in pairs(worldItems) do
	-- 	local itemId = v.itemId

	-- 	if perishableItems[v.itemId] then
	-- 		local value = (tonumber(v.data3) or 0) + 1

	-- 		if value - 1 > perishableItems[itemId] then
	-- 			v.data3 = perishableItems[itemId]
	-- 			dbExec(connection, "UPDATE items SET data3 = ? WHERE dbID = ?", v.data3, v.dbID)
	-- 		end

	-- 		if value <= perishableItems[itemId] then
	-- 			v.data3 = value
	-- 			dbExec(connection, "UPDATE items SET data3 = ? WHERE dbID = ?", v.data3, v.dbID)
	-- 		end
	-- 	end
	-- end
end

addCommandHandler("giveitem",
	function (sourcePlayer, commandName, targetPlayer, itemId, amount, data1, data2, data3)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 7 then
			itemId = tonumber(itemId)
			amount = tonumber(amount) or 1

			if not targetPlayer or not itemId or not amount then
				outputChatBox("[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Item ID] [Mennyiség] [ < Data 1 | Data 2 | Data 3 > ]", sourcePlayer, 255, 150, 0, true)
			else
				targetPlayer = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local state = giveItem(targetPlayer, itemId, amount, false, data1, data2, data3)

					if state then
						outputChatBox("#DC143C[SeeMTA]: #ffffffA kiválasztott tárgy sikeresen odaadásra került.", sourcePlayer, 0, 0, 0, true)

						exports.see_logs:logCommand(sourcePlayer, commandName, {
							"accountId: " .. getElementData(targetPlayer, "char.accID"),
							"characterId: " .. getElementData(targetPlayer, "char.ID"),
							"itemId: " .. itemId,
							"amount: " .. amount,
							"data1: " .. tostring(data1),
							"data2: " .. tostring(data2),
							"data3: " .. tostring(data3)
						})
					else
						outputChatBox("#DC143C[SeeMTA]: #ffffffA kiválasztott tárgy odaadása meghiúsult.", sourcePlayer, 0, 0, 0, true)
					end
				end
			end
		end
	end)

local blackjackRewards = {
	-- esély, nyeremény
	{100, 5},
	{85, 10},
	{75, 15},
	{65, 25},
	{55, 50},
	{45, 75},
	{25, 100000},
	{5, 200000},
	{1, 1000000}
}

function generateBlackjack(serial)
	local winnerNumber = math.random(1, 21)
	local numberChance = math.random(1, 100) / 100

	if numberChance < 0.1 then
		numberChance = 0.1
	end

	local numsKeyed = {}
	local numbers = {}

	for i = 1, 4 do
		local num = math.ceil(math.random(1, 21) * numberChance)
		numsKeyed[num] = i
		numbers[i] = num
	end

	local rewardChance = 100 - math.ceil(math.random(0, 100) * (winnerNumber / 21))
	local availableRewards = {}

	for i = 1, #blackjackRewards do
		local rewardDetails = blackjackRewards[i]

		if rewardDetails[1] >= rewardChance then
			table.insert(availableRewards, rewardDetails)
		end
	end

	table.sort(availableRewards,
		function (a, b)
			return a[1] < b[1]
		end
	)

	local prize = availableRewards[math.ceil(math.random(1, #availableRewards) * 0.375)]

	if not prize then
		prize = blackjackRewards[1]
	end

	local win = false

	for i = 1, 4 do
		if numbers[i] > winnerNumber then
			win = true
			break
		end
	end

	return toJSON({win, winnerNumber, numbers[1], numbers[2], numbers[3], numbers[4], prize[2], serial}, true)
end

local moneyManiaRewards = {
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
	10, 10, 10, 10, 10, 10, 10,
	15, 15, 15, 15, 15, 15,
	25, 25, 25, 25, 25,
	50, 50, 50, 50,
	1000, 1000, 1000,
	5000, 5000,
	10000
}

function generateMoneyMania(serial)
	local availableSymbols = {"bank", "card", "dollar"}
	local symbols = {}

	for column = 1, 3 do
		symbols[column] = {}

		for row = 1, 3 do
			symbols[column][row] = availableSymbols[math.random(1, #availableSymbols)]
		end
	end

	local prizes = {}
	local winnerColumns = {}

	for column = 1, 3 do
		prizes[column] = moneyManiaRewards[math.ceil(math.random(1, #moneyManiaRewards) * math.random())]

		if symbols[column][1] == symbols[column][2] and symbols[column][2] == symbols[column][3] then
			winnerColumns[column] = true
		end
	end

	return toJSON({symbols, prizes, winnerColumns, serial}, true)
end

local piggyRewards = {
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
	10, 10, 10, 10, 10, 10, 10,
	15, 15, 15, 15, 15, 15,
	25, 25, 25, 25, 25,
	50, 50, 50, 50,
	1000, 1000, 1000,
	5000, 5000,
	10000
}

function generateFortunePiggy(serial)
	local prizes = {}
	local counter = {}

	for column = 1, 2 do
		prizes[column] = {}

		for row = 1, 3 do
			local prize = piggyRewards[math.ceil(math.random(1, #piggyRewards) * math.random())]

			prizes[column][row] = prize

			if not counter[prize] then
				counter[prize] = 0
			end

			counter[prize] = counter[prize] + 1
		end
	end

	local reward = 0
	local highest = 0
	local luck = false

	for prize, count in pairs(counter) do
		if count >= 3 and count > highest then
			highest = count
			reward = prize
		end
	end

	if math.random() < 0.25 then
		luck = math.random(1, 3)
	end

	return toJSON({prizes, reward, luck, serial}, true)
end

local moneyLiftRewards = {
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
	10, 10, 10, 10, 10, 10, 10,
	15, 15, 15, 15, 15, 15,
	25, 25, 25, 25, 25,
	50, 50, 50, 50,
	1000, 1000, 1000,
	5000, 5000,
	10000
}

function generateMoneyLift(serial)
	local symbols = {}
	local prizes = {}

	for x = 1, 6 do
		symbols[x] = {}
		prizes[x] = moneyLiftRewards[math.ceil(math.random(1, #moneyLiftRewards) * math.random())]

		for y = 1, 5 do
			symbols[x][y] = "arrow"
		end

		if math.random() < 0.85 then
			symbols[x][math.random(1, 5)] = "stop"
		end
	end

	local counter = {}
	local reward = 0

	for x = 1, 6 do
		counter[x] = 0

		for y = 1, 5 do
			if symbols[x][y] == "arrow" then
				counter[x] = counter[x] + 1
			end
		end

		if counter[x] == 5 then
			reward = reward + prizes[x]
		end
	end

	return toJSON({symbols, prizes, reward, serial}, true)
end

function giveItem(element, itemId, amount, slotId, data1, data2, data3)
	if isElement(element) then
		local ownerType = getElementType(element)
		local ownerId = false

		if ownerType == "player" then
			ownerId = getElementData(element, defaultSettings.characterId)
		elseif ownerType == "vehicle" then
			ownerId = getElementData(element, defaultSettings.vehicleId)
		elseif ownerType == "object" then
			ownerId = getElementData(element, defaultSettings.objectId)
		end

		if ownerId then
			if not itemsTable[element] then
				itemsTable[element] = {}
			end

			if not slotId then
				slotId = findEmptySlot(element, ownerType, itemId)
			elseif tonumber(slotId) then
				if itemsTable[element][slotId] then
					slotId = findEmptySlot(element, ownerType, itemId)
				end
			end

			if tonumber(slotId) then
				local serial = false

				if serialItems[itemId] then
					serial = lastWeaponSerial + 1
					lastWeaponSerial = serial
				end

				if scratchItems[itemId] then
					lastTicketSerial = lastTicketSerial + 1

					if itemId == 293 then -- Black Jack
						data1 = generateBlackjack(lastTicketSerial)
					elseif itemId == 296 then -- Money Mania
						data1 = generateMoneyMania(lastTicketSerial)
					elseif itemId == 374 then -- Szerencsemalac
						data1 = generateFortunePiggy(lastTicketSerial)
					elseif itemId == 375 then -- Pénzlift
						data1 = generateMoneyLift(lastTicketSerial)
					end
				end

				if itemId == 361 then -- Pénzkazetta
					if isElement(sourceResource) and getResourceName(sourceResource) == "see_bank" then
						if ownerType == "player" then
							local moneyCasettes = getElementData(resourceRoot, "moneyCasettes") or {}

							moneyCasettes[element] = true

							if isTimer(trackingTimer[element]) then
								killTimer(trackingTimer[element])
							end

							trackingTimer[element] = setTimer(
								function (sourcePlayer)
									local moneyCasettes = getElementData(resourceRoot, "moneyCasettes") or {}

									if moneyCasettes[sourcePlayer] then
										moneyCasettes[sourcePlayer] = nil

										setElementData(resourceRoot, "moneyCasettes", moneyCasettes)
									end

									trackingTimer[sourcePlayer] = nil
								end,
							1000 * 60 * 8, 1, element)

							setElementData(resourceRoot, "moneyCasettes", moneyCasettes)
						end
					end
				end

				itemsTable[element][slotId] = {}
				itemsTable[element][slotId].locked = true

				dbQuery(
					function (query)
						local result, rows, dbID = dbPoll(query, 0)

						if itemsTable[element][slotId] and itemsTable[element][slotId].locked then
							itemsTable[element][slotId] = nil
						end

						if result and dbID then
							addItem(element, dbID, slotId, itemId, amount, data1, data2, data3, false, serial)

							if ownerType == "player" then
								triggerClientEvent(element, "äĐĐÍÄ<", element, ownerType, itemsTable[element][slotId])
								triggerClientEvent(element, "movedItemInInv", element)
							end
						end
					end,
				connection, "INSERT INTO items (itemId, slot, amount, data1, data2, data3, serial, ownerType, ownerId) VALUES (?,?,?,?,?,?,?,?,?)", itemId, slotId, amount, data1, data2, data3, serial, ownerType, ownerId)

				return true
			end
		end
	end

	return false
end
addEvent("äĐĐÍÄ<", true)
addEventHandler("äĐĐÍÄ<", getRootElement(), giveItem)

function takeItem(element, dataType, dataValue, amount)
	if not isElement(element) then
		return false
	end

	if not itemsTable[element] then
		return false
	end

	local ownerType = getElementType(element)
	local ownerId = false

	if ownerType == "player" then
		ownerId = getElementData(element, defaultSettings.characterId)
	elseif ownerType == "vehicle" then
		ownerId = getElementData(element, defaultSettings.vehicleId)
	elseif ownerType == "object" then
		ownerId = getElementData(element, defaultSettings.objectId)
	end

	if not ownerId then
		return false
	end

	local deleted = {}

	for k, v in pairs(itemsTable[element]) do
		if v[dataType] and v[dataType] == dataValue then
			-- item mennyiség módosítás
			if amount and v.amount - amount > 0 then
				v.amount = v.amount - amount

				if ownerType == "player" then
					triggerClientEvent(element, "updateAmount", element, ownerType, v.dbID, v.amount)
				end

				dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", v.amount, v.dbID)
			-- item törlés
			else
				table.insert(deleted, v.dbID)
				itemsTable[element][v.slot] = nil
			end
		end
	end

	if #deleted > 0 then
		if ownerType == "player" then
			triggerClientEvent(element, "deleteItem", element, ownerType, deleted)
			triggerClientEvent(element, "movedItemInInv", element)
		end

		dbExec(connection, "DELETE FROM items WHERE dbID IN (" .. table.concat(deleted, ",") .. ")")
	end
end
addEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", true)
addEventHandler("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", getRootElement(), takeItem)

function clearItems(element)
	if isElement(element) then
		local ownerType = getElementType(element)
		local ownerId = false

		if ownerType == "player" then
			ownerId = tonumber(getElementData(element, defaultSettings.characterId))
		elseif ownerType == "vehicle" then
			ownerId = tonumber(getElementData(element, defaultSettings.vehicleId))
		elseif ownerType == "object" then
			ownerId = tonumber(getElementData(element, defaultSettings.objectId))
		end

		itemsTable[element] = nil

		if isElement(inventoryInUse[element]) then
			triggerClientEvent(inventoryInUse[element], "loadItems", inventoryInUse[element], {}, ownerType, element, true)
		end

		dbExec(connection, "DELETE FROM items WHERE ownerType = ? AND ownerId = ?", ownerType, ownerId)
	end
end

function takeItemWithData(element, itemId, dataValue, dataType)
	if isElement(element) then
		if itemsTable[element] then
			itemId = tonumber(itemId)
			dataType = dataType or "data1"

			if itemId and dataValue and dataType then
				local ownerType = getElementType(element)
				local ownerId = false

				if ownerType == "player" then
					ownerId = tonumber(getElementData(element, defaultSettings.characterId))
				elseif ownerType == "vehicle" then
					ownerId = tonumber(getElementData(element, defaultSettings.vehicleId))
				elseif ownerType == "object" then
					ownerId = tonumber(getElementData(element, defaultSettings.objectId))
				end

				if ownerId then
					local deleted = {}

					for k, v in pairs(itemsTable[element]) do
						if v[dataType] and v[dataType] == dataValue then
							table.insert(deleted, v.dbID)
							itemsTable[element][v.slot] = nil
						end
					end

					if #deleted > 0 then
						if ownerType == "player" then
							triggerClientEvent(element, "deleteItem", element, ownerType, deleted)
							triggerClientEvent(element, "movedItemInInv", element)
						end

						dbExec(connection, "DELETE FROM items WHERE dbID IN (" .. table.concat(deleted, ",") .. ")")
					end
				end
			end
		end
	end
end

function getElementItems(element)
	if isElement(element) then
		if itemsTable[element] then
			return itemsTable[element]
		end
	end

	return {}
end

addEvent("takeAmountFrom", true)
addEventHandler("takeAmountFrom", getRootElement(),
	function (itemId, amount)
		if isElement(source) and itemsTable[source] then
			local ownerType = getElementType(source)
			local ownerId = false

			if ownerType == "player" then
				ownerId = getElementData(source, defaultSettings.characterId)
			elseif ownerType == "vehicle" then
				ownerId = getElementData(source, defaultSettings.vehicleId)
			elseif ownerType == "object" then
				ownerId = getElementData(source, defaultSettings.objectId)
			end

			if ownerId then
				local slot = getItemSlotID(source, itemId)

				if slot then
					local newAmount = itemsTable[source][slot].amount - amount

					itemsTable[source][slot].amount = newAmount

					dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", newAmount, itemsTable[source][slot].dbID)
				end
			end
		end
	end)

function addItem(element, dbID, slotId, itemId, amount, data1, data2, data3, nameTag, serial)
	if dbID and slotId and itemId and amount then
		itemsTable[element][slotId] = {}
		itemsTable[element][slotId].dbID = dbID
		itemsTable[element][slotId].slot = slotId
		itemsTable[element][slotId].itemId = itemId
		itemsTable[element][slotId].amount = amount
		itemsTable[element][slotId].data1 = data1
		itemsTable[element][slotId].data2 = data2
		itemsTable[element][slotId].data3 = data3
		itemsTable[element][slotId].inUse = false
		itemsTable[element][slotId].locked = false
		itemsTable[element][slotId].nameTag = nameTag
		itemsTable[element][slotId].serial = serial
	end
end

function hasItemWithData(element, itemId, data, dataType)
	if itemsTable[element] then
		data = tonumber(data) or data
		dataType = dataType or "data1"

		for k, v in pairs(itemsTable[element]) do
			if v.itemId == itemId and (tonumber(v[dataType]) or v[dataType]) == data then
				return v
			end
		end
	end

	return false
end

function hasItem(element, itemId, amount)
	if itemsTable[element] then
		amount = tonumber(amount) or 1

		for k, v in pairs(itemsTable[element]) do
			if v.itemId == itemId and (not amount or v.amount == amount) then
				return v
			end
		end
	end

	return false
end

function getItemSlotID(element, itemDbID)
	if itemsTable[element] then
		for k, v in pairs(itemsTable[element]) do
			if v.dbID == itemDbID then
				return v.slot
			end
		end
	end

	return false
end

function getItemsCount(element)
	local items = 0

	if itemsTable[element] then
		for k, v in pairs(itemsTable[element]) do
			items = items + 1
		end
	end

	return items
end

function getCurrentWeight(element)
	local weight = 0

	if itemsTable[element] then
		for k, v in pairs(itemsTable[element]) do
			weight = weight + getItemWeight(v.itemId) * v.amount
		end
	end

	return weight
end

function getFreeSlotCount(element, itemId)
	if itemsTable[element] then
		local elementType = getElementType(element)
		local emptyslot = 0

		if elementType == "player" and itemId then
			if isKeyItem(itemId) then
				for i = defaultSettings.slotLimit, defaultSettings.slotLimit * 2 - 1 do
					if not itemsTable[element][i] then
						emptyslot = emptyslot + 1
					end
				end
			elseif isPaperItem(itemId) then
				for i = defaultSettings.slotLimit * 2, defaultSettings.slotLimit * 3 - 1 do
					if not itemsTable[element][i] then
						emptyslot = emptyslot + 1
					end
				end
			else
				for i = 0, defaultSettings.slotLimit - 1 do
					if not itemsTable[element][i] then
						emptyslot = emptyslot + 1
					end
				end
			end
		else
			for i = 0, defaultSettings.slotLimit - 1 do
				if not itemsTable[element][i] then
					emptyslot = emptyslot + 1
				end
			end
		end

		return emptyslot
	end

	return 0
end

addEvent("moveItem", true)
addEventHandler("moveItem", getRootElement(),
	function (dbID, itemId, movedSlotId, hoverSlotId, stackAmount, ownerElement, targetElement)
		if not isElement(source) or not isElement(ownerElement) or not isElement(targetElement) then
			return
		end

		dbID = tonumber(dbID)

		if not dbID then
			return
		end

		local ownerType = getElementType(ownerElement)
		local ownerId = false

		if ownerType == "player" then
			ownerId = getElementData(ownerElement, defaultSettings.characterId)
		elseif ownerType == "vehicle" then
			ownerId = getElementData(ownerElement, defaultSettings.vehicleId)
		elseif ownerType == "object" then
			ownerId = getElementData(ownerElement, defaultSettings.objectId)
		end

		if ownerElement == targetElement then
			local movedItem = itemsTable[ownerElement][movedSlotId]

			if not movedItem or dbID ~= movedItem.dbID then
				return
			end

			if itemsTable[ownerElement][hoverSlotId] then
				if itemsTable[ownerElement][hoverSlotId].locked then
					outputChatBox("#DC143C[SeeMTA - Inventory]: #FFFFFFEz a slot zárolva van! Kérlek várj egy kicsit.", source, 255, 255, 255, true)
				else
					outputChatBox("#DC143C[SeeMTA - Inventory]: #FFFFFFA kiválasztott slot foglalt.", source, 255, 255, 255, true)
				end

				triggerClientEvent(source, "failedToMoveItem", source, movedSlotId, hoverSlotId, stackAmount)
				return
			end

			-- mozgatás
			if stackAmount >= movedItem.amount or stackAmount <= 0 then
				if ownerElement == source and targetElement == source then
					triggerClientEvent(source, "movedItemInInv", source, true)
				end

				itemsTable[ownerElement][hoverSlotId] = itemsTable[ownerElement][movedSlotId]
				itemsTable[ownerElement][hoverSlotId].slot = hoverSlotId
				itemsTable[ownerElement][movedSlotId] = nil

				dbExec(connection, "UPDATE items SET ownerType = ?, ownerId = ?, slot = ? WHERE dbID = ?", ownerType, ownerId, hoverSlotId, dbID)
			-- stackelés
			elseif stackAmount > 0 then
				movedItem.amount = movedItem.amount - stackAmount

				giveItem(ownerElement, itemId, stackAmount, hoverSlotId, movedItem.data1, movedItem.data2, movedItem.data3)

				dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", movedItem.amount, dbID)
			end

			return
		end

		-- átmozgatás egy másik inventoryba
		local targetType = getElementType(targetElement)
		local targetId = false

		if targetType == "player" then
			targetId = getElementData(targetElement, defaultSettings.characterId)
		elseif targetType == "vehicle" then
			targetId = getElementData(targetElement, defaultSettings.vehicleId)
		elseif targetType == "object" then
			targetId = getElementData(targetElement, defaultSettings.objectId)
		end

		if targetType == "vehicle" then
			if isVehicleLocked(targetElement) then
				outputChatBox("#DC143C[SeeMTA - Inventory]: #FFFFFFA kiválasztott jármű csomagtartója zárva van.", source, 255, 255, 255, true)
				triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
				return
			end
		end

		local movedItem = itemsTable[ownerElement][movedSlotId]

		if not movedItem or dbID ~= movedItem.dbID then
			triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
			return
		end

		if isElement(inventoryInUse[targetElement]) then
			outputChatBox("#DC143C[SeeMTA - Inventory]: #FFFFFFNem rakhatsz tárgyat az inventoryba amíg azt valaki más használja!", source, 255, 255, 255, true)
			triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
			return
		end

		if targetType == "object" then
			if storedSafes[targetId] then
				if storedSafes[targetId].ownerGroup > 0 then
					if not exports.see_groups:isPlayerInGroup(source, storedSafes[targetId].ownerGroup) then
						outputChatBox("#DC143C[SeeMTA - Inventory]: #FFFFFFA kiválasztott széfhez nincs kulcsod.", source, 255, 255, 255, true)
						triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
						return
					end
				elseif not hasItemWithData(source, 154, targetId) then
					outputChatBox("#DC143C[SeeMTA - Inventory]: #FFFFFFA kiválasztott széfhez nincs kulcsod.", source, 255, 255, 255, true)
					triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
					return
				end
			end
		end

		if targetType ~= "player" then
			if itemId == 361 then -- Pénzkazetta
				outputChatBox("#DC143C[SeeMTA - Inventory]: #FFFFFFEzt az itemet csak más játékosnak adhatod át!", source, 255, 255, 255, true)
				triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
				return
			end
		end

		if not itemsTable[targetElement] then
			itemsTable[targetElement] = {}
		end

		hoverSlotId = findEmptySlot(targetElement, targetType, itemId)

		if not hoverSlotId then
			outputChatBox("#DC143C[SeeMTA - Inventory]: #FFFFFFNincs szabad slot a kiválasztott inventoryban!", source, 255, 255, 255, true)
			triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
			return
		end

		local statement = false

		if stackAmount >= movedItem.amount or stackAmount <= 0 then
			statement = "move"
			stackAmount = movedItem.amount
		elseif stackAmount > 0 then
			statement = "stack"
		end

		if getCurrentWeight(targetElement) + getItemWeight(itemId) * stackAmount > getWeightLimit(targetType, targetElement) then
			outputChatBox("#DC143C[SeeMTA - Inventory]: #FFFFFFA kiválasztott inventory nem bírja el ezt a tárgyat!", source, 255, 255, 255, true)
			triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
			return
		end

		if statement == "move" then
			itemsTable[targetElement][hoverSlotId] = itemsTable[ownerElement][movedSlotId]
			itemsTable[targetElement][hoverSlotId].slot = hoverSlotId
			itemsTable[ownerElement][movedSlotId] = nil

			triggerItemEvent(targetElement, "äĐĐÍÄ<", targetType, itemsTable[targetElement][hoverSlotId])
			triggerItemEvent(ownerElement, "deleteItem", ownerType, {dbID})

			dbExec(connection, "UPDATE items SET ownerType = ?, ownerId = ?, slot = ? WHERE dbID = ?", targetType, targetId, hoverSlotId, dbID)
		end

		if statement == "stack" then
			movedItem.amount = movedItem.amount - stackAmount

			giveItem(targetElement, itemId, stackAmount, hoverSlotId, movedItem.data1, movedItem.data2, movedItem.data3)
			triggerItemEvent(ownerElement, "updateAmount", ownerType, dbID, movedItem.amount)

			dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", movedItem.amount, dbID)
		end

		triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)

		exports.see_logs:logCommand(source, eventName, {dbID, itemId, stackAmount, ownerType, ownerId, targetType, targetId})

		local itemName = ""

		if availableItems[itemId] then
			itemName = getItemName(itemId)

			if itemsTable[targetElement][hoverSlotId].nameTag then
				itemName = " (" .. itemName .. " (" .. itemsTable[targetElement][hoverSlotId].nameTag .. "))"
			else
				itemName = " (" .. itemName .. ")"
			end
		end

		if ownerType == "player" and targetType == "player" then
			exports.see_chat:localAction(ownerElement, "átadott egy tárgyat " .. getElementData(targetElement, "visibleName"):gsub("_", " ") .. "-nak/nek." .. itemName)

			setPedAnimation(ownerElement, "DEALER", "DEALER_DEAL", -1, false, false, false, false)
			setPedAnimation(targetElement, "DEALER", "DEALER_DEAL", -1, false, false, false, false)

			return
		end

		if ownerType == "player" then
			if targetType == "vehicle" then
				exports.see_chat:localAction(ownerElement, "berakott egy tárgyat a jármű csomagtartójába." .. itemName)
			end

			if targetType == "object" then
				exports.see_chat:localAction(ownerElement, "berakott egy tárgyat a széfbe." .. itemName)
			end

			return
		end

		if ownerType == "vehicle" then
			exports.see_chat:localAction(targetElement, "kivett egy tárgyat a jármű csomagtartójából." .. itemName)
			return
		end

		if ownerType == "object" then
			exports.see_chat:localAction(targetElement, "kivett egy tárgyat a széfből." .. itemName)
			return
		end
	end)

addEvent("stackItem", true)
addEventHandler("stackItem", getRootElement(),
	function (ownerElement, movedItemId, hoverItemId, stackAmount)
		if isElement(source) then
			if itemsTable[ownerElement] then
				local ownerType = getElementType(source)

				for k, v in pairs(itemsTable[ownerElement]) do
					if v.dbID == hoverItemId then
						v.amount = v.amount + stackAmount

						triggerItemEvent(source, "updateAmount", ownerType, v.dbID, v.amount)

						dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", v.amount, v.dbID)
					end

					if v.dbID == movedItemId then
						if v.amount - stackAmount > 0 then
							v.amount = v.amount - stackAmount

							triggerItemEvent(source, "updateAmount", ownerType, v.dbID, v.amount)

							dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", v.amount, v.dbID)
						else
							triggerItemEvent(source, "deleteItem", ownerType, {v.dbID})

							dbExec(connection, "DELETE FROM items WHERE dbID = ?", v.dbID)

							itemsTable[ownerElement][v.slot] = nil
						end
					end
				end
			end
		end
	end)

function triggerItemEvent(element, event, ...)
	local sourcePlayer = element

	if getElementType(element) == "player" then
		triggerClientEvent(element, event, element, ...)
	else
		if isElement(inventoryInUse[element]) then
			triggerClientEvent(inventoryInUse[element], event, inventoryInUse[element], ...)
			sourcePlayer = inventoryInUse[element]
		end
	end

	if event == "äĐĐÍÄ<" or event == "deleteItem" or event == "updateAmount" then
		if isElement(sourcePlayer) and getElementType(element) == "player" then
			triggerClientEvent(sourcePlayer, "movedItemInInv", sourcePlayer, event == "updateAmount")
		end
	end
end

function hasSpaceForItem(element, itemId, amount)
	if itemsTable[element] then
		local elementType = getElementType(element)
		local emptyslot = 0

		amount = amount or 1

		if elementType == "player" and isKeyItem(itemId) then
			for i = defaultSettings.slotLimit, defaultSettings.slotLimit * 2 - 1 do
				if not itemsTable[element][i] then
					emptyslot = emptyslot + 1
				end
			end
		elseif elementType == "player" and isPaperItem(itemId) then
			for i = defaultSettings.slotLimit * 2, defaultSettings.slotLimit * 3 - 1 do
				if not itemsTable[element][i] then
					emptyslot = emptyslot + 1
				end
			end
		else
			for i = 0, defaultSettings.slotLimit - 1 do
				if not itemsTable[element][i] then
					emptyslot = emptyslot + 1
				end
			end
		end

		if emptyslot >= 1 then
			if getCurrentWeight(element) + getItemWeight(itemId) * amount <= getWeightLimit(elementType, element) then
				return true
			end

			return false, "weight"
		end

		return false, "slot"
	end

	return false
end

function findEmptySlot(element, ownerType, itemId)
	if itemsTable[element] then
		if ownerType == "player" then
			if isKeyItem(itemId) then
				return findEmptySlotOfKeys(element)
			elseif isPaperItem(itemId) then
				return findEmptySlotOfPapers(element)
			end
		end

		local slotId = false

		for i = 0, defaultSettings.slotLimit - 1 do
			if not itemsTable[element][i] then
				slotId = tonumber(i)
				break
			end
		end

		if slotId then
			if slotId <= defaultSettings.slotLimit then
				return tonumber(slotId)
			end
		end

		return false
	end

	return false
end

function findEmptySlotOfKeys(player)
	if itemsTable[player] then
		local slotId = false

		for i = defaultSettings.slotLimit, defaultSettings.slotLimit * 2 - 1 do
			if not itemsTable[player][i] then
				slotId = tonumber(i)
				break
			end
		end

		if slotId then
			if slotId <= defaultSettings.slotLimit * 2 then
				return tonumber(slotId)
			else
				return false
			end
		else
			return false
		end
	end

	return false
end

function findEmptySlotOfPapers(player)
	if itemsTable[player] then
		local slotId = false

		for i = defaultSettings.slotLimit * 2, defaultSettings.slotLimit * 3 - 1 do
			if not itemsTable[player][i] then
				slotId = tonumber(i)
				break
			end
		end

		if slotId then
			if slotId <= defaultSettings.slotLimit * 3 then
				return tonumber(slotId)
			else
				return false
			end
		else
			return false
		end
	end

	return false
end

addEvent("closeInventory", true)
addEventHandler("closeInventory", getRootElement(),
	function (element, nearby)
		if isElement(element) then
			inventoryInUse[element] = nil

			if getElementType(element) == "vehicle" and getVehicleType(element) == "Automobile" then
				setVehicleDoorOpenRatio(element, 1, 0, 250)
				setTimer(triggerLatentClientEvent, 250, 1, nearby, "toggleVehicleTrunk", source, "close", element)
			end
		end
	end)

addEvent("requestItems", true)
addEventHandler("requestItems", getRootElement(),
	function (element, ownerId, ownerType, nearbyPlayers)
		if isElement(element) then
			if ownerId and ownerType then
				local canOpenInv = true

				if ownerType == "vehicle" then
					if isVehicleLocked(element) then
						canOpenInv = false
					end
				elseif ownerType == "object" then
					if storedSafes[ownerId] then
						if storedSafes[ownerId].ownerGroup > 0 then
							if not exports.see_groups:isPlayerInGroup(source, storedSafes[ownerId].ownerGroup) then
								canOpenInv = false
							end
						elseif not hasItemWithData(source, 154, ownerId) then
							canOpenInv = false
						end
					end
				end

				if not canOpenInv then
					outputChatBox("#DC143C[SeeMTA - Inventory]: #FFFFFFA kiválasztott inventory zárva van, esetleg nincs kulcsod hozzá.", source, 255, 255, 255, true)
					return
				end

				if isElement(inventoryInUse[element]) then
					outputChatBox("#DC143C[SeeMTA - Inventory]: #FFFFFFA kiválasztott inventory már használatban van!", source, 255, 255, 255, true)
					return
				end

				inventoryInUse[element] = source
				loadItems(element)

				if ownerType == "vehicle" then
					exports.see_chat:localAction(source, "belenézett a csomagtartóba.")

					if getVehicleType(element) == "Automobile" then
						setVehicleDoorOpenRatio(element, 1, 1, 500)
						triggerLatentClientEvent(nearbyPlayers, "toggleVehicleTrunk", source, "open", element)
					end
				elseif ownerType == "object" then
					exports.see_chat:localAction(source, "belenézett a széfbe.")
				end
			end
		end
	end)

addEvent("requestCache", true)
addEventHandler("requestCache", getRootElement(),
	function ()
		if isElement(source) then
			local characterId = getElementData(source, defaultSettings.characterId)

			if characterId then
				loadItems(source)
			end
		end
	end)

function loadItems(element)
	if isElement(element) then
		local ownerType = getElementType(element)
		local ownerId = false

		if ownerType == "player" then
			ownerId = tonumber(getElementData(element, defaultSettings.characterId))
		elseif ownerType == "vehicle" then
			ownerId = tonumber(getElementData(element, defaultSettings.vehicleId))
		elseif ownerType == "object" then
			ownerId = tonumber(getElementData(element, defaultSettings.objectId))
		end

		if ownerId then
			itemsTable[element] = {}

			return dbQuery(
				function (query)
					local result = dbPoll(query, 0)

					if result then
						local lost, restored = 0, 0

						for k, v in pairs(result) do
							local slotId = false

							if itemsTable[element][v.slot] then
								slotId = findEmptySlot(element, ownerType, v.itemId)

								if slotId then
									dbExec(connection, "UPDATE items SET slot = ? WHERE dbID = ?", slotId, v.dbID)
									restored = restored + 1
								end

								lost = lost + 1
							else
								slotId = v.slot
							end

							addItem(element, v.dbID, slotId, v.itemId, v.amount, v.data1, v.data2, v.data3, v.nameTag, v.serial)
						end

						if lost > 0 and ownerType == "player" then
							outputChatBox("#dc143c[SeeMTA - Inventory]: #4aabd0" .. lost .. " #ffffffdarab elveszett tárggyal rendelkezel.", element, 255, 255, 255, true)

							if restored > 0 then
								outputChatBox("#dc143c[SeeMTA - Inventory]: #ffffffEbből #4aabd0" .. restored .. " #ffffffdarab lett visszaállítva.", element, 255, 255, 255, true)
							end

							if lost - restored > 0 then
								outputChatBox("#dc143c[SeeMTA - Inventory]: #ffffffNem sikerült visszaállítani #4aabd0" .. lost - restored .. " #ffffffdarab tárgyad, mert nincs szabad slot az inventorydban.", element, 255, 255, 255, true)
								outputChatBox("#dc143c[SeeMTA - Inventory]: #ffffffkövetkező bejelentkezésedkor ismét megpróbáljuk.", element, 255, 255, 255, true)
							end

							if lost == restored then
								outputChatBox("#dc143c[SeeMTA - Inventory]: #ffffffAz összes hibás tárgyadat sikeresen visszaállítottuk. Kellemes játékot kívánunk! :).", element, 255, 255, 255, true)
							end
						end
					end

					if ownerType == "player" then
						triggerClientEvent(element, "loadItems", element, itemsTable[element], "player")
					else
						if isElement(inventoryInUse[element]) then
							triggerClientEvent(inventoryInUse[element], "loadItems", inventoryInUse[element], itemsTable[element], ownerType, element, true)
						end
					end
				end,
			connection, "SELECT * FROM items WHERE ownerType = ? AND ownerId = ?", ownerType, ownerId)
		end

		return false
	end

	return false
end
