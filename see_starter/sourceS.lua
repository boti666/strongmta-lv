local resources = {
	"see_database",
	"see_infinity",
	"see_logs",
	--"see_anticheat",
	"see_core",
	"see_performance",
	"see_remove",
	"see_water",
	"see_maps",
	"see_accounts",
	"see_binco",
	"see_controls",
	"see_boneattach",
	"see_administration",
	"see_starter",
	"see_newdebug",
	"see_workaround",
	"see_hud",
	"see_dynamicsky",
	"see_weather",
	"see_newcars",
	"see_vehiclenames",
	"see_drm",
	"see_mods_veh",
	"see_mods_skin",
	"see_names",
	"see_chat",
	"see_items",
	"see_jobhandler",
	"see_jobvehicle",
	"see_groups",
	"see_weapontuning",
	"see_weaponmods",
	"see_weaponsounds",
	"see_weaponnew",
	"see_glue",
	"see_interiors",
	"see_interioredit",
	"see_regoffice",
	"see_vehiclepanel",
	"see_vehicles",
	"see_fuel",
	"see_minigames",
	"see_damage",
	"see_death",
	"see_mods_obj",
	"see_tempomat",
	"see_killmsg",
	"see_notifications",
	"see_radio",
	"see_3dtext",
	"see_shader",
	"see_dashboard",
	"see_autobroadcast",
	"see_premiumshop",
	"see_carshop",
	"see_boatshop",
	"see_animals",
	"see_borders",
	"see_jail",
	"see_burnout",
	"see_windmill",
	"see_job_factory",
	"see_job_truck",
	"see_job_post",
	"see_job_pizza",
	"see_case",
	"see_job_bus",
	"see_license",
	"see_speedbump",
	"see_kresztablak",
	"see_textures",
	"see_impound",
	"see_peds",
	"see_tuning",
	"see_tuningcomp",
	"see_spinner",
	"see_paintjob",
	"see_headlight",
	"see_wheels",
	"see_wheeltexture",
	"see_customhorn",
	"see_mdc",
	"see_groupscripting",
	"see_groupradio",
	"see_sound",
	"see_casino",
	"see_roulette",
	"see_platina",
	"see_fortunewheel",
	"see_blackjack",
	"see_poker",
	"see_lottery",
	"see_cveh",
	"see_shootingrange",
	"see_weaponskill",
	"see_clothesshop",
	"see_animations",
	"see_bank",
	"see_mechanic",
	"see_gates",
	"see_shark",
	"see_crosshair",
	"see_ad",
	"see_drag",
	"see_fishing",
	"see_tuningcomp",
	"see_flashbang",
	"lv_chat",
	"lv_groups",
	"lv_items",
	"lv_publicphone",
	"see_backfire",
	"old_animations",
	"see_utils",
	"lv_hud",
	"see_adminpanel",
	"see_attach",
	"see_metaldetector",
	"see_driveby",
	"see_botondvision",
	"see_botondvision2",
	"see_botondvision3",
	"see_carrental",
	"lv_core"
}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		local connection = false
		local started = 0

		outputDebugString("[StrongMTA]: Starting resources...")

		for k, v in ipairs(resources) do
			local resname = getResourceFromName(v)
			local state = startResource(resname)

			if string.find(v, "database") and state then
				connection = exports[v]:getConnection()
			end

			if not connection then
				break
			end

			if state then
				started = started + 1
			end
		end

		if not connection then
			outputDebugString("[StrongMTA]: Unable to connect to the database, operation canceled!")
			cancelEvent(true, "Unable to connect to the database")
		else
			outputDebugString("[StrongMTA]: " .. started .. " resource(s) started.")
		end
	end
)

function getResourceList()
	return resources
end
