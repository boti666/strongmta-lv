local connection = false

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end
)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()
	end
)

addEvent("tryToBuyCloth", true)
addEventHandler("tryToBuyCloth", getRootElement(),
	function (model, price)
		if isElement(source) and client and client == source then
			local currentBalance = exports.see_core:getMoney(source) or 0

			if currentBalance - price >= 0 then
				local characterId = getElementData(source, "char.ID")
				local boughtClothes = getElementData(source, "boughtClothes") or ""
				
				boughtClothes = fromJSON(boughtClothes) or {}
				boughtClothes[model] = true
				boughtClothes = toJSON(boughtClothes, true)

				exports.see_core:takeMoney(source, price, "buycloth")

				setElementData(source, "boughtClothes", boughtClothes)
				dbExec(connection, "UPDATE characters SET boughtClothes = ? WHERE characterId = ?", boughtClothes, characterId)

				triggerClientEvent(source, "clothBuyProcessed", source, "s", "Sikeres vásárlás!")
			else
				triggerClientEvent(source, "clothBuyProcessed", source, "e", "Nincs elég pénzed!")
			end
		end
	end
)

addEvent("tryToBuyClothSlot", true)
addEventHandler("tryToBuyClothSlot", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			local currentBalance = getElementData(source, "acc.premiumPoints") or 0

			currentBalance = currentBalance - 1000

			if currentBalance  >= 0 then
				local accountId = getElementData(source, "char.accID")
				local characterId = getElementData(source, "char.ID")
				local clothesLimit = getElementData(source, "clothesLimit") or 2

				clothesLimit = clothesLimit + 1

				setElementData(source, "clothesLimit", clothesLimit)
				setElementData(source, "acc.premiumPoints", currentBalance)

				dbExec(connection, "UPDATE characters SET clothesLimit = ? WHERE characterId = ?", clothesLimit, characterId)
				dbExec(connection, "UPDATE accounts SET premiumPoints = ? WHERE accountId = ?", currentBalance, accountId)

				triggerClientEvent(source, "buyTheClothesSlot", source, "s", "Sikeresen vásároltál +1 slotot!")
			else
				triggerClientEvent(source, "buyTheClothesSlot", source, "e", "Nincs elég prémium pontod!")
			end
		end
	end
)

addEvent("onTryToRemoveCloth", true)
addEventHandler("onTryToRemoveCloth", getRootElement(),
	function (targetPlayer, slotName)
		if isElement(source) and client and client == source then
			if isElement(targetPlayer) then
				local targetName = getElementData(targetPlayer, "visibleName"):gsub("_", " ")

				if slotName then
					local currentClothes = getElementData(targetPlayer, "currentClothes") or ""

					currentClothes = fromJSON(currentClothes) or {}
					currentClothes[slotName] = nil

					setElementData(targetPlayer, "currentClothes", toJSON(currentClothes, true))

					outputChatBox("#3d7abc[StrongMTA - Adminruha]:#ffffff Sikeresen levetted #32b3ef" .. targetName .. " #ffffffegy ruhadarabját. #32b3ef(" .. slotName .. ")", source, 255, 255, 255, true)
				end
			end
		end
	end
)

addEvent("onNeededForWaitAim", true)
addEventHandler("onNeededForWaitAim", getRootElement(),
	function (state)
		if isElement(source) then
			if state == "off" then
				setPedAnimation(source, false)
			else
				setPedAnimation(source, "COP_AMBIENT", "Coplook_loop", -1, true, false, false)
			end
		end
	end
)