local screenX, screenY = guiGetScreenSize()

local panelState = false
local panelWidth = 200
local panelHeight = 320
local panelPosX = (screenX / 2)
local panelPosY = (screenY / 2)
local panelMargin = 3
local animalElement = false
local panelFont = false

local moveDifferenceX, moveDifferenceY = 0, 0
local isMoving = false
local animalTimer = false
local feedPanel = false
local caressTimer = false

local playerPanelState = false
local playerPanelWidth = 200
local playerPanelHeight = 140
local playerPanelPosX = (screenX / 2)
local playerPanelPosY = (screenY / 2)

local actionBarWidth = 286

function createFonts()
	destroyFonts()
	panelFont = dxCreateFont("files/roboto.ttf", 13, false, "antialiased")
end

function destroyFonts()
	if isElement(panelFont) then
		destroyElement(panelFont)
	end
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		if isTimer(animalTimer) then
			killTimer(animalTimer)
		end

		animalTimer = setTimer(
			function()
				local characterId = getElementData(localPlayer, "char.ID")
				if characterId then
					local animalElement = getElementByID("animal_" .. characterId)
					if isElement(animalElement) then
						local currentHunger = getElementData(animalElement, "animal.hunger") - 1
						local currentLove = getElementData(animalElement, "animal.love")
						if currentLove == 0 then -- nincs szeretet, nem engedelmeskedik
							setElementData(animalElement, "animal.obedient", false, true)
						else
							setElementData(animalElement, "animal.love", currentLove - 1, true)
						end
						if currentHunger <= 0 then -- elfogy a kaja, meghal
							setElementData(animalElement, "animal.hunger", 0, true)
							triggerServerEvent("animalStarvedToDeath", localPlayer, animalElement, getElementData(animalElement, "animal.animalId"))
						end
						setElementData(animalElement, "animal.hunger", currentHunger, true)
					end
				end
			end, 
		360000, 0)
	end
)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
		if state == "up" then
			isMoving = false
			if button == "left" then
				local characterId = getElementData(localPlayer, "char.ID")
				if characterId then
					clickAnimal = getElementByID("animal_" .. characterId)
				end
				if isElement(clickAnimal) then
					local currentTask = getElementData(clickAnimal, "ped.task.1")
					if currentTask then
						if currentTask[1] == "killPed" then
							if absoluteX >= (screenX / 2) - (actionBarWidth / 2) and absoluteX <= (screenX / 2) - (actionBarWidth / 2) + actionBarWidth and absoluteY >= screenY - 170 and absoluteY <= screenY - 130 then
								setPedTask(clickAnimal, {"walkFollowElement", localPlayer, 3})
							end
						end
					end
				end
			end
			
			if not panelState and not playerPanelState then
				if button == "right" then
					if isElement(clickedElement) then
						if getElementType(clickedElement) == "ped" then
							local animalId = getElementData(clickedElement, "animal.animalId")
							if animalId then
								local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
								local targetPosX, targetPosY, targetPosZ = getElementPosition(clickedElement)

								if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, targetPosX, targetPosY, targetPosZ) <= 5 then
									createFonts()
									feedPanel = false
									panelState = true
									panelPosX = absoluteX
									panelPosY = absoluteY

									animalElement = clickedElement
								end
							end
						elseif getElementType(clickedElement) == "player" then
							if clickedElement ~= localPlayer then
								local characterId = getElementData(localPlayer, "char.ID")
								if characterId then
									local myAnimal = getElementByID("animal_" .. characterId)
									if isElement(myAnimal) then
										local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
										local targetPosX, targetPosY, targetPosZ = getElementPosition(clickedElement)

										if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, targetPosX, targetPosY, targetPosZ) <= 5 then
											createFonts()
											playerPanelState = true
											playerPanelPosX = absoluteX
											playerPanelPosY = absoluteY

											playerAnimalElement = clickedElement
										end
									end
								end
							end
						end
					end
				end
			else
				if button == "left" then
					if playerPanelState then
						if isElement(playerAnimalElement) then
							if absoluteX >= playerPanelPosX + 5 and absoluteX <= playerPanelPosX + 5 + playerPanelWidth - 10 and absoluteY >= playerPanelPosY + 40 and absoluteY <= playerPanelPosY + 70 then -- attack
								local localX, localY, localZ = getElementPosition(localPlayer)
								local targetX, targetY, targetZ = getElementPosition(playerAnimalElement)
								if getDistanceBetweenPoints3D(localX, localY, localZ, targetX, targetY, targetZ) <= 15 then
									local characterId = getElementData(localPlayer, "char.ID")
									if characterId then
										local myAnimal = getElementByID("animal_" .. characterId)
										if isElement(myAnimal) then
											setPedTask(myAnimal, {"killPed", playerAnimalElement, 5, 1})
										end
									end
								else
									outputChatBox("#3d7abc[StrongMTA]: #ffffffA peted túl messze van tőled.", 255, 255, 255, true)
								end
								playerPanelState = false
								destroyFonts()
							elseif absoluteX >= playerPanelPosX + 5 and absoluteX <= playerPanelPosX + 5 + playerPanelWidth - 10 and absoluteY >= playerPanelPosY + 100 and absoluteY <= playerPanelPosY + 130 then -- close
								playerPanelState = false
								destroyFonts()
							end
						end
					elseif panelState then
						if isElement(animalElement) then
							if absoluteX >= panelPosX + 5 and absoluteX <= panelPosX + 5 + panelWidth - 10 and absoluteY >= panelPosY + 40 and absoluteY <= panelPosY + 70 then -- követ / marad @ ppsnack
								if not feedPanel then
									local characterId = getElementData(localPlayer, "char.ID")
									if characterId then
										local ownerId = getElementData(animalElement, "animal.ownerId")
										if ownerId then
											if tonumber(characterId) == tonumber(ownerId) then
												local doAction = true
												if not getElementData(animalElement, "animal.obedient") then
													local randomNumber = math.random(0, 101)
													if randomNumber > 10 then
														doAction = false
													end
												end
												if doAction then
													local thisTask = getElementData(animalElement, "ped.thisTask")
													if thisTask then
														local task = getElementData(animalElement, "ped.task." .. thisTask)
														if task then
															if task[1] == "walkFollowElement" or task[1] == "killPed" then -- eddig mozgott, most meg kell állnia
																clearPedTasks(animalElement)
																outputChatBox("#3d7abc[StrongMTA]: #ffffffMegállítottad a peted. Mostantól itt fog várni.", 255, 255, 255, true)
															end
														end
													else -- eddig várt, most mozognia kell
														setPedTask(animalElement, {"walkFollowElement", localPlayer, 3})
														outputChatBox("#3d7abc[StrongMTA]: #ffffffA peted elkezdett követni téged.", 255, 255, 255, true)
													end
												end
											end
										end
									end
								else
									triggerServerEvent("feedAnimal", localPlayer, animalElement, 163)
								end
								panelState = false
								destroyFonts()
							elseif absoluteX >= panelPosX + 5 and absoluteX <= panelPosX + 5 + panelWidth - 10 and absoluteY >= panelPosY + 80 and absoluteY <= panelPosY + 110 then -- simogatás @ snack
								if not feedPanel then
									local currentLove = getElementData(animalElement, "animal.love")
									if currentLove + 5 > 100 then
										setElementData(animalElement, "animal.love", 100, true)
									else
										setElementData(animalElement, "animal.love", currentLove + 5, true)
									end

									triggerServerEvent("setAnimationForAnimalPet", localPlayer, animalElement, true)

									if isTimer(caressTimer) then
										killTimer(caressTimer)
									end

									caressTimer = setTimer(
										function()
											triggerServerEvent("setAnimationForAnimalPet", localPlayer, animalElement, false)
										end, 
									1000 * 7, 1)
								else
									triggerServerEvent("feedAnimal", localPlayer, animalElement, 161)
								end

								panelState = false
								destroyFonts()
							elseif absoluteX >= panelPosX + 5 and absoluteX <= panelPosX + 5 + panelWidth - 10 and absoluteY >= panelPosY + 120 and absoluteY <= panelPosY + 150 then -- etetés @ kutyatáp
								if not feedPanel then
									feedPanel = true
								else
									triggerServerEvent("feedAnimal", localPlayer, animalElement, 162)
									panelState = false
									destroyFonts()
								end
							elseif absoluteX >= panelPosX + 5 and absoluteX <= panelPosX + 5 + panelWidth - 10 and absoluteY >= panelPosY + 160 and absoluteY <= panelPosY + 190 then -- támadás saját kutyával @ jutalomfalat
								if not feedPanel then
									local characterId = getElementData(localPlayer, "char.ID")
									if characterId then
										local ownerId = getElementData(animalElement, "animal.ownerId")
										if ownerId then
											if tonumber(characterId) ~= tonumber(ownerId) then
												local localAnimal = getElementByID("animal_" .. tostring(characterId))
												if isElement(localAnimal) then

													clearPedTasks(localAnimal)
													clearPedTasks(animalElement)

													addPedTask(localAnimal, {"killPed", animalElement, 5, 1})
													addPedTask(animalElement, {"killPed", localAnimal, 5, 1})

													outputChatBox("#3d7abc[StrongMTA]: #ffffffRáuszítottad a peted a kiválasztott állatra.", 255, 255, 255, true)
												end
											end
										end
									end
								else
									triggerServerEvent("feedAnimal", localPlayer, animalElement, 160)
								end
								panelState = false
								destroyFonts()
							elseif absoluteX >= panelPosX + 5 and absoluteX <= panelPosX + 5 + panelWidth - 10 and absoluteY >= panelPosY + 200 and absoluteY <= panelPosY + 230 then -- ugattatás
								if not feedPanel then
									local characterId = getElementData(localPlayer, "char.ID")
									if characterId then
										local ownerId = getElementData(animalElement, "animal.ownerId")
										if ownerId then
											if tonumber(characterId) == tonumber(ownerId) then
												triggerServerEvent("triggerBark", localPlayer, animalElement)
											end
										end
									end
									panelState = false
									destroyFonts()
								end
							elseif absoluteX >= panelPosX + 5 and absoluteX <= panelPosX + 5 + panelWidth - 10 and absoluteY >= panelPosY + 280 and absoluteY <= panelPosY + 310 then -- bezárás
								panelState = false
								destroyFonts()
							end
						end
					end
				end
			end
		end
		if state == "down" then
			if button == "left" then
				if playerPanelState then
					if absoluteX >= playerPanelPosX and absoluteX <= playerPanelPosX + playerPanelWidth and absoluteY >= playerPanelPosY and absoluteY <= playerPanelPosY + 30 then
						moveDifferenceX = absoluteX - playerPanelPosX
						moveDifferenceY = absoluteY - playerPanelPosY

						isMoving = true
					end
				elseif panelState then
					if absoluteX >= panelPosX and absoluteX <= panelPosX + panelWidth and absoluteY >= panelPosY and absoluteY <= panelPosY + 30 then
						moveDifferenceX = absoluteX - panelPosX
						moveDifferenceY = absoluteY - panelPosY

						isMoving = true
					end
				end
			end
		end
	end
)

addEventHandler("onClientPedDamage", getRootElement(),
	function (attacker)
		if isElement(attacker) then
			if getElementData(source, "animal.animalId") then
				local characterId = getElementData(localPlayer, "char.ID")
				if characterId then
					local ownerId = getElementData(source, "animal.ownerId")
					if ownerId then
						if tonumber(ownerId) == tonumber(characterId) then
							local currentTask = getElementData(source, "ped.task.1")
							if currentTask then
								if currentTask[1] ~= "killPed" then
									setPedTask(source, {"killPed", attacker, 5, 1})
									outputChatBox("#3d7abc[StrongMTA]: #ffffffValaki bántja a petedet.", 255, 255, 255, true)
								end
							else
								setPedTask(source, {"killPed", attacker, 5, 1})
								outputChatBox("#3d7abc[StrongMTA]: #ffffffValaki bántja a petedet.", 255, 255, 255, true)
							end
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientPlayerDamage", getRootElement(),
	function (attacker)
		if source == localPlayer then
			if isElement(attacker) then
				local characterId = getElementData(localPlayer, "char.ID")
				if characterId then
					myAnimal = getElementByID("animal_" .. characterId)
					if isElement(myAnimal) then
						local playerX, playerY, playerZ = getElementPosition(localPlayer)
						local animalX, animalY, animalZ = getElementPosition(myAnimal)
						if getDistanceBetweenPoints3D(playerX, playerY, playerZ, animalX, animalY, animalZ) <= 100 then
							local currentTask = getElementData(myAnimal, "ped.task.1")
							if currentTask then
								if currentTask[1] ~= "killPed" then
									setPedTask(myAnimal, {"killPed", attacker, 5, 1})
								end
							else
								setPedTask(myAnimal, {"killPed", attacker, 5, 1})
							end
						end
					end
				end
			end
		end
	end
)

local myAnimal = false
setTimer(
	function ()
		myAnimal = false

		local characterId = getElementData(localPlayer, "char.ID")
		if characterId then
			for k,v in pairs(getElementsByType("ped")) do
				if getElementData(v, "animal.ownerId") == characterId then
					myAnimal = v
					break
				end
			end
		end
	end,
1000, 0)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if myAnimal then
			if isElement(myAnimal) then
				local currentTask = getElementData(myAnimal, "ped.task.1")
				if currentTask then
					if currentTask[1] == "killPed" then
						local absX, absY = 0, 0
						if isCursorShowing() then
							local relX, relY = getCursorPosition()

							absX = screenX * relX
							absY = screenY * relY
						end

						if absX >= (screenX / 2) - (actionBarWidth / 2) and absX <= (screenX / 2) - (actionBarWidth / 2) + actionBarWidth and absY >= screenY - 170 and absY <= screenY - 130 then
							dxDrawImage((screenX / 2) - (actionBarWidth / 2), screenY - 170, actionBarWidth, 40, "files/cback2.png")
						else
							dxDrawImage((screenX / 2) - (actionBarWidth / 2), screenY - 170, actionBarWidth, 40, "files/cback1.png")
						end
					end
				end
			end
		end

		if playerPanelState then
			if isElement(myAnimal) then
				local absX, absY = 0, 0
				if isCursorShowing() then
					local relX, relY = getCursorPosition()

					absX = screenX * relX
					absY = screenY * relY
				end

				if isMoving then
					playerPanelPosX = absX - moveDifferenceX
					playerPanelPosY = absY - moveDifferenceY
				end

				-- ** Háttér
				dxDrawRectangle(playerPanelPosX, playerPanelPosY, playerPanelWidth, playerPanelHeight, tocolor(0, 0, 0, 140))

				-- ** Keret
				dxDrawRectangle(playerPanelPosX - panelMargin, playerPanelPosY - panelMargin, playerPanelWidth + (panelMargin * 2), panelMargin, tocolor(0, 0, 0, 200)) -- felső
				dxDrawRectangle(playerPanelPosX - panelMargin, playerPanelPosY + playerPanelHeight, playerPanelWidth + (panelMargin * 2), panelMargin, tocolor(0, 0, 0, 200)) -- alsó
				dxDrawRectangle(playerPanelPosX - panelMargin, playerPanelPosY, panelMargin, playerPanelHeight, tocolor(0, 0, 0, 200)) -- bal
				dxDrawRectangle(playerPanelPosX + playerPanelWidth, playerPanelPosY, panelMargin, playerPanelHeight, tocolor(0, 0, 0, 200)) -- jobb

				-- ** Cím
				--dxDrawText("#3d7abcPet Panel", playerPanelPosX + 5, playerPanelPosY - 25, 0, 0, tocolor(255, 255, 255, 255), 1.0, panelFont, "left", "top", false, false, true, true, true)

				dxDrawText("", playerPanelPosX + 6, playerPanelPosY + 11, playerPanelPosX + playerPanelWidth - 2, playerPanelPosY + 45, tocolor(0, 0, 0, 255), 1.0, panelFont, "left", "top", true, false, true, false, true)
				dxDrawText(split((getElementData(myAnimal, "visibleName") or ""), "#")[1], playerPanelPosX + 5, playerPanelPosY + 10, playerPanelPosX + playerPanelWidth - 2, playerPanelPosY + 45, tocolor(61, 122, 188, 255), 1.0, panelFont, "left", "top", true, false, true, false, true)

				local toggleColor = tocolor(255, 255, 255, 40)
				if absX >= playerPanelPosX + 5 and absX <= playerPanelPosX + 5 + playerPanelWidth - 10 and absY >= playerPanelPosY + 40 and absY <= playerPanelPosY + 70 then
					toggleColor = tocolor(61, 122, 188, 140)
				end
				dxDrawRectangle(playerPanelPosX + 5, playerPanelPosY + 40, playerPanelWidth - 10, 30, toggleColor)
				dxDrawText("Támadás", playerPanelPosX + 6, playerPanelPosY + 41, playerPanelPosX + 5 + playerPanelWidth - 10, playerPanelPosY + 70, tocolor(0, 0, 0, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
				dxDrawText("Támadás", playerPanelPosX + 5, playerPanelPosY + 40, playerPanelPosX + 5 + playerPanelWidth - 10, playerPanelPosY + 70, tocolor(255, 255, 255, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
			
				local closeColor = tocolor(255, 255, 255, 40)
				if absX >= playerPanelPosX + 5 and absX <= playerPanelPosX + 5 + playerPanelWidth - 10 and absY >= playerPanelPosY + 100 and absY <= playerPanelPosY + 130 then
					closeColor = tocolor(61, 122, 188, 140)
				end
				dxDrawRectangle(playerPanelPosX + 5, playerPanelPosY + 100, playerPanelWidth - 10, 30, closeColor)
				dxDrawText("Bezárás", playerPanelPosX + 6, playerPanelPosY + 101, playerPanelPosX + 5 + playerPanelWidth - 10, playerPanelPosY + 130, tocolor(0, 0, 0, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
				dxDrawText("Bezárás", playerPanelPosX + 5, playerPanelPosY + 100, playerPanelPosX + 5 + playerPanelWidth - 10, playerPanelPosY + 130, tocolor(255, 255, 255, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
			
			end
		elseif panelState then
			if isElement(animalElement) then
				local absX, absY = 0, 0
				if isCursorShowing() then
					local relX, relY = getCursorPosition()

					absX = screenX * relX
					absY = screenY * relY
				end

				if isMoving then
					panelPosX = absX - moveDifferenceX
					panelPosY = absY - moveDifferenceY
				end

				-- ** Háttér
				dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(0, 0, 0, 140))

				-- ** Keret
				dxDrawRectangle(panelPosX - panelMargin, panelPosY - panelMargin, panelWidth + (panelMargin * 2), panelMargin, tocolor(0, 0, 0, 200)) -- felső
				dxDrawRectangle(panelPosX - panelMargin, panelPosY + panelHeight, panelWidth + (panelMargin * 2), panelMargin, tocolor(0, 0, 0, 200)) -- alsó
				dxDrawRectangle(panelPosX - panelMargin, panelPosY, panelMargin, panelHeight, tocolor(0, 0, 0, 200)) -- bal
				dxDrawRectangle(panelPosX + panelWidth, panelPosY, panelMargin, panelHeight, tocolor(0, 0, 0, 200)) -- jobb

				-- ** Cím
				--dxDrawText("#3d7abcPet Panel", panelPosX + 5, panelPosY - 25, 0, 0, tocolor(255, 255, 255, 255), 1.0, panelFont, "left", "top", false, false, true, true, true)

				-- ** Content

				dxDrawText(split((getElementData(animalElement, "visibleName") or ""), "#")[1], panelPosX + 5, panelPosY + 10, panelPosX + panelWidth - 2, panelPosY + 45, tocolor(61, 122, 188, 255), 1.0, panelFont, "left", "top", true, false, true, false, true)

				local myAnimal = false
				local characterId = getElementData(localPlayer, "char.ID")
				if characterId then
					local ownAnimalElement = getElementByID("animal_" .. characterId)
					if isElement(ownAnimalElement) then
						if animalElement == ownAnimalElement then
							myAnimal = true
						end
					end
				end

				-- Követ / Marad
				local toggleText = "Marad"
				local thisTask = getElementData(animalElement, "ped.thisTask")
				if not thisTask then
					toggleText = "Kövess"
				end

				if feedPanel then
					toggleText = "PPSnack"
				end
				if myAnimal then
					local toggleColor = tocolor(255, 255, 255, 40)
					if absX >= panelPosX + 5 and absX <= panelPosX + 5 + panelWidth - 10 and absY >= panelPosY + 40 and absY <= panelPosY + 70 then
						toggleColor = tocolor(61, 122, 188, 140)

						if toggleText == "Marad" then
							toggleColor = tocolor(247, 148, 29, 140)
						end
					end
					dxDrawRectangle(panelPosX + 5, panelPosY + 40, panelWidth - 10, 30, toggleColor)
					dxDrawText(toggleText, panelPosX + 6, panelPosY + 41, panelPosX + 5 + panelWidth - 10, panelPosY + 70, tocolor(0, 0, 0, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
					dxDrawText(toggleText, panelPosX + 5, panelPosY + 40, panelPosX + 5 + panelWidth - 10, panelPosY + 70, tocolor(255, 255, 255, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
				else
					dxDrawRectangle(panelPosX + 5, panelPosY + 40, panelWidth - 10, 30, tocolor(255, 255, 255, 40))
					dxDrawText(toggleText, panelPosX + 6, panelPosY + 41, panelPosX + 5 + panelWidth - 10, panelPosY + 70, tocolor(0, 0, 0, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
					dxDrawText(toggleText, panelPosX + 5, panelPosY + 40, panelPosX + 5 + panelWidth - 10, panelPosY + 70, tocolor(200, 200, 200, 200), 1.0, panelFont, "center", "center", false, false, true, true, true)
				end

				-- Simogatás
				local caressText = "Simogatás"
				if feedPanel then
					caressText = "Kutya táp"
				end
				local caressColor = tocolor(255, 255, 255, 40)
				if absX >= panelPosX + 5 and absX <= panelPosX + 5 + panelWidth - 10 and absY >= panelPosY + 80 and absY <= panelPosY + 110 then
					caressColor = tocolor(50, 179, 239, 140)
				end
				dxDrawRectangle(panelPosX + 5, panelPosY + 80, panelWidth - 10, 30, caressColor)
				dxDrawText(caressText, panelPosX + 6, panelPosY + 81, panelPosX + 5 + panelWidth - 10, panelPosY + 110, tocolor(0, 0, 0, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
				dxDrawText(caressText, panelPosX + 5, panelPosY + 80, panelPosX + 5 + panelWidth - 10, panelPosY + 110, tocolor(255, 255, 255, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)

				-- Etetés
				local feedText = "Etetés"
				if feedPanel then
					feedText = "Kutya snack"
				end
				local feedColor = tocolor(255, 255, 255, 40)
				if absX >= panelPosX + 5 and absX <= panelPosX + 5 + panelWidth - 10 and absY >= panelPosY + 120 and absY <= panelPosY + 150 then
					feedColor = tocolor(50, 179, 239, 140)
				end
				dxDrawRectangle(panelPosX + 5, panelPosY + 120, panelWidth - 10, 30, feedColor)
				dxDrawText(feedText, panelPosX + 6, panelPosY + 121, panelPosX + 5 + panelWidth - 10, panelPosY + 150, tocolor(0, 0, 0, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
				dxDrawText(feedText, panelPosX + 5, panelPosY + 120, panelPosX + 5 + panelWidth - 10, panelPosY + 150, tocolor(255, 255, 255, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)

				-- Saját kutyával megtámadás
				local attackText = "Támadás"
				if feedPanel then
					attackText = "Jutalom falat"
				end
				local attackColor = tocolor(255, 255, 255, 40)
				if absX >= panelPosX + 5 and absX <= panelPosX + 5 + panelWidth - 10 and absY >= panelPosY + 160 and absY <= panelPosY + 190 then
					attackColor = tocolor(215, 89, 89, 140)
				end
				
				dxDrawRectangle(panelPosX + 5, panelPosY + 160, panelWidth - 10, 30, attackColor)
				dxDrawText(attackText, panelPosX + 6, panelPosY + 161, panelPosX + 5 + panelWidth - 10, panelPosY + 190, tocolor(0, 0, 0, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
				dxDrawText(attackText, panelPosX + 5, panelPosY + 160, panelPosX + 5 + panelWidth - 10, panelPosY + 190, tocolor(255, 255, 255, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)

				-- Ugattatás
				local barkText = "Ugattatás"
				if not feedPanel then
					if myAnimal then
						local barkColor = tocolor(255, 255, 255, 40)
						if absX >= panelPosX + 5 and absX <= panelPosX + 5 + panelWidth - 10 and absY >= panelPosY + 200 and absY <= panelPosY + 230 then
							barkColor = tocolor(255, 125, 0, 140)
						end
						dxDrawRectangle(panelPosX + 5, panelPosY + 200, panelWidth - 10, 30, barkColor)
						dxDrawText(barkText, panelPosX + 6, panelPosY + 201, panelPosX + 5 + panelWidth - 10, panelPosY + 230, tocolor(0, 0, 0, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
						dxDrawText(barkText, panelPosX + 5, panelPosY + 200, panelPosX + 5 + panelWidth - 10, panelPosY + 230, tocolor(255, 255, 255, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
					else
						dxDrawRectangle(panelPosX + 5, panelPosY + 200, panelWidth - 10, 30, tocolor(255, 255, 255, 40))
						dxDrawText(barkText, panelPosX + 6, panelPosY + 201, panelPosX + 5 + panelWidth - 10, panelPosY + 230, tocolor(0, 0, 0, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
						dxDrawText(barkText, panelPosX + 5, panelPosY + 200, panelPosX + 5 + panelWidth - 10, panelPosY + 230, tocolor(200, 200, 200, 200), 1.0, panelFont, "center", "center", false, false, true, true, true)
					end
				end

				-- Kilépés
				local closeColor = tocolor(255, 255, 255, 40)
				if absX >= panelPosX + 5 and absX <= panelPosX + 5 + panelWidth - 10 and absY >= panelPosY + 280 and absY <= panelPosY + 310 then
					closeColor = tocolor(215, 89, 89, 140)
				end
				dxDrawRectangle(panelPosX + 5, panelPosY + 280, panelWidth - 10, 30, closeColor)
				dxDrawText("Bezárás", panelPosX + 6, panelPosY + 281, panelPosX + 5 + panelWidth - 10, panelPosY + 310, tocolor(0, 0, 0, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
				dxDrawText("Bezárás", panelPosX + 5, panelPosY + 280, panelPosX + 5 + panelWidth - 10, panelPosY + 310, tocolor(255, 255, 255, 255), 1.0, panelFont, "center", "center", false, false, true, true, true)
			end
		end
	end
)

addEvent("petSound", true)
addEventHandler("petSound", getRootElement(),
	function (typ)
		local x, y, z = getElementPosition(source)
		local int = getElementInterior(source)
		local dim = getElementDimension(source)

		if typ == "attack" then
			local soundElement = playSound3D("files/attack.mp3", x, y, z)
			setSoundMaxDistance( soundElement, 20 )
			attachElements(soundElement, source)
			setElementInterior(soundElement, int)
			setElementDimension(soundElement, dim)
		elseif typ == "follow" then
			local soundElement = playSound3D("files/follow.mp3", x, y, z)
			setSoundMaxDistance( soundElement, 20 )
			attachElements(soundElement, source)
			setElementInterior(soundElement, int)
			setElementDimension(soundElement, dim)
		elseif typ == "caress" then
			local soundElement = playSound3D("files/caress.mp3", x, y, z)
			setSoundMaxDistance( soundElement, 20 )
			attachElements(soundElement, source)
			setElementInterior(soundElement, int)
			setElementDimension(soundElement, dim)
		elseif typ == "bark" then
			local soundElement = playSound3D("files/bark.mp3", x, y, z)
			setSoundMaxDistance( soundElement, 30 )
			attachElements(soundElement, source)
			setElementInterior(soundElement, int)
			setElementDimension(soundElement, dim)
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if isElement(source) then
			if source == localPlayer then
				if dataName == "loggedIn" then
					if isTimer(animalTimer) then
						killTimer(animalTimer)
					end

					animalTimer = setTimer(
						function()
							local characterId = getElementData(localPlayer, "char.ID")
							if characterId then
								local animalElement = getElementByID("animal_" .. characterId)
								if isElement(animalElement) then
									local currentHunger = getElementData(animalElement, "animal.hunger") - 1
									local currentLove = getElementData(animalElement, "animal.love")
									if currentLove == 0 then -- nincs szeretet, nem engedelmeskedik
										setElementData(animalElement, "animal.obedient", false, true)
									else
										setElementData(animalElement, "animal.love", currentLove - 1, true)
									end
									if currentHunger <= 0 then -- elfogy a kaja, meghal
										setElementData(animalElement, "animal.hunger", 0, true)
										triggerServerEvent("animalStarvedToDeath", localPlayer, animalElement, getElementData(animalElement, "animal.animalId"))
									end
									setElementData(animalElement, "animal.hunger", currentHunger, true)
								end
							end
						end, 
					360000, 0)
				end
			else
				if getElementData(source, "animal.animalId") then
					if dataName == "ped.task.1" then
						local selectedTask = getElementData(source, "ped.task.1")
						if selectedTask then
							if selectedTask[1] == "killPed" then
								local pedPosX, pedPosY, pedPosZ = getElementPosition(source)
								local soundElement = playSound3D("files/attack.mp3", pedPosX, pedPosY, pedPosZ)
								if isElement(soundElement) then
									setSoundMaxDistance(soundElement, 20)
									attachElements(soundElement, source)
								end
							elseif selectedTask[1] == "walkFollowElement" then
								local pedPosX, pedPosY, pedPosZ = getElementPosition(source)
								local soundElement = playSound3D("files/follow.mp3", pedPosX, pedPosY, pedPosZ)
								if isElement(soundElement) then
									setSoundMaxDistance(soundElement, 20)
									attachElements(soundElement, source)
								end
							end
						end
					elseif dataName == "animal.health" then
						--setElementHealth(source, getElementData(source, "animal.health"))
					end
				end
			end
		end
	end
)

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

addEventHandler("onClientResourceStart",getResourceRootElement(),
	function ()
		addEventHandler("onClientPreRender",root,cycleNPCs)
	end,
true, "high+999999")


function stopAllNPCActions(npc)
	stopNPCWalkingActions(npc)
	stopNPCWeaponActions(npc)

	setPedControlState(npc,"vehicle_fire",false)
	setPedControlState(npc,"vehicle_secondary_fire",false)
	setPedControlState(npc,"steer_forward",false)
	setPedControlState(npc,"steer_back",false)
	setPedControlState(npc,"horn",false)
	setPedControlState(npc,"handbrake",false)
end

function stopNPCWalkingActions(npc)
	setPedControlState(npc,"forwards",false)
	setPedControlState(npc,"sprint",false)
	setPedControlState(npc,"walk",false)
end

function stopNPCWeaponActions(npc)
	setPedControlState(npc,"aim_weapon",false)
	setPedControlState(npc,"fire",false)
end

function makeNPCWalkToPos(npc,x,y)
	local px,py = getElementPosition(npc)
	setPedCameraRotation(npc,math.deg(math.atan2(x-px,y-py)))
	setPedControlState(npc,"forwards",true)
	local speed = getNPCWalkSpeed(npc)
	setPedControlState(npc,"walk",speed == "walk")
	setPedControlState(npc,"sprint",
		speed == "sprint" or
		speed == "sprintfast" and not getPedControlState(npc,"sprint")
	)
end

function makeNPCWalkAlongLine(npc,x1,y1,z1,x2,y2,z2,off)
	local x,y,z = getElementPosition(npc)
	local p2 = getPercentageInLine(x,y,x1,y1,x2,y2)
	local len = getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2)
	p2 = p2+off/len
	local p1 = 1-p2
	local destx,desty = p1*x1+p2*x2,p1*y1+p2*y2
	makeNPCWalkToPos(npc,destx,desty)
end

function makeNPCWalkAroundBend(npc,x0,y0,x1,y1,x2,y2,off)
	local x,y,z = getElementPosition(npc)
	local len = getDistanceBetweenPoints2D(x1,y1,x2,y2)*math.pi*0.5
	local p2 = getAngleInBend(x,y,x0,y0,x1,y1,x2,y2)/math.pi*2+off/len
	local destx,desty = getPosFromBend(p2*math.pi*0.5,x0,y0,x1,y1,x2,y2)
	makeNPCWalkToPos(npc,destx,desty)
end

function makeNPCShootAtPos(npc,x,y,z)
	local sx,sy,sz = getElementPosition(npc)
	x,y,z = x-sx,y-sy,z-sz
	local yx,yy,yz = 0,0,1
	local xx,xy,xz = yy*z-yz*y,yz*x-yx*z,yx*y-yy*x
	yx,yy,yz = y*xz-z*xy,z*xx-x*xz,x*xy-y*xx
	local inacc = 1-(getNPCWeaponAccuracy(npc) or 0.5)
	local ticks = getTickCount()
	local xmult = inacc*math.sin(ticks*0.01 )*1000/math.sqrt(xx*xx+xy*xy+xz*xz)
	local ymult = inacc*math.cos(ticks*0.011)*1000/math.sqrt(yx*yx+yy*yy+yz*yz)
	local mult = 1000/math.sqrt(x*x+y*y+z*z)
	xx,xy,xz = xx*xmult,xy*xmult,xz*xmult
	yx,yy,yz = yx*ymult,yy*ymult,yz*ymult
	x,y,z = x*mult,y*mult,z*mult
	
	setPedAimTarget(npc,sx+xx+yx+x,sy+xy+yy+y,sz+xz+yz+z)
	if isPedInVehicle(npc) then
		setPedControlState(npc,"vehicle_fire",not getPedControlState(npc,"vehicle_fire"))
	else
		setPedControlState(npc,"aim_weapon",true)
		setPedControlState(npc,"fire",not getPedControlState(npc,"fire"))
	end
end

function makeNPCShootAtElement(npc,target)
	local x,y,z = getElementPosition(target)
	local vx,vy,vz = getElementVelocity(target)
	local tgtype = getElementType(target)
	if tgtype == "ped" or tgtype == "player" then
		x,y,z = getPedBonePosition(target,3)
		local vehicle = getPedOccupiedVehicle(target)
		if vehicle then
			vx,vy,vz = getElementVelocity(vehicle)
		end
	end
	vx,vy,vz = vx*6,vy*6,vz*6
	makeNPCShootAtPos(npc,x+vx,y+vy,z+vz)
end

performTask = {}

function performTask.walkToPos(npc,task)
	if isPedInVehicle(npc) then return true end
	local destx,desty,destz,dest_dist = task[2],task[3],task[4],task[5]
	local x,y = getElementPosition(npc)
	local distx,disty = destx-x,desty-y
	local dist = distx*distx+disty*disty
	local dest_dist = task[5]
	if dist < dest_dist*dest_dist then return true end
	makeNPCWalkToPos(npc,destx,desty)
end

function performTask.walkAlongLine(npc,task)
	if isPedInVehicle(npc) then return true end
	local x1,y1,z1,x2,y2,z2 = task[2],task[3],task[4],task[5],task[6],task[7]
	local off,enddist = task[8],task[9]
	local x,y,z = getElementPosition(npc)
	local pos = getPercentageInLine(x,y,x1,y1,x2,y2)
	local len = getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2)
	if pos >= 1-enddist/len then return true end
	makeNPCWalkAlongLine(npc,x1,y1,z1,x2,y2,z2,off)
end

function performTask.walkAroundBend(npc,task)
	if isPedInVehicle(npc) then return true end
	local x0,y0 = task[2],task[3]
	local x1,y1,z1 = task[4],task[5],task[6]
	local x2,y2,z2 = task[7],task[8],task[9]
	local off,enddist = task[10],task[11]
	local x,y,z = getElementPosition(npc)
	local len = getDistanceBetweenPoints2D(x1,y1,x2,y2)*math.pi*0.5
	local angle = getAngleInBend(x,y,x0,y0,x1,y1,x2,y2)+enddist/len
	if angle >= math.pi*0.5 then return true end
	makeNPCWalkAroundBend(npc,x0,y0,x1,y1,x2,y2,off)
end

function performTask.walkFollowElement(npc,task)
	if isPedInVehicle(npc) then return true end
	local followed,mindist = task[2],task[3]
	if not isElement(followed) then return true end
	local x,y = getElementPosition(npc)
	local fx,fy = getElementPosition(followed)
	local dx,dy = fx-x,fy-y
	if dx*dx+dy*dy > mindist*mindist then
		makeNPCWalkToPos(npc,fx,fy)
	else
		stopAllNPCActions(npc)
	end
end

function performTask.shootPoint(npc,task)
	local x,y,z = task[2],task[3],task[4]
	makeNPCShootAtPos(npc,x,y,z)
end

function performTask.shootElement(npc,task)
	local target = task[2]
	if not isElement(target) then return true end
	makeNPCShootAtElement(npc,target)
end

function performTask.killPed(npc,task)
	if isPedInVehicle(npc) then return true end
	local target,shootdist,followdist = task[2],task[3],task[4]
	if not isElement(target) or isPedDead(target) then return true end

	local x,y,z = getElementPosition(npc)
	local tx,ty,tz = getElementPosition(target)
	local dx,dy = tx-x,ty-y
	local distsq = dx*dx+dy*dy

	if distsq < shootdist*shootdist then
		makeNPCShootAtElement(npc,target)
		setPedRotation(npc,-math.deg(math.atan2(dx,dy)))
	else
		stopNPCWeaponActions(npc)
	end
	if distsq > followdist*followdist then
		makeNPCWalkToPos(npc,tx,ty)
	else
		stopNPCWalkingActions(npc)
	end

	return false
end

local attackDistance = 10

function addPedTask(pedElement, selectedTask)
	if isElement(pedElement) then
		local lastTask = getElementData(pedElement, "ped.lastTask")
		if not lastTask then
			lastTask = 1
			setElementData(pedElement, "ped.thisTask", 1)
		else
			lastTask = lastTask + 1
		end
		setElementData(pedElement, "ped.task." .. lastTask, selectedTask)
		setElementData(pedElement, "ped.lastTask", lastTask)
		return true
	else
		return false
	end
end

function clearPedTasks(pedElement)
	if isElement(pedElement) then
		local thisTask = getElementData(pedElement, "ped.thisTask")
		if thisTask then
		
			local lastTask = getElementData(pedElement, "ped.lastTask")
			for currentTask = thisTask, lastTask do
				--removeElementData(pedElement,"ped.task." .. currentTask)
				setElementData(pedElement, "ped.task." .. currentTask, nil)
			end

			--removeElementData(pedElement, "ped.thisTask")
			setElementData(pedElement, "ped.thisTask", nil)
			--removeElementData(pedElement, "ped.lastTask")
			setElementData(pedElement, "ped.lastTask", nil)
			return true
		end
	else
		return false
	end
end

function setPedTask(pedElement, selectedTask)
	if isElement(pedElement) then
		clearPedTasks(pedElement)
		setElementData(pedElement, "ped.task.1", selectedTask)
		setElementData(pedElement, "ped.thisTask", 1)
		setElementData(pedElement, "ped.lastTask", 1)
		return true
	else
		return false
	end
end


function cycleNPCs()
	local streamedPeds = {}
	for pednum,ped in ipairs(getElementsByType("ped",root,true)) do
		if getElementData(ped,"ped.isControllable") then
			streamedPeds[ped] = true
		end
	end
	for npc,streamedin in pairs(streamedPeds) do
		if getElementHealth(getPedOccupiedVehicle(npc) or npc) >= 1 then
			while true do
				local thisTask = getElementData(npc,"ped.thisTask")
				if thisTask then
					local task = getElementData(npc,"ped.task."..thisTask)
					if task then
						if performTask[task[1]](npc,task) then
							clearPedTasks(npc)
						else
							break
						end
					else
						stopAllNPCActions(npc)
						break
					end
				else
					stopAllNPCActions(npc)
					break
				end
			end
		else
			stopAllNPCActions(npc)
		end
	end
end

function setNPCTaskToNext(npc)
	setElementData(
		npc,"ped.thisTask",
		getElementData(npc,"ped.thisTask")+1,
		true
	)
end



