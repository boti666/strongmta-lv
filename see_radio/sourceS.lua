local storedHiFis = {}

function placeRadio(thePlayer, itemId)
	if isElement(thePlayer) then
		if itemId then
			local playerPosX, playerPosY, playerPosZ = getElementPosition(thePlayer)
			local playerRotX, playerRotY, playerRotZ = getElementRotation(thePlayer)
			local objectElement = createObject(2103, playerPosX, playerPosY, playerPosZ - 1, 0, 0, playerRotZ + 180)

			if isElement(objectElement) then
				local radioId = 1

				for i = 1, #storedHiFis + 1 do
					if not storedHiFis[i] then
						radioId = i
						break
					end
				end

				storedHiFis[radioId] = objectElement

				setElementInterior(objectElement, getElementInterior(thePlayer))
				setElementDimension(objectElement, getElementDimension(thePlayer))
				setElementData(objectElement, "radioId", radioId)

				exports.see_items:takeItem(thePlayer, "dbID", itemId)
				exports.see_chat:localAction(thePlayer, "lerak egy rádiót a földre.")
			end
		end
	end
end

addEvent("pickupRadio", true)
addEventHandler("pickupRadio", getRootElement(),
	function (hifiElement)
		if isElement(hifiElement) then
			local radioId = getElementData(hifiElement, "radioId")

			if radioId then
				if exports.see_items:hasSpaceForItem(source, 150, 1) then
					exports.see_items:giveItem(source, 150, 1)

					if storedHiFis[radioId] then
						if isElement(storedHiFis[radioId]) then
							destroyElement(storedHiFis[radioId])
						end

						storedHiFis[radioId] = nil
					end
				else
					outputChatBox("#dc143c[StrongMTA]: #ffffffNincs elég hely az inventorydban a rádió felvételéhez.", source, 255, 255, 255, true)
				end
			end
		end
	end)