local events = {}

local function getKey()
	return exports.see_protect:getKey()
end

_addEvent = addEvent
addEvent = function(n, t, b)
	if not b then -- bögészőé
		events[n] = true
		n = getKey()..n
	end
	_addEvent(n, t)
end

_addEventHandler = addEventHandler
addEventHandler = function(n, s, f, gp, p)
	if events[n] then
		local newName = getKey()..n
		if not localPlayer then
			local func = f
			f = function( ... )
				if client and source then
					if not (source == client or source == resourceRoot) then
						local ac = getResourceFromName("see_anticheat");
						if ac and getResourceState(ac) == "running" then
							exports.see_anticheat:reportTrigger(eventName, client, getResourceName(getThisResource()));
						end
						return false;
					end
				end
				return func ( ... );
			end
		end
		_addEventHandler(newName, s, f, gp, p)
	else
		_addEventHandler(n, s, f, gp, p)
	end
end

_removeEventHandler = removeEventHandler
removeEventHandler = function(n, e, f)
	if events[n] then
		events[n] = nil
		n = getKey()..n
	end
	_removeEventHandler(n, e, f)
end

_triggerEvent = triggerEvent
triggerEvent = function(name, ...)
	_triggerEvent(getKey()..name, ...)
end

if type(triggerServerEvent) == "function" then
	_triggerServerEvent = triggerServerEvent
	function triggerServerEvent(name, ...)
		_triggerServerEvent(getKey()..name, ...)
	end
end

if type(triggerClientEvent) == "function" then
	_triggerClientEvent = triggerClientEvent
	function triggerClientEvent(sendto, name, ...)
		_triggerClientEvent(sendto, getKey()..name, ...)
	end
end