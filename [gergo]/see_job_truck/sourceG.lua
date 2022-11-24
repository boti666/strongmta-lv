TRUCK_MODEL = 456
DOOR_MESH_MODEL = 2054
CARRIER_MODEL = 2053

function shallowcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

local _tocolor = tocolor
function tocolor(...)
	if _tocolor then
		return _tocolor(...)
	else
		return 0
	end
end

items = {
	[1] = {
		name = "Körte",
		model = 1271,
		picture = "files/images/items/pear.png",
		picOffset = 0.5,
		picColor = tocolor(61, 122, 188),
		mainIcon = "files/images/items/pear.png",
		mainIcColor = tocolor(61, 122, 188),
		value = 250
	},
	[2] = {
		name = "Narancs",
		model = 1271,
		picture = "files/images/items/orange.png",
		picOffset = 0.5,
		picColor = tocolor(255, 127, 0),
		mainIcon = "files/images/items/orange.png",
		mainIcColor = tocolor(255, 127, 0),
		value = 250
	},
	[3] = {
		name = "Mosógép",
		model = 1208,
		mainIcon = "files/images/items/washm.png",
		mainIcColor = tocolor(255, 255, 255),
		fragile = true,
		value = 250
	},
	[4] = {
		name = "Nyersolaj",
		model = 935,
		picture = "files/images/items/oil.png",
		picOffset = 0.75,
		picColor = tocolor(125, 125, 125),
		mainIcon = "files/images/items/oil.png",
		mainIcColor = tocolor(125, 125, 125),
		value = 250
	},
	[5] = {
		name = "TV",
		model = 2318,
		mainIcon = "files/images/items/tv.png",
		mainIcColor = tocolor(89, 142, 215),
		fragile = true,
		value = 250
	},
	[6] = {
		name = "Kénsav",
		model = 3632,
		picture = "files/images/items/acid.png",
		picOffset = 0.75,
		picColor = tocolor(215, 89, 89),
		mainIcon = "files/images/items/acid.png",
		mainIcColor = tocolor(215, 89, 89),
		value = 250
	},
	[7] = {
		name = "Akkumulátor",
		model = 1271,
		picture = "files/images/items/batt.png",
		picOffset = 0.5,
		picColor = tocolor(125, 125, 125),
		mainIcon = "files/images/items/batt.png",
		mainIcColor = tocolor(125, 125, 125),
		value = 250
	},
	[8] = {
		name = "Fékek",
		model = 1271,
		picture = "files/images/items/brake.png",
		picOffset = 0.5,
		picColor = tocolor(125, 125, 125),
		mainIcon = "files/images/items/brake.png",
		mainIcColor = tocolor(125, 125, 125),
		value = 250
	},
	[9] = {
		name = "Sárgarépa",
		model = 1271,
		picture = "files/images/items/carrot.png",
		picOffset = 0.5,
		picColor = tocolor(255, 127, 0),
		mainIcon = "files/images/items/carrot.png",
		mainIcColor = tocolor(255, 127, 0),
		value = 250
	},
	[10] = {
		name = "Kukorica",
		model = 1271,
		picture = "files/images/items/corn.png",
		picOffset = 0.5,
		picColor = tocolor(223, 181, 81),
		mainIcon = "files/images/items/corn.png",
		mainIcColor = tocolor(223, 181, 81),
		value = 250
	},
	[11] = {
		name = "Dinnye",
		model = 1271,
		picture = "files/images/items/melon.png",
		picOffset = 0.5,
		picColor = tocolor(215, 89, 89),
		mainIcon = "files/images/items/melon.png",
		mainIcColor = tocolor(215, 89, 89),
		value = 250
	},
	[12] = {
		name = "Paprika",
		model = 1271,
		picture = "files/images/items/pepper.png",
		picOffset = 0.5,
		picColor = tocolor(215, 89, 89),
		mainIcon = "files/images/items/pepper.png",
		mainIcColor = tocolor(215, 89, 89),
		value = 250
	},
	[13] = {
		name = "Eper",
		model = 1271,
		picture = "files/images/items/strawb.png",
		picOffset = 0.5,
		picColor = tocolor(215, 89, 89),
		mainIcon = "files/images/items/strawb.png",
		mainIcColor = tocolor(215, 89, 89),
		value = 250
	},
	[14] = {
		name = "Motorolaj",
		model = 935,
		picture = "files/images/items/engineoil.png",
		picOffset = 0.75,
		picColor = tocolor(125, 125, 125),
		mainIcon = "files/images/items/engineoil.png",
		mainIcColor = tocolor(125, 125, 125),
		value = 250
	},
	[15] = {
		name = "Üzemanyag",
		model = 935,
		picture = "files/images/items/fuel.png",
		picOffset = 0.75,
		picColor = tocolor(125, 125, 125),
		mainIcon = "files/images/items/fuel.png",
		mainIcColor = tocolor(125, 125, 125),
		value = 250
	}
}

offsets = {
	[1271] = {0, 1.1, -0.425, 17, 0, 0},
	[1208] = {0, 1.1, -0.795, 17, 0, 0},
	[935] = {0, 1, -0.225, 17, 0, 0},
	[2648] = {0, 0.95, -0.55, -17, 0, 180},
	[2318] = {0, 0.95, -0.55, -17, 0, 180},
	[3632] = {0, 0.95, -0.35, 17, 0, 0}
}

companies = {
	[1] = {
		name = "Xoomer (Come-A-Lot South)",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/xoomer.png", false},
		type = "drop",
		itemPositions = {},
		items = {7, 14, 15},
		loadingBay = {2115.5, 948.46826171874, 7.221191406300022, 10.171691894580022, tocolor(215, 89, 89), false, false, 9.87}
	},
	[2] = {
		name = "Xoomer (Come-A-Lot West)",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/xoomer.png", false},
		type = "drop",
		itemPositions = {},
		items = {7, 14, 15},
		loadingBay = {2632.2670898438, 1067.776489257, 7.221191406300022, 10.171691894580022, tocolor(215, 89, 89), false, false, 9.87}
	},
	[3] = {
		name = "Xoomer (The Emerald Ilse)",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/xoomer.png", false},
		type = "drop",
		itemPositions = {},
		items = {7, 14, 15},
		loadingBay = {2201.732421875, 2490.25, 10.7705078125, 4.981689453099989, tocolor(215, 89, 89), false, false, 9.87}
	},
	[4] = {
		name = "Xoomer (Prickle Pine)",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/xoomer.png", false},
		type = "drop",
		itemPositions = {},
		items = {7, 14, 15},
		loadingBay = {2114.9621582031, 2748.8291015625, 5.230224609400011, 10.270898437499909, tocolor(215, 89, 89), false, false, 9.87}
	},
	[5] = {
		name = "Burger Shot (Old Venturas Strip)",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/burger.png", false},
		type = "drop",
		itemPositions = {},
		items = {1, 2, 9, 10, 11, 12, 13},
		loadingBay = {2483.787109375, 2016.0408935547, 9.376708984400011, 11.76953125, tocolor(215, 89, 89), false, false, 9.87}
	},
	[6] = {
		name = "Burger Shot (Redsands East)",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/burger.png", false},
		type = "drop",
		itemPositions = {},
		items = {1, 2, 9, 10, 11, 12, 13},
		loadingBay = {1851.8704833984, 2078.203125, 9.350219726600017, 11.797119140599989, tocolor(215, 89, 89), false, false, 9.87}
	},
	[7] = {
		name = "Burger Shot (Whitewood Estates)",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/burger.png", false},
		type = "drop",
		itemPositions = {},
		items = {1, 2, 9, 10, 11, 12, 13},
		loadingBay = {1163.7382812, 2078.9711914063, 9.491943409399937, 11.141845703099989, tocolor(215, 89, 89), false, false, 9.87}
	},
	[8] = {
		name = "Globe Oil Olajfinomító",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/oil.png", false},
		type = "drop",
		itemPositions = {},
		items = {4, 14, 15},
		loadingBay = {253.445877075, 1450.3023681641, 6.32246398945, 12.051147460899983, tocolor(215, 89, 89), false, false, 9.63}
	},
	[9] = {
		name = "Fort Carson Hobby Bolt",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/hobby.png", false},
		type = "drop",
		itemPositions = {},
		items = {3, 5, 6, 7},
		loadingBay = {-146.69326782227, 1158.6168212891, 9.090469360360004, 6.000732421799967, tocolor(215, 89, 89), false, false, 18.79}
	},
	[10] = {
		name = "Fort Carson Kórház",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/fch.png", false},
		type = "drop",
		itemPositions = {},
		items = {1, 2, 9, 10, 11, 12, 13},
		loadingBay = {-317.39266967773, 1021.88, 7.099609375, 4.460332031300027, tocolor(215, 89, 89), false, false, 18.77}
	},
	[11] = {
		name = "Las Venturas Kórház",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/lvh.png", false},
		type = "drop",
		itemPositions = {},
		items = {1, 2, 9, 10, 11, 12, 13},
		loadingBay = {1577.4677734375, 1774.6364746094, 4.7440185547000056, 5.0479736327999944, tocolor(215, 89, 89), false, false, 9.845}
	},
	[12] = {
		name = "Las Venturas Autókereskedés",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/carshop.png", false},
		type = "drop",
		itemPositions = {},
		items = {6, 7, 8, 14, 15},
		loadingBay = {1737.8975830078, 1852.2288818359, 11.609741211000028, 9.336425781300022, tocolor(215, 89, 89), false, false, 9.87}
	},
	[13] = {
		name = "Las Venturas Mechanic Shop",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/fix.png", false},
		type = "drop",
		itemPositions = {},
		items = {6, 7, 8, 14, 15},
		loadingBay = {1029.251953125, 1342.66796875, 7.7900390625, 20.3486328125, tocolor(215, 89, 89), false, false, 9.87}
	},
	[14] = {
		name = "Xoomer (Tierra Robada)",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/xoomer.png", false},
		type = "drop",
		itemPositions = {},
		items = {7, 14, 15},
		loadingBay = {-1461.6092529297, 1867.2032470703, 5.28125, 6.325561523000033, tocolor(215, 89, 89), false, false, 31.68}
	},
	[15] = {
		name = "El Quebrados Hobby Bolt",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/hobby.png", false},
		type = "drop",
		itemPositions = {},
		items = {3, 5, 6, 7},
		loadingBay = {-1535.828125, 2567.1928710938, 8.651000976600017, 6.278808593699978, tocolor(215, 89, 89), false, false, 54.879}
	},
	[16] = {
		name = "Whitewood Estates Raktár",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/wh.png", false},
		type = "drop",
		itemPositions = {},
		items = {4, 14, 15},
		loadingBay = {1077.8757324219, 2088.2458496099, 3.5357666014999722, 4.995117187000233, tocolor(215, 89, 89), false, false, 9.87}
	},
	[17] = {
		name = "Whitewood Estates Raktár",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/wh.png", false},
		type = "drop",
		itemPositions = {},
		items = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13},
		loadingBay = {1061.6635742188, 2100.5915527344, 12.6513671875, 6.439453125, tocolor(215, 89, 89), false, false, 9.87}
	},
	[18] = {
		name = "Fort Carson BBQ",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/fcbbq.png", false},
		type = "drop",
		itemPositions = {},
		items = {1, 2, 9, 10, 11, 12, 13},
		loadingBay = {-29.011436462402, 1162.2802734375, 4.807773590088001, 7.713134765599989, tocolor(215, 89, 89), false, false, 18.43}
	},
	[19] = {
		name = "Steakhouse",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/sh.png", false},
		type = "drop",
		itemPositions = {},
		items = {1, 2, 9, 10, 11, 12, 13},
		loadingBay = {1682.3448486328, 2197.3564453125, 6.2293701172000056, 8.6123046875, tocolor(215, 89, 89), false, false, 9.87}
	},
	[20] = {
		name = "24/7 (Starfish Casino)",
		blip = {1387.6708984375, -1898.2607421875, 9.2578125, "minimap/jobblips/247.png", false},
		type = "drop",
		itemPositions = {},
		items = {1, 2, 9, 10, 11, 12, 13},
		loadingBay = {2549.9599609375, 2003.3199462891, 11.9638671875, 6.762207031199978, tocolor(215, 89, 89), false, false, 9.87}
	},
	[21] = {
		name = "Rockshore Depo Terminal 1",
		blip = {2847.796875, 897.8232421875, 25.757776260376, "minimap/jobblips/rockshore.png", false},
		type = "pick",
		itemPositions = {
			{2801.0461425781, 968.01009521484, 9.75},
			{2801.0461425781, 970.11009521484, 9.75},
			{2801.0461425781, 972.21009521484, 9.75},
			{2803.0461425781, 968.01009521484, 9.75},
			{2803.0461425781, 970.11009521484, 9.75},
			{2803.0461425781, 972.21009521484, 9.75},
			{2805.0461425781, 968.01009521484, 9.75},
			{2805.0461425781, 970.11009521484, 9.75},
			{2805.0461425781, 972.21009521484, 9.75},
			{2807.0461425781, 968.01009521484, 9.75},
			{2807.0461425781, 970.11009521484, 9.75},
			{2807.0461425781, 972.21009521484, 9.75}
		},
		items = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
		loadingBay = {2800.0461425781, 966.41009521484, 8.309082031300022, 7.440490722660002, tocolor(215, 89, 89), false, false, 9.8}
	},
	[22] = {
		name = "Rockshore Depo Terminal 2",
		blip = {2847.796875, 897.8232421875, 25.757776260376, "minimap/jobblips/rockshore.png", false},
		type = "pick",
		itemPositions = {
			{2821.9461425781, 968.01009521484, 9.75},
			{2821.9461425781, 970.11009521484, 9.75},
			{2821.9461425781, 972.21009521484, 9.75},
			{2823.9461425781, 968.01009521484, 9.75},
			{2823.9461425781, 970.11009521484, 9.75},
			{2823.9461425781, 972.21009521484, 9.75},
			{2825.9461425781, 968.01009521484, 9.75},
			{2825.9461425781, 970.11009521484, 9.75},
			{2825.9461425781, 972.21009521484, 9.75},
			{2827.9461425781, 968.01009521484, 9.75},
			{2827.9461425781, 970.11009521484, 9.75},
			{2827.9461425781, 972.21009521484, 9.75}
		},
		items = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
		loadingBay = {2820.9461425781, 966.41009521484, 8.309082031300022, 7.440490722660002, tocolor(215, 89, 89), false, false, 9.8}
	},
	[23] = {
		name = "Rockshore Depo Terminal 3",
		blip = {2847.796875, 897.8232421875, 25.757776260376, "minimap/jobblips/rockshore.png", false},
		type = "pick",
		itemPositions = {
			{2831.766845703, 892.6, 9.8203125},
			{2831.766845703, 894.7, 9.8203125},
			{2831.766845703, 896.8, 9.8203125},
			{2831.766845703, 898.9, 9.8203125},
			{2831.766845703, 901, 9.8203125},
			{2833.766845703, 892.6, 9.8203125},
			{2833.766845703, 894.7, 9.8203125},
			{2833.766845703, 896.8, 9.8203125},
			{2833.766845703, 898.9, 9.8203125},
			{2833.766845703, 901, 9.8203125},
			{2835.766845703, 892.6, 9.8203125},
			{2835.766845703, 894.7, 9.8203125},
			{2835.766845703, 896.8, 9.8203125},
			{2835.766845703, 898.9, 9.8203125},
			{2835.766845703, 901, 9.8203125},
			{2837.766845703, 892.6, 9.8203125},
			{2837.766845703, 894.7, 9.8203125},
			{2837.766845703, 896.8, 9.8203125},
			{2837.766845703, 898.9, 9.8203125},
			{2837.766845703, 901, 9.8203125}
		},
		items = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
		loadingBay = {2829.766845703, 890.90594482422, 10.033447265800078, 11.52520751953, tocolor(215, 89, 89), false, false, 9.8}
	},
	[24] = {
		name = "Rockshore Depo Terminal 4",
		blip = {2847.796875, 897.8232421875, 25.757776260376, "minimap/jobblips/rockshore.png", false},
		type = "pick",
		itemPositions = {
			{2869.25, 892.6, 9.8203125},
			{2869.25, 894.7, 9.8203125},
			{2869.25, 896.8, 9.8203125},
			{2869.25, 898.9, 9.8203125},
			{2869.25, 901, 9.8203125},
			{2871.25, 892.6, 9.8203125},
			{2871.25, 894.7, 9.8203125},
			{2871.25, 896.8, 9.8203125},
			{2871.25, 898.9, 9.8203125},
			{2871.25, 901, 9.8203125},
			{2873.25, 892.6, 9.8203125},
			{2873.25, 894.7, 9.8203125},
			{2873.25, 896.8, 9.8203125},
			{2873.25, 898.9, 9.8203125},
			{2873.25, 901, 9.8203125},
			{2875.25, 892.6, 9.8203125},
			{2875.25, 894.7, 9.8203125},
			{2875.25, 896.8, 9.8203125},
			{2875.25, 898.9, 9.8203125},
			{2875.25, 901, 9.8203125}
		},
		items = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
		loadingBay = {2867.4987792969, 890.90594482422, 9.647949218699978, 11.52520751953, tocolor(215, 89, 89), false, false, 9.8}
	}
}

for i = 1, #companies do
	companies[i].blip[1] = companies[i].loadingBay[1] + companies[i].loadingBay[3] / 2
	companies[i].blip[2] = companies[i].loadingBay[2] + companies[i].loadingBay[4] / 2
	companies[i].maxSize = math.max(companies[i].loadingBay[3], companies[i].loadingBay[4])
end
