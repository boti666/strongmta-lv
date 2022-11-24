--[[

	CREATE TABLE `log_economy` (
		`logId` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		`characterId` INT(11) NOT NULL,
		`economyType` VARCHAR(1024) NOT NULL,
		`managedAmount` INT(11) NOT NULL
	);

	CREATE TABLE `log_vehicle` (
		`logId` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		`vehicleId` INT(11) NOT NULL,
		`characterId` INT(11) NOT NULL,
		`accountId` INT(11) NOT NULL,
		`command` VARCHAR(256) NOT NULL,
		`arguments` VARCHAR(512) NOT NULL
	);

	CREATE TABLE `log_command` (
		`logId` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		`characterId` INT(11) NOT NULL,
		`accountId` INT(11) NOT NULL,
		`mtaSerial` VARCHAR(32) NOT NULL,
		`ipAddress` VARCHAR(128) NOT NULL,
		`command` VARCHAR(256) NOT NULL,
		`arguments` VARCHAR(512) NOT NULL
	);

	CREATE TABLE `log_premiumshop` (
		`logId` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		`accountId` INT(11) NOT NULL,
		`characterId` INT(11) NOT NULL,
		`itemId` VARCHAR(32) NOT NULL,
		`amount` INT(11) NOT NULL,
		`oldPP` INT(11) NOT NULL,
		`newPP` INT(11) NOT NULL
	);

	CREATE TABLE `log_adminjail` (
		`logId` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
		`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
		`accountId` INT(11) NOT NULL,
		`adminName` VARCHAR(256) NOT NULL,
		`reason` TEXT NOT NULL,
		`duration` INT(11) NOT NULL DEFAULT '0'
	);

]]

local connection = false

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = exports.see_database:getConnection()
	end
)

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end
)

function addLogEntry(logType, datas)
	if logType and datas and type(datas) == "table" then
		local columns = {}
		local values = {}
		local params = {}

		for k, v in pairs(datas) do
			table.insert(columns, k)
			table.insert(values, "?")
			table.insert(params, v)
		end

		dbExec(connection, "INSERT INTO `??` (" .. table.concat(columns, ",") .. ") VALUES (" .. table.concat(values, ",") .. ")", "log_" .. logType, unpack(params))
	end
end

function logEconomy(thePlayer, typ, amount)
	addLogEntry("economy", {
		characterId = getElementData(thePlayer, "char.ID"),
		economyType = typ,
		managedAmount = amount
	})
end

function logCommand(thePlayer, commandName, arguments)
	addLogEntry("command", {
		characterId = getElementData(thePlayer, "char.ID"),
		accountId = getElementData(thePlayer, "char.accID"),
		mtaSerial = getPlayerSerial(thePlayer),
		ipAddress = getPlayerIP(thePlayer),
		command = commandName,
		arguments = table.concat(arguments, " | ")
	})
end

function logVehicle(thePlayer, theVehicle, commandName, arguments)
	local vehicleId = getElementData(theVehicle, "vehicle.dbID")

	if vehicleId then
		addLogEntry("vehicle", {
			vehicleId = vehicleId,
			characterId = getElementData(thePlayer, "char.ID"),
			accountId = getElementData(thePlayer, "char.accID"),
			command = commandName,
			arguments = table.concat(arguments, " | ")
		})
	end
end