local collisions = {
	[1] = engineLoadCOL("files/kresz.col"),
	[2] = engineLoadCOL("files/speed.col"),
	[3] = engineLoadCOL("files/border.col")
}

local mods = {
	{"kresz5", "kresz_ti01", 9485},
	{"kresz5", "kresz_ti17", 9486},
	{"kresz5", "kresz_ti25", 9487},
	{"kresz5", "kresz_ti26", 9488},
	{"border", "speed", 9489},
	{"kresz5", "kresz_ti28", 9490},
	{"speed30", "speed", 9491},
	{"speed50", "speed", 9492},
	{"speed70", "speed", 9493},
	{"speed90", "speed", 9496},
	{"speed100", "speed", 9497},
	{"speed110", "speed", 9498},
	{"speed120", "speed", 9499},
	{"kresz5", "kresz_ti45", 9500},
	{"kresz1", "kresz_ti48", 9501},
	{"kresz1", "kresz_ti50", 9502},
	{"kresz5", "kresz_ti51", 9503},
	{"kresz6", "kresz_ve01", 9504},
	{"kresz6", "kresz_ve02", 9505},
	{"kresz6", "kresz_ve03", 9506},
	{"kresz6", "kresz_ve04", 9512},
	{"kresz6", "kresz_ve07", 9513},
	{"kresz6", "kresz_ve08", 9520},
	{"kresz6", "kresz_ve09", 9521},
	{"kresz6", "kresz_ve13", 9522},
	{"kresz6", "kresz_ve14", 9636},
	{"kresz6", "kresz_ve16", 9637},
	{"kresz6", "kresz_ve17", 9638},
	{"kresz6", "kresz_ve18", 9639},
	{"kresz6", "kresz_ve19", 9640},
	{"kresz6", "kresz_ve20", 9641},
	{"kresz6", "kresz_ve22", 9642},
	{"kresz6", "kresz_ve28", 9643},
	{"kresz6", "kresz_ve29", 9644},
	{"kresz6", "kresz_ve30", 9645},
	{"kresz6", "kresz_ve31", 9646},
	{"kresz6", "kresz_ve32", 9647},
	{"kresz6", "kresz_ve37", 9648},
	{"kresz5", "kresz_us01", 9699},
	{"kresz5", "kresz_us02", 9700},
	{"kresz5", "kresz_us03", 9701},
	{"kresz5", "kresz_us04", 9702},
	{"kresz5", "kresz_us05", 9703},
	{"kresz5", "kresz_us06", 9704},
	{"kresz5", "kresz_us07", 9705},
	{"kresz1", "kresz_ut01", 9706},
	{"kresz1", "kresz_ut02", 9707},
	{"kresz1", "kresz_ut03", 9708},
	{"kresz1", "kresz_ut04", 9709},
	{"kresz1", "kresz_tj01", 9710},
	{"kresz1", "kresz_tj03", 9711},
	{"kresz1", "kresz_tj05", 9712},
	{"kresz1", "kresz_tj11", 9713},
	{"kresz1", "kresz_tj16", 9714},
	{"kresz1", "kresz_tj17", 9715},
	{"kresz1", "kresz_tj18", 9716},
	{"kresz1", "kresz_tj19", 9717},
	{"kresz1", "kresz_tj23", 9718},
	{"kresz1", "kresz_tj32", 9719},
	{"kresz1", "kresz_tj33", 9720},
	{"kresz1", "kresz_tj38", 9721},
	{"kresz3", "kresz_es01", 9722},
	{"kresz4", "kresz_es02", 9723},
	{"kresz5", "kresz_es03", 9724},
	{"kresz1", "kresz_es04", 9725},
	{"kresz2", "kresz_fu01", 9726},
	{"kresz2", "kresz_fu02", 9727},
}

local loadedTXDs = {}
local loadedDFFs = {}

function addkreszobject(dffName, txdName, model)
	model = tonumber(model)

	removeWorldModel(model, 10000, 0, 0, 0)

	local txd = false
	local path = "files/" .. tostring(txdName) .. ".txd"

	if loadedTXDs[path] then
		txd = loadedTXDs[path]
	else
		txd = engineLoadTXD(path, model)
		loadedTXDs[path] = txd
	end

	engineImportTXD(txd, model)

	local col = collisions[1]

	if model == 9489 then
		col = collisions[3]
	else
		if model >= 9491 then
			col = collisions[2]
		end
	end

	engineReplaceCOL(col, model)
	engineSetModelLODDistance(model, 150)

	local dff = false
	local path = "files/" .. tostring(dffName) .. ".dff"

	if loadedDFFs[path] then
		dff = loadedDFFs[path]
	else
		dff = engineLoadDFF(path, model)
		loadedDFFs[path] = dff
	end

	engineReplaceModel(dff, model)
end

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		outputChatBox("Kresz rendszer leállítva (kresztablak modelset)!")
	end)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		engineSetAsynchronousLoading(true, true)
		setTrafficLightState(9)

		removeWorldModel(1262, 10000, 0, 0, 0)
		removeWorldModel(1283, 10000, 0, 0, 0)
		removeWorldModel(1284, 10000, 0, 0, 0)
		removeWorldModel(1350, 10000, 0, 0, 0)
		removeWorldModel(1315, 10000, 0, 0, 0)
		--removeWorldModel(3516, 10000, 0, 0, 0)
		removeWorldModel(3855, 10000, 0, 0, 0)
		removeWorldModel(1352, 10000, 0, 0, 0)
		removeWorldModel(1351, 10000, 0, 0, 0)
		removeWorldModel(1676, 10000, 0, 0, 0)
		removeWorldModel(1686, 10000, 0, 0, 0)
		removeWorldModel(1244, 10000, 0, 0, 0)
		removeWorldModel(3465, 10000, 0, 0, 0)

		for i = 1, #mods do
			addkreszobject(mods[i][1], mods[i][2], mods[i][3])
		end
	end)