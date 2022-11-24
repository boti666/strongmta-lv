local adminNames = false

addCommandHandler("anames",
	function ()
		if getElementData(localPlayer, "adminDuty") == 0 and getElementData(localPlayer, "acc.adminLevel") < 6 then
			if getElementData(localPlayer, "acc.rpGuard") > 0 then 
				return 
			end 
			outputChatBox("#d75959[StrongMTA]: #ffffffCsak semmi MG!", 255, 255, 255, true)
		end
		if getElementData(localPlayer, "adminDuty") == 1 or getElementData(localPlayer, "acc.adminLevel") > 5 then 
			if not adminNames then 
				adminNames = "normal"
				outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen #7cc576bekapcsoltad #ffffffaz adminisztrátori neveket.", 255, 255, 255, true)
				if getElementData(localPlayer, "acc.adminLevel") >= 6 then 
					adminNames = "super"
				end
			else
				adminNames = false
				outputChatBox("#3d7abc[StrongMTA]: #ffffffSikeresen #d75959kikapcsoltad #ffffffaz adminisztrátori neveket.", 255, 255, 255, true)
			end
		end
	end 
)

addCommandHandler("togname",
	function ()
		showMyName = not showMyName
		print(showMyName)
	end 
)

