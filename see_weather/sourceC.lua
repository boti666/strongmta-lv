addEventHandler("onClientResourceStart", getResourceRootElement(),
	function (dataName)
		if getElementData(localPlayer, "loggedIn") then
			setTimer(triggerServerEvent, 500, 1, "requestWeather", localPlayer)
		end
	end
)

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName)
		if dataName == "loggedIn" then
			if getElementData(source, dataName) then
				triggerServerEvent("requestWeather", localPlayer)
			end
		end
	end
)

addEvent("receiveWeather", true)
addEventHandler("receiveWeather", getRootElement(),
	function (current_weather, next_weather, current_time)
		setWeather(current_weather)
		setWeatherBlended(next_weather)
		setTime(current_time.hour, current_time.minute)
		setMinuteDuration(60000)
	end
)
