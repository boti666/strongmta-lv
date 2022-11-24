local availableWeapons = {
	ak47 = 355,
	cane = 326,
	chnsaw = 341,
	chromegun = 349,
	colt45 = 346,
	desert_eagle = 348,
	flower = 325,
	grenade = 342,
	katana = 339,
	knifecur = 335,
	m4 = 356,
	mp5lng = 353,
	rifle = 357,
	shotgspa = 351,
	silenced = 347,
	sniper = 358,
	tec9 = 372,
	uzi = 352,
	vibrator = 323
}

local txd
local dff

for k, v in pairs(availableWeapons) do
	txd = engineLoadTXD("files/" .. k .. ".txd")

	if txd then
		dff = engineLoadDFF("files/" .. k .. ".dff")

		if dff then
			engineImportTXD(txd, v)
			engineReplaceModel(dff, v)
		end
	end
end
