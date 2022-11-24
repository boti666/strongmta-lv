local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local panelState = false
local panelFont = false

local panelWidth = respc(500)
local panelHeight = respc(425)

local panelPosX = screenX / 2 - panelWidth / 2
local panelPosY = screenY / 2 - panelHeight / 2

local titleHeight = respc(30)

local activeButton = false

local panelIsMoving = false
local moveDifferenceX = 0
local moveDifferenceY = 0

local weaponList = {}
local mainList = {
	{"M4 Skill", "Gépkarabélyok", 78, 200, 1000},
	{"AK-47 Skill", "Gépkarabélyok", 77, 200, 1000},
	{"Uzi & Tec-9 Skill", "Géppisztolyok", 75, 50, 1000},
	{"P90 Skill", "Géppisztolyok", 76, 250, 1000},
	{"Glock-17 Skill", "Pisztolyok", 69, 40, 1000},
	{"Hangtompítós Skill", "Pisztolyok", 70, 500, 1000},
	{"Desert Eagle Skill", "Pisztolyok", 71, 200, 1000},
	{"Sörétes Skill", "Sörétesek", 72, 200, 1000},
	{"Rövid csövű Skill", "Sörétesek", 73, 200, 1000},
	{"SPAZ-12 Skill", "Sörétesek", 74, 200, 1000}
}

function spairs(t, order)
	local keys = {}

	for k in pairs(t) do
		keys[#keys+1] = k
	end

	if order then
		table.sort(keys,
			function (a, b)
				return order(t, a, b)
			end
		)
	else
		table.sort(keys)
	end

	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

function processCategories()
	local categories = {}

	weaponList = {}

	local counter = 0

	for i = 1, #mainList do
		local dat = mainList[i]
		local cat = dat[2]

		if not categories[cat] then
			categories[cat] = true
			weaponList[1 + counter] = {cat, false}
			counter = counter + 1
		end

		weaponList[1 + counter] = dat
		weaponList[1 + counter][6] = nil
		weaponList[1 + counter][7] = false

		counter = counter + 1
	end
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		processCategories()
	end
)

function togglePanel(state)
	if state ~= panelState then
		panelState = state

		if panelState then
			panelFont = dxCreateFont("files/Roboto.ttf", respc(18), false, "antialiased")

			addEventHandler("onClientRender", getRootElement(), renderThePanel)
			addEventHandler("onClientClick", getRootElement(), clickOnPanel)

			playSound(":see_shootingrange/files/sounds/skillopen.mp3")
		else
			removeEventHandler("onClientRender", getRootElement(), renderThePanel)
			removeEventHandler("onClientClick", getRootElement(), clickOnPanel)

			if isElement(panelFont) then
				destroyElement(panelFont)
			end

			panelFont = nil

			playSound(":see_shootingrange/files/sounds/skillclose.mp3")
		end
	end
end

function isPanelOpen()
	return panelState
end

function clickOnPanel(button, state, absX, absY)
	if button == "left" then
		if state == "down" then
			if absX >= panelPosX and absX <= panelPosX + panelWidth - respc(28) - respc(5) and absY >= panelPosY and absY <= panelPosY + titleHeight then
				panelIsMoving = true
				moveDifferenceX = absX - panelPosX
				moveDifferenceY = absY - panelPosY
			end
		else
			if state == "up" then
				if panelIsMoving then
					panelIsMoving = false
					moveDifferenceX = 0
					moveDifferenceY = 0
				end

				if activeButton then
					if activeButton == "exit" then
						togglePanel(false)
					else
						local button = split(activeButton, "_")

						if button[1] == "downgrade" then
							if getPedStat(localPlayer, button[2]) > 0 then
								triggerServerEvent("downgradeWeaponSkill", localPlayer, button[2])
							else
								exports.see_hud:showInfobox("error", "Nincs skillpontod erre a fegyverre!")
							end
							togglePanel(false)
						end
					end
				end
			end
		end
	end
end

function renderThePanel()
	-- ** Keret
	dxDrawRectangle(panelPosX - 2, panelPosY, 2, panelHeight, tocolor(0, 0, 0, 255)) -- bal
	dxDrawRectangle(panelPosX + panelWidth, panelPosY, 2, panelHeight, tocolor(0, 0, 0, 255)) -- jobb
	dxDrawRectangle(panelPosX - 2, panelPosY - 2, panelWidth + 4, 2, tocolor(0, 0, 0, 255)) -- felső
	dxDrawRectangle(panelPosX - 2, panelPosY + panelHeight, panelWidth + 4, 2, tocolor(0, 0, 0, 255)) -- alsó

	-- ** Háttér
	dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(0, 0, 0, 100))
	dxDrawImage(panelPosX, panelPosY + titleHeight, panelWidth, panelHeight - titleHeight, ":see_hud/files/images/vin.png")

	-- ** Cím
	dxDrawRectangle(panelPosX, panelPosY, panelWidth, titleHeight, tocolor(0, 0, 0, 200))
	dxDrawText("#ffffffStrong#3d7abcMTA #ffffff- Fegyverskill", panelPosX + respc(7.5), panelPosY, panelPosX + panelWidth, panelPosY + titleHeight, tocolor(255, 255, 255), 0.8, panelFont, "left", "center", false, false, false, true)

	-- ** Content
	local buttons = {}

	buttons.exit = {panelPosX + panelWidth - respc(28) - respc(5), panelPosY + titleHeight / 2 - respc(14), respc(28), respc(28)}

	if activeButton == "exit" then
		dxDrawImage(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], "files/close.png", 0, 0, 0, tocolor(215, 89, 89))
	else
		dxDrawImage(buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], "files/close.png", 0, 0, 0, tocolor(255, 255, 255))
	end

	local oneSize = (panelHeight - titleHeight) / 14

	for i = 1, 14 do
		local rowY = panelPosY + titleHeight + oneSize * (i - 1)

		if i % 2 == 1 then
			dxDrawRectangle(panelPosX, rowY, panelWidth, oneSize, tocolor(0, 0, 0, 125))
		else
			dxDrawRectangle(panelPosX, rowY, panelWidth, oneSize, tocolor(0, 0, 0, 150))
		end

		local data = weaponList[i]

		if data then
			if data[2] then
				local statLevel = getPedStat(localPlayer, data[3])

				if statLevel > 0 then
					dxDrawText(data[1] .. " #3d7abc(" .. statLevel .. "/1000)", panelPosX + respc(15), rowY, 0, rowY + oneSize, tocolor(255, 255, 255), 0.65, panelFont, "left", "center", false, false, false, true)
				else
					dxDrawText(data[1] .. " #d75959(" .. statLevel .. "/1000)", panelPosX + respc(15), rowY, 0, rowY + oneSize, tocolor(255, 255, 255), 0.65, panelFont, "left", "center", false, false, false, true)
				end

				local buttonName = "downgrade_" .. data[3]

				buttons[buttonName] = {panelPosX + panelWidth - respc(160), rowY + respc(4), respc(150), oneSize - respc(8)}

				if statLevel > 0 then
					local progress = buttons[buttonName][3] - math.floor((1000 - statLevel) / 1000 * buttons[buttonName][3])
					local alpha = 200

					if activeButton == buttonName then
						alpha = 255
					end

					dxDrawRectangle(buttons[buttonName][1] + progress, buttons[buttonName][2], buttons[buttonName][3] - progress, buttons[buttonName][4], tocolor(215, 89, 89, alpha))
					dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], progress, buttons[buttonName][4], tocolor(61, 122, 188, alpha))

					dxDrawText("Csökkentés (-1)", buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][1] + buttons[buttonName][3], buttons[buttonName][2] + buttons[buttonName][4], tocolor(0, 0, 0), 0.55, panelFont, "center", "center")
				else
					if activeButton == buttonName then
						dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][3], buttons[buttonName][4], tocolor(215, 89, 89))
					else
						dxDrawRectangle(buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][3], buttons[buttonName][4], tocolor(215, 89, 89, 200))
					end
					dxDrawText("Nincs pont!", buttons[buttonName][1], buttons[buttonName][2], buttons[buttonName][1] + buttons[buttonName][3], buttons[buttonName][2] + buttons[buttonName][4], tocolor(0, 0, 0), 0.55, panelFont, "center", "center")
				end
			else
				dxDrawText(data[1], panelPosX + respc(5), rowY, 0, rowY + oneSize, tocolor(61, 122, 188), 0.65, panelFont, "left", "center")
			end
		end
	end

	-- ** Button handler
	activeButton = false

	if isCursorShowing() then
		local relX, relY = getCursorPosition()
		local absX, absY = relX * screenX, relY * screenY

		if panelIsMoving then
			panelPosX = absX - moveDifferenceX
			panelPosY = absY - moveDifferenceY
		else
			for k, v in pairs(buttons) do
				if absX >= v[1] and absX <= v[1] + v[3] and absY >= v[2] and absY <= v[2] + v[4] then
					activeButton = k
					break
				end
			end
		end
	end
end
