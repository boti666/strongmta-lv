addCommandHandler("asay",
	function (sourcePlayer, commandName, ...)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 1 then
			if not (...) then
				outputChatBox("#ff9600[Használat]: #ffffff/" .. commandName .. " [Üzenet]", sourcePlayer, 255, 255, 255, true)
			else
				local msg = table.concat({...}, " ")

				if #msg > 0 and utfLen(msg) > 0 and utf8.len((utf8.gsub(msg, " ", "") or 0)) > 0 then
					local adminNick = getElementData(sourcePlayer, "acc.adminNick")
					local adminRank = exports.see_administration:getPlayerAdminTitle(sourcePlayer)

					outputChatBox(adminRank .. " " .. adminNick .. ": " .. msg, getRootElement(), 215, 89, 89, true)

					triggerClientEvent(getElementsByType("player"), "playNotification", sourcePlayer, "epanel")
				end
			end
		end
	end)