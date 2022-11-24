local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.see_hud:getResponsiveMultipler()

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local placedTable = false

addCommandHandler("createbilliard",
	function (commandName)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			if not placedTable then
				if isElement(placedTable) then
					destroyElement(placedTable)
				end

				placedTable = createObject(2964, 0, 0, 0)

				setElementCollisionsEnabled(placedTable, false)
				setElementAlpha(placedTable, 175)
				setElementInterior(placedTable, getElementInterior(localPlayer))
				setElementDimension(placedTable, getElementDimension(localPlayer))

				addEventHandler("onClientRender", getRootElement(), tablePlaceRender)
				addEventHandler("onClientKey", getRootElement(), tablePlaceKey)

				outputChatBox("#3d7abc[StrongMTA - Billiárd]: #ffffffBilliárd asztal létrehozás mód #3d7abcbekapcsolva!", 255, 255, 255, true)
				outputChatBox("#3d7abc[StrongMTA - Billiárd]: #ffffffAz asztal #3d7abclerakásához #ffffffnyomd meg az #3d7abcBAL CTRL #ffffffgombot.", 255, 255, 255, true)
				outputChatBox("#3d7abc[StrongMTA - Billiárd]: #ffffffA #d75959kilépéshez #ffffffírd be a #d75959/" .. commandName .. " #ffffffparancsot.", 255, 255, 255, true)
			else
				removeEventHandler("onClientRender", getRootElement(), tablePlaceRender)
				removeEventHandler("onClientKey", getRootElement(), tablePlaceKey)

				if isElement(placedTable) then
					destroyElement(placedTable)
				end
				placedTable = nil

				outputChatBox("#3d7abc[StrongMTA - Billiárd]: #ffffffBilliárd asztal létrehozás mód #d75959kikapcsolva!", 255, 255, 255, true)
			end
		end
	end)

function tablePlaceRender()
	if placedTable then
		local x, y, z = getElementPosition(localPlayer)
		local rz = select(3, getElementRotation(localPlayer))

		setElementPosition(placedTable, x, y, z - 1.1)
		setElementRotation(placedTable, 0, 0, math.ceil(math.floor(rz * 5) / 5) - 90)
	end
end

function tablePlaceKey(button, state)
	if isElement(placedTable) then
		if button == "lctrl" and state then
			local x, y, z = getElementPosition(placedTable)
			local rz = select(3, getElementRotation(placedTable))
			local interior = getElementInterior(placedTable)
			local dimension = getElementDimension(placedTable)

			triggerServerEvent("placeThePoolTable", localPlayer, {x, y, z, rz, interior, dimension})

			if isElement(placedTable) then
				destroyElement(placedTable)
			end
			placedTable = nil

			removeEventHandler("onClientRender", getRootElement(), tablePlaceRender)
			removeEventHandler("onClientKey", getRootElement(), tablePlaceKey)
		end
	end
end

local debugMode = false
local poolTables = {}
local syncTables = {}
local pottedBalls = {}
local gameActive = false

local standingTableId = false
local standingTableObj = false

local holdRMB = false
local holdLMB = false

local forcePickStart = false
local forcePickState = 0
local forcePosition = {0, 0}

local aimLength = "med"
local nextAnimSync = 0

local pedRot = 0

local hoverBallId = false
local cueRotCorrection = 0
local maxRotCorrection = math.rad(7.5)
local syncTableId = false

local Roboto = false

addCommandHandler("nearbybilliard",
	function (commandName, maxDistance)
		if getElementData(localPlayer, "acc.adminLevel") >= 9 then
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
			local nearby = {}

			maxDistance = tonumber(maxDistance) or 15

			for i, v in ipairs(getElementsByType("object", resourceRoot, true)) do
				local tableId = getElementData(v, "poolTableID")

				if tableId then
					local targetX, targetY, targetZ = getElementPosition(v)
					local distance = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)

					if distance <= maxDistance then
						table.insert(nearby, {tableId, distance})
					end
				end
			end

			if #nearby > 0 then
				outputChatBox("#3d7abc[StrongMTA - Billiárd]: #ffffffKözeledben lévő asztalok (" .. maxDistance .. " yard):", 255, 255, 255, true)

				for i, v in ipairs(nearby) do
					outputChatBox("    * #3d7abcAzonosító: #ffffff" .. v[1] .. " - " .. math.floor(v[2] * 500) / 500 .. " yard", 255, 255, 255, true)
				end
			else
				outputChatBox("#d75959[StrongMTA - Billiárd]: #ffffffNincs egyetlen asztal sem a közeledben.", 255, 255, 255, true)
			end
		end
	end)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in ipairs({2995, 2996, 2997, 2998, 2999, 3000, 3001, 3002, 3003, 3100, 3101, 3102, 3103, 3104, 3105, 3106, 2964, 338}) do
			for i = 0, 50 do
				removeWorldModel(v, 1000000, 0, 0, 0, i)
			end
		end

		local txd = engineLoadTXD("files/k_pool.txd")
		engineImportTXD(txd, 2964)
		local txd = engineLoadTXD("files/pool_blsx.txd")
		engineImportTXD(txd, unpack(numModels))
	end)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if getElementModel(source) == 2964 then
			local tableId = getElementData(source, "poolTableID")

			if tableId then
				triggerEvent("syncThePoolTable", localPlayer, tableId)
			end
		end
	end)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementModel(source) == 2964 then
			local tableId = getElementData(source, "poolTableID")

			if tableId and not poolTables[tableId] and not syncTables[tableId] then
				syncTables[tableId] = true
			end

			for k, v in pairs(syncTables) do
				if v then
					triggerServerEvent("syncThePoolTable", localPlayer, k)
					syncTables[k] = nil
				end
			end
		end
	end)

addEvent("syncThePoolTable", true)
addEventHandler("syncThePoolTable", getRootElement(),
	function (id, element, balls, actions)
		if balls then
			destroyPoolTable(id, true)

			local x, y, z = getElementPosition(element)
			local rz = select(3, getElementRotation(element))
			local interior = getElementInterior(element)
			local dimension = getElementDimension(element)

			syncTables[id] = false
			poolTables[id] = {}

			poolTables[id].obj = element
			poolTables[id].col = createColSphere(x, y, z + 0.9, 3)

			setElementInterior(poolTables[id].col, interior)
			setElementDimension(poolTables[id].col, dimension)
			setElementData(poolTables[id].col, "poolTableCol", element)

			poolTables[id].boundary = {}

			for i = 1, #boundaryPoses do
				local startX, startY = rotateAround(rz, boundaryPoses[i][1], boundaryPoses[i][2], x, y)
				local stopX, stopY = rotateAround(rz, boundaryPoses[i][3], boundaryPoses[i][4], x, y)

				poolTables[id].boundary[i] = {startX, startY, stopX, stopY, math.atan2(startY - stopY, startX - stopX)}
			end

			poolTables[id].pockets = {}

			for i = 1, #pocketPoses do
				poolTables[id].pockets[i] = {pocketPoses[i][1], rotateAround(rz, pocketPoses[i][2], pocketPoses[i][3], x, y)}
			end

			poolTables[id].forces = 0
			poolTables[id].balls = {}
			poolTables[id].ballsKeyed = {}
			poolTables[id].potted = {}
			poolTables[id].pottedKeyed = {}
			poolTables[id].falled = {}
			poolTables[id].actions = actions

			for i = 1, #balls do
				local dat = balls[i]

				if dat then
					local obj = createObject(dat.model, dat.x, dat.y, dat.z)
					local rx, ry, rz = quaternionToEuler(eulerToQuaternion(getElementRotation(obj)))
					local qx, qy, qz, qw = eulerToQuaternion(math.deg(rx), math.deg(ry), math.deg(rz) - 90)

					poolTables[id].balls[i] = {
						obj = obj,
						num = modelNums[dat.model],
						vel = {0, 0},
						pos = {dat.x, dat.y, dat.z},
						rot = {qx, qy, qz, qw},
						inpocket = dat.inpocket,
						fallen = dat.fallen
					}

					setElementInterior(obj, interior)
					setElementDimension(obj, dimension)
					setElementFrozen(obj, true)

					poolTables[id].ballsKeyed[obj] = i
				end
			end
		else
			if obj then
				if standingTableId == id then
					removeEventHandler("onClientKey", getRootElement(), playerPressedKey)

					if gameActive then
						triggerServerEvent("givePoolStick", localPlayer, false, true)
						setElementFrozen(localPlayer, false)

						showCursor(false)
						setCursorAlpha(255)
					end

					standingTableId = false
					standingTableObj = false

					gameActive = false
					holdRMB = false
					holdLMB = false

					if isElement(Roboto) then
						destroyElement(Roboto)
					end

					Roboto = nil
				end

				syncTables[id] = nil
				destroyPoolTable(id)
			else
				syncTables[id] = true

				if standingTableId ~= id then
					destroyPoolTable(id)
				end
			end
		end
	end)

function destroyPoolTable(id, onlyobjs)
	if poolTables[id] then
		for i = 1, #poolTables[id].balls do
			if isElement(poolTables[id].balls[i].obj) then
				destroyElement(poolTables[id].balls[i].obj)
			end
		end

		if isElement(poolTables[id].col) then
			destroyElement(poolTables[id].col)
		end

		if not onlyobjs then
			poolTables[id] = nil
		end
	end
end

addEventHandler("onClientColShapeHit", getResourceRootElement(),
	function (element, matchingDimension)
		if element == localPlayer and matchingDimension then
			if isElement(source) then
				if not standingTableId then
					local obj = getElementData(source, "poolTableCol")

					if isElement(obj) then
						Roboto = dxCreateFont("files/Roboto.ttf", respc(14), false, "antialiased")

						standingTableObj = obj
						standingTableId = getElementData(obj, "poolTableID")

						exports.see_hud:showInfobox("i", "Nyomj [E] gombot a játékba való be -és kiszálláshoz.")

						addEventHandler("onClientKey", getRootElement(), playerPressedKey, true, "high+99999")
					end
				end
			end
		end
	end)

addEventHandler("onClientColShapeLeave", getResourceRootElement(),
	function (element, matchingDimension)
		if element == localPlayer and matchingDimension then
			if standingTableId then
				removeEventHandler("onClientKey", getRootElement(), playerPressedKey)

				if gameActive then
					triggerServerEvent("givePoolStick", localPlayer, false, true)
					setElementFrozen(localPlayer, false)

					showCursor(false)
					setCursorAlpha(255)
				end

				standingTableId = false
				standingTableObj = false

				gameActive = false
				holdRMB = false
				holdLMB = false

				if isElement(Roboto) then
					destroyElement(Roboto)
				end

				Roboto = nil
			end
		end
	end)

local clickTick = 0

function playerPressedKey(key, press)
	if standingTableId then
		if key == "e" then
			cancelEvent()

			if press then
				if getTickCount() - clickTick >= 1000 then
					gameActive = not gameActive

					if gameActive then
						triggerServerEvent("givePoolStick", localPlayer, true)
					else
						triggerServerEvent("givePoolStick", localPlayer, false)
					end

					clickTick = getTickCount()
				else
					exports.see_hud:showInfobox("e", "Ne ilyen gyorsan!")
				end
			end
		elseif key == "mouse2" then
			if gameActive and not syncTableId then
				cancelEvent()

				if press ~= holdRMB then
					if press and poolTables[standingTableId].forces > 0 then
						return
					end

					if press and syncTableId then
						exports.see_hud:showInfobox("e", "Várd meg, amíg a másik asztalon véget ér a játék!")
						return
					end

					if press then
						local playerX, playerY, playerZ = getElementPosition(localPlayer)
						local tableX, tableY, tableZ = getElementPosition(standingTableObj)

						if math.abs(playerZ - tableZ) - 0.45 >= 1 then
							return
						end

						local playerRot = select(3, getElementRotation(localPlayer))
						local facingAngle = math.deg(math.atan2(tableY - playerY, tableX - playerX)) + 180 - playerRot

						if facingAngle < 0 then
							facingAngle = facingAngle + 360
						end

						if facingAngle < 180 then
							return
						end

						triggerServerEvent("setPoolAnimation", localPlayer, "pool_" .. aimLength .. "_start", true)
						setElementFrozen(localPlayer, true)

						showCursor(true)
						setCursorAlpha(0)
						setCursorPosition(screenX / 2, screenY / 2)

						pedRot = getPedRotation(localPlayer)
						holdRMB = press
						holdLMB = false
						hoverBallId = false
					else
						triggerServerEvent("setPoolAnimation", localPlayer, "pool_" .. aimLength .. "_start_o", false)
						setElementFrozen(localPlayer, false)

						showCursor(false)
						setCursorAlpha(255)

						holdRMB = press
						holdLMB = false
						hoverBallId = false
					end
				end
			end
		elseif key == "mouse1" then
			if gameActive then
				cancelEvent()

				if press ~= holdLMB then
					if press and not hoverBallId then
						return
					end

					holdLMB = press
					forcePickStart = getTickCount()
					forcePickState = 0

					if not press and hoverBallId and standingTableId then
						triggerServerEvent("forceABall", localPlayer, standingTableId, hoverBallId, forcePosition, aimLength)
						setElementFrozen(localPlayer, false)

						showCursor(false)
						setCursorAlpha(255)

						exports.see_chat:localActionC(localPlayer, "meglök egy golyót.")
						hoverBallId = false
						holdRMB = false
						holdLMB = false
					end

					forcePosition = {0, 0}
				end
			end
		end
	end
end

addEvent("forceABall", true)
addEventHandler("forceABall", getRootElement(),
	function (tableId, ballId, forces)
		local poolTable = poolTables[tableId]

		if poolTable then
			if poolTable.balls[ballId] then
				local visibleName = getElementData(source, "visibleName")

				if not visibleName then
					visibleName = getPlayerName(source)
				end

				local actions = {{visibleName, poolTable.balls[ballId].num}}
				local history = #poolTable.actions

				if history > 15 then
					history = 15
				end

				for i = 1, history do
					table.insert(actions, poolTable.actions[i])
				end

				poolTable.falled = {}
				poolTable.actions = actions

				if source == localPlayer then
					syncTableId = tableId
					triggerServerEvent("syncPoolTableActions", localPlayer, tableId, poolTable.actions)
				end

				poolTable.balls[ballId].vel = forces

				local x, y, z = getElementPosition(poolTable.balls[ballId].obj)
				local sound = playSound3D("files/sounds/stick.mp3", x, y, z)

				setElementInterior(sound, getElementInterior(poolTable.obj))
				setElementDimension(sound, getElementDimension(poolTable.obj))
				setSoundMaxDistance(sound, 25)
			end
		end
	end)

addEvent("syncPoolBalls", true)
addEventHandler("syncPoolBalls", getRootElement(),
	function (tableId, balls, falled, newgame)
		local poolTable = poolTables[tableId]

		if poolTable then
			poolTable.falled = falled

			local falledNum = #falled + 1

			if falledNum > 0 then
				local actions = {}

				if falledNum >= 15 then
					falledNum = 15
				else
					local count = 0

					for i = falledNum + 1, 15 do
						count = count + 1
						actions[i] = poolTable.actions[count]
					end
				end

				local count = 0

				for i = falledNum, 1, -1 do
					count = count + 1

					if count == 1 then
						if newgame then
							actions[1] = "newgame"
						else
							actions[1] = "roundend"
						end
					else
						actions[count] = falled[i]
					end
				end

				poolTable.actions = actions

				if source == localPlayer then
					triggerServerEvent("syncPoolTableActions", localPlayer, tableId, poolTable.actions)
				end
			end

			poolTable.showPottedBalls = getTickCount()
			poolTable.potted = {}
			poolTable.pottedKeyed = {}

			for i = 1, #balls do
				local ball = balls[i]

				poolTable.balls[i].animating = true
				poolTable.balls[i].vel = {0, 0}
				poolTable.balls[i].pos = {ball.x, ball.y, ball.z}
				poolTable.balls[i].inpocket = ball.inpocket
				poolTable.balls[i].fallen = ball.fallen

				local currentPotted = false

				for j = 1, #falled do
					local num = falled[j]

					if num == poolTable.balls[i].num then
						currentPotted = true
						break
					end
				end

				if currentPotted then
					if not poolTable.potted[ball.inpocket] then
						poolTable.potted[ball.inpocket] = {}
					end

					table.insert(poolTable.potted[ball.inpocket], poolTable.balls[i].num)
				end

				if ball.inpocket or ball.fallen then
					poolTable.pottedKeyed[poolTable.balls[i].num] = true
				end

				moveObject(poolTable.balls[i].obj, 200, ball.x, ball.y, ball.z)
			end

			setTimer(
				function ()
					for i = 1, #balls do
						local ball = balls[i]

						poolTable.balls[i].animating = false
					end
				end,
			300, 1)
		end
	end)

addEventHandler("onClientPreRender", getRootElement(),
	function (timeSlice)
		timeSlice = timeSlice * 0.001

		for tableId, poolTable in pairs(poolTables) do
			if isElement(poolTable.obj) then
				local boundariesNum, ballsNum, pocketsNum = #poolTable.boundary, #poolTable.balls, #poolTable.pockets
				local tableX, tableY, tableZ = getElementPosition(poolTable.obj)

				tableZ = tableZ + 0.9

				for i = 1, boundariesNum do
					if debugMode then
						local pos = poolTable.boundary[i]

						dxDrawLine3D(pos[1], pos[2], tableZ + 0.04, pos[3], pos[4], tableZ + 0.04, tocolor(255, 255, 0), 0.5)
					end

					for j = 1, ballsNum do
						local ball = poolTable.balls[j]

						if not ball.inpocket and not ball.fallen and not ball.animating then
							if ball.vel[1] ~= 0 or ball.vel[2] ~= 0 then
								resolveWallCollision(tableId, i, j, timeSlice)
							end
						end
					end
				end

				poolTable.forces = 0

				for i = 1, ballsNum do
					local ball = poolTable.balls[i]

					if not ball.inpocket and not ball.fallen and not ball.animating then
						ball.pos[1] = ball.pos[1] + ball.vel[1] * timeSlice
						ball.pos[2] = ball.pos[2] + ball.vel[2] * timeSlice

						if ball.vel[1] ~= 0 or ball.vel[2] ~= 0 then
							for j = 1, ballsNum do
								local nextBall = poolTable.balls[j]

								if i ~= j and not nextBall.inpocket and not nextBall.fallen and not nextBall.animating then
									resolveBallCollision(tableId, i, j)
								end
							end

							local angle = math.atan2(ball.vel[2], ball.vel[1]) - math.rad(90)
							local speed = math.sqrt(ball.vel[1] * ball.vel[1] + ball.vel[2] * ball.vel[2])

							speed = speed - ballSetup.friction * timeSlice

							if speed < 0.001 then
								speed = 0
							end

							ball.vel[1] = speed * math.sin(-angle)
							ball.vel[2] = speed * math.cos(-angle)

							ball.vel[1] = ball.vel[1] - ball.vel[1] * ballSetup.airResistance * timeSlice
							ball.vel[2] = ball.vel[2] - ball.vel[2] * ballSetup.airResistance * timeSlice

							if speed > 0 then
								rotateBall(tableId, i, speed * timeSlice * (180 / math.pi) / ballSetup.radius, angle)
							end

							if getDistanceBetweenPoints2D(ball.pos[1], ball.pos[2], tableX, tableY) >= 1.15 then
								if syncTableId == tableId then
									table.insert(poolTable.falled, {ball.num, true})
								end

								ball.fallen = true
								ball.vel = {0, 0}
								ball.pos = {poolTable.pockets[1][2], poolTable.pockets[1][3], ball.pos[3] - 0.25}

								moveObject(ball.obj, 225, ball.pos[1], ball.pos[2], ball.pos[3])
							end
						end

						setElementPosition(ball.obj, ball.pos[1], ball.pos[2], ball.pos[3])

						poolTable.forces = poolTable.forces + math.abs(ball.vel[1]) + math.abs(ball.vel[2])
					end
				end

				for i = 1, pocketsNum do
					local pocket = poolTable.pockets[i]

					for j = 1, ballsNum do
						local ball = poolTable.balls[j]

						if not ball.inpocket and not ball.fallen and not ball.animating then
							if ball.vel[1] ~= 0 or ball.vel[2] ~= 0 then
								if isPointInCircle(ball.pos[1], ball.pos[2], pocket[2], pocket[3], pocket[1]) then
									local sound = playSound3D("files/sounds/fall.mp3", ball.pos[1], ball.pos[2], ball.pos[3])

									setElementInterior(sound, getElementInterior(ball.obj))
									setElementDimension(sound, getElementDimension(ball.obj))
									setSoundMaxDistance(sound, 25)

									if syncTableId == tableId then
										table.insert(poolTable.falled, ball.num)
									end

									ball.inpocket = i
									ball.vel = {0, 0}
									ball.pos = {pocket[2], pocket[3], ball.pos[3] - 0.25}

									moveObject(ball.obj, 225, ball.pos[1], ball.pos[2], ball.pos[3])
								end
							end
						end
					end

					if pocket and poolTable.showPottedBalls then
						if not pottedBalls[tableId .. "," .. i] then
							pottedBalls[tableId .. "," .. i] = pocket
						end
					end

					if debugMode then
						dxDrawLine3D(pocket[2], pocket[3], tableZ, pocket[2], pocket[3], tableZ + 0.25, tocolor(255, 255, 0), 0.5)

						for d = 0, 360, 20 do
							local r1 = math.rad(d - 20)
							local r2 = math.rad(d)

							dxDrawLine3D(
								pocket[2] + math.cos(r1) * pocket[1],
								pocket[3] + math.sin(r1) * pocket[1],
								tableZ,
								pocket[2] + math.cos(r2) * pocket[1],
								pocket[3] + math.sin(r2) * pocket[1],
								tableZ,
								tocolor(255, 255, 0),
								0.5
							)
						end
					end
				end

				poolTable.forces = math.floor(poolTable.forces * 500) / 500

				if poolTable.forces <= 0.01 then
					poolTable.forces = 0

					if syncTableId == tableId then
						syncTableId = false

						local temp = {}

						for i = 1, ballsNum do
							local ball = poolTable.balls[i]

							temp[ball.num] = {ball.pos[1], ball.pos[2], ball.pos[3], ball.inpocket, ball.fallen}
						end

						triggerServerEvent("syncPoolBalls", localPlayer, tableId, temp, poolTable.falled)

						poolTable.falled = {}
					end
				end
			end
		end

		if standingTableId then
			local poolTable = poolTables[standingTableId]

			if gameActive then
				if poolTable.forces <= 0 then
					if not hoverBallId then
						dxDrawText("Célzás: jobb klikk nyomva tartva.", 1, 1, screenX + 1, screenY - respc(150) + 1, tocolor(0, 0, 0), 1, Roboto, "center", "bottom")
						dxDrawText("#598ed7Célzás: #3d7abcjobb klikk #ffffffnyomva tartva.", 0, 0, screenX, screenY - respc(150), tocolor(255, 255, 255), 1, Roboto, "center", "bottom", false, false, false, true)
					else
						dxDrawText("Lövés: bal klikk nyomva tartva, korrekció: A és D.", 1, 1, screenX + 1, screenY - respc(150) + 1, tocolor(0, 0, 0), 1, Roboto, "center", "bottom")
						dxDrawText("#598ed7Lövés: #3d7abcbal klikk #ffffffnyomva tartva, #598ed7korrekció: #3d7abcA#ffffff és #3d7abcD#ffffff.", 0, 0, screenX, screenY - respc(150), tocolor(255, 255, 255), 1, Roboto, "center", "bottom", false, false, false, true)
					end
				else
					dxDrawText("Golyók mozgásban...", 1, 1, screenX + 1, screenY - respc(150) + 1, tocolor(0, 0, 0), 1, Roboto, "center", "bottom")
					dxDrawText("Golyók mozgásban...", 0, 0, screenX, screenY - respc(150), tocolor(255, 255, 255), 1, Roboto, "center", "bottom")
				end

				if holdRMB then
					local cursorX, cursorY = getCursorPosition()

					hoverBallId = false

					if cursorX then
						local worldX, worldY, worldZ = getWorldFromScreenPosition(cursorX * screenX, cursorY * screenY, 50)
						local camX, camY, camZ = getCameraMatrix()
						local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(camX, camY, camZ, worldX, worldY, worldZ, false, false, false, true, false, false, true)

						if hit then
							local playerX, playerY, playerZ = getElementPosition(localPlayer)
							local tableX, tableY, tableZ = getElementPosition(standingTableObj)

							tableZ = tableZ + 0.9

							if poolTable.ballsKeyed[hitElement] then
								hitX, hitY, hitZ = getElementPosition(hitElement)
							end

							local aimAngle = math.atan2(playerY - hitY, playerX - hitX)

							pedRot = math.deg(aimAngle) + 90 - 5

							local cueDistance = getDistanceBetweenPoints2D(playerX, playerY, hitX, hitY)
							local cueLength = "short"

							if cueDistance >= 0.8 and cueDistance < 1.3 then
								cueLength = "med"
							elseif cueDistance >= 1.3 then
								cueLength = "long"
							end

							if debugMode then
								dxDrawText("cue dist: " .. cueDistance, 500, 400)
								dxDrawText("cue length: " .. cueLength, 500, 420)
							end

							if aimLength ~= cueLength then
								aimLength = cueLength

								if getTickCount() >= nextAnimSync then
									nextAnimSync = getTickCount() + 500
									triggerServerEvent("setPoolAnimation", localPlayer, "pool_" .. aimLength .. "_start", true)
								else
									setPedAnimation(localPlayer, "pool", "pool_" .. aimLength .. "_start", -1, false, false, false, true)
								end
							end

							local crosshairX, crosshairY = false, false
							local crosshairColor = tocolor(255, 255, 255)

							if poolTable.ballsKeyed[hitElement] and cueDistance > 0.6 and cueDistance <= 1.65 then
								hoverBallId = poolTable.ballsKeyed[hitElement]
								crosshairColor = tocolor(61, 122, 188)
							end

							if cueDistance <= 0.6 or cueDistance > 1.65 then
								crosshairColor = tocolor(215, 89, 89)
							end

							if hoverBallId then
								crosshairX, crosshairY = getScreenFromWorldPosition(hitX, hitY, tableZ)
							else
								crosshairX, crosshairY = getScreenFromWorldPosition(hitX, hitY, hitZ)
							end

							if tonumber(crosshairX) then
								dxDrawImage(crosshairX - 8, crosshairY - 8, 16, 16, "files/images/crosshair.png", 0, 0, 0, crosshairColor)
							end

							if hoverBallId then
								if debugMode then
									dxDrawText("rotCorrection: " .. math.deg(cueRotCorrection), 500, 440)
								end

								if getKeyState("arrow_r") or getKeyState("d") then
									if cueRotCorrection > -maxRotCorrection then
										cueRotCorrection = cueRotCorrection - math.rad(20) * timeSlice
									end
								elseif getKeyState("arrow_l") or getKeyState("a") then
									if cueRotCorrection < maxRotCorrection then
										cueRotCorrection = cueRotCorrection + math.rad(20) * timeSlice
									end
								end

								aimAngle = aimAngle + math.rad(176)
								cueDistance = cueDistance / 1.65

								local lineProgress = 0

								if holdLMB then
									local progress = (getTickCount() - forcePickStart) / 500
									local state = forcePickState

									if progress > 1 then
										forcePickStart = getTickCount()

										if forcePickState == 0 then
											forcePickState = 1
										else
											forcePickState = 0
										end
									end

									lineProgress = interpolateBetween(state, 0, 0, 1 - state, 0, 0, progress, "Linear")
								end

								local length, force = interpolateBetween(2, 0.25 - cueDistance * 0.15, 0, 30, 6 - cueDistance * 3.5, 0, lineProgress, "InQuad")

								if debugMode then
									dxDrawText("cue force: " .. force, 500, 460)
								end

								local rotatedX = math.cos(aimAngle + cueRotCorrection)
								local rotatedY = math.sin(aimAngle + cueRotCorrection)
								local startX, startY = hitX, hitY
								local endX, endY = rotatedX * force, rotatedY * force

								forcePosition = {endX * 0.5, endY * 0.5}

								local offset = 0.9 - cueDistance * 0.65

								for i = 0, 30 do
									endX = hitX + offset / 30 * i * rotatedX
									endY = hitY + offset / 30 * i * rotatedY

									local r, g, b = 255, 255, 255

									if holdLMB and length >= i then
										r, g, b = interpolateBetween(0, 255, 0, 255, 0, 0, i / 19.5, "Linear")
									end

									dxDrawLine3D(startX, startY, hitZ, endX, endY, hitZ, tocolor(r, g, b, 255 - 8.5 * i + 25), (30 - i) / 15)

									startX, startY = endX, endY
								end
							end
						end
					end

					if aimLength == "short" then
						setElementRotation(localPlayer, 0, 0, pedRot - 16, "default", true)
					elseif aimLength == "long" then
						setElementRotation(localPlayer, 0, 0, pedRot - 4, "default", true)
					else
						setElementRotation(localPlayer, 0, 0, pedRot, "default", true)
					end
				end
			end

			if poolTable.actions then
				local sx, sy = respc(480), respc(225) / 13
				local x = screenX - sx - respc(14)
				local y = screenY - sy * 13 - respc(14)

				for i = 1, 13 do
					local rowY = y + sy * (i - 1)

					if i % 2 == 0 then
						dxDrawRectangle(x, rowY, sx, sy, tocolor(0, 0, 0, 105))
					else
						dxDrawRectangle(x, rowY, sx, sy, tocolor(0, 0, 0, 175))
					end

					local action = poolTable.actions[i]

					if action then
						if action == "roundend" then
							dxDrawText("*** Kör vége (sync) ***", x, rowY, x + sx, rowY + sy, tocolor(145, 145, 145, 145), 0.65, Roboto, "center", "center")
						elseif action == "newgame" then
							dxDrawText("*** Új játék kezdődik ***", x, rowY, x + sx, rowY + sy, tocolor(61, 122, 188), 0.65, Roboto, "center", "center")
						elseif type(action) == "table" then
							if tonumber(action[2]) then
								if action[2] == 1 or action[2] == 5 then
									dxDrawText("#3d7abc" .. action[1]:gsub("_", " ") .. "#ffffff meglökte az " .. ballNames[action[2]] .. " golyót.", x + respc(4), rowY, x + sx, rowY + sy, tocolor(255, 255, 255), 0.65, Roboto, "left", "center", false, false, false, true)
								else
									dxDrawText("#3d7abc" .. action[1]:gsub("_", " ") .. "#ffffff meglökte a " .. ballNames[action[2]] .. " golyót.", x + respc(4), rowY, x + sx, rowY + sy, tocolor(255, 255, 255), 0.65, Roboto, "left", "center", false, false, false, true)
								end
							else
								if action[1] == 1 or action[1] == 5 then
									dxDrawText("Az " .. ballNames[action[1]] .. " golyó leesett a földre.", x + respc(4), rowY, x + sx, rowY + sy, tocolor(255, 255, 255), 0.65, Roboto, "left", "center", false, false, false, true)
								else
									dxDrawText("A " .. ballNames[action[1]] .. " golyó leesett a földre.", x + respc(4), rowY, x + sx, rowY + sy, tocolor(255, 255, 255), 0.65, Roboto, "left", "center", false, false, false, true)
								end
							end
						else
							if action == 1 or action == 5 then
								dxDrawText("Az " .. ballNames[action] .. " golyó leesett.", x + respc(4), rowY, x + sx, rowY + sy, tocolor(255, 255, 255), 0.65, Roboto, "left", "center", false, false, false, true)
							else
								dxDrawText("A " .. ballNames[action] .. " golyó leesett.", x + respc(4), rowY, x + sx, rowY + sy, tocolor(255, 255, 255), 0.65, Roboto, "left", "center", false, false, false, true)
							end
						end
					end
				end

				local offset = (sx - respc(41 + 2)) / 8

				for i = 1, 8 do
					dxDrawImage(x + offset * (i - 0.5), y - respc(50) * 2, respc(41), respc(41), "files/images/" .. i .. ".png", 0, 0, 0, tocolor(255, 255, 255, poolTable.pottedKeyed[i] and 55 or 255))
				end

				for i = 1, 8 do
					dxDrawImage(x + offset * (i - 0.5), y - respc(50), respc(41), respc(41), "files/images/" .. i + 8 .. ".png", 0, 0, 0, tocolor(255, 255, 255, poolTable.pottedKeyed[i + 8] and 55 or 255))
				end
			end
		end
	end)

addEventHandler("onClientRender", getRootElement(),
	function ()
		local camX, camY, camZ = getCameraMatrix()

		for k, pocket in pairs(pottedBalls) do
			local dat = split(k, ",")

			if dat then
				local tableId = tonumber(dat[1])
				local pocketId = tonumber(dat[2])
				local poolTable = poolTables[tableId]

				if poolTable and poolTable.potted[pocketId] and poolTable.showPottedBalls then
					local tableX, tableY, tableZ = getElementPosition(poolTable.obj)
					local pocketX, pocketY = getScreenFromWorldPosition(pocket[2], pocket[3], tableZ + 0.9 + 0.15)

					if pocketX and pocketY then
						local elapsedTime = getTickCount() - poolTable.showPottedBalls
						local progress = 255

						if elapsedTime < 500 then
							progress = 255 * elapsedTime / 500
						end

						if elapsedTime > 5000 then
							progress = 255 - (255 * (elapsedTime - 5000) / 500)

							if progress < 0 then
								progress = 0
							end

							if elapsedTime > 5500 then
								poolTable.potted[pocketId] = nil
								pottedBalls[k] = nil
							end
						end

						if poolTable.potted[pocketId] then
							local dist = getDistanceBetweenPoints3D(camX, camY, camZ, tableX, tableY, tableZ)

							if dist <= 12 then
								local scale = 220 / dist

								pocketX = pocketX - scale / 2
								pocketY = pocketY - scale / 2

								for i = 1, #poolTable.potted[pocketId] do
									dxDrawImage(pocketX, pocketY - scale * (i - 1), scale, scale, "files/images/" .. poolTable.potted[pocketId][i] .. ".png", 0, 0, 0, tocolor(255, 255, 255, progress))
								end
							end
						end
					end
				else
					pottedBalls[k] = nil
				end
			end
		end
	end)

function eulerToQuaternion(rx, ry, rz)
	local cx = math.cos(-0.5*rx)
	local sx = math.sin(-0.5*rx)

	local cy = math.cos(-0.5*ry)
	local sy = math.sin(-0.5*ry)

	local cz = math.cos(-0.5*rz)
	local sz = math.sin(-0.5*rz)

	return cx*sy*sz + sx*cy*cz,
		   cx*sy*cz - sx*cy*sz,
		   cx*cy*sz - sx*sy*cz,
		   cx*cy*cz + sx*sy*sz
end

function quaternionToEuler(x, y, z, w)
	return -math.asin(2 * (w * x - z * y)),
		   -math.atan2((w * w) - (x * x) - (y * y) + (z * z), 2 * ((y * w) + (z * x))),
		   -math.atan2((w * w) - (x * x) + (y * y) - (z * z), 2 * ((z * w) + (y * x)))
end

function quaternionFromAxisAngle(x, y, z, angle)
	local s = math.sqrt(x*x + y*y + z*z)
	local qx, qy, qz, qw = 0, 0, 0, 1

	if s > 0.01 then
		local omega = 0.5 * angle
		x, y, z = x/s, y/s, z/s
		s = math.sin(omega)
		qx, qy, qz, qw = s*x, s*y, s*z, math.cos(omega)
	end

	return normalizeQuaternion(qx, qy, qz, qw)
end

function normalizeQuaternion(x, y, z, w)
	local d = math.sqrt(x*x + y*y + z*z + w*w)
	if d == 0 then
		return 0, 0, 0, 1
	else
		return x/d, y/d, z/d, w/d
	end
end

function getQuaternionProduct(x1, y1, z1, w1, x2, y2, z2, w2)
	return w1*x2 + x1*w2 + y1*z2 - z1*y2,
		   w1*y2 - x1*z2 + y1*w2 + z1*x2,
		   w1*z2 + x1*y2 - y1*x2 + z1*w2,
		   w1*w2 - x1*x2 - y1*y2 - z1*z2
end

function rotateBall(tableId, ballId, speed, angle)
	local ball = poolTables[tableId].balls[ballId]
	local qx, qy, qz, qw = quaternionFromAxisAngle(-math.cos(angle), math.sin(angle), 0, speed * 0.01)

	qx, qy, qz, qw = getQuaternionProduct(ball.rot[1], ball.rot[2], ball.rot[3], ball.rot[4], qx, qy, qz, qw)

	ball.rot[1], ball.rot[2], ball.rot[3], ball.rot[4] = qx, qy, qz, qw

	local rx, ry, rz = quaternionToEuler(qx, qy, qz, qw)

	setElementRotation(ball.obj, math.deg(rx), math.deg(ry), math.deg(rz) - 90)
end

function isPointInCircle(x, y, cx, cy, r)
	local dx = math.abs(x - cx)
	local dy = math.abs(y - cy)

	if dx > r or dy > r then
		return false
	end

	if dx + dy <= r then
		return true
	end

	return dx * dx + dy * dy <= r * r
end

local lastHitTick = 0

function resolveBallCollision(tableId, firstBallId, secondBallId)
	local firstBall = poolTables[tableId].balls[firstBallId]
	local secondBall = poolTables[tableId].balls[secondBallId]

	-- check balls colliding
	local deltaX = firstBall.pos[1] - secondBall.pos[1]
	local deltaY = firstBall.pos[2] - secondBall.pos[2]

	local dist = deltaX * deltaX + deltaY * deltaY
	local maxdist = ballSetup.radius + ballSetup.radius

	-- if balls colliding
	if maxdist * maxdist >= dist then
		local relVelX = firstBall.vel[1] - secondBall.vel[1]
		local relVelY = firstBall.vel[2] - secondBall.vel[2]

		-- check magnitude
		if relVelX * deltaX + relVelY * deltaY < 0 then
			dist = math.sqrt(dist)

			local x = deltaX * (maxdist - dist) / dist
			local y = deltaY * (maxdist - dist) / dist

			local mass = 1 / ballSetup.mass -- no need A and B mass because the balls mass is same
			local totalMass = mass + mass

			firstBall.pos[1] = firstBall.pos[1] + x * (mass / totalMass)
			firstBall.pos[2] = firstBall.pos[2] + y * (mass / totalMass)

			-- calculate relative velocity in terms of the normal direction
			dist = math.sqrt(x * x + y * y)

			if dist ~= 0 and dist ~= 1 then
				x = x / dist
				y = y / dist
			end

			local contactVel = x * relVelX + y * relVelY

			-- do not resolve if velocities are separating
			if contactVel > 0 then
				return
			end

			-- calculate impulse scalar
			local impulse = -(1 + ballSetup.restitution) * contactVel
			impulse = impulse / totalMass

			x = x * impulse * mass
			y = y * impulse * mass

			firstBall.vel[1] = firstBall.vel[1] + x
			firstBall.vel[2] = firstBall.vel[2] + y

			secondBall.vel[1] = secondBall.vel[1] - x
			secondBall.vel[2] = secondBall.vel[2] - y

			if getTickCount() - lastHitTick >= 15 then
				local sound = playSound3D("files/sounds/hit.mp3", firstBall.pos[1], firstBall.pos[2], firstBall.pos[3])

				setElementInterior(sound, getElementInterior(firstBall.obj))
				setElementDimension(sound, getElementDimension(firstBall.obj))

				setSoundVolume(sound, math.abs(contactVel))
				setSoundMaxDistance(sound, 25)

				lastHitTick = getTickCount()
			end
		end
	end
end

function resolveWallCollision(tableId, boundaryId, ballId, timeSlice)
	local wall = poolTables[tableId].boundary[boundaryId]
	local ball = poolTables[tableId].balls[ballId]
	local closestX, closestY = circleSegmentIntersect(ballSetup.radius, ball.pos[1], ball.pos[2], wall[1], wall[2], wall[3], wall[4])

	if closestX then
		local dx = ball.pos[1] - closestX
		local dy = ball.pos[2] - closestY
		local dist = math.sqrt(dx * dx + dy * dy)

		dx = dx / dist
		dy = dy / dist

		local newPosX = ball.pos[1] + dx * (ballSetup.radius - dist)
		local newPosY = ball.pos[2] + dy * (ballSetup.radius - dist)
		local bounce = math.sqrt(ball.vel[1] * ball.vel[1] + ball.vel[2] * ball.vel[2]) * (ballSetup.restitution * 0.75)

		if bounce > 0 then
			local sound = playSound3D("files/sounds/wall.mp3", ball.pos[1], ball.pos[2], ball.pos[3])

			setElementInterior(sound, getElementInterior(ball.obj))
			setElementDimension(sound, getElementDimension(ball.obj))
			setSoundVolume(sound, bounce)
			setSoundMaxDistance(sound, 25)

			local angle = 2 * (wall[5] + math.rad(180)) - math.atan2(ball.vel[2], ball.vel[1])

			ball.vel[1] = math.cos(angle) * bounce
			ball.vel[2] = math.sin(angle) * bounce
		end

		ball.pos[1] = newPosX
		ball.pos[2] = newPosY

		if debugMode then
			dxDrawLine3D(ball.pos[1], ball.pos[2], ball.pos[3], ball.pos[1] + ball.vel[1], ball.pos[2] + ball.vel[2], ball.pos[3], tocolor(255, 255, 0), 1)
		end
	end
end

function circleSegmentIntersect(r, cx, cy, x1, y1, x2, y2)
	local dx, dy = x2 - x1, y2 - y1
	local f = (dx * (cx - x1) + dy * (cy - y1)) / (dx * dx + dy * dy)

	if f < 0 or f > 1 then
		return false
	end

	x2 = x1 + f * dx
	y2 = y1 + f * dy

	x1 = x2 - cx
	y1 = y2 - cy

	if x1 * x1 + y1 * y1 < r * r then
		return x2, y2
	end

	return false
end
