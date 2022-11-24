local connection = false

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end
)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()
	end
)

addEvent("onAnwserSent", true)
addEventHandler("onAnwserSent", getRootElement(),
    function(myName, myPlayerID, message, targetPlayer)
        --executeCommandHandler("vá", source, getElementData(targetPlayer, "playerID"), table.concat(message, " "))
        outputChatBox(string.format("#ff9000[Válasz]: #ffffff%s (%d): #ff9000%s", getElementData(targetPlayer, "visibleName"), getElementData(targetPlayer, "playerID"), message), source, 0, 0, 0, true)
        outputChatBox(string.format("#ff9000[Segítség]: #ffffff%s (%d): #ff9000%s", myName, myPlayerID, message), targetPlayer, 0, 0, 0, true)

        triggerClientEvent("onAdminMSGVa", resourceRoot, string.format("%s %s válaszolt neki: %s", exports.see_administration:getPlayerAdminTitle(source), myName, getElementData(targetPlayer, "char.Name"):gsub("_", " ")))
		triggerClientEvent("onAdminMSGVa", resourceRoot, string.format("Üzenet: %s", message))
    end
)

addEvent("executeCommandForClient", true)
addEventHandler("executeCommandForClient", getRootElement(),
    function(command, pID)
        executeCommandHandler(command, source, pID)
    end
)

addEvent("requestPlayerDatas", true)
addEventHandler("requestPlayerDatas", getRootElement(),
    function(player)
        if connection then
            local datas = {}
            local qh = dbQuery(
                function()
    
                end,
            {player}, connection, "SELECT * FROM bans WHERE playerAccountId = '"..getElementData(player, "char.accID").."'")
            local result = dbPoll(qh, -1)
            datas.banNum = #result

            local qh = dbQuery(
                function()
    
                end,
            {player}, connection, "SELECT * FROM log_adminjail WHERE accountId = '"..getElementData(player, "char.accID").."'")
            local result = dbPoll(qh, -1)
            datas.jailNum = #result

            triggerClientEvent(source, "onClientGotDatas", source, datas)
        end
    end
)