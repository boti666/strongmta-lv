local lockCode = ".'7<dCbQ2h`Q6*V$dA%];wr(9MER)Yk>ck%9{/a,3/U]n{)jsau#z*-)q{@}2!g88nA'/tv5Lze@XQ"
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

addCommandHandler("encodemodels",
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