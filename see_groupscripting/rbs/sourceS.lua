local rbsList = {}

addEvent("placeRoadBlock", true)
addEventHandler("placeRoadBlock", getRootElement(),
	function (model, pos, rot, int, dim)
		if source == client and model then
			local objectElement = createObject(model, pos[1], pos[2], pos[3], 0, 0, rot[3])

			if isElement(objectElement) then
				setElementInterior(objectElement, int)
				setElementDimension(objectElement, dim)
				setElementFrozen(objectElement, true)

				local ID = 1

				for i = 1, #rbsList + 1 do
					if not rbsList[i] then
						ID = i
						break
					end
				end

				rbsList[ID] = objectElement

				setElementData(objectElement, "rbsData", {ID, objectElement, getElementData(source, "visibleName"):gsub("_", " ")})
			end
		end
	end)

addEvent("deleteRoadBlock", true)
addEventHandler("deleteRoadBlock", getRootElement(),
	function (id)
		if source == client and id then
			if rbsList[id] then
				if isElement(rbsList[id]) then
					destroyElement(rbsList[id])
				end

				rbsList[id] = nil
			end
		end
	end)