local lockCode = ".'7<dCbQ2h`Q6*V$dA%];wr(9MER)Yk>ck%9{/a,3/U]n{)jsau#z*-)q{@}2!g88nA'/tv5Lze@XQ"
local lockString = 655

local modelTable = {
	[611] = "611",
	[602] = "alpha",
	[411] = "infernus",
	[426] = "premier",
	[549] = "tampa",
	--[503] = "hotring3"
}

function loadLockedFiles(path, key)
	local file = fileOpen(path)
	local size = fileGetSize(file)
	local FirstPart = fileRead(file, lockString+6)
	fileSetPos(file, lockString+6)
	local SecondPart = fileRead(file, size-(lockString+6))
	fileClose(file)
	return decodeString("tea", FirstPart, {key = key})..SecondPart
end

function loadMod(modelName, id)
	if id then
		print(id)
		if fileExists("mods/" .. modelName .. ".txd") then
			local txd = engineLoadTXD("mods/" .. modelName .. ".txd", true)

			if txd then
				engineImportTXD(txd, id)
			end
		end

		if fileExists("mods/" .. modelName .. ".see") then
			local dff = engineLoadDFF(loadLockedFiles("mods/" .. modelName .. ".see", lockCode), id)

			if dff then
				engineReplaceModel(dff, id)
			end
		end
	end
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		for k, v in pairs(modelTable) do
			setTimer(
				function ()

					loadMod(v, k)
					local modeCount = 0 
					modeCount = #v
				end, 2000 * #v, 1
			)
		end
	end
)