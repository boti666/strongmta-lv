local modelTextureNames = {
	[526] = "Nissan S14 A_Ratas",
	[562] = "disk",
	ronalt = "ronalt1",
	drag = "tire(r)"
}

local availableTextures = {
	[1] = "textures/nissan/1.png",
	[2] = "defaults/ronalt/1.png",
	[3] = "defaults/ronalt/2.png",
	[4] = "defaults/ronalt/3.png",
	[5] = "defaults/ronalt/4.png",
	[6] = "defaults/ronalt/5.png",
	[7] = "defaults/drag/1.png",
	[8] = "defaults/drag/2.png",
	[9] = "defaults/drag/3.png",
	[10] = "defaults/ronalt/6.png",
	[11] = "defaults/ronalt/7.png",
	[12] = "defaults/ronalt/8.png",
	[13] = "defaults/ronalt/9.png",
	[14] = "defaults/ronalt/10.png",
	[15] = "textures/nissan/2.png",
	[16] = "textures/nissan/3.png",
	[17] = "textures/nissanskyline/1.png",
	[18] = "textures/nissanskyline/2.png",
	[19] = "textures/nissanskyline/3.png",
}

local availablePaintjobs = {
	disk = {
		[562] = {17, 18, 19}
	},
	["Nissan S14 A_Ratas"] = {
		[526] = {1, 15, 16}
	},
	ronalt1 = {
		ronalt = {2, 3, 4, 5, 6, 10, 11, 12, 13, 14}
	},
	["tire(r)"] = {
		drag = {7, 8, 9}
	}
}

local availableWheelPaintjobs = {
	[1075] = "ronalt",
	[1078] = "drag"
}

local createdTextures = {}
local createdShaders = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(availableTextures) do
			createdTextures[k] = dxCreateTexture(v, "dxt3")
		end

		for k, v in pairs(getElementsByType("vehicle"), getRootElement(), true) do
			applyTexture(v)
		end
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			applyTexture(source)
		end
	end
)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		for k, v in pairs(createdShaders) do
			if isElement(v) then
				destroyElement(v)
			end
		end

		for k, v in pairs(createdTextures) do
			destroyElement(v)
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "vehicle.tuning.WheelPaintjob" then
			applyTexture(source)
		end
	end
)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if createdShaders[source] then
			if isElement(createdShaders[source]) then
				destroyElement(createdShaders[source])
			end

			createdShaders[source] = nil
		end
	end
)

addCommandHandler("awheeltext",
	function (commandName, paintjobId)
		if getElementData(localPlayer, "acc.adminLevel") >= 7 then
			paintjobId = tonumber(paintjobId)

			if not paintjobId then
				outputChatBox("#3d7abc[Használat]:#ffffff /" .. commandName .. " [ID]", 255, 255, 255, true)
			else
				local currentVeh = getPedOccupiedVehicle(localPlayer)

				if currentVeh then
					if isTextureIdValid(currentVeh, paintjobId) or paintjobId == 0 then
						setElementData(currentVeh, "vehicle.tuning.WheelPaintjob", paintjobId)
						triggerServerEvent("logAdminPaintjob", localPlayer, getElementData(currentVeh, "vehicle.dbID") or 0, commandName, paintjobId)
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffEz a kerék nem kompatibilis ezzel a kocsival!", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffElőbb ülj be egy kocsiba!", 255, 255, 255, true)
				end
			end
		end
	end
)

function applyTexture(vehicle)
	local paintjobId = getElementData(vehicle, "vehicle.tuning.WheelPaintjob") or 0

	if paintjobId then
		if paintjobId == 0 then
			if isElement(createdShaders[vehicle]) then
				destroyElement(createdShaders[vehicle])
			end

			createdShaders[vehicle] = nil
		else
			if paintjobId > 0 then
				local model = getElementModel(vehicle)

				if not isElement(createdShaders[vehicle]) then
					createdShaders[vehicle] = dxCreateShader("texturechanger.fx")
				end

				local modelTexture = false
				local wheelUpgrade = getVehicleUpgradeOnSlot(vehicle, 12)

				if wheelUpgrade > 0 then
					local wheelTexture = availableWheelPaintjobs[wheelUpgrade]

					if wheelTexture then
						modelTexture = modelTextureNames[wheelTexture]
					end
				else
					modelTexture = modelTextureNames[model]
				end

				if modelTexture then
					local selectedPaintjob = availablePaintjobs[modelTexture]

					if selectedPaintjob then
						if selectedPaintjob[model] then
							local textureId = selectedPaintjob[model][paintjobId]

							if textureId then
								if createdShaders[vehicle] then
									if createdTextures[textureId] then
										dxSetShaderValue(createdShaders[vehicle], "gTexture", createdTextures[textureId])
										engineApplyShaderToWorldTexture(createdShaders[vehicle], modelTexture, vehicle)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function isTextureIdValid(vehicle, textureId)
	local wheelUpgrade = getVehicleUpgradeOnSlot(vehicle, 12)

	if wheelUpgrade > 0 then
		local wheelTexture = availableWheelPaintjobs[wheelUpgrade]

		if wheelTexture then
			local modelTexture = modelTextureNames[wheelTexture]

			if availablePaintjobs[modelTexture] then
				if availablePaintjobs[modelTexture][wheelTexture] then
					if availablePaintjobs[modelTexture][wheelTexture][textureId] then
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
		else
			return false
		end
	else
		local model = getElementModel(vehicle)
		local modelTexture = modelTextureNames[model]

		if modelTexture then
			local selectedPaintjob = availablePaintjobs[modelTexture]

			if selectedPaintjob then
				if selectedPaintjob[model] then
					if selectedPaintjob[model][textureId] then
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
		else
			return false
		end
	end
end

function applyWheelTexture(paintjobId, sync)
	paintjobId = tonumber(paintjobId)

	if paintjobId then
		local currentVeh = getPedOccupiedVehicle(localPlayer)

		if isElement(currentVeh) then
			if isTextureIdValid(currentVeh, paintjobId) or paintjobId == 0 then
				setElementData(currentVeh, "vehicle.tuning.WheelPaintjob", paintjobId, sync)
			end
		end
	end
end

function getWheelTextureCount(vehicle)
	local wheelUpgrade = getVehicleUpgradeOnSlot(vehicle, 12)

	if wheelUpgrade > 0 then
		local wheelTexture = availableWheelPaintjobs[wheelUpgrade]

		if wheelTexture then
			local modelTexture = modelTextureNames[wheelTexture]
			return #availablePaintjobs[modelTexture][wheelTexture]
		else
			return false
		end
	else
		local model = getElementModel(vehicle)
		local modelTexture = modelTextureNames[model]
		local selectedPaintjob = availablePaintjobs[modelTexture]

		if modelTexture then
			if selectedPaintjob then
				if selectedPaintjob[model] then
					return #selectedPaintjob[model]
				end
			end
		end
	end

	return false
end
