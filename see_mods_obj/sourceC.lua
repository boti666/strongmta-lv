local mods = {}

local function registerMod(fileName, model)
	local id = #mods + 1

	model = model or fileName

	mods[id] = {}
	mods[id].model = tonumber(model)
	mods[id].path = fileName
end

registerMod("horgaszbot", 2993)
registerMod("barrier", 981)
registerMod("kanna", 363)
registerMod("pump", 3465)
registerMod("pisztoly", 330)
registerMod("emelo_block", 4830)
registerMod("emelo_kar", 4991)
registerMod("showroom", 9950)
registerMod("statue_v3stair", 13722)
registerMod("statue_v3", 13831)
registerMod("traffi_allo", 13759)
registerMod("uszo", 3917)
registerMod("int3int_carupg_int", 14776)
registerMod("int_kbsgarage05b", 14796)
registerMod("int_kbsgarage2", 14826)
registerMod("int3int_kbsgarage", 14783)
registerMod("int_kbsgarage3b", 14797)
registerMod("int_kbsgarage3", 14798)
registerMod("Cauldron1", 10115)
registerMod("Cauldron2", 10116)
registerMod("cellphone", 2967)
registerMod("axe", 321)
registerMod("speed_bump01", 10117)
registerMod("kb_tr_main", 14385)
registerMod("traffi", 951)
registerMod("slotm", 1515)
registerMod("slotm2", 2618)
registerMod("slotm3", 2640)
registerMod("slotm4", 1948)
registerMod("rbs1", 10139)
registerMod("rbs2", 10138)
registerMod("rbs3", 10137)
registerMod("rbs4", 10136)
registerMod("boja", 10135)
registerMod("8track", 13624)
registerMod("8track2", 13625)
registerMod("8track3", 13628)
registerMod("flex", 1636)
registerMod("texturacsere_id_13657", 13657)
registerMod("hajobelso", 9494)
registerMod("lv", 13725)
registerMod("cj_money_bags", 1550)
registerMod("letter", 6427)
registerMod("parcel", 2694)
registerMod("gunbox", 1271)
registerMod("billboards", 17281)
--registerMod("fekvo", 10869)
--registerMod("12916", 12916)

local function loadMod(id)
	if id then
		if mods and mods[id] then
			if fileExists("mods/" .. mods[id].path .. ".txd") then
				local txd = engineLoadTXD("mods/" .. mods[id].path .. ".txd", true)

				if txd then
					engineImportTXD(txd, mods[id].model)
				end
			end

			if fileExists("mods/" .. mods[id].path .. ".col") then
				local col = engineLoadCOL("mods/" .. mods[id].path .. ".col")

				if col then
					engineReplaceCOL(col, mods[id].model)
				end
			end

			if fileExists("mods/" .. mods[id].path .. ".dff") then
				local dff = engineLoadDFF("mods/" .. mods[id].path .. ".dff", mods[id].model)

				if dff then
					engineReplaceModel(dff, mods[id].model)
				end
			end
		end
	end
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k in pairs(mods) do
			loadMod(k)
		end
	end)
