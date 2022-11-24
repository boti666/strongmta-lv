tuningPositions = {
	{394.8173828125, 2454.6396484375, 14.5, 0},
	{404.8173828125, 2454.6396484375, 14.5, 0},
	{414.8173828125, 2454.6396484375, 14.5, 0}
}

componentOffsets = {
	wheel_lf_dummy = {4, 0.25, 0, 0, -0.25, 0},
	bump_front_dummy = {-0.25, 4, 0.15, -0.25, 0, 0},
	bump_rear_dummy = {0.25, -4, 0.25, 0.25, 0, 0},
	bonnet_dummy = {0, 4, 2, 0, 0, 0},
	exhaust_ok = {0, -5, 1, 0, 0, 0},
	door_rf_dummy = {4, -0.75, -0.25, 0, -0.75, -0.5},
	boot_dummy = {0, -4.5, 1.25, 0, -1, 0},
	boot_dummy_excomp = {0, -5.25, 2.5, 0, -1, 0}
}

tuningEffect = {
	Engine = {
		engineAcceleration = {5, 10, 17.5, 30},
		maxVelocity = {5, 10, 20, 30}
	},
	Turbo = {
		engineAcceleration = {5, 10, 17.5, 30, 35},
		dragCoeff = {-5, -10, -20, -30}
	},
	ECU = {
		engineAcceleration = {5, 10, 17.5, 30},
		maxVelocity = {5, 10, 20, 30}
	},
	Transmission = {
		engineAcceleration = {5, 10, 17.5, 30},
		maxVelocity = {5, 10, 20, 30}
	},
	Suspension = {
		suspensionDamping = {90, 180, 260, 350}
	},
	Brakes = {
		brakeDeceleration = {5, 10, 20, 30}
	},
	Tires = {
		tractionLoss = {5, 10, 20, 30},
		tractionMultiplier = {5, 10, 20, 30}
	},
	WeightReduction = {
		mass = {-5, -10, -20, -30}
	}
}

handlingFlags = {
	_1G_BOOST = 0x1,
	_2G_BOOST = 0x2,
	NPC_ANTI_ROLL = 0x4,
	NPC_NEUTRAL_HANDL = 0x8,
	NO_HANDBRAKE = 0x10,
	STEER_REARWHEELS = 0x20,
	HB_REARWHEEL_STEER = 0x40,
	ALT_STEER_OPT = 0x80,
	WHEEL_F_NARROW2 = 0x100,
	WHEEL_F_NARROW = 0x200,
	WHEEL_F_WIDE = 0x400,
	WHEEL_F_WIDE2 = 0x800,
	WHEEL_R_NARROW2 = 0x1000,
	WHEEL_R_NARROW = 0x2000,
	WHEEL_R_WIDE = 0x4000,
	WHEEL_R_WIDE2 = 0x8000,
	HYDRAULIC_GEOM = 0x10000,
	HYDRAULIC_INST = 0x20000,
	HYDRAULIC_NONE = 0x40000,
	NOS_INST = 0x80000,
	OFFROAD_ABILITY = 0x100000,
	OFFROAD_ABILITY2 = 0x200000,
	HALOGEN_LIGHTS = 0x400000,
	PROC_REARWHEEL_1ST = 0x800000,
	USE_MAXSP_LIMIT = 0x1000000,
	LOW_RIDER = 0x2000000,
	STREET_RACER = 0x4000000,
	SWINGING_CHASSIS = 0x10000000
}

modelFlags = {
	IS_VAN = 0x1,
	IS_BUS = 0x2,
	IS_LOW = 0x4,
	IS_BIG = 0x8,
	REVERSE_BONNET = 0x10,
	HANGING_BOOT = 0x20,
	TALIGATE_BOOT = 0x40,
	NOSWING_BOOT = 0x80,
	NO_DOORS = 0x100,
	TANDEM_SEATS = 0x200,
	SIT_IN_BOAT = 0x400,
	CONVERTIBLE = 0x800,
	NO_EXHAUST = 0x1000,
	DBL_EXHAUST = 0x2000,
	NO1FPS_LOOK_BEHIND = 0x4000,
	FORCE_DOOR_CHECK = 0x8000,
	AXLE_F_NOTILT = 0x10000,
	AXLE_F_SOLID = 0x20000,
	AXLE_F_MCPHERSON = 0x40000,
	AXLE_F_REVERSE = 0x80000,
	AXLE_R_NOTILT = 0x100000,
	AXLE_R_SOLID = 0x200000,
	AXLE_R_MCPHERSON = 0x400000,
	AXLE_R_REVERSE = 0x800000,
	IS_BIKE = 0x1000000,
	IS_HELI = 0x2000000,
	IS_PLANE = 0x4000000,
	IS_BOAT = 0x8000000,
	BOUNCE_PANELS = 0x10000000,
	DOUBLE_RWHEELS = 0x20000000,
	FORCE_GROUND_CLEARANCE = 0x40000000,
	IS_HATCHBACK = 0x80000000
}

componentNames = {
	[1025] = "Zender Dynamic",
	[1073] = "WedsSport TC105N",
	[1074] = "Vossen 305T",
	[1075] = "Ronal Turbo",
	[1076] = "Dayton 100 Spoke",
	[1077] = "Hamann Edition Race",
	[1078] = "Dunlop Drag",
	[1079] = "BBS Stance",
	[1080] = "Advan Racing RGII",
	[1081] = "Classic",
	[1082] = "Volk Racing TE37",
	[1083] = "Dub Bigchips",
	[1084] = "Borbet A",
	[1085] = "BBS RS",
	[1096] = "Fifteen52",
	[1097] = "AMG Monoblock",
	[1098] = "American Racing"
}

function isFlagSet(val, flag)
	return (bitAnd(val, flag) == flag)
end

function getVehicleHandlingFlags(vehicle)
	local flagBytes = getVehicleHandling(vehicle).handlingFlags
	local flagKeyed = {}

	for k, v in pairs(handlingFlags) do
		if isFlagSet(flagBytes, v) then
			flagKeyed[k] = true
		end
	end

	return flagKeyed, flagBytes
end

function getVehicleModelFlags(vehicle)
	local flagBytes = getVehicleHandling(vehicle).modelFlags
	local flagKeyed = {}

	for k, v in pairs(modelFlags) do
		if isFlagSet(flagBytes, v) then
			flagKeyed[k] = true
		end
	end

	return flagKeyed, flagBytes
end

tuningContainer = {
	[1] = {
		name = "Teljesítmény",
		icon = "files/icons/teljesitmeny.png",
		subMenu = {
			[1] = {
				name = "Motor",
				icon = "files/icons/performance/motor.png",
				camera = "bonnet_dummy",
				hideComponent = "bonnet_dummy",
				checkData = "vehicle.tuning.Engine",
				subMenu = {
					[1] = {
						name = "Gyári",
						icon = "files/icons/free.png",
						value = 0,
						priceType = "free",
						price = 0
					},
					[2] = {
						name = "Alap csomag",
						icon = "files/icons/dollar.png",
						value = 1,
						priceType = "money",
						price = 750
					},
					[3] = {
						name = "Profi csomag",
						icon = "files/icons/dollar.png",
						value = 2,
						priceType = "money",
						price = 7500
					},
					[4] = {
						name = "Verseny csomag",
						icon = "files/icons/dollar.png",
						value = 3,
						priceType = "money",
						price = 15000
					},
					[5] = {
						name = "Venom csomag",
						icon = "files/icons/pp.png",
						value = 4,
						priceType = "premium",
						price = 900
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "vehicle.tuning.Engine", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningEngine = ? WHERE vehicleId = ?", value, vehicleId)
					end

					makeTuning(vehicle)

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "vehicle.tuning.Engine") or 0

					if current == value then
						return true
					else
						return false
					end
				end
			},
			[2] = {
				name = "Turbó, Supercharger",
				icon = "files/icons/performance/turbo.png",
				camera = "bonnet_dummy",
				hideComponent = "bonnet_dummy",
				checkData = "vehicle.tuning.Turbo",
				subMenu = {
					[1] = {
						name = "Gyári",
						icon = "files/icons/free.png",
						value = 0,
						priceType = "free",
						price = 0
					},
					[2] = {
						name = "Alap csomag",
						icon = "files/icons/dollar.png",
						value = 1,
						priceType = "money",
						price = 1250
					},
					[3] = {
						name = "Profi csomag",
						icon = "files/icons/dollar.png",
						value = 2,
						priceType = "money",
						price = 6000
					},
					[4] = {
						name = "Verseny csomag",
						icon = "files/icons/dollar.png",
						value = 3,
						priceType = "money",
						price = 17500
					},
					[5] = {
						name = "Venom csomag",
						icon = "files/icons/pp.png",
						value = 4,
						priceType = "premium",
						price = 900
					},
					[6] = {
						name = "Venom+Supercharger",
						icon = "files/icons/sch.png",
						value = 5,
						supercharger = true,
						priceType = "premium",
						price = 1500
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "vehicle.tuning.Turbo", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningTurbo = ? WHERE vehicleId = ?", value, vehicleId)
					end

					makeTuning(vehicle)

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "vehicle.tuning.Turbo") or 0

					if current == value then
						return true
					else
						return false
					end
				end
			},
			[3] = {
				name = "ECU",
				icon = "files/icons/performance/ecu.png",
				camera = "bonnet_dummy",
				hideComponent = "bonnet_dummy",
				checkData = "vehicle.tuning.ECU",
				subMenu = {
					[1] = {
						name = "Gyári",
						icon = "files/icons/free.png",
						value = 0,
						priceType = "free",
						price = 0
					},
					[2] = {
						name = "Alap csomag",
						icon = "files/icons/dollar.png",
						value = 1,
						priceType = "money",
						price = 6000
					},
					[3] = {
						name = "Profi csomag",
						icon = "files/icons/dollar.png",
						value = 2,
						priceType = "money",
						price = 12500
					},
					[4] = {
						name = "Verseny csomag",
						icon = "files/icons/dollar.png",
						value = 3,
						priceType = "money",
						price = 25000
					},
					[5] = {
						name = "Venom csomag",
						icon = "files/icons/pp.png",
						value = 4,
						priceType = "premium",
						price = 900
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "vehicle.tuning.ECU", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningECU = ? WHERE vehicleId = ?", value, vehicleId)
					end

					makeTuning(vehicle)

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "vehicle.tuning.ECU") or 0

					if current == value then
						return true
					else
						return false
					end
				end
			},
			[4] = {
				name = "Váltó",
				icon = "files/icons/performance/valto.png",
				camera = "bonnet_dummy",
				hideComponent = "bonnet_dummy",
				checkData = "vehicle.tuning.Transmission",
				subMenu = {
					[1] = {
						name = "Gyári",
						icon = "files/icons/free.png",
						value = 0,
						priceType = "free",
						price = 0
					},
					[2] = {
						name = "Alap csomag",
						icon = "files/icons/dollar.png",
						value = 1,
						priceType = "money",
						price = 1400
					},
					[3] = {
						name = "Profi csomag",
						icon = "files/icons/dollar.png",
						value = 2,
						priceType = "money",
						price = 8000
					},
					[4] = {
						name = "Verseny csomag",
						icon = "files/icons/dollar.png",
						value = 3,
						priceType = "money",
						price = 12500
					},
					[5] = {
						name = "Venom csomag",
						icon = "files/icons/pp.png",
						value = 4,
						priceType = "premium",
						price = 900
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "vehicle.tuning.Transmission", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningTransmission = ? WHERE vehicleId = ?", value, vehicleId)
					end

					makeTuning(vehicle)

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "vehicle.tuning.Transmission") or 0

					if current == value then
						return true
					else
						return false
					end
				end
			},
			[5] = {
				name = "Felfüggesztés",
				icon = "files/icons/performance/felfugg.png",
				camera = "wheel_lf_dummy",
				hideComponent = "wheel_rf_dummy",
				checkData = "vehicle.tuning.Suspension",
				subMenu = {
					[1] = {
						name = "Gyári",
						icon = "files/icons/free.png",
						value = 0,
						priceType = "free",
						price = 0
					},
					[2] = {
						name = "Alap csomag",
						icon = "files/icons/dollar.png",
						value = 1,
						priceType = "money",
						price = 5000
					},
					[3] = {
						name = "Profi csomag",
						icon = "files/icons/dollar.png",
						value = 2,
						priceType = "money",
						price = 12500
					},
					[4] = {
						name = "Verseny csomag",
						icon = "files/icons/dollar.png",
						value = 3,
						priceType = "money",
						price = 25000
					},
					[5] = {
						name = "Venom csomag",
						icon = "files/icons/pp.png",
						value = 4,
						priceType = "premium",
						price = 900
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "vehicle.tuning.Suspension", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningSuspension = ? WHERE vehicleId = ?", value, vehicleId)
					end

					makeTuning(vehicle)

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "vehicle.tuning.Suspension") or 0

					if current == value then
						return true
					else
						return false
					end
				end
			},
			[6] = {
				name = "Fékek",
				icon = "files/icons/performance/fek.png",
				camera = "wheel_lf_dummy",
				hideComponent = false,
				checkData = "vehicle.tuning.Brakes",
				subMenu = {
					[1] = {
						name = "Gyári",
						icon = "files/icons/free.png",
						value = 0,
						priceType = "free",
						price = 0
					},
					[2] = {
						name = "Alap csomag",
						icon = "files/icons/dollar.png",
						value = 1,
						priceType = "money",
						price = 3250
					},
					[3] = {
						name = "Profi csomag",
						icon = "files/icons/dollar.png",
						value = 2,
						priceType = "money",
						price = 9000
					},
					[4] = {
						name = "Verseny csomag",
						icon = "files/icons/dollar.png",
						value = 3,
						priceType = "money",
						price = 15000
					},
					[5] = {
						name = "Venom csomag",
						icon = "files/icons/pp.png",
						value = 4,
						priceType = "premium",
						price = 900
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "vehicle.tuning.Brakes", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningBrakes = ? WHERE vehicleId = ?", value, vehicleId)
					end

					makeTuning(vehicle)

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "vehicle.tuning.Brakes") or 0

					if current == value then
						return true
					else
						return false
					end
				end
			},
			[7] = {
				name = "Gumik",
				icon = "files/icons/performance/gumi.png",
				camera = "wheel_lf_dummy",
				hideComponent = false,
				checkData = "vehicle.tuning.Tires",
				subMenu = {
					[1] = {
						name = "Gyári",
						icon = "files/icons/free.png",
						value = 0,
						priceType = "free",
						price = 0
					},
					[2] = {
						name = "Alap csomag",
						icon = "files/icons/dollar.png",
						value = 1,
						priceType = "money",
						price = 1250
					},
					[3] = {
						name = "Profi csomag",
						icon = "files/icons/dollar.png",
						value = 2,
						priceType = "money",
						price = 4000
					},
					[4] = {
						name = "Verseny csomag",
						icon = "files/icons/dollar.png",
						value = 3,
						priceType = "money",
						price = 7500
					},
					[5] = {
						name = "Venom csomag",
						icon = "files/icons/pp.png",
						value = 4,
						priceType = "premium",
						price = 900
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "vehicle.tuning.Tires", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningTires = ? WHERE vehicleId = ?", value, vehicleId)
					end

					makeTuning(vehicle)

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "vehicle.tuning.Tires") or 0

					if current == value then
						return true
					else
						return false
					end
				end
			},
			[8] = {
				name = "Nitro",
				icon = "files/icons/performance/nitro.png",
				camera = "boot_dummy",
				hideComponent = "boot_dummy",
				subMenu = {
					[1] = {
						name = "Kiszerelés",
						icon = "files/icons/free.png",
						value = 0,
						priceType = "free",
						price = 0
					},
					[2] = {
						name = "25%",
						icon = "files/icons/dollar.png",
						value = 25,
						priceType = "money",
						price = 10000
					},
					[3] = {
						name = "50%",
						icon = "files/icons/dollar.png",
						value = 50,
						priceType = "money",
						price = 15000
					},
					[4] = {
						name = "75%",
						icon = "files/icons/dollar.png",
						value = 75,
						priceType = "money",
						price = 25000
					},
					[5] = {
						name = "100%",
						icon = "files/icons/dollar.png",
						value = 100,
						priceType = "money",
						price = 30000
					}
				},
				serverFunction = function (vehicle, value)
					local nitroLevel = getElementData(vehicle, "vehicle.nitroLevel") or 0

					if nitroLevel then
						if value > 0 then
							if nitroLevel + value <= 100 then
								setElementData(vehicle, "vehicle.nitroLevel", nitroLevel + value)
							else
								setElementData(vehicle, "vehicle.nitroLevel", 100)
							end
						else
							setElementData(vehicle, "vehicle.nitroLevel", 0)
						end
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					return false
				end
			},
			[9] = {
				name = "Súlycsökkentés",
				icon = "files/icons/performance/sulycsokkentes.png",
				camera = false,
				hideComponent = false,
				checkData = "vehicle.tuning.WeightReduction",
				subMenu = {
					[1] = {
						name = "Gyári",
						icon = "files/icons/free.png",
						value = 0,
						priceType = "free",
						price = 0
					},
					[2] = {
						name = "Alap csomag",
						icon = "files/icons/dollar.png",
						value = 1,
						priceType = "money",
						price = 4250
					},
					[3] = {
						name = "Profi csomag",
						icon = "files/icons/dollar.png",
						value = 2,
						priceType = "money",
						price = 7500
					},
					[4] = {
						name = "Verseny csomag",
						icon = "files/icons/dollar.png",
						value = 3,
						priceType = "money",
						price = 15000
					},
					[5] = {
						name = "Venom csomag",
						icon = "files/icons/pp.png",
						value = 4,
						priceType = "premium",
						price = 900
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "vehicle.tuning.WeightReduction", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningWeightReduction = ? WHERE vehicleId = ?", value, vehicleId)
					end

					makeTuning(vehicle)

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "vehicle.tuning.WeightReduction") or 0

					if current == value then
						return true
					else
						return false
					end
				end
			}
		}
	},
	[2] = {
		name = "Optika",
		icon = "files/icons/optika.png",
		subMenu = {
			[1] = {
				name = "Első lökhárító",
				icon = "files/icons/optical/elso.png",
				priceType = "money",
				price = 1000,
				camera = "bump_front_dummy",
				upgradeSlot = 14,
				subMenu = false,
				clientFunction = function (vehicle, value)
					if originalUpgrade == value then
						return true
					else
						return false
					end
				end
			},
			[2] = {
				name = "Hátsó lökhárító",
				icon = "files/icons/optical/hatso.png",
				priceType = "money",
				price = 1000,
				camera = "bump_rear_dummy",
				upgradeSlot = 15,
				subMenu = false,
				clientFunction = function (vehicle, value)
					if originalUpgrade == value then
						return true
					else
						return false
					end
				end
			},
			[3] = {
				name = "Küszöb",
				icon = "files/icons/optical/kuszob.png",
				priceType = "money",
				price = 1000,
				camera = "door_rf_dummy",
				upgradeSlot = 3,
				subMenu = false,
				clientFunction = function (vehicle, value)
					if originalUpgrade == value then
						return true
					else
						return false
					end
				end
			},
			[4] = {
				name = "Motorháztető",
				icon = "files/icons/optical/motorhaz.png",
				priceType = "money",
				price = 1000,
				camera = "bonnet_dummy",
				upgradeSlot = 0,
				subMenu = false,
				clientFunction = function (vehicle, value)
					if originalUpgrade == value then
						return true
					else
						return false
					end
				end
			},
			[5] = {
				name = "Légterelő",
				icon = "files/icons/optical/legterelo.png",
				priceType = "money",
				price = 1500,
				camera = "boot_dummy_excomp",
				upgradeSlot = 2,
				subMenu = false,
				clientFunction = function (vehicle, value)
					if originalUpgrade == value then
						return true
					else
						return false
					end
				end
			},
			[6] = {
				name = "Tetőlégterelő",
				icon = "files/icons/optical/tetolegterelo.png",
				priceType = "money",
				price = 1000,
				upgradeSlot = 7,
				camera = "base",
				subMenu = false,
				clientFunction = function (vehicle, value)
					if originalUpgrade == value then
						return true
					else
						return false
					end
				end
			},
			[7] = {
				name = "Kerekek",
				icon = "files/icons/optical/felni.png",
				priceType = "money",
				isTheWheelTuning = true,
				price = 5000,
				upgradeSlot = 12,
				camera = "base",
				subMenu = false,
				clientFunction = function (vehicle, value)
					if originalUpgrade == value then
						return true
					else
						return false
					end
				end
			},
			[8] = {
				name = "Kipufogó",
				icon = "files/icons/optical/kipufogo.png",
				priceType = "money",
				price = 2000,
				upgradeSlot = 13,
				camera = "exhaust_ok",
				subMenu = false,
				clientFunction = function (vehicle, value)
					if originalUpgrade == value then
						return true
					else
						return false
					end
				end
			},
			[9] = {
				name = "Hidraulika",
				icon = "files/icons/optical/hidra.png",
				priceType = "money",
				price = 15000,
				upgradeSlot = 9,
				camera = "base",
				subMenu = false,
				clientFunction = function (vehicle, value)
					if originalUpgrade == value then
						return true
					else
						return false
					end
				end
			},
			[10] = {
				name = "Izzó szín",
				icon = "files/icons/optical/izzo.png",
				priceType = "money",
				price = 2500,
				id = "color",
				id2 = "headLightColor",
				camera = "lightpaint",
				subMenu = {
					[1] = {
						name = "Izzó szín",
						icon = "files/icons/optical/izzo.png",
						colorPicker = true,
						colorId = 5,
						priceType = "money",
						price = 2500
					}
				}
			},
			[11] = {
				name = "Neon",
				icon = "files/icons/optical/neon.png",
				priceType = "money",
				price = 5000,
				camera = "door_rf_dummy",
				id = "neon",
				subMenu = {
					[1] = {
						name = "Piros",
						icon = "files/icons/optical/neon.png",
						priceType = "money",
						price = 5000,
						value = 14399
					},
					[2] = {
						name = "Kék",
						icon = "files/icons/optical/neon.png",
						priceType = "money",
						price = 5000,
						value = 14400
					},
					[3] = {
						name = "Zöld",
						icon = "files/icons/optical/neon.png",
						priceType = "money",
						price = 5000,
						value = 14401
					},
					[4] = {
						name = "Citromsárga",
						icon = "files/icons/optical/neon.png",
						priceType = "money",
						price = 5000,
						value = 14402
					},
					[5] = {
						name = "Rózsaszín",
						icon = "files/icons/optical/neon.png",
						priceType = "money",
						price = 5000,
						value = 14403
					},
					[6] = {
						name = "Fehér",
						icon = "files/icons/optical/neon.png",
						priceType = "money",
						price = 5000,
						value = 14404
					},
					[7] = {
						name = "Eltávolítás",
						icon = "files/icons/optical/neon.png",
						priceType = "free",
						price = 0,
						value = 0
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "tuning.neon", value)
					setElementData(vehicle, "tuning.neon.state", 0)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningNeon = ? WHERE vehicleId = ?", value, vehicleId)
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					if neonId == value then
						return true
					else
						return false
					end
				end
			},
			[12] = {
				name = "Air-Ride",
				icon = "files/icons/optical/airride.png",
				priceType = "money",
				price = 20000,
				camera = "base",
				subMenu = {
					[1] = {
						name = "Beszerelés",
						icon = "files/icons/optical/airride.png",
						priceType = "money",
						price = 20000,
						value = 1
					},
					[2] = {
						name = "Kiszerelés",
						icon = "files/icons/optical/airride.png",
						priceType = "free",
						price = 0,
						value = 0
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")
					local currUpgrades = (getElementData(vehicle, "vehicle.tuning.Optical") or ""):gsub("1087,", "")
					local hydraulicsUpgrade = getVehicleUpgradeOnSlot(vehicle, 9)

					if hydraulicsUpgrade then
						removeVehicleUpgrade(vehicle, hydraulicsUpgrade)
					end

					setElementData(vehicle, "vehicle.tuning.AirRide", value)
					setElementData(vehicle, "vehicle.tuning.Optical", currUpgrades)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningAirRide = ?, tuningOptical = ? WHERE vehicleId = ?", value, currUpgrades, vehicleId)
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "vehicle.tuning.AirRide") or 0

					if current == value then
						return true
					else
						return false
					end
				end
			},
			[13] = {
				name = "Spinner",
				icon = "files/icons/spinner.png",
				priceType = "premium",
				price = 1000,
				camera = "base",
				isSpinner = true,
				subMenu = {
					[1] = {
						name = "1. típus - króm",
						icon = "files/icons/spinner.png",
						priceType = "premium",
						price = 1000,
						isSpinnerItem = true,
						value = 4812
					},
					[2] = {
						name = "1. típus - színezhető",
						icon = "files/icons/spinner.png",
						priceType = "premium",
						price = 1000,
						isSpinnerItem = true,
						value = 4813,
						colorPicker = true,
						colorId = 6
					},
					[3] = {
						name = "2. típus - króm",
						icon = "files/icons/spinner.png",
						priceType = "premium",
						price = 1000,
						isSpinnerItem = true,
						value = 4814
					},
					[4] = {
						name = "2. típus - színezhető",
						icon = "files/icons/spinner.png",
						priceType = "premium",
						price = 1000,
						isSpinnerItem = true,
						value = 4817,
						colorPicker = true,
						colorId = 6
					},
					[5] = {
						name = "3. típus - króm",
						icon = "files/icons/spinner.png",
						priceType = "premium",
						price = 1000,
						isSpinnerItem = true,
						value = 4816
					},
					[6] = {
						name = "3. típus - színezhető",
						icon = "files/icons/spinner.png",
						priceType = "premium",
						price = 1000,
						isSpinnerItem = true,
						value = 4815,
						colorPicker = true,
						colorId = 6
					},
					[7] = {
						name = "4. típus - króm",
						icon = "files/icons/spinner.png",
						priceType = "premium",
						price = 1000,
						isSpinnerItem = true,
						value = 4818
					},
					[8] = {
						name = "4. típus - színezhető",
						icon = "files/icons/spinner.png",
						priceType = "premium",
						price = 1000,
						isSpinnerItem = true,
						value = 4819,
						colorPicker = true,
						colorId = 6
					},
					[9] = {
						name = "Leszerel",
						icon = "files/icons/spinner.png",
						priceType = "free",
						price = 0,
						isSpinnerItem = true,
						value = false
					}
				},
				clientFunction = function (vehicle, value)
					if exports.lv_spinner:getOriginalSpinner() == value then
						return true
					else
						return false
					end
				end
			}
		}
	},
	[3] = {
		name = "Fényezés",
		icon = "files/icons/fenyezes.png",
		subMenu = {
			[1] = {
				name = "Szín 1",
				icon = "files/icons/fenyezes.png",
				id = "color",
				colorPicker = true,
				colorId = 1,
				priceType = "money",
				price = 10000,
				subMenu = false
			},
			[2] = {
				name = "Szín 2",
				icon = "files/icons/fenyezes.png",
				id = "color",
				colorPicker = true,
				colorId = 2,
				priceType = "money",
				price = 10000,
				subMenu = false
			},
			[3] = {
				name = "Szín 3",
				icon = "files/icons/fenyezes.png",
				id = "color",
				colorPicker = true,
				colorId = 3,
				priceType = "money",
				price = 10000,
				subMenu = false
			},
			[4] = {
				name = "Szín 4",
				icon = "files/icons/fenyezes.png",
				id = "color",
				colorPicker = true,
				colorId = 4,
				priceType = "money",
				price = 10000,
				subMenu = false
			},
			[5] = {
				name = "Kilóméteróra 1",
				icon = "files/icons/speedo.png",
				id = "color",
				colorPicker = true,
				colorId = 7,
				priceType = "money",
				price = 2500,
				subMenu = false
			},
			[6] = {
				name = "Kilóméteróra 2",
				icon = "files/icons/speedo.png",
				id = "color",
				colorPicker = true,
				colorId = 8,
				priceType = "money",
				price = 2500,
				subMenu = false
			}
		}
	},
	[4] = {
		name = "Extrák",
		icon = "files/icons/extra.png",
		subMenu = {
			[1] = {
				name = "LSD ajtó",
				icon = "files/icons/optical/lsd.png",
				camera = "base",
				id = "door",
				subMenu = {
					[1] = {
						name = "Felszerelés",
						icon = "files/icons/optical/lsd.png",
						priceType = "premium",
						price = 1000,
						value = "scissor"
					},
					[2] = {
						name = "Leszerelés",
						icon = "files/icons/optical/lsd.png",
						priceType = "free",
						price = 0,
						value = nil
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "vehicle.tuning.DoorType", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningDoorType = ? WHERE vehicleId = ?", value, vehicleId)
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					if originalDoor == value then
						return true
					else
						return false
					end
				end
			},
			[2] = {
				name = "Lámpa csere",
				icon = "files/icons/optical/hatsolampa.png",
				id = "headlight",
				camera = "base",
				subMenu = false,
				clientFunction = function (vehicle, value)
					if originalHeadLight == value then
						return true
					else
						return false
					end
				end
			},
			[3] = {
				name = "Paintjob",
				icon = "files/icons/fenyezes.png",
				id = "paintjob",
				camera = "base",
				subMenu = false,
				clientFunction = function (vehicle, value)
					if originalPaintjob == value then
						return true
					else
						return false
					end
				end
			},
			[4] = {
				name = "Kerék paintjob",
				icon = "files/icons/fenyezes.png",
				id = "wheelPaintjob",
				camera = "base",
				subMenu = false,
				clientFunction = function (vehicle, value)
					if originalWheelPaintjob == value then
						return true
					else
						return false
					end
				end
			},
			[5] = {
				name = "Első kerék szélessége",
				icon = "files/icons/optical/gumiszelesseg.png",
				camera = "bump_front_dummy",
				id = "handling",
				handlingPrefix = "WHEEL_F_",
				subMenu = {
					[1] = {
						name = "Extra keskeny",
						icon = "files/icons/optical/gumiszelesseg.png",
						priceType = "money",
						price = 5000,
						value = "NARROW2"
					},
					[2] = {
						name = "Keskeny",
						icon = "files/icons/optical/gumiszelesseg.png",
						priceType = "money",
						price = 7500,
						value = "NARROW"
					},
					[3] = {
						name = "Normál",
						icon = "files/icons/optical/gumiszelesseg.png",
						priceType = "money",
						price = 5000,
						value = "NORMAL"
					},
					[4] = {
						name = "Széles",
						icon = "files/icons/optical/gumiszelesseg.png",
						priceType = "money",
						price = 15000,
						value = "WIDE"
					},
					[5] = {
						name = "Extra széles",
						icon = "files/icons/optical/gumiszelesseg.png",
						priceType = "money",
						price = 25000,
						value = "WIDE2"
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")
					local flagsKeyed, flagBytes = getVehicleHandlingFlags(vehicle)
					local originalBytes = flagBytes

					for flag in pairs(flagsKeyed) do
						if string.find(flag, "WHEEL_F_") then
							flagBytes = flagBytes - handlingFlags[flag]
						end
					end

					if value ~= "NORMAL" then
						flagBytes = flagBytes + handlingFlags["WHEEL_F_" .. value]
					end

					if flagBytes ~= originalBytes then
						setVehicleHandling(vehicle, "handlingFlags", flagBytes)
					end

					setElementData(vehicle, "vehicle.handlingFlags", flagBytes)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET handlingFlags = ? WHERE vehicleId = ?", flagBytes, vehicleId)
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					local flagBytes = originalHandling
					local activeFlag = "NORMAL"

					if isFlagSet(flagBytes, handlingFlags["WHEEL_F_NARROW2"]) then
						activeFlag = "NARROW2"
					elseif isFlagSet(flagBytes, handlingFlags["WHEEL_F_NARROW"]) then
						activeFlag = "NARROW"
					elseif isFlagSet(flagBytes, handlingFlags["WHEEL_F_WIDE"]) then
						activeFlag = "WIDE"
					elseif isFlagSet(flagBytes, handlingFlags["WHEEL_F_WIDE2"]) then
						activeFlag = "WIDE2"
					end

					if activeFlag == value then
						return true
					else
						return false
					end
				end
			},
			[6] = {
				name = "Hátsó kerék szélessége",
				icon = "files/icons/optical/gumiszelesseg.png",
				camera = "bump_rear_dummy",
				id = "handling",
				handlingPrefix = "WHEEL_R_",
				subMenu = {
					[1] = {
						name = "Extra keskeny",
						icon = "files/icons/optical/gumiszelesseg.png",
						priceType = "money",
						price = 5000,
						value = "NARROW2"
					},
					[2] = {
						name = "Keskeny",
						icon = "files/icons/optical/gumiszelesseg.png",
						priceType = "money",
						price = 7500,
						value = "NARROW"
					},
					[3] = {
						name = "Normál",
						icon = "files/icons/optical/gumiszelesseg.png",
						priceType = "money",
						price = 5000,
						value = "NORMAL"
					},
					[4] = {
						name = "Széles",
						icon = "files/icons/optical/gumiszelesseg.png",
						priceType = "money",
						price = 15000,
						value = "WIDE"
					},
					[5] = {
						name = "Extra széles",
						icon = "files/icons/optical/gumiszelesseg.png",
						priceType = "money",
						price = 25000,
						value = "WIDE2"
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")
					local flagsKeyed, flagBytes = getVehicleHandlingFlags(vehicle)
					local originalBytes = flagBytes

					for flag in pairs(flagsKeyed) do
						if string.find(flag, "WHEEL_R_") then
							flagBytes = flagBytes - handlingFlags[flag]
						end
					end

					if value ~= "NORMAL" then
						flagBytes = flagBytes + handlingFlags["WHEEL_R_" .. value]
					end

					if flagBytes ~= originalBytes then
						setVehicleHandling(vehicle, "handlingFlags", flagBytes)
					end

					setElementData(vehicle, "vehicle.handlingFlags", flagBytes)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET handlingFlags = ? WHERE vehicleId = ?", flagBytes, vehicleId)
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					local flagBytes = originalHandling
					local activeFlag = "NORMAL"

					if isFlagSet(flagBytes, handlingFlags["WHEEL_R_NARROW2"]) then
						activeFlag = "NARROW2"
					elseif isFlagSet(flagBytes, handlingFlags["WHEEL_R_NARROW"]) then
						activeFlag = "NARROW"
					elseif isFlagSet(flagBytes, handlingFlags["WHEEL_R_WIDE"]) then
						activeFlag = "WIDE"
					elseif isFlagSet(flagBytes, handlingFlags["WHEEL_R_WIDE2"]) then
						activeFlag = "WIDE2"
					end

					if activeFlag == value then
						return true
					else
						return false
					end
				end
			},
			[7] = {
				name = "Meghajtás",
				icon = "files/icons/optical/meghajtas.png",
				subMenu = {
					[1] = {
						name = "Elsőkerék (FWD)",
						icon = "files/icons/optical/meghajtas.png",
						priceType = "money",
						price = 10000,
						value = "fwd"
					},
					[2] = {
						name = "Összkerék (AWD)",
						icon = "files/icons/optical/meghajtas.png",
						priceType = "money",
						price = 10000,
						value = "awd"
					},
					[3] = {
						name = "Hátsókerék (RWD)",
						icon = "files/icons/optical/meghajtas.png",
						priceType = "money",
						price = 10000,
						value = "rwd"
					},
					[4] = {
						name = "Kapcsolható (RWD/AWD)",
						icon = "files/icons/optical/meghajtas.png",
						priceType = "money",
						price = 50000,
						value = "tog"
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					if value == "tog" then
						setVehicleHandling(vehicle, "driveType", "awd")
						setElementData(vehicle, "activeDriveType", "awd")
					else
						setVehicleHandling(vehicle, "driveType", value)
					end

					setElementData(vehicle, "vehicle.tuning.DriveType", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningDriveType = ? WHERE vehicleId = ?", value, vehicleId)
					end

					makeTuning(vehicle)

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "vehicle.tuning.DriveType")

					if not current then
						current = getVehicleHandling(vehicle).driveType
					end

					if current == value then
						return true
					else
						return false
					end
				end
			},
			[8] = {
				name = "Fordulókör",
				icon = "files/icons/slock.png",
				subMenu = {
					[1] = {
						name = "30°",
						icon = "files/icons/slock.png",
						priceType = "money",
						price = 7500,
						value = 30
					},
					[2] = {
						name = "40°",
						icon = "files/icons/slock.png",
						priceType = "money",
						price = 7500,
						value = 40
					},
					[3] = {
						name = "50°",
						icon = "files/icons/slock.png",
						priceType = "money",
						price = 7500,
						value = 50
					},
					[4] = {
						name = "60°",
						icon = "files/icons/slock.png",
						priceType = "money",
						price = 7500,
						value = 60
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setVehicleHandling(vehicle, "steeringLock", value)
					setElementData(vehicle, "vehicle.tuning.SteeringLock", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET tuningSteeringLock = ? WHERE vehicleId = ?", value, vehicleId)
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					if getVehicleHandling(vehicle).steeringLock == value then
						return true
					else
						return false
					end
				end
			},
			[9] = {
				name = "Önzáró differenciálmű",
				icon = "files/icons/diff.png",
				subMenu = {
					[1] = {
						name = "Felszerelés",
						icon = "files/icons/diff.png",
						priceType = "money",
						price = 10500,
						value = "SOLID"
					},
					[2] = {
						name = "Leszerelés",
						icon = "files/icons/diff.png",
						priceType = "money",
						price = 10500,
						value = "NORMAL"
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")
					local flagsKeyed, flagBytes = getVehicleModelFlags(vehicle)
					local originalBytes = flagBytes

					for flag in pairs(flagsKeyed) do
						if string.find(flag, "AXLE_R_") then
							flagBytes = flagBytes - modelFlags[flag]
						end
					end

					if value ~= "NORMAL" then
						flagBytes = flagBytes + modelFlags["AXLE_R_" .. value]
					end

					if flagBytes ~= originalBytes then
						setVehicleHandling(vehicle, "modelFlags", flagBytes)
					end

					setElementData(vehicle, "vehicle.modelFlags", flagBytes)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET modelFlags = ? WHERE vehicleId = ?", flagBytes, vehicleId)
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					local flagBytes = getVehicleHandling(vehicle).modelFlags
					local activeFlag = "NORMAL"

					if isFlagSet(flagBytes, modelFlags["AXLE_R_SOLID"]) then
						activeFlag = "SOLID"
					end

					if activeFlag == value then
						return true
					else
						return false
					end
				end
			},
			[10] = {
				name = "Offroad optimalizáció",
				icon = "files/icons/optical/offroad.png",
				subMenu = {
					[1] = {
						name = "Nincs optimalizálva",
						icon = "files/icons/optical/offroad.png",
						priceType = "free",
						price = 0,
						value = "NORMAL"
					},
					[2] = {
						name = "Terep beállítás",
						icon = "files/icons/optical/offroad.png",
						priceType = "money",
						price = 20000,
						value = "ABILITY"
					},
					[3] = {
						name = "Murva beállítás",
						icon = "files/icons/optical/offroad.png",
						priceType = "money",
						price = 20000,
						value = "ABILITY2"
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")
					local flagsKeyed, flagBytes = getVehicleHandlingFlags(vehicle)
					local originalBytes = flagBytes

					for flag in pairs(flagsKeyed) do
						if string.find(flag, "OFFROAD_") then
							flagBytes = flagBytes - handlingFlags[flag]
						end
					end

					if value ~= "NORMAL" then
						flagBytes = flagBytes + handlingFlags["OFFROAD_" .. value]
					end

					if flagBytes ~= originalBytes then
						setVehicleHandling(vehicle, "handlingFlags", flagBytes)
					end

					setElementData(vehicle, "vehicle.handlingFlags", flagBytes)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET handlingFlags = ? WHERE vehicleId = ?", flagBytes, vehicleId)
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					local flagBytes = getVehicleHandling(vehicle).handlingFlags
					local activeFlag = "NORMAL"

					if isFlagSet(flagBytes, handlingFlags["OFFROAD_ABILITY"]) then
						activeFlag = "ABILITY"
					elseif isFlagSet(flagBytes, handlingFlags["OFFROAD_ABILITY2"]) then
						activeFlag = "ABILITY2"
					end

					if activeFlag == value then
						return true
					else
						return false
					end
				end
			},
			[11] = {
				name = "Rendszám",
				icon = "files/icons/optical/plate.png",
				camera = "bump_rear_dummy",
				id = "licensePlate",
				subMenu = {
					[1] = {
						name = "Gyári rendszám",
						icon = "files/icons/free.png",
						priceType = "free",
						price = 0,
						value = "default"
					},
					[2] = {
						name = "Egyedi rendszám",
						icon = "files/icons/pp.png",
						licensePlate = true,
						priceType = "premium",
						price = 1200,
						value = "custom"
					}
				}
			},
			[12] = {
				name = "Traffipax radar",
				icon = "files/icons/optical/speedtrap.png",
				priceType = "money",
				price = 15000,
				camera = "base",
				subMenu = {
					[1] = {
						name = "Beszerelés",
						icon = "files/icons/optical/speedtrap.png",
						priceType = "money",
						price = 15000,
						value = 1
					},
					[2] = {
						name = "Kiszerelés",
						icon = "files/icons/optical/speedtrap.png",
						priceType = "free",
						price = 0,
						value = 0
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "traffipaxRadarInVehicle", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET traffipaxRadar = ? WHERE vehicleId = ?", value, vehicleId)
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "traffipaxRadarInVehicle") or 0

					if current == value then
						return true
					else
						return false
					end
				end
			},
			[13] = {
				name = "Variáns",
				icon = "files/icons/variant.png",
				priceType = "money",
				price = 50000,
				camera = "base",
				variantEditor = true
			},
			[14] = {
				name = "SeeGO navigációs rendszer",
				icon = "files/icons/gps.png",
				priceType = "money",
				price = 3000,
				camera = "base",
				subMenu = {
					[1] = {
						name = "Beszerelés",
						icon = "files/icons/gps.png",
						priceType = "money",
						price = 3000,
						value = 1
					},
					[2] = {
						name = "Kiszerelés",
						icon = "files/icons/gps.png",
						priceType = "free",
						price = 0,
						value = 0
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "vehicle.GPS", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET gpsNavigation = ? WHERE vehicleId = ?", value, vehicleId)
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "vehicle.GPS") or 0

					if value == 1 and current >= 1 or current == value then
						return true
					else
						return false
					end
				end
			},
			[15] = {
				name = "Egyedi duda",
				icon = "files/icons/horn.png",
				priceType = "premium",
				price = 1200,
				camera = "base",
				hornSound = true,
				subMenu = {
					[1] = {
						name = "Kiszerelés",
						icon = "files/icons/horn.png",
						priceType = "free",
						price = 0,
						value = 0
					},
					[2] = {
						name = "Duda 1",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 1
					},
					[3] = {
						name = "Duda 2",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 2
					},
					[4] = {
						name = "Duda 3",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 3
					},
					[5] = {
						name = "Duda 4",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 4
					},
					[6] = {
						name = "Duda 5",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 5
					},
					[7] = {
						name = "Duda 6",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 6
					},
					[8] = {
						name = "Duda 7",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 7
					},
					[9] = {
						name = "Duda 8",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 8
					},
					[10] = {
						name = "Duda 9",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 9
					},
					[11] = {
						name = "Duda 10",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 10
					},
					[12] = {
						name = "Duda 11",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 11
					},
					[13] = {
						name = "Duda 12",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 12
					},
					[14] = {
						name = "Duda 13",
						icon = "files/icons/horn.png",
						priceType = "premium",
						price = 1200,
						value = 13
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "customHorn", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET customHorn = ? WHERE vehicleId = ?", value, vehicleId)
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "customHorn") or 0

					if current == value then
						return true
					else
						return false
					end
				end
			},

			[16] = {
				name = "Backfire",
				icon = "files/icons/misc.png",
				--priceType = "premium",
				--price = 3000,
				camera = "base",
				subMenu = {
					[1] = {
						name = "Kiszerelés",
						icon = "files/icons/free.png",
						priceType = "free",
						price = 0,
						value = 0
					},
					[2] = {
						name = "Beszerelés",
						icon = "files/icons/sch.png",
						priceType = "premium",
						price = 1200,
						value = 1
					}
				},
				serverFunction = function (vehicle, value)
					local vehicleId = getElementData(vehicle, "vehicle.dbID")

					setElementData(vehicle, "vehicle.backfire", value)

					if vehicleId then
						dbExec(connection, "UPDATE vehicles SET backFire = ? WHERE vehicleId = ?", value, vehicleId)
					end

					return true
				end,
				clientFunction = function (vehicle, value)
					local current = getElementData(vehicle, "vehicle.backfire") or 0

					if value == 1 and current >= 1 or current == value then
						return true
					else
						return false
					end
				end
			},
		}
	}
}
