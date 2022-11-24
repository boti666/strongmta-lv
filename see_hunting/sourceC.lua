local screenX, screenY = guiGetScreenSize()

local forestPositions = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function()
		addEventHandler("onClientPreRender", getRootElement(), cycleNPCs)
		
		if debugMode then
			addEventHandler("onClientRender", getRootElement(), renderWayPoints)
		end
		
		for k, v in ipairs(forestPositions) do
			local soundElement = playSound3D("files/sounds/forestsound.mp3", v[1], v[2], v[3], true)
			if isElement(soundElement) then
				setSoundMaxDistance(soundElement, 1200)
				setSoundVolume(soundElement, 1)
			end
		end
	end,
true, "high+999999")

addEventHandler("onClientPedDamage", getResourceRootElement(),
	function (attacker)
		if isElement(attacker) then
			if getElementType(attacker) == "player" then
				if getElementData(source, "huntingAnimal.isControllable") then
					local thisTask = getElementData(source, "huntingAnimal.thisTask")

					if thisTask then
						local selectedTask = getElementData(source, "huntingAnimal.task." .. thisTask)

						if selectedTask then
							if selectedTask[1] ~= "killPed" then
								local animalId = getElementData(source, "animalId")

								if animalId then
									local animalPos = getElementData(source, "animalPos")

									if not animalPos then
										local animalX, animalY, animalZ = getElementPosition(source)

										setElementData(source, "animalPos", {animalX, animalY, animalZ})
										setElementData(source, "huntingAnimal.walk_speed", "run")
										setElementData(source, "huntingAnimal.currentStance", "agressive")

										clearPedTasks(source)
										addPedTask(source, {"killPed", attacker, 5, 1})

										triggerServerEvent("animalAttackSound", localPlayer, animalId)
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
	function (animalElement, animalId)
		if isElement(animalElement) then
			animalId = tonumber(animalId)

			if animalId then
				local animalType = availableAnimals[animalId].animalType

				if animalType then
					local soundElement = playSound3D(availableTypes[animalType].attackSound, getElementPosition(animalElement))
					setSoundMaxDistance(soundElement, 240)
					setSoundVolume(soundElement, 1)
					attachElements(soundElement, animalElement)
				end
			end
		end
	end
)

addEvent("animalDeathSound", true)
addEventHandler("animalDeathSound", getRootElement(),
	function (animalElement, animalId)
		if isElement(animalElement) then
			animalId = tonumber(animalId)

			if animalId then
				local animalType = availableAnimals[animalId].animalType

				if animalType then
					local soundElement = playSound3D(availableTypes[animalType].deathSound, getElementPosition(animalElement))
					attachElements(soundElement, animalElement)
				end
			end
		end
	end
)

function renderWayPoints()
	for k, v in ipairs(availableAnimals) do
		for i = 1, #v.waypoints do
			if v.waypoints[i] and v.waypoints[i + 1] then
				dxDrawLine3D(v.waypoints[i][1], v.waypoints[i][2], v.waypoints[i][3], v.waypoints[i + 1][1], v.waypoints[i + 1][2], v.waypoints[i + 1][3], tocolor(255, 0, 0, 50), 8)
			end
		end

		dxDrawLine3D(v.waypoints[1][1], v.waypoints[1][2], v.waypoints[1][3], v.waypoints[#v.waypoints][1], v.waypoints[#v.waypoints][2], v.waypoints[#v.waypoints][3], tocolor(255, 0, 0, 50), 8)
	end
end

function getPercentageInLine(x, y, x1, y1, x2, y2)
	x, y = x - x1, y - y1
	local yx, yy = x2 - x1, y2 - y1
	
	return (x * yx + y * yy) / ( yx * yx + yy * yy)
end

function getAngleInBend(x, y, x0, y0, x1, y1, x2, y2)
	x, y = x - x0, y - y0
	local yx, yy = x1 - x0, y1 - y0
	local xx, xy = x2 - x0, y2 - y0
	local rx = (x * yy - y * yx) / (xx * yy - xy * yx)
	local ry = (x * xy - y * xx) / (yx * xy - yy * xx)

	return math.atan2(rx, ry)
end

function getPosFromBend(angle, x0, y0, x1, y1, x2, y2)
	local yx, yy = x1 - x0, y1 - y0 
	local xx, xy = x2 - x0, y2 - y0
	local rx, ry = math.sin(angle), math.cos(angle)

	return
		rx * xx + ry * yx + x0,
		rx * xy + ry * yy + y0
end

function stopAllNPCActions(npc)
	setPedControlState(npc, "forwards", false)
	setPedControlState(npc, "sprint", false)
	setPedControlState(npc, "walk", false)
	setPedControlState(npc, "aim_weapon", false)
	setPedControlState(npc, "fire", false)
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
	setPedControlState(npc,"aim_weapon",true)
	setPedControlState(npc,"fire",not getPedControlState(npc,"fire"))
end

function makeNPCShootAtElement(npc,target)
	local x,y,z = getElementPosition(target)
	local vx,vy,vz = getElementVelocity(target)
	local tgtype = getElementType(target)
	if tgtype == "ped" or tgtype == "player" then
		x,y,z = getPedBonePosition(target,3)
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
		setPedControlState(npc, "aim_weapon", false)
		setPedControlState(npc, "fire", false)
	end
	if distsq > followdist*followdist then
		makeNPCWalkToPos(npc,tx,ty)
	else
		setPedControlState(npc, "forwards", false)
		setPedControlState(npc, "sprint", false)
		setPedControlState(npc, "walk", false)
	end

	return false
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
				setElementData(pedElement, "huntingAnimal.task." .. currentTask, nil)
			end

			setElementData(pedElement, "huntingAnimal.thisTask", nil)
			setElementData(pedElement, "huntingAnimal.lastTask", nil)

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

function cycleNPCs()
	local streamedPeds = {}

	for k, v in ipairs(getElementsByType("ped", resourceRoot, true)) do
		if getElementData(v, "huntingAnimal.isControllable") then
			streamedPeds[v] = true
		end
	end

	for ped in pairs(streamedPeds) do
		if getElementHealth(ped) >= 1 then
			while true do
				local thisTask = getElementData(ped, "huntingAnimal.thisTask")

				if thisTask then
					local selectedTask = getElementData(ped, "huntingAnimal.task." .. thisTask)

					if selectedTask then
						if performTask[selectedTask[1]](ped, selectedTask) then
							setNPCTaskToNext(ped)
						else
							break
						end
					else
						stopAllNPCActions(ped)
						break
					end
				else
					stopAllNPCActions(ped)
					break
				end
			end
		else
			stopAllNPCActions(ped)
		end
	end
end

function setNPCTaskToNext(npc)
	setElementData(npc, "huntingAnimal.thisTask", getElementData(npc, "huntingAnimal.thisTask") + 1, true)
end

function getNPCWalkSpeed(npc)
	return getElementData(npc, "huntingAnimal.walk_speed")
end

function getNPCWeaponAccuracy(npc)
	return getElementData(npc, "huntingAnimal.accuracy")
end