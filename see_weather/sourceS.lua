local availableWeathers = {11, 12, 13, 14, 17, 18}

local currentWeather = availableWeathers[1]
local nextWeather = availableWeathers[2]

local forcedWeather = false
local forcedTime = false

local elapsedMinutes = 0

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		processMinute(true, true)
		setTimer(processMinute, 1000 * 60 * 1, 0)
	end
)

addEvent("requestWeather", true)
addEventHandler("requestWeather", getRootElement(),
	function ()
		triggerClientEvent(client or source, "receiveWeather", resourceRoot, forcedWeather or currentWeather, forcedWeather or nextWeather, forcedTime or getRealTime())
	end
)

function processMinute(randomizeWeather, isResourceStart)
	elapsedMinutes = elapsedMinutes + 1

	if elapsedMinutes == 30 or randomizeWeather then
		elapsedMinutes = 0
		currentWeather = availableWeathers[math.random(1, #availableWeathers)]

		if not nextWeather then
			nextWeather = currentWeather
		end

		while nextWeather == currentWeather do
			nextWeather = availableWeathers[math.random(1, #availableWeathers)]
		end
	end

	if not isResourceStart then
		triggerClientEvent("receiveWeather", resourceRoot, forcedWeather or currentWeather, forcedWeather or nextWeather, forcedTime or getRealTime())
	end
end

function setServerTime(hour, minute)
	local realTime = getRealTime()

	if hour and minute then
		forcedTime = realTime
		forcedTime.hour = hour
		forcedTime.minute = minute
	else
		forcedTime = false
	end

	triggerClientEvent("receiveWeather", resourceRoot, forcedWeather or currentWeather, forcedWeather or nextWeather, forcedTime or realTime)
end

function setServerWeather(weatherId)
	forcedWeather = weatherId
	triggerClientEvent("receiveWeather", resourceRoot, forcedWeather or currentWeather, forcedWeather or nextWeather, forcedTime or getRealTime())
end

addCommandHandler("setweather",
	function (sourcePlayer, commandName, weatherId)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 7 then
			if not weatherId then
				outputChatBox("#ff9600[Használat]: #ffffff/" .. commandName .. " [ID (* = visszaállítás)]", sourcePlayer, 0, 0, 0, true)
			elseif weatherId == "*" then
				setServerWeather(false)
				outputChatBox("#3d7abc[StrongMTA]: #ffffffAz időjárás visszaállítva.", sourcePlayer, 0, 0, 0, true)
			else
				weatherId = tonumber(weatherId)
				setServerWeather(weatherId)
				outputChatBox("#3d7abc[StrongMTA]: #ffffffAz időjárás átállítva. #32b3ef(" .. weatherId .. ")", sourcePlayer, 0, 0, 0, true)
			end
		end
	end
)

addCommandHandler("settime",
	function (sourcePlayer, commandName, hour, minute)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 7 then
			if not hour then
				outputChatBox("#ff9600[Használat]: #ffffff/" .. commandName .. " [Óra (* = valós idő)] < [Perc] >", sourcePlayer, 0, 0, 0, true)
			elseif hour == "*" then
				setServerTime(false, false)
				outputChatBox("#3d7abc[StrongMTA]: #ffffffAz idő visszaállítva.", sourcePlayer, 0, 0, 0, true)
			else
				hour = tonumber(hour) or 12
				minute = tonumber(minute) or 0

				if hour >= 0 and hour <= 23 and minute >= 0 and minute <= 59 then
					setServerTime(hour, minute)
					outputChatBox("#3d7abc[StrongMTA]: #ffffffAz idő átállítva. #32b3ef(" .. string.format("%.2i:%.2i", hour, minute) .. ")", sourcePlayer, 0, 0, 0, true)
				else
					outputChatBox("#d75959[StrongMTA]: #ffffffÉrvénytelen idő intervallum.", sourcePlayer, 0, 0, 0, true)
				end
			end
		end
	end
)

addCommandHandler("setrain",
	function (sourcePlayer, commandName, rainLevel)
		if getElementData(sourcePlayer, "acc.adminLevel") >= 7 then
			if not rainLevel then
				outputChatBox("#ff9600[Használat]: #ffffff/" .. commandName .. " [Szint [0-10] (* = visszaállítás)]", sourcePlayer, 0, 0, 0, true)
			elseif rainLevel == "*" then
				resetRainLevel()
				outputChatBox("#3d7abc[StrongMTA]: #ffffffAz eső szintje visszaállítva.", sourcePlayer, 0, 0, 0, true)
			else
				rainLevel = tonumber(rainLevel) or 0
				setRainLevel(rainLevel)
				outputChatBox("#3d7abc[StrongMTA]: #ffffffAz eső szintje átállítva. #32b3ef(" .. rainLevel .. ")", sourcePlayer, 0, 0, 0, true)
			end
		end
	end
)
