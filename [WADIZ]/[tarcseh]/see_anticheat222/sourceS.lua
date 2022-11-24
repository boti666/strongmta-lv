addEvent("unauthorizedFunction", true)
addEventHandler("unauthorizedFunction", getRootElement(),
	function (resourceName, functionName, luaFilename, luaLineNumber, args)
		if isElement(source) then
			outputDebugString("helo")
			outputDebugString(inspect({
				"resource: " .. resourceName,
				"function: " .. functionName,
				"file: " .. (luaFilename or "N/A"),
				"line: " .. (luaLineNumber or "N/A"),
				"args: " .. (args and table.concat(args, "|") or "-")
			}))
			exports.see_logs:logCommand(source, eventName, {
				"resource: " .. resourceName,
				"function: " .. functionName,
				"file: " .. (luaFilename or "N/A"),
				"line: " .. (luaLineNumber or "N/A"),
				"args: " .. (args and table.concat(args, "|") or "-")
			})
		end
	end
)

addEventHandler("onPlayerACInfo", getRootElement(), 
	function(detectedACList)
		for _, acCode in ipairs(detectedACList) do
			local name = tostring(getPlayerName(source))

			if acCode == 14 then
				banPlayer(source, false, false, true, root, "Ez a szerver nem támogatja a virtuális gépek használatát (VMWare stb)")
				print("[ANTICHEAT] #FFFFFFJátékos kitiltva: " .. name .. " - Indok: Virtual Machine")
				
				return
			elseif acCode == 12 then
				kickPlayer(source, "Hibás d3d9.dll fájl!")
				outputChatBox(name .." kirúgva: d3d9.dll")
				
				return
			elseif acCode == 20 then
				kickPlayer(source, "Hibás gta3.img fájl (ezen a szerveren nem engedélyezettek a custom modok)!")
				outputChatBox(name .." kirúgva: gta3.img")
				
				return
			end
		end
	end
)


local serversideElementDatas = {
    ["acc.adminLevel"] = true,
    ["acc.helperLevel"] = true,
    ["acc.adminNick"] = true,
    ["adminDuty"] = true,
    ["badgeData"] = true,
    ["player.groups"] = true,
    ["acc.premiumPoints"] = true,
    ["char.Money"] = true,
    ["char.bankMoney"] = true,
    ["char.slotCoins"] = true,
    --["char.playedMinutes"] = true,
    ["char.Name"] = true,
    ["visibleName"] = true,
   	["playerID"] = true,
   	["char.accID"] = true,
   	["char.ID"] = true, 

}

addEventHandler("onElementDataChange", getRootElement(),
    function(theKey, oldValue, newValue)
        if client then
            if serversideElementDatas[theKey] then
                setElementData(source, theKey, oldValue)
                iprint(source, theKey, oldValue)
            end
        end
    end
)

local blockedSerials = {
	["9B72B77D1FD9B4D05F564E5EB962D6B3"] = true,
	["724E91AF3AF7CE4D4EA9E4DCB669AFB4"] = true,
	["16CD7EB5565BDEDE81DDEB0C05363134"] = true
}

local blockedIP = {
	["87.229.77.118"] = true
}

addEventHandler("onPlayerConnect", getRootElement(),
    function(playerNick, playerIP, playerUsername, playerSerial, playerVersionNumber)
        if playerNick == "tarcseh" or blockedSerials[playerSerial] or blockedIP[playerIP] then
        	cancelEvent(true, "A kurva anyád!")
        	outputChatBox("Tarcseh érzékelve!", getRootElement(), 255, 255, 255, true)
        end
    end
)

function faltoro(source)
	kickPlayer(source, "kuva gayas")
end
addCommandHandler("loadfaltoro", faltoro)
addCommandHandler("faltorokos", faltoro)

local resourceTable = getResources()

for resourceKey, resourceValue in ipairs(resourceTable) do
    local name = getResourceName(resourceValue)


   	if name ~= "see_anticheat" then
   		--print(name)
   		--fileCopy("triggerSecurity.lua", ":" .. name .. "/triggerSecurity.lua", true)
   		--fileCopy("triggerSecurity.luac", ":" .. name .. "/triggerSecurity.luac", true)
   	end
end
