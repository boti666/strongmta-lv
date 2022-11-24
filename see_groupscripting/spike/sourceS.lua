local spikeList = {}
local stingerDetails = {
	[2892] = {
		radius = 5.04148,
		length = 10.04,
		width = 1.23,
		height = 0.24
	},
	[2899] = {
		radius = 2.52697,
		length = 4.99,
		width = 1.15,
		height = 0.24
	}
}

function rotateAround(angle, x1, y1, x2, y2)
	angle = math.rad(angle)

	local rotatedX = x1 * math.cos(angle) - y1 * math.sin(angle)
	local rotatedY = x1 * math.sin(angle) + y1 * math.cos(angle)

	return rotatedX + (x2 or 0), rotatedY + (y2 or 0)
end

addEvent("placeStinger", true)
addEventHandler("placeStinger", getRootElement(),
	function (model, pos, rot, int, dim)
		if source == client and model then
			local objectElement = createObject(model, pos[1], pos[2], pos[3], 0, 0, rot[3])

			if isElement(objectElement) then
				setElementInterior(objectElement, int)
				setElementDimension(objectElement, dim)

				local spikeId = 1

				for i = 1, #spikeList + 1 do
					if not spikeList[i] then
						spikeId = i
						break
					end
				end

				local details = stingerDetails[model]
				local x1, y1 = rotateAround(rot[3], -details.width / 2, -details.length / 2, pos[1], pos[2])
				local x2, y2 = rotateAround(rot[3], details.width / 2, -details.length / 2, pos[1], pos[2])
				local x3, y3 = rotateAround(rot[3], details.width / 2, details.length / 2, pos[1], pos[2])
				local x4, y4 = rotateAround(rot[3], -details.width / 2, details.length / 2, pos[1], pos[2])

				local colShape = createColPolygon(x1, y1, x2, y2, x3, y3, x4, y4, x1, y1)
				local bigColShape = createColSphere(pos[1], pos[2], pos[3], 25)
				
				setElementData(colShape, "stingerCol", objectElement)
				setElementData(bigColShape, "bigStingerCol", objectElement)
				setElementData(objectElement, "spikeData", {spikeId, objectElement, getElementData(source, "visibleName"):gsub("_", " ")})

				spikeList[spikeId] = {objectElement, colShape, bigColShape}
			end
		end
	end)

addEvent("deleteStinger", true)
addEventHandler("deleteStinger", getRootElement(),
	function (id)
		if source == client and id then
			if spikeList[id] then
				if isElement(spikeList[id][1]) then
					destroyElement(spikeList[id][1])
				end

				if isElement(spikeList[id][2]) then
					destroyElement(spikeList[id][2])
				end

				if isElement(spikeList[id][3]) then
					destroyElement(spikeList[id][3])
				end

				spikeList[id] = nil
			end
		end
	end)

addEvent("syncStingerStates", true)
addEventHandler("syncStingerStates", getRootElement(),
	function (wheelstates)
		if isElement(source) and wheelstates then
			setVehicleWheelStates(source, unpack(wheelstates))
		end
	end)