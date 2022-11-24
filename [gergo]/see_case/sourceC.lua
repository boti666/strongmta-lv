local screenX,screenY = guiGetScreenSize()
local panelState = false
local itemSize = 45
local rollSizeX = screenX
local rollSizeY = itemSize
local renderTarget = false
local shuffledItems = {}
local raffleState = false
local itemStartX = 0
local itemStopX = 0
local winnedItem = false
local buttons = {}
local activeButton = false
local selectedCase = false

addEvent("showTheRaffle",true)
addEventHandler("showTheRaffle",root,
	function (case)
		setElementData(localPlayer, "caseOpening", true)
		togglePanel(true)
		if case == "defaultEgg" or case == "redEgg" or case == "goldEgg" then
			easter = true
		end
		selectedCase = case
		startRaffle(selectedCase)
	end
)

function togglePanel(state)
	if state ~= panelState then
		if state then
			addEventHandler("onClientRender",root,renderTheRaffle)
			panelState = true
			winnedItem = false
			raffleState = false
			selectedCase = false
			showGetButton = false
		else
			removeEventHandler("onClientRender",root,renderTheRaffle)
			panelState = false
			winnedItem = false
			raffleState = false
			selectedCase = false
			easter = false
			showGetButton = false
			if isElement(renderTarget) then
				destroyElement(renderTarget)
				renderTarget = nil
			end
		end
	end
end

function startRaffle(case)
	shuffledItems = {}
	math.randomseed(getTickCount()+math.random(getTickCount()))
	while #shuffledItems <= 100 do
		local item = availableCases[case][math.random(#availableCases[case])]
		if math.random(1,100) <= item[2] then
			table.insert(shuffledItems,item)
		end
		shuffleTable(availableCases[case])
	end
	itemStartX = 0
	itemStopX =  math.ceil(#shuffledItems/2)*(itemSize+10)
	raffleState = getTickCount()
end

local lastItem = false
local itemTick = false
local bgAlpha = 0

local Raleway = dxCreateFont("files/Roboto.ttf", 12, false)
local Raleway16 = dxCreateFont("files/Roboto.ttf", 16, false)

function renderTheRaffle()
	if panelState then
		buttons = {}
		local now = getTickCount()
		local moveX = itemStartX
		if tonumber(raffleState) and now >= raffleState then
			local elapsedTime = now-raffleState
			local duration = 10000
			local progress = elapsedTime/duration
			moveX = interpolateBetween(
				itemStartX,0,0,
				-itemStopX,0,0,
				progress,"InOutQuad"
			)
			if progress >= 1 then
				raffleState = "endRaffle"
				itemStartX = -itemStopX
				itemTick = getTickCount()
			end
			bgAlpha = interpolateBetween(
				0, 0, 0,
				1, 0, 0,
				progress, "SineCurve"
			)
		end
		local imageSize = itemSize-20
		local y = screenY/2-itemSize
		logoW, logoH = 300, 300
		dxDrawImage(screenX/2-logoW/2, y - logoH - 20, logoW, logoH, ":see_carshop/files/images/logos/gta-sa.png", 0, 0, 0, tocolor(255, 255, 255, 200*bgAlpha))
		dxDrawRectangle(0,y-10,screenX,itemSize+20,tocolor(25,25,25))
		dxDrawRectangle(0,y-10,screenX,2,tocolor(61, 122, 188))
		dxDrawRectangle(0,y-10+itemSize+18,screenX,2,tocolor(61, 122, 188))

		for i = 1,#shuffledItems do
			local x = moveX+(i-1)*(itemSize+10)
			local image = ":see_items/files/items/"  ..  tostring(tonumber(shuffledItems[i][1]) - 1) .. ".png"
			dxDrawImage(x,y,itemSize,itemSize,image)
			if raffleState == "endRaffle" and not winnedItem then
				if (screenX-2)/2 >= x and (screenX-2)/2 <= x+itemSize then
					winnedItem = shuffledItems[i]
				end
			elseif (screenX-2)/2 >= x and (screenX-2)/2 <= x+itemSize then
				if lastItem ~= i then
					playSound("files/roll.mp3")
					lastItem = i
				end
			end
		end
		dxDrawText(exports.see_items:getItemName(shuffledItems[lastItem][1]), screenX/2 + 2, screenY/2 - 80 + 2, screenX/2 + 2, screenY/2 - 80 + 2, tocolor(0, 0, 0), 1, Raleway, "center", "center")
		dxDrawText(exports.see_items:getItemName(shuffledItems[lastItem][1]), screenX/2, screenY/2 - 80, screenX/2, screenY/2 - 80, tocolor(61, 122, 188), 1, Raleway, "center", "center")
		--dxDrawText(exports.see_items:getItemName(shuffledItems[lastItem][1]), screenX/2 + 2, screenY/2 - 50 + 2, screenX/2 + 2, screenY/2 - 50 + 2, tocolor(0, 0, 0), 1, Raleway, "center", "center")
		dxDrawRectangle((screenX-2)/2,y-10,2,itemSize+20,tocolor(188, 135, 61)) 
		if easter then
		end
		if winnedItem then
			local elapsedTime = now-itemTick
			local duration = 1000
			local progress = elapsedTime/duration

			imageSize = interpolateBetween(
				0,0,0,
				1,0,0,
				progress,"InOutQuad"
			)
			if progress >= 1 then
				showGetButton = true
			end
		end
		local absX,absY = getCursorPosition()
		if isCursorShowing() then
			absX,absY = absX*screenX,absY*screenY
		else
			absX,absY = -1,-1
		end
		local buttonW,buttonH = 300,40
		local buttonX,buttonY = (screenX-buttonW)*0.5,y+itemSize+20
		if winnedItem and showGetButton then
			local itemName = exports.see_items:getItemName(winnedItem[1])

			--outputChatBox("#3d7abc[StrongMTA - Láda]:#ffffff Sikeresen #3d7abckinyitottad #ffffffa ládát!", 255, 255, 255, true)
			outputChatBox("#3d7abc[StrongMTA - Láda]:#ffffff Nyitott item: #3d7abc" .. itemName, 255, 255, 255, true)

			triggerServerEvent("giveWinnedItem", localPlayer, localPlayer, selectedCase, winnedItem, "farAsFeelingsGoes")
			setElementData(localPlayer, "caseOpening", false)
			togglePanel(false)
		end
		activeButton = false
		if isCursorShowing() then
			for k,v in pairs(buttons) do
				if absX >= v[1] and absX <= v[1]+v[3] and absY >= v[2] and absY <= v[2]+v[4] then
					activeButton = k
					break
				end
			end
		end
	end
end

addEventHandler("onClientClick", root,
	function(button, state, _, _, _, _, _, clickedElement)
		if state == "up" then
			if button == "right" then
				if isElement(clickedElement) then
					local c1,c2,c3 = getElementPosition(clickedElement)
					local p1,p2,p3 = getElementPosition(localPlayer)
					if getElementData(clickedElement, "casePed") and (getDistanceBetweenPoints3D(p1,p2,p3,c1,c2,c3) < 3) then
						triggerServerEvent("onClientCaseClick", localPlayer, clickedElement)
					end
				end
			end
		end
	end
)