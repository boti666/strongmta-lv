local spawnedAnimals = {}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		setTimer(doRefreshing, 2000, 0)

		for k, v in ipairs(availableAnimals) do
			local animalElement = createPed(availableTypes[v.animalType].skin, v.waypoints[1][1], v.waypoints[1][2], v.waypoints[1][3])

			if isElement(animalElement) then
				local colShapeElement = createColSphere(v.waypoints[1][1], v.waypoints[1][2], v.waypoints[1][3], 10)

				if isElement(colShapeElement) then
					attachElements(colShapeElement, animalElement)
					setElementData(colShapeElement, "animalElement", animalElement)

					setElementData(animalElement, "animalId", k)
					setElementData(animalElement, "animalWaypoint", 2)

					setElementData(animalElement, "huntingAnimal.isControllable", true)
					setElementData(animalElement, "huntingAnimal.walk_speed", "walk")
					setElementData(animalElement, "huntingAnimal.accuracy", 1)
					setElementData(animalElement, "huntingAnimal.currentStance", "neutral")

					if v.health then
						setElementData(animalElement, "huntingAnimal.health", v.health)
					else
						if availableTypes[v.animalType].health then
							setElementData(animalElement, "huntingAnimal.health", availableTypes[v.animalType].health)
						end
					end

					if v.hitDamage then
						setElementData(animalElement, "hitDamage", v.hitDamage)
					else
						if availableTypes[v.animalType].hitDamage then
							setElementData(animalElement, "hitDamage", availableTypes[v.animalType].hitDamage)
						end
					end

					processAnimalWaypoints(animalElement)

					spawnedAnimals[k] = animalElement
				end
			end
		end
	end
)

function processAnimalWaypoints(animalElement)
	local animalId = getElementData(animalElement, "animalId")
	local waypoints = availableAnimals[animalId].waypoints

	clearPedTasks(animalElement)

	for i = 1, #waypoints do
		if waypoints[i] and waypoints[i + 1] then
			addPedTask(animalElement, {"walkAlongLine", waypoints[i][1], waypoints[i][2], waypoints[i][3], waypoints[i + 1][1], waypoints[i + 1][2], waypoints[i + 1][3], 1, 1})
		end
	end

	addPedTask(animalElement, {"walkAlongLine", waypoints[#waypoints][1], waypoints[#waypoints][2], waypoints[#waypoints][3], waypoints[1][1], waypoints[1][2], waypoints[1][3], 1, 1})
end

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "huntingAnimal.thisTask" then
			local animalId = getElementData(source, "animalId")
			local newValue = getElementData(source, dataName)

			if oldValue and newValue then
				local lastTask = getElementData(source, "huntingAnimal.task." .. oldValue)
				local nextTask = getElementData(source, "huntingAnimal.task." .. newValue)

				if lastTask and not nextTask then
					local walkingSpeed = getElementData(source, "huntingAnimal.walk_speed")

					if walkingSpeed == "run" then
						setElementData(source, "huntingAnimal.walk_speed", "walk")
						setElementData(source, "huntingAnimal.currentStance", "neutral")
					end

					processAnimalWaypoints(source)
				end
			end
		end
	end
)

addEventHandler("onColShapeHit", getResourceRootElement(),
	function (hitElement, matchingDimension)
		if getElementType(hitElement) == "player" then
			if matchingDimension then
				local animalElement = getElementData(source, "animalElement")

				if isElement(animalElement) then
					local thisTask = getElementData(animalElement, "huntingAnimal.thisTask")

					if thisTask then
						local selectedTask = getElementData(animalElement, "huntingAnimal.task." .. thisTask)

						if selectedTask then
							if selectedTask[1] ~= "killPed" then -- eddig várt, most támad
								local animalPos = getElementData(animalElement, "animalPos")

								if not animalPos then
									local walkSpeed = getElementData(animalElement, "huntingAnimal.walk_speed")

									if walkSpeed == "walk" then -- csak akkor támadjon ha már visszaért az előző támadásból (biztonsági okok)
										local animalId = getElementData(animalElement, "animalId")
										local animalX, animalY, animalZ = getElementPosition(animalElement)

										setElementData(animalElement, "animalPos", {animalX, animalY, animalZ})
										setElementData(animalElement, "huntingAnimal.walk_speed", "run")
										setElementData(animalElement, "huntingAnimal.currentStance", "agressive")

										setPedTask(animalElement, {"killPed", hitElement, 5, 1})

										triggerClientEvent(getElementsByType("player"), "animalAttackSound", hitElement, animalElement, animalId)
									end
								end
							end
						end
					end
				end
			end
		end
	end
)

addEvent("animalAttackSound", true)
addEventHandler("animalAttackSound", getRootElement(),
	function (animalId)
		if animalId then
			local animalElement = spawnedAnimals[animalId]

			if isElement(animalElement) then
				triggerClientEvent(getElementsByType("player"), "animalAttackSound", source, animalElement, animalId)
			end
		end
	end
)

addEventHandler("onPedWasted", getResourceRootElement(),
	function ()
		local animalId = getElementData(source, "animalId")

		if animalId then
			triggerClientEvent(getElementsByType("player"), "animalDeathSound", resourceRoot, source, animalId)
		end
	end)

function doRefreshing()
	for animalId, animalElement in pairs(spawnedAnimals) do
		local thisTask = getElementData(animalElement, "huntingAnimal.thisTask")

		if thisTask then
			local selectedTask = getElementData(animalElement, "huntingAnimal.task." .. thisTask)

			if selectedTask then
				if selectedTask[1] == "killPed" then -- ha a vad eltávolodott nagyon akkor menjen vissza (beakadások elkerülése stb..)
					local animalX, animalY, animalZ = getElementPosition(animalElement)
					local animalBasePos = getElementData(animalElement, "animalPos")

					if getDistanceBetweenPoints3D(animalX, animalY, animalZ, animalBasePos[1], animalBasePos[2], animalBasePos[3]) >= 30 then
						local animalWaypoint = getElementData(animalElement, "animalWaypoint")
						local waypoint = availableAnimals[animalId].waypoints[animalWaypoint]

						setElementData(animalElement, "animalPos", false)
						setElementData(animalElement, "huntingAnimal.walk_speed", "run")
						setElementData(animalElement, "huntingAnimal.currentStance", "agressive")

						setPedTask(animalElement, {"walkAlongLine", animalBasePos[1], animalBasePos[2], animalBasePos[3], waypoint[1], waypoint[2], waypoint[3], 1, 1})
					end
				end
			end
		end
	end
end

function addPedTask(pedElement, selectedTask)
	if isElement(pedElement) then
		local lastTask = getElementData(pedElement, "huntingAnimal.lastTask")

		if not lastTask then
			lastTask = 1
			setElementData(pedElement, "huntingAnimal.thisTask", 1)
		else
			lastTask = lastTask + 1
		end

		setElementData(pedElement, "huntingAnimal.task." .. lastTask, selectedTask)
		setElementData(pedElement, "huntingAnimal.lastTask", lastTask)

		return true
	else
		return false
	end
end

function clearPedTasks(pedElement)
	if isElement(pedElement) then
		local thisTask = getElementData(pedElement, "huntingAnimal.thisTask")

		if thisTask then
			local lastTask = getElementData(pedElement, "huntingAnimal.lastTask")

			for currentTask = thisTask, lastTask do
				removeElementData(pedElement,"huntingAnimal.task." .. currentTask)
			end

			removeElementData(pedElement, "huntingAnimal.thisTask")
			removeElementData(pedElement, "huntingAnimal.lastTask")

			return true
		end
	else
		return false
	end
end

function setPedTask(pedElement, selectedTask)
	if isElement(pedElement) then
		clearPedTasks(pedElement)
		setElementData(pedElement, "huntingAnimal.task.1", selectedTask)
		setElementData(pedElement, "huntingAnimal.thisTask", 1)
		setElementData(pedElement, "huntingAnimal.lastTask", 1)
		return true
	else
		return false
	end
end