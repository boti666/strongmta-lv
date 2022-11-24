local connection = false

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()

		if connection then
			dbQuery(loadAllGroup, connection, "SELECT * FROM groups")
		end
	end)

function loadAllGroup(qh)
	local resultTable = dbPoll(qh, 0)

	if resultTable then
		for k, v in pairs(resultTable) do
			local id = v.groupId

			if availableGroups[id] then
				availableGroups[id].balance = tonumber(v.balance) or 0
				availableGroups[id].description = v.description

				if not availableGroups[id].ranks then
					availableGroups[id].ranks = {}
				end

				local ranksTable = split(v.ranks, ",")
				local rankPaysTable = split(v.ranks_pay, ",")

				for i = 1, #ranksTable do
					if not availableGroups[id].ranks[i] then
						availableGroups[id].ranks[i] = {}
					end

					availableGroups[id].ranks[i].name = ranksTable[i] or "rang " .. i
					availableGroups[id].ranks[i].pay = tonumber(rankPaysTable[i]) or 0
				end

				if not availableGroups[id].permissions then
					availableGroups[id].permissions = {}
				end

				if not availableGroups[id].duty then
					availableGroups[id].duty = {}
				end

				if not availableGroups[id].duty.skins then
					availableGroups[id].duty.skins = {}
				end
			else
				outputDebugString("Group " .. id .. ". not found in the table.")
			end
		end
	end
end

function loadPlayerGroups(thePlayer)
	local characterId = tonumber(getElementData(thePlayer, "char.ID"))

	if characterId then
		dbQuery(
			function (qh)
				local result = dbPoll(qh, 0)
				local groups = {}

				if result then
					for k, v in ipairs(result) do
						groups[v.groupId] = {v.rank, v.dutySkin, v.isLeader}
					end
				end

				setElementData(thePlayer, "player.groups", groups)
			end,
		connection, "SELECT * FROM groupMembers WHERE characterId = ?", characterId)
	end
end

function requestGroupData(source, groups, characterId, groupId)
	local groupIds = {}

	for k, v in pairs(groups) do
		table.insert(groupIds, k)
	end

	if #groupIds > 0 then
		local members = {}

		dbQuery(
			function (qh, client)
				local result, rows = dbPoll(qh, 0)
				
				for k, row in ipairs(result) do
					if row.characterName then
						local group = row.groupId

						if not members[group] then
							members[group] = {}
						end

						table.insert(members[group], row)
					end
				end

				triggerClientEvent(client, "receiveGroupMembers", client, members, characterId, groupId)
			end,
		{source}, connection, [[
			SELECT groupMembers.groupId AS groupId, groupMembers.rank AS rank, groupMembers.isLeader AS isLeader, groupMembers.dutySkin AS dutySkin, characters.name AS characterName, characters.characterId AS id, characters.lastOnline AS lastOnline 
			FROM groupMembers 
			LEFT JOIN characters 
			ON characters.characterId = groupMembers.characterId 
			WHERE groupMembers.groupId IN (]] .. table.concat(groupIds, ",") .. [[) 
			ORDER BY groupMembers.groupId, groupMembers.rank, characters.name
		]])
	end
end

addEvent("requestGroupData", true)
addEventHandler("requestGroupData", getRootElement(),
	function (groups)
		if isElement(source) and client and client == source and groups then
			requestGroupData(source, groups)
		end
	end)

addEvent("requestGroups", true)
addEventHandler("requestGroups", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			triggerClientEvent(source, "receiveGroups", source, availableGroups)
		end
	end)

function reloadGroupDatasForPlayer(qh, player, sourcePlayer, sourceGroups, characterId, groupId)
	if isElement(player) then
		loadPlayerGroups(player)
	end

	if isElement(sourcePlayer) then
		requestGroupData(sourcePlayer, sourceGroups, characterId, groupId)
	end

	dbFree(qh)
end

addEvent("modifyRankForPlayer", true)
addEventHandler("modifyRankForPlayer", getRootElement(),
	function (characterId, currRank, groupId, state, player, sourceGroups)
		if characterId and currRank and groupId and state then
			if state == "up" then
				if currRank < 15 then
					dbQuery(reloadGroupDatasForPlayer, {player, source, sourceGroups, characterId, groupId}, connection, "UPDATE groupMembers SET rank = ? WHERE groupId = ? AND characterId = ?", currRank + 1, groupId, characterId)
				end
			elseif state == "down" then
				if currRank > 1 then
					dbQuery(reloadGroupDatasForPlayer, {player, source, sourceGroups, characterId, groupId}, connection, "UPDATE groupMembers SET rank = ? WHERE groupId = ? AND characterId = ?", currRank - 1, groupId, characterId)
				end
			end
		end
	end)

addEvent("deletePlayerFromGroup", true)
addEventHandler("deletePlayerFromGroup", getRootElement(),
	function (characterId, groupId, player, sourceGroups)
		if characterId and groupId then
			dbQuery(reloadGroupDatasForPlayer, {player, source, sourceGroups}, connection, "DELETE FROM groupMembers WHERE groupId = ? AND characterId = ?", groupId, characterId)
		end
	end)

addEvent("invitePlayerToGroup", true)
addEventHandler("invitePlayerToGroup", getRootElement(),
	function (characterId, groupId, player, sourceGroups)
		if characterId and groupId then
			dbQuery(reloadGroupDatasForPlayer, {player, source, sourceGroups}, connection, "INSERT INTO groupMembers (groupId, characterId) VALUES (?,?)", groupId, characterId)
		end
	end)

addCommandHandler("setplayerleader",
	function (sourcePlayer, commandName, targetPlayer, groupId, isLeader)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			groupId = tonumber(groupId)
			isLeader = tonumber(isLeader)

			if not (targetPlayer and groupId and isLeader) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Csoport ID] [Leader (0 = nem | 1 = igen)]", sourcePlayer, 255, 255, 255, true)
			else
				local targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if availableGroups[groupId] then
						if isPlayerInGroup(targetPlayer, groupId) then
							if isLeader == 0 then
								if isPlayerLeaderInGroup(targetPlayer, groupId) then
									dbQuery(
										function (qh)
											if isElement(targetPlayer) then
												loadPlayerGroups(targetPlayer)
											end

											if isElement(sourcePlayer) then
												outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen elvetted a kiválasztott játékos leader jogát a csoportból.", sourcePlayer, 255, 255, 255, true)
											end

											dbFree(qh)
										end,
									connection, "UPDATE groupMembers SET isLeader = 'N' WHERE groupId = ? AND characterId = ?", groupId, getElementData(targetPlayer, "char.ID"))
								else
									outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos nem leader a csoportban.", sourcePlayer, 255, 255, 255, true)
								end
							else
								if not isPlayerLeaderInGroup(targetPlayer, groupId) then
									dbQuery(
										function (qh)
											if isElement(targetPlayer) then
												loadPlayerGroups(targetPlayer)
											end

											if isElement(sourcePlayer) then
												outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen beállítottad a játékost a kiválasztott csoport leaderének.", sourcePlayer, 255, 255, 255, true)
											end

											dbFree(qh)
										end,
									connection, "UPDATE groupMembers SET isLeader = 'Y' WHERE groupId = ? AND characterId = ?", groupId, getElementData(targetPlayer, "char.ID"))
								else
									outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos már a csoport leadere.", sourcePlayer, 255, 255, 255, true)
								end
							end
						else
							outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos nem a csoport tagja.", sourcePlayer, 255, 255, 255, true)
						end
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott csoport nem létezik.", sourcePlayer, 255, 255, 255, true)
					end
				end
			end
		end
	end)

addCommandHandler("addplayergroup",
	function (sourcePlayer, commandName, targetPlayer, groupId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			groupId = tonumber(groupId)

			if not (targetPlayer and groupId) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Csoport ID]", sourcePlayer, 255, 255, 255, true)
			else
				local targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if availableGroups[groupId] then
						if not isPlayerInGroup(targetPlayer, groupId) then
							dbQuery(
								function (qh)
									if isElement(targetPlayer) then
										loadPlayerGroups(targetPlayer)
									end

									if isElement(sourcePlayer) then
										outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen hozzáadtad a játékost a kiválasztott csoporthoz.", sourcePlayer, 255, 255, 255, true)
									end

									dbFree(qh)
								end,
							connection, "INSERT INTO groupMembers (groupId, characterId) VALUES (?,?)", groupId, getElementData(targetPlayer, "char.ID"))
						else
							outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos már a csoport tagja.", sourcePlayer, 255, 255, 255, true)
						end
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott csoport nem létezik.", sourcePlayer, 255, 255, 255, true)
					end
				end
			end
		end
	end)

addCommandHandler("removeplayergroup",
	function (sourcePlayer, commandName, targetPlayer, groupId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			groupId = tonumber(groupId)

			if not (targetPlayer and groupId) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Csoport ID]", sourcePlayer, 255, 255, 255, true)
			else
				local targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if availableGroups[groupId] then
						if isPlayerInGroup(targetPlayer, groupId) then
							dbQuery(
								function (qh)
									if isElement(targetPlayer) then
										loadPlayerGroups(targetPlayer)
									end

									if isElement(sourcePlayer) then
										outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen eltávolítottad a játékost a kiválasztott csoportból.", sourcePlayer, 255, 255, 255, true)
									end

									dbFree(qh)
								end,
							connection, "DELETE FROM groupMembers WHERE groupId = ? AND characterId = ?", groupId, getElementData(targetPlayer, "char.ID"))
						else
							outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos nem a csoport tagja.", sourcePlayer, 255, 255, 255, true)
						end
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott csoport nem létezik.", sourcePlayer, 255, 255, 255, true)
					end
				end
			end
		end
	end)

addEvent("renameGroupRank", true)
addEventHandler("renameGroupRank", getRootElement(),
	function (rankId, rankName, groupId)
		if rankId and rankName and groupId then
			local ranks = {}

			availableGroups[groupId].ranks[rankId].name = rankName

			triggerClientEvent(getElementsByType("player"), "modifyGroupData", resourceRoot, groupId, "rankName", rankId, rankName)

			for i = 1, #availableGroups[groupId].ranks do
				table.insert(ranks, availableGroups[groupId].ranks[i].name)
			end

			dbExec(connection, "UPDATE groups SET ranks = ? WHERE groupId = ?", table.concat(ranks, ","), groupId)

			exports.see_logs:logCommand(source, eventName, {groupId, getElementData(source, "visibleName"), rankName, "rank: " .. rankId})
		end
	end)

addEvent("setGroupRankPayment", true)
addEventHandler("setGroupRankPayment", getRootElement(),
	function (rankId, payment, groupId)
		if rankId and payment and groupId then
			local ranks_pay = {}

			availableGroups[groupId].ranks[rankId].pay = payment

			triggerClientEvent(getElementsByType("player"), "modifyGroupData", resourceRoot, groupId, "rankPayment", rankId, payment)

			for i = 1, #availableGroups[groupId].ranks do
				table.insert(ranks_pay, availableGroups[groupId].ranks[i].pay)
			end

			dbExec(connection, "UPDATE groups SET ranks_pay = ? WHERE groupId = ?", table.concat(ranks_pay, ","), groupId)

			exports.see_logs:logCommand(source, eventName, {groupId, getElementData(source, "visibleName"), payment, "rank: " .. rankId})
		end
	end)

addEvent("rewriteGroupDescription", true)
addEventHandler("rewriteGroupDescription", getRootElement(),
	function (description, groupId)
		if description and groupId then
			availableGroups[groupId].description = description

			triggerClientEvent(getElementsByType("player"), "modifyGroupData", resourceRoot, groupId, "description", false, description)

			dbExec(connection, "UPDATE groups SET description = ? WHERE groupId = ?", description, groupId)

			exports.see_logs:logCommand(source, eventName, {groupId, getElementData(source, "visibleName"), description})
		end
	end)

addEvent("setGroupBalance", true)
addEventHandler("setGroupBalance", getRootElement(),
	function (amount, groupId)
		if amount and groupId then
			local currentBalance = availableGroups[groupId].balance

			currentBalance = currentBalance + amount

			local currentMoney = getElementData(source, "char.Money") or 0

			if currentBalance < 0 then
				triggerClientEvent(source, "setInputError", source, "#d75959Nincs elegendő pénz a számlán.")
			else
				if amount > 0 and currentMoney < amount then
					triggerClientEvent(source, "setInputError", source, "#d75959Nincs nálad ennyi pénz.")
				else
					setElementData(source, "char.Money", currentMoney - amount)

					availableGroups[groupId].balance = currentBalance

					dbQuery(
						function (qh, player)
							exports.see_logs:logCommand(player, "groupBalance", {groupId, getElementData(player, "visibleName"), amount .. " $", "balance: " .. currentBalance .. " $"})

							triggerClientEvent(player, "setInputError", player, "#3d7abcA tranzakció sikeresen megtörtént!")
							
							triggerClientEvent(getElementsByType("player"), "modifyGroupData", resourceRoot, groupId, "balance", false, currentBalance)

							dbFree(qh)
						end,
					{source}, connection, "UPDATE groups SET balance = ? WHERE groupId = ?", currentBalance, groupId)
				end
			end
		end
	end)

function getGroupBalance(groupId)
	if tonumber(groupId) then
		if availableGroups[groupId] then
			return tonumber(availableGroups[groupId].balance)
		else
			return false
		end
	else
		return false
	end
end

function setGroupBalance(groupId, balance)
	if tonumber(groupId) and tonumber(balance) then
		if availableGroups[groupId] then
			dbExec(connection, "UPDATE groups SET balance = ? WHERE groupId = ?", tonumber(balance), tonumber(groupId))
			availableGroups[groupId].balance = tonumber(balance)
		else
			return false
		end
	else
		return false
	end
end

function getGroupRankPay(groupId, rankId)
	if tonumber(groupId) and rankId then
		if availableGroups[groupId] then
			if availableGroups[groupId].ranks[rankId] then
				return availableGroups[groupId].ranks[rankId].pay or 0
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

function sendGroupMessage(groupId, messages)
	if tonumber(groupId) and messages then
		if availableGroups[groupId] then
			local players = getElementsByType("player")

			for i = 1, #players do
				local player = players[i]

				if isElement(player) and isPlayerInGroup(player, groupId) then
					if type(messages) == "table" then
						for j = 1, #messages do
							outputChatBox(messages[j], player, 0, 0, 0, true)
						end
					else
						outputChatBox(messages, player, 0, 0, 0, true)
					end
				end
			end

			return true
		else
			return false
		end
	else
		return false
	end
end

addEvent("updateDutySkin", true)
addEventHandler("updateDutySkin", getRootElement(),
	function (groupId, selectedSkin, originalSkin)
		if groupId and availableGroups[groupId] then
			local characterId = getElementData(source, "char.ID")

			if characterId then
				local playerGroups = getElementData(source, "player.groups")

				if playerGroups then
					if playerGroups[groupId] then
						playerGroups[groupId][2] = selectedSkin
					end

					setElementData(source, "player.groups", playerGroups)
				end

				if getElementData(source, "inDuty") then
					setElementModel(source, selectedSkin)
				else
					setElementModel(source, originalSkin)
				end

				dbExec(connection, "UPDATE groupMembers SET dutySkin = ? WHERE groupId = ? AND characterId = ?", selectedSkin, groupId, characterId)
			end
		end
	end)

addCommandHandler("getgroupcount",
	function (sourcePlayer, commandName, groupId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 6 then
			groupId = tonumber(groupId)

			if not groupId then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Csoport ID]", sourcePlayer, 255, 255, 255, true)
			else
				if availableGroups[groupId] then
					local count = 0

					for k, v in pairs(getElementsByType("player")) do
						if getElementData(v, "loggedIn") then
							local groups = getElementData(v, "player.groups") or {}

							if groups[groupId] then
								count = count + 1
							end
						end
					end

					outputChatBox("#3d7abc[StrongMTA]: #ffffffA kiválasztott csoport online létszáma #3d7abc" .. count .. ".", sourcePlayer, 255, 255, 255, true)
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott csoport nem létezik.", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end)

addEventHandler("onElementModelChange", getRootElement(),
	function (oldModel, newModel)
		if getElementType(source) == "player" and (getElementData(source, "adminDuty") or 0) == 0 then
			local allowed = true

			for k, v in pairs(availableGroups) do
				for k2, v2 in ipairs(v.duty.skins) do
					if v2 == newModel and not isPlayerInGroup(source, k) then
						allowed = false
						break
					end
				end

				if not allowed then
					break
				end
			end

			if not allowed then
				setTimer(
					function (player)
						setElementModel(player, oldModel)
					end,
				500, 1, source)

				outputChatBox("#d75959[StrongMTA]: #ffffffEzt a skint csak az adott csoport tagjai hordhatják!", source, 0, 0, 0, true)
			end
		end
	end)

addEvent("requestDuty", true)
addEventHandler("requestDuty", getRootElement(),
	function (groupId)
		if source == client and groupId then
			local group = availableGroups[groupId]
			
			if group then
				if getElementData(source, "inDuty") then
					setElementData(source, "inDuty", false)
					setElementModel(source, getElementData(source, "char.Skin"))

					if group.duty.items then
						for k, v in ipairs(group.duty.items) do
							exports.see_items:takeItemWithData(source, v[1], "duty", "data3")
						end
					end
					
					outputChatBox("#3d7abc[StrongMTA]: #ffffffLeadtad a szolgálatot.", source, 0, 0, 0, true)
				else
					local groupData = getPlayerGroups(source)[groupId]
					local skinId = tonumber(groupData[2])

					if not skinId or skinId == 0 then
						if group.duty.skins and group.duty.skins[1] then
							skinId = group.duty.skins[1]
						end
					end

					setElementData(source, "inDuty", groupId)
					setElementModel(source, skinId)

					if group.duty.armor and group.duty.armor > 0 then
						local armor = getPedArmor(source)

						armor = armor + group.duty.armor

						if armor < 100 then
							setPedArmor(source, armor)
						else
							setPedArmor(source, 100)
						end
					end

					if group.duty.items then
						for k, v in ipairs(group.duty.items) do
							exports.see_items:giveItem(source, v[1], v[2], false, v[3], v[4], "duty")
						end
					end

					outputChatBox("#3d7abc[StrongMTA]: #ffffffFelvetted a szolgálatot.", source, 0, 0, 0, true)
				end
			end
		end
	end
)

addCommandHandler("ch2", 
	function (source)
		if getElementData(source, "acc.adminLevel") >= 6 or isPlayerLeaderInGroup(source, 1) or isPlayerLeaderInGroup(source, 15) or isPlayerLeaderInGroup(source, 13) or isPlayerLeaderInGroup(source, 38) or isPlayerLeaderInGroup(source, 12) or isPlayerInGroup(source, 39) or isPlayerInGroup(source, 2) or isPlayerLeaderInGroup(source, 18) or isPlayerLeaderInGroup(source, 19) then 
			--outputChatBox("vaatok kucsot adok fk id: " .. isPlayerInGroup(source, 1))
			local pedVehicle = getPedOccupiedVehicle(source)
			if pedVehicle then 
				--outputChatBox("kocsiban usz")
				local vehGroup = getElementData(pedVehicle, "vehicle.group")
				local vehicleId = getElementData(pedVehicle, "vehicle.dbID")
				if vehGroup > 0 then
					outputChatBox("#3d7abc[StrongMTA]: #FFFFFFSikeresen adtál egy kulcsot a(z) #32b3ef".. vehicleId .. " #FFFFFFazonosítójú járműhöz.", source, 255, 255, 255, true) 
					--outputChatBox(inspect(vehGroup))
					--exports.see_items:giveItem(source, 1, vehGroup, vehGroup)

					exports.see_items:giveItem(source, 1, 1, vehicleId, vehicleId, false, false)
				end
			else
				outputChatBox("#d75959[StrongMTA]: Nem ülsz járműben!", source, 255, 255, 255, true)
			end
		end
	end 
)

local lastClickTick = {}
addCommandHandler("gov", function(player, cmd, ...)
	local now = getTickCount()
	local a = 60
	if not lastClickTick[player] then 
		lastClickTick[player] = (a * 1000) * -1
	end 

	if now <= lastClickTick[player] + a * 1000 then
		exports.see_hud:showInfobox(player, "e", "1 percenként!")
		return
	end
	
	local groupID = isPlayerHavePermission(player, "gov")
	if groupID then
		if isPlayerLeaderInGroup(player, groupID) then 
			local msg = table.concat({...}, " ")

			if #msg > 1 then 
				outputChatBox ("============[".. getGroupName(groupID) .. " felhívás]============", root, 222, 53, 84, true )
				outputChatBox (msg, root, 172, 211, 115, true)
				outputChatBox ("==========================================================", root, 222, 53, 84, true )

				local playerName = getElementData(player, "visibleName"):gsub("_", " ")
				for k, v in pairs(getElementsByType("player")) do 
					if getElementData(v, "acc.adminLevel") >= 1 then 
						outputChatBox("#3d7abc[StrongMTA - #32b3efAdminNapló#3d7abc]: #32b3ef"..playerName .. " #FFFFFFhasználta a /gov parancsot", v, 255, 255, 255, true)
					end
				end

				lastClickTick[player] = getTickCount()
			end 
		end 
	end
end)