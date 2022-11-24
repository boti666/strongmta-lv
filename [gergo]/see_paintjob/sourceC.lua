--[[local modelTextures = {
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
	[597] = "r_map",
	[596] = "remap_taurus",
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
	[599] = "remap",
	[582] = "template",

}

local availableTextures = {
	[1] = "challenger/1.dds",
	[2] = "challenger/2.dds",
	[3] = "challenger/3.dds",
	[4] = "challenger/4.dds",
	[5] = "polmav/3.dds",
	[6] = "galant/1.dds",
	[7] = "galant/2.dds",
	[8] = "gmcsavana/1.dds",
	[9] = "gmcsavana/2.dds",
	[10] = "corrado/1.dds",
	[11] = "mercedes560sec/1.dds",
	[12] = "mercedes560sec/2.dds",
	[13] = "mercedes560sec/3.dds",
	[14] = "mercedes560sec/4.dds",
	[15] = "mercedes560sec/5.dds",
	[16] = "mercedes560sec/6.dds",
	[17] = "mercedes560sec/7.dds",
	--[18] = "quattro/1.dds",
	--[19] = "quattro/2.dds",
	--[20] = "quattro/3.dds",
	--[21] = "quattro/4.dds",
	[22] = "mustang/1.dds",
	[23] = "mustang/2.dds",
	[24] = "mustang/3.dds",
	[25] = "mustang/4.dds",
	[26] = "mustang/5.dds",
	[27] = "mustang/6.dds",
	[28] = "mustang/7.dds",
	[29] = "nissan/1.dds",
	[30] = "nissan/2.dds",
	[31] = "nissan/3.dds",
	[32] = "audirs4/1.dds",
	[33] = "audirs4/2.dds",
	[34] = "audirs4/3.dds",
	[35] = "audirs4/4.dds",
	[36] = "audirs4/5.dds",
	[37] = "audirs4/6.dds",
	[38] = "bmwm3/1.dds",
	[39] = "bmwm3/2.dds",
	[40] = "bmwm3/3.dds",
	[41] = "chevybelair/1.dds",
	[42] = "chevybelair/2.dds",
	[43] = "chevybelair/3.dds",
	[44] = "chevybelair/4.dds",
	[45] = "chevycaprice/1.dds",
	[46] = "chevycaprice/2.dds",
	[47] = "chevycaprice/3.dds",
	[48] = "chevycaprice/4.dds",
	[49] = "chevycaprice/5.dds",
	[50] = "chevycaprice/6.dds",
	[51] = "chevychevelle/1.dds",
	[52] = "chevychevelle/2.dds",
	[53] = "chevychevelle/3.dds",
	[54] = "chevychevelle/4.dds",
	[55] = "chevychevelle/5.dds",
	[56] = "chevychevelle/6.dds",
	[57] = "chevychevelle/7.dds",
	[58] = "charger_439/charger_1.dds",
	[59] = "charger_439/charger_2.dds",
	[60] = "ferrari/1.png",
	[61] = "ferrari/2.png",
	[62] = "ferrari/3.png",
	[63] = "ferrari/4.png",
	[64] = "ferrari/5.png",
	[65] = "ferrari/6.png",
	[66] = "ferrari/7.png",
	[67] = "ferrari/8.png",
	[68] = "ferrari/9.png",
	[69] = "ferrari/10.png",
	[70] = "ferrari/11.png",
	[71] = "fordcustom/1.dds",
	[72] = "fordcustom/2.dds",
	[73] = "fordcustom/3.dds",
	[74] = "fordcustom/4.dds",
	[75] = "fordcustom/5.dds",
	[76] = "hondacivic/1.dds",
	[77] = "hondacivic/2.dds",
	[78] = "hondacivic/3.dds",
	[79] = "hondacivic/4.dds",
	[80] = "jeepwrangler/1.dds",
	[81] = "jeepwrangler/2.dds",
	[82] = "jeepwrangler/3.dds",
	[83] = "jeepwrangler/4.dds",
	[84] = "jeepwrangler/5.dds",
	[85] = "jeepwrangler/6.dds",
	[86] = "jeepwrangler/7.dds",
	[87] = "jeepwrangler/8.dds",
	[88] = "mitsubishilancer/1.dds",
	[89] = "mitsubishilancer/2.dds",
	[90] = "mitsubishilancer/3.dds",
	[91] = "mitsubishilancer/4.dds",
	[92] = "mitsubishilancer/5.dds",
	[93] = "mitsubishilancer/6.dds",
	[94] = "mitsubishilancer/7.dds",
	[95] = "mustangnew/1.dds",
	[96] = "mustangnew/2.dds",
	[97] = "mustangnew/3.dds",
	[98] = "mustangnew/4.dds",
	[99] = "mustang_stratum/1.dds",
	[100] = "mustang_stratum/2.dds",
	[101] = "mustang_stratum/3.dds",
	[102] = "nissanskyline/1.dds",
	[103] = "nissanskyline/2.dds",
	[104] = "nissanskyline/3.dds",
	[105] = "nissanskyline/4.dds",
	[106] = "subaruimpreza/1.dds",
	[107] = "subaruimpreza/2.dds",
	[108] = "subaruimpreza/3.dds",
	[109] = "toyotasupra/1.dds",
	[110] = "toyotasupra/2.dds",
	[111] = "toyotasupra/3.dds",
	[112] = "toyotasupra/4.dds",
	[113] = "toyotasupra/5.dds",
	[114] = "toyotasupra/6.dds",
	[115] = "nissan/4.dds",
	[116] = "nissan/5.dds",
	[117] = "dodge_polara/1.dds",
	[118] = "gremlin/1.dds",
	--[119] = "crownvic/1.dds",
	[120] = "challenger/5.dds",
	[121] = "challenger/6.dds",
	[122] = "challenger/7.dds",
	[123] = "e34/1.dds",
	[124] = "e34/2.dds",
	[125] = "e34/3.dds",
	[126] = "pontiacgto/1.dds",
	[127] = "pontiacgto/2.dds",
	[128] = "pontiacgto/3.dds",
	[129] = "pontiacgto/4.dds",
	[130] = "polmav/1.dds",
	[131] = "polmav/2.dds",
	[132] = "m635/1.dds",
	[133] = "m635/2.dds",
	[134] = "m635/3.dds",
	[135] = "m635/4.dds",
	[136] = "m635/5.dds",
	[137] = "m635/6.dds",
	[138] = "m635/7.dds",
	[139] = "m635/8.dds",
	[140] = "m635/9.dds",
	[141] = "m635/10.dds",
	[142] = "m635/11.dds",
	[143] = "m635/12.dds",
	[144] = "m3/1.dds",
	[145] = "m3/2.dds",
	[146] = "m3/3.dds",
	[147] = "m3/4.dds",
	[148] = "amggt/1.dds",
	[149] = "amggt/2.dds",
	[150] = "amggt/3.dds",
	[151] = "amggt/4.dds",
	[152] = "amggt/5.dds",
	[153] = "amggt/6.dds",
	[154] = "thunderbird_536/bird_1.dds",
	[155] = "thunderbird_536/bird_2.dds",
	[156] = "thunderbird_536/bird_3.dds",
	[157] = "thunderbird_536/bird_4.dds",
	[158] = "charger_439/charger_3.dds",
	[159] = "comet/1.png",
	[160] = "comet/2.png",
	[161] = "comet/3.png",
	[162] = "comet/4.png",
	[163] = "explorer/1.dds",
	[164] = "copcarpj/1.dds",
	[165] = "copcarpj/2.dds",
	[166] = "copcarpj/3.dds",
	[167] = "demon/1.dds",
	[168] = "demon/2.dds",
	[169] = "demon/3.dds",
	[170] = "demon/4.dds",
	[171] = "demon/5.dds",
	[172] = "dodgesrt/1.dds",
	[173] = "dodgesrt/2.dds",
	[174] = "dodgesrt/3.dds",
	[175] = "dodgesrt/4.dds",
	[176] = "e60/1.dds",
	[177] = "e60/2.dds",
	[178] = "e60/m51.dds",
	[179] = "e60/m52.dds",
	[180] = "e60/m53.dds",
	[181] = "e60/4.dds",
	[182] = "e60/5.dds",
	[183] = "e250/1.dds",
	[184] = "e250/2.dds",
	[185] = "e250/3.dds",
	[186] = "e420/1.dds",
	[187] = "e420/2.dds",
	[188] = "e420/3.dds",
	[189] = "fiero/1.dds",
	[190] = "fiero/2.dds",
	[191] = "gnx/1.dds",
	[192] = "gnx/2.dds",
	[193] = "gnx/3.dds",
	[194] = "gnx/4.dds",
	[195] = "gnx/5.dds",
	[196] = "golf/1.dds",
	[197] = "golf/2.dds",
	[198] = "golf/3.dds",
	[199] = "golf/4.dds",
	[200] = "golf/5.dds",
	[201] = "grandsrt8/1.dds",
	[202] = "grandsrt8/2.dds",
	[203] = "grandsrt8/3.dds",
	[204] = "grandsrt8/4.dds",
	[205] = "hummer/1.dds",
	[206] = "hummer/2.dds",
	[207] = "hummer/3.dds",
	[208] = "nissan/6.dds",
	[209] = "raptor/1.dds",
	[210] = "raptor/2.dds",
	[211] = "raptor/3.dds",
	[212] = "raptor/4.dds",
	[213] = "raptor/5.dds",
	[214] = "sanchez/1.dds",
	[215] = "sanchez/2.dds",
	[216] = "sanchez/3.dds",
	[217] = "sanchez/4.dds",
	[218] = "sanchez/5.dds",
	[219] = "subaru/4.dds",
	[220] = "subaru/5.dds",
	[221] = "subaru/6.dds",
	[222] = "subaru/7.dds",
	[223] = "subaru/8.dds",
	[224] = "barkas/1.dds",
	[225] = "barkas/2.dds",
	[226] = "barkas/3.dds",
	[227] = "explorer/2.dds",
	[228] = "explorer/3.dds",
	[229] = "explorer/4.dds",
	[230] = "explorer/5.dds",
	[231] = "dodgepd/1.dds",
	[232] = "dodgepd/2.dds",
	--[233] = "dodgepd/3.dds",
	[234] = "f150/1.dds",
	[235] = "f150/2.dds",
	[236] = "sprinter/1.dds",

}

local paintjobs = {
	["remap_hummer"] = {
		[470] = {206, 207, 208}
	},
	["remapsrt8"] = {
		[400] = {201, 202, 203, 204, 205}
	},
	["remap_body"] = {
		[589] = {196, 197, 198, 199, 200}
	},
	["remap_gnx87"] = {
		[474] = {191, 192, 193, 194, 195}
	},
	["remap_fiero88"] = {
		[545] = {189, 190}
	},
	["chrom"] = {
		[550] = {186, 187, 188},
	},
	["remap_taurus"] = {
		[596] = {164, 165, 166}
	},
	["remapbirdbody"] = {
		[536] = {154, 155, 156, 157}
	},	
	["remap_m635csi84"] = {
		[491] = {132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143}
	},
	["polmav_sign_1"] = {
		[497] = {130, 131, 5}
	},
	["remap_judge69"] = {
		[475] = {126, 127, 128, 129}
	},
	["face"] = {
		[420] = {123, 124, 125}
	},
	["body"] = {
		[562] = {102, 103, 104, 105},
	},
	["template"] = {
		[582] = {236},
	},
 	["remap_gremlin73"] = {
		[410] = {118}
	},
	["tg_body"] = {
		[438] = {117}
	},
	["remap_challenger70"] = {
		[603] = {1, 2, 3, 4, 120, 121, 122}
	},
	["remap_supra92"] = {
		[559] = {109, 110, 111, 112, 113, 114}
	},
	["remap_impreza"] = {
		[540] = {106, 107, 108, 219, 220, 221, 223}
	},
	["remapmesa256"] = {
		[500] = {80, 81, 82, 83, 84, 85, 86, 87}
	},
	["remap_civic"] = {
		[565] = {76, 77, 78, 79}
	},
	["@hite"] = {
		[535] = {71, 72, 73, 74, 75}
	},
	["remap430body"] = {
		[411] = {60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70}
	},
	["remap_charger70"] = {
		[439] = {58, 59, 158}
	},
	["remap_galant87"] = {
		[547] = {6, 7}
	},
	["remapgmc"] = {
		[418] = {8, 9}
	},
	["r_map"] = {
		[401] = {11, 12, 13, 14, 15, 16, 17},
		[436] = {10},
		[527] = {95, 96, 97, 98},
		[561] = {99, 100, 101},
		[502] = {148, 149, 150, 151, 152, 153},
		[558] = {144, 145, 146, 147},
		[480] = {159, 160, 161, 162},
		[597] = {163, 227, 228, 229, 230},
		[426] = {167,168,169,170,171},
		[529] = {172, 173, 174, 175},
		[445] = {176, 177, 178, 179, 180, 181, 182},
		[458] = {183, 184, 185},
		[402] = {22, 23, 24, 25, 26, 27, 28},
		[526] = {29, 30, 31, 115, 116, 208},
		[495] = {209, 210, 211, 212, 213},
		[468] = {214, 215, 216, 217, 218},
		[506] = {214, 215, 216, 217, 218},
		[483] = {224,225,226},
	},
	["remap"] = {
		[598] = {231, 232},
		[599] = {234, 235},
	},
	["remap_quattro82"] = {
		[602] = {18, 19, 20, 21}
	},
	["remapelegybody128"] = {
		[560] = {88, 89, 90, 91, 92, 93, 94}
	},
	["remap_rs_body"] = {
		[580] = {32, 33, 34, 35, 36, 37}
	},
	["remap_belair57"] = {
		[576] = {41, 42, 43, 44}
	},
	["T_Body2"] = {
		[467] = {45, 46, 47, 48, 49, 50}
	},
	["remap_chevelle67"] = {
		[517] = {51, 52, 53, 54, 55, 56, 57}
	}
}

local textures = {}
local shaders = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(availableTextures) do
			textures[k] = dxCreateTexture("textures/" .. v, "dxt1")
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
		if dataName == "vehicle.tuning.Paintjob" then
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

addCommandHandler("apaintjob",
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
						setElementData(pedveh, "vehicle.tuning.Paintjob", paintjobId)
						triggerServerEvent("logAdminPaintjob", localPlayer, getElementData(pedveh, "vehicle.dbID") or 0, commandName, paintjobId)
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffEz a paintjob nem kompatibilis ezzel a kocsival!", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffElőbb ülj be egy kocsiba!", 255, 255, 255, true)
				end
			end
		end
	end)

function applyTexture(vehicle)
	local paintjobId = getElementData(vehicle, "vehicle.tuning.Paintjob") or 0

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

function applyPaintJob(paintjobId, sync)
	local pedveh = getPedOccupiedVehicle(localPlayer)

	paintjobId = tonumber(paintjobId)

	if paintjobId then
		if isElement(pedveh) then
			local model = getElementModel(pedveh)

			if isTextureIdValid(model, paintjobId) or paintjobId == 0 then
				setElementData(pedveh, "vehicle.tuning.Paintjob", paintjobId, sync)
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
end]]

local modelTextures = {
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
	[1] = "challenger/1.dds",
	[2] = "challenger/2.dds",
	[3] = "challenger/3.dds",
	[4] = "challenger/4.dds",
	[5] = "polmav/3.dds",
	[6] = "galant/1.dds",
	[7] = "galant/2.dds",
	[8] = "gmcsavana/1.dds",
	[9] = "gmcsavana/2.dds",
	[10] = "corrado/1.dds",
	[11] = "mercedes560sec/1.dds",
	[12] = "mercedes560sec/2.dds",
	[13] = "mercedes560sec/3.dds",
	[14] = "mercedes560sec/4.dds",
	[15] = "mercedes560sec/5.dds",
	[16] = "mercedes560sec/6.dds",
	[17] = "mercedes560sec/7.dds",
	[22] = "mustang/1.dds",
	[23] = "mustang/2.dds",
	[24] = "mustang/3.dds",
	[25] = "mustang/4.dds",
	[26] = "mustang/5.dds",
	[27] = "mustang/6.dds",
	[28] = "mustang/7.dds",
	[29] = "nissan/1.dds",
	[30] = "nissan/2.dds",
	[31] = "nissan/3.dds",
	[32] = "audirs4/1.dds",
	[33] = "audirs4/2.dds",
	[34] = "audirs4/3.dds",
	[35] = "audirs4/4.dds",
	[36] = "audirs4/5.dds",
	[37] = "audirs4/6.dds",
	[38] = "bmwm3/1.dds",
	[39] = "bmwm3/2.dds",
	[40] = "bmwm3/3.dds",
	[41] = "chevybelair/1.dds",
	[42] = "chevybelair/2.dds",
	[43] = "chevybelair/3.dds",
	[44] = "chevybelair/4.dds",
	[45] = "chevycaprice/1.dds",
	[46] = "chevycaprice/2.dds",
	[47] = "chevycaprice/3.dds",
	[48] = "chevycaprice/4.dds",
	[49] = "chevycaprice/5.dds",
	[50] = "chevycaprice/6.dds",
	[51] = "chevychevelle/1.dds",
	[52] = "chevychevelle/2.dds",
	[53] = "chevychevelle/3.dds",
	[54] = "chevychevelle/4.dds",
	[55] = "chevychevelle/5.dds",
	[56] = "chevychevelle/6.dds",
	[57] = "chevychevelle/7.dds",
	[58] = "charger_439/charger_1.dds",
	[59] = "charger_439/charger_2.dds",
	[60] = "ferrari/1.png",
	[61] = "ferrari/2.png",
	[62] = "ferrari/3.png",
	[63] = "ferrari/4.png",
	[64] = "ferrari/5.png",
	[65] = "ferrari/6.png",
	[66] = "ferrari/7.png",
	[67] = "ferrari/8.png",
	[68] = "ferrari/9.png",
	[69] = "ferrari/10.png",
	[70] = "ferrari/11.png",
	[71] = "fordcustom/1.dds",
	[72] = "fordcustom/2.dds",
	[73] = "fordcustom/3.dds",
	[74] = "fordcustom/4.dds",
	[75] = "fordcustom/5.dds",
	[76] = "hondacivic/1.dds",
	[77] = "hondacivic/2.dds",
	[78] = "hondacivic/3.dds",
	[79] = "hondacivic/4.dds",
	[80] = "jeepwrangler/1.dds",
	[81] = "jeepwrangler/2.dds",
	[82] = "jeepwrangler/3.dds",
	[83] = "jeepwrangler/4.dds",
	[84] = "jeepwrangler/5.dds",
	[85] = "jeepwrangler/6.dds",
	[86] = "jeepwrangler/7.dds",
	[87] = "jeepwrangler/8.dds",
	[88] = "mitsubishilancer/1.dds",
	[89] = "mitsubishilancer/2.dds",
	[90] = "mitsubishilancer/3.dds",
	[91] = "mitsubishilancer/4.dds",
	[92] = "mitsubishilancer/5.dds",
	[93] = "mitsubishilancer/6.dds",
	[94] = "mitsubishilancer/7.dds",
	[95] = "mustangnew/1.dds",
	[96] = "mustangnew/2.dds",
	[97] = "mustangnew/3.dds",
	[98] = "mustangnew/4.dds",
	[99] = "mustang_stratum/1.dds",
	[100] = "mustang_stratum/2.dds",
	[101] = "mustang_stratum/3.dds",
	[102] = "nissanskyline/1.dds",
	[103] = "nissanskyline/2.dds",
	[104] = "nissanskyline/3.dds",
	[105] = "nissanskyline/4.dds",
	[106] = "subaruimpreza/1.dds",
	[107] = "subaruimpreza/2.dds",
	[108] = "subaruimpreza/3.dds",
	[109] = "toyotasupra/1.dds",
	[110] = "toyotasupra/2.dds",
	[111] = "toyotasupra/3.dds",
	[112] = "toyotasupra/4.dds",
	[113] = "toyotasupra/5.dds",
	[114] = "toyotasupra/6.dds",
	[115] = "nissan/4.dds",
	[116] = "nissan/5.dds",
	[117] = "dodge_polara/1.dds",
	[118] = "gremlin/1.dds",
	[120] = "challenger/5.dds",
	[121] = "challenger/6.dds",
	[122] = "challenger/7.dds",
	[123] = "e34/1.dds",
	[124] = "e34/2.dds",
	[125] = "e34/3.dds",
	[126] = "pontiacgto/1.dds",
	[127] = "pontiacgto/2.dds",
	[128] = "pontiacgto/3.dds",
	[129] = "pontiacgto/4.dds",
	[130] = "polmav/1.dds",
	[131] = "polmav/2.dds",
	[132] = "m635/1.dds",
	[133] = "m635/2.dds",
	[134] = "m635/3.dds",
	[135] = "m635/4.dds",
	[136] = "m635/5.dds",
	[137] = "m635/6.dds",
	[138] = "m635/7.dds",
	[139] = "m635/8.dds",
	[140] = "m635/9.dds",
	[141] = "m635/10.dds",
	[142] = "m635/11.dds",
	[143] = "m635/12.dds",
	[144] = "m3/1.dds",
	[145] = "m3/2.dds",
	[146] = "m3/3.dds",
	[147] = "m3/4.dds",
	[148] = "amggt/1.dds",
	[149] = "amggt/2.dds",
	[150] = "amggt/3.dds",
	[151] = "amggt/4.dds",
	[152] = "amggt/5.dds",
	[153] = "amggt/6.dds",
	[154] = "thunderbird_536/bird_1.dds",
	[155] = "thunderbird_536/bird_2.dds",
	[156] = "thunderbird_536/bird_3.dds",
	[157] = "thunderbird_536/bird_4.dds",
	[158] = "charger_439/charger_3.dds",
	[159] = "comet/1.png",
	[160] = "comet/2.png",
	[161] = "comet/3.png",
	[162] = "comet/4.png",
	[167] = "demon/1.dds",
	[168] = "demon/2.dds",
	[169] = "demon/3.dds",
	[170] = "demon/4.dds",
	[171] = "demon/5.dds",
	[172] = "dodgesrt/1.dds",
	[173] = "dodgesrt/2.dds",
	[174] = "dodgesrt/3.dds",
	[175] = "dodgesrt/4.dds",
	[176] = "e60/1.dds",
	[177] = "e60/2.dds",
	[178] = "e60/m51.dds",
	[179] = "e60/m52.dds",
	[180] = "e60/m53.dds",
	[181] = "e60/4.dds",
	[182] = "e60/5.dds",
	[183] = "e250/1.dds",
	[184] = "e250/2.dds",
	[185] = "e250/3.dds",
	[186] = "e420/1.dds",
	[187] = "e420/2.dds",
	[188] = "e420/3.dds",
	[189] = "fiero/1.dds",
	[190] = "fiero/2.dds",
	[191] = "gnx/1.dds",
	[192] = "gnx/2.dds",
	[193] = "gnx/3.dds",
	[194] = "gnx/4.dds",
	[195] = "gnx/5.dds",
	[196] = "golf/1.dds",
	[197] = "golf/2.dds",
	[198] = "golf/3.dds",
	[199] = "golf/4.dds",
	[200] = "golf/5.dds",
	[201] = "grandsrt8/1.dds",
	[202] = "grandsrt8/2.dds",
	[203] = "grandsrt8/3.dds",
	[204] = "grandsrt8/4.dds",
	[205] = "hummer/1.dds",
	[206] = "hummer/2.dds",
	[207] = "hummer/3.dds",
	[208] = "nissan/6.dds",
	[209] = "raptor/1.dds",
	[210] = "raptor/2.dds",
	[211] = "raptor/3.dds",
	[212] = "raptor/4.dds",
	[213] = "raptor/5.dds",
	[214] = "sanchez/1.dds",
	[215] = "sanchez/2.dds",
	[216] = "sanchez/3.dds",
	[217] = "sanchez/4.dds",
	[218] = "sanchez/5.dds",
	[219] = "subaru/4.dds",
	[220] = "subaru/5.dds",
	[221] = "subaru/6.dds",
	[222] = "subaru/7.dds",
	[223] = "subaru/8.dds",
	[224] = "barkas/1.dds",
	[225] = "barkas/2.dds",
	[226] = "barkas/3.dds",


}

local paintjobs = {
	["remap_hummer"] = {
		[470] = {206, 207, 208}
	},
	["remapsrt8"] = {
		[400] = {201, 202, 203, 204, 205}
	},
	["remap_body"] = {
		[589] = {196, 197, 198, 199, 200}
	},
	["remap_gnx87"] = {
		[474] = {191, 192, 193, 194, 195}
	},
	["remap_fiero88"] = {
		[545] = {189, 190}
	},
	["chrom"] = {
		[550] = {186, 187, 188},
	},
	["police"] = {
		[596] = {166}
	},
	["remapbirdbody"] = {
		[536] = {154, 155, 156, 157}
	},	
	["remap_m635csi84"] = {
		[491] = {132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143}
	},
	["polmav_sign_1"] = {
		[497] = {130, 131, 5}
	},
	["remap_judge69"] = {
		[475] = {126, 127, 128, 129}
	},
	["face"] = {
		[420] = {123, 124, 125}
	},
	["body"] = {
		[562] = {102, 103, 104, 105},
	},
	["remap_gremlin73"] = {
		[410] = {118}
	},
	["tg_body"] = {
		[438] = {117}
	},
	["remap_challenger70"] = {
		[603] = {1, 2, 3, 4, 120, 121, 122}
	},
	["remap_supra92"] = {
		[559] = {109, 110, 111, 112, 113, 114}
	},
	["remap_impreza"] = {
		[540] = {106, 107, 108, 219, 220, 221, 223}
	},
	["remapmesa256"] = {
		[500] = {80, 81, 82, 83, 84, 85, 86, 87}
	},
	["remap_civic"] = {
		[565] = {76, 77, 78, 79}
	},
	["@hite"] = {
		[535] = {71, 72, 73, 74, 75}
	},
	["remap430body"] = {
		[411] = {60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70}
	},
	["remap_charger70"] = {
		[439] = {58, 59, 158}
	},
	["remap_galant87"] = {
		[547] = {6, 7}
	},
	["remapgmc"] = {
		[418] = {8, 9}
	},
	["remap"] = {
		[401] = {11, 12, 13, 14, 15, 16, 17},
		[436] = {10},
		[527] = {95, 96, 97, 98},
		[561] = {99, 100, 101},
		[502] = {148, 149, 150, 151, 152, 153},
		[558] = {144, 145, 146, 147},
		[480] = {159, 160, 161, 162},
		[597] = {163},
		[598] = {164, 165},
		[426] = {167,168,169,170,171},
		[529] = {172, 173, 174, 175},
		[445] = {176, 177, 178, 179, 180, 181, 182},
		[458] = {183, 184, 185},
		[402] = {22, 23, 24, 25, 26, 27, 28},
		[526] = {29, 30, 31, 115, 116, 208},
		[495] = {209, 210, 211, 212, 213},
		[468] = {214, 215, 216, 217, 218},
		[506] = {214, 215, 216, 217, 218},
		[483] = {224,225,226}

	},
	["remap_quattro82"] = {
		[602] = {18, 19, 20, 21}
	},
	["remapelegybody128"] = {
		[560] = {88, 89, 90, 91, 92, 93, 94}
	},
	["remap_rs_body"] = {
		[580] = {32, 33, 34, 35, 36, 37}
	},
	["remap_belair57"] = {
		[576] = {41, 42, 43, 44}
	},
	["T_Body2"] = {
		[467] = {45, 46, 47, 48, 49, 50}
	},
	["remap_chevelle67"] = {
		[517] = {51, 52, 53, 54, 55, 56, 57}
	}
}

local textures = {}
local shaders = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(availableTextures) do
			textures[k] = dxCreateTexture("textures/" .. v, "dxt1")
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
		if dataName == "vehicle.tuning.Paintjob" then
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

addCommandHandler("apaintjob",
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
						setElementData(pedveh, "vehicle.tuning.Paintjob", paintjobId)
						triggerServerEvent("logAdminPaintjob", localPlayer, getElementData(pedveh, "vehicle.dbID") or 0, commandName, paintjobId)
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffEz a paintjob nem kompatibilis ezzel a kocsival!", 255, 255, 255, true)
					end
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffElőbb ülj be egy kocsiba!", 255, 255, 255, true)
				end
			end
		end
	end)

function applyTexture(vehicle)
	local paintjobId = getElementData(vehicle, "vehicle.tuning.Paintjob") or 0

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

function applyPaintJob(paintjobId, sync)
	local pedveh = getPedOccupiedVehicle(localPlayer)

	paintjobId = tonumber(paintjobId)

	if paintjobId then
		if isElement(pedveh) then
			local model = getElementModel(pedveh)

			if isTextureIdValid(model, paintjobId) or paintjobId == 0 then
				setElementData(pedveh, "vehicle.tuning.Paintjob", paintjobId, sync)
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