local screenX, screenY = guiGetScreenSize()

local imageSections = {
	[0] = {-1, -1},
	[1] = {0, -1},
	[2] = {0, 0},
	[3] = {-1, 0}
}

local crosshairData = {}
local weaponList = {
	[22] = {69, 40},
	[23] = {70, 500},
	[24] = {71, 200},
	[25] = {72, 200},
	[26] = {73, 200},
	[27] = {74, 200},
	[28] = {75, 50},
	[29] = {76, 250},
	[30] = {77, 200},
	[31] = {78, 200},
	[32] = {75, 50},
	[33] = {79, 300},
	[34] = {79, 300}
}

local currentWeapon = false
local crosshairMinSize = 2
local crosshairMaxSize = 32
local crosshairCurSize = crosshairMaxSize

function findSkillAccuracy(weaponId)
	local skillLevel = -1
	local skillName = "poor"

	if weaponList[weaponId] then
		skillLevel = getPedStat(localPlayer, weaponList[weaponId][1])

		if skillLevel >= 999 then
			skillName = "pro"
		else
			if skillLevel >= weaponList[weaponId][2] then
				skillName = "std"
			end
		end
	end

	if skillLevel == -1 then
		crosshairMinSize = crosshairMaxSize
		crosshairCurSize = crosshairMinSize
	else
		crosshairMinSize = crosshairMaxSize * (0.75 / getWeaponProperty(weaponId, skillName, "accuracy"))
		crosshairCurSize = crosshairMinSize
	end
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		crosshairData = getElementData(localPlayer, "crosshairData") or {0, 255, 255, 255}
		setPlayerHudComponentVisible("crosshair", tonumber(crosshairData[1]) == 0)
	end
)

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName)
		if dataName == "crosshairData" then
			crosshairData = getElementData(localPlayer, "crosshairData") or {0, 255, 255, 255}
			setPlayerHudComponentVisible("crosshair", tonumber(crosshairData[1]) == 0)
		end
	end
)

addEventHandler("onClientPlayerWeaponFire", localPlayer,
	function ()
		if currentWeapon then
			crosshairCurSize = crosshairMaxSize * 2
		end
	end
)

addEventHandler("onClientPlayerWeaponSwitch", getRootElement(),
	function ()
		local weaponId = getPedWeapon(localPlayer)

		currentWeapon = false

		if weaponId >= 22 and weaponId <= 33 then
			currentWeapon = weaponId
			findSkillAccuracy(weaponId)
			setPlayerHudComponentVisible("crosshair", tonumber(crosshairData[1]) == 0)
		else
			setPlayerHudComponentVisible("crosshair", true)
		end
	end
)

addEventHandler("onClientPreRender", getRootElement(),
	function (deltaTime)
		if crosshairCurSize > crosshairMinSize then
			crosshairCurSize = crosshairCurSize - deltaTime / 30
		else
			if crosshairCurSize < crosshairMinSize then
				crosshairCurSize = crosshairMinSize
			end
		end
	end
)

function round(num, decimal)
	decimal = decimal or 1
	return math.floor(num * decimal + 0.5) / decimal
end

addEventHandler("onClientRender", getRootElement(),
	function ()
		if crosshairData[1] and crosshairData[1] > 0 then
			if currentWeapon then
				if getPedControlState("aim_weapon") then
					if getPedTask(localPlayer, "secondary", 0) == "TASK_SIMPLE_USE_GUN" then
						local targetX, targetY, targetZ = getPedTargetEnd(localPlayer)

						if targetX then
							local target2dX, target2dY = getScreenFromWorldPosition(targetX, targetY, targetZ)

							if target2dX then
								local crosshairSize = round(crosshairCurSize)

								for i = 0, 3 do
									dxDrawImage(math.floor(target2dX + imageSections[i][1] * crosshairSize), math.floor(target2dY + imageSections[i][2] * crosshairSize), crosshairSize, crosshairSize, "files/" .. crosshairData[1] .. ".png", 90 * i, 0, 0, tocolor(crosshairData[2], crosshairData[3], crosshairData[4], 255))
								end
							end
						end
					end
				end
			end
		end
	end
)