local bone_0 = {5, 4, 3, 1, 4, 4, 32, 22, 33, 23, 34, 24, 41, 51, 42, 52, 43, 53, 44, 54}
local bone_t = {nil, 5, nil, 2, 32, 22, 33, 23, 34, 24, 35, 25, 42, 52, 43, 53, 42, 52, 43, 53}
local bone_f = {6, 8, 31, 3, 5, 5, 34, 24, 32, 22, 36, 26, 43, 53, 44, 54, 44, 54, 42, 52}

local sx, sy, sz = 0, 0, 3
local tx, ty, tz = 0, 0, 4
local fx, fy, fz = 0, 1, 3

local sqrt = math.sqrt
local deg = math.deg
local asin = math.asin
local atan2 = math.atan2
local rad = math.rad
local sin = math.sin
local cos = math.cos

local minimized = false

addEvent("attachElementToBone", true)
addEvent("detachElementFromBone", true)
addEventHandler("attachElementToBone", getRootElement(), attachElementToBone)
addEventHandler("detachElementFromBone", getRootElement(), detachElementFromBone)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setTimer(triggerServerEvent, 2000, 1, "requestAttachmentData", localPlayer)
	end)

addEventHandler("onClientPreRender", getRootElement(),
	function ()
		if minimized then
			return
		end

		for k = 1, #attachments do
			local v = attachments[k]

			if v then
				local element = v[1]
				local ped = v[2]

				if not isElement(element) then
					clearData(element)
				else
					if isElementStreamedIn(ped) then
						local xx, xy, xz, yx, yy, yz, zx, zy, zz = getBoneMatrix(ped, v[3])
						local offrx, offry, offrz = v[7], v[8], v[9]
						local rxx, rxy, rxz, ryx, ryy, ryz, rzx, rzy, rzz = getMatrixFromEulerAngles(offrx, offry, offrz)

						offrx, offry, offrz = getEulerAnglesFromMatrix(
							rxx * xx + rxy * yx + rxz * zx,
							rxx * xy + rxy * yy + rxz * zy,
							rxx * xz + rxy * yz + rxz * zz,
							ryx * xx + ryy * yx + ryz * zx, 
							ryx * xy + ryy * yy + ryz * zy,
							ryx * xz + ryy * yz + ryz * zz,
							rzx * xx + rzy * yx + rzz * zx,
							rzx * xy + rzy * yy + rzz * zy,
							rzx * xz + rzy * yz + rzz * zz
						)

						local x, y, z = getPedBonePosition(ped, bone_0[v[3]])
						local offx, offy, offz = v[4], v[5], v[6]
						local objx, objy, objz = x + offx * xx + offy * yx + offz * zx, y + offx * xy + offy * yy + offz * zy, z + offx * xz + offy * yz + offz * zz

						if not isNaN(objx) and not isNaN(objy) and not isNaN(objz) then
							setElementPosition(element, objx, objy, objz)
						end
						
						if not isNaN(offrx) and not isNaN(offry) and not isNaN(offrz) then
							setElementRotation(element, offrx, offry, offrz, "ZXY")
						end
					else
						setElementPosition(element, getElementPosition(ped))
					end
				end
			end
		end
	end)

addEventHandler("onClientMinimize", getRootElement(),
	function ()
		minimized = true
	end)

addEventHandler("onClientRestore", getRootElement(),
	function ()
		minimized = false
	end)

addEvent("receiveAttachmentData", true)
addEventHandler("receiveAttachmentData", getRootElement(),
	function (attachs, attachsId)
		for k = 1, #attachs do
			local v = attachs[k]

			if v then
				local element = v[1]
				local attachmentId = #attachments + 1

				attachments[attachmentId] = v
				attachmentsId[element] = attachmentId

				setElementCollisionsEnabled(element, false)
			end
		end
	end)

function isNaN(x)
	return x ~= x
end

function getMatrixFromPoints(x, y, z, x3, y3, z3, x2, y2, z2)
	x3 = x3 - x
	y3 = y3 - y
	z3 = z3 - z
	x2 = x2 - x
	y2 = y2 - y
	z2 = z2 - z
	
	local x1 = y2 * z3 - z2 * y3
	local y1 = z2 * x3 - x2 * z3
	local z1 = x2 * y3 - y2 * x3
	
	x2 = y3 * z1 - z3 * y1
	y2 = z3 * x1 - x3 * z1
	z2 = x3 * y1 - y3 * x1
	
	local len1 = 1 / sqrt(x1 * x1 + y1 * y1 + z1 * z1)
	local len2 = 1 / sqrt(x2 * x2 + y2 * y2 + z2 * z2)
	local len3 = 1 / sqrt(x3 * x3 + y3 * y3 + z3 * z3)
	
	x1 = x1 * len1
	y1 = y1 * len1
	z1 = z1 * len1
	x2 = x2 * len2
	y2 = y2 * len2
	z2 = z2 * len2
	x3 = x3 * len3
	y3 = y3 * len3
	z3 = z3 * len3
	
	return x1, y1, z1, x2, y2, z2, x3, y3, z3
end

function getEulerAnglesFromMatrix(x1, y1, z1, x2, y2, z2, x3, y3, z3)
	local nz1, nz2, nz3
	nz3 = sqrt(x2 * x2 + y2 * y2)
	nz1 = -x2 * z2 / nz3
	nz2 = -y2 * z2 / nz3
	
	local vx = nz1 * x1 + nz2 * y1 + nz3 * z1
	local vz = nz1 * x3 + nz2 * y3 + nz3 * z3
	
	return deg(asin(z2)), -deg(atan2(vx, vz)), -deg(atan2(x2, y2))
end

function getMatrixFromEulerAngles(x, y, z)
	x, y, z = rad(x), rad(y), rad(z)
	local sinx, cosx, siny, cosy, sinz, cosz = sin(x), cos(x), sin(y), cos(y), sin(z), cos(z)
	
	return cosy * cosz - siny * sinx * sinz, cosy * sinz + siny * sinx * cosz, -siny * cosx, -cosx * sinz, cosx * cosz, sinx, siny * cosz + cosy * sinx * sinz, siny * sinz - cosy * sinx * cosz, cosy * cosx
end

if not isFromServerSide then
	function getBoneMatrix(ped, bone)
		local x, y, z, tx, ty, tz, fx, fy, fz
		x, y, z = getPedBonePosition(ped, bone_0[bone])
		
		if bone == 1 then
			local x6, y6, z6 = getPedBonePosition(ped, 6)
			local x7, y7, z7 = getPedBonePosition(ped, 7)
			tx, ty, tz = (x6 + x7) * 0.5, (y6 + y7) * 0.5, (z6 + z7) * 0.5
		elseif bone == 3 then
			local x21, y21, z21 = getPedBonePosition(ped, 21)
			local x31, y31, z31 = getPedBonePosition(ped, 31)
			tx, ty, tz = (x21 + x31) * 0.5, (y21 + y31) * 0.5, (z21 + z31) * 0.5
		else
			tx, ty, tz = getPedBonePosition(ped, bone_t[bone])
		end
		
		fx, fy, fz = getPedBonePosition(ped, bone_f[bone])
		local xx, xy, xz, yx, yy, yz, zx, zy, zz = getMatrixFromPoints(x, y, z, tx, ty, tz, fx, fy, fz)
		
		if bone == 1 or bone == 3 then
			xx, xy, xz, yx, yy, yz = -yx, -yy, -yz, xx, xy, xz
		end
		
		return xx, xy, xz, yx, yy, yz, zx, zy, zz
	end
end