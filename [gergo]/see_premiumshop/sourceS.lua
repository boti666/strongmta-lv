local connection = false

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()
	end)

addEvent("refreshPPShop", true)
addEventHandler("refreshPPShop", getRootElement(),
	function ()
		if isElement(source) then
			dbQuery(
				function (qh, thePlayer)
					if isElement(thePlayer) then
						local result = dbPoll(qh, 0)[1]

						if result then
							triggerClientEvent(thePlayer, "ppShopPoints", thePlayer, result.premiumPoints)
						end
					end
				end,
			{source}, connection, "SELECT premiumPoints FROM accounts WHERE accountId = ? LIMIT 1", getElementData(source, "char.accID"))
		end
	end)

addEvent("buyPremiumItem", true)
addEventHandler("buyPremiumItem", getRootElement(),
	function (item, amount)
		if isElement(source) and client and client == source and item and amount then
			local currentBalance = getElementData(source, "acc.premiumPoints") or 0
			local newBalance = currentBalance

			newBalance = newBalance - currentPedItemPrices[item] * amount

			if newBalance >= 0 then
				local accountId = getElementData(source, "char.accID")
				local characterId = getElementData(source, "char.ID")
				local visibleName = getElementData(source, "visibleName"):gsub("_", " ")

				if not string.find(item, "money") then
					local itemId = tonumber(item)
					local data1 = false

					if not itemId then
						if string.find(item, "bp") then
							itemId = 299
							data1 = tonumber(string.sub(item, 3))
						end
					end

					if exports.see_items:hasSpaceForItem(source, itemId, amount) then
						exports.see_items:giveItem(source, itemId, amount, false, data1)
					else
						exports.see_accounts:showInfo(source, "e", "Nincs nálad elég hely!")
						return
					end

					local itemName = exports.see_items:getItemName(itemId)
					if itemName then
						if itemId == 299 and blueprintNames[data1] then
							itemName = "Blueprint: " .. blueprintNames[data1]
						end

						outputChatBox("#3d7abc[StrongMTA - Prémium]: #ffffffVásároltál #32b3ef" .. formatNumber(amount) .. " #ffffffdarab #32b3ef" .. itemName .. "#ffffff-t. #8e8e8e[" .. visibleName .. "]", source, 0, 0, 0, true)
					end
				else
					local price = 0

					if item == "money1" then
						price = 24000
					elseif item == "money2" then
						price = 100000
					elseif item == "money3" then
						price = 300000
					elseif item == "money4" then
						price = 700000
					end

					exports.see_core:giveMoney(source, price)

					outputChatBox("#3d7abc[StrongMTA - Prémium]: #ffffffVásároltál #32b3ef" .. formatNumber(price) .. " #ffffff$-t. #8e8e8e[" .. visibleName .. "]", source, 0, 0, 0, true)
				end

				exports.see_accounts:showInfo(source, "s", "Sikeres vásárlás!")

				setElementData(source, "acc.premiumPoints", newBalance)
				triggerClientEvent(source, "ppShopPoints", source, newBalance)
				dbExec(connection, "UPDATE accounts SET premiumPoints = ? WHERE accountId = ?", newBalance, accountId)

				exports.see_logs:addLogEntry("premiumshop", {
					accountId = accountId,
					characterId = characterId,
					itemId = item,
					amount = amount,
					oldPP = currentBalance,
					newPP = newBalance
				})

				--setTimer(function(player)
					
				triggerClientEvent(source, "syncPPShop", source)
				--end, 1000, 1, source)
				
				
			else
				exports.see_accounts:showInfo(source, "e", "Nincs elég egyenleged!")
			end
		end
	end)