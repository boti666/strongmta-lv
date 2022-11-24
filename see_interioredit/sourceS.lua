local connection = false
local interiorDatas = {}
local useableObjects = {}

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getRootElement(),
	function (startedRes)
		connection = exports.see_database:getConnection()

		dbQuery(
			function (qh)
				local result = dbPoll(qh, 0)

				for i = 1, #result do
					local row = result[i]

					interiorDatas[row.interiorId] = row

					toggleUseableFurnitures(row.interiorId, true)
				end
			end,
		connection, "SELECT * FROM interior_datas")
	end)

function loadInterior(thePlayer, interiorId, editInterior, forceLoad)
	local currentInterior = getElementData(thePlayer, "currentCustomInterior") or 0

	if not forceLoad and currentInterior > 0 and currentInterior == interiorId then
		return
	end

	setElementData(thePlayer, "currentCustomInterior", interiorId)

	setElementFrozen(thePlayer, true)
	setElementInterior(thePlayer, 1)
	setElementDimension(thePlayer, interiorId)
	setCameraInterior(thePlayer, 1)

	if editInterior then
		setElementData(thePlayer, "editingInterior", interiorId)
	else
		setElementData(thePlayer, "editingInterior", false)
		setCameraTarget(thePlayer, thePlayer)
	end

	local editable = exports.see_interiors:getInteriorEditable(interiorId)

	if not editable then
		return
	end

	if not interiorDatas[interiorId] then
		interiorDatas[interiorId] = {}
		interiorDatas[interiorId].interiorId = interiorId
		interiorDatas[interiorId].paidCash = 0
		interiorDatas[interiorId].interiorData = ""
		interiorDatas[interiorId].dynamicData = ""
		interiorDatas[interiorId].unlockedPP = ""
	end

	local dat = interiorDatas[interiorId]

	if dat then
		if editInterior then
			local ppThings = split(dat.unlockedPP, ",")
			local ppThingsTable = {}

			for i = 1, #ppThings do
				local model = tonumber(ppThings[i])
				ppThingsTable[model] = (ppThingsTable[model] or 0) + 1
			end

			toggleUseableFurnitures(interiorId, false)

			triggerClientEvent(thePlayer, "interiorEdit:onInteriorLoaded", thePlayer, interiorId, editable, editInterior, dat.interiorData, dat.dynamicData, dat.paidCash, ppThingsTable)
		else
			triggerClientEvent(thePlayer, "interiorEdit:onInteriorLoaded", thePlayer, interiorId, editable, false, dat.interiorData, dat.dynamicData, 0, {})
		end
	end
end

registerEvent("interiorEdit:loadInterior", getRootElement(),
	function (interiorId, editInterior)
		if isElement(source) and interiorId then
			loadInterior(source, interiorId, editInterior, true)
		end
	end)

registerEvent("interiorEdit:exitInterior", getRootElement(),
	function (normalexit)
		if isElement(source) then
			local interiorId = getElementData(source, "currentCustomInterior") or 0

			if interiorId > 0 then
				setElementData(source, "editingInterior", false)
				setElementData(source, "currentCustomInterior", false)

				setCameraTarget(source, source)
				setElementFrozen(source, false)

				if normalexit then
					local entrance = exports.see_interiors:getInteriorEntrance(interiorId)

					exports.see_interiors:warpElement(source, entrance.position[1], entrance.position[2], entrance.position[3], entrance.rotation[1], entrance.rotation[2], entrance.rotation[3], entrance.interior, entrance.dimension)

					toggleUseableFurnitures(interiorId, true)
				end
			end
		end
	end)

registerEvent("interiorEdit:saveInterior", getRootElement(),
	function (interiorId, interiorData, costs)
		if isElement(source) then
			if interiorId and interiorData then
				local entrance = exports.see_interiors:getInteriorEntrance(interiorId)
				local currCosts = costs - interiorDatas[interiorId].paidCash

				if currCosts > 0 then
					exports.see_core:takeMoney(source, currCosts, eventName)
				else
					exports.see_core:giveMoney(source, currCosts, eventName)
				end

				interiorDatas[interiorId].paidCash = costs
				interiorDatas[interiorId].interiorData = interiorData

				toggleUseableFurnitures(interiorId, true)

				exports.see_interiors:warpElement(source, entrance.position[1], entrance.position[2], entrance.position[3], entrance.rotation[1], entrance.rotation[2], entrance.rotation[3], entrance.interior, entrance.dimension)

				dbExec(connection, "UPDATE interior_datas SET paidCash = ?, interiorData = ? WHERE interiorId = ?", costs, interiorData, interiorId)
			end
		end
	end)

function toggleUseableFurnitures(interiorId, state)
	local dat = interiorDatas[interiorId]

	for k, v in pairs(useableObjects) do
		if (getElementData(v, "radioFurniture") or getElementData(v, "tvFurniture")) == interiorId then
			if isElement(v) then
				destroyElement(v)
			end

			useableObjects[k] = nil
		end
	end

	if dat and state then
		local furnitures = gettok(dat.interiorData, 8, ";")

		if furnitures ~= "-" and furnitures then
			local datas = split(furnitures, "/")

			for i = 1, #datas, 5 do
				local model = tonumber(datas[i])

				if hiFis[model] or useableTvs[model] then
					local obj = createObject(model, datas[i+1], datas[i+2], datas[i+3], 0, 0, datas[i+4])

					if isElement(obj) then
						setElementDoubleSided(obj, true)
						setElementInterior(obj, 1)
						setElementDimension(obj, interiorId)
						table.insert(useableObjects, obj)

						if hiFis[model] then
							setElementData(obj, "radioFurniture", interiorId)
						elseif useableTvs[model] then
							setElementData(obj, "tvFurniture", interiorId)
						end
					end
				end
			end
		end
	end
end

registerEvent("interiorEdit:updateDynamicData", getRootElement(),
	function (interiorId, data, affected)
		if interiorId and data then
			if interiorDatas[interiorId] then
				interiorDatas[interiorId].dynamicData = data

				triggerClientEvent(affected, "interiorEdit:updateDynamicData", resourceRoot, data, true)

				dbExec(connection, "UPDATE interior_datas SET dynamicData = ? WHERE interiorId = ?", data, interiorId)
			end
		end
	end)

registerEvent("interiorEdit:placeSafe", getRootElement(),
	function (dat)
		if source == client and dat then
			local interiorId = getElementData(source, "editingInterior") or 0

			if interiorId > 0 then
				local currBalance = getElementData(source, "acc.premiumPoints") or 0

				currBalance = currBalance - prices.furnitures[2332]

				if currBalance >= 0 then
					setElementData(source, "acc.premiumPoints", currBalance)

					triggerEvent("createSafe", source, 0, dat[3], dat[4], dat[5], dat[6], 1, interiorId)

					dbExec(connection, "UPDATE accounts SET premiumPoints = ? WHERE accountId = ?", currBalance, getElementData(source, "char.accID"))
				else
					exports.see_accounts:showInfo(source, "e", "Nincs elég prémium pontod!")
				end
			end
		end
	end)

registerEvent("interiorEdit:placeBilliard", getRootElement(),
	function (dat)
		if source == client and dat then
			local interiorId = getElementData(source, "editingInterior") or 0

			if interiorId > 0 then
				local currBalance = getElementData(source, "acc.premiumPoints") or 0

				currBalance = currBalance - prices.furnitures[2964]

				if currBalance >= 0 then
					setElementData(source, "acc.premiumPoints", currBalance)

					triggerEvent("placeThePoolTable", source, {dat[3], dat[4], dat[5], dat[6], 1, interiorId})

					dbExec(connection, "UPDATE accounts SET premiumPoints = ? WHERE accountId = ?", currBalance, getElementData(source, "char.accID"))
				else
					exports.see_accounts:showInfo(source, "e", "Nincs elég prémium pontod!")
				end
			end
		end
	end)

registerEvent("interiorEdit:buyPPFurniture", getRootElement(),
	function (interiorId, model)
		if source == client and interiorId and model then
			local currBalance = getElementData(source, "acc.premiumPoints") or 0

			currBalance = currBalance - prices.furnitures[model]

			if currBalance >= 0 then
				setElementData(source, "acc.premiumPoints", currBalance)

				interiorDatas[interiorId].unlockedPP = interiorDatas[interiorId].unlockedPP .. model .. ","

				local ppThings = split(interiorDatas[interiorId].unlockedPP, ",")
				local ppThingsTable = {}

				for i = 1, #ppThings do
					local model = tonumber(ppThings[i])
					ppThingsTable[model] = (ppThingsTable[model] or 0) + 1
				end

				triggerClientEvent(source, "interiorEdit:gotPPThings", source, ppThingsTable)

				dbExec(connection, "UPDATE interior_datas SET unlockedPP = ? WHERE interiorId = ?", interiorDatas[interiorId].unlockedPP, interiorId)
				dbExec(connection, "UPDATE accounts SET premiumPoints = ? WHERE accountId = ?", currBalance, getElementData(source, "char.accID"))

				exports.see_accounts:showInfo(source, "s", "Sikeres vásárlás!")
			else
				exports.see_accounts:showInfo(source, "e", "Nincs elég prémium pontod!")
			end
		end
	end)

registerEvent("interiorEdit:requestTvMovie", getRootElement(),
	function ()
		if isElement(source) then
			local streamURL = getElementData(source, "tvStreamURL")
			local startTime = getElementData(source, "tvStartTime") or getRealTime().timestamp

			if streamURL and startTime then
				triggerClientEvent(client, "interiorEdit:playTvMovie", source, streamURL, getRealTime().timestamp - startTime)
			end
		end
	end)

registerEvent("interiorEdit:stopTvMovie", getRootElement(),
	function (interiorId)
		if isElement(source) and interiorId then
			local affected = {}

			for k, v in pairs(getElementsByType("player")) do
				if getElementInterior(v) == 1 and getElementDimension(v) == interiorId then
					table.insert(affected, v)
				end
			end

			removeElementData(source, "tvStreamURL")
			removeElementData(source, "tvStartTime")

			triggerClientEvent(affected, "interiorEdit:playTvMovie", source, false, false)
		end
	end)

registerEvent("interiorEdit:playTvMovie", getRootElement(),
	function (url, interiorId, fromMovieList)
		if isElement(source) and url and interiorId then
			local url = url:gsub("&list=(.+)", "") or url
			local id = url:match("v=(.+)&") or url:match("v=(.+)#") or url:match("v=(.+)") or url:match("tu.be/(.+)#") or url:match("tu.be/(.+)?") or url:match("tu.be/(.+)")

			if fromMovieList then
				id = url
			end

			if url and id then
				local affected = {}

				for k, v in pairs(getElementsByType("player")) do
					if getElementInterior(v) == 1 and getElementDimension(v) == interiorId then
						table.insert(affected, v)
					end
				end

				setElementData(source, "tvStreamURL", id, false)
				setElementData(source, "tvStartTime", getRealTime().timestamp, false)

				triggerClientEvent(affected, "interiorEdit:playTvMovie", source, id, true)
			else
				exports.see_hud:showInfobox(client, "e", "Érvénytelen URL! Kérlek próbálj másikat.")
			end
		end
	end)