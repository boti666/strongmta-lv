local jailTable = {
	[8] = {
		{{"asd"}},
		{{"asd"}}
	}
}

addEvent("requestAdminData", true)
addEventHandler("requestAdminData", getRootElement(), 
	function(player)
		--triggerClientEvent(player, "receiveAdminData", player, 1, player)
		triggerClientEvent(source, "receiveAdminData", source, getElementData(player, "char.accID"), {{}, {}})
		iprint(player)
	end
)

addEvent("sendAdminReply", true)
addEventHandler("sendAdminReply", getRootElement(), 
	function(playerID, message)
		local targetPlayer, targetName = exports.see_core:findPlayer(source, tonumber(playerID))
	
		if targetPlayer then
			local myName = getElementData(source, "visibleName"):gsub("_", " ")
			local myPlayerID = getElementData(source, "playerID") or "N/A"
			local targetPlayerID = playerID

			local adminName = getElementData(source, "acc.adminNick")
			local adminRank = exports.see_administration:getPlayerAdminTitle(source)

			--outputChatBox(string.format("#ff9000[Válasz]: #ffffff%s (%d): #ff9000%s", targetName, targetPlayerID, message), sourcePlayer, 0, 0, 0, true)
			outputChatBox(string.format("#ff9000[Segítség]: #ffffff%s %s (%d): #ff9000%s", adminRank, adminName, myPlayerID, message), targetPlayer, 0, 0, 0, true)

			triggerClientEvent("onAdminMSGVa", resourceRoot, string.format("%s %s #ffffffválaszolt neki: %s", adminRank, adminName, "#7cc576" .. targetName))
			triggerClientEvent("onAdminMSGVa", resourceRoot, string.format("Üzenet: %s", "#ffffff" .. message))
		end
	end
)

addEvent("executeAdminCommad", true)
addEventHandler("executeAdminCommad", getRootElement(), 
	function(commandName, playerID, reason)
		if reason then
			executeCommandHandler(commandName, source, tonumber(playerID), reason)
		else
			executeCommandHandler(commandName, source, tonumber(playerID))
		end
	end
)