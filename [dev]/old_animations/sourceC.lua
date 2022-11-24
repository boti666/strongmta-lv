local anim = false
local localPlayer = getLocalPlayer()
local walkanims = { WALK_armed = true, WALK_civi = true, WALK_csaw = true, Walk_DoorPartial = true, WALK_drunk = true, WALK_fat = true, WALK_fatold = true, WALK_gang1 = true, WALK_gang2 = true, WALK_old = true, WALK_player = true, WALK_rocket = true, WALK_shuffle = true, Walk_Wuzi = true, woman_run = true, WOMAN_runbusy = true, WOMAN_runfatold = true, woman_runpanic = true, WOMAN_runsexy = true, WOMAN_walkbusy = true, WOMAN_walkfatold = true, WOMAN_walknorm = true, WOMAN_walkold = true, WOMAN_walkpro = true, WOMAN_walksexy = true, WOMAN_walkshop = true, run_1armed = true, run_armed = true, run_civi = true, run_csaw = true, run_fat = true, run_fatold = true, run_gang1 = true, run_old = true, run_player = true, run_rocket = true, Run_Wuzi = true }
local attachedRotation = false

function onRender()
	local forcedanimation = getElementData(localPlayer, "forcedanimation")

	if (getPedAnimation(localPlayer)) and not (forcedanimation==1) then
		local screenWidth, screenHeight = guiGetScreenSize()
		anim = true

		local block, style = getPedAnimation(localPlayer)
		if block == "ped" and walkanims[ style ] then
			local px, py, pz, lx, ly, lz = getCameraMatrix()
			setPedRotation( localPlayer, math.deg( math.atan2( ly - py, lx - px ) ) - 90 )
		end
	elseif not (getPedAnimation(localPlayer)) and (anim) then
		anim = false
		toggleAllControls(true, true, false)
	end
	
	local element = getElementAttachedTo(localPlayer)
	if element and getElementType( element ) == "vehicle" then
		if attachedRotation then
			local rx, ry, rz = getElementRotation( element )
			setPedRotation( localPlayer, rz + attachedRotation )
		else
			local rx, ry, rz = getElementRotation( element )
			attachedRotation = getPedRotation( localPlayer ) - rz
		end
	elseif attachedRotation then
		attachedRotation = false
	end
end
addEventHandler("onClientRender", getRootElement(), onRender)

function onRender()
	if not getPedAnimation(getLocalPlayer()) and getPedControlState ( "jump" ) and getPedControlState ( "sprint" ) and getPedControlState ( "forwards" ) then -- W + SPACE + SHIFT
		setPedAnimation( getLocalPlayer(), "ped", "EV_dive", 2000, false, true, false)
	end
end
-- addEventHandler("onClientRender", getRootElement(), onRender)


function applyAnimation(thePlayer, block, name, animtime, loop, updatePosition, forced)
	if animtime==nil then animtime=-1 end
	if loop==nil then loop=true end
	if updatePosition==nil then updatePosition=true end
	if forced==nil then forced=true end
	
	
	if isElement(thePlayer) and getElementType(thePlayer)=="player" and not getPedOccupiedVehicle(thePlayer) and getElementData(thePlayer, "freeze") ~= 1 then
		if getElementData(thePlayer, "injuriedanimation") or ( not forced and getPedAnimation(thePlayer) ) then
			return false
		end
		
		toggleAllControls(true, true, false)
		
		if (forced) then
			triggerServerEvent("forcedanim", getLocalPlayer())
		else
			triggerServerEvent("unforcedanim", getLocalPlayer())
		end
		
		local setanim = setPedAnimation(thePlayer, block, name, animtime, loop, updatePosition, false)
		if animtime > 50 then
			setElementData(thePlayer, "animationt", setTimer(removeAnimation, animtime, 1, thePlayer), false)
		end
		return setanim
	else
		return false
	end
end

function removeAnimation(thePlayer)
	if isElement(thePlayer) and getElementType(thePlayer)=="player" and getElementData(thePlayer, "freeze") ~= 1 and not getElementData(thePlayer, "injuriedanimation") then
		local setanim = setPedAnimation(thePlayer)
		triggerServerEvent("unforcedanim", thePlayer)
		toggleAllControls(true, true, false)
		setTimer(setPedAnimation, 50, 2, thePlayer)
		setTimer(triggerServerEvent, 100, 1, "onPlayerStopAnimation", thePlayer, true )
		return setanim
	else
		return false
	end
end