local screenSizeX, screenSizeY = guiGetScreenSize()

local progressBarSizeX = 300
local progressBarSizeY = 25
local progressBarPosnX = (screenSizeX - progressBarSizeX) * 0.5
local progressBarPosnY = screenSizeY - 100 - progressBarSizeY

local generationStarted = false
local generationProgress = 0
local generationStartTime = 0
local generatedNodes = {}
local generatedNodesByZones = {}
local generationRate = 1

local savingProcessActive = false

local surfaceMaterialsLookup = {}

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		if mapSizeX < 1 or mapSizeY < 1 then
			error("The mapSizeX/Y must be greater than zero.")
		end

		if mapSizeX > 16000 or mapSizeY > 16000 then
			error("The mapSizeX/Y must not exceed 16,000.")
		end

		if (mapSizeX / zoneSize) % 1 ~= 0 or (mapSizeY / zoneSize) % 1 ~= 0 then
			error("The zoneSize must divide the minimum and maximum mapSizeX/Y without a remainder.")
		end

		generationRate = math.floor(250 / math.min(frequencyOfNodes, 250))

		for i,v in ipairs(allowedSurfaceMaterials) do
			surfaceMaterialsLookup[v] = true
		end
	end
)

bindKey("f1", "down",
	function ()
		local rectangleSize = 100
		local rectangleCenter = {getElementPosition(localPlayer)}

		generationAreaBBox.minX = rectangleCenter[1] - rectangleSize
		generationAreaBBox.maxX = rectangleCenter[1] + rectangleSize
		generationAreaBBox.minY = rectangleCenter[2] - rectangleSize
		generationAreaBBox.maxY = rectangleCenter[2] + rectangleSize

		tryToStartGeneration()
	end
)

addEvent("onSavingProcessStateChange", true)
addEventHandler("onSavingProcessStateChange", resourceRoot,
	function (receivedState)
		savingProcessActive = receivedState
	end
)

function tryToStartGeneration()
	if savingProcessActive then
		print("Please wait, the nodes is still being saved..")
		return false
	end

	if not generationStarted then
		local generationThread = coroutine.create(generateNodes)

		if generationThread then
			coroutine.resume(generationThread)
			return true
		end
	end

	return false
end

function generateNodes()
	if not coroutine.running() or generationStarted then
		return
	end

	generationStarted = true
	generatedNodes = {}
	generatedNodesByZones = {}

	for k in pairs(generationAreaBBox) do
		generationAreaBBox[k] = math.floor(generationAreaBBox[k])
	end

	local areaSizeX = math.max(generationAreaBBox.minX, generationAreaBBox.maxX) - math.min(generationAreaBBox.minX, generationAreaBBox.maxX)
	local areaSizeY = math.max(generationAreaBBox.minY, generationAreaBBox.maxY) - math.min(generationAreaBBox.minY, generationAreaBBox.maxY)

	local nodeCountX = math.floor(areaSizeX / frequencyOfNodes)
	local nodeCountY = math.floor(areaSizeY / frequencyOfNodes)

	local totalNodeCountX = nodeCountX * frequencyOfNodes
	local totalNodeCountY = nodeCountY * frequencyOfNodes

	local totalNodeCount = nodeCountX * nodeCountY
	local checkedNodeCount = 0

	generationProgress = 0
	generationStartTime = getTickCount()
	savedPlayerPosition = {getElementPosition(localPlayer)}

	setCameraTarget(localPlayer)
	addEventHandler("onClientRender", root, renderProgress)

	for colX = 0, nodeCountX - 1 do
		local deltaX = colX / totalNodeCountX * frequencyOfNodes
		local pointX = generationAreaBBox.minX * (1 - deltaX) + generationAreaBBox.maxX * deltaX

		for rowY = 0, nodeCountY - 1 do
			local deltaY = rowY / totalNodeCountY * frequencyOfNodes
			local pointY = generationAreaBBox.minY * (1 - deltaY) + generationAreaBBox.maxY * deltaY

			local pointZ = getGroundPosition(pointX, pointY, 500)
			if not pointZ then
				pointZ = 0
			end

			local itsTimeToPause = rowY % generationRate == 0
			if itsTimeToPause then
				setElementPosition(localPlayer, pointX, pointY, pointZ)
				setCameraMatrix(pointX, pointY, pointZ + frequencyOfNodes, pointX, pointY, pointZ)
			end

			local _, hitX, hitY, hitZ, _, normalX, normalY, normalZ, materialId = processLineOfSight(
				pointX, pointY, pointZ + 50,
				pointX, pointY, pointZ - 50,
				true, false, false, true,
				true, false, false, false,
				nil, false
			)

			if hitZ then
				if surfaceMaterialsLookup[materialId] then
					local waterTestState = true

					if skipUnderWaterNodes then
						local waterLevel = getWaterLevel(hitX, hitY, hitZ) or 0

						if waterLevel - hitZ > 0 then
							waterTestState = false
						else
							if testLineAgainstWater(hitX, hitY, hitZ + 0.5, hitX, hitY, hitZ - 0.5) then
								waterTestState = false
							end
						end
					end

					if waterTestState then
						local normalLength = math.sqrt(normalX * normalX + normalY * normalY + normalZ * normalZ)
						local surfaceTheta = math.acos(normalZ / normalLength)
						local surfaceAlpha = math.atan2(normalY, normalX)

						hitX = math.floor(hitX)
						hitY = math.floor(hitY)

						local nodeIdx = #generatedNodes + 1
						local zoneIdx = getZoneIndex(hitX, hitY)

						if not generatedNodesByZones[zoneIdx] then
							generatedNodesByZones[zoneIdx] = {nodeIdx}
						else
							table.insert(generatedNodesByZones[zoneIdx], nodeIdx)
						end

						generatedNodes[nodeIdx] =
						{
							hitX,
							hitY,
							hitZ,
							surfaceTheta, -- X Angle (Radian)
							surfaceAlpha, -- Z Angle (Radian)
						}
					end
				end
			end

			generationProgress = checkedNodeCount / totalNodeCount
			checkedNodeCount = checkedNodeCount + 1

			if itsTimeToPause then
				local generationThread = coroutine.running()

				setTimer(
					function ()
						coroutine.resume(generationThread)
					end,
				50, 1)

				coroutine.yield()
			end
		end
	end

	local elapsedTime = getTickCount() - generationStartTime

	setTimer(
		function ()
			setCameraTarget(localPlayer)
			setElementPosition(localPlayer, unpack(savedPlayerPosition))

			removeEventHandler("onClientRender", root, renderProgress)

			generationStarted = false
			generationProgress = 0

			local zoneCounter = 0
			for k in pairs(generatedNodesByZones) do
				zoneCounter = zoneCounter + 1
			end

			savingProcessActive = true
			triggerServerEvent("saveGeneratedNodes", resourceRoot, generatedNodes, generatedNodesByZones)

			outputChatBox("Generation Results:", 255, 255, 255, true)
			outputChatBox(" - Number of Zones: #dead69" .. zoneCounter, 255, 255, 255, true)
			outputChatBox(" - Number of Nodes: #dead69" .. #generatedNodes, 255, 255, 255, true)
			outputChatBox(" - Elapsed Time: #dead69" .. formatSeconds(elapsedTime / 1000), 255, 255, 255, true)

			generatedNodes = nil
			generatedNodesByZones = nil
			collectgarbage("collect")
		end,
	1000, 1)
end

function renderProgress()
	dxDrawRectangle(0, 0, screenSizeX, screenSizeY, 0xFF222222)
	dxDrawThinRectangleBorder(progressBarPosnX, progressBarPosnY, progressBarSizeX, progressBarSizeY, 0xFFFFFFFF)
	dxDrawThinRectangleBorder(progressBarPosnX + 3, progressBarPosnY + 3, progressBarSizeX - 6, progressBarSizeY - 6, 0xFFFFFFFF)
	dxDrawRectangle(progressBarPosnX + 3, progressBarPosnY + 3, (progressBarSizeX - 6) * generationProgress, progressBarSizeY - 6, 0xFFFFFFFF)
	dxDrawText(string.format("%.f", math.round(generationProgress * 100), 1) .. "%", 0, progressBarPosnY - progressBarSizeY, screenSizeX, progressBarPosnY, 0xFFFFFFFF, 0.8, "bankgothic", "center", "center")
end

function dxDrawThinRectangleBorder(posnX, posnY, sizeX, sizeY, color)
	dxDrawRectangle(posnX - 1, posnY - 1, sizeX + 2, 1, color)
	dxDrawRectangle(posnX - 1, posnY, 1, sizeY, color)
	dxDrawRectangle(posnX + sizeX, posnY, 1, sizeY, color)
	dxDrawRectangle(posnX - 1, posnY + sizeY, sizeX + 2, 1, color)
end
