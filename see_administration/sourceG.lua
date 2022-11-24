local adminTitles = {
	[1] = "Admin[1]",
	[2] = "Admin[2]",
	[3] = "Admin[3]",
	[4] = "Admin[4]",
	[5] = "Admin[5]",
	[6] = "Főadmin",
	[7] = "SzuperAdmin",
	[8] = "Scripter",
	[9] = "Project Manager",
	[10] = "Server Project Owner",
	[11] = "Fejlesztő"
}

local levelColors = {
	[1] = "#3d7abc",
	[2] = "#3d7abc",
	[3] = "#3d7abc",
	[4] = "#3d7abc",
	[5] = "#3d7abc",
	[6] = "#dfb551",
	[7] = "#d93617",
	[8] = "#32b3ef",
	[9] = "#d75959",
	[10] = "#3d7abc",
	[11] = "#32b3ef"
}

function getPlayerAdminTitle(player)
	return adminTitles[getPlayerAdminLevel(player)] or false
end

function getAdminLevelColor(adminLevel)
	return levelColors[tonumber(adminLevel)] or "#3d7abc"
end

function getPlayerAdminLevel(player)
	return isElement(player) and tonumber(getElementData(player, "acc.adminLevel")) or 0
end

function getPlayerAdminNick(player)
	return isElement(player) and getElementData(player, "acc.adminNick")
end