local tickSync = 0

addEvent("getTickSyncKillmsg", true)
addEventHandler("getTickSyncKillmsg", getRootElement(),
	function (tick)
		tickSync = tick - getRealTime().timestamp
	end)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		triggerServerEvent("getTickSyncKillmsg", localPlayer)
	end)

local quitReasons = {
	unknown = "Ismeretlen",
	quit = "Lecsatlakozott",
	kicked = "Kirúgva",
	banned = "Kitiltva",
	["bad connection"] = "Rossz kapcsolat",
	["timed out"] = "Időtúllépés"
}

addEventHandler("onClientPlayerQuit", getRootElement(),
	function (reason)
		if getElementData(source, "loggedIn") then
			local localX, localY, localZ = getElementPosition(localPlayer)
			local playerX, playerY, playerZ = getElementPosition(source)
			local distance = getDistanceBetweenPoints3D(localX, localY, localZ, playerX, playerY, playerZ)

			if distance <= 20 then
				outputChatBox(getElementData(source, "visibleName"):gsub("_", " ") .. " kilépett a közeledben. [" .. quitReasons[string.lower(reason)] .. "] Távolság: " .. math.floor(distance) .. " yard", 215, 89, 89, true)
			end
		end
	end)

local deathTypes = {
	[19] = "robbanás",
	[37] = "égés",
	[49] = "autóbaleset",
	[50] = "autóbaleset",
	[51] = "robbanás",
	[52] = "elütötték",
	[53] = "fulladás",
	[54] = "esés",
	[55] = "unknown",
	[56] = "verekedés",
	[57] = "fegyver",
	[59] = "tank",
	[63] = "robbanás",
	[0] = "verekedés"
}

local weaponNames = {
	Rammed = "autóbaleset",
	shovel = "Csákány",
	["colt 45"] = "Glock 17",
	silenced = "Hangtompítós Colt-45",
	rifle = "Vadász puska",
	sniper = "Remington 700",
	mp5 = "P90"
}

addEventHandler("onClientPlayerWasted", getRootElement(),
	function (killer, weapon, bodypart)
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			local timestamp = getRealTime().timestamp + tickSync
			local time = getRealTime(timestamp)

			time = "[" .. string.format("%04d.%02d.%02d %02d:%02d:%02d", time.year + 1900, time.month + 1, time.monthday, time.hour, time.minute, time.second) .. "] "

			local killedName = getElementData(source, "visibleName"):gsub("_", " ")
			local deathText = ""
			local customText = getElementData(source, "customDeath") or getElementData(source, "deathReason")

			if customText then
				deathText = " [" .. customText .. "]"
			elseif tonumber(weapon) then
				deathText = deathTypes[weapon]

				if not deathText then
					local weaponName = getWeaponNameFromID(weapon)

					if weaponNames[weaponName] then
						weaponName = weaponNames[weaponName]

						if weaponName == "autóbaleset" then
							deathText = " [autóbaleset]"
						else
							deathText = " [" .. weaponName .. "]"
						end
					else
						deathText = " [" .. weaponName .. "]"
					end

					if bodypart == 9 then
						deathText = deathText .. " (fejlövés)"
					end
				else
					deathText = " [" .. deathText .. "]"
				end
			end

			if isElement(killer) then
				local killerType = getElementType(killer)

				if killerType == "player" then
					if exports.see_groups:isPlayerInGroup(killer, 40) then -- hitman
						return
					end
				end

				local killerName = ""

				if killerType == "player" then
					killerName = getPlayerName(killer, "visibleName"):gsub("_", " ")
				elseif killerType == "vehicle" then
					local vehdriver = getVehicleController(killer)

					if vehdriver then
						killerName = getElementData(vehdriver, "visibleName"):gsub("_", " ")
					else
						killerName = "Egy jármű"
					end
				end

				outputChatBox(time .. killerName .. " megölte " .. killedName .. "-t." .. deathText, 175, 175, 175)
			else
				outputChatBox(time .. killedName .. " meghalt." .. deathText, 175, 175, 175)
			end
		end
	end)