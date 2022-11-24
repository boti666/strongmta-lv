local lockCode = "HAUSGd8g1hjasgdAZJSbtddcx76F67RDA%/SEDASoidjAKLSjDKLAJsdNJXKY"
local lockString = 655

local fileType = ".dff"

function lockFile(path, key, fileName)
	local file = fileOpen(path)
	local size = fileGetSize(file)
	local FirstPart = fileRead(file, lockString)
	fileSetPos(file, lockString)
	local SecondPart = fileRead(file, size-lockString)
	fileClose(file)
	file = fileCreate(utf8.gsub("mods/" .. fileName, fileType, "")..".see")
	fileWrite(file, encodeString("tea", FirstPart, { key = key })..SecondPart)
	fileClose(file)
    outputDebugString("[encode]: 'mods/" .. fileName .. ".see' created.")
	return true
end

addCommandHandler("encodeskin",
	function (player, cmd, ...)
		if getElementData(player, "acc.adminLevel") >= 9 then
			local names = {...}

			if string.len(#names) > 0 then
				for k, v in pairs(names) do
                    local data = ""

					if fileExists("mods/serverFiles/" .. v .. ".dff") then
						lockFile("mods/serverFiles/" .. v .. ".dff", lockCode, v)
					end
				
				end
			else
				outputChatBox("#ff4646>> Használat: #ffffff/" .. cmd .. " [modell nevek, szóközzel elválasztva ha egyszerre többet akarsz]", player, 255, 255, 255, true)
			end
		end
	end
)