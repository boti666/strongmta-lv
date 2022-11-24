local connection = exports.see_database:getConnection()

addEvent("getTickSyncKillmsg", true)
addEventHandler("getTickSyncKillmsg", getRootElement(),
	function ()
		if isElement(source) then
			triggerClientEvent(source, "getTickSyncKillmsg", source, getRealTime().timestamp)
		end
	end)

addEvent("urmaDebugPre", true)
addEventHandler("urmaDebugPre", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			--print("debughook")
			--triggerClientEvent(source, "getTickSyncKillmsg", source, getRealTime().timestamp)
		end
	end
)

addEvent("interiorReport", true)
addEventHandler("interiorReport", getRootElement(),
	function ()
		if isElement(source) and client and client == source then 
			if getElementData(source, "loggedIn") then
				if getPlayerSerial(source) == "3964A9A5103CDA070946DED861649B52" then 
					local characterId = getElementData(source, "char.ID") or 0
					local query = dbQuery(connection, "SELECT * FROM interiors WHERE ownerId = ?", characterId)
					local queryResult = dbPoll(query, -1)
					queryResult = queryResult[1]
					--iprint(queryResult)

					if not queryResult then 
						return print("no result")
					end

					local notReportedInteriors = queryResult.lastReport or nil

					if notReportedInteriors > -1 then 
						print(inspect(tostring(notReportedInteriors)))
					end
				end
			end
		end
	end 
)