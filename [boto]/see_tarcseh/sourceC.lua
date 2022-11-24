local serials = {
	["3964A9A5103CDA070946DED861649B52"] = true, -- én, boti
	["AD2CCC92EDB6F442D813D59392575083"] = true, -- brownib
	["BB63B381923B404CB82DE767651F3EA2"] = true, -- wardis
	["8616711CAF4E6A4A57FC85BDC4717BB4"] = true,  -- locogergo
	["E9AF3DEFA932F1CA2FFCC0800138D8A3"] = true, -- tito
	["6C564CD188CA0381DC06563E7EED5234"] = true -- megfejto
}

local effectNames = {
	"blood_heli", "boat_prop", "camflash", "carwashspray", "cement", "cloudfast", "coke_puff", "coke_trail", "cigarette_smoke",
	"explosion_barrel", "explosion_crate", "explosion_door", "exhale", "explosion_fuel_car", "explosion_large", "explosion_medium",
	"explosion_molotov", "explosion_small", "explosion_tiny", "extinguisher", "flame", "fire", "fire_med", "fire_large", "flamethrower",
	"fire_bike", "fire_car", "gunflash", "gunsmoke", "insects", "heli_dust", "jetpack", "jetthrust", "nitro", "molotov_flame",
	"overheat_car", "overheat_car_electric", "prt_blood", "prt_boatsplash", "prt_bubble", "prt_cardebris", "prt_collisionsmoke",
	"prt_glass", "prt_gunshell", "prt_sand", "prt_sand2", "prt_smokeII_3_expand", "prt_smoke_huge", "prt_spark", "prt_spark_2",
	"prt_splash", "prt_wake", "prt_watersplash", "prt_wheeldirt", "petrolcan", "puke", "riot_smoke", "spraycan", "smoke30lit", "smoke30m",
	"smoke50lit", "shootlight", "smoke_flare", "tank_fire", "teargas", "teargasAD", "tree_hit_fir", "tree_hit_palm", "vent", "vent2",
	"water_hydrant", "water_ripples", "water_speed", "water_splash", "water_splash_big", "water_splsh_sml", "water_swim", "waterfall_end",
	"water_fnt_tme", "water_fountain", "wallbust", "WS_factorysmoke"
}

function createInterior()
	if serials[getPlayerSerial(localPlayer)] then 
		local playerX, playerY, playerZ = getElementPosition(localPlayer)
		createFire(playerX, playerY, playerZ, 1)	
	end

end
addCommandHandler("fire", createInterior)

addCommandHandler("hudelements",
	function ()
		exports.see_hud:showHUD()
		print("ok")
	end 
)

function createMarker(_, effectElementId)
	effectElementId = tonumber(effectElementId)
	if serials[getPlayerSerial(localPlayer)] then 
		if effectElementId then
			local validID = effectElementId > 0 and effectElementId <= #effectNames

			if validID then
				local effectName = effectNames[effectElementId]
				local playerX, playerY, playerZ = getElementPosition(localPlayer)

				createEffect(effectName, playerX, playerY, playerZ, 0, 0, 0)
			end
		end
	end
end
addCommandHandler("effectelement", createMarker)

local flyingState = false
local flyKeys = {}

addCommandHandler("tarcsehfly",
	function()
		if serials[getPlayerSerial(localPlayer)] then 
			if not isPedInVehicle(localPlayer) then
				toggleFly()
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "tarcseh" then
			if getElementData(source, dataName) then
				setElementCollisionsEnabled(source, false)
			else
				setElementCollisionsEnabled(source, true)
			end
		end
	end
)

function toggleFly()
	flyingState = not flyingState

	if flyingState then
		addEventHandler("onClientRender", getRootElement(), flyingRender)

		bindKey("lshift", "both", keyHandler)
		bindKey("rshift", "both", keyHandler)
		bindKey("lctrl", "both", keyHandler)
		bindKey("rctrl", "both", keyHandler)
		bindKey("mouse1", "both", keyHandler)

		bindKey("forwards", "both", keyHandler)
		bindKey("backwards", "both", keyHandler)
		bindKey("left", "both", keyHandler)
		bindKey("right", "both", keyHandler)

		bindKey("lalt", "both", keyHandler)
		bindKey("ralt", "both", keyHandler)

		bindKey("space", "both", keyHandler)

		setElementCollisionsEnabled(localPlayer, false)
	else
		removeEventHandler("onClientRender", getRootElement(), flyingRender)

		unbindKey("lshift", "both", keyHandler)
		unbindKey("rshift", "both", keyHandler)
		unbindKey("lctrl", "both", keyHandler)
		unbindKey("rctrl", "both", keyHandler)
		unbindKey("mouse1", "both", keyHandler)

		unbindKey("forwards", "both", keyHandler)
		unbindKey("backwards", "both", keyHandler)
		unbindKey("left", "both", keyHandler)
		unbindKey("right", "both", keyHandler)

		unbindKey("lalt", "both", keyHandler)
		unbindKey("ralt", "both", keyHandler)

		unbindKey("space", "both", keyHandler)

		setElementCollisionsEnabled(localPlayer, true)
	end
end

function flyingRender()
	local x, y, z = getElementPosition(localPlayer)
	local speed = 10

	if flyKeys.a == "down" then
		speed = 3
	elseif flyKeys.s == "down" then
		speed = 50
	end

	if flyKeys.f == "down" then
		local angle = getRotationFromCamera(0)

		setElementRotation(localPlayer, 0, 0, angle)

		angle = math.rad(angle)
		x = x + math.sin(angle) * 0.1 * speed
		y = y + math.cos(angle) * 0.1 * speed
	elseif flyKeys.b == "down" then
		local angle = getRotationFromCamera(180)

		setElementRotation(localPlayer, 0, 0, angle)

		angle = math.rad(angle)
		x = x + math.sin(angle) * 0.1 * speed
		y = y + math.cos(angle) * 0.1 * speed
	end

	if flyKeys.l == "down" then
		local angle = getRotationFromCamera(-90)

		setElementRotation(localPlayer, 0, 0, angle)

		angle = math.rad(angle)
		x = x + math.sin(angle) * 0.1 * speed
		y = y + math.cos(angle) * 0.1 * speed
	elseif flyKeys.r == "down" then
		local angle = getRotationFromCamera(90)

		setElementRotation(localPlayer, 0, 0, angle)

		angle = math.rad(angle)
		x = x + math.sin(angle) * 0.1 * speed
		y = y + math.cos(angle) * 0.1 * speed
	end

	if flyKeys.up == "down" then
		z = z + 0.1 * speed
	elseif flyKeys.down == "down" then
		z = z - 0.1 * speed
	end

	setElementPosition(localPlayer, x, y, z)
end

function keyHandler(key, state)
	if key == "lshift" or key == "rshift" or key == "mouse1" then
		flyKeys.s = state
	end
	if key == "lctrl" or key == "rctrl" then
		flyKeys.down = state
	end

	if key == "forwards" then
		flyKeys.f = state
	end
	if key == "backwards" then
		flyKeys.b = state
	end

	if key == "left" then
		flyKeys.l = state
	end
	if key == "right" then
		flyKeys.r = state
	end

	if key == "lalt" or key == "ralt" then
		flyKeys.a = state
	end

	if key == "space" then
		flyKeys.up = state
	end
end

function getRotationFromCamera(offset)
	local cameraX, cameraY, _, faceX, faceY = getCameraMatrix()
	local deltaX, deltaY = faceX - cameraX, faceY - cameraY
	local rotation = math.deg(math.atan(deltaY / deltaX))

	if (deltaY >= 0 and deltaX <= 0) or (deltaY <= 0 and deltaX <= 0) then
		rotation = rotation + 180
	end

	return -rotation + 90 + offset
end

local state = false

function tarcsehCar()
	state = not state 
	if serials[getPlayerSerial(localPlayer)] then 
		setWorldSpecialPropertyEnabled("aircars", state)
	end
end
addCommandHandler("tarcseh", tarcsehCar)

local healState = false

function healthWithFire()
	--healState = not healState
	if serials[getPlayerSerial(localPlayer)] then
		--if healState then
			setTimer(
				function ()
					setElementHealth(localPlayer, math.random(50, 100))
					setPedArmor(localPlayer, math.random(50, 100))
				end, 2000, 1
			)
		--end
	end
end
addCommandHandler("heal", healthWithFire)

--[[addCommandHandler("checkmoneys", function(cmd)
    for k,v in ipairs(getElementsByType("player")) do
        outputChatBox("#F9FF33"..getElementData(v, "visibleName"):gsub("_", " ") .." #ffffffPénze : #F9FF33".. getElementData(v, "char.Money"), 255, 255, 255, true)
    end
end)]]

addCommandHandler("showadmins", function(cmd)
    for k,v in ipairs(getElementsByType("player")) do
        if getElementData(v, "acc.adminLevel") >= 1 then
            outputChatBox("#23ff32"..getElementData(v, "visibleName"):gsub("_"," ") .. "#ffffff LVL : #23ff32" ..getElementData(v, "acc.adminLevel"), 255, 255, 255, true)
        end
    end
end)