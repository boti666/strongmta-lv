local screenX, screenY = guiGetScreenSize()

local panelState = false
local panelWidth = 200
local panelHeight = 120
local panelPosX = (screenX / 2)
local panelPosY = (screenY / 2)
local panelMargin = 3

local playerElement = false
local panelFont = false

local moveDifferenceX, moveDifferenceY = 0, 0
local isMoving = false

local cuffModel = 2812

local leftCuffObj = {}
local rightCuffObj = {}

local cuffData = {}
local cuffAnim = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setElementData(localPlayer, "cuffed", false)
		setElementData(localPlayer, "visz", false)

		local txd = engineLoadTXD("cuff/files/cuff.txd")
		if txd then
			local dff = engineLoadDFF("cuff/files/cuff.dff")
			if dff then
				engineImportTXD(txd, cuffModel)
				engineReplaceModel(dff, cuffModel)
			end
		end

		engineLoadIFP("cuff/files/standing2.ifp", "cuff_standing2")
		engineLoadIFP("cuff/files/standing.ifp", "cuff_standing")
		engineLoadIFP("cuff/files/walking.ifp", "cuff_walking")
	end)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		if getElementData(localPlayer, "cuffed") or getElementData(localPlayer, "cuffAnimation") then
			setPedAnimation(localPlayer)
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "visz" then
			if getElementData(source, "visz") then
				cuffData[source] = getElementData(source, "visz")
			else
				cuffData[source] = getElementData(source, "cuffed") and 1 or nil
			end
		elseif dataName == "cuffed" then
			local cuffed = getElementData(source, "cuffed")
			local visz = getElementData(source, "visz") or 1

			if isElement(leftCuffObj[source]) then
				destroyElement(leftCuffObj[source])
			end
			
			if isElement(rightCuffObj[source]) then
				destroyElement(rightCuffObj[source])
			end

			leftCuffObj[source] = nil
			rightCuffObj[source] = nil

			cuffData[source] = cuffed and visz or nil

			if cuffed then
				setPedAnimation(source, "cuff_standing2", "standing", -1, true, false)

				cuffAnim[source] = 0

				leftCuffObj[source] = createObject(cuffModel, 0, 0, 0)
				setElementDoubleSided(leftCuffObj[source], true)
				exports.see_boneattach:attachElementToBone(leftCuffObj[source], source, 11, 0, 0, 0, 90, -45, 0)

				rightCuffObj[source] = createObject(cuffModel, 0, 0, 0)
				setElementDoubleSided(rightCuffObj[source], true)
				exports.see_boneattach:attachElementToBone(rightCuffObj[source], source, 12, 0, 0, 0, 90, -45, 0)

				local playerX, playerY, playerZ = getElementPosition(source)
				local soundEffect = playSound3D("cuff/files/cuff.mp3", playerX, playerY, playerZ)

				setElementInterior(soundEffect, getElementInterior(source))
				setElementDimension(soundEffect, getElementDimension(source))
				setSoundMaxDistance(soundEffect, 5)
			else
				setPedAnimation(source)
				cuffData[source] = nil
				cuffAnim[source] = nil
			end
		elseif dataName == "cuffAnimation" then
			local dataValue = getElementData(source, "cuffAnimation")
			
			if dataValue == 1 then
				setPedAnimation(source, "cuff_standing", "standing", -1, true, false)
			elseif dataValue == 2 then
				setPedAnimation(source, "cuff_walking", "walking", -1, true, true)
			elseif dataValue == 3 then
				setPedAnimation(source, "cuff_standing2", "standing", -1, true, false)
			else
				setPedAnimation(source)
			end

			if dataValue then
				cuffAnim[source] = dataValue
			else
				cuffAnim[source] = nil
			end
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		for k, v in pairs(cuffData) do
			if isElement(leftCuffObj[k]) and isElement(rightCuffObj[k]) then
				if isElementStreamedIn(k) then
					local interior = getElementInterior(k)
					local dimension = getElementDimension(k)

					if getElementDimension(leftCuffObj[k]) ~= dimension then
						setElementInterior(leftCuffObj[k], interior)
						setElementInterior(rightCuffObj[k], interior)
						setElementDimension(leftCuffObj[k], dimension)
						setElementDimension(rightCuffObj[k], dimension)
					end

					local lx, ly, lz = getElementPosition(leftCuffObj[k])
					local rx, ry, rz = getElementPosition(rightCuffObj[k])

					dxDrawLine3D(lx, ly, lz, rx, ry, rz, tocolor(75, 75, 75))

					if isElement(v) then
						local bx, by, bz = getPedBonePosition(v, 25)

						dxDrawLine3D(lx, ly, lz, bx, by, bz, tocolor(10, 10, 10))
					end
				end
			else
				if isElement(leftCuffObj[source]) then
					destroyElement(leftCuffObj[source])
				end

				if isElement(rightCuffObj[source]) then
					destroyElement(rightCuffObj[source])
				end

				leftCuffObj[source] = nil
				rightCuffObj[source] = nil

				cuffData[k] = nil
				cuffAnim[k] = nil
			end
		end

		if panelState then
			if isElement(playerElement) then
				local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
				local targetPosX, targetPosY, targetPosZ = getElementPosition(playerElement)

				if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, targetPosX, targetPosY, targetPosZ) > 4 then
					panelState = false
					playSound(":see_radio/files/hificlose.mp3", false)
					destroyFonts()
					return
				end

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

				local height = panelHeight
				local cuffed = getElementData(playerElement, "cuffed")

				if cuffed then
					height = panelHeight + 40
				end

				-- ** Háttér
				dxDrawRectangle(panelPosX, panelPosY, panelWidth, height, tocolor(0, 0, 0, 140))

				-- ** Keret
				dxDrawRectangle(panelPosX - panelMargin, panelPosY - panelMargin, panelWidth + (panelMargin * 2), panelMargin, tocolor(0, 0, 0, 200)) -- felső
				dxDrawRectangle(panelPosX - panelMargin, panelPosY + height, panelWidth + (panelMargin * 2), panelMargin, tocolor(0, 0, 0, 200)) -- alsó
				dxDrawRectangle(panelPosX - panelMargin, panelPosY, panelMargin, height, tocolor(0, 0, 0, 200)) -- bal
				dxDrawRectangle(panelPosX + panelWidth, panelPosY, panelMargin, height, tocolor(0, 0, 0, 200)) -- jobb

				-- ** Content
				dxDrawText(getElementData(playerElement, "visibleName"):gsub("_", " "), panelPosX + 5, panelPosY + 10, panelPosX + panelWidth - 2, panelPosY + 45, tocolor(61, 122, 188, 255), 0.75, panelFont, "left", "top", true, false, false, false, false)

				-- Bilincselés
				local buttonText = "Megbilincselés"
				if cuffed then
					buttonText = "Bilincs levétele"
				end

				local buttonColor = tocolor(255, 255, 255, 40)
				if absX >= panelPosX + 5 and absX <= panelPosX + 5 + panelWidth - 10 and absY >= panelPosY + 40 and absY <= panelPosY + 70 then
					buttonColor = tocolor(61, 122, 188, 140)

					if buttonText == "Bilincs levétele" then
						buttonColor = tocolor(215, 89, 89, 140)
					end
				end
				dxDrawRectangle(panelPosX + 5, panelPosY + 40, panelWidth - 10, 30, buttonColor)
				dxDrawText(buttonText, panelPosX + 5, panelPosY + 40, panelPosX + 5 + panelWidth - 10, panelPosY + 70, tocolor(255, 255, 255, 255), 1, panelFont, "center", "center", false, false, false, false, true)
				
				-- Megragadás
				local closeButtonY = 80

				if cuffed then
					local buttonText = "Visz"
					if getElementData(playerElement, "visz") then
						buttonText = "Elenged"
					end

					local buttonColor = tocolor(255, 255, 255, 40)
					if absX >= panelPosX + 5 and absX <= panelPosX + 5 + panelWidth - 10 and absY >= panelPosY + 80 and absY <= panelPosY + 110 then
						buttonColor = tocolor(61, 122, 188, 140)

						if buttonText == "Elenged" then
							buttonColor = tocolor(215, 89, 89, 140)
						end
					end
					dxDrawRectangle(panelPosX + 5, panelPosY + 80, panelWidth - 10, 30, buttonColor)
					dxDrawText(buttonText, panelPosX + 5, panelPosY + 80, panelPosX + 5 + panelWidth - 10, panelPosY + 110, tocolor(255, 255, 255, 255), 1, panelFont, "center", "center", false, false, false, false, true)
					
					closeButtonY = 120
				end

				-- Kilépés
				local buttonColor = tocolor(255, 255, 255, 40)
				if absX >= panelPosX + 5 and absX <= panelPosX + 5 + panelWidth - 10 and absY >= panelPosY + closeButtonY and absY <= panelPosY + closeButtonY + 30 then
					buttonColor = tocolor(215, 89, 89, 140)
				end
				dxDrawRectangle(panelPosX + 5, panelPosY + closeButtonY, panelWidth - 10, 30, buttonColor)
				dxDrawText("Bezárás", panelPosX + 5, panelPosY + closeButtonY, panelPosX + 5 + panelWidth - 10, panelPosY + closeButtonY + 30, tocolor(255, 255, 255, 255), 1, panelFont, "center", "center", false, false, false, false, true)
			else
				panelState = false
				destroyFonts()
			end
		end
	end)

addEventHandler("onClientPreRender", getRootElement(),
	function ()
		for k, v in pairs(cuffData) do
			if isElementStreamedIn(k) and isElement(v) then
				if not isPedInVehicle(v) then
					local sourceX, sourceY, sourceZ = getElementPosition(k)
					local targetX, targetY, targetZ = getElementPosition(v)

					local deltaX = targetX - sourceX
					local deltaY = targetY - sourceY
					local distance = deltaX * deltaX + deltaY * deltaY

					if distance >= 2 then
						local sourceRotX, sourceRotY, sourceRotZ = getElementRotation(k)

						setElementRotation(k, sourceRotX, sourceRotY, -math.deg(math.atan2(deltaX, deltaY)), "default", true)

						if cuffAnim[source] ~= 2 then
							cuffAnim[source] = 2
							setElementData(k, "cuffAnimation", 2)
						end
					elseif cuffAnim[source] ~= 1 then
						cuffAnim[source] = 1
						setElementData(k, "cuffAnimation", 1)
					end
				end
			end
		end
	end)

function createFonts()
	destroyFonts()
	panelFont = dxCreateFont("files/fonts/Roboto.ttf", 13, false, "antialiased")
end

function destroyFonts()
	if isElement(panelFont) then
		destroyElement(panelFont)
	end
end

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
		if state == "up" then
			if button == "right" then
				if not panelState then
					if isElement(clickedElement) then
						if getElementType(clickedElement) == "player" then
							if clickedElement ~= localPlayer then
								local playerPosX, playerPosY, playerPosZ = getElementPosition(localPlayer)
								local targetPosX, targetPosY, targetPosZ = getElementPosition(clickedElement)

								if getDistanceBetweenPoints3D(playerPosX, playerPosY, playerPosZ, targetPosX, targetPosY, targetPosZ) <= 5 then
									if exports.see_groups:isPlayerHavePermission(localPlayer, "cuff") then
										createFonts()
										
										panelState = true
										panelPosX = absoluteX
										panelPosY = absoluteY

										playerElement = clickedElement

										playSound(":see_radio/files/hifiopen.mp3", false)
									end
								end
							end
						end
					end
				end
			else
				if button == "left" then
					isMoving = false

					if panelState then
						if isElement(playerElement) then
							local closeButtonY = 80

							if absoluteX >= panelPosX + 5 and absoluteX <= panelPosX + 5 + panelWidth - 10 and absoluteY >= panelPosY + 40 and absoluteY <= panelPosY + 70 then
								--triggerServerEvent("cuffPlayer", localPlayer, playerElement)
								executeCommandHandler("cuff", "1")
								iprint(playerElement)
								panelState = false
								playSound(":see_radio/files/hificlose.mp3", false)
								destroyFonts()
							end

							if getElementData(playerElement, "cuffed") then
								if absoluteX >= panelPosX + 5 and absoluteX <= panelPosX + 5 + panelWidth - 10 and absoluteY >= panelPosY + 80 and absoluteY <= panelPosY + 110 then
									triggerServerEvent("viszPlayer", localPlayer, playerElement)
									panelState = false
									playSound(":see_radio/files/hificlose.mp3", false)
									destroyFonts()
								end
								closeButtonY = 120
							end

							if absoluteX >= panelPosX + 5 and absoluteX <= panelPosX + 5 + panelWidth - 10 and absoluteY >= panelPosY + closeButtonY and absoluteY <= panelPosY + closeButtonY + 30 then
								panelState = false
								playSound(":see_radio/files/hificlose.mp3", false)
								destroyFonts()
							end
						end
					end
				end
			end
		else
			if state == "down" then
				if button == "left" then
					if panelState then
						if absoluteX >= panelPosX and absoluteX <= panelPosX + panelWidth and absoluteY >= panelPosY and absoluteY <= panelPosY + 30 then
							moveDifferenceX = absoluteX - panelPosX
							moveDifferenceY = absoluteY - panelPosY

							isMoving = true
						end
					end
				end
			end
		end
	end)