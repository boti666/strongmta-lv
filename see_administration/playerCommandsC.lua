local answerState = true

addCommandHandler("togvá",
	function ()
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			if answerState then
				outputChatBox("#3d7abc[StrongMTA - #32b3efAdminNapló#3d7abc]: #ffffffSikeresen kikapcsoltad a /vá-kat!", 255, 255, 255, true)
				answerState = false
			else
				outputChatBox("#3d7abc[StrongMTA - #32b3efAdminNapló#3d7abc]: #ffffffSikeresen bekapcsoltad a /vá-kat!", 255, 255, 255, true)
				answerState = true
			end
		end
	end)

addEvent("onAdminMSGVa", true)
addEventHandler("onAdminMSGVa", getRootElement(),
	function (message)
		if answerState then
			local adminLevel = getElementData(localPlayer, "acc.adminLevel") or 0

			if adminLevel >= 1 then
				outputChatBox("#3d7abc[StrongMTA - #32b3efAdminNapló#3d7abc]: #ffffff" .. message, 255, 255, 255, true)
			end
		end
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function(dataName)
		if source == localPlayer then
			if dataName == "acc.adminLevel" then
				if getElementData(source, dataName) >= 9 then
					setDevelopmentMode(true, true)
				else
					setDevelopmentMode(false)
				end
			elseif dataName == "adminDuty" then
				if getElementData(source, "acc.adminLevel") >= 9 then
					setDevelopmentMode(true, true)
				else
					setDevelopmentMode(false)
				end
			end
		end
	end)

addCommandHandler("getpos",
	function()
		if getElementData(localPlayer, "acc.adminLevel") >= 1 then
			local cx, cy, cz, lx, ly, lz = getCameraMatrix()
			local pedveh = getPedOccupiedVehicle(localPlayer)

			if pedveh then
				outputChatBox("Position: " .. table.concat({getElementPosition(pedveh)}, ", "))
				outputChatBox("Rotation: " .. table.concat({getElementRotation(pedveh)}, ", "))
			else
				outputChatBox("Position: " .. table.concat({getElementPosition(localPlayer)}, ", "))
				outputChatBox("Rotation: " .. table.concat({getElementRotation(localPlayer)}, ", "))
			end

			outputChatBox("Interior: " .. getElementInterior(localPlayer))
			outputChatBox("Dimension: " .. getElementDimension(localPlayer))

			outputChatBox("Camera Position: " .. table.concat({cx, cy, cz}, ", "))
			outputChatBox("Camera Rotation: " .. table.concat({lx, ly, lz}, ", "))
		end
	end)


--addCommandHandler("asd",
--	function ()
--		triggerServerEvent("spawnToHospital", localPlayer)
--	end 
--)
--function onClientChatMessageHandler(text)
	--if string.find(text, "SeeMTA") then
	--	cancelEvent()
	--end
--end
--addEventHandler("onClientChatMessage", root, onClientChatMessageHandler)