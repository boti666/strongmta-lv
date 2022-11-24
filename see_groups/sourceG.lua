groupTypes = {
	law_enforcement = "Rendvédelem",
	government = "Önkormányzat",
	mafia = "Maffia",
	gang = "Banda",
	organisation = "Szervezet",
	other = "Egyéb"
}

availableGroups = {
	[1] = {
		name = "Las Venturas Metropolitan Police Department",
		prefix = "LVMPD",
		type = "law_enforcement",
		permissions = {
			tazer = true,
			stinger = true,
			bulletExamine = true,
			impoundTow = true,
			impoundTowFinal = true,
			megaPhone = true,
			roadBlock = true,
			cuff = true,
			graffitiClean = true,
			gov = true,
			ticket = true,
			departmentRadio = true,
			jail = true,
			doorRammer = true
		},
		duty = {
			skins = {280, 281, 282, 283, 284, 71, 288, 70},
			positions = {
				{2266.06616, 2470.50146, 19995.85938, 0, 0}
			},
			armor = 100,
			items = {
				{78, 1},
				{109, 100},
				{118, 1},
				{155, 1},
				{79, 1},
				{114, 100},
				{314, 1, "pd"},
				{112, 250},
				{113, 250},

			}
		}
	},
	[2] = {
		name = "Las Venturas Medical Services",
		prefix = "LVMS",
		type = "other",
		permissions = {
			megaPhone = true,
			tazer = true,
			ticket = true,
			heal = true,
			departmentRadio = true,
			gov = true
		},
		duty = {
			skins = {10, 274, 275, 276},
			positions = {
				{43.267234802246, 2064.7727050781, 51.0859375, 1, 1902},
			},
			armor = 0,
			items = {
				{153, 10},
				{371, 1},
				{364, 1},
				{372, 1}
			}
		}
	},
	[3] = {
		name = "Zemmour Famille",
		prefix = "ZF",
		type = "organisation",
		permissions = {
			sprayGraffiti = true,
			canRobATM = true,
			weaponCraft = true,
			weaponCraft2 = true
		},
		duty = {
			skins = {},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[4] = {
		name = "Slovenska Združba",
		prefix = "SZ",
		type = "mafia",
		permissions = {
			hideWeapons = true,
			sprayGraffiti = true,
			canRobATM = true,
			weaponCraft = true,
			weaponCraft2 = true
		},
		duty = {
			skins = {221, 253, 255, 262, 263, 222, 223},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[6] = {
		name = "Mexican Connection",
		prefix = "MC",
		type = "organisation",
		permissions = {
			sprayGraffiti = true,
			canRobATM = true,
			weaponCraft = true,
			weaponCraft2 = true
		},
		duty = {
			skins = {233, 234, 235, 238, 239}, -- 236
			positions = {},
			armor = 0,
			items = false
		}
	},
	[9] = {
		name = "OutLaw Gangster Disciples",
		prefix = "OGD",
		type = "gang",
		permissions = {
			sprayGraffiti = true,
			canRobATM = true,
			weaponCraft = true,
			weaponCraft2 = true
		},
		duty = {
			skins = {},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[10] = {
		name = "Albanian Criminal Organization",
		prefix = "ACO",
		type = "organisation",
		permissions = {
			sprayGraffiti = true,
			canRobATM = true,
			weaponCraft = true,
			weaponCraft2 = true
		},
		duty = {
			skins = {},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[11] = {
		name = "StrongCity Used Car Dealership",
		prefix = "SCUCD",
		type = "other",
		permissions = {
			gov = true,
		},
		duty = {
			skins = {},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[12] = {
		name = "Federal Bureau of Investigation",
		prefix = "FBI",
		type = "law_enforcement",
		permissions = {
			tazer = true,
			trackPhone = true,
			bulletExamine = true,
			impoundTow = true,
			impoundTowFinal = true,
			megaPhone = true,
			roadBlock = true,
			graffitiClean = true,
			cuff = true,
			gov = true,
			ticket = true,
			departmentRadio = true,
			jail = true,
			hiddenName = true,
			doorRammer = true
		},
		duty = {
			skins = {126, 163, 164, 186, 244, 286},
			positions = {
				{2470.3674316406, 2361.5441894531, 19998.5625, 0, 0}
			},
			armor = 100,
			items = {
				{78, 1},
				{109, 100},
				{118, 1},
				{155, 1},
				{99, 1},
				{314, 1, "nni"},
				{291, 1},
				{83, 1},
				{112, 300},
				{109, 250}
			}
		}
	},
	[13] = {
		name = "San Andreas Sheriff's Department",
		prefix = "SASD",
		type = "law_enforcement",
		permissions = {
			tazer = true,
			megaPhone = true,
			bulletExamine = true,
			impoundTow = true,
			impoundTowFinal = true,
			roadBlock = true,
			graffitiClean = true,
			cuff = true,
			gov = true,	
			ticket = true,
			departmentRadio = true,
			jail = true,
			doorRammer = true
		},
		duty = {
			skins = {265, 266, 267, 277, 278},
			positions = {
				--{-215.4169921875, 966.490234375, 19998.562, 0, 0},
				--{254.28349304199, 77.511001586914, 1003.640625, 0, 0}
				{68.454490661621, 2044.72265625, 51.0859375, 1, 1526}
			},
			armor = 100,
			items = {
				{79, 1},
				{114, 50},
				{78, 1},
				{109, 100},
				{69, 1},
				{118, 1},
				{155, 1},
				{314, 1, "nav"}
			}
		}
	},
	[14] = {
		name = "Brother Till That",
		prefix = "BTD",
		type = "gang",
		permissions = {
			sprayGraffiti = true,
			canRobATM = true,
			weaponCraft = true,
			weaponCraft2 = true
		},
		duty = {
			skins = {},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[15] = {
		name = "Redline Auto Service",
		prefix = "RAS",
		type = "other",
		permissions = {
			repair = true,
			impoundTow = true,
			gov = true
		},
		duty = {
			skins = {
				50,
				305,
				268,
				191
			},
			positions = {
				{1024.1123046875, 1304.01953125, 10.956250190735, 0, 0}
			},
			armor = 0,
			items = false
		}
	},
	[16] = {
		name = "Hungarian Connection",
		prefix = "HC",
		type = "gang",
		permissions = {
			sprayGraffiti = true,
			canRobATM = true,
			weaponCraft = true,
			weaponCraft2 = true
		},
		duty = {
			skins = {121, 122, 123, 125, 128, 130},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[17] = {
		name = "Albanian Boys",
		prefix = "ALB",
		type = "mafia",
		permissions = {
			canRobATM = true,
			weaponCraft = true,
			weaponCraft2 = true
		},
		duty = {
			skins = {114, 115, 116, 118, 146},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[18] = {
		name = "Special Operations Command Central",
		prefix = "US Army",
		type = "law_enforcement",
		permissions = {
			tazer = true,
			stinger = true,
			bulletExamine = true,
			impoundTow = true,
			impoundTowFinal = true,
			megaPhone = true,
			roadBlock = true,
			cuff = true,
			graffitiClean = true,
			gov = true,
			ticket = true,
			departmentRadio = true,
			jail = true,
			doorRammer = true
		},
		duty = {
			skins = {132, 133, 136, 142, 143, 150, 151, 152, 153, 156, 301, 302, 304, 166, 167, 168, 169, 172, 173},
			positions = {
				{258.50115966797, -41.69652557373, 1002.0234375, 14, 1911}
			},
			armor = 100,
			items = {
				{86, 1},
				{113, 400},
				{78, 1},
				{109, 200},
				{118, 1},
				{155, 1}
			}
		}
	},
	[19] = {
		name = "Graves Auto Service",
		prefix = "GAS",
		type = "other",
		permissions = {
			repair = true,
			impoundTow = true,
			gov = true
		},
		duty = {
			skins = {
				212,
				213,
				215,
				216,
				218,
			},
			positions = {
				{2016.36377, 2049.70947, 11.35537, 0, 0}
			},
			armor = 0,
			items = false
		}
	},
	[20] = {
		name = "Szabad maffia",
		prefix = "empty",
		type = "mafia",
		permissions = {
			canRobATM = true
		},
		duty = {
			skins = {0},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[21] = {
		name = "Szabad rendvédelem",
		prefix = "empty",
		type = "law_enforcement",
		permissions = {
			tazer = true,
			megaPhone = true,
			roadBlock = true,
			graffitiClean = true,
			cuff = true,
			gov = true,
			ticket = true,
			departmentRadio = true,
			jail = true
		},
		duty = {
			skins = {0},
			positions = {
				{264.384765625, 109.328125, 1004.6171875, 10, 1611}
			},
			armor = 100,
			items = {
				{78, 1},
				{109, 100},
				{86, 1},
				{113, 750},
				{88, 1},
				{111, 50},
				{69, 1},
				{118, 1},
				{155, 1},
				{93, 1},
				{314, 1, "army"}
			}
		}
	},
	[22] = {
		name = "Garduna Clan",
		prefix = "empty",
		type = "mafia",
		permissions = {
			canRobATM = true,
			weaponCraft = true,
			weaponCraft2 = true
		},
		duty = {
			skins = {85, 102, 103, 104, 117},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[23] = {
		name = "Almighty Latin King Nation",
		prefix = "ALKN",
		type = "gang",
		permissions = {
			sprayGraffiti = true,
			canRobATM = true
		},
		duty = {
			--skins = {0},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[24] = {
		name = "Las Venturas Taxi",
		prefix = "LVT",
		type = "other",
		permissions = {
			gov = true,
			canAcceptTaxi = true
		},
		duty = {
			skins = {0},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[25] = {
		name = "Cartel De Jalisco Nueva Generación",
		prefix = "cartel",
		type = "mafia",
		permissions = {
			canRobATM = true
		},
		duty = {
			skins = {75, 18, 138, 139},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[26] = {
		name = "Special Weapons And Tactics",
		prefix = "SWAT",
		type = "law_enforcement",
		permissions = {
			tazer = true,
			megaPhone = true,
			roadBlock = true,
			graffitiClean = true,
			cuff = true,
			gov = true,
			ticket = true,
			departmentRadio = true,
			jail = true,
			doorRammer = true
		},
		duty = {
			skins = {279, 285, 287},
			positions = {
				{2268.1899414062, 2470.7602539062, 19995.859375, 0, 0},
				{2472.1669921875, 2361.7946777344, 19998.5625, 0, 0}
			},
			armor = 100,
			items = {
				{78, 1}, -- Desert Eagle
				{109, 200}, -- dezi toli

				{83, 1}, -- p90
				{112, 400}, -- kisgep

				{93, 2}, -- flashbang 2db
				{94, 2}, -- füstgránát 2db

				{118, 1}, -- bilincs
				{155, 1}, -- sokkolo

				{115, 1}, -- faltoro
				{291, 1} -- villogo
			}
		}
	},
	[29] = {
		name = "Berisha De Organization",
		prefix = "BDO",
		type = "mafia",
		permissions = {
			canRobATM = true
		},
		duty = {
			skins = {251, 18, 82, 81, 84},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[30] = {
		name = "Szabad banda",
		prefix = "empty",
		type = "gang",
		permissions = {
			sprayGraffiti = true,
			canRobATM = true
		},
		duty = {
			skins = {0},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[31] = {
		name = "Szabad banda",
		prefix = "empty",
		type = "gang",
		permissions = {
			sprayGraffiti = true,
			canRobATM = true
		},
		duty = {
			skins = {0},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[33] = {
		name = "Parkolási Felügyelet",
		prefix = "PF",
		type = "law_enforcement",
		permissions = {
			impoundTow = true,
			impoundTowFinal = true,
			departmentRadio = true,
			megaPhone = true,
			gov = true
		},
		duty = {
			skins = {0},
			positions = {
				{40.010272979736, 2038.4140625, 51.0859375, 1, 1850},
			},
			armor = 0,
			items = {
				{99, 1}
			}
		}
	},
	[34] = {
		name = "Szabad maffia",
		prefix = "empty",
		type = "mafia",
		permissions = {
			canRobATM = true
		},
		duty = {
			skins = {0},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[35] = {
		name = "Szabad banda",
		prefix = "empty",
		type = "gang",
		permissions = {
			sprayGraffiti = true,
			canRobATM = true
		},
		duty = {
			skins = {0},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[36] = {
		name = "Szabad maffia",
		prefix = "empty",
		type = "mafia",
		permissions = {
			canRobATM = true
		},
		duty = {
			skins = {0},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[37] = {
		name = "Szabad banda",
		prefix = "empty",
		type = "gang",
		permissions = {
			sprayGraffiti = true,
			canRobATM = true
		},
		duty = {
			skins = {0},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[38] = {
		name = "Fly Eliot",
		prefix = "empty",
		type = "other",
		permissions = {
			gov = true
		},
		duty = {
			skins = {0},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[39] = {
		name = "Fierra Car Service",
		prefix = "FCS",
		type = "other",
		permissions = {
			repair = true,
			gov = true,
			impoundTow = true,
		},
		duty = {
			skins = {},
			positions = {},
			armor = 0,
			items = {
				{287, 1}
			}
		}
	},
	[40] = {
		name = "Hitman",
		prefix = "Hitman",
		type = "other",
		permissions = {
			unlockVehicle = true,
			doorRammer = true,
			canRobATM = true
		},
		duty = {
			skins = {0},
			positions = {},
			armor = 0,
			items = false
		}
	},
	[41] = {
		name = "Admin Frakció",
		prefix = "Admin Frakció",
		type = "other",
		permissions = {},
		duty = {
			skins = {0},
			positions = {},
			armor = 0,
			items = false
		}
	}
}

for k, v in pairs(availableGroups) do
	if not availableGroups[k].balance then
		availableGroups[k].balance = 0
	end

	if not availableGroups[k].description then
		availableGroups[k].description = "leírás"
	end

	if not availableGroups[k].ranks then
		availableGroups[k].ranks = {}
	end

	for i = 1, 15 do
		if not availableGroups[k].ranks[i] then
			availableGroups[k].ranks[i] = {
				name = "rang " .. i,
				pay = 0
			}
		end
	end
end

function getGroups()
	return availableGroups
end

function getGroupTypes()
	return groupTypes
end

function getGroupData(groupId)
	return availableGroups[groupId]
end

function addPlayerGroup(playerElement, groupId, dutySkin)
	if isElement(playerElement) then
		groupId = tonumber(groupId)

		if groupId then
			if availableGroups[groupId] then
				local playerGroups = getElementData(playerElement, "player.groups") or {}
				
				if playerGroups then
					if not playerGroups[groupId] then
						if not dutySkin then
							dutySkin = availableGroups[groupId].duty.skins[1]
						end

						playerGroups[groupId] = {1, dutySkin, "N"}
						setElementData(playerElement, "player.groups", playerGroups)

						return true
					end
				end
			end
		end
	end
	
	return false
end

function removePlayerGroup(playerElement, groupId)
	if isElement(playerElement) then
		groupId = tonumber(groupId)

		if groupId then
			if availableGroups[groupId] then
				local playerGroups = getElementData(playerElement, "player.groups") or {}
				
				if playerGroups then
					if playerGroups[groupId] then
						playerGroups[groupId] = nil
						setElementData(playerElement, "player.groups", playerGroups)
						return true
					end
				end
			end
		end
	end
	
	return false
end

function setPlayerLeader(playerElement, groupId, state)
	if isElement(playerElement) then
		groupId = tonumber(groupId)

		if groupId then
			if availableGroups[groupId] then
				local playerGroups = getElementData(playerElement, "player.groups") or {}
				
				if playerGroups then
					if playerGroups[groupId] then
						playerGroups[groupId][3] = state
						setElementData(playerElement, "player.groups", playerGroups)
						return true
					end
				end
			end
		end
	end
	
	return false
end

function isPlayerLeaderInGroup(playerElement, groupId)
	if isElement(playerElement) then
		groupId = tonumber(groupId)

		if groupId then
			if availableGroups[groupId] then
				local playerGroups = getElementData(playerElement, "player.groups") or {}
				
				if playerGroups then
					if playerGroups[groupId] then
						if utf8.lower(playerGroups[groupId][3]) == "y" then
							return true
						end
					end
				end
			end
		end
	end

	return false
end

function isPlayerInGroup(playerElement, groups)
	if isElement(playerElement) then
		if groups then
			if type(groups) == "table" then
				local playerGroups = getElementData(playerElement, "player.groups") or {}

				if playerGroups then
					for i = 1, #groups do
						local groupId = groups[i]

						if availableGroups[groupId] then
							if playerGroups[groupId] then
								return groupId
							end
						end
					end
				end
			else
				local groupId = tonumber(groups)
				
				if availableGroups[groupId] then
					local playerGroups = getElementData(playerElement, "player.groups") or {}
					
					if playerGroups then
						if playerGroups[groupId] then
							return groupId
						end
					end
				end
			end
		end
	end

	return false
end

function getPlayerGroups(playerElement)
	if isElement(playerElement) then
		local playerGroups = getElementData(playerElement, "player.groups") or {}
		
		if playerGroups then
			return playerGroups
		end
	end
	
	return false
end

function getPlayerGroupCount(playerElement)
	if isElement(playerElement) then
		local playerGroups = getElementData(playerElement, "player.groups") or {}
		local groupCounter = 0
		
		for k, v in pairs(playerGroups) do
			groupCounter = groupCounter + 1
		end

		return groupCounter
	end
	
	return false
end

function setPlayerRank(playerElement, groupId, rankId)
	if isElement(playerElement) then
		groupId = tonumber(groupId)
		rankId = tonumber(rankId)

		if groupId and rankId then
			if availableGroups[groupId] then
				local playerGroups = getElementData(playerElement, "player.groups") or {}
				
				if playerGroups then
					if playerGroups[groupId] then
						playerGroups[groupId][1] = rankId
						setElementData(playerElement, "player.groups", playerGroups)
						return true
					end
				end
			end
		end
	end
	
	return false
end

function getPlayerRank(playerElement, groupId)
	if isElement(playerElement) then
		groupId = tonumber(groupId)

		if groupId then
			if availableGroups[groupId] then
				local playerGroups = getElementData(playerElement, "player.groups") or {}

				if playerGroups then
					if playerGroups[groupId] then
						local rankId = playerGroups[groupId][1]

						if rankId then
							if availableGroups[groupId].ranks[rankId] then
								return rankId, availableGroups[groupId].ranks[rankId].name, availableGroups[groupId].ranks[rankId].pay
							end
						end
					end
				end
			end
		end
	end

	return false
end

function getGroupPrefix(groupId)
	if groupId then
		if availableGroups[groupId] then
			return availableGroups[groupId].prefix
		end
	end
	
	return false
end

function getGroupName(groupId)
	if groupId then
		if availableGroups[groupId] then
			return availableGroups[groupId].name
		end
	end
	
	return false
end

function getGroupType(groupId)
	if groupId then
		if availableGroups[groupId] then
			return availableGroups[groupId].type
		end
	end
	
	return false
end

function isPlayerHavePermission(playerElement, permission)
	if isElement(playerElement) and permission then
		local playerGroups = getElementData(playerElement, "player.groups") or {}

		if playerGroups then
			for k, v in pairs(playerGroups) do
				if availableGroups[k] and availableGroups[k].permissions[permission] then
					return k
				end
			end
		end
	end

	return false
end

function thousandsStepper(amount)
	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1 ")) .. right
end

function isPlayerOfficer(playerElement)
	return isPlayerInGroup(playerElement, {1, 26, 13, 12, 21})
end