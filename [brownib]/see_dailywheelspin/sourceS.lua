local connection = false
local alreadySpinnedPlayers = {}

function loadSpinnedPlayers(qh)
    local result = dbPoll(qh, 600)
    local timestamp = getRealTime().timestamp

    alreadySpinnedPlayers = {}
    for k, v in pairs(result) do
        if timestamp > (v.timestamp + 86400) then
            for k, v in pairs(getElementsByType("player")) do 
                if getElementData(v, "char.accID") == v.accountId then
                    setElementData(v, "alreadySpinned", false)
                end
            end
            dbExec(connection, "DELETE FROM dailyspin WHERE dbId = ?", v.dbId)
        elseif timestamp < (v.timestamp + 86400) then
            alreadySpinnedPlayers[v.accountId] = true
        end
    end
end

addEventHandler("onDatabaseConnected", getRootElement(),
    function(db)
        connection = db
    end
)

local fortuneObjects = {}

addEventHandler("onResourceStart", resourceRoot,
    function()
        connection = exports.see_database:getConnection()
        dbQuery(loadSpinnedPlayers, connection, "SELECT * FROM dailyspin")
        setTimer(loadSpinnedPlayers, 60 * 1000 * 10, 1)
        for i = 1, #fortuneWheels do
            local fortuneObject = createObject(1945, fortuneWheels[i][1], fortuneWheels[i][2], fortuneWheels[i][3] + 1, 0, 0, fortuneWheels[i][4] - 180)
            setElementInterior(fortuneObject, fortuneWheels[i][5])
            setElementDimension(fortuneObject, fortuneWheels[i][6])
            setElementDoubleSided(fortuneObject, true)
            setElementData(fortuneObject, "dailySpinObject", true)
            fortuneObjects[fortuneObject] = true

            local fortuneObjectSupportPos = {getPositionFromElementOffset(fortuneObject, 0, 0.15, 0)}
            local fortuneObjectSupport = createObject(1897, fortuneObjectSupportPos[1], fortuneObjectSupportPos[2], fortuneObjectSupportPos[3], 0, 0, fortuneWheels[i][4] - 180)
            setObjectScale(fortuneObjectSupport, 1, 1, 1.9)
            setElementInterior(fortuneObjectSupport, fortuneWheels[i][5])
            setElementDimension(fortuneObjectSupport, fortuneWheels[i][6])
            setElementDoubleSided(fortuneObjectSupport, true)
        end

		for k, v in pairs({1945}) do
			for i = 0, 50 do
				removeWorldModel(v, 1000000, 0, 0, 0, i)
			end
		end
    end
)

local winItems = {
    [40] = 5, -- Járműt nyertél.
    [20] = 10, -- Valami ajandek kene
    --[10] = false, -- Semmi, nem nyertél.
    --[5] = 163, -- ez a 1-es zsetonn
    --[2] = 163, -- ez a gyemant
}

function giveWinnedItem(sourcePlayer, num)
    if isElement(sourcePlayer) then
        if winItems[num] then
            iprint(num)
            exports.see_items:giveItem(sourcePlayer, winItems[num], 1, false, false, false, false)
            outputChatBox("#3d7abc[StrongMTA]: #ffffffNyertél egy #3d7abc" .. exports.see_items:getItemName(winItems[num]) .. "#ffffff-t!", sourcePlayer, 255, 255, 255, true)
        elseif num == 1 then
            iprint(num)
            setElementData(sourcePlayer, "char.Money", getElementData(sourcePlayer, "char.Money") + 2000000)
            outputChatBox("#3d7abc[StrongMTA]: #ffffffNyertél #3d7abc" .. "2.000.000" .. "$#ffffff-t!", sourcePlayer, 255, 255, 255, true)
        elseif num == 10 then
            iprint(num)
            outputChatBox("#3d7abc[StrongMTA]: #ffffffNem nyertél semmit.", sourcePlayer, 255, 255, 255, true)
        elseif num == 5 then
            iprint(num)
            setElementData(sourcePlayer, "char.slotCoins", getElementData(sourcePlayer, "char.slotCoins") + 75000)
            outputChatBox("#3d7abc[StrongMTA]: #ffffffNyertél #3d7abc" .. "75.000" .. "SSC#ffffff-t!", sourcePlayer, 255, 255, 255, true)
        elseif num == 2 then
            iprint(num)
            setElementData(sourcePlayer, "acc.premiumPoints", getElementData(sourcePlayer, "acc.premiumPoints") + 10000)
            outputChatBox("#3d7abc[StrongMTA]: #ffffffNyertél #3d7abc" .. "10.000" .. "PP#ffffff-t!", sourcePlayer, 255, 255, 255, true)
        else
            iprint(num)
        end
    end
end

addEvent("startDailySpin", true)
addEventHandler("startDailySpin", getRootElement(),
    function(clickedElement)
        if (not getElementData(source, "alreadySpinned") or exports.see_items:hasItem(source, 5)) and not getElementData(clickedElement, "dailySpin.inUse") and client and client == source then
            local hasTicket = false
            local usedTicket = false
            if exports.see_items:hasItem(source, 5) then
                hasTicket = true
            end
            if alreadySpinnedPlayers[getElementData(source, "char.accID")] then
                local doReturn = false
                if not hasTicket then
                    outputChatBox("#3d7abc[StrongMTA]: #ffffffTe ma már pörgettél!", source, 255, 255, 255, true)
                    setElementData(source, "alreadySpinned", true)
                    doReturn = true
                else
                    usedTicket = true
                    exports.see_items:takeItem(source, "itemId", 5, 1)
                end
                if doReturn then
                    return
                end
            end
            if not usedTicket then
                dbExec(connection, "INSERT INTO dailyspin (accountId, timestamp) VALUES(?,?)", getElementData(source, "char.accID"), getRealTime().timestamp)
                setElementData(source, "alreadySpinned", true)
                alreadySpinnedPlayers[getElementData(source, "char.accID")] = true
            end
            setElementData(clickedElement, "dailySpin.inUse", true)
            local num = chooseRandomNumber()
            local x, y, z = getElementPosition(clickedElement)
		    local ry = select(2, getElementRotation(clickedElement))
            moveObject(clickedElement, 10000, x, y, z, 0, -(ry + (num - 1) * degPerNum) - 360, 0, "InOutQuad")
            setTimer(
                function(clickedElement, sourcePlayer, num)
                    setElementData(clickedElement, "dailySpin.inUse", false)
                    giveWinnedItem(sourcePlayer, num)
                end, 10000, 1, clickedElement, source, num
            )
        end
    end
)