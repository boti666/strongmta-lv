local shutdownTimer = false
local shutdownTimeLeft = 0
local shutdownReason = ""

addCommandHandler("startshutdown",
	function (sourcePlayer, commandName, seconds, ...)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			seconds = tonumber(seconds)

			if not (seconds and (...)) then
				outputChatBox("#3d7abc[Használat]: #ffffff/" .. commandName .. " [Másodperc] [Indok]", sourcePlayer, 0, 0, 0, true)
			else
				if isTimer(shutdownTimer) then
					killTimer(shutdownTimer)
				end

				shutdownReason = table.concat({...}, " ")
				shutdownTimeLeft = seconds
				shutdownTimer = setTimer(shutdownTick, 1000, seconds)
				shutdownTick()

				triggerClientEvent(getElementsByType("player"), "startShutdown", resourceRoot, seconds)

				outputChatBox("#d75959[SZERVER LEÁLLÍTÁS]: Indoklás: #ffffff" .. shutdownReason, root, 0, 0, 0, true)
				outputChatBox("#d75959[SZERVER LEÁLLÍTÁS]: Mindenkinek erősen ajánlott a folyamatban lévő munkákat leadni, mivel azok jelenlegi állapota nem kerül mentésre!", root, 0, 0, 0, true)
			end
		end
	end)

addCommandHandler("stopshutdown",
	function (sourcePlayer, commandName)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 9 then
			if shutdownTimer then
				if isTimer(shutdownTimer) then
					killTimer(shutdownTimer)
				end

				shutdownTimer = nil
				shutdownTimeLeft = 0
				shutdownReason = ""

				triggerClientEvent("stopShutdown", resourceRoot)
			else
				outputChatBox("#d75959[StrongMTA - Shutdown]: #ffffffNincs leállítás folyamatban.", sourcePlayer, 0, 0, 0, true)
			end
		end
	end)

function shutdownTick()
	if shutdownTimeLeft > 0 then
		local minute = math.floor(shutdownTimeLeft / 60)
		local seconds = shutdownTimeLeft - minute * 60

		if (minute == 0 and seconds ~= 0) or seconds == 0 then
			triggerClientEvent(getElementsByType("player"), "shutdownTick", resourceRoot)

			if minute > 0 and seconds == 0 then
				outputChatBox("#d75959[SZERVER LEÁLLÍTÁS]: Figyelem, a szerver #ffffff" .. minute .. " perc #d75959múlva leáll!", root, 0, 0, 0, true)
			elseif minute == 0 and seconds ~= 0 then
				outputChatBox("#d75959[SZERVER LEÁLLÍTÁS]: Figyelem, a szerver #ffffff" .. seconds .. " másodperc #d75959múlva leáll!", root, 0, 0, 0, true)
			end
		end
	else
		shutdown(shutdownReason or "")
	end

	shutdownTimeLeft = shutdownTimeLeft - 1
end
