currentStamina = 100

local jumped = false
local canMove = true

local adminDuty = 0
local drugStaminaOff = false
local glueState = false

local increase = 0.0075
local decrease = 0.00375

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function()
		adminDuty = getElementData(localPlayer, "adminDuty") or 0
		drugStaminaOff = getElementData(localPlayer, "drugStaminaOff")
		glueState = getElementData(localPlayer, "playerGlueState")
	end)
	
addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName)
		if dataName == "adminDuty" then
			adminDuty = getElementData(localPlayer, dataName)
		end
		
		if dataName == "drugStaminaOff" then
			drugStaminaOff = getElementData(localPlayer, dataName)
		end
		
		if dataName == "playerGlueState" then
			glueState = getElementData(localPlayer, dataName)
		end
	end)

addEventHandler("onClientPreRender", getRootElement(),
	function (timeSlice)
		if adminDuty ~= 1 then
			local standingBoat = false
			local standingOn = getPedContactElement(localPlayer)

			if standingOn then
				if getElementType(standingOn) == "vehicle" then
					if getVehicleType(standingOn) == "Boat" then
						standingBoat = true
					end
				end
			end

			if getPedTask(localPlayer, "secondary", 0) == "TASK_SIMPLE_FIGHT" then
				currentStamina = currentStamina - 7 * timeSlice / 1000

				if currentStamina <= 0 then
					currentStamina = 0

					if canMove then
						exports.see_controls:toggleControl({"forwards", "backwards", "left", "right", "jump"}, false)
						triggerServerEvent("tiredAnim", localPlayer, true)
						canMove = false
					end
				end
			elseif not doesPedHaveJetPack(localPlayer) then
				local speedx, speedy, speedz = getElementVelocity(localPlayer)
				local actualspeed = (speedx * speedx + speedy * speedy) ^ 0.5

				if speedz >= 0.1 and not jumped and not isPedInVehicle(localPlayer) and not drugStaminaOff and not glueState and not standingBoat then
					jumped = true
					currentStamina = currentStamina - 6.5
					
					if currentStamina <= 0 then
						currentStamina = 0
						
						if canMove then
							exports.see_controls:toggleControl({"forwards", "backwards", "left", "right", "jump"}, false)
							triggerServerEvent("tiredAnim", localPlayer, true)
							canMove = false
						end
					end
				end
				
				if speedz < 0.05 then
					jumped = false
				end
				
				if actualspeed <= 0.05 and not jumped then
					if currentStamina <= 100 then
						if currentStamina > 25 then
							if not canMove then
								exports.see_controls:toggleControl({"forwards", "backwards", "left", "right", "jump"}, true)
								triggerServerEvent("tiredAnim", localPlayer, false)
								canMove = true
							end
							
							currentStamina = currentStamina + increase * timeSlice
						else
							currentStamina = currentStamina + increase * timeSlice * 0.75
						end
					else
						currentStamina = 100
					end
				elseif actualspeed > 0.05 and not isPedInVehicle(localPlayer) and not drugStaminaOff and not glueState and not standingBoat then
					if currentStamina >= 0 then
						currentStamina = currentStamina - decrease * timeSlice
					else
						currentStamina = 0
						
						if canMove then
							exports.see_controls:toggleControl({"forwards", "backwards", "left", "right", "jump"}, false)
							triggerServerEvent("tiredAnim", localPlayer, true)
							canMove = false
						end
					end
				end
			end
		end

		setPedControlState("walk", true)
	end)

render.stamina = function (x, y)
	if not getElementData(localPlayer, "hudStyle") then 
		r, g, b = 255, 255, 255

		if currentStamina < 25 then
			r, g, b = interpolateBetween(255, 255, 255, 215, 89, 89, 1-currentStamina / 25, "Linear")
		end

		dxDrawImage(math.floor(x - resp(16) + respc(7)), math.floor(y - respc(16) + respc(7) - 1), respc(32), respc(32), "files/images/bolt.png", 0, 0, 0, tocolor(r, g, b))
		
		dxDrawSeeBar(x + respc(14 + 7), y, renderData.size.staminaX - respc(14 + 7), respc(12), 2, tocolor(r, g, b, 200), currentStamina, "stamina")
	end
end