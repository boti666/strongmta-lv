local attachmentsData = {}
serverSide = true

addEvent("requestAttachmentData", true)
addEventHandler("requestAttachmentData", getRootElement(),
	function ()
		if attachmentsData[client] then
			return
		end

		triggerClientEvent(client, "receiveAttachmentData", client, attachments, attachmentsId)

		attachmentsData[client] = true
	end)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		if attachmentsData[source] then
			attachmentsData[source] = nil
		end
	end)

addEventHandler("onElementDestroy", getRootElement(),
	function ()
		if attachmentsData[source] then
			attachmentsData[source] = nil
		end
	end)