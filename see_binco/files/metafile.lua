function get_script_path()
	local info = debug.getinfo(1, "S")
	local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
	return script_path
end

local dir = get_script_path() .. "/skins"
local files = {}

for file in io.popen('dir "' .. dir .. '" /b'):lines() do
	table.insert(files, file)
end

local sorted = {}

for i = 1, #files do
	local skinId = files[i]:gsub(".png", "")
	table.insert(sorted, tonumber(skinId))
end

table.sort(sorted, function(a, b)
	return a < b
end)

for i = 1, #sorted do
	print("<file src=\"files/skins/" .. sorted[i] .. ".png\" />")
end