local lockCode = "HAUSGd8g1hjasgdAZJSbtddcx76F67RDA%/SEDASoidjAKLSjDKLAJsdNJXKY"
local lockString = 655
function loadLockedFiles(path, key)
	local file = fileOpen(path)
	local size = fileGetSize(file)
	local FirstPart = fileRead(file, lockString+6)
	fileSetPos(file, lockString+6)
	local SecondPart = fileRead(file, size-(lockString+6))
	fileClose(file)
	return decodeString("tea", FirstPart, {key = key})..SecondPart
end

function loadSkinMod(path, model)
	print("ok")
	if fileExists(path .. "/" .. model .. ".txd") then
		print("txd match")
		local txd = engineLoadTXD(path .. "/" .. model .. ".txd")

		if txd then
			print("if txd match")
			engineImportTXD(txd, model)
		end
	end

	if fileExists(path .. "/" .. model .. ".see") then
		print("if dff match")
		local dff = engineLoadDFF(loadLockedFiles("mods/" .. model .. ".see", lockCode))
		iprint(dff)

		if fileExists(path .. "/" .. model .. ".see") then
			engineReplaceModel(dff, model)
		end
	end
end

loadSkinMod("mods", 180)
loadSkinMod("mods", 291)
loadSkinMod("mods", 292)