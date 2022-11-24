local modelTextures = {
	[526] = "Nissan S14 A_Lempos",
	[551] = "01",
	[420] = "lights",
	[558] = "m3_tl",
	[467] = "lightsus",
	[507] = "fonar",
	[550] = "1",
	[561] = "gt05_misc",
	[401] = "all",
	[421] = "lampa",
	[405] = "a8tail",
	[558] = "lights",
	[529] = "lights",
	[474] = "vehiclelights",
	[589] = "0x2B9F1F34",
	[445] = "lights",
	[491] = "vehiclelights",
	[496] = "scirocco_lights",
	[518] = "vehiclelights"
}

local availableTextures = {
	[1] = "nissan/1.png",
	[2] = "nissan/2.png",
	[3] = "nissan/3.png",
	[4] = "bmw750/1.png",
	[5] = "bmw750/2.png",
	[6] = "bmw750/3.png",
	[7] = "bmw750/4.png",
	[8] = "bmw750/5.png",
	[9] = "bmw750/6.png",
	[10] = "bmw750/7.png",
	[11] = "bmw750/8.png",
	[12] = "bmw750/9.png",
	[13] = "bmw750/10.png",
	[14] = "bmw750/11.png",
	[15] = "bmwe34m5/1.png",
	[16] = "bmwe34m5/2.png",
	[17] = "bmwe34m5/3.png",
	[18] = "bmwe34m5/4.png",
	[19] = "bmwe34m5/5.png",
	[20] = "bmwm3/1.png",
	[21] = "chevycaprice/1.png",
	[22] = "chevycaprice/2.png",
	[23] = "chevycaprice/3.png",
	[24] = "chevycaprice/4.png",
	[25] = "chevycaprice/5.png",
	[26] = "chevycaprice/6.png",
	[27] = "chevycaprice/7.png",
	[28] = "chevycaprice/8.png",
	[29] = "mercedese500/1.png",
	[30] = "mercedese500/2.png",
	[31] = "mercedese500/3.png",
	[32] = "mercedese500/4.png",
	[33] = "mercedesw210/1.png",
	[34] = "mercedesw210/2.png",
	[35] = "mustang_stratum/1.png",
	[36] = "mustang_stratum/2.png",
	[37] = "mustang_stratum/3.png",
	[38] = "mustang_stratum/4.png",
	[43] = "560sec/1.png",
	[44] = "760light/1.png",
	[45] = "760light/2.png",
	[46] = "760light/3.png",
	[47] = "760light/4.png",
	[48] = "a8/1.png",
	[48] = "a8/2.png",
	[48] = "a8/3.png",
	[49] = "bmwm3/1.png",
	[50] = "bmwm3/2.png",
	[51] = "bmwm3/3.png",
	[52] = "bmwm3/4.png",
	[53] = "bmwm3/5.png",
	[54] = "bmwm3/6.png",
	[55] = "dodge/1.png",
	[56] = "gnx/1.png",
	[57] = "golf/1.png",
	[58] = "golf/2.png",
	[59] = "golf/3.png",
	[60] = "golf/4.png",
	[61] = "golf/5.png",
	[62] = "golf/6.png",
	[62] = "golf/7.png",
	[63] = "m5e60/1.png",
	[64] = "m5e60/2.png",
	[65] = "m5e60/3.png",
	[66] = "m5e60/4.png",
	[67] = "m5e60/5.png",
	[68] = "m5e60/6.png",
	[69] = "m635csilights/1.png",
	[70] = "m635csilights/2.png",
	[71] = "m635csilights/3.png",
	[72] = "scirocco/scirocco1.png",
	[73] = "scirocco/scirocco2.png",
	[74] = "scirocco/scirocco3.png",
	[75] = "scirocco/scirocco4.png",
	[76] = "viper/vehiclelights.png"

}	

local paintjobs = {
	["gt05_misc"] = {
		[561] = {35, 36, 37, 38}
	},
	["1"] = {
		[550] = {33, 34}
	},
	["fonar"] = {
		[507] = {21, 22, 23, 24, 25, 26, 27, 28}
	},
	["lightsus"] = {
		[467] = {21, 22, 23, 24, 25, 26, 27, 28}
	},
	["m3_tl"] = {
		[558] = {20}
	},
	["01"] = {
		[551] = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}
	},
	["Nissan S14 A_Lempos"] = {
		[526] = {1, 2, 3}
	},
	["all"] = {
		[401] = {43}
	},
	["lampa"] = {
		[421] = {44, 45, 46, 47}
	},
	["a8tail"] = {
		[405] = {44, 45, 46, 47}
	},
	["lights"] = {
		[529] = {55},
		[420] = {15,16,17,18,19},
		[445] = {63, 64, 65, 66, 67, 68},
		[558] = {49, 50, 51, 52, 53, 54}
	},
	["vehiclelights"] = {
		[474] = {56},
		[518] = {76}
	},
	["0x2B9F1F34"] = {
		[589] = {57, 58, 59, 60, 61, 62}
	},
	["scirocco_lights"] = {
		[496] = {72, 73, 74, 75}
	}

}

local textures = {}
local shaders = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(availableTextures) do
			textures[k] = dxCreateTexture("textures/" .. v, "dxt3")
		end

		for k, v in pairs(getElementsByType("vehicle"), getRootElement(), true) do
			applyTexture(v)
		end
	end)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "vehicle" then
			applyTexture(source)
		end
	end)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		for k, v in pairs(shaders) do
			if isElement(v) then
				destroyElement(v)
			end
		end

		for k, v in pairs(textures) do
			destroyElement(v)
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "vehicle.tuning.HeadLight" then
			applyTexture(source)
		end
	end)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if shaders[source] then
			if isElement(shaders[source]) then
				destroyElement(shaders[source])
			end

			shaders[source] = nil
		end
	end)

addCommandHandler("aheadlight",
	function (commandName, paintjobId)
		if getElementData(localPlayer, "acc.adminLevel") >= 7 then
			paintjobId = tonumber(paintjobId)

			if not paintjobId then
				outputChatBox("#3d7abc[Használat]:#ffffff /" .. commandName .. " [ID]", 255, 255, 255, true)
			else
				local pedveh = getPedOccupiedVehicle(localPlayer)

				if pedveh then
					local model = getElementModel(pedveh)

					if isTextureIdValid(model, paintjobId) or paintjobId == 0 then
						setElementData(pedveh, "vehicle.tuning.HeadLight", paintjobId)
						triggerServerEvent("logAdminPaintjob", localPlayer, getElementData(pedveh, "vehicle.dbID") or 0, commandName, paintjobId)
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffEz a lámpa nem kompatibilis ezzel a kocsival!", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffElőbb ülj be egy kocsiba!", 255, 255, 255, true)
				end
			end
		end
	end)

function applyTexture(vehicle)
	local paintjobId = getElementData(vehicle, "vehicle.tuning.HeadLight") or 0

	if paintjobId then
		if paintjobId == 0 then
			if isElement(shaders[vehicle]) then
				destroyElement(shaders[vehicle])
			end

			shaders[vehicle] = nil
		elseif paintjobId > 0 then
			local model = getElementModel(vehicle)

			if not isElement(shaders[vehicle]) then
				shaders[vehicle] = dxCreateShader("texturechanger.fx")
			end

			local modelTexture = modelTextures[model]

			if modelTexture then
				local paintjob = paintjobs[modelTexture]

				if paintjob and paintjob[model] then
					local textureId = paintjob[model][paintjobId]

					if textureId and shaders[vehicle] then
						if textures[textureId] then
							dxSetShaderValue(shaders[vehicle], "gTexture", textures[textureId])
							engineApplyShaderToWorldTexture(shaders[vehicle], modelTexture, vehicle)
						end
					end
				end
			end
		end
	end
end

function isTextureIdValid(model, textureId)
	local modelTexture = modelTextures[model]

	if modelTexture then
		local paintjob = paintjobs[modelTexture]

		if paintjob then
			if paintjob[model] then
				if paintjob[model][textureId] then
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

function applyHeadLight(paintjobId, sync)
	local pedveh = getPedOccupiedVehicle(localPlayer)

	paintjobId = tonumber(paintjobId)

	if paintjobId then
		if isElement(pedveh) then
			local model = getElementModel(pedveh)

			if isTextureIdValid(model, paintjobId) or paintjobId == 0 then
				setElementData(pedveh, "vehicle.tuning.HeadLight", paintjobId, sync)
			end
		end
	end
end

function getHeadLightCount(model)
	model = tonumber(model)

	local modelTexture = modelTextures[model]
	local paintjob = paintjobs[modelTexture]

	if model and modelTexture and paintjob and paintjob[model] then
		return #paintjob[model]
	end

	return false
end