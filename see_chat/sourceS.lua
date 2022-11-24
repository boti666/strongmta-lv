function formatNumber(amount, stepper)
	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end
connection = false

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()
	end)

addEvent("onOOCMessage", true)
addEventHandler("onOOCMessage", getRootElement(),
	function (nearby, visibleName, msg)
		if isElement(source) and client and client == source then
			local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}
			local spectaters = {}

			if spectatingPlayers then
				for k, v in pairs(spectatingPlayers) do
					if isElement(k) then
						table.insert(spectaters, k)
					end
				end
			end

			triggerClientEvent(nearby, "onClientRecieveOOCMessage", source, msg, visibleName)

			if #spectaters > 0 then
				triggerClientEvent(spectaters, "onClientRecieveOOCMessage", source, msg, visibleName, true)
			end
		end
	end)

function sendLocalSay(ped, msg)
	if isElement(ped) then
		if utfLen(msg) == 0 then
			return
		end

		local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}

		local visibleName = getElementData(ped, "visibleName"):gsub("_", " ")
		local affected = {}
		local pedveh = getPedOccupiedVehicle(ped)
		local str = ""

		if pedveh and getElementData(pedveh, "vehicle.windowState") and not getVehicleType(pedveh) == "Automobile" then
			str = str .. " (járműben)"

			for k, v in pairs(getVehicleOccupants(pedveh)) do
				if getElementData(v, "loggedIn") then
					table.insert(affected, {v, "#FFFFFF"})
				end
			end

			if spectatingPlayers then
				for k, v in pairs(spectatingPlayers) do
					if isElement(k) then
						outputChatBox("[>o<] " .. visibleName .. " mondja" .. str .. ": " .. msg, k, 231, 217, 176, true)
					end
				end
			end
		else
			local px, py, pz = getElementPosition(ped)

			for k, v in ipairs(getElementsByType("player")) do
				if getElementData(v, "loggedIn") then
					local maxdist = 12
					local pedveh = getPedOccupiedVehicle(v)

					if pedveh then
						if getElementData(pedveh, "vehicle.windowState") then
							maxdist = 8
						end
					end

					local tx, ty, tz = getElementPosition(v)
					local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

					if dist <= maxdist then
						table.insert(affected, {v, RGBToHex(interpolateBetween(255, 255, 255, 50, 50, 50, dist / maxdist, "Linear"))})
					end
				end
			end
		end

		if #affected > 0 then
			msg = firstToUpper(msg)

			for i = 1, #affected do
				local dat = affected[i]

				if isElement(dat[1]) then
					outputChatBox(dat[2] .. visibleName .. " mondja" .. str .. ": " .. msg, dat[1], 231, 217, 176, true)
				end
			end
		end
	
		if spectatingPlayers then
			for k, v in pairs(spectatingPlayers) do
				if isElement(k) then
					outputChatBox("[>o<] " .. visibleName .. " mondja" .. str .. ": " .. msg, k, 231, 217, 176, true)
				end
			end
		end
	end
end

function sendLocalSayInPhone(ped, msg)
	if isElement(ped) then
		if utfLen(msg) == 0 then
			return
		end

		local visibleName = getElementData(ped, "visibleName"):gsub("_", " ")
		local affected = {}
		local pedveh = getPedOccupiedVehicle(ped)
		local str = " (telefonba)"

		if pedveh and getElementData(pedveh, "vehicle.windowState") then
			str = " (járműben, telefonba)"

			for k, v in pairs(getVehicleOccupants(pedveh)) do
				if getElementData(v, "loggedIn") then
					table.insert(affected, {v, "#FFFFFF"})
				end
			end
		else
			local px, py, pz = getElementPosition(ped)

			for k, v in ipairs(getElementsByType("player")) do
				if getElementData(v, "loggedIn") then
					local maxdist = 12
					local pedveh = getPedOccupiedVehicle(v)

					if pedveh then
						if getElementData(pedveh, "vehicle.windowState") then
							maxdist = 8
						end
					end

					local tx, ty, tz = getElementPosition(v)
					local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

					if dist <= maxdist then
						table.insert(affected, {v, RGBToHex(interpolateBetween(255, 255, 255, 50, 50, 50, dist / maxdist, "Linear"))})
					end
				end
			end
		end

		if #affected > 0 then
			msg = firstToUpper(msg)

			for i = 1, #affected do
				local dat = affected[i]

				if isElement(dat[1]) then
					outputChatBox(dat[2] .. visibleName .. " mondja" .. str .. ": " .. msg, dat[1], 231, 217, 176, true)
				end
			end
		end
	end
end

function localAction(ped, msg)
	if isElement(ped) then
		if utfLen(msg) == 0 then
			return
		end

		local px, py, pz = getElementPosition(ped)
		local visibleName = getElementData(ped, "visibleName"):gsub("_", " ")
		local affected = {}

		for k, v in ipairs(getElementsByType("player")) do
			if getElementData(v, "loggedIn") then
				local tx, ty, tz = getElementPosition(v)

				if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 12 then
					table.insert(affected, v)
				end
			end
		end

		if #affected > 0 then
			for i = 1, #affected do
				outputChatBox("#C2A2DA*** " .. visibleName .. " #C2A2DA" .. msg, affected[i], 194, 162, 218, true)
			end
		end
	end
end

function sendLocalDo(ped, msg)
	if isElement(ped) and client and client == ped then
		if utfLen(msg) == 0 then
			return
		end

		local px, py, pz = getElementPosition(ped)
		local visibleName = getElementData(ped, "visibleName"):gsub("_", " ")
		local affected = {}

		for k, v in ipairs(getElementsByType("player")) do
			if getElementData(v, "loggedIn") then
				local tx, ty, tz = getElementPosition(v)

				if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 12 then
					table.insert(affected, v)
				end
			end
		end

		if #affected > 0 then
			msg = firstToUpper(msg)

			for i = 1, #affected do
				outputChatBox(" *" .. msg .. " ((#FF2850" .. visibleName .. "))", affected[i], 255, 40, 80, true)
			end
		end
	end
end

addEvent("onDoMessage", true)
addEventHandler("onDoMessage", getRootElement(),
	function (nearby, visibleName, msg)
		if isElement(source) and client and client == source then
			for k, v in ipairs(nearby) do
				if isElement(v) then
					outputChatBox(" *" .. msg .. " ((#FF2850" .. visibleName .. "))", v, 255, 40, 80, true)
				end
			end

			local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}
	
			if spectatingPlayers then
				for k, v in pairs(spectatingPlayers) do
					if isElement(k) then
						outputChatBox("[>o<] *" .. msg .. " ((#FF2850" .. visibleName .. "))", k, 255, 40, 80, true)
					end
				end
			end
		end
	end)

addEvent("onDoMessageLow", true)
addEventHandler("onDoMessageLow", getRootElement(),
	function (nearby, visibleName, msg)
		if isElement(source) and client and client == source then
			for k, v in ipairs(nearby) do
				if isElement(v) then
					outputChatBox("[LOW] *" .. msg .. " ((#ff6682" .. visibleName .. "))", v, 255, 102, 130, true)
				end
			end

			local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}
	
			if spectatingPlayers then
				for k, v in pairs(spectatingPlayers) do
					if isElement(k) then
						outputChatBox("[>o<] [LOW] *" .. msg .. " ((#ff6682" .. visibleName .. "))", k, 255, 102, 130, true)
					end
				end
			end
		end
	end)

addEvent("onActionMessageLow", true)
addEventHandler("onActionMessageLow", getRootElement(),
	function (nearby, visibleName, msg)
		if isElement(source) and client and client == source then
			for k, v in ipairs(nearby) do
				if isElement(v) then
					outputChatBox("#DBC5EB*** [LOW] " .. visibleName .. " #DBC5EB" .. msg, v, 219, 197, 235, true)
				end
			end

			local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}
	
			if spectatingPlayers then
				for k, v in pairs(spectatingPlayers) do
					if isElement(k) then
						outputChatBox("#DBC5EB[>o<] *** [LOW] " .. visibleName .. " #DBC5EB" .. msg, k, 219, 197, 235, true)
					end
				end
			end
		end
	end)

addEvent("onActionMessageA", true)
addEventHandler("onActionMessageA", getRootElement(),
	function (nearby, visibleName, msg)
		if isElement(source) and client and client == source then
			for k, v in ipairs(nearby) do
				if isElement(v) then
					outputChatBox("#956CB4>> " .. visibleName .. " #956CB4" .. msg, v, 194, 162, 218, true)
				end
			end

			local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}
	
			if spectatingPlayers then
				for k, v in pairs(spectatingPlayers) do
					if isElement(k) then
						outputChatBox("#956CB4[>o<] >> " .. visibleName .. " #956CB4" .. msg, k, 194, 162, 218, true)
					end
				end
			end
		end
	end)

addEvent("onActionMessage", true)
addEventHandler("onActionMessage", getRootElement(),
	function (nearby, visibleName, msg)
		if isElement(source) and client and client == source then
			for k, v in ipairs(nearby) do
				if isElement(v) then
					outputChatBox("#C2A2DA*** " .. visibleName .. " #C2A2DA" .. msg, v, 194, 162, 218, true)
				end
			end

			local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}
	
			if spectatingPlayers then
				for k, v in pairs(spectatingPlayers) do
					if isElement(k) then
						outputChatBox("#C2A2DA[>o<] *** " .. visibleName .. " #C2A2DA" .. msg, k, 194, 162, 218, true)
					end
				end
			end
		end
	end)

addEvent("onLocalMessage", true)
addEventHandler("onLocalMessage", getRootElement(),
	function (nearby, visibleName, msg, str, adminDuty, adminTitle, levelColor, ped)
		if isElement(source) and client and client == source then
			for k, v in ipairs(nearby) do
				if isElement(v[1]) then
					if adminDuty ~= 1 then
						outputChatBox(v[2] .. visibleName .. " mondja" .. str .. ": " .. msg, v[1], 231, 217, 176, true)
					else
						outputChatBox(levelColor .. "[ADMIN] " .. adminTitle .. " " .. visibleName .. " mondja" .. str .. ": " .. msg, v[1], 231, 217, 176, true)
					end
				end
			end

			local talkingAnim = getElementData(ped, "talkingAnim") or "false"

			if talkingAnim ~= "false" then
				setPedAnimation(ped, "GANGS", talkingAnim, #msg * 150, true, true, false, false)
				--triggerServerEvent("sayAnimServer", getRootElement(), ped, msg, talkingAnim)
			end

			local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}
	
			if spectatingPlayers then
				for k, v in pairs(spectatingPlayers) do
					--if isElement(k) then
						--print("ide futok")
						if adminDuty ~= 1 then
							--print("idaig futok")
							outputChatBox("[>o<] " .. visibleName .. " mondja" .. str .. ": " .. msg, k, 255, 255, 255, true)
						else
							outputChatBox(levelColor .. "[>o<] [ADMIN] " .. adminTitle .. " " .. visibleName .. " mondja" .. str .. ": " .. msg, k, 231, 217, 176, true)
						end
					--end
				end
			end
		end
	end)

addEvent("laughAnim", true)
addEventHandler("laughAnim", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			setPedAnimation(source, "rapping", "laugh_01", -1, false, false, false, false, 250, true)
		end
	end)

addEvent("sayAnimServer", true)
addEventHandler("sayAnimServer", getRootElement(),
	function(player, message, anim)
		if isElement(player) and client and client == player then
			setPedAnimation(player, "GANGS", anim, #message * 150, true, true, false, false)
			--print("asd")
		end
	end
)

addEventHandler("onPlayerCommand", getRootElement(),
	function (commandName)
		if commandName == "say" or commandName == "me" then
			cancelEvent()
		end
	end)

function firstToUpper(text)
	return (text:gsub("^%l", string.upper))
end

function RGBToHex(r, g, b)
	return string.format("#%.2X%.2X%.2X", r, g, b)
end

addEvent("onMegaPhoneMessage", true)
addEventHandler("onMegaPhoneMessage", getRootElement(),
	function (nearby, visibleName, msg)
		if isElement(source) and client and client == source then
			for k, v in ipairs(nearby) do
				if isElement(v[1]) then
					outputChatBox("((" .. visibleName .. ")) Megaphone <O: " .. msg, v[1], 255 * v[2], 255 * v[2], 0 * v[2], true)
				end
			end

			local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}
	
			if spectatingPlayers then
				for k, v in pairs(spectatingPlayers) do
					if isElement(k) then
						outputChatBox("[>o<] ((" .. visibleName .. ")) Megaphone <O: " .. msg, k, 255, 255, 0, true)
					end
				end
			end
		end
	end)

addEvent("onTryMessage", true)
addEventHandler("onTryMessage", getRootElement(),
	function (nearby, visibleName, msg, rnd, commandName)
		if isElement(source) and client and client == source then
			for k, v in ipairs(nearby) do
				if isElement(v) then
					if commandName == "megprobal" or commandName == "megpróbál" then
						if rnd == 1 then
							outputChatBox(" *** " .. visibleName .. " megpróbál " .. msg .. " és sikerül neki.", v, 173, 211, 115, true)
						elseif rnd == 2 then
							outputChatBox(" *** " .. visibleName .. " megpróbál " .. msg .. " de sajnos nem sikerül neki.", v, 220, 20, 60, true)
						end
					elseif commandName == "megprobalja" or commandName == "megpróbálja" then
						if rnd == 1 then
							outputChatBox(" *** " .. visibleName .. " megpróbálja " .. msg .. " és sikerül neki.", v, 173, 211, 115, true)
						elseif rnd == 2 then
							outputChatBox(" *** " .. visibleName .. " megpróbálja " .. msg .. " de sajnos nem sikerül neki.", v, 220, 20, 60, true)
						end
					end
				end
			end

			local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}
	
			if spectatingPlayers then
				for k, v in pairs(spectatingPlayers) do
					if isElement(k) then
						if commandName == "megprobal" or commandName == "megpróbál" then
							if rnd == 1 then
								outputChatBox("[>o<] *** " .. visibleName .. " megpróbál " .. msg .. " és sikerül neki.", v, 173, 211, 115, true)
							elseif rnd == 2 then
								outputChatBox("[>o<] *** " .. visibleName .. " megpróbál " .. msg .. " de sajnos nem sikerül neki.", v, 220, 20, 60, true)
							end
						elseif commandName == "megprobalja" or commandName == "megpróbálja" then
							if rnd == 1 then
								outputChatBox("[>o<] *** " .. visibleName .. " megpróbálja " .. msg .. " és sikerül neki.", k, 173, 211, 115, true)
							elseif rnd == 2 then
								outputChatBox("[>o<] *** " .. visibleName .. " megpróbálja " .. msg .. " de sajnos nem sikerül neki.", k, 220, 20, 60, true)
							end
						end
					end
				end
			end
		end
	end)

addEvent("shoutNormal", true)
addEventHandler("shoutNormal", getRootElement(),
	function (msg)
		if isElement(source) and client and client == source then
			local visibleName = getElementData(source, "visibleName"):gsub("_", " ")
			local affected = {}
			local pedveh = getPedOccupiedVehicle(source)
			local str = ""
			maxdist = 12

			if pedveh then
				local px, py, pz = getElementPosition(source)

				for k, v in ipairs(getElementsByType("player")) do
					if getElementData(v, "loggedIn") then
						local maxdist = 20
						local pedveh = getPedOccupiedVehicle(v)

						if pedveh then
							--if getElementData(pedveh, "vehicle.windowState") then
								maxdist = 12
							--end
						end

						local tx, ty, tz = getElementPosition(v)
						local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

						if dist <= maxdist then
							table.insert(affected, {v, RGBToHex(interpolateBetween(255, 255, 255, 50, 50, 50, dist / maxdist, "Linear"))})
						end
					end
				end
			else
				for k, v in ipairs(getElementsByType("player")) do
					if getElementData(v, "loggedIn") then
						local maxdist = 20
						local px, py, pz = getElementPosition(source)
						local tx, ty, tz = getElementPosition(v)
						local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

						if dist <= maxdist then
							table.insert(affected, {v, RGBToHex(interpolateBetween(255, 255, 255, 50, 50, 50, dist / maxdist, "Linear"))})
						end
					end
				end
			end

			local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}
	
			if spectatingPlayers then
				for k, v in pairs(spectatingPlayers) do
					if isElement(v) then
						table.insert(affected, {v, "#FFFFFF", true})
					end
				end
			end

			if #affected > 0 then
				msg = firstToUpper(msg)

				for i = 1, #affected do
					local dat = affected[i]

					if isElement(dat[1]) then
						if dat[3] then
							outputChatBox("[>o<] " .. dat[2] .. visibleName .. " ordítja" .. str .. ": " .. msg, dat[1], 231, 217, 176, true)
						else
							outputChatBox(dat[2] .. visibleName .. " ordítja" .. str .. ": " .. msg, dat[1], 231, 217, 176, true)
						end
					end
				end
			end

			setPedAnimation(source, "RIOT", "RIOT_shout", -1, false, false, false, false, 250, true)
		end
	end
)

addEvent("shoutInterior", true)
addEventHandler("shoutInterior", getRootElement(),
	function (currentStandingInterior, msg, intX, intY, intZ)
		if isElement(source) and client and client == source then
			local px, py, pz = getElementPosition(source)
			local visibleName = getElementData(source, "visibleName"):gsub("_", " ")
			local affected = {}

			for k, v in ipairs(getElementsByType("player")) do
				if getElementData(v, "loggedIn") then
					if getElementDimension(v) == currentStandingInterior[1] then
						local tx, ty, tz = getElementPosition(v)
						local dist = getDistanceBetweenPoints3D(intX, intY, intZ, tx, ty, tz)

						if dist <= 20 then
							table.insert(affected, {v, RGBToHex(interpolateBetween(255, 255, 255, 50, 50, 50, dist / 20, "Linear")), false, true})
						end
					else
						local tx, ty, tz = getElementPosition(v)
						local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

						if dist <= 20 then
							table.insert(affected, {v, RGBToHex(interpolateBetween(255, 255, 255, 50, 50, 50, dist / 20, "Linear"))})
						end
					end
				end
			end

			local spectatingPlayers = getElementData(source, "spectatingPlayers") or {}
	
			if spectatingPlayers then
				for k, v in pairs(spectatingPlayers) do
					if isElement(k) then
						table.insert(affected, {k, "#FFFFFF", true})
					end
				end
			end

			if #affected > 0 then
				msg = firstToUpper(msg)

				for i = 1, #affected do
					local dat = affected[i]

					if isElement(dat[1]) then
						if dat[3] then
							outputChatBox("[>o<] " .. dat[2] .. visibleName .. " ordítja: " .. msg, dat[1], 231, 217, 176, true)
						else
							--iprint(dat)
							if dat[4] then
								outputChatBox(dat[2] .. visibleName .. " ordítja ((kívülről)): " .. msg, dat[1], 231, 217, 176, true)
							else
								outputChatBox(dat[2] .. visibleName .. " ordítja: " .. msg, dat[1], 231, 217, 176, true)
							end
						end
					end
				end
			end

			setPedAnimation(source, "RIOT", "RIOT_shout", -1, false, false, false, false, 250, true)
		end
	end)
