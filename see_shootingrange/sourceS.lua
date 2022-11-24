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

addEvent("startWeaponTraining", true)
addEventHandler("startWeaponTraining", getRootElement(),
	function (weaponId, dimension)
		if isElement(source) then
			setElementInterior(source, 0)
			setElementDimension(source, dimension)
			triggerClientEvent(source, "startWeaponTraining", source, weaponId, dimension)
		end
	end
)

addEvent("warpPlayerTraining", true)
addEventHandler("warpPlayerTraining", getRootElement(),
	function (interior, dimension)
		if isElement(source) then
			setElementInterior(source, interior)
			setElementDimension(source, dimension)
		end
	end
)

addEvent("setWeaponStat", true)
addEventHandler("setWeaponStat", getRootElement(),
	function (stat, level)
		if isElement(source) then
			local characterId = getElementData(source, "char.ID")

			if characterId then
				local skillTable = {}

				setPedStat(source, stat, level)

				for i = 69, 79 do
					table.insert(skillTable, getPedStat(source, i))
				end

				skillTable = table.concat(skillTable, ",")

				if skillTable then
					dbExec(connection, "UPDATE characters SET weaponSkills = ? WHERE characterId = ?", skillTable, characterId)
				end
			end
		end
	end
)