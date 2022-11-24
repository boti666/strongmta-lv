attachments = {}
attachmentsId = {}

function attachElementToBone(element, ped, bone, x, y, z, rx, ry, rz)
	if not isElement(element) or not isElement(ped) then
		return false
	end

	if getElementType(ped) ~= "player" and getElementType(ped) ~= "ped" then
		return false
	end

	bone = tonumber(bone)

	if not bone or bone < 1 or bone > 20 then
		return false
	end

	x = tonumber(x) or 0
	y = tonumber(y) or 0
	z = tonumber(z) or 0

	rx = tonumber(rx) or 0
	ry = tonumber(ry) or 0
	rz = tonumber(rz) or 0

	local attachmentId = attachmentsId[element]

	if not attachmentId then
		attachmentId = #attachments + 1
	end

	attachments[attachmentId] = {element, ped, bone, x, y, z, rx, ry, rz}
	attachmentsId[element] = attachmentId

	setElementCollisionsEnabled(element, false)

	if serverSide then
		triggerClientEvent(getElementsByType("player"), "attachElementToBone", resourceRoot, element, ped, bone, x, y, z, rx, ry, rz)
	end

	return true
end

function detachElementFromBone(element)
	if not element or not attachmentsId[element] then
		return false
	end

	clearData(element)

	setElementCollisionsEnabled(element, true)

	if serverSide then
		triggerClientEvent(getElementsByType("player"), "detachElementFromBone", resourceRoot, element)
	end

	return true
end

function isElementAttachedToBone(element)
	if not element then
		return false
	end

	local attachId = attachmentsId[element]

	if not attachId then
		return false
	end

	return isElement(attachments[attachId][2])
end

function getElementBoneAttachmentDetails(element)
	if not element then
		return false
	end

	local attachId = attachmentsId[element]

	if not attachId then
		return false
	end

	if not isElement(attachments[attachId][2]) then
		return false
	end

	return attachments[attachId][2], attachments[attachId][3], attachments[attachId][4], attachments[attachId][5], attachments[attachId][6], attachments[attachId][7], attachments[attachId][8], attachments[attachId][9]
end

function setElementBonePositionOffset(element, x, y, z)
	local ped, bone, _, _, _, rx, ry, rz = getElementBoneAttachmentDetails(element)

	if not ped then
		return false
	end

	return attachElementToBone(element, ped, bone, x, y, z, rx, ry, rz)
end

function setElementBoneRotationOffset(element, rx, ry, rz)
	local ped, bone, x, y, z = getElementBoneAttachmentDetails(element)

	if not ped then
		return false
	end

	return attachElementToBone(element, ped, bone, x, y, z, rx, ry, rz)
end

if not serverSide then
	function getBonePositionAndRotation(ped, bone)
		if not isElement(ped) then
			return false
		end

		if getElementType(ped) ~= "player" and getElementType(ped) ~= "ped" then
			return false
		end

		if not isElementStreamedIn(ped) then
			return false
		end

		bone = tonumber(bone)

		if not bone or bone < 1 or bone > 20 then
			return false
		end

		local x, y, z = getPedBonePosition(ped, bone_0[bone])
		local rx, ry, rz = getEulerAnglesFromMatrix(getBoneMatrix(ped, bone))

		return x, y, z, rx, ry, rz
	end
end

function clearData(element)
	if not element then
		return false
	end

	local attachId = attachmentsId[element]

	if not attachId then
		return false
	end

	local temp = {}

	attachmentsId = {}

	for i = 1, #attachments do
		if attachments[i] and i ~= attachId then
			local newId = #temp + 1
			temp[newId] = attachments[i]
			attachmentsId[attachments[i][1]] = newId
		end
	end

	attachments = temp
end

if not serverSide then
	addEventHandler("onClientElementDestroy", getRootElement(),
		function ()
			if attachmentsId[source] then
				clearData(source)
			end
		end)
else
	addEventHandler("onElementDestroy", getRootElement(),
		function ()
			if attachmentsId[source] then
				clearData(source)
			end
		end)
end