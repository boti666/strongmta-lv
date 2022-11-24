local renderEventAdded = false
local sharkAttacked = false

local elapsedTime = 0
local attackTime = math.random(10000, 30000)

local sharkColShapes = {}
local sharkPositions = {
	{-3000, 3000, -4000, 300},
	{-4000, -3000, 300, 4000},
	{3000, 4000, 300, 4000},
	{-3000, 3000, 3000, 4000}
}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		local txd = engineLoadTXD("files/shark.txd")

		if txd then
			local dff = engineLoadDFF("files/shark.dff")

			if dff then
				engineImportTXD(txd, 1607)
				engineImportTXD(txd, 1608)

				engineReplaceModel(dff, 1607)
				engineReplaceModel(dff, 1608)
			end
		end

		for i = 1, #sharkPositions do
			local v = sharkPositions[i]

			if v then
				sharkColShapes[i] = createColRectangle(v[1], v[3], v[2] - v[1], v[4] - v[3])
			end
		end

		if getElementData(localPlayer, "loggedIn") then
			if not renderEventAdded then
				addEventHandler("onClientPreRender", getRootElement(), preRenderFunc)
				renderEventAdded = true
			end
		end
	end
)

addEventHandler("onClientPlayerSpawn", getLocalPlayer(),
	function ()
		sharkAttacked = false
		attackTime = math.random(10000, 30000)
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if source == localPlayer then
			if dataName == "loggedIn" then
				if not renderEventAdded then
					addEventHandler("onClientPreRender", getRootElement(), preRenderFunc)
					renderEventAdded = true
				end
			end
		elseif dataName == "sharkAttacked" then
			if isElementStreamedIn(source) then
				local sourceX, sourceY, sourceZ = getElementPosition(source)
				local objectElement = createObject(1608, sourceX, sourceY, sourceZ - 30, 90, 0, 0)

				if isElement(objectElement) then
					moveObject(objectElement, 1000, sourceX, sourceY, sourceZ - 1, 0, 0, 0, "OutQuad")

					setTimer(
						function (sourcePlayer)
							playSound3D("files/splash.mp3", sourceX, sourceY, sourceZ)

							if sourcePlayer == localPlayer then
								setElementPosition(sourcePlayer, sourceX, sourceY, sourceZ - 1.25)
								triggerServerEvent("killedByShark", sourcePlayer)
							end
						end,
					750, 1, source)

					setTimer(
						function ()
							moveObject(objectElement, 1500, sourceX, sourceY, sourceZ - 30, 0, 0, 0, "InQuad")
							setTimer(destroyElement, 1000, 1, objectElement)
						end,
					1000, 1)
				end
			end
		end
	end
)

function preRenderFunc(deltaTime)
	local withinZone = false

	for i = 1, #sharkColShapes do
		if isElementWithinColShape(localPlayer, sharkColShapes[i]) then
			withinZone = true
			break
		end
	end

	if withinZone and isElementInWater(localPlayer) then
		elapsedTime = elapsedTime + deltaTime
	else
		if elapsedTime > 0 then
			if not getPedAnimation(localPlayer) then
				elapsedTime = 0
			end
		end
	end

	if not sharkAttacked then
		if elapsedTime >= attackTime then
			if math.random(1, 100) >= 50 then
				sharkAttacked = true
				setElementFrozen(localPlayer, true)
				setElementData(localPlayer, "sharkAttacked", getTickCount())
			end
		end
	end
end
