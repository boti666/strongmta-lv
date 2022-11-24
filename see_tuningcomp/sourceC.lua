local modificationList = {}
local threadTimer = false
local pendingCount = 0

local function registerMod(carModel, upgradeName, upgradeModel)
	local model = tonumber(carModel) or getVehicleModelFromName(carModel)

	if not modificationList[model] then
		modificationList[model] = {}
		modificationList[model].path = carModel
		modificationList[model].upgrades = {}
	end

	if upgradeName then
		table.insert(modificationList[model].upgrades, {upgradeModel, upgradeName})
	end
end

local function loadMod(model, upgrade)
	local path = ""

	if not upgrade then
		path = modificationList[model].path
	else
		path = upgrade
	end

	if fileExists("mods/" .. path .. ".txd") then
		local txd = engineLoadTXD("mods/" .. path .. ".txd")
		if txd then
			engineImportTXD(txd, model)
		end
	end

	if fileExists("mods/" .. path .. ".dff") then
		local dff = engineLoadDFF("mods/" .. path .. ".dff", model)
		if dff then
			engineReplaceModel(dff, model)
		end
	end
end

local function preLoadMod(model, upgrade)
	if isTimer(threadTimer) then
		killTimer(threadTimer)
	end

	threadTimer = setTimer(
		function ()
			pendingCount = 0
		end,
	200, 1)

	if pendingCount > 0 then
		setTimer(loadMod, pendingCount * 250, 1, model, upgrade)
		return
	end

	pendingCount = pendingCount + 1

	loadMod(model, upgrade)
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local nextPreLoadTime = 50

		for model, data in pairs(modificationList) do
			setTimer(preLoadMod, nextPreLoadTime, 1, model)
			nextPreLoadTime = nextPreLoadTime + 50

			for k, upgrade in ipairs(data.upgrades) do
				setTimer(preLoadMod, nextPreLoadTime, 1, upgrade[1], upgrade[2])
				nextPreLoadTime = nextPreLoadTime + 50
			end
		end
	end
)

registerMod("blade")
registerMod("blade", "exh_lr_bl1", 1104)
registerMod("blade", "exh_lr_bl2", 1105)
registerMod("blade", "fbmp_lr_bl1", 1182)
registerMod("blade", "fbmp_lr_bl2", 1181)

registerMod("tornado")
registerMod("tornado", "exh_lr_t1", 1136)
registerMod("tornado", "exh_lr_t2", 1135)
registerMod("tornado", "fbmp_lr_t1", 1191)
registerMod("tornado", "fbmp_lr_t2", 1190)
registerMod("tornado", "rbmp_lr_t1", 1192)
registerMod("tornado", "rbmp_lr_t2", 1193)
registerMod("tornado", "wg_l_lr_t1", 1134)
registerMod("tornado", "wg_r_lr_t1", 1137)

registerMod("remington")
registerMod("remington", "rbmp_lr_rem1", 1180)
registerMod("remington", "rbmp_lr_rem2", 1179)
registerMod("remington", "fbmp_lr_rem2", 1185)
registerMod("remington", "rbmp_lr_rem2", 1178)
registerMod("remington", "misc_c_lr_rem1", 1100)
registerMod("remington", "misc_c_lr_rem2", 1123)
registerMod("remington", "misc_c_lr_rem3", 1125)
registerMod("remington", "exh_lr_rem1", 1126)
registerMod("remington", "exh_lr_rem2", 1127)
registerMod("remington", "wg_l_lr_rem1", 1122)
registerMod("remington", "wg_l_lr_rem2", 1106)
registerMod("remington", "wg_r_lr_rem1", 1101)
registerMod("remington", "wg_r_lr_rem2", 1124)

registerMod("flash")
registerMod("flash", "exh_a_f", 1046)
registerMod("flash", "exh_c_f", 1045)
registerMod("flash", "fbmp_a_f", 1153)
registerMod("flash", "fbmp_c_f", 1152)
registerMod("flash", "rbmp_a_f", 1150)
registerMod("flash", "rbmp_c_f", 1151)
registerMod("flash", "rf_a_f", 1054)
registerMod("flash", "rf_c_f", 1053)
registerMod("flash", "spl_a_f_r", 1049)
registerMod("flash", "spl_c_f_r", 1050)
registerMod("flash", "wg_l_a_f", 1047)
registerMod("flash", "wg_l_c_f", 1048)
registerMod("flash", "wg_r_a_f", 1051)
registerMod("flash", "wg_r_c_f", 1052)

registerMod("savanna")
registerMod("savanna", "exh_lr_sv1", 1129)
registerMod("savanna", "exh_lr_sv2", 1132)
registerMod("savanna", "fbmp_lr_sv1", 1189)
registerMod("savanna", "fbmp_lr_sv2", 1188)
registerMod("savanna", "rbmp_lr_sv1", 1187)
registerMod("savanna", "rbmp_lr_sv2", 1186)
registerMod("savanna", "rf_lr_sv1", 1130)
registerMod("savanna", "rf_lr_sv2", 1131)

registerMod("stratum")
registerMod("stratum", "exh_a_st", 1064)
registerMod("stratum", "exh_c_st", 1059)
registerMod("stratum", "fbmp_a_st", 1155)
registerMod("stratum", "fbmp_c_st", 1157)
registerMod("stratum", "rbmp_a_st", 1154)
registerMod("stratum", "rbmp_c_st", 1156)
registerMod("stratum", "rf_a_st", 1055)
registerMod("stratum", "rf_c_st", 1061)
registerMod("stratum", "spl_a_st_r", 1058)
registerMod("stratum", "spl_c_st_r", 1060)
registerMod("stratum", "wg_l_a_st", 1056)
registerMod("stratum", "wg_l_c_st", 1057)
registerMod("stratum", "wg_r_a_st", 1062)
registerMod("stratum", "wg_r_c_st", 1063)

registerMod("jester")
registerMod("jester", "exh_a_j", 1065)
registerMod("jester", "exh_c_j", 1066)
registerMod("jester", "fbmp_a_j", 1160)
registerMod("jester", "fbmp_c_j", 1173)
registerMod("jester", "rbmp_a_j", 1159)
registerMod("jester", "rbmp_c_j", 1161)
registerMod("jester", "rf_a_j", 1067)
registerMod("jester", "rf_c_j", 1068)
registerMod("jester", "spl_a_j_b", 1162)
registerMod("jester", "spl_c_j_b", 1158)
registerMod("jester", "wg_l_a_j", 1070)
registerMod("jester", "wg_r_a_j", 1071)
registerMod("jester", "wg_r_c_j", 1072)

registerMod("slamvan")
registerMod("slamvan", "bbb_lr_slv1", 1109)
registerMod("slamvan", "exh_lr_slv1", 1113)
registerMod("slamvan", "exh_lr_slv2", 1114)
registerMod("slamvan", "fbb_lr_slv1", 1115)
registerMod("slamvan", "fbb_lr_slv2", 1116)
registerMod("slamvan", "fbmp_lr_slv1", 1117)

registerMod("sultan")
registerMod("sultan", "exh_a_s", 1028)
registerMod("sultan", "exh_c_s", 1029)
registerMod("sultan", "fbmp_a_s", 1169)
registerMod("sultan", "fbmp_c_s", 1170)
registerMod("sultan", "rbmp_a_s", 1141)
registerMod("sultan", "rbmp_c_s", 1140)
registerMod("sultan", "rf_a_s", 1032)
registerMod("sultan", "rf_c_s", 1033)
registerMod("sultan", "spl_a_s_b", 1138)
registerMod("sultan", "spl_c_s_b", 1139)
registerMod("sultan", "wg_l_a_s", 1026)
registerMod("sultan", "wg_l_c_s", 1031)
registerMod("sultan", "wg_r_a_s", 1027)
registerMod("sultan", "wg_r_c_s", 1030)

registerMod("elegy")
registerMod("elegy", "exh_a_l", 1034)
registerMod("elegy", "exh_c_l", 1037)
registerMod("elegy", "fbmp_a_l", 1171)
registerMod("elegy", "fbmp_c_l", 1172)
registerMod("elegy", "rbmp_a_l", 1149)
registerMod("elegy", "rbmp_c_l", 1148)
registerMod("elegy", "spl_a_l_b", 1147)
registerMod("elegy", "spl_c_l_b", 1146)
registerMod("elegy", "wg_L_a_l", 1036)
registerMod("elegy", "wg_l_c_l", 1039)
registerMod("elegy", "wg_r_a_l", 1040)
registerMod("elegy", "wg_r_c_l", 1041)
registerMod("elegy", "exh_a_f", 1046)
registerMod("elegy", "exh_c_f", 1045)
registerMod("elegy", "fbmp_a_f", 1153)
registerMod("elegy", "fbmp_c_f", 1152)
registerMod("elegy", "rbmp_a_f", 1150)
registerMod("elegy", "rbmp_c_f", 1151)
registerMod("elegy", "rf_a_f", 1054)
registerMod("elegy", "rf_c_f", 1053)
registerMod("elegy", "spl_a_f_r", 1049)
registerMod("elegy", "spl_c_f_r", 1050)
registerMod("elegy", "wg_l_a_f", 1047)
registerMod("elegy", "wg_l_c_f", 1048)
registerMod("elegy", "wg_r_a_f", 1051)
registerMod("elegy", "wg_r_c_f", 1052)

registerMod("uranus")
registerMod("uranus", "exh_a_u", 1092)
registerMod("uranus", "exh_c_u", 1089)
registerMod("uranus", "fbmp_a_u", 1166)
registerMod("uranus", "fbmp_c_u", 1165)
registerMod("uranus", "rbmp_a_u", 1168)
registerMod("uranus", "rbmp_c_u", 1167)
registerMod("uranus", "rf_a_u", 1088)
registerMod("uranus", "rf_c_u", 1091)
registerMod("uranus", "spl_a_u_b", 1164)
registerMod("uranus", "spl_c_u_b", 1163)
registerMod("uranus", "wg_l_a_u", 1090)
registerMod("uranus", "wg_l_c_u", 1093)
registerMod("uranus", "wg_r_a_u", 1094)
registerMod("uranus", "wg_r_c_u", 1095)
