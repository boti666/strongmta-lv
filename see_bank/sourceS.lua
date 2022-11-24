local connection = false
local atmDataTable = {}
local payTimers = {}

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end
)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()

		if connection then
			dbQuery(loadATMs, connection, "SELECT * FROM atms")
		end

		--setTimer(resetRobbedATMs, 1, 0)
		resetRobbedATMs()
		--print("HASDAKJDJKLAHSD")

		--setTimer(resetRobbedATMs, 1000 * 60 * 15, 0)
		setTimer(
			function ()
				triggerClientEvent("clearBlips", getRootElement())
				resetRobbedATMs()
			end, 
		1000 * 60 * 15, 0)
	end
)


addEventHandler("onPlayerQuit", getRootElement(),
	function()
		if isTimer(payTimers[source]) then
			killTimer(payTimers[source])
		end

		payTimers[source] = nil

		--if tradeContractDatas[source] then
		--	if isElement(tradeContractDatas[source]["theSeller"]) then
		--		triggerClientEvent(tradeContractDatas[source]["theSeller"], "failedToSell", tradeContractDatas[source]["theSeller"])
		--	end
		--
		--	tradeContractDatas[source] = nil
		--end
	end)

function payTheMoney(sourcePlayer, targetPlayer, amount)
	if isElement(sourcePlayer) and isElement(targetPlayer) then
		local playerName = getElementData(sourcePlayer, "visibleName"):gsub("_", " ")
		local targetName = getElementData(targetPlayer, "visibleName"):gsub("_", " ")

		exports.see_chat:localAction(sourcePlayer, "átad egy kis pénzt neki: " .. targetName)

		exports.see_core:takeMoney(sourcePlayer, amount, "pay")

		exports.see_core:giveMoney(targetPlayer, amount, "pay")

		local moneyTax = amount * 2

		outputChatBox("#3d7abc[StrongMTA]: #FFFFFF Adtál #32b3ef" .. targetName .. "#FFFFFF-nak/nek #7cc576" .. amount .. " #FFFFFFdollárt.", sourcePlayer, 0, 0, 0, true)
		outputChatBox("#3d7abc[StrongMTA]: #32b3ef" .. playerName .. "#FFFFFF adott neked #7cc576" .. amount .. " #FFFFFFdollárt.", targetPlayer, 0, 0, 0, true)
	end

	payTimers[sourcePlayer] = nil
end

addCommandHandler("pay",
	function(sourcePlayer, cmd, targetPlayer, amount)
		amount = tonumber(amount)

		if not (targetPlayer and amount) then
			outputChatBox("#3d7abc[Használat]: #FFFFFF/" .. cmd .. " [Név / ID] [Összeg]", sourcePlayer, 0, 0, 0, true)
		else
			targetPlayer = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				if targetPlayer~=sourcePlayer then
					local px, py, pz = getElementPosition(sourcePlayer)
					local tx, ty, tz = getElementPosition(targetPlayer)

					local pi = getElementInterior(sourcePlayer)
					local ti = getElementInterior(targetPlayer)

					local pd = getElementDimension(sourcePlayer)
					local td = getElementDimension(targetPlayer)

					local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)
					if getElementData(sourcePlayer, "disallowPay") == true then 
						return outputChatBox("#D75959[StrongMTA]: #FFFFFFATM kezelése közben mégis hogyan akarsz átadni pénzt?!", sourcePlayer, 255, 255, 255, true)
					end
					if dist <= 5 and pi == ti and pd == td then
						amount = math.ceil(amount)

						if amount > 0 then
							local currentMoney = getElementData(sourcePlayer, "char.Money") or 0

							if currentMoney - amount >= 0 then
								if not payTimers[sourcePlayer] then
									payTimers[sourcePlayer] = setTimer(payTheMoney, 5000, 1, sourcePlayer, targetPlayer, amount)

									outputChatBox("#D75959[StrongMTA]: #FFFFFFA pénz átadása maximum 5 másodpercen belül elindul.", sourcePlayer, 255, 255, 255, true)
								else
									outputChatBox("#D75959[StrongMTA]: #FFFFFFMég az előző pénzt sem adtad át, hova ilyen gyorsan?!", sourcePlayer, 255, 255, 255, true)
								end
							else
								outputChatBox("#D75959[StrongMTA]: #FFFFFFNincs nálad ennyi pénz!", sourcePlayer, 255, 255, 255, true)
							end
						else
							outputChatBox("#D75959[StrongMTA]: #FFFFFFMaradjunk a nullánál nagyobb egész számoknál.", sourcePlayer, 255, 255, 255, true)
						end
					else
						outputChatBox("#D75959[StrongMTA]: #FFFFFFA kiválasztott játékos túl messze van tőled.", sourcePlayer, 255, 255, 255, true)
					end
				else
					outputChatBox("#D75959[StrongMTA]: #FFFFFFMagadnak nem tudsz pénzt adni!", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end 
)

addCommandHandler("deleteatm",
	function (sourcePlayer, commandName, databaseId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			databaseId = tonumber(databaseId)

			if not databaseId then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [ID]", sourcePlayer, 255, 255, 255, true)
			else
				local objectElement = false

				for k in pairs(atmDataTable) do
					local bankId = getElementData(k, "bankId")

					if bankId and databaseId == bankId then
						objectElement = k
						break
					end
				end

				if isElement(objectElement) then
					outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen törölted a kiválasztott ATM-et. #32b3ef(" .. databaseId .. ")", sourcePlayer, 255, 255, 255, true)

					if isElement(atmDataTable[objectElement]["colShapeElement"]) then
						destroyElement(atmDataTable[objectElement]["colShapeElement"])
					end

					destroyElement(objectElement)
					atmDataTable[objectElement] = nil

					dbExec(connection, "DELETE FROM atms WHERE dbID = ?", databaseId)
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott ATM nem létezik.", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("placeATM", true)
addEventHandler("placeATM", getRootElement(),
	function (positionsTable)
		if isElement(source) and client and client == source then
			if getElementData(source, "acc.adminLevel") >= 6 then 
				if positionsTable then
					dbExec(connection, "INSERT INTO atms (posX, posY, posZ, rotZ, interior, dimension) VALUES (?,?,?,?,?,?)", unpack(positionsTable))
					dbQuery(placeATMCallback, {source}, connection, "SELECT * FROM atms WHERE dbID = LAST_INSERT_ID()")
				end
			end
		end
	end
)

function placeATMCallback(queryHandle, sourcePlayer)
	local resultRows, numAffectedRows, lastInsertId = dbPoll(queryHandle, 0)

	if resultRows then
		local resultRow = resultRows[1]

		if resultRow then
			createATM(resultRow.dbID, resultRow, true)

			if isElement(sourcePlayer) then
				local currentX, currentY, currentZ = getElementPosition(sourcePlayer)

				setElementPosition(sourcePlayer, currentX, currentY, currentZ + 0.5)

				exports.see_accounts:showInfo(sourcePlayer, "s", "ATM sikeresen létrehozva! ID: " .. resultRow.dbID)
			end
		end
	end
end

function loadATMs(queryHandle)
	local resultRows, numAffectedRows, lastInsertId = dbPoll(queryHandle, 0)

	if resultRows then
		for k, v in pairs(resultRows) do
			createATM(v.dbID, v)
		end
	end
end

function createATM(dbID, data)
	if dbID and data then
		local objectElement = createObject(2942, data.posX, data.posY, data.posZ, 0, 0, data.rotZ)

		if isElement(objectElement) then
			setElementFrozen(objectElement, true)
			setElementInterior(objectElement, data.interior)
			setElementDimension(objectElement, data.dimension)
			setElementData(objectElement, "bankId", dbID)
		end

		local colShapeElement = createColSphere(data.posX, data.posY, data.posZ + 0.35, 1.25)

		if isElement(colShapeElement) then
			setElementInterior(colShapeElement, data.interior)
			setElementDimension(colShapeElement, data.dimension)
			setElementData(colShapeElement, "atmRobID", dbID)
			setElementData(colShapeElement, "atmRobObject", objectElement)
		end

		atmDataTable[objectElement] = {}
		atmDataTable[objectElement]["colShapeElement"] = colShapeElement
		atmDataTable[objectElement]["robProgress"] = false
		atmDataTable[objectElement]["compartments"] = {}

		return true
	end

	return false
end

function resetRobbedATMs()
	--print("run?")
	for k in pairs(atmDataTable) do
		--iprint(atmDataTable)
		if getElementModel(k) == 2943 then
			setElementModel(k, 2942)

			atmDataTable[k]["robProgress"] = false
			atmDataTable[k]["compartments"] = {}

			setElementData(k, "isRobbed", false)
			triggerClientEvent(root, "removeRobbedBlips")
			--print("run?")
		end
	end
end


addEvent("startATMGrinding", true)
addEventHandler("startATMGrinding", getRootElement(),
	function (playersTable, grindingState, objectElement, grindingProgress)
		if isElement(source) and client and client == source then
			if atmDataTable[objectElement] then
				local currentProgress = atmDataTable[objectElement]["robProgress"]

				setElementData(objectElement, "isRobbed", true)

				if grindingState then
					setPedAnimation(source, "SWORD", "sword_IDLE")
				else
					currentProgress = grindingProgress
					atmDataTable[objectElement]["robProgress"] = currentProgress

					if grindingProgress <= 0 then
						setElementModel(objectElement, 2943)
					end
				end

				triggerClientEvent(playersTable, "syncSpark", source, grindingState, objectElement, currentProgress)
			end
		end
	end
)

addEvent("requestATMCompartments", true)
addEventHandler("requestATMCompartments", getRootElement(),
	function (objectElement)
		if isElement(source) and client and client == source then
			if atmDataTable[objectElement] then
				triggerClientEvent(source, "showRobGui", source, atmDataTable[objectElement]["compartments"])
			end
		end
	end
)

addEvent("openATMCompartment", true)
addEventHandler("openATMCompartment", getRootElement(),
	function (playersTable, objectElement, compartmentId)
		if isElement(source) and client and client == source then
			if atmDataTable[objectElement] then
				if exports.see_items:hasSpaceForItem(source, 361, 1) then
					triggerClientEvent(playersTable, "atmCompartmentSound", source, objectElement, compartmentId)

					exports.see_items:giveItem(source, 361, 1)
					atmDataTable[objectElement]["compartments"][compartmentId] = true

					setPedAnimation(source, "BOMBER", "BOM_Plant_Loop", -1, true, false, false)
					setTimer(setPedAnimation, 2000, 1, source, false)
				else
					exports.see_accounts:showInfo(source, "e", "Nem fér el nálad a tárgy!")
				end
			end
		end
	end
)

function formatNumber(amount, stepper)
	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end

addEvent("ĐÄđÍ<}Ä>~~~~ˇ^", true)
addEventHandler("ĐÄđÍ<}Ä>~~~~ˇ^", getRootElement(),
	function (amount)
		if isElement(source) and client and client == source then
			if amount then
				amount = tonumber(amount)

				if amount then
					amount = math.floor(amount)

					if amount then
						local chargeAmount = math.floor(amount * 0.01)
						local currentBalance = getElementData(source, "char.bankMoney") or 0
						local newBalance = currentBalance + amount - chargeAmount

						if exports.see_core:takeMoneyEx(source, amount) then
							setElementData(source, "char.bankMoney", newBalance)

							outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen befizettél #3d7abc" .. formatNumber(amount) .. " $-t #ffffffa számládra.", source, 255, 255, 255, true)
							outputChatBox("Új egyenleged: #3d7abc" .. formatNumber(newBalance) .. " $", source, 255, 255, 255, true)
							outputChatBox("Kezelési költség: #3d7abc" .. formatNumber(chargeAmount) .. " $", source, 255, 255, 255, true)

							exports.see_accounts:showInfo(source, "s", "Sikeres tranzakció! Részletek a chatboxban!")

							setElementData(source, "severStatusBankSendMoney", false)
						end
					end
				end
			end
		end
	end
)

addEvent("withdrawMoney", true)
addEventHandler("withdrawMoney", getRootElement(),
	function (amount)
		if isElement(source) and client and client == source then
			if amount then
				amount = tonumber(amount)

				if amount then
					amount = math.floor(amount)

					if amount then
						local chargeAmount = math.floor(amount * 0.01)
						local currentBalance = getElementData(source, "char.bankMoney") or 0
						local newBalance = currentBalance - amount

						if exports.see_core:giveMoney(source, amount - chargeAmount) then
							setElementData(source, "char.bankMoney", newBalance)

							outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen kivettél #3d7abc" .. formatNumber(amount) .. " $-t #ffffffa számládról.", source, 255, 255, 255, true)
							outputChatBox("Új egyenleged: #3d7abc" .. formatNumber(newBalance) .. " $", source, 255, 255, 255, true)
							outputChatBox("Kezelési költség: #3d7abc" .. formatNumber(chargeAmount) .. " $", source, 255, 255, 255, true)

							exports.see_accounts:showInfo(source, "s", "Sikeres tranzakció! Részletek a chatboxban!")

							setElementData(source, "severStatusBankSendMoney", false)
						end
					end
				end
			end
		end
	end
)
