local controlTable = {
	"fire", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right", "zoom_in", "zoom_out",
	"change_camera", "jump", "sprint", "look_behind", "crouch", "action", "walk", "aim_weapon",
	"enter_exit", "vehicle_fire", "vehicle_secondary_fire", "vehicle_left", "vehicle_right",
	"steer_forward", "steer_back", "accelerate", "brake_reverse", "radio_next", "radio_previous", "radio_user_track_skip", "horn",
	"handbrake", "vehicle_look_left", "vehicle_look_right", "vehicle_look_behind", "vehicle_mouse_look", "special_control_left", "special_control_right",
	"special_control_down", "special_control_up", "enter_passenger"
}
local controlStates = {}
local controlCounters = {}
local controllerResources = {}
local _toggleControl = toggleControl

_toggleControl("radar", false)

addEventHandler("onClientResourceStop", getRootElement(),
	function (stoppedres)
		local resourceName = getResourceName(stoppedres)

		if controllerResources[resourceName] then
			controllerResources[resourceName] = nil
			toggleControl("all", true, true, resourceName)
		end
	end
)

addEventHandler("onClientKey", getRootElement(),
	function (key)
		if controlCounters[key] then
			if controlCounters[key] > 0 then
				_toggleControl(key, false)
				controlStates[key] = true
			elseif controlStates[key] then
				_toggleControl(key, true)
				controlStates[key] = false
			end
		end
	end, true, "high+9999999"
)

addEvent("toggleControl", true)
addEventHandler("toggleControl", localPlayer,
	function (control, enabled, resourceName)
		toggleControl(control, enabled, false, resourceName)
	end
)

function toggleControl(control, enabled, important, resourceName)
	if control then
		if sourceResource then
			resourceName = getResourceName(sourceResource)
		end

		if control == "all" or control[1] == "all" then
			for i = 1, #controlTable do
				local v = controlTable[i]

				if v then
					if not controlCounters[v] then
						controlCounters[v] = 0
					end
					
					if important then
						controlCounters[v] = 0
					elseif not enabled then
						controlCounters[v] = controlCounters[v] + 1
					elseif controlCounters[v] - 1 >= 0 then
						controlCounters[v] = controlCounters[v] - 1
					else
						controlCounters[v] = 0
					end
					
					if controlCounters[v] > 0 then
						setPedControlState(v, false)
						_toggleControl(v, false)
						controlStates[v] = true
						controllerResources[resourceName] = true
					elseif controlStates[v] then
						_toggleControl(v, true)
						controlStates[v] = false
						controllerResources[resourceName] = nil
					end
				end
			end
		else
			for i = 1, #control do
				local v = control[i]

				if v then
					if not controlCounters[v] then
						controlCounters[v] = 0
					end

					if not enabled then
						controlCounters[v] = controlCounters[v] + 1
					elseif controlCounters[v] - 1 >= 0 then
						controlCounters[v] = controlCounters[v] - 1
					else
						controlCounters[v] = 0
					end
					
					if controlCounters[v] > 0 then
						setPedControlState(v, false)
						_toggleControl(v, false)
						controlStates[v] = true
						controllerResources[resourceName] = true
					elseif controlStates[v] then
						_toggleControl(v, true)
						controlStates[v] = false
						controllerResources[resourceName] = nil
					end
				end
			end
		end
	end
end