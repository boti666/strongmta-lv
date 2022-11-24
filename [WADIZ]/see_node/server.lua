local savingProcessActive = false

local zoneFileOutPath = "nodes/%d.data"
local zoneListFileOutPath = "nodes/zones.list"

addEvent("saveGeneratedNodes", true)
addEventHandler("saveGeneratedNodes", resourceRoot,
	function (generatedNodes, generatedNodesByZones)
		if not savingProcessActive then
			local saveProcessThread = coroutine.create(saveNodes)

			if saveProcessThread then
				if fileExists(zoneListFileOutPath) then
					local listFile = fileOpen(zoneListFileOutPath)

					if listFile then
						local fileSize = fileGetSize(listFile)
						local fileData = fileRead(listFile, fileSize)

						fileClose(listFile)

						if fileData then
							fileData = split(fileData, "/")

							if type(fileData) == "table" then
								for i = 1, #fileData do
									local zoneIndex = tonumber(fileData[i])
									local zoneFilePath = zoneFileOutPath:format(zoneIndex)

									if fileExists(zoneFilePath) then
										fileDelete(zoneFilePath)
									end
								end
							end
						end
					end
				end
				coroutine.resume(saveProcessThread, generatedNodes, generatedNodesByZones)
			end
		end
	end
)

function saveNodes(generatedNodes, generatedNodesByZones)
	if not coroutine.running() or savingProcessActive then
		return
	end

	savingProcessActive = true
	triggerClientEvent("onSavingProcessStateChange", resourceRoot, savingProcessActive)
	print("Saving of nodes started.")

	local zoneCollection = {}

	for zoneIndex, nodeCollection in pairs(generatedNodesByZones) do
		local zoneFile = fileCreate(zoneFileOutPath:format(zoneIndex))

		if zoneFile then
			zoneCollection[#zoneCollection + 1] = zoneIndex

			for i = 1, #nodeCollection do
				local nodeIndex = nodeCollection[i]
				local nodeCoors = generatedNodes[nodeIndex]

				if nodeCoors then
					if i < #nodeCollection then
						fileWrite(zoneFile, table.concat(nodeCoors, " ") .. "\r\n")
					else
						fileWrite(zoneFile, table.concat(nodeCoors, " "))
					end

					fileFlush(zoneFile)
				end
			end

			fileClose(zoneFile)
		end
	end

	local listFile = fileCreate(zoneListFileOutPath)

	if listFile then
		fileWrite(listFile, table.concat(zoneCollection, "/"))
		fileClose(listFile)
	end

	savingProcessActive = false
	triggerClientEvent("onSavingProcessStateChange", resourceRoot, savingProcessActive)
	print("Nodes saved.")
end
