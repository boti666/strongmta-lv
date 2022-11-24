local perishableValue = 420

local itemNames = {}
local itemPrices = {
	[158] = 2500000,
	[221] = 15000*10,
	[222] = 7500*10,
	[223] = 7500*10,
	[224] = 7500*10,
	[225] = 7500*10,
	[226] = 15000*10,
	[227] = 1500*10,
	[228] = 1500*10,
	[229] = 1500*10,
	[230] = 1500*10,
	[231] = 1500*10,
	[246] = 7500*10,
	[247] = 30000*10,
	[248] = 1500*10,
	[250] = 15000*10,
	[251] = 15000*10,
	[252] = 15000*10,
	[253] = 750000,
	[254] = 1250000,
	[255] = 15000*10,
	[256] = 7500*10,
	[259] = 1000000,
	[260] = 1500000,
	[261] = 15000*10,
	[351] = 18000*10,
	[352] = 19500*10,
	[353] = 7500*10,
	[354] = 15000*10,
	[355] = 15000*10,
	[356] = 7500*10,
	[357] = 7500*10,
	[359] = 21000*10,
	[360] = 15000*10,
	[363] = 500000*10
}

local availableTradePoints = {
	{192, "Sophie Lung", 816.30609130859, 856.66107177734, 12.7890625, 260}, -- Bányató
	{158, "Az öreg halász", -315.09371948242, 811.10095214844, 15.604573249817, 110}, -- Kikötő
	{160, "Az öreg halász", 2901.1335449219, 2127.1279296875, 11.307812690735, 210},
	{161, "Az öreg halász", -2035.68359375, 2368.8308105469, 3.7380256652832, 156},
	{132, "Az öreg halász", 263.46380615234, 2895.8076171875, 10.531394958496, 34},
	{231, "Zacis bácsi", 2873.8024902344, 2440.5969238281, 11.068956375122, 220}
}

addEventHandler("onResourceStart", getRootElement(),
	function (startedResource)
		if startedResource == getThisResource() then
			for i, v in ipairs(availableTradePoints) do
				local colSphereElement = createColSphere(v[3], v[4], v[5], 2)

				if isElement(colSphereElement) then
					local pedElement = createPed(v[1], v[3], v[4], v[5], v[6], false)

					if isElement(pedElement) then
						setElementFrozen(pedElement, true)
						setElementData(pedElement, "invulnerable", true)
						setElementData(pedElement, "visibleName", v[2])
						setElementData(pedElement, "pedNameType", "Hal leadó")
					end
				end
			end

			local inventoryResource = getResourceFromName("see_items")
			if inventoryResource then
				if getResourceState(inventoryResource) == "running" then
					itemNames = {}

					for itemId in pairs(itemPrices) do
						itemNames[itemId] = exports.see_items:getItemName(itemId)
					end
				end
			end
		else
			if getResourceName(startedResource) == "see_items" then
				itemNames = {}

				for itemId in pairs(itemPrices) do
					itemNames[itemId] = exports.see_items:getItemName(itemId)
				end
			end
		end
	end
)

addEventHandler("onColShapeHit", getResourceRootElement(),
	function (hitElement, matchingDimension)
		if isElement(source) then
			if matchingDimension then
				if getElementType(hitElement) == "player" then
					if not getPedOccupiedVehicle(hitElement) then
						local playerItems = exports.see_items:getElementItems(hitElement)
						local rewardAmount = 0

						for k, v in pairs(playerItems) do
							if itemPrices[v.itemId] then
								local health = math.floor(100 - (tonumber(v.data3) or 0) / perishableValue * 100)
								local price = math.ceil(itemPrices[v.itemId] * health / 100)

								rewardAmount = rewardAmount + price
								exports.see_items:takeItem(hitElement, "dbID", v.dbID)

								outputChatBox("#3d7abc[StrongMTA - Horgászat]: #FFFFFFLeadtál #3d7abc1 #FFFFFFdarab #3d7abc" .. itemNames[v.itemId] .. "#FFFFFF-t #598ed7(" .. health .. "%)#FFFFFF, kaptál érte #3d7abc" .. price .. " #FFFFFFdollárt.", hitElement, 0, 0, 0, true)
							end
						end

						if rewardAmount > 0 then
							exports.see_core:giveMoney(hitElement, rewardAmount)
							exports.see_hud:showInfobox(hitElement, "s", "Sikeresen leadtál " .. rewardAmount .. " $ értékű halat.")
						end
					end
				end
			end
		end
	end
)

addEvent("throwInRod", true)
addEventHandler("throwInRod", getRootElement(),
	function (waterPosX, waterPosY, waterPosZ)
		if isElement(source) and client and client == source then
			if waterPosX and waterPosY and waterPosZ then
				triggerClientEvent("throwInRod", source, waterPosX, waterPosY, waterPosZ)
				exports.see_chat:localAction(source, "bedobja a horgot a vízbe.")
			end
		end
	end
)

addEvent("endFishing", true)
addEventHandler("endFishing", getRootElement(),
    function (itemId, itemName)
        if isElement(source) and client and client == source then
            triggerClientEvent("endFishing", source, itemId)

            if getElementData(source, "endingFishing") then
               	--triggerClientEvent("endFishing", source, false)
                setElementFrozen(source, false)
                setPedAnimation(source, false)

                exports.see_controls:toggleControl(source, "all", true)
                exports.see_chat:localAction(source, "kihúzza a horgot a vízből.")

                setElementData(source, "endingFishing", false)
            end

            if itemId and itemName then
                if exports.see_items:hasSpaceForItem(source, itemId) then
                    exports.see_items:giveItem(source, itemId, 1)

                    exports.see_hud:showInfobox(source, "s", "Sikeresen kifogtad a halat! (" .. itemName .. ")")
                    exports.see_chat:localAction(source, "kihúz valamit a vízből.")

                    outputChatBox("#3d7abc[StrongMTA - Horgászat]: #FFFFFFSikeresen fogtál egy #598ed7" .. itemName .. "#FFFFFF-t.", source, 0, 0, 0, true)
                else
                    outputChatBox("#d75959[StrongMTA - Horgászat]: #FFFFFFSajnos nincs elég hely az inventorydban, hogy megtartsd a halat.", source, 0, 0, 0, true)
                end
            end

            setElementFrozen(source, false)
            setPedAnimation(source, false)

            exports.see_controls:toggleControl(source, "all", true)
            exports.see_chat:localAction(source, "kihúzza a horgot a vízből.")
        end
    end
)

addEvent("setFishingAnim", true)
addEventHandler("setFishingAnim", getRootElement(),
	function (streamedPlayers)
		if isElement(source) and client and client == source then
			triggerClientEvent(streamedPlayers, "moveDownFloater", source)
			setElementFrozen(source, true)
			setPedAnimation(source, "SWORD", "sword_IDLE")
			exports.see_controls:toggleControl(source, "all", false)
		end
	end
)

addEvent("floaterMoveStopped", true)
addEventHandler("floaterMoveStopped", getRootElement(),
	function (streamedPlayers)
		if isElement(source) and client and client == source then
			triggerClientEvent(streamedPlayers, "floaterMoveStopped", source)
		end
	end
)

addEvent("failTheRod", true)
addEventHandler("failTheRod", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			local fishingRodInHand = getElementData(source, "fishingRodInHand")
			if fishingRodInHand then
				exports.see_items:takeItem(source, "dbID", fishingRodInHand)
				setElementData(source, "fishingRodInHand", false)
			end
		end
	end
)

addEvent("Łä>&ä&đ€}Đ", true)
addEventHandler("Łä>&ä&đ€}Đ", getRootElement(),
	function (streamedPlayers)
		if isElement(source) and client and client == source then
			triggerClientEvent(streamedPlayers, "Łä>&ä&đ€}Đ", source)
		end
	end
)
