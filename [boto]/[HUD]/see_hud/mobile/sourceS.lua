addEvent("attachMobilePhone", true)
addEventHandler("attachMobilePhone", getRootElement(),
	function(state)
		if state then

		else

		end
	end
)

function callMember(number)
	for k, v in ipairs(getElementsByType("player")) do
		if v and number and exports.see_items:hasItemWithData(v, 9, tonumber(number), "data1") then
			return v
		end
	end
	return false
end


addEvent("callNumber", true)
addEventHandler("callNumber", getRootElement(),
	function(callNum, playerNum)
		local player = callMember(callNum)
		
		if player then
			triggerClientEvent(player, "incomingCall", source, playerNum, callNum)
		else
			triggerClientEvent(source, "lineIsBusy", source)
			--triggerClientEvent(source, "talkingSysMessage", source, "#DC143CEzen a számon előfizető \nnem kapcsolható")
		end
	end
)

addEvent("acceptCall", true)
addEventHandler("acceptCall", getRootElement(),
	function(player)
		local triggeredP = source

		triggerClientEvent(player, "someoneAccepted", triggeredP)
		triggerClientEvent(player, "callingWith", triggeredP)

		--iprint(triggeredP)
	end
)

addEvent("playRingtone", true)
addEventHandler("playRingtone", getRootElement(),
	function(currentRingtone)
		if tonumber(currentRingtone) then

		end
	end
)

addEvent("playVibrate", true)
addEventHandler("playVibrate", getRootElement(),
	function()

	end
)

addEvent("playNotificationSound", true)
addEventHandler("playNotificationSound", getRootElement(),
	function(currentNotisound)
		if tonumber(currentNotisound) then

		end
	end
)

addEvent("sendPhoneMessage", true)
addEventHandler("sendPhoneMessage", getRootElement(),
	function(asd1, asd2, asd3)
		if asd1 and asd2 and asd3 then
			--iprint(asd1)
			--iprint(asd2)
			--iprint(asd3)

			triggerClientEvent(asd1, "talkingSysMessage", asd1, asd2)
		end
	end
)

addEvent("cancelCall", true)
addEventHandler("cancelCall", getRootElement(),
	function(player)
		--iprint(player)
		--iprint(source)
		
		if player then
			triggerClientEvent(player, "callEnd", player)
		end
	end
)

addEvent("sendSMS", true)
addEventHandler("sendSMS", getRootElement(),
	function(smsNum, sourceNum, sourceMessage)

		local player = callMember(smsNum)
		
		if player then
			triggerClientEvent(player, "gotSMS", source, tonumber(sourceNum), sourceMessage)
			triggerClientEvent(source, "addToMySMSLine", player, sourceMessage, tonumber(smsNum), false)
		else
			triggerClientEvent(source, "addToMySMSLine", source, sourceMessage, tonumber(smsNum), true)
		end
	end
)

addEvent("sendAdvertisement", true)
addEventHandler("sendAdvertisement", getRootElement(),
	function(advertiseMessage, phone, asd3)
		if isElement(source) and client and client == source then 
			triggerClientEvent(root, "onAdvertisement", source, advertiseMessage, phone)
		end
	end
)

addEvent("selfieAim", true)
addEventHandler("selfieAim", getRootElement(),
	function(state)
		if state then
	    	setPedAnimation(source, "PED", "gang_gunstand")
	  	else
	    	setPedAnimation(source, false)
	  	end
	end
)

