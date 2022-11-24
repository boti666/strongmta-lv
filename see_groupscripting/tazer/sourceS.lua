addEvent("ASUGD871g76sagd71gashjdgjhagd", true)
addEventHandler("ASUGD871g76sagd71gashjdgjhagd", getRootElement(),
	function (targetPlayer)
		--source = client
		if isElement(source) and isElement(targetPlayer) then
			--iprint(client, source, targetPlayer)
			--if source == client then 
				if client == source then 
					return print("self szajbacsuma")
				end

				if exports.see_groups:isPlayerOfficer(targetPlayer) then 
					return print("fakcioba van")
				end

				if exports.see_groups:isPlayerOfficer(source) and exports.see_items:hasItem(source, 155) then 
					local tazed = getElementData(targetPlayer, "tazed")

					if not tazed then
						exports.see_controls:toggleControl(targetPlayer, {"forwards", "backwards", "left", "right", "jump", "crouch", "aim_weapon", "fire", "enter_exit", "enter_passenger"}, false)
						
						setPedAnimation(targetPlayer, "ped", "FLOOR_hit_f", -1, false, false, true)
						setElementData(targetPlayer, "tazed", true)
						setElementData(targetPlayer, "forcedanimation", 1)
						fadeCamera(targetPlayer, false, 1, 255, 255, 255)

						setTimer(
							function(player)
								if isElement(player) then
									setPedAnimation(player, "FAT", "idle_tired", -1, true, false, false)
									fadeCamera(player, true, 1, 255, 255, 255)

									setTimer(
										function(player)
											if isElement(player) then
												exports.see_controls:toggleControl(player, {"forwards", "backwards", "left", "right", "jump", "crouch", "aim_weapon", "fire", "enter_exit", "enter_passenger"}, true)
												setPedAnimation(player, false)
												setElementData(player, "tazed", false)
												setElementData(player, "forcedanimation", 0)
											end
										end,
									10000, 1, player)
								end
							end,
						20000, 1, targetPlayer)

						triggerClientEvent(targetPlayer, "playTazerSound", targetPlayer)

						local targetName = getElementData(targetPlayer, "visibleName"):gsub("_", " ")
						local playerName = getElementData(source, "visibleName"):gsub("_", " ")

						outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen lesokkoltad a kiválasztott játékost! #32b3ef(" .. targetName .. ")", source, 255, 255, 255, true)
						outputChatBox("#3d7abc[StrongMTA]: #32b3ef" .. playerName .. " #fffffflesokkolt téged!", targetPlayer, 255, 255, 255, true)

						exports.see_chat:localAction(source, "lesokkolt valakit. ((" .. targetName .. "))")
					end
				end
			--end
		end
	end
)

addEvent("€z€'i'×z'÷s*Äkl*k*", true)
addEventHandler("€z€'i'×z'÷s*Äkl*k*", getRootElement(),
	function (targetPlayer)
		print("asd")
		if isElement(source) and isElement(targetPlayer) then
			print("elem")
			if source == targetPlayer then 
				return print ("targetPlayer == source")
			end

			if not exports.see_groups:isPlayerOfficer(source) then 
				return print(source.. "isPlayerOfficer == false")
			end

			local sourceX, sourceY, sourceZ = getElementPosition(source)
			local targetX, targetY, targetZ = getElementPosition(targetPlayer)

			if getDistanceBetweenPoints3D(sourceX, sourceY, sourceZ, targetX, targetY, targetZ) > 7 then 
				return
			end

			if not (exports.see_items:hasItem(source, 155) and exports.see_groups:isPlayerInGroup(source, 1) or exports.see_groups:isPlayerInGroup(source, 13) or exports.see_groups:isPlayerInGroup(source, 12)) then 
				return print("no item")
			end

			if not getElementData(targetPlayer, "tazed") then
				setElementData(targetPlayer, "tazed", true)

				exports.see_controls:toggleControl(targetPlayer, {"jump", "crouch", "walk", "aim_weapon", "fire", "enter_passenger"}, false)
				setPedAnimation(targetPlayer, "ped", "FLOOR_hit_f", -1, false, false, true)
				setElementData(targetPlayer, "tazed", true)
				setElementData(targetPlayer, "forcedanimation", 1)
				fadeCamera(targetPlayer, false, 1, 255, 255, 255)

				setTimer(
					function(player)
						if isElement(player) then
							setPedAnimation(player, "FAT", "idle_tired", -1, true, false, false)
							fadeCamera(player, true, 1, 255, 255, 255)

							setTimer(
								function(player)
									if isElement(player) then
										exports.see_controls:toggleControl(player, {"jump", "crouch", "walk", "aim_weapon", "fire", "enter_passenger"}, true)
										setPedAnimation(player, false)

										setElementData(player, "tazed", false)
									end
								end,
							10000, 1, player)
						end
					end,
				20000, 1, targetPlayer)

				local targetName = getElementData(targetPlayer, "visibleName"):gsub("_", " ")
				local playerName = getElementData(source, "visibleName"):gsub("_", " ")

				triggerClientEvent(targetPlayer, "playTazerSound", targetPlayer)

				outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen lesokkoltad a kiválasztott játékost! #32b3ef(" .. targetName .. ")", source, 255, 255, 255, true)
				outputChatBox("#3d7abc[StrongMTA]: #32b3ef" .. playerName .. " #fffffflesokkolt téged!", targetPlayer, 255, 255, 255, true)

				--print(playerName)

				exports.see_chat:localAction(source, "lesokkolt valakit. ((" .. getElementData(targetPlayer, "visibleName"):gsub("_", " ") .. "))")
			end
		end
	end
)