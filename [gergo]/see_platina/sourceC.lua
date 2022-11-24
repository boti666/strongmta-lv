--local skodaModel = exports.see_infinity:getVehicleModel("skoda_octavia_rs")
--local bentleyModel = exports.see_infinity:getVehicleModel("bentley_cont")
--local m6Model = exports.see_infinity:getVehicleModel("bmw_m6")

local modelTextures = {
	--[skodaModel] = "remap",
	--[bentleyModel] = "remap",
	--[m6Model] = "remapelegybody128",
	[483] = "remap",
	[603] = "remap_challenger70",
	[547] = "remap_galant87",
	[418] = "remapgmc",
	[401] = "remap",
	[436] = "remap",
	[602] = "remap_quattro82",
	[402] = "remap",
	[526] = "remap",
	[580] = "remap_rs_body",
	[576] = "remap_belair57",
	[467] = "T_Body2",
	[517] = "remap_chevelle67",
	[439] = "remap_charger70",
	[411] = "remap430body",
	[535] = "@hite",
	[565] = "remap_civic",
	[500] = "remapmesa256",
	[560] = "remapelegybody128",
	[527] = "remap",
	[561] = "remap",
	[562] = "body",
	[540] = "remap_impreza",
	[559] = "remap_supra92",
	[438] = "tg_body",
	[410] = "remap_gremlin73",
	[420] = "face",
	[475] = "remap_judge69",
	[497] = "polmav_sign_1",
	[491] = "remap_m635csi84",
	[558] = "remap",
	[502] = "remap",
	[536] = "remapbirdbody",
	[480] = "remap",
	[597] = "remap",
	[596] = "police",
	[598] = "remap",
	[426] = "remap",
	[529] = "remap",
	[445] = "remap",
	[458] = "remap",
	[550] = "chrom",
	[545] = "remap_fiero88",
	[474] = "remap_gnx87",
	[589] = "remap_body",
	[400] = "remapsrt8",
	[470] = "remap_hummer",
	[495] = "remap",
	[468] = "remap",
	[506] = "remap",
}

local availableTextures = {
	[1] = "gold.png",

}

local paintjobs = {
	["remap_hummer"] = {
		[470] = {1}
	},
	["remapsrt8"] = {
		[400] = {1}
	},
	["remap_body"] = {
		[589] = {1},
		[485] = {1}
	},
	["remap_gnx87"] = {
		[474] = {1}
	},
	["remap_fiero88"] = {
		[545] = {1}
	},
	["chrom"] = {
		[550] = {1},
	},
	["police"] = {
		[596] = {1}
	},
	["remapbirdbody"] = {
		[536] = {1}
	},	
	["remap_m635csi84"] = {
		[491] = {1}
	},
	["polmav_sign_1"] = {
		[497] = {1}
	},
	["remap_judge69"] = {
		[475] = {1}
	},
	["face"] = {
		[420] = {1}
	},
	["body"] = {
		[562] = {1},
	},
	["remap_gremlin73"] = {
		[410] = {1}
	},
	["tg_body"] = {
		[438] = {1}
	},
	["remap_challenger70"] = {
		[603] = {1}
	},
	["remap_supra92"] = {
		[559] = {1}
	},
	["remap_impreza"] = {
		[540] = {1}
	},
	["remapmesa256"] = {
		[500] = {1}
	},
	["remap_civic"] = {
		[565] = {1}
	},
	["@hite"] = {
		[535] = {1}
	},
	["remap430body"] = {
		[411] = {1}
	},
	["remap_charger70"] = {
		[439] = {1}
	},
	["remap_galant87"] = {
		[547] = {1}
	},
	["remapgmc"] = {
		[418] = {1}
	},
	["remap"] = {
		[401] = {1},
		[436] = {1},
		[527] = {1},
		[561] = {1},
		[502] = {1},
		[558] = {1},
		[480] = {1},
		[597] = {1},
		[598] = {1},
		[529] = {1},
		[445] = {1},
		[458] = {1},
		[402] = {1},
		[526] = {1},
		[495] = {1},
		[468] = {1},
		[506] = {1},
		[483] = {1},
		--[skodaModel] = {1},
		--[bentleyModel] = {1}

	},
	["Paint_material"] = {
		[426] = {1}
	},
	["remap_quattro82"] = {
		[602] = {1}
	},
	["remapelegybody128"] = {
		[560] = {1},
		--[m6Model] = {1}
	},
	["remap_rs_body"] = {
		[580] = {1}
	},
	["remap_belair57"] = {
		[576] = {1}
	},
	["T_Body2"] = {
		[467] = {1}
	},
	["remap_chevelle67"] = {
		[517] = {1}
	}
}

local textures = {}
local shaders = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(availableTextures) do
			textures[k] = dxCreateTexture("files/" .. v, "dxt1")
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
	function (dataName, oldData, newData)
		if dataName == "vehicle.Tuning.Platina" then
			applyTexture(source)
		elseif dataName == "vehicleColor" then
			replaceColor(source)
		end
	end
)

addEventHandler("onClientElementDestroy", getRootElement(),
	function ()
		if shaders[source] then
			if isElement(shaders[source]) then
				destroyElement(shaders[source])
			end

			shaders[source] = nil
		end
	end)

addCommandHandler("aplatinawardis",
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
						setElementData(pedveh, "vehicle.Tuning.Platina", paintjobId)
						triggerServerEvent("logAdminPaintjob", localPlayer, getElementData(pedveh, "vehicle.dbID") or 0, commandName, paintjobId)
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffEz a paintjob nem kompatibilis ezzel a kocsival!", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffElőbb ülj be egy kocsiba!", 255, 255, 255, true)
				end
			end
		end
	end
)

function replaceColor(vehicle)
	vehicleColor = {getVehicleColor(vehicle, true)}
	local r, g, b = unpack(getElementData(vehicle, "vehicleColor"))

	local gold = {r / 255, g / 255, b / 255}

	if shaders[vehicle] then
		dxSetShaderValue(shaders[vehicle], "gSurfaceColor", unpack(gold))
        dxSetShaderValue(shaders[vehicle], "gFuzzySpecColor", unpack(gold))
        dxSetShaderValue(shaders[vehicle], "gSubColor", unpack(gold))
	end
end

function applyTexture(vehicle)
	local paintjobId = getElementData(vehicle, "vehicle.Tuning.Platina") or 0

	vehicleColor = {getVehicleColor(vehicle, true)}

	if getElementData(vehicle, "vehicleColor") then
		r, g, b = unpack(getElementData(vehicle, "vehicleColor"))
	else
		r, g, b = unpack(vehicleColor)
	end


	local gold = {r / 255, g / 255, b / 255}

	if paintjobId then
		if paintjobId == 0 then
			if isElement(shaders[vehicle]) then
				destroyElement(shaders[vehicle])
			end

			shaders[vehicle] = nil
		elseif paintjobId > 0 then
			local model = getElementModel(vehicle)

			if not isElement(shaders[vehicle]) then
				shaders[vehicle] = dxCreateShader("files/hl_gold.fx")

				dxSetShaderValue(shaders[vehicle], "gSurfaceColor", unpack(gold))
            	dxSetShaderValue(shaders[vehicle], "gFuzzySpecColor", unpack(gold))
            	dxSetShaderValue(shaders[vehicle], "gSubColor", unpack(gold))
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

function applyPaintJob(paintjobId, sync)
	local pedveh = getPedOccupiedVehicle(localPlayer)

	paintjobId = tonumber(paintjobId)

	if paintjobId then
		if isElement(pedveh) then
			local model = getElementModel(pedveh)

			if isTextureIdValid(model, paintjobId) or paintjobId == 0 then
				setElementData(pedveh, "vehicle.Tuning.Platina", paintjobId, sync)
			end
		end
	end
end

function getPaintJobCount(model)
	model = tonumber(model)

	local modelTexture = modelTextures[model]
	local paintjob = paintjobs[modelTexture]

	if model == 467 then
		return #paintjob[model] - 2
	end

	if model == 500 or model == 438 then
		return #paintjob[model] - 1
	end

	if model and modelTexture and paintjob and paintjob[model] then
		return #paintjob[model]
	end

	return false
end