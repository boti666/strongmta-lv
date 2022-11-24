local connection = false
local poolTables = {}
local ballMinZ = 0.9296875

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()

		dbQuery(
			function (qh)
				local result = dbPoll(qh, 0)

				if result then
					for k, v in pairs(result) do
						loadPoolTable(v.id, v)
					end
				end
			end,
		connection, "SELECT * FROM billiards")
	end)

function loadPoolTable(id, data, sync)
	local obj = createObject(2964, data.x, data.y, data.z, 0, 0, data.rz)

	setElementInterior(obj, data.interior)
	setElementDimension(obj, data.dimension)
	setElementData(obj, "poolTableID", id)

	poolTables[id] = {}
	poolTables[id].element = obj
	poolTables[id].balls = {}
	poolTables[id].actions = {}

	for i = 1, #ballOffsets do
		local x, y = rotateAround(data.rz, ballOffsets[i][1], ballOffsets[i][2])

		poolTables[id].balls[i] = {
			model = numModels[i],
			x = data.x + x,
			y = data.y + y,
			z = data.z + ballMinZ,
			inpocket = false,
			fallen = false
		}
	end

	if sync then
		triggerClientEvent("syncThePoolTable", resourceRoot, id, obj, poolTables[id].balls)
	end
end

addEvent("moveBilliardFurniture", true)
addEventHandler("moveBilliardFurniture", getRootElement(),
	function (id, x, y, z, rz, int, dim)
		if isElement(source) then
			if x and y and z and rz then
				local data = poolTables[id]

				if data then
					if not int then
						int = getElementInterior(data.element)
					end

					if not dim then
						dim = getElementDimension(data.element)
					end

					data.x, data.y, data.z, data.rz = x, y, z, rz
					data.interior, data.dimension = int, dim

					for i = 1, #ballOffsets do
						data.balls[i].x, data.balls[i].y = rotateAround(data.rz, ballOffsets[i][1], ballOffsets[i][2], x, y)
						data.balls[i].z = z + ballMinZ
					end

					setElementPosition(data.element, x, y, z)
					setElementRotation(data.element, 0, 0, rz)
					setElementInterior(data.element, int)
					setElementDimension(data.element, dim)

					triggerClientEvent("syncThePoolTable", resourceRoot, id, data.element, data.balls)

					exports.see_accounts:showInfo(source, "s", "A kiválasztott billiárd asztal sikeresen áthelyezésre került.")

					dbExec(connection, "UPDATE billiards SET x = ?, y = ?, z = ?, rz = ?, interior = ?, dimension = ? WHERE id = ?", x, y, z, rz, int, dim, id)
				end
			end
		end
	end)

addEvent("placeThePoolTable", true)
addEventHandler("placeThePoolTable", getRootElement(),
	function (dat)
		if isElement(source) then
			if dat then
				dbExec(connection, "INSERT INTO billiards (x, y, z, rz, interior, dimension) VALUES (?,?,?,?,?,?)", unpack(dat))
				dbQuery(
					function (qh, sourcePlayer)
						local result = dbPoll(qh, 0)[1]

						if result then
							loadPoolTable(result.id, result, true)
							exports.see_accounts:showInfo(sourcePlayer, "s", "Billiárd asztal sikeresen létrehozva! ID: " .. result.id)
						end
					end,
				{source}, connection, "SELECT * FROM billiards WHERE id = LAST_INSERT_ID()")
			end
		end
	end)

addEvent("syncThePoolTable", true)
addEventHandler("syncThePoolTable", getRootElement(),
	function (tableId)
		if isElement(source) then
			local poolTable = poolTables[tableId]

			if poolTable then
				triggerClientEvent(source, "syncThePoolTable", source, tableId, poolTable.element, poolTable.balls, poolTable.actions)
			end
		end
	end)

addEventHandler("onPlayerSpawn", getRootElement(),
	function ()
		for tableId, data in pairs(poolTables) do
			triggerClientEvent(source, "syncThePoolTable", source, tableId, data.element, data.balls, data.actions)
		end
	end)

addEvent("givePoolStick", true)
addEventHandler("givePoolStick", getRootElement(),
	function (give, stopAnim)
		if isElement(source) then
			takeAllWeapons(source)

			if give then
				setTimer(giveWeapon, 100, 1, source, 7, 1, true)
				exports.see_controls:toggleControl(source, {"fire"}, false)
			else
				exports.see_controls:toggleControl(source, {"fire"}, true)
			end

			if stopAnim then
				setPedAnimation(source)
			end
		end
	end)

addEvent("setPoolAnimation", true)
addEventHandler("setPoolAnimation", getRootElement(),
	function (anim, state)
		if isElement(source) then
			setPedAnimation(source, "pool", anim, -1, false, false, true)
			
			if not state then
				setTimer(setPedAnimation, 100, 1, source)
			end
		end
	end)

addEvent("forceABall", true)
addEventHandler("forceABall", getRootElement(),
	function (tableId, ballId, forces, aimLength)
		if isElement(source) then
			setPedAnimation(source, "pool", "pool_" .. aimLength .. "_shot", 500, false, false, true, false)
					
			setTimer(
				function (thePlayer)
					triggerClientEvent("forceABall", thePlayer, tableId, ballId, forces)
					setPedAnimation(thePlayer)
				end,
			500, 1, source)
		end
	end)

addEvent("syncPoolBalls", true)
addEventHandler("syncPoolBalls", getRootElement(),
	function (tableId, balls, falled)
		if isElement(source) then
			local poolTable = poolTables[tableId]

			if poolTable then
				local tableX, tableY, tableZ = getElementPosition(poolTable.element)
				local tableRotation = select(3, getElementRotation(poolTable.element))
				local newgame = false

				for num = 1, #balls do
					local ball = balls[num]

					poolTable.balls[num].x = ball[1]
					poolTable.balls[num].y = ball[2]
					poolTable.balls[num].z = ball[3]
					poolTable.balls[num].inpocket = ball[4]
					poolTable.balls[num].fallen = ball[5]

					if num == 8 and (ball[4] or ball[5]) then
						newgame = true
					end
				end

				if newgame then
					for num = 1, #balls do
						local x, y = rotateAround(tableRotation, ballOffsets[num][1], ballOffsets[num][2])

						poolTable.balls[num].x = tableX + x
						poolTable.balls[num].y = tableY + y
						poolTable.balls[num].z = tableZ + ballMinZ
						poolTable.balls[num].inpocket = false
						poolTable.balls[num].fallen = false
					end
				else
					local cueball = poolTable.balls[16]
					
					if cueball.inpocket or cueball.fallen then
						local x, y = rotateAround(tableRotation, ballOffsets[16][1], ballOffsets[16][2])

						cueball.x = tableX + x
						cueball.y = tableY + y
						cueball.z = tableZ + ballMinZ
						cueball.inpocket = false
						cueball.fallen = false
					end
				end

				triggerClientEvent("syncPoolBalls", source, tableId, poolTable.balls, falled, newgame)
			end
		end
	end)

addEvent("syncPoolTableActions", true)
addEventHandler("syncPoolTableActions", getRootElement(),
	function (tableId, actions)
		if isElement(source) then
			local poolTable = poolTables[tableId]

			if poolTable then
				poolTable.actions = actions
			end
		end
	end)