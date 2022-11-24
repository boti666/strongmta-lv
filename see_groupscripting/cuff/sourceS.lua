addCommandHandler("auncuff",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not targetPlayer then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", sourcePlayer, 255, 255, 255, true)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if getElementData(targetPlayer, "cuffed") then
						triggerEvent("**ÄÄ**÷×}>*'{'>*}", sourcePlayer, targetPlayer, "emosskiddaj")
						exports.see_logs:logCommand(sourcePlayer, commandName, {targetName})
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos nincs megbilincselve.", sourcePlayer, 255, 255, 255, true)
					end
				end
			end
		end
	end)

addCommandHandler("acuff",
	function (sourcePlayer, commandName, targetPlayer)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not targetPlayer then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", sourcePlayer, 255, 255, 255, true)
			else
				targetPlayer, targetName = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					if not getElementData(targetPlayer, "cuffed") then
						triggerEvent("**ÄÄ**÷×}>*'{'>*}", sourcePlayer, targetPlayer, "emosskiddaj")
						exports.see_logs:logCommand(sourcePlayer, commandName, {targetName})
					else
						outputChatBox("#d75959[StrongMTA]: #ffffffA kiválasztott játékos már meg van bilincselve.", sourcePlayer, 255, 255, 255, true)
					end
				end
			end
		end
	end)

addCommandHandler("cuff",
	function (sourcePlayer, commandName, targetPlayer)
		if exports.see_groups:isPlayerHavePermission(sourcePlayer, "cuff") then
			if not targetPlayer then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", sourcePlayer, 255, 255, 255, true)
			else
				targetPlayer = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer and targetPlayer ~= sourcePlayer then
					local sourcePosX, sourcePosY, sourcePosZ = getElementPosition(sourcePlayer)
					local targetPosX, targetPosY, targetPosZ = getElementPosition(targetPlayer)

					local sourceInterior = getElementInterior(sourcePlayer)
					local targetInterior = getElementInterior(targetPlayer)

					local sourceDimension = getElementDimension(sourcePlayer)
					local targetDimension = getElementDimension(targetPlayer)

					local distance = getDistanceBetweenPoints3D(sourcePosX, sourcePosY, sourcePosZ, targetPosX, targetPosY, targetPosZ)

					if distance <= 5 and sourceInterior == targetInterior and sourceDimension == targetDimension then
						triggerEvent("**ÄÄ**÷×}>*'{'>*}", sourcePlayer, targetPlayer, "emosskiddaj")
					else
						outputChatBox("#d75959[Bilincs]: #ffffffA kiválasztott játékos túl messze van tőled.", sourcePlayer, 255, 255, 255, true)
					end
				end
			end
		end
	end
)

addEvent("**ÄÄ**÷×}>*'{'>*}", true)
addEventHandler("**ÄÄ**÷×}>*'{'>*}", getRootElement(),
	function (targetPlayer, code)
		if code ~= "emosskiddaj" then 
			return iprint(source, targetPlayer)
		end
		print("asd")
		if isElement(source) and isElement(targetPlayer) then
			if exports.see_groups:isPlayerOfficer(source) and exports.see_groups:isPlayerHavePermission(source, "cuff") then 
				local canCuff = false

				local sourcePosX, sourcePosY, sourcePosZ = getElementPosition(source)
				local targetPosX, targetPosY, targetPosZ = getElementPosition(targetPlayer)

				if getDistanceBetweenPoints3D(sourcePosX, sourcePosY, sourcePosZ, targetPosX, targetPosY, targetPosZ) > 3 then
					return
				end

				if exports.see_groups:isPlayerOfficer(source) then
					canCuff = true
				end

				if not (exports.see_items:hasItem(source, 118) and exports.see_groups:isPlayerHavePermission(source, "cuff")) then 
					canCuff = false
				end

					
				if not canCuff then
					return
				end

				--if client ~= source then
				--	return
				--end

				local state = not getElementData(targetPlayer, "cuffed")

				setElementData(targetPlayer, "cuffed", state)

				if not state then
					setElementData(targetPlayer, "visz", false)
				end
				
				if state then
					exports.see_controls:toggleControl(targetPlayer, {"forwards", "backwards", "left", "right", "jump", "crouch", "aim_weapon", "fire", "enter_exit", "enter_passenger"}, false)
				else
					exports.see_controls:toggleControl(targetPlayer, {"forwards", "backwards", "left", "right", "jump", "crouch", "aim_weapon", "fire", "enter_exit", "enter_passenger"}, true)
				end

				local targetName = getElementData(targetPlayer, "visibleName"):gsub("_", " ")
				local playerName = getElementData(source, "visibleName"):gsub("_", " ")

				if state then
					outputChatBox("#3d7abc[Bilincs]: #ffffffSikeresen megbilincselted a kiválasztott játékost! #6094cb(" .. targetName .. ")", source, 255, 255, 255, true)
					outputChatBox("#3d7abc[Bilincs]: #6094cb" .. playerName .. " #ffffffmegbilincselt téged!", targetPlayer, 255, 255, 255, true)

					exports.see_chat:localAction(source, "megbilincselte " .. targetName .. "-t.")
				else
					removeElementData(source, "grabbedPlayer")
					outputChatBox("#3d7abc[Bilincs]: #ffffffSikeresen elengedted a kiválasztott játékost! #6094cb(" .. targetName .. ")", source, 255, 255, 255, true)
					outputChatBox("#3d7abc[Bilincs]: #6094cb" .. playerName .. " #fffffflevette rólad a bilincset!", targetPlayer, 255, 255, 255, true)

					exports.see_chat:localAction(source, "elengedte " .. targetName .. "-t.")
				end
			end
		end
	end)

local warpTimer = {}

addCommandHandler("visz",
	function (sourcePlayer, commandName, targetPlayer)
		if exports.see_groups:isPlayerHavePermission(sourcePlayer, "cuff") then
			if not targetPlayer then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", sourcePlayer, 255, 255, 255, true)
			else
				targetPlayer = exports.see_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer and targetPlayer ~= sourcePlayer then
					local sourcePosX, sourcePosY, sourcePosZ = getElementPosition(sourcePlayer)
					local targetPosX, targetPosY, targetPosZ = getElementPosition(targetPlayer)

					local sourceInterior = getElementInterior(sourcePlayer)
					local targetInterior = getElementInterior(targetPlayer)

					local sourceDimension = getElementDimension(sourcePlayer)
					local targetDimension = getElementDimension(targetPlayer)

					local distance = getDistanceBetweenPoints3D(sourcePosX, sourcePosY, sourcePosZ, targetPosX, targetPosY, targetPosZ)

					if distance <= 5 and sourceInterior == targetInterior and sourceDimension == targetDimension then
						if getElementData(targetPlayer, "cuffed") then
							triggerEvent("{×}×*Ä}*€¤{'÷¤×¤¤*>¤}{'*÷×*×€", sourcePlayer, targetPlayer)
						else
							outputChatBox("#d75959[Vezetőszár]: #ffffffA kiválasztott játékos nincs megbilincselve.", sourcePlayer, 255, 255, 255, true)
						end
					else
						outputChatBox("#d75959[Vezetőszár]: #ffffffA kiválasztott játékos túl messze van tőled.", sourcePlayer, 255, 255, 255, true)
					end
				end
			end
		end
	end
)


addEvent("{×}×*Ä}*€¤{'÷¤×¤¤*>¤}{'*÷×*×€", true)
addEventHandler("{×}×*Ä}*€¤{'÷¤×¤¤*>¤}{'*÷×*×€", getRootElement(),
	function (targetPlayer)
		if isElement(source) and isElement(targetPlayer) then
			local canCuff = false

			local sourcePosX, sourcePosY, sourcePosZ = getElementPosition(source)
			local targetPosX, targetPosY, targetPosZ = getElementPosition(targetPlayer)

			if getDistanceBetweenPoints3D(sourcePosX, sourcePosY, sourcePosZ, targetPosX, targetPosY, targetPosZ) > 3 then 
				return 
			end

			if not (exports.see_groups:isPlayerOfficer(source) and exports.see_items:hasItem(source, 118) and exports.see_groups:isPlayerInGroup(source, 1) or exports.see_groups:isPlayerInGroup(source, 12) or exports.see_groups:isPlayerInGroup(source, 13)) then 
				return 
			end

			if (getElementData(source, "adminDuty") or 0) > 1 then
				canCuff = true
			end

			if exports.see_groups:isPlayerOfficer(source) then
				canCuff = true
			end
				
			if not canCuff then
				return
			end

			local state = not getElementData(targetPlayer, "visz")

			if warpTimer[targetPlayer] then
				if isTimer(warpTimer[targetPlayer]) then
					killTimer(warpTimer[targetPlayer])
				end
			end

			if state then
				setElementData(targetPlayer, "visz", source)
				setElementData(source, "grabbedPlayer", targetPlayer)
				setElementData(targetPlayer, "cuffAnimation", 1)
				if getPedOccupiedVehicle(targetPlayer) then
					removePedFromVehicle(targetPlayer)
					warpPlayer(targetPlayer, source)
				end
				warpTimer[targetPlayer] = setTimer(warpPlayer, 1500, 0, targetPlayer, source)
			else
				if getElementData(targetPlayer, "cuffed") then
					setElementData(targetPlayer, "cuffAnimation", 3)
				else
					setElementData(targetPlayer, "cuffAnimation", false)
				end
				removeElementData(source, "grabbedPlayer")

				setElementData(targetPlayer, "visz", false)
				warpTimer[targetPlayer] = nil
			end

			local targetName = getElementData(targetPlayer, "visibleName"):gsub("_", " ")
			local playerName = getElementData(source, "visibleName"):gsub("_", " ")

			if state then
				outputChatBox("#3d7abc[Vezetőszár]: #ffffffElkezdted vinni a kiválasztott játékost! #6094cb(" .. targetName .. ")", source, 255, 255, 255, true)
			else
				outputChatBox("#3d7abc[Vezetőszár]: #ffffffSikeresen elengedted a kiválasztott játékost! #6094cb(" .. targetName .. ")", source, 255, 255, 255, true)
			end
		end
	end)


function warpPlayer(player, target)
	if isElement(player) and isElement(target) then
		local playerInterior = getElementInterior(player)
		local targetInterior = getElementInterior(target)

		local playerDimension = getElementDimension(player)
		local targetDimension = getElementDimension(target)

		local playerPosX, playerPosY, playerPosZ = getElementPosition(player)
		local targetPosX, targetPosY, targetPosZ = getElementPosition(target)

		local _, _, playerRotZ = getElementRotation(player)
		local _, _, targetRotZ = getElementRotation(target)
		local angle = math.rad(targetRotZ + 180 - playerRotZ)

		local deltaX = targetPosX - playerPosX
		local deltaY = targetPosY - playerPosY
		local distance = deltaX * deltaX + deltaY * deltaY

		if getPedOccupiedVehicle(target) and not getPedOccupiedVehicle(player) then
           warpPedIntoVehicle(player, getPedOccupiedVehicle(target), 2)
        end

        if not getPedOccupiedVehicle(target) and getPedOccupiedVehicle(player) then
        	removePedFromVehicle(player)
        end

		if playerInterior ~= targetInterior or playerDimension ~= targetDimension or distance > 10 then
			setElementPosition(player, targetPosX + math.cos(angle) / 2, targetPosY + math.sin(angle) / 2, targetPosZ)
			setElementInterior(player, targetInterior)
			setElementDimension(player, targetDimension)
		end
	else
		if isTimer(warpTimer[player]) then
			killTimer(warpTimer[player])
		end

		warpTimer[player] = nil
	end
end

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		setElementData(source, "cuffed", false)
		setElementData(source, "cuffAnimation", false)
		setElementData(source, "visz", false)
	end)

addEventHandler("onPlayerWasted", getRootElement(),
	function ()
		setElementData(source, "cuffed", false)
		setElementData(source, "cuffAnimation", false)
		setElementData(source, "visz", false)
	end)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue, newValue)
		if dataName == "visz" then
			if not newValue then
				if warpTimer[source] then
					if isTimer(warpTimer[source]) then
						killTimer(warpTimer[source])
					end

					warpTimer[source] = nil
				end
			end
		end
	end)