-- Xenius
local resources = {}
local lastResource = 0
function compileResource(res)
	local xmlPatch = ":"..res.."/meta.xml"
	local xmlFile = xmlLoadFile(xmlPatch)
	if xmlFile then
		outputDebugString("RESOURCE: "..res,0,55,167,220)
		local index = 0
		local scriptNode = xmlFindChild(xmlFile,'script',index)
		if scriptNode then
			repeat
			local scriptPath = xmlNodeGetAttribute(scriptNode,'src') or false
			local scriptType = xmlNodeGetAttribute(scriptNode,'type') or "server"
			local serverEncypt = xmlNodeGetAttribute(scriptNode,'encypt') or "null"
			if scriptPath and (scriptType:lower() == "client" or serverEncypt:lower() == "true" or scriptType:lower() == "shared") then
				if string.find(scriptPath:lower(), "luac") then
					outputDebugString("LEVÉDÉS: Fájl "..scriptPath.." már levédett!",3,220,20,20)
				else
					local FROM=":"..res.."/"..scriptPath
					local TO= ":"..res.."/"..scriptPath.."c"
					fetchRemote("http://luac.mtasa.com/?compile=1&debug=0&obfuscate=3", function(data) fileSave(TO,data) end, fileLoad(FROM), true)
					xmlNodeSetAttribute(scriptNode,'src',scriptPath..'c')
					if serverEncypt:lower() == "true" then
						if fileExists(FROM) then
							outputDebugString("LEVÉDÉS: ".. FROM.." törölve. (encypt = true)",3,0,255,0)
							fileDelete(FROM)
						end
					end
					outputDebugString("LEVÉDÉS: ".. TO.." Levédve és elmentve",3,0,255,0)
				end
			end
			index = index + 1
			scriptNode = xmlFindChild(xmlFile,'script',index)
			until not scriptNode
		end
		xmlSaveFile(xmlFile)
		xmlUnloadFile(xmlFile)
	else
		outputDebugString("LEVÉDÉS: Nem olvasható: meta.xml",3,220,20,20)
		return false
	end
end

function uncompileResource(res)
	local xmlPatch = ":"..res.."/meta.xml"
	local xmlFile = xmlLoadFile(xmlPatch)
	if xmlFile then
		outputDebugString("RESOURCE: "..res,0,55,167,220)
		local index = 0
		local scriptNode = xmlFindChild(xmlFile,'script',index)
		if scriptNode then
			repeat
			local scriptPath = xmlNodeGetAttribute(scriptNode,'src') or false
			local scriptType = xmlNodeGetAttribute(scriptNode,'type') or "server"
			if scriptPath and (scriptType:lower() == "client" or scriptType:lower() == "shared") then
				if string.find(scriptPath:lower(), "luac") then
					fileDelete(":"..res.."/"..scriptPath)
					xmlNodeSetAttribute(scriptNode,'src',scriptPath:gsub("luac","lua"))
					outputDebugString("LEVÉDÉS: "..res.."/"..scriptPath .." már nem védett!",0,255,0,0)
				else
					outputDebugString("LEVÉDÉS: Fájl "..scriptPath.." már nem védett!",3,220,20,20)
				end
			end
			index = index + 1
			scriptNode = xmlFindChild(xmlFile,'script',index)
			until not scriptNode
		end
		xmlSaveFile(xmlFile)
		xmlUnloadFile(xmlFile)
	else
		outputDebugString("LEVÉDÉS: Nem olvasható: meta.xml",3,220,20,20)
		return false
	end
end

addCommandHandler("compileall", function(player,cmd,res)
		resources = getResources()
		lastResource = 0
		compileNextResource()

end)

addCommandHandler("uncompileall", function(player,cmd,res)
		resources = getResources()
		lastResource = 0
		uncompileNextResource()

end)

addCommandHandler("compile", function(player,cmd,res)
		local resource = getResourceFromName(res)
		if resource then
			
			compileResource(res)
			
		else
			
		end

end)

addCommandHandler("uncompile", function(player,cmd,res)
		local resource = getResourceFromName(res)
		if resource then
			uncompileResource(res)

		end
end)

function uncompileNextResource()
	if lastResource < #resources then
		lastResource = lastResource + 1
		uncompileResource(getResourceName(resources[lastResource]))
		setTimer(uncompileNextResource, 1000, 1)
	end
end

function compileNextResource()
	if lastResource < #resources then
		lastResource = lastResource + 1
		compileResource(getResourceName(resources[lastResource]))
		setTimer(compileNextResource, 1000, 1)
	end
end


function fileLoad(path)
    local File = fileOpen(path, true)
    if File then
        local data = fileRead(File, 500000000)
        fileClose(File)
        return data
    end
end
 
function fileSave(path, data)
    local File = fileCreate(path)
    if File then
        fileWrite(File, data)
        fileClose(File)
    end
end