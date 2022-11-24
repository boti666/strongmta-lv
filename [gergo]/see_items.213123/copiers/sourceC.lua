local storedCopiers = {}
local copierModel = 2186

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setTimer(triggerServerEvent, 2000, 1, "requestCopiers", localPlayer)
	end)

addEvent("receiveCopiers", true)
addEventHandler("receiveCopiers", getRootElement(),
	function (datas)
		if datas and type(datas) == "table" then
			storedCopiers = datas
		end
	end)

addEvent("createCopier", true)
addEventHandler("createCopier", getRootElement(),
	function (copierId, data)
		if copierId then
			copierId = tonumber(copierId)

			if data and type(data) == "table" then
				storedCopiers[copierId] = data
			end
		end
	end)

addEvent("destroyCopier", true)
addEventHandler("destroyCopier", getRootElement(),
	function (copierId)
		if copierId then
			copierId = tonumber(copierId)

			if storedCopiers[copierId] then
				storedCopiers[copierId] = nil
			end
		end
	end)

addCommandHandler("nearbycopiers",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			local x, y, z = getElementPosition(localPlayer)
			local int = getElementInterior(localPlayer)
			local dim = getElementDimension(localPlayer)
			local nearby = 0

			outputChatBox("#DC143C[SeeMTA]: #FFFFFFA közeledben lévő fénymásolók:", 255, 255, 255, true)

			for k, v in pairs(storedCopiers) do
				if int == v.interior and dim == v.dimension then
					local dist = getDistanceBetweenPoints3D(x, y, z, v.posX, v.posY, v.posZ)

					if dist <= 15 then
						outputChatBox("#DC143C[SeeMTA]: #FFFFFFAzonosító: #8dc63f" .. v.copierId .. "#FFFFFF <> Távolság: #8dc63f" .. math.floor(dist), 255, 255, 255, true)
						nearby = nearby + 1
					end
				end
			end

			if nearby == 0 then
				outputChatBox("#DC143C[SeeMTA]: #FFFFFFA közeledben nem található egyetlen fénymásoló sem.", 255, 255, 255, true)
			end
		end
	end)

local placeCopier = false

addCommandHandler("createcopier",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 7 then
			if not placeCopier then
				placeCopier = createObject(copierModel, 0, 0, 0)
				setElementCollisionsEnabled(placeCopier, false)
				setElementInterior(placeCopier, getElementInterior(localPlayer))
				setElementDimension(placeCopier, getElementDimension(localPlayer))
				setElementAlpha(localPlayer, 0)
				addEventHandler("onClientRender", getRootElement(), renderCopierPlacement)
			else
				removeEventHandler("onClientRender", getRootElement(), renderCopierPlacement)
				destroyElement(placeCopier)
				placeCopier = false
				setElementAlpha(localPlayer, 255)
			end
		end
	end)

function renderCopierPlacement()
	local x, y, z = getElementPosition(localPlayer)
	local rx, ry, rz = getElementRotation(localPlayer)

	z = z - 1
	rz = math.floor(rz / 5) * 5

	setElementPosition(placeCopier, x, y, z)
	setElementRotation(placeCopier, 0, 0, rz)

	if getKeyState("lalt") then
		removeEventHandler("onClientRender", getRootElement(), renderCopierPlacement)
		destroyElement(placeCopier)
		placeCopier = false
		setElementAlpha(localPlayer, 255)
		triggerServerEvent("placeCopier", localPlayer, x, y, z, rz, getElementInterior(localPlayer), getElementDimension(localPlayer))
	end
end