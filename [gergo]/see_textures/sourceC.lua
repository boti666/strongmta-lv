local platebackTexture = dxCreateTexture("files/plateback.png", "dxt3")
local gokartTexture = dxCreateTexture("files/gokart.png", "dxt3")

local texturesTable = {
	ab_wuzibet = dxCreateTexture("files/ab_wuzibet.png", "dxt3"),
	airport1_64 = dxCreateTexture("files/airport1_64.png", "dxt3"),
	airport2_64 = dxCreateTexture("files/airport2_64.png", "dxt3"),
	ap_screens1 = dxCreateTexture("files/ap_screens1.png", "dxt3"),
	arch_plans = dxCreateTexture("files/arch_plans.png", "dxt3"),
	bloodpool_64 = dxCreateTexture("files/bloodpool_64.png", "dxt3"),
	BLUE_FABRIC = dxCreateTexture("files/BLUE_FABRIC.png", "dxt3"),
	bubbles = dxCreateTexture("files/bubbles.png", "dxt3"),
	cj_binders = dxCreateTexture("files/cj_binders.png", "dxt3"),
	CJ_BS_MENU5 = dxCreateTexture("files/CJ_BS_MENU5.png", "dxt3"),
	cj_sheetmetal2 = dxCreateTexture("files/cj_sheetmetal2.png", "dxt3"),
	CJ_SPRUNK_DIRTY = dxCreateTexture("files/CJ_SPRUNK_DIRTY.png", "dxt3"),
	CJ_SPRUNK_FRONT2 = dxCreateTexture("files/CJ_SPRUNK_FRONT2.png", "dxt3"),
	CJ_SPRUNK_FRONT2LOD = dxCreateTexture("files/CJ_SPRUNK_FRONT2LOD.png", "dxt3"),
	conc_slabgrey_256128 = dxCreateTexture("files/conc_slabgrey_256128.png", "dxt3"),
	coronastar = dxCreateTexture("files/coronastar.png", "dxt3"),
	fireball6 = dxCreateTexture("files/fireball6.png", "dxt3"),
	gen_monitor = dxCreateTexture("files/gen_monitor.png", "dxt3"),
	kmb_atm_sign = dxCreateTexture("files/kmb_atm_sign.png", "dxt3"),
	LAInside_Tracksign1 = dxCreateTexture("files/LAInside_Tracksign1.png", "dxt3"),
	LAInside_Tracksign2 = dxCreateTexture("files/LAInside_Tracksign2.png", "dxt3"),
	michelle_car1 = dxCreateTexture("files/michelle_car1.png", "dxt3"),
	michelle_car3 = dxCreateTexture("files/michelle_car3.png", "dxt3"),
	mp_cop_ceilingtile = dxCreateTexture("files/mp_cop_ceilingtile.png", "dxt3"),
	mp_cop_chief = dxCreateTexture("files/mp_cop_chief.png", "dxt3"),
	mp_cop_signs = dxCreateTexture("files/mp_cop_signs.png", "dxt3"),
	mp_cop_tile = dxCreateTexture("files/mp_cop_tile.png", "dxt3"),
	mp_cop_wall = dxCreateTexture("files/mp_cop_wall.png", "dxt3"),
	mp_cop_wallpink = dxCreateTexture("files/mp_cop_wallpink.png", "dxt3"),
	notice01 = dxCreateTexture("files/notice01.png", "dxt3"),
	otb_bigsignf = dxCreateTexture("files/otb_bigsignf.png", "dxt3"),
	otb_numbers = dxCreateTexture("files/otb_numbers.png", "dxt3"),
	--siteM16 = dxCreateTexture("files/siteM16.png", "dxt3"),
	sjmlode93 = dxCreateTexture("files/sjmlode93.png", "dxt3"),
	--smoke = dxCreateTexture("files/smoke.png", "dxt3"),
	--smokeII_3 = dxCreateTexture("files/smokeII_3.png", "dxt3"),
	SNIPERcrosshair = dxCreateTexture("files/SNIPERcrosshair.png", "dxt3"),
	vehiclelights128 = dxCreateTexture("files/vehiclelights128.png", "dxt3"),
	vehiclelightson128 = dxCreateTexture("files/vehiclelightson128.png", "dxt3"),
	vehicleshatter128 = dxCreateTexture("files/vehicleshatter128.png", "dxt3"),
	waterclear256 = dxCreateTexture("files/waterclear256.png", "dxt3"),
	plateback1 = platebackTexture,
	plateback2 = platebackTexture,
	plateback3 = platebackTexture,
	vegasmotelsign01_128 = dxCreateTexture("files/forlease_law.png", "dxt3"),
	bobobillboard1 = dxCreateTexture("files/bobobillboard1.png", "dxt3"),
	lamp_shad_64 = dxCreateTexture("files/lamp_shad_64.png", "dxt3"),
	headlight = dxCreateTexture("files/headlight.png", "dxt3"),
	headlight1 = dxCreateTexture("files/headlight1.png", "dxt3"),
	semi1dirty = dxCreateTexture("files/semi1dirty.png", "dxt3"),
	dirtringtex1_256 = gokartTexture,
	dirtringtex2_256 = gokartTexture,
	homies_1 = gokartTexture,
	semi3dirty = gokartTexture,
	dirtringtex3_256 = dxCreateTexture("files/stadion.png", "dxt3"),
	mp_aldeasign = dxCreateTexture("files/mp_aldeasign.png", "dxt3"),
	xtreme_prolaps = dxCreateTexture("files/xtreme_prolaps.png", "dxt3"),
	benson92adverts256 = dxCreateTexture("files/benson92adverts256.png", "dxt3"),
	cj_painting30 = dxCreateTexture("files/cj_painting30.png", "dxt3"),
	cj_painting36 = dxCreateTexture("files/cj_painting36.png", "dxt3"),
	cj_painting19 = dxCreateTexture("files/cj_painting19.png", "dxt3"),
	cj_painting1 = dxCreateTexture("files/cj_painting1.png", "dxt3"),
	cj_painting7 = dxCreateTexture("files/cj_painting7.png", "dxt3"),
	prolaps02 = dxCreateTexture("files/prolaps02.png", "dxt3"),
	--collisionsmoke = dxCreateTexture("files/collisionsmoke.png", "dxt3"),
	particleskid = dxCreateTexture("files/particleskid.png", "dxt3"),
}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(texturesTable) do
			local shaderElement = dxCreateShader("files/texturechanger.fx")

			if shaderElement then
				dxSetShaderValue(shaderElement, "gTexture", v)
				engineApplyShaderToWorldTexture(shaderElement, k)
			end
		end
	end
)
