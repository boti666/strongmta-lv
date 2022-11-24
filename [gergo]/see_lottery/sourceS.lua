local connection = false

local lotteryTable = {}
local currentGame = 0
local totalSelled = 0
local winPercent = {
	[1] = 0,
	[2] = 5,
	[3] = 10,
	[4] = 15,
	[5] = 100
}

local savedMasks = {}

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end
)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()

		if isElement(connection) then
			requestLotteryDatas()
		end

		if fileExists("savedMasks.json") then
			local jsonFile = fileOpen("savedMasks.json")

			if jsonFile then
				local fileContent = fileRead(jsonFile, fileGetSize(jsonFile))

				fileClose(jsonFile)

				if fileContent then
					local maskNumbers = fromJSON(fileContent) or {}

					for i = 1, #maskNumbers do
						local maskNumber = tonumber(maskNumbers[i])

						if fileExists("savedMasks/" .. maskNumber .. ".mask") then
							local theFile = fileOpen("savedMasks/" .. maskNumber .. ".mask")

							if theFile then
								local pixels = fileRead(theFile, fileGetSize(theFile))

								fileClose(theFile)

								if pixels then
									savedMasks[maskNumber] = pixels
								end
							end
						end
					end	

					clearUnusedMasks(eventName)
				end
			end
		end

		setTimer(clearUnusedMasks, 1000 * 60 * 60, 0)
	end
)

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		if fileExists("savedMasks.json") then
			fileDelete("savedMasks.json")
		end

		local theFile = fileCreate("savedMasks.json")
		if theFile then
			local jsonData = {}

			for k in pairs(savedMasks) do
				table.insert(jsonData, k)
			end

			fileWrite(theFile, toJSON(jsonData, true))
			fileClose(theFile)
		end
	end
)

addEvent("createMask", true)
addEventHandler("createMask", getRootElement(),
	function (itemId, pixels)
		if itemId and pixels then
			savedMasks[itemId] = pixels

			if fileExists("savedMasks/" .. itemId .. ".mask") then
				fileDelete("savedMasks/" .. itemId .. ".mask")
			end

			local theFile = fileCreate("savedMasks/" .. itemId .. ".mask")
			if theFile then
				fileWrite(theFile, pixels)
				fileClose(theFile)
			end

			triggerClientEvent("createMask", resourceRoot, itemId, pixels)
		end
	end
)

addEvent("requestMasks", true)
addEventHandler("requestMasks", getRootElement(),
	function ()
		if isElement(source) then
			triggerClientEvent(source, "requestMasks", source, savedMasks)
		end
	end
)

function clearUnusedMasks(eventName)
	local itemList = {}
	local itemIDs = {}

	for k in pairs(savedMasks) do
		table.insert(itemList, k)
		itemIDs[k] = true
	end

	if #itemList > 0 then
		dbQuery(
			function (query)
				local result = dbPoll(query, 0)

				if result then
					local usedIDs = {}

					for i = 1, #result do
						local row = result[i]

						if row then
							if itemIDs[row.dbID] then
								usedIDs[row.dbID] = true
							end
						end
					end

					local unusedIDs = {}

					for k in pairs(itemIDs) do
						if not usedIDs[k] then
							table.insert(unusedIDs, k)
						end
					end

					if #unusedIDs > 0 then
						for i = 1, #unusedIDs do
							local itemId = tonumber(unusedIDs[i])

							if itemId then
								savedMasks[itemId] = nil

								if fileExists("savedMasks/" .. itemId .. ".mask") then
									fileDelete("savedMasks/" .. itemId .. ".mask")
								end
							end
						end

						if not eventName then
							triggerClientEvent("deleteMask", resourceRoot, unusedIDs)
						end
					end
				end
			end, connection, "SELECT dbID FROM items WHERE dbID IN (" .. table.concat(itemList, ",") .. ")"
		)
	end
end

function requestLotteryDatas(sync)
	if connection then
		dbQuery(
			function (query)
				local result = dbPoll(query, 0)

				if result then
					totalSelled = 0

					for k, v in pairs(result) do
						lotteryTable[v.id] = v
						currentGame = v.id
						totalSelled = totalSelled + v.selled
					end

					if sync then
						triggerEvent("requestDatasOfLottery", resourceRoot)
					end
				end
			end, connection, "SELECT * FROM lottery"
		)
	end
end

function pickNumbers()
	local numsKeyed = {}
	local nums = {}

	for i = 1, 5 do
		local num = math.random(1, 90)
		repeat num = math.random(1, 90)
		until not numsKeyed[num]

		numsKeyed[num] = i
		nums[i] = num
	end

	return toJSON(nums, true)
end

addCommandHandler("getlottonums",
	function (sourcePlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			outputDebugString("Current winner numbers: " .. table.concat(fromJSON(lotteryTable[currentGame].nums), " | "))
		end
	end
)

addCommandHandler("newlottery",
	function (sourcePlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			dbExec(connection, "INSERT INTO lottery SET nums = ?, started = ?", pickNumbers(), getRealTime().timestamp)

			requestLotteryDatas(true)

			outputChatBox("#3d7abc[StrongMTA]: #ffffffÚj lottó játék indítva.", sourcePlayer, 0, 0, 0, true)
		end
	end
)

function checkForNewGame()
	if currentGame > 0 then
		local gameTable = lotteryTable[currentGame]

		if gameTable then
			local currentTime = getRealTime().timestamp

			if currentTime >= gameTable.started + 60 * 60 * 24 * 7 then
				if gameTable.winners == 0 then
					dbExec(connection, "INSERT INTO lottery SET nums = ?, started = ?, prize = ?", pickNumbers(), getRealTime().timestamp, gameTable.prize)
				else
					dbExec(connection, "INSERT INTO lottery SET nums = ?, started = ?", pickNumbers(), getRealTime().timestamp)
				end

				requestLotteryDatas(true)

				return true
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
setTimer(checkForNewGame, 1000 * 60 * 5, 0)

addEvent("giveALotteryTicket", true)
addEventHandler("giveALotteryTicket", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			if currentGame > 0 then
				local gameTable = lotteryTable[currentGame]

				if gameTable then
					if exports.see_core:getMoney(source) - 500 >= 0 then
						if exports.see_items:giveItem(source, 294, 1, false, totalSelled + 1, false, gameTable.id) then -- szelvényszám, bejelölt számok, játék id
							exports.see_core:takeMoney(source, 500)

							gameTable.prize = gameTable.prize + 100
							gameTable.selled = gameTable.selled + 1
							totalSelled = totalSelled + 1

							triggerEvent("requestDatasOfLottery", source)

							outputChatBox("#3d7abc[StrongMTA - Lottó]: #ffffffSikeresen vásároltál egy üres lottó szelvényt.", source, 255, 255, 255, true)
							outputChatBox("#3d7abc[StrongMTA - Lottó]: #ffffffKitölteni az inventorydban tudod, rákattintással.", source, 255, 255, 255, true)

							dbExec(connection, "UPDATE lottery SET prize = ?, selled = ? WHERE id = ?", gameTable.prize, gameTable.selled, gameTable.id)
						else
							exports.see_hud:showInfobox(source, "e", "Nincs nálad elég hely!")
						end
					else
						exports.see_hud:showInfobox(source, "e", "Nincs nálad elég pénz!")
					end
				end
			end
		end
	end
)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "loggedIn" then
			if getElementData(source, dataName) then
				announceLottery(source)
			end
		end
	end
)

addCommandHandler("lottoadat",
	function (sourcePlayer)
		if getElementData(sourcePlayer, "loggedIn") then
			announceLottery(sourcePlayer)
		end
	end
)

function formatNumber(amount, stepper)
	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end

function announceLottery(element)
	if not element then
		element = getRootElement()
	end

	if currentGame > 0 then
		local gameTable = lotteryTable[currentGame]

		if gameTable then
			outputChatBox("#3d7abc[StrongMTA - Lottó]: #ffffffJelenlegi játék: #32b3ef" .. gameTable.id .. "#ffffff.", element, 255, 255, 255, true)
			outputChatBox("#3d7abc[StrongMTA - Lottó]: #ffffffFőnyeremény: #32b3ef" .. formatNumber(gameTable.prize) .. " $.", element, 255, 255, 255, true)
			outputChatBox("#3d7abc[StrongMTA - Lottó]: #ffffffElőző 5 játék nyerőszámai:", element, 255, 255, 255, true)

			for i = #lotteryTable - 1, #lotteryTable - 5, -1 do
				local dat = lotteryTable[i]

				if dat then
					outputChatBox(string.format("- #32b3ef%d. #ffffffjáték: #32b3ef%s #ffffff| Főnyeremény: #32b3ef%s #ffffff$", dat.id, table.concat(fromJSON(dat.nums), ", "), formatNumber(dat.prize)), element, 255, 255, 255, true)
				end
			end
		end
	end
end

addEvent("requestDatasOfLottery", true)
addEventHandler("requestDatasOfLottery", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			if currentGame > 0 then
				local gameTable = lotteryTable[currentGame]

				if gameTable then
					local lastList = {}

					for i = #lotteryTable - 1, #lotteryTable - 3, -1 do
						local dat = lotteryTable[i]

						if dat then
							table.insert(lastList, dat)
						end
					end

					if source == resourceRoot then
						triggerClientEvent("requestDatasOfLottery", resourceRoot, gameTable.id, gameTable.prize, lastList)
					else
						triggerClientEvent(source, "requestDatasOfLottery", source, gameTable.id, gameTable.prize, lastList)
					end
				end
			end
		end
	end
)

addEvent("tryToConvertLottery", true)
addEventHandler("tryToConvertLottery", getRootElement(),
	function (itemId)
		if isElement(source) and client and client == source and itemId then
			local items = exports.see_items:getElementItems(source)
			
			for k, v in pairs(items) do
				if v.itemId == 294 and v.dbID == itemId then
					local nums = fromJSON(v.data2 or "")

					if not nums or #nums ~= 5 then
						outputChatBox("#d75959[StrongMTA - Lottó]: #ffffffA szelvény érvénytelen.", source, 255, 255, 255, true)
						return
					end

					local serial = ""

					for i = 1, 7 - string.len(v.data1) do
						serial = serial .. tostring(math.random(1, 9))
					end

					serial = serial .. v.data1

					exports.see_items:takeItem(source, "dbID", itemId)
					exports.see_items:giveItem(source, 295, 1, false, v.data2, false, toJSON({v.data1, v.data3, serial}, true)) -- data1: számok, data2: állapot, data3: szelvényszám/játék id

					break
				end
			end
		end
	end
)

addEvent("checkLotteryWin", true)
addEventHandler("checkLotteryWin", getRootElement(),
	function (itemId)
		if isElement(source) and client and client == source and itemId then
			local items = exports.see_items:getElementItems(source)
			
			for k, v in pairs(items) do
				if v.itemId == 295 and v.dbID == itemId then
					local ticketDat = fromJSON(v.data3 or "")

					if v.data2 ~= "empty" then
						if tonumber(ticketDat[2]) ~= currentGame then
							local myNumbers = fromJSON(v.data1)
							local gameDetails = false

							for i = #lotteryTable - 1, 1, -1 do
								local gameDat = lotteryTable[i]

								if gameDat then
									if tonumber(ticketDat[2]) == gameDat.id then
										gameDetails = gameDat
										break
									end
								end
							end

							if gameDetails then
								local winnerNumbers = fromJSON(gameDetails.nums)
								local rewardCounter = 0

								table.sort(myNumbers)
								table.sort(winnerNumbers)

								for i = 1, 5 do
									if winnerNumbers[i] == myNumbers[i] then
										rewardCounter = rewardCounter + 1
									end
								end

								exports.see_items:takeItem(source, "dbID", v.dbID)

								if rewardCounter >= 2 then
									local rewardAmount = math.floor(gameDetails.prize / 100 * winPercent[rewardCounter])
									
									exports.see_core:giveMoney(source, rewardAmount, "lotteryWin")

									outputChatBox("#3d7abc[StrongMTA - Lottó]: #ffffffA szelvény nyert #32b3ef" .. formatNumber(rewardAmount) .. " #ffffff$-t.", source, 255, 255, 255, true)
									outputChatBox("#3d7abc[StrongMTA - Lottó]: #ffffffTalálatok száma: #32b3ef" .. rewardCounter .. "#ffffff.", source, 255, 255, 255, true)

									if rewardCounter == 5 then
										lotteryTable[gameDetails.id].winners = lotteryTable[gameDetails.id].winners + 1
										dbExec(connection, "UPDATE lottery SET winners = ? WHERE id = ?", lotteryTable[gameDetails.id].winners, gameDetails.id)
									end
								else
									outputChatBox("#3d7abc[StrongMTA - Lottó]: #ffffffSajnos ez a szelvény nem nyert.", source, 255, 255, 255, true)
								end
							else
								outputChatBox("#d75959[StrongMTA - Lottó]: #ffffffA szelvény érvénytelen.", source, 255, 255, 255, true)
							end
						else
							outputChatBox("#d75959[StrongMTA - Lottó]: #ffffffA lottószámok még nincsenek kihúzva erre a játékra.", source, 255, 255, 255, true)
						end
					else
						outputChatBox("#d75959[StrongMTA - Lottó]: #ffffffA szelvény érvénytelen.", source, 255, 255, 255, true)
					end

					break
				end
			end
		end
	end
)

addEvent("checkTicketWin", true)
addEventHandler("checkTicketWin", getRootElement(),
	function (itemId)
		if isElement(source) and client and client == source and itemId then
			local items = exports.see_items:getElementItems(source)
			local deletedIDs = {}
			
			for k, v in pairs(items) do
				if scratchItems[v.itemId] and v.dbID == itemId then
					local data = fromJSON(v.data1) or {}
					local rewardAmount = 0

					if v.itemId == 293 then -- Black Jack
						if tostring(data[1]) == "true" then
							rewardAmount = tonumber(data[7])
						end
					elseif v.itemId == 296 then -- Money Mania
						local winnerColumns = {}

						for k in pairs(data[3]) do
							table.insert(winnerColumns, tonumber(k))
						end

						if #winnerColumns > 0 then
							for i = 1, #winnerColumns do
								local column = winnerColumns[i]

								if column and data[2][column] then
									rewardAmount = rewardAmount + tonumber(data[2][column])
								end
							end
						end
					elseif v.itemId == 374 then -- Szerencsemalac
						if data[2] > 0 then
							rewardAmount = data[2]

							if data[3] then
								rewardAmount = rewardAmount * 2
							end
						end
					elseif v.itemId == 375 then -- Pénzlift
						if data[3] > 0 then
							rewardAmount = data[3]
						end
					end

					if rewardAmount > 0 then
						exports.see_core:giveMoney(source, rewardAmount, "ticketWin")
						outputChatBox("#3d7abc[StrongMTA - Szerencsejáték]: #ffffffA sorsjegy nyert #32b3ef" .. formatNumber(rewardAmount) .. " #ffffff$-t.", source, 255, 255, 255, true)
					else
						outputChatBox("#3d7abc[StrongMTA - Szerencsejáték]: #ffffffSajnálom, ez a sorsjegy nem nyert!", source, 255, 255, 255, true)
					end

					exports.see_items:takeItem(source, "dbID", v.dbID)
					savedMasks[itemId] = nil

					if fileExists("savedMasks/" .. itemId .. ".mask") then
						fileDelete("savedMasks/" .. itemId .. ".mask")
					end

					table.insert(deletedIDs, itemId)

					break
				end
			end

			if #deletedIDs > 0 then
				triggerClientEvent("deleteMask", resourceRoot, deletedIDs)
			end
		end
	end
)