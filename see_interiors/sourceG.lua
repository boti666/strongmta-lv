function parseInteriorData(interiorId, data1, data2)
	if interiorId and data1 and data2 then
		local int = availableInteriors[interiorId]

		if int then
			local details = split(data1, "_")

			if details then
				local k = details[1]
				local k2 = details[2]
				
				if k and k2 then
					local v = split(data2, ",")
						
					if v then
						if not int[k] then
							int[k] = {}
						end
						
						if #v > 1 then
							int[k][k2] = {v[1], v[2], v[3]}
						else
							int[k][k2] = data2
						end
					end
				else
					int[data1] = data2
				end
			end
		end
	end
end

function formatNumber(amount, stepper)
	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end

gameInteriors = {
	e = {
		interior = 1,
		name = "Szerkeszthető",
		position = {37.9, 2034.5, 50},
		rotation = {0, 0, 0},
	},
	[1] = {
		interior = 1,
		name = "Ammo nation 1",
		position = {285.8505859375, -41.099609375, 1001.515625},
		rotation = {0, 0, 0}
	},
	[2] = {
		interior = 1,
		name = "Burglary House 1",
		position = {223.125, 1287.0751953125, 1082.140625},
		rotation = {0, 0, 0}
	},
	[3] = {
		interior = 1,
		name = "The Wellcome Pump (Catalina)",
		position = {681.5654296875, -446.388671875, -25.609762191772},
		rotation = {0, 0, 0}
	},
	[4] = {
		interior = 1,
		name = "Restaurant 1",
		position = {455.2529296875, -22.484375, 999.9296875},
		rotation = {0, 0, 0}
	},
	[5] = {
		interior = 1,
		name = "Caligulas Casino",
		position = {2233.9345703125, 1714.6845703125, 1012.3828125},
		rotation = {0, 0, 0}
	},
	[6] = {
		interior = 1,
		name = "Denise's Place",
		position = {244.0892, 304.8456, 999.1484},
		rotation = {0, 0, 0}
	},
	[7] = {
		interior = 1,
		name = "Shamal cabin",
		position = {3.0205078125, 33.20703125, 1199.59375},
		rotation = {0, 0, 0}
	},
	[8] = {
		interior = 1,
		name = "Sweet's House",
		position = {2525.042, -1679.115, 1015.499},
		rotation = {0, 0, 0}
	},
	[9] = {
		interior = 1,
		name = "Transfender",
		position = {627.302734375, -12.056640625, 1000.921875},
		rotation = {0, 0, 0}
	},
	[10] = {
		interior = 1,
		name = "Safe House 4",
		position = {2216.54, -1076.29, 1050.484},
		rotation = {0, 0, 0}
	},
	[11] = {
		interior = 1,
		name = "Trials Stadium",
		position = {-1401.13, 106.11, 1032.273},
		rotation = {0, 0, 0}
	},
	[12] = {
		interior = 1,
		name = "Warehouse 1",
		position = {1419.583984375, 3.720703125, 1002.390625},
		rotation = {0, 0, 0}
	},
	[13] = {
		interior = 1,
		name = "Doherty Garage",
		position = {-2042.42, 178.59, 28.84},
		rotation = {0, 0, 0}
	},
	[14] = {
		interior = 1,
		name = "Sindacco Abatoir",
		position = {963.6078, 2108.397, 1011.03},
		rotation = {0, 0, 0}
	},
	[15] = {
		interior = 1,
		name = "Sub Urban",
		position = {203.6484375, -50.6640625, 1001.8046875},
		rotation = {0, 0, 0}
	},
	[16] = {
		interior = 1,
		name = "Wu Zi Mu's Betting place",
		position = {-2159.926, 641.4587, 1052.382},
		rotation = {0, 0, 0}
	},
	[17] = {
		interior = 2,
		name = "Ryder's House",
		position = {2468.8427734375, -1698.2109375, 1013.5078125},
		rotation = {0, 0, 0}
	},
	[18] = {
		interior = 2,
		name = "Angel Pine Trailer",
		position = {2.0595703125, -3.0146484375, 999.42840576172},
		rotation = {0, 0, 0}
	},
	[19] = {
		interior = 2,
		name = "The Pig Pen",
		position = {1204.748046875, -13.8515625, 1000.921875},
		rotation = {0, 0, 0}
	},
	[20] = {
		interior = 2,
		name = "BDups Crack Palace",
		position = {1523.751, -46.0458, 1002.131},
		rotation = {0, 0, 0}
	},
	[21] = {
		interior = 2,
		name = "Big Smoke's Crack Palace",
		position = {2541.5400390625, -1303.8642578125, 1025.0703125},
		rotation = {0, 0, 0}
	},
	[22] = {
		interior = 2,
		name = "Burglary House 2",
		position = {225.756, 1240, 1082.149},
		rotation = {0, 0, 0}
	},
	[23] = {
		interior = 2,
		name = "Burglary House 3",
		position = {447.47, 1398.348, 1084.305},
		rotation = {0, 0, 0}
	},
	[24] = {
		interior = 2,
		name = "Burglary House 4",
		position = {491.33203125, 1398.4990234375, 1080.2578125},
		rotation = {0, 0, 0}
	},
	[25] = {
		interior = 2,
		name = "Katie's Place",
		position = {267.229, 304.71, 999.148},
		rotation = {0, 0, 0}
	},
	[26] = {
		interior = 2,
		name = "Loco Low Co.",
		position = {612.591, -75.637, 997.992},
		rotation = {0, 0, 0}
	},
	[27] = {
		interior = 2,
		name = "Reece's Barbershop",
		position = {612.591, -75.637, 997.992},
		rotation = {0, 0, 0}
	},
	[28] = {
		interior = 3,
		name = "Jizzy's Pleasure Domes",
		position = {-2636.719, 1402.917, 906.4609},
		rotation = {0, 0, 0}
	},
	[29] = {
		interior = 3,
		name = "Brothel",
		position = {620.197265625, -70.900390625, 997.9921875},
		rotation = {0, 0, 0}
	},
	[30] = {
		interior = 3,
		name = "Brothel 2",
		position = {967.5334, -53.0245, 1001.125},
		rotation = {0, 0, 0}
	},
	[31] = {
		interior = 3,
		name = "BDups Apartment",
		position = {1525.6337890625, -11.015625, 1002.0971069336},
		rotation = {0, 0, 0}
	},
	[32] = {
		interior = 3,
		name = "Bike School",
		position = {1494.390625, 1303.5791015625, 1093.2890625},
		rotation = {0, 0, 0}
	},
	[32] = {
		interior = 3,
		name = "Bike School",
		position = {1494.390625, 1303.5791015625, 1093.2890625},
		rotation = {0, 0, 0}
	},
	[33] = {
		interior = 3,
		name = "Big Spread Ranch",
		position = {1212.0166015625, -25.875, 1000.953125},
		rotation = {0, 0, 0}
	},
	[34] = {
		interior = 3,
		name = "LV Tattoo Parlour",
		position = {-204.439, -43.652, 1002.299},
		rotation = {0, 0, 0}
	},
	[35] = {
		interior = 3,
		name = "LVPD HQ",
		position = {288.8291015625, 166.921875, 1007.171875},
		rotation = {0, 0, 0}
	},
	[36] = {
		interior = 3,
		name = "OG Loc's House",
		position = {516.889, -18.412, 1001.565},
		rotation = {0, 0, 0}
	},
	[37] = {
		interior = 3,
		name = "Pro-Laps",
		position = {206.9296875, -140.375, 1003.5078125},
		rotation = {0, 0, 0}
	},
	[38] = {
		interior = 3,
		name = "Las Venturas Planning Dep.",
		position = {390.7685546875, 173.8505859375, 1008.3828125},
		rotation = {0, 0, 0}
	},
	[39] = {
		interior = 3,
		name = "Record Label Hallway",
		position = {1038.219, 6.9905, 1001.284},
		rotation = {0, 0, 0}
	},
	[40] = {
		interior = 3,
		name = "Driving School",
		position = {-2027.92, -105.183, 1035.172},
		rotation = {0, 0, 0}
	},
	[41] = {
		interior = 3,
		name = "Johnson House",
		position = {2496.0791015625, -1692.083984375, 1014.7421875},
		rotation = {0, 0, 0}
	},
	[42] = {
		interior = 3,
		name = "Burglary House 5",
		position = {235.2529296875, 1186.6806640625, 1080.2578125},
		rotation = {0, 0, 0}
	},
	[43] = {
		interior = 3,
		name = "Gay Gordo's Barbershop",
		position = {418.662109375, -84.3671875, 1001.8046875},
		rotation = {0, 0, 0}
	},
	[44] = {
		interior = 3,
		name = "Helena's Place",
		position = {292.4459, 308.779, 999.1484},
		rotation = {0, 0, 0}
	},
	[45] = {
		interior = 3,
		name = "Inside Track Betting",
		position = {834.66796875, 7.306640625, 1004.1870117188},
		rotation = {0, 0, 0}
	},
	[46] = {
		interior = 3,
		name = "Sex Shop",
		position = {-100.314453125, -25.0380859375, 1000.71875},
		rotation = {0, 0, 0}
	},
	[47] = {
		interior = 3,
		name = "Wheel Arch Angels",
		position = {614.3889, -124.0991, 997.995},
		rotation = {0, 0, 0}
	},
	[48] = {
		interior = 4,
		name = "24/7 shop 1",
		position = {-27.0751953125, -31.7607421875, 1003.5572509766},
		rotation = {0, 0, 0}
	},
	[49] = {
		interior = 4,
		name = "Ammu-Nation 2",
		position = {285.6376953125, -86.6171875, 1001.5228881836},
		rotation = {0, 0, 0}
	},
	[50] = {
		interior = 4,
		name = "Burglary House 6",
		position = {-260.65234375, 1456.9775390625, 1084.3671875},
		rotation = {0, 0, 0}
	},
	[51] = {
		interior = 4,
		name = "Burglary House 7",
		position = {221.7998046875, 1140.837890625, 1082.609375},
		rotation = {0, 0, 0}
	},
	[52] = {
		interior = 4,
		name = "Burglary House 8",
		position = {261.01953125, 1284.294921875, 1080.2578125},
		rotation = {0, 0, 0}
	},
	[53] = {
		interior = 4,
		name = "Diner 2",
		position = {460, -88.43, 999.62},
		rotation = {0, 0, 0}
	},
	[54] = {
		interior = 4,
		name = "Dirtbike Stadium",
		position = {-1435.869, -662.2505, 1052.465},
		rotation = {0, 0, 0}
	},
	[55] = {
		interior = 4,
		name = "Michelle's Place",
		position = {302.6404, 304.8048, 999.1484},
		rotation = {0, 0, 0}
	},
	[56] = {
		interior = 5,
		name = "Madd Dogg's Mansion",
		position = {1272.9116, -768.9028, 1090.5097},
		rotation = {0, 0, 0}
	},
	[57] = {
		interior = 5,
		name = "Well Stacked Pizza Co.",
		position = {372.3212890625, -133.27734375, 1001.4921875},
		rotation = {0, 0, 0}
	},
	[58] = {
		interior = 5,
		name = "Victim",
		position = {227.5625, -7.5419921875, 1002.2109375},
		rotation = {0, 0, 0}
	},
	[59] = {
		interior = 5,
		name = "Burning Desire House",
		position = {2351.154, -1180.577, 1027.977},
		rotation = {0, 0, 0}
	},
	[60] = {
		interior = 5,
		name = "Burglary House 9",
		position = {22.79996, 1404.642, 1084.43},
		rotation = {0, 0, 0}
	},
	[61] = {
		interior = 5,
		name = "Burglary House 10",
		position = {227.0888671875, 1114.2666015625, 1080.9969482422},
		rotation = {0, 0, 0}
	},
	[62] = {
		interior = 5,
		name = "Burglary House 11",
		position = {140.5107421875, 1365.939453125, 1083.859375},
		rotation = {0, 0, 0}
	},
	[63] = {
		interior = 5,
		name = "The Crack Den",
		position = {318.6767578125, 1115.048828125, 1083.8828125},
		rotation = {0, 0, 0}
	},
	[64] = {
		interior = 5,
		name = "Police Station (Barbara's)",
		position = {322.318359375, 302.396484375, 999.1484375},
		rotation = {0, 0, 0}
	},
	[65] = {
		interior = 5,
		name = "Diner 1",
		position = {448.7435, -110.0457, 1000.0772},
		rotation = {0, 0, 0}
	},
	[66] = {
		interior = 5,
		name = "Ganton Gym",
		position = {772.36328125, -5.5146484375, 1000.7286376953},
		rotation = {0, 0, 0}
	},
	[67] = {
		interior = 5,
		name = "Vank Hoff Hotel",
		position = {2233.650390625, -1114.6142578125, 1050.8828125},
		rotation = {0, 0, 0}
	},
	[68] = {
		interior = 6,
		name = "Ammu-Nation 3",
		position = {296.8642578125, -112.0703125, 1001.515625},
		rotation = {0, 0, 0}
	},
	[69] = {
		interior = 6,
		name = "Ammu-Nation 4",
		position = {316.4541015625, -169.509765625, 999.60101318359},
		rotation = {0, 0, 0}
	},
	[70] = {
		interior = 6,
		name = "LSPD HQ",
		position = {246.7333984375, 63.0712890625, 1003.640625},
		rotation = {0, 0, 0}
	},
	[71] = {
		interior = 6,
		name = "Safe House 3",
		position = {2333.033, -1073.96, 1049.023},
		rotation = {0, 0, 0}
	},
	[72] = {
		interior = 6,
		name = "Safe House 5",
		position = {2196.7109375, -1204.205078125, 1049.0234375},
		rotation = {0, 0, 0}
	},
	[73] = {
		interior = 6,
		name = "Safe House 6",
		position = {2308.6064453125, -1212.41796875, 1049.0234375},
		rotation = {0, 0, 0}
	},
	[74] = {
		interior = 6,
		name = "Cobra Marital Arts Gym",
		position = {774.056640625, -50.0830078125, 1000.5859375},
		rotation = {0, 0, 0}
	},
	[75] = {
		interior = 6,
		name = "24/7 shop 2",
		position = {-27.365234375, -57.5771484375, 1003.546875},
		rotation = {0, 0, 0}
	},
	[76] = {
		interior = 6,
		name = "Millie's Bedroom",
		position = {344.52, 304.821, 999.148},
		rotation = {0, 0, 0}
	},
	[77] = {
		interior = 6,
		name = "Fanny Batter's Brothel",
		position = {744.271, 1437.253, 1102.703},
		rotation = {0, 0, 0}
	},
	[78] = {
		interior = 6,
		name = "Restaurant 2",
		position = {443.981, -65.219, 1050},
		rotation = {0, 0, 0}
	},
	[79] = {
		interior = 6,
		name = "Burglary House 15",
		position = {234.220703125, 1064.42578125, 1084.2111816406},
		rotation = {0, 0, 0}
	},
	[80] = {
		interior = 6,
		name = "Burglary House 16",
		position = {-68.701171875, 1351.806640625, 1080.2109375},
		rotation = {0, 0, 0}
	},
	[81] = {
		interior = 7,
		name = "Ammu-Nation 5 (2 Floors)",
		position = {315.385, -142.242, 999.601},
		rotation = {0, 0, 0}
	},
	[82] = {
		interior = 7,
		name = "8-Track Stadium",
		position = {-1417.872, -276.426, 1051.191},
		rotation = {0, 0, 0}
	},
	[83] = {
		interior = 7,
		name = "Below the Belt Gym",
		position = {773.7890625, -78.080078125, 1000.6616821289},
		rotation = {0, 0, 0}
	},
	[84] = {
		interior = 8,
		name = "Colonel Fuhrberger's House",
		position = {2807.5234375, -1174.1103515625, 1025.5703125},
		rotation = {0, 0, 0}
	},
	[85] = {
		interior = 8,
		name = "Burglary House 22",
		position = {-42.49, 1407.644, 1084.43},
		rotation = {0, 0, 0}
	},
	[86] = {
		interior = 9,
		name = "Unknown safe house",
		position = {2255.09375, -1140.169921875, 1050.6328125},
		rotation = {0, 0, 0}
	},
	[87] = {
		interior = 9,
		name = "Andromada Cargo hold",
		position = {315.48, 984.13, 1959.11},
		rotation = {0, 0, 0}
	},
	[88] = {
		interior = 9,
		name = "Burglary House 12",
		position = {82.8525390625, 1322.6796875, 1083.8662109375},
		rotation = {0, 0, 0}
	},
	[89] = {
		interior = 9,
		name = "Burglary House 13",
		position = {260.642578125, 1237.58203125, 1084.2578125},
		rotation = {0, 0, 0}
	},
	[90] = {
		interior = 9,
		name = "Cluckin' Bell",
		position = {365.67, -11.61, 1000.87},
		rotation = {0, 0, 0}
	},
	[91] = {
		interior = 10,
		name = "Four Dragons Casino",
		position = {2018.384765625, 1017.8740234375, 996.875},
		rotation = {0, 0, 0}
	},
	[92] = {
		interior = 10,
		name = "RC Zero's Battlefield",
		position = {-1128.666015625, 1066.4921875, 1345.7438964844},
		rotation = {0, 0, 0}
	},
	[93] = {
		interior = 10,
		name = "Burger Shot",
		position = {363.0419921875, -74.9619140625, 1001.5078125},
		rotation = {0, 0, 0}
	},
	[94] = {
		interior = 10,
		name = "Burglary House 14",
		position = {24.0498046875, 1340.3623046875, 1084.375},
		rotation = {0, 0, 0}
	},
	[95] = {
		interior = 10,
		name = "Janitor room(Four Dragons Maintenance)",
		position = {1891.396, 1018.126, 31.882},
		rotation = {0, 0, 0}
	},
	[96] = {
		interior = 10,
		name = "Hashbury safe house",
		position = {2269.576171875, -1210.4306640625, 1047.5625},
		rotation = {0, 0, 0}
	},
	[97] = {
		interior = 10,
		name = "24/7 shop 3",
		position = {6.0673828125, -30.60546875, 1003.5494384766},
		rotation = {0, 0, 0}
	},
	[98] = {
		interior = 10,
		name = "Abandoned AC Tower",
		position = {422.0302734375, 2536.4365234375, 10},
		rotation = {0, 0, 0}
	},
	[99] = {
		interior = 10,
		name = "SFPD HQ",
		position = {246.3916015625, 108.1259765625, 1003.21875},
		rotation = {0, 0, 0}
	},
	[100] = {
		interior = 11,
		name = "The Four Dragons Office",
		position = {2011.603, 1017.023, 39.091},
		rotation = {0, 0, 0}
	},
	[101] = {
		interior = 11,
		name = "Ten Green Bottles Bar",
		position = {501.900390625, -67.828125, 998.7578125},
		rotation = {0, 0, 0}
	},
	[102] = {
		interior = 12,
		name = "The Casino",
		position = {1133.158203125, -15.0625, 1000.6796875},
		rotation = {0, 0, 0}
	},
	[103] = {
		interior = 12,
		name = "Macisla's Barbershop",
		position = {411.98046875, -53.673828125, 1001.8984375},
		rotation = {0, 0, 0}
	},
	[104] = {
		interior = 12,
		name = "Safe house 7",
		position = {2237.297, -1077.925, 1049.023},
		rotation = {0, 0, 0}
	},
	[105] = {
		interior = 12,
		name = "Modern safe house",
		position = {2324.499, -1147.071, 1050.71},
		rotation = {0, 0, 0}
	},
	[106] = {
		interior = 13,
		name = "LS Atrium",
		position = {2324.499, -1147.071, 1050.71},
		rotation = {0, 0, 0}
	},
	[107] = {
		interior = 13,
		name = "CJ's Garage",
		position = {2324.499, -1147.071, 1050.71},
		rotation = {0, 0, 0}
	},
	[108] = {
		interior = 14,
		name = "Kickstart Stadium",
		position = {-1464.536, 1557.69, 1052.531},
		rotation = {0, 0, 0}
	},
	[109] = {
		interior = 14,
		name = "Didier Sachs",
		position = {204.0888671875, -168.1689453125, 1000.5234375},
		rotation = {0, 0, 0}
	},
	[110] = {
		interior = 14,
		name = "Francis Int. Airport (Front ext.)",
		position = {-1827.1473, 7.2074, 1061.1435},
		rotation = {0, 0, 0}
	},
	[111] = {
		interior = 14,
		name = "Francis Int. Airport (Baggage Claim/Ticket Sales)",
		position = {-1855.5687, 41.2631, 1061.1435},
		rotation = {0, 0, 0}
	},
	[112] = {
		interior = 14,
		name = "Wardrobe",
		position = {255.719, -41.137, 1002.023},
		rotation = {0, 0, 0}
	},
	[113] = {
		interior = 15,
		name = "Binco",
		position = {207.543, -109.004, 1005.133},
		rotation = {0, 0, 0}
	},
	[114] = {
		interior = 15,
		name = "Blood Bowl Stadium",
		position = {-1423.505859375, 936.16015625, 1036.4901123047},
		rotation = {0, 0, 0}
	},
	[115] = {
		interior = 15,
		name = "Jefferson Motel",
		position = {2227.7724609375, -1150.2373046875, 1025.796875},
		rotation = {0, 0, 0}
	},
	[116] = {
		interior = 15,
		name = "Burglary House 17",
		position = {-284.4794921875, 1471.185546875, 1084.375},
		rotation = {0, 0, 0}
	},
	[117] = {
		interior = 15,
		name = "Burglary House 18",
		position = {327.808, 1479.74, 1084.438},
		rotation = {0, 0, 0}
	},
	[118] = {
		interior = 15,
		name = "Burglary House 19",
		position = {375.572, 1417.439, 1081.328},
		rotation = {0, 0, 0}
	},
	[119] = {
		interior = 15,
		name = "Burglary House 20",
		position = {384.644, 1471.479, 1080.195},
		rotation = {0, 0, 0}
	},
	[120] = {
		interior = 15,
		name = "Burglary House 21",
		position = {294.990234375, 1472.7744140625, 1080.2578125},
		rotation = {0, 0, 0}
	},
	[121] = {
		interior = 16,
		name = "24/7 shop 4",
		position = {-25.8740234375, -140.95703125, 1003.546875},
		rotation = {0, 0, 0}
	},
	[122] = {
		interior = 16,
		name = "LS Tattoo Parlour",
		position = {-204.2294921875, -26.71875, 1002.2734375},
		rotation = {0, 0, 0}
	},
	[123] = {
		interior = 16,
		name = "Sumoring? stadium",
		position = {-1400, 1250, 1040},
		rotation = {0, 0, 0}
	},
	[124] = {
		interior = 17,
		name = "24/7 shop 5",
		position = {-25.7509765625, -187.48046875, 1003.546875},
		rotation = {0, 0, 0}
	},
	[125] = {
		interior = 17,
		name = "Club",
		position = {493.4687, -23.008, 1000.6796},
		rotation = {0, 0, 0}
	},
	[126] = {
		interior = 17,
		name = "Rusty Brown's - Ring Donuts",
		position = {377.003, -192.507, 1000.633},
		rotation = {0, 0, 0}
	},
	[127] = {
		interior = 17,
		name = "The Sherman's Dam Generator Hall",
		position = {-942.132, 1849.142, 5.005},
		rotation = {0, 0, 0}
	},
	[128] = {
		interior = 17,
		name = "Hemlock Tattoo",
		position = {377.003, -192.507, 1000.633},
		rotation = {0, 0, 0}
	},
	[129] = {
		interior = 18,
		name = "Lil Probe Inn",
		position = {-228.796875, 1401.177734375, 27.765625},
		rotation = {0, 0, 0}
	},
	[130] = {
		interior = 18,
		name = "24/7 shop 6",
		position = {-30.8720703125, -91.3359375, 1003.546875},
		rotation = {0, 0, 0}
	},
	[131] = {
		interior = 18,
		name = "Atrium",
		position = {1726.974609375, -1637.888671875, 20.222967147827},
		rotation = {0, 0, 0}
	},
	[132] = {
		interior = 18,
		name = "Warehouse 2",
		position = {1307.220703125, 3.22265625, 1001.02734375},
		rotation = {0, 0, 0}
	},
	[133] = {
		interior = 18,
		name = "Zip",
		position = {161.2744140625, -96.2490234375, 1001.8046875},
		rotation = {0, 0, 0}
	},
	[134] = {
		interior = 3,
		name = "Garázs - Kicsi",
		position = {614.3889, -124.0991, 997.995},
		rotation = {0, 0, 270}
	},
	[135] = {
		interior = 2,
		name = "Garázs - Közepes",
		position = {613.193359375, -76.302734375, 998},
		rotation = {0, 0, 270}
	},
	[136] = {
		interior = 1,
		name = "Garázs - Nagy",
		position = {608.2451171875, -5.7783203125, 1000.9193115234},
		rotation = {0, 0, 270}
	}
}

function getGameInteriors()
	return gameInteriors
end

deletedInteriors = {}
availableInteriors = {
	[1] = {
		name = "Benzinkút",
		gameInterior = 97,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2117.5959472656, 897.19274902344, 11.1796875},
			rotation = {0, 0, 179.68054199219},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-25.8740234375, -140.95703125, 1003.546875},
			rotation = {0, 0, 0},
			interior = 16,
			dimension = 1
		}
	},
	[2] = {
		name = "Benzinkút",
		gameInterior = 121,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2637.2587890625, 1128.7164306641, 11.1796875},
			rotation = {0, 0, 1.5698276758194},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-25.8740234375, -140.95703125, 1003.546875},
			rotation = {0, 0, 0},
			interior = 16,
			dimension = 2
		}
	},
	[3] = {
		name = "Benzinkút",
		gameInterior = 121,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2150.7019042969, 2734.5266113281, 11.176349639893},
			rotation = {0, 0, 181.6498260498},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-25.8740234375, -140.95703125, 1003.546875},
			rotation = {0, 0, 0},
			interior = 16,
			dimension = 3
		}
	},
	[4] = {
		name = "Benzinkút",
		gameInterior = 121,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2188.7155761719, 2469.5202636719, 11.2421875},
			rotation = {0, 0, 88.588958740234},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-25.8740234375, -140.95703125, 1003.546875},
			rotation = {0, 0, 0},
			interior = 16,
			dimension = 4
		}
	},
	[5] = {
		name = "Benzinkút",
		gameInterior = 121,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1599.7967529297, 2221.212890625, 11.0625},
			rotation = {0, 0, 49.735515594482},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-25.8740234375, -140.95703125, 1003.546875},
			rotation = {0, 0, 0},
			interior = 16,
			dimension = 5
		}
	},
	[6] = {
		name = "Benzinkút",
		gameInterior = 121,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {638.74932861328, 1683.8020019531, 7.1875},
			rotation = {0, 0, 220.52719116211},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-25.8740234375, -140.95703125, 1003.546875},
			rotation = {0, 0, 0},
			interior = 16,
			dimension = 6
		}
	},
	[7] = {
		name = "Benzinkút",
		gameInterior = 121,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1320.1539306641, 2697.9677734375, 50.26628112793},
			rotation = {0, 0, 30.065649032593},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-25.8740234375, -140.95703125, 1003.546875},
			rotation = {0, 0, 0},
			interior = 16,
			dimension = 7
		}
	},
	[8] = {
		name = "Benzinkút",
		gameInterior = 121,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1465.6614990234, 1872.6290283203, 32.6328125},
			rotation = {0, 0, 2.4686188697815},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-25.8740234375, -140.95703125, 1003.546875},
			rotation = {0, 0, 0},
			interior = 16,
			dimension = 8
		}
	},
	[11] = {
		name = "Bank",
		gameInterior = 4,
		type = "building",
		price = 4,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2474.5458984375, 1023.7262573242, 10.8203125},
			rotation = {0, 0, 355.27645874023},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2474.9501953125, 1029.6218261719, -1.5816850662231},
			rotation = {0, 0, 182.02487182617},
			interior = 0,
			dimension = 0
		}
	},
	[12] = {
		name = "Bank",
		gameInterior = 4,
		type = "building",
		price = 4,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-828.10430908203, 1503.3115234375, 19.682628631592},
			rotation = {0, 0, 0.89329743385315},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-827.85437011719, 1502.2331542969, 13.718315124512},
			rotation = {0, 0, 183.23162841797},
			interior = 0,
			dimension = 0
		}
	},
	[13] = {
		name = "Városháza",
		gameInterior = 38,
		type = "building",
		price = 4,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1042.7795410156, 1010.8475952148, 11},
			rotation = {0, 0, 138.73779296875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {389.28747558594, 173.78804016113, 1008.3828125},
			rotation = {-0, 0, 89.761878967285},
			interior = 3,
			dimension = 13
		}
	},
	[14] = {
		name = "Binco",
		gameInterior = 113,
		type = "building",
		price = 4,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1656.2729492188, 1733.3719482422, 10.82811164856},
			rotation = {0, 0, 278.48394775391},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {207.65524291992, -110.74481201172, 1005.1328125},
			rotation = {0, 0, 187.30325317383},
			interior = 15,
			dimension = 14
		}
	},
	[15] = {
		name = "Raktár",
		gameInterior = 1,
		type = "building",
		price = 1,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1443.5197753906, 2349.7348632813, 10.8203125},
			rotation = {0, 0, 91.470825195313},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {1435.0725097656, 2360.7426757813, -3.9390625953674},
			rotation = {0, 0, 263.15567016602},
			interior = 0,
			dimension = 0
		}
	},
	[16] = {
		name = "Gyár",
		gameInterior = 1,
		type = "building",
		price = 1,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1466.3245849609, 2357.7292480469, 10.8203125},
			rotation = {0, 0, 277.85906982422},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {1510.6705322266, 2334.2546386719, -1.4910898208618},
			rotation = {0, 0, 265.63897705078},
			interior = 0,
			dimension = 0
		}
	},
	[17] = {
		name = "Iroda",
		gameInterior = 32,
		type = "building",
		price = 1,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1442.3312988281, 2360.0622558594, 10.8203125},
			rotation = {0, 0, 75.078765869141},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {1494.390625, 1303.5791015625, 1093.2890625},
			rotation = {0, 0, 0},
			interior = 3,
			dimension = 17
		}
	},
	[19] = {
		name = "Tető",
		gameInterior = 0,
		type = "building",
		price = 1,
		dummy = "Y",
		ownerId = 0,
		entrance = {
			position = {2262.4545898438, -1216.9007568359, 1049.0234375},
			rotation = {0, 0, 89.290596008301},
			interior = 10,
			dimension = 18
		},
		exit = {
			position = {0, 0, 0},
			rotation = {0, 0, 0},
			interior = 0,
			dimension = 19
		}
	},
	[30] = {
		name = "Ammu Nation",
		gameInterior = 68,
		type = "building",
		price = 1,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2158.8972167969, 943.14324951172, 10.8203125},
			rotation = {0, 0, 3.2058653831482},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {296.8642578125, -112.0703125, 1001.515625},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 30
		}
	},
	[31] = {
		name = "Rendőrség",
		gameInterior = 99,
		type = "building",
		price = 1,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2340.1025390625, 2457.1384277344, 14.96875},
			rotation = {0, 0, 353.67474365234},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {246.3916015625, 108.1259765625, 1003.21875},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 31
		}
	},
	[32] = {
		name = "The Well Stacked Pizza Co.",
		gameInterior = 57,
		type = "building",
		price = 1,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2351.7543945313, 2532.5012207031, 10.8203125},
			rotation = {0, 0, 356.28570556641},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {372.3212890625, -133.27734375, 1001.4921875},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 32
		}
	},
	[33] = {
		name = "Lottózó",
		gameInterior = 16,
		type = "building",
		price = 1,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {662.42095947266, 1717.0665283203, 7.1875},
			rotation = {0, 0, 219.31329345703},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-2158.6604003906, 642.85095214844, 1052.375},
			rotation = {0, 0, 322.42449951172},
			interior = 1,
			dimension = 33
		}
	},
	[34] = {
		name = "Autósiskola",
		gameInterior = 40,
		type = "building",
		price = 1,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {886.37414550781, 2004.4193115234, 10.8203125},
			rotation = {0, 0, 199.73352050781},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-2026.8887939453, -104.13233184814, 1035.171875},
			rotation = {0, 0, 320.19921875},
			interior = 3,
			dimension = 34
		}
	},
	[63] = {
		name = "Iroda",
		gameInterior = 6,
		type = "building2",
		price = 1,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-390.50701904297, 1277.6354980469, 8.21875},
			rotation = {0, 0, 108.8436050415},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-388.16497802734, 1283.5579833984, 5.3093748092651},
			rotation = {0, 0, 134.46464538574},
			interior = 0,
			dimension = 0
		}
	},
	[64] = {
		name = "SWAT",
		gameInterior = 6,
		type = "building2",
		price = 6,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2521.9934082031, 2465.2526855469, 21.875},
			rotation = {0, 0, 269.68942260742},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2537.4968261719, 2452.7399902344, 20003.55078125},
			rotation = {0, 0, 195.35615539551},
			interior = 0,
			dimension = 0
		}
	},
	[67] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1897.6873779297, 729.19970703125, 10.819780349731},
			rotation = {0, 0, 89.927612304688},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 67
		}
	},
	[68] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1897.4548339844, 736.68316650391, 10.819780349731},
			rotation = {0, 0, 91.807647705078},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 68
		}
	},
	[69] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1901.923828125, 741.91790771484, 10.819780349731},
			rotation = {0, 0, 1.6136431694031},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 69
		}
	},
	[70] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1908.9887695313, 742.03918457031, 10.819780349731},
			rotation = {0, 0, 0.67373418807983},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 70
		}
	},
	[71] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1915.921875, 741.72644042969, 10.8203125},
			rotation = {0, 0, 2.8670856952667},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 71
		}
	},
	[72] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1922.7906494141, 742.14727783203, 10.8203125},
			rotation = {0, 0, 3.8071179389954},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 72
		}
	},
	[73] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1929.3491210938, 742.10906982422, 10.8203125},
			rotation = {0, 0, 3.4938032627106},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 73
		}
	},
	[74] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1935.9359130859, 742.31524658203, 10.8203125},
			rotation = {0, 0, 1.3004585504532},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 74
		}
	},
	[75] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1942.4616699219, 742.37890625, 10.8203125},
			rotation = {0, 0, 0.98718529939651},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 75
		}
	},
	[76] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1949.4036865234, 742.41058349609, 10.8203125},
			rotation = {0, 0, 6.6272826194763},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 76
		}
	},
	[77] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.0301513672, 742.46691894531, 10.8203125},
			rotation = {0, 0, 2.553852558136},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 77
		}
	},
	[78] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.5450439453, 737.90588378906, 10.8203125},
			rotation = {0, 0, 274.84326171875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 78
		}
	},
	[79] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.3598632813, 731.23095703125, 10.8203125},
			rotation = {0, 0, 271.70989990234},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 79
		}
	},
	[80] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.6533203125, 724.41931152344, 10.8203125},
			rotation = {0, 0, 276.41000366211},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 80
		}
	},
	[81] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.5920410156, 721.62628173828, 10.8203125},
			rotation = {0, 0, 275.78332519531},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 81
		}
	},
	[82] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.6999511719, 714.91583251953, 10.8203125},
			rotation = {0, 0, 263.56326293945},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 82
		}
	},
	[83] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.1077880859, 691.5390625, 10.8203125},
			rotation = {0, 0, 273.47915649414},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 83
		}
	},
	[84] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.1193847656, 684.64764404297, 10.8203125},
			rotation = {0, 0, 273.25344848633},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 84
		}
	},
	[85] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1955.9650878906, 677.77795410156, 10.8203125},
			rotation = {0, 0, 275.13348388672},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 85
		}
	},
	[87] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.0979003906, 671.13067626953, 10.8203125},
			rotation = {0, 0, 269.49337768555},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 87
		}
	},
	[88] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1955.8553466797, 664.72711181641, 10.8203125},
			rotation = {0, 0, 271.91345214844},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 88
		}
	},
	[89] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1952.1385498047, 664.03485107422, 10.8203125},
			rotation = {0, 0, 184.48196411133},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 89
		}
	},
	[90] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1945.3743896484, 663.9716796875, 10.8203125},
			rotation = {0, 0, 181.43099975586},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 90
		}
	},
	[91] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1938.8479003906, 663.92669677734, 10.8203125},
			rotation = {0, 0, 179.51449584961},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 91
		}
	},
	[92] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1932.0327148438, 663.91979980469, 10.8203125},
			rotation = {0, 0, 184.90049743652},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 92
		}
	},
	[93] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1925.6165771484, 663.93035888672, 10.8203125},
			rotation = {0, 0, 176.74066162109},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 93
		}
	},
	[94] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1918.7935791016, 663.91595458984, 10.8203125},
			rotation = {0, 0, 183.85922241211},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 94
		}
	},
	[95] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1911.9489746094, 663.83184814453, 10.8203125},
			rotation = {0, 0, 178.40765380859},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 95
		}
	},
	[96] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1904.8424072266, 663.81976318359, 10.8203125},
			rotation = {0, 0, 183.33378601074},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 96
		}
	},
	[97] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1897.953125, 664.01983642578, 10.8203125},
			rotation = {0, 0, 183.02061462402},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 97
		}
	},
	[98] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1897.5847167969, 668.50842285156, 10.8203125},
			rotation = {0, 0, 87.927711486816},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 98
		}
	},
	[99] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1897.5988769531, 675.28381347656, 10.8203125},
			rotation = {0, 0, 91.132095336914},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 99
		}
	},
	[100] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1897.5764160156, 681.93432617188, 10.8203125},
			rotation = {0, 0, 88.239540100098},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 100
		}
	},
	[102] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1897.1175537109, 677.19146728516, 14.275157928467},
			rotation = {0, 0, 93.542770385742},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 102
		}
	},
	[103] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1897.162109375, 669.81127929688, 14.277047157288},
			rotation = {0, 0, 87.542640686035},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 103
		}
	},
	[104] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1897.9711914063, 663.96948242188, 14.2734375},
			rotation = {0, 0, 176.53010559082},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 104
		}
	},
	[105] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1904.9815673828, 664.01538085938, 14.2734375},
			rotation = {0, 0, 182.74983215332},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 105
		}
	},
	[106] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1911.9976806641, 664.03179931641, 14.2734375},
			rotation = {0, 0, 184.94320678711},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 106
		}
	},
	[107] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1918.6524658203, 663.98211669922, 14.2734375},
			rotation = {0, 0, 179.92979431152},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 107
		}
	},
	[108] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1925.4284667969, 664.08605957031, 14.2734375},
			rotation = {0, 0, 182.74969482422},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 108
		}
	},
	[109] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1932.0723876953, 663.80993652344, 14.2734375},
			rotation = {0, 0, 183.06297302246},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 109
		}
	},
	[110] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1938.8173828125, 663.83172607422, 14.2734375},
			rotation = {0, 0, 181.47276306152},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 110
		}
	},
	[111] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1945.6008300781, 663.95562744141, 14.2734375},
			rotation = {0, 0, 181.78605651855},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 111
		}
	},
	[112] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1952.2673339844, 663.87683105469, 14.2734375},
			rotation = {0, 0, 179.27932739258},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 112
		}
	},
	[113] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.7272949219, 664.8466796875, 14.273241043091},
			rotation = {0, 0, 273.59338378906},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 113
		}
	},
	[114] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.7677001953, 671.39447021484, 14.273241043091},
			rotation = {0, 0, 265.13317871094},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 114
		}
	},
	[115] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.5275878906, 677.97888183594, 14.273241043091},
			rotation = {0, 0, 277.66656494141},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 115
		}
	},
	[116] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.7770996094, 688.21923828125, 14.273241043091},
			rotation = {0, 0, 272.0266418457},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 116
		}
	},
	[118] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.6546630859, 718.22247314453, 14.281055450439},
			rotation = {0, 0, 271.01611328125},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 118
		}
	},
	[119] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.7431640625, 724.71765136719, 14.281055450439},
			rotation = {0, 0, 268.50936889648},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 119
		}
	},
	[120] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.728515625, 731.30450439453, 14.281055450439},
			rotation = {0, 0, 275.08950805664},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 120
		}
	},
	[121] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1956.7525634766, 738.04913330078, 14.281055450439},
			rotation = {0, 0, 272.26959228516},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 121
		}
	},
	[122] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1955.9989013672, 742.34753417969, 14.2734375},
			rotation = {0, 0, 1.2571212053299},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 122
		}
	},
	[123] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1949.2874755859, 742.62176513672, 14.2734375},
			rotation = {0, 0, 4.3904428482056},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 123
		}
	},
	[124] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1942.5093994141, 742.36199951172, 14.2734375},
			rotation = {0, 0, 358.43698120117},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 124
		}
	},
	[125] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1935.9990234375, 742.40637207031, 14.2734375},
			rotation = {0, 0, 2.5102763175964},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 125
		}
	},
	[126] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1929.1311035156, 742.36730957031, 14.2734375},
			rotation = {0, 0, 358.75030517578},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 126
		}
	},
	[127] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1922.5640869141, 742.4267578125, 14.2734375},
			rotation = {0, 0, 358.43695068359},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 127
		}
	},
	[128] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1915.759765625, 742.31536865234, 14.2734375},
			rotation = {0, 0, 357.49688720703},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 128
		}
	},
	[129] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1908.8719482422, 742.458984375, 14.2734375},
			rotation = {0, 0, 0.63030099868774},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 129
		}
	},
	[130] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1901.7677001953, 742.60107421875, 14.2734375},
			rotation = {0, 0, 4.7035317420959},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 130
		}
	},
	[131] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1897.2580566406, 736.8779296875, 14.277292251587},
			rotation = {0, 0, 95.234329223633},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 131
		}
	},
	[132] = {
		name = "Motel szoba",
		gameInterior = 96,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1897.2628173828, 729.20129394531, 14.275426864624},
			rotation = {0, 0, 87.786849975586},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 132
		}
	},
	[134] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2373.3017578125, 1643.0444335938, 11.0234375},
			rotation = {0, 0, 179.18507385254},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 134
		}
	},
	[139] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2368.4890136719, 1643.1081542969, 11.0234375},
			rotation = {0, 0, 181.3786315918},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 139
		}
	},
	[140] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2363.4794921875, 1643.2459716797, 11.0234375},
			rotation = {0, 0, 176.05194091797},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 140
		}
	},
	[141] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.4802246094, 1643.3974609375, 11.0234375},
			rotation = {0, 0, 176.96846008301},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 141
		}
	},
	[142] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.2824707031, 1648.6140136719, 11.0234375},
			rotation = {0, 0, 92.054328918457},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 142
		}
	},
	[143] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.3447265625, 1653.8931884766, 11.0234375},
			rotation = {0, 0, 89.547607421875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 143
		}
	},
	[144] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.3762207031, 1659.0856933594, 11.0234375},
			rotation = {0, 0, 88.920967102051},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 144
		}
	},
	[145] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.2680664063, 1664.2147216797, 11.0234375},
			rotation = {0, 0, 89.54759979248},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 145
		}
	},
	[146] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.2575683594, 1669.3542480469, 11.0234375},
			rotation = {0, 0, 92.054290771484},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 146
		}
	},
	[147] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.3405761719, 1674.2846679688, 11.0234375},
			rotation = {0, 0, 88.294250488281},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 147
		}
	},
	[148] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.3645019531, 1679.2628173828, 11.0234375},
			rotation = {0, 0, 85.160926818848},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 148
		}
	},
	[149] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2361.1333007813, 1682.4868164063, 11.0234375},
			rotation = {0, 0, 359.93344116211},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 149
		}
	},
	[150] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2366.3198242188, 1682.509765625, 11.0234375},
			rotation = {0, 0, 2.4401097297668},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 150
		}
	},
	[151] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2371.3713378906, 1682.4338378906, 11.0234375},
			rotation = {0, 0, 359.62005615234},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 151
		}
	},
	[152] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2376.3762207031, 1682.4602050781, 11.0234375},
			rotation = {0, 0, 1.5000505447388},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 152
		}
	},
	[153] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2381.3068847656, 1682.4948730469, 11.0234375},
			rotation = {0, 0, 1.813351392746},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 153
		}
	},
	[154] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2386.2456054688, 1682.3975830078, 11.0234375},
			rotation = {0, 0, 3.0667181015015},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 154
		}
	},
	[155] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2391.3449707031, 1682.4663085938, 11.0234375},
			rotation = {0, 0, 359.30673217773},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 155
		}
	},
	[156] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2396.3425292969, 1682.3194580078, 11.0234375},
			rotation = {0, 0, 1.1868180036545},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 156
		}
	},
	[157] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2401.2492675781, 1682.4151611328, 11.0234375},
			rotation = {0, 0, 0.24679954349995},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 157
		}
	},
	[158] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2406.3845214844, 1682.4362792969, 11.0234375},
			rotation = {0, 0, 1.1868249177933},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 158
		}
	},
	[159] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2406.28515625, 1682.3983154297, 14.2734375},
			rotation = {0, 0, 0.58359616994858},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 159
		}
	},
	[160] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2401.3254394531, 1682.5715332031, 14.281055450439},
			rotation = {0, 0, 359.01699829102},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 160
		}
	},
	[161] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2396.2724609375, 1682.5599365234, 14.281055450439},
			rotation = {0, 0, 2.077784538269},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 161
		}
	},
	[162] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2391.3908691406, 1682.6484375, 14.281055450439},
			rotation = {0, 0, 359.25772094727},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 162
		}
	},
	[163] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2386.4516601563, 1682.7503662109, 14.281055450439},
			rotation = {0, 0, 358.94442749023},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 163
		}
	},
	[164] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2381.1804199219, 1682.8104248047, 14.281055450439},
			rotation = {0, 0, 355.49771118164},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 164
		}
	},
	[165] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2376.41796875, 1682.7293701172, 14.281055450439},
			rotation = {0, 0, 8.1036691665649},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 165
		}
	},
	[166] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2371.2243652344, 1682.5751953125, 14.281055450439},
			rotation = {0, 0, 0.19765885174274},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 166
		}
	},
	[167] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2366.3461914063, 1682.6513671875, 14.281055450439},
			rotation = {0, 0, 358.07702636719},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 167
		}
	},
	[168] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2361.3032226563, 1682.7136230469, 14.281055450439},
			rotation = {0, 0, 359.95703125},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 168
		}
	},
	[169] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.2189941406, 1679.3240966797, 14.281055450439},
			rotation = {0, 0, 92.68115234375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 169
		}
	},
	[170] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.2744140625, 1674.1585693359, 14.281055450439},
			rotation = {0, 0, 88.848571777344},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 170
		}
	},
	[171] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.0263671875, 1669.1395263672, 14.281055450439},
			rotation = {0, 0, 91.041938781738},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 171
		}
	},
	[172] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.09765625, 1664.2545166016, 14.281055450439},
			rotation = {0, 0, 91.355285644531},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 172
		}
	},
	[173] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.0852050781, 1659.2755126953, 14.281055450439},
			rotation = {0, 0, 88.221969604492},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 173
		}
	},
	[174] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2357.9228515625, 1653.9995117188, 14.281055450439},
			rotation = {0, 0, 89.162040710449},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 174
		}
	},
	[175] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2357.8740234375, 1648.7292480469, 14.281055450439},
			rotation = {0, 0, 84.775375366211},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 175
		}
	},
	[176] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2358.255859375, 1643.279296875, 14.281055450439},
			rotation = {0, 0, 186.68218994141},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 176
		}
	},
	[177] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2363.5471191406, 1642.8664550781, 14.274926185608},
			rotation = {0, 0, 182.29541015625},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 177
		}
	},
	[178] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2368.6389160156, 1642.8033447266, 14.273559570313},
			rotation = {0, 0, 178.22204589844},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 178
		}
	},
	[179] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2373.3898925781, 1643.0034179688, 14.272789955139},
			rotation = {0, 0, 180.72871398926},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 179
		}
	},
	[180] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2498.4479980469, 1643.5795898438, 14.265625},
			rotation = {0, 0, 181.98207092285},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 180
		}
	},
	[181] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2503.5048828125, 1643.5784912109, 14.265625},
			rotation = {0, 0, 179.47540283203},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 181
		}
	},
	[182] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2508.5192871094, 1643.5784912109, 14.265625},
			rotation = {0, 0, 181.35540771484},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 182
		}
	},
	[183] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2513.6301269531, 1643.5784912109, 14.265625},
			rotation = {0, 0, 177.90873718262},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 183
		}
	},
	[184] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.5104980469, 1643.5784912109, 14.265625},
			rotation = {0, 0, 262.82287597656},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 184
		}
	},
	[185] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.5703125, 1648.6015625, 14.265625},
			rotation = {0, 0, 273.13949584961},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 185
		}
	},
	[186] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.6987304688, 1653.8410644531, 14.273241043091},
			rotation = {0, 0, 270.87359619141},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 186
		}
	},
	[187] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.5222167969, 1659.0295410156, 14.273241043091},
			rotation = {0, 0, 271.81362915039},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 187
		}
	},
	[189] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.7121582031, 1664.2961425781, 14.273241043091},
			rotation = {0, 0, 270.94592285156},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 189
		}
	},
	[190] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.7241210938, 1669.2069091797, 14.273241043091},
			rotation = {0, 0, 269.37921142578},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 190
		}
	},
	[191] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.6350097656, 1674.3126220703, 14.273241043091},
			rotation = {0, 0, 266.55908203125},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 191
		}
	},
	[192] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.8076171875, 1679.2652587891, 14.273241043091},
			rotation = {0, 0, 269.6923828125},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 192
		}
	},
	[193] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.3872070313, 1682.3894042969, 14.265625},
			rotation = {0, 0, 357.73983764648},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 193
		}
	},
	[194] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2511.3210449219, 1682.5096435547, 14.265625},
			rotation = {0, 0, 5.8865957260132},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 194
		}
	},
	[195] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2506.4020996094, 1682.3337402344, 14.265625},
			rotation = {0, 0, 1.4998661279678},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 195
		}
	},
	[196] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2501.146484375, 1682.5234375, 14.265625},
			rotation = {0, 0, 346.45971679688},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 196
		}
	},
	[197] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2496.26953125, 1682.5167236328, 14.265625},
			rotation = {0, 0, 359.30648803711},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 197
		}
	},
	[198] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2491.2824707031, 1682.5728759766, 14.265625},
			rotation = {0, 0, 359.30648803711},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 198
		}
	},
	[199] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2486.1726074219, 1682.5821533203, 14.265625},
			rotation = {0, 0, 0.87320989370346},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 199
		}
	},
	[200] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2481.3146972656, 1682.7141113281, 14.265625},
			rotation = {0, 0, 3.6932172775269},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 200
		}
	},
	[201] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2476.2839355469, 1682.7624511719, 14.265625},
			rotation = {0, 0, 356.17324829102},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 201
		}
	},
	[202] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2471.3227539063, 1682.5120849609, 14.265625},
			rotation = {0, 0, 358.67980957031},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 202
		}
	},
	[203] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2466.4094238281, 1682.7661132813, 14.265625},
			rotation = {0, 0, 3.3798277378082},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 203
		}
	},
	[204] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2461.3640136719, 1682.6949462891, 14.265625},
			rotation = {0, 0, 2.4397616386414},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 204
		}
	},
	[206] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2498.5395507813, 1643.5787353516, 11.01566696167},
			rotation = {0, 0, 179.33601379395},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 206
		}
	},
	[207] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2503.4001464844, 1643.5787353516, 11.0234375},
			rotation = {0, 0, 181.5294342041},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 207
		}
	},
	[208] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2508.3127441406, 1643.5787353516, 11.0234375},
			rotation = {0, 0, 181.5294342041},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 208
		}
	},
	[209] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2513.4609375, 1643.5787353516, 11.0234375},
			rotation = {0, 0, 180.27610778809},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 209
		}
	},
	[210] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.3947753906, 1643.5906982422, 11.0234375},
			rotation = {0, 0, 270.20367431641},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 210
		}
	},
	[211] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.4875488281, 1648.6187744141, 11.0234375},
			rotation = {0, 0, 267.69686889648},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 211
		}
	},
	[212] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.521484375, 1653.7320556641, 11.0234375},
			rotation = {0, 0, 272.71029663086},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 212
		}
	},
	[213] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.5405273438, 1659.0561523438, 11.0234375},
			rotation = {0, 0, 271.77020263672},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 213
		}
	},
	[214] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.5363769531, 1664.2867431641, 11.0234375},
			rotation = {0, 0, 273.02349853516},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 214
		}
	},
	[215] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.5026855469, 1669.2149658203, 11.0234375},
			rotation = {0, 0, 270.51684570313},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 215
		}
	},
	[216] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.4489746094, 1674.3214111328, 11.0234375},
			rotation = {0, 0, 269.89010620117},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 216
		}
	},
	[217] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.3559570313, 1679.2878417969, 11.0234375},
			rotation = {0, 0, 268.63668823242},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 217
		}
	},
	[218] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2516.2453613281, 1682.2216796875, 11.0234375},
			rotation = {0, 0, 358.25091552734},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 218
		}
	},
	[219] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2511.216796875, 1682.3393554688, 11.0234375},
			rotation = {0, 0, 358.25091552734},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 219
		}
	},
	[220] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2506.2915039063, 1682.2473144531, 11.0234375},
			rotation = {0, 0, 356.68423461914},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 220
		}
	},
	[221] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2501.1945800781, 1682.427734375, 11.0234375},
			rotation = {0, 0, 356.68432617188},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 221
		}
	},
	[222] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2496.3942871094, 1682.1519775391, 11.0234375},
			rotation = {0, 0, 359.48092651367},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 222
		}
	},
	[223] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2491.3305664063, 1682.2852783203, 11.0234375},
			rotation = {0, 0, 359.16760253906},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 223
		}
	},
	[224] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2486.3759765625, 1682.2873535156, 11.0234375},
			rotation = {0, 0, 0.42096936702728},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 224
		}
	},
	[225] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2481.3640136719, 1682.330078125, 11.0234375},
			rotation = {0, 0, 359.16778564453},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 225
		}
	},
	[226] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2476.4018554688, 1682.3881835938, 11.0234375},
			rotation = {0, 0, 1.0478098392487},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 226
		}
	},
	[227] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2471.2966308594, 1682.1159667969, 11.0234375},
			rotation = {0, 0, 355.72109985352},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 227
		}
	},
	[228] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2466.4436035156, 1682.2796630859, 11.0234375},
			rotation = {0, 0, 1.9878214597702},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 228
		}
	},
	[229] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2461.2150878906, 1682.3405761719, 11.0234375},
			rotation = {0, 0, 358.85452270508},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 229
		}
	},
	[231] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2086.806640625, 2154.2216796875, 10.8203125},
			rotation = {0, 0, 181.55297851563},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 231
		}
	},
	[233] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2085.3725585938, 2154.3005371094, 10.8203125},
			rotation = {0, 0, 181.23962402344},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 233
		}
	},
	[234] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2078.8596191406, 2153.9099121094, 10.8203125},
			rotation = {0, 0, 183.74626159668},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 234
		}
	},
	[235] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2077.2390136719, 2154.0427246094, 10.8203125},
			rotation = {0, 0, 172.15274047852},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 235
		}
	},
	[236] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2070.8901367188, 2154.0419921875, 10.8203125},
			rotation = {0, 0, 179.0461730957},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 236
		}
	},
	[237] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2069.4096679688, 2154.0795898438, 10.8203125},
			rotation = {0, 0, 179.35949707031},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 237
		}
	},
	[238] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2064.8366699219, 2156.3527832031, 10.8203125},
			rotation = {0, 0, 92.275390625},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 238
		}
	},
	[239] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2064.6345214844, 2162.9426269531, 10.8203125},
			rotation = {0, 0, 89.142059326172},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 239
		}
	},
	[240] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2064.6755371094, 2164.2863769531, 10.8203125},
			rotation = {0, 0, 85.695373535156},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 240
		}
	},
	[241] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2064.5661621094, 2170.8757324219, 10.8203125},
			rotation = {0, 0, 94.782188415527},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 241
		}
	},
	[242] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2064.5439453125, 2172.3374023438, 10.8203125},
			rotation = {0, 0, 87.88875579834},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 242
		}
	},
	[243] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2064.4052734375, 2178.9250488281, 10.8203125},
			rotation = {0, 0, 93.552139282227},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 243
		}
	},
	[244] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2064.4104003906, 2180.2512207031, 10.8203125},
			rotation = {0, 0, 91.04541015625},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 244
		}
	},
	[245] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2064.2917480469, 2186.892578125, 10.8203125},
			rotation = {0, 0, 90.418731689453},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 245
		}
	},
	[246] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2066.9050292969, 2188.9753417969, 10.8203125},
			rotation = {0, 0, 359.16799926758},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 246
		}
	},
	[247] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2073.5759277344, 2189.1359863281, 10.8203125},
			rotation = {0, 0, 2.6146895885468},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 247
		}
	},
	[248] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2074.9704589844, 2189.0891113281, 10.8203125},
			rotation = {0, 0, 1.9880058765411},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 248
		}
	},
	[249] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2081.505859375, 2189.265625, 10.8203125},
			rotation = {0, 0, 1.0480147600174},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 249
		}
	},
	[250] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2082.9001464844, 2189.154296875, 10.8203125},
			rotation = {0, 0, 358.85470581055},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 250
		}
	},
	[251] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2089.4626464844, 2189.16796875, 10.8203125},
			rotation = {0, 0, 359.81817626953},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 251
		}
	},
	[252] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2090.9653320313, 2189.1057128906, 10.8203125},
			rotation = {0, 0, 359.5048828125},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 252
		}
	},
	[253] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1400,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2094.7712402344, 2189.1418457031, 10.8203125},
			rotation = {0, 0, 0.4448818564415},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 253
		}
	},
	[254] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-63.297710418701, 1210.1831054688, 19.671812057495},
			rotation = {0, 0, 2.3252739906311},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 254
		}
	},
	[255] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-68.753089904785, 1221.7991943359, 19.669002532959},
			rotation = {0, 0, 270.51748657227},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 255
		}
	},
	[256] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-68.697875976563, 1223.6297607422, 19.657600402832},
			rotation = {0, 0, 272.3974609375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 256
		}
	},
	[257] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-63.308166503906, 1234.5970458984, 19.527515411377},
			rotation = {0, 0, 179.02311706543},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 257
		}
	},
	[258] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-63.368530273438, 1235.0532226563, 22.44026184082},
			rotation = {0, 0, 176.5164642334},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 258
		}
	},
	[261] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-63.426410675049, 1210.5294189453, 22.436527252197},
			rotation = {0, 0, 359.81826782227},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 261
		}
	},
	[263] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-68.331100463867, 1221.9580078125, 22.44026184082},
			rotation = {0, 0, 267.36053466797},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 263
		}
	},
	[264] = {
		name = "Motel szoba",
		gameInterior = 2,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-68.231330871582, 1223.8485107422, 22.44026184082},
			rotation = {0, 0, 269.51583862305},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 264
		}
	},
	[266] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-768.61016845703, 2764.6286621094, 45.855598449707},
			rotation = {0, 0, 0.58018106222153},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 266
		}
	},
	[267] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-767.111328125, 2764.5739746094, 45.855598449707},
			rotation = {0, 0, 357.04895019531},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 267
		}
	},
	[268] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-760.51959228516, 2764.9504394531, 45.855598449707},
			rotation = {0, 0, 4.0474581718445},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 268
		}
	},
	[269] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-759.12310791016, 2764.7009277344, 45.855598449707},
			rotation = {0, 0, 2.4573836326599},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 269
		}
	},
	[270] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-759.16827392578, 2765.15234375, 48.255599975586},
			rotation = {0, 0, 359.95065307617},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 270
		}
	},
	[271] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-760.68731689453, 2765.0991210938, 48.255599975586},
			rotation = {0, 0, 358.98724365234},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 271
		}
	},
	[272] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-767.15087890625, 2765.216796875, 48.255599975586},
			rotation = {0, 0, 359.61395263672},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 272
		}
	},
	[273] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-768.58441162109, 2765.2416992188, 48.255599975586},
			rotation = {0, 0, 359.92727661133},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 273
		}
	},
	[274] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-775.17260742188, 2765.2084960938, 48.255599975586},
			rotation = {0, 0, 357.10726928711},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 274
		}
	},
	[275] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-776.76654052734, 2765.3640136719, 48.255599975586},
			rotation = {0, 0, 357.10720825195},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 275
		}
	},
	[276] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-775.11566162109, 2765.302734375, 45.855598449707},
			rotation = {0, 0, 4.0004663467407},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 276
		}
	},
	[277] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-776.74682617188, 2765.2993164063, 45.855598449707},
			rotation = {0, 0, 358.67370605469},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 277
		}
	},
	[280] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1100,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-789.49945068359, 2765.2133789063, 45.854598999023},
			rotation = {0, 0, 89.831169128418},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 280
		}
	},
	[282] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1100,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-789.57061767578, 2763.7478027344, 45.854598999023},
			rotation = {0, 0, 89.517807006836},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 282
		}
	},
	[283] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1100,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-789.55383300781, 2757.1870117188, 45.854598999023},
			rotation = {0, 0, 89.204429626465},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 283
		}
	},
	[284] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1100,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-789.54162597656, 2755.8327636719, 45.854598999023},
			rotation = {0, 0, 95.784484863281},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 284
		}
	},
	[285] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1100,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-789.56988525391, 2749.0827636719, 45.854598999023},
			rotation = {0, 0, 92.964492797852},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 285
		}
	},
	[286] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1100,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-789.56085205078, 2747.8188476563, 45.854598999023},
			rotation = {0, 0, 94.531188964844},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 286
		}
	},
	[287] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1100,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-789.50231933594, 2747.7097167969, 48.255599975586},
			rotation = {0, 0, 86.674377441406},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 287
		}
	},
	[288] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1100,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-789.45916748047, 2749.1828613281, 48.255599975586},
			rotation = {0, 0, 90.121063232422},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 288
		}
	},
	[289] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1100,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-789.39440917969, 2755.5788574219, 48.255599975586},
			rotation = {0, 0, 86.987686157227},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 289
		}
	},
	[290] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1100,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-789.54162597656, 2757.36328125, 48.255599975586},
			rotation = {0, 0, 86.987655639648},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 290
		}
	},
	[291] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1100,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-789.50860595703, 2765.3706054688, 48.255599975586},
			rotation = {0, 0, 85.397575378418},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 291
		}
	},
	[292] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1100,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-789.42279052734, 2763.8117675781, 48.255599975586},
			rotation = {0, 0, 95.737670898438},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 292
		}
	},
	[293] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1200,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-89.0810546875, 1229.1831054688, 19.7421875},
			rotation = {0, 0, 2.073362827301},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 293
		}
	},
	[294] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1200,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-90.688850402832, 1229.2069091797, 19.7421875},
			rotation = {0, 0, 2.7000460624695},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 294
		}
	},
	[295] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1200,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-90.964584350586, 1229.5576171875, 22.44026184082},
			rotation = {0, 0, 1.4466795921326},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 295
		}
	},
	[296] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1200,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-88.834785461426, 1229.4547119141, 22.44026184082},
			rotation = {0, 0, 2.0732946395874},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 296
		}
	},
	[297] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1200,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-77.567825317383, 1234.4627685547, 22.44026184082},
			rotation = {0, 0, 89.180870056152},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 297
		}
	},
	[298] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1200,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-102.00046539307, 1234.5965576172, 22.44026184082},
			rotation = {0, 0, 262.11911010742},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 298
		}
	},
	[299] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1200,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-77.662422180176, 1234.5783691406, 19.7421875},
			rotation = {0, 0, 96.074371337891},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 299
		}
	},
	[300] = {
		name = "Motel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 1200,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-101.84376525879, 1234.5140380859, 19.7421875},
			rotation = {0, 0, 272.48284912109},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 300
		}
	},
	[301] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-36.079456329346, 1214.3605957031, 19.359375},
			rotation = {0, 0, 357.39715576172},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 301
		}
	},
	[302] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-26.637088775635, 1214.5418701172, 19.359375},
			rotation = {0, 0, 356.45721435547},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 302
		}
	},
	[303] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-17.462732315063, 1214.5477294922, 19.359375},
			rotation = {0, 0, 3.9772915840149},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 303
		}
	},
	[304] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {12.513074874878, 1210.7116699219, 19.341047286987},
			rotation = {0, 0, 272.79638671875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 304
		}
	},
	[305] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {12.959671974182, 1219.9652099609, 19.340284347534},
			rotation = {0, 0, 273.10955810547},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 305
		}
	},
	[306] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {13.290073394775, 1229.2674560547, 19.341890335083},
			rotation = {0, 0, 271.22952270508},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 306
		}
	},
	[307] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {13.309363365173, 1210.5551757813, 22.503162384033},
			rotation = {0, 0, 275.01287841797},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 307
		}
	},
	[308] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {13.408975601196, 1220.0364990234, 22.503162384033},
			rotation = {0, 0, 270.62628173828},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 308
		}
	},
	[309] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {13.315225601196, 1229.2913818359, 22.503162384033},
			rotation = {0, 0, 265.61279296875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 309
		}
	},
	[310] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-17.421497344971, 1214.9771728516, 22.464834213257},
			rotation = {0, 0, 359.59030151367},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 310
		}
	},
	[311] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-26.861755371094, 1214.8018798828, 22.464834213257},
			rotation = {0, 0, 0.21696530282497},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 311
		}
	},
	[312] = {
		name = "Motel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 1300,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-36.269641876221, 1214.8082275391, 22.464834213257},
			rotation = {0, 0, 1.4702779054642},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 312
		}
	},
	[313] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {0.07935144007206, 1185.7878417969, 19.402997970581},
			rotation = {0, 0, 90.434326171875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 313
		}
	},
	[314] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-0.10221416503191, 1178.8138427734, 19.45046043396},
			rotation = {0, 0, 87.300971984863},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 314
		}
	},
	[315] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-0.44479578733444, 1172.0919189453, 19.496152877808},
			rotation = {0, 0, 92.627723693848},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 315
		}
	},
	[316] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-0.39321413636208, 1165.3424072266, 19.547756195068},
			rotation = {0, 0, 89.49437713623},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 316
		}
	},
	[317] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {25.781661987305, 1161.0115966797, 19.641683578491},
			rotation = {0, 0, 272.14605712891},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 317
		}
	},
	[318] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {25.867742538452, 1167.6986083984, 19.523139953613},
			rotation = {0, 0, 271.83279418945},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 318
		}
	},
	[320] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {25.87134552002, 1181.4307861328, 19.259679794312},
			rotation = {0, 0, 272.77270507813},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 320
		}
	},
	[321] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {25.914302825928, 1174.5603027344, 19.390913009644},
			rotation = {0, 0, 271.51940917969},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 321
		}
	},
	[326] = {
		name = "Barbers",
		gameInterior = 103,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1449.8979492188, 2592.4272460938, 55.8359375},
			rotation = {0, 0, 178.19506835938},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {411.98046875, -53.673828125, 1001.8984375},
			rotation = {0, 0, 0},
			interior = 12,
			dimension = 326
		}
	},
	[327] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-813.90313720703, 2753.4934082031, 46},
			rotation = {0, 0, 141.21360778809},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 327
		}
	},
	[328] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-815.82574462891, 2765.5891113281, 46},
			rotation = {0, 0, 49.719429016113},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 328
		}
	},
	[329] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-825.54876708984, 2752.4130859375, 46},
			rotation = {0, 0, 138.39356994629},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 329
		}
	},
	[330] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-827.18322753906, 2764.8767089844, 46},
			rotation = {0, 0, 50.032707214355},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 330
		}
	},
	[331] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-838.70422363281, 2762.2731933594, 46},
			rotation = {0, 0, 50.346061706543},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 331
		}
	},
	[332] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-851.75482177734, 2760.9929199219, 46},
			rotation = {0, 0, 327.62542724609},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 332
		}
	},
	[333] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-865.96850585938, 2749.4028320313, 46},
			rotation = {0, 0, 213.88423156738},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 333
		}
	},
	[334] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-867.49249267578, 2761.7758789063, 46},
			rotation = {0, 0, 319.7685546875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 334
		}
	},
	[335] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-880.30078125, 2760.8869628906, 46},
			rotation = {0, 0, 323.21524047852},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 335
		}
	},
	[336] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-879.23443603516, 2747.9450683594, 46},
			rotation = {0, 0, 214.80082702637},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 336
		}
	},
	[337] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-816.32415771484, 1448.3575439453, 13.9453125},
			rotation = {0, 0, 37.546405792236},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 337
		}
	},
	[338] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-802.72082519531, 1448.3955078125, 13.9453125},
			rotation = {0, 0, 40.993160247803},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 338
		}
	},
	[339] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-788.14880371094, 1448.0969238281, 13.9453125},
			rotation = {0, 0, 33.786487579346},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 339
		}
	},
	[340] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-775.72924804688, 1447.8118896484, 13.9453125},
			rotation = {0, 0, 38.486503601074},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 340
		}
	},
	[341] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-773.6796875, 1425.7652587891, 13.9453125},
			rotation = {0, 0, 228.36833190918},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 341
		}
	},
	[342] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-786.50225830078, 1425.8868408203, 13.9453125},
			rotation = {0, 0, 230.56167602539},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 342
		}
	},
	[343] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-799.54711914063, 1425.7651367188, 13.9453125},
			rotation = {0, 0, 225.5482635498},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 343
		}
	},
	[344] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-814.35522460938, 1425.7424316406, 13.9453125},
			rotation = {0, 0, 231.50161743164},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 344
		}
	},
	[345] = {
		name = "The Smokin Beef",
		gameInterior = 101,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-857.94378662109, 1535.6120605469, 22.587043762207},
			rotation = {0, 0, 145.09715270996},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {501.900390625, -67.828125, 998.7578125},
			rotation = {0, 0, 0},
			interior = 11,
			dimension = 345
		}
	},
	[347] = {
		name = "Four Dragons Casino",
		gameInterior = 91,
		type = "building2",
		price = 6,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2019.8980712891, 1007.716003418, 10.8203125},
			rotation = {0, 0, 92.431823730469},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2018.384765625, 1017.8740234375, 996.875},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 347
		}
	},
	[348] = {
		name = "Cluckin' Bell",
		gameInterior = 93,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1213.5147705078, 1830.7604980469, 41.9296875},
			rotation = {0, 0, 136.54333496094},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {363.0419921875, -74.9619140625, 1001.5078125},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 348
		}
	},
	[349] = {
		name = "Caligula's Casino",
		gameInterior = 5,
		type = "building2",
		price = 6,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2196.6000976563, 1677.2083740234, 12.3671875},
			rotation = {0, 0, 183.20252990723},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.9345703125, 1714.6845703125, 1012.3828125},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 349
		}
	},
	[350] = {
		name = "Luxor",
		gameInterior = 131,
		type = "building2",
		price = 6,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2238.376953125, 1285.7180175781, 10.8203125},
			rotation = {0, 0, 355.15872192383},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {1726.974609375, -1637.888671875, 20.222967147827},
			rotation = {0, 0, 0},
			interior = 18,
			dimension = 350
		}
	},
	[352] = {
		name = "General Store",
		gameInterior = 75,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1531.0161132813, 2592.2670898438, 55.8359375},
			rotation = {0, 0, 178.87930297852},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-27.365234375, -57.5771484375, 1003.546875},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 352
		}
	},
	[354] = {
		name = "El Quebrados ivó",
		gameInterior = 101,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1458.0521240234, 2591.0766601563, 55.984375},
			rotation = {0, 0, 176.33456420898},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {501.900390625, -67.828125, 998.7578125},
			rotation = {0, 0, 0},
			interior = 11,
			dimension = 354
		}
	},
	[356] = {
		name = "Lakókocsi",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1370.5993652344, 2052.5480957031, 52.515625},
			rotation = {0, 0, 312.00067138672},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 356
		}
	},
	[357] = {
		name = "No I Desert",
		gameInterior = 97,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-145.80439758301, 1172.5322265625, 19.7421875},
			rotation = {0, 0, 178.57595825195},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {6.0673828125, -30.60546875, 1003.5494384766},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 357
		}
	},
	[358] = {
		name = "Cluckin' Bell",
		gameInterior = 90,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {172.46417236328, 1176.2459716797, 14.7578125},
			rotation = {0, 0, 327.8957824707},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {364.84655761719, -10.787553787231, 1001.8515625},
			rotation = {0, 0, 176.55450439453},
			interior = 9,
			dimension = 358
		}
	},
	[359] = {
		name = "Burger Shot",
		gameInterior = 93,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1158.4226074219, 2071.9926757813, 11.0625},
			rotation = {0, 0, 83.29606628418},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {363.0419921875, -74.9619140625, 1001.5078125},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 359
		}
	},
	[360] = {
		name = "Burger Shot",
		gameInterior = 93,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1872.7282714844, 2071.7736816406, 11.0625},
			rotation = {0, 0, 90.105949401855},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {363.0419921875, -74.9619140625, 1001.5078125},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 360
		}
	},
	[361] = {
		name = "Burger Shot",
		gameInterior = 93,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2472.2602539063, 2034.0869140625, 11.0625},
			rotation = {0, 0, 274.4573059082},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {363.0419921875, -74.9619140625, 1001.5078125},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 361
		}
	},
	[362] = {
		name = "General Store",
		gameInterior = 48,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2810.9248046875, 1987.1705322266, 10.8203125},
			rotation = {0, 0, 359.64712524414},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-27.0751953125, -31.7607421875, 1003.5572509766},
			rotation = {0, 0, 0},
			interior = 4,
			dimension = 362
		}
	},
	[363] = {
		name = "24/7",
		gameInterior = 75,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2546.3356933594, 1972.0675048828, 10.8203125},
			rotation = {0, 0, 2.1070833206177},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-27.365234375, -57.5771484375, 1003.546875},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 363
		}
	},
	[364] = {
		name = "Lakóház",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1426.8828125, 2171.2312011719, 50.625},
			rotation = {0, 0, 27.792678833008},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 364
		}
	},
	[365] = {
		name = "Lakókocsi",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-766.38073730469, 1613.7104492188, 27.273302078247},
			rotation = {0, 0, 178.46063232422},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 365
		}
	},
	[368] = {
		name = "Lakókocsi",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-761.61242675781, 1613.623046875, 27.1171875},
			rotation = {0, 0, 177.20722961426},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 368
		}
	},
	[369] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {98.392402648926, 1179.6499023438, 18.6640625},
			rotation = {0, 0, 269.53302001953},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 369
		}
	},
	[370] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {98.437408447266, 1178.2698974609, 18.6640625},
			rotation = {0, 0, 272.9563293457},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 370
		}
	},
	[371] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {98.506393432617, 1171.4689941406, 18.6640625},
			rotation = {0, 0, 275.14971923828},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 371
		}
	},
	[372] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {98.513038635254, 1170.2526855469, 18.6640625},
			rotation = {0, 0, 271.07641601563},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 372
		}
	},
	[373] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {98.544906616211, 1163.8083496094, 18.6640625},
			rotation = {0, 0, 267.00311279297},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 373
		}
	},
	[374] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {98.76651763916, 1161.9519042969, 18.6640625},
			rotation = {0, 0, 280.16323852539},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 374
		}
	},
	[379] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {98.902587890625, 1163.720703125, 20.940155029297},
			rotation = {0, 0, 265.12313842773},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 379
		}
	},
	[380] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {98.794815063477, 1162.2747802734, 20.940155029297},
			rotation = {0, 0, 270.11297607422},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 380
		}
	},
	[381] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {98.960304260254, 1170.1727294922, 20.940155029297},
			rotation = {0, 0, 269.48638916016},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 381
		}
	},
	[382] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {99.081436157227, 1171.5694580078, 20.940155029297},
			rotation = {0, 0, 268.23303222656},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 382
		}
	},
	[383] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {99.104393005371, 1178.1680908203, 20.940155029297},
			rotation = {0, 0, 273.55969238281},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 383
		}
	},
	[385] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {99.152229309082, 1179.7529296875, 20.940155029297},
			rotation = {0, 0, 270.73959350586},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 385
		}
	},
	[386] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {86.158340454102, 1162.2684326172, 18.6640625},
			rotation = {0, 0, 183.31886291504},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 386
		}
	},
	[387] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {84.653846740723, 1162.1470947266, 18.6640625},
			rotation = {0, 0, 190.13973999023},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 387
		}
	},
	[388] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {78.172874450684, 1162.267578125, 18.6640625},
			rotation = {0, 0, 187.39215087891},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 388
		}
	},
	[389] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {76.667144775391, 1162.1463623047, 18.6640625},
			rotation = {0, 0, 177.05206298828},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 389
		}
	},
	[390] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {70.258056640625, 1162.3275146484, 18.6640625},
			rotation = {0, 0, 180.49877929688},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 390
		}
	},
	[391] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {68.839538574219, 1162.2976074219, 18.6640625},
			rotation = {0, 0, 189.58544921875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 391
		}
	},
	[392] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {68.878601074219, 1162.0943603516, 20.940155029297},
			rotation = {0, 0, 183.31872558594},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 392
		}
	},
	[393] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {70.38525390625, 1162.0158691406, 20.940155029297},
			rotation = {0, 0, 184.9580078125},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 393
		}
	},
	[394] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {76.959648132324, 1162.0555419922, 20.940155029297},
			rotation = {0, 0, 179.2453918457},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 394
		}
	},
	[395] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {78.384605407715, 1162.0698242188, 20.940155029297},
			rotation = {0, 0, 183.63217163086},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 395
		}
	},
	[396] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {84.769515991211, 1162.0523681641, 20.940155029297},
			rotation = {0, 0, 180.81219482422},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 396
		}
	},
	[397] = {
		name = "Motel szoba",
		gameInterior = 6,
		type = "rentable",
		price = 800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {86.081047058105, 1162.0263671875, 20.940155029297},
			rotation = {0, 0, 185.19891357422},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {244.0892, 304.8456, 999.1484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 397
		}
	},
	[398] = {
		name = "Fort Carson 1",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-121.01838684082, 857.95965576172, 18.582431793213},
			rotation = {0, 0, 172.65129089355},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 398
		}
	},
	[399] = {
		name = "Fort Carson 2",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-152.33187866211, 881.59680175781, 18.445621490479},
			rotation = {0, 0, 89.280403137207},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 399
		}
	},
	[400] = {
		name = "Fort Carson 4",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-123.06343078613, 875.27624511719, 18.730869293213},
			rotation = {0, 0, 173.25459289551},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 400
		}
	},
	[401] = {
		name = "Fort Carson 3",
		gameInterior = 18,
		type = "house",
		price = 92000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-92.115783691406, 887.14349365234, 21.254306793213},
			rotation = {0, 0, 236.83847045898},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 401
		}
	},
	[402] = {
		name = "Fort Carson 5",
		gameInterior = 18,
		type = "house",
		price = 93000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-153.35192871094, 906.66870117188, 19.301181793213},
			rotation = {0, 0, 3.0662879943848},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 402
		}
	},
	[403] = {
		name = "Fort Carson 6",
		gameInterior = 23,
		type = "house",
		price = 120000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-124.22336578369, 917.36053466797, 19.901124954224},
			rotation = {0, 0, 294.75891113281},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {447.47, 1398.348, 1084.305},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 403
		}
	},
	[404] = {
		name = "Fort Carson 7",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-86.833671569824, 915.69476318359, 21.099603652954},
			rotation = {0, 0, 273.71868896484},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 404
		}
	},
	[405] = {
		name = "Fort Carson 8",
		gameInterior = 18,
		type = "house",
		price = 92000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-52.915115356445, 894.76068115234, 22.387119293213},
			rotation = {0, 0, 184.12789916992},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 405
		}
	},
	[406] = {
		name = "Fort Carson 9",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-83.049125671387, 932.41436767578, 20.698162078857},
			rotation = {0, 0, 2.1262693405151},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 406
		}
	},
	[407] = {
		name = "Fort Carson 10",
		gameInterior = 18,
		type = "house",
		price = 97000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-54.744617462158, 919.18237304688, 22.371494293213},
			rotation = {0, 0, 189.47802734375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 407
		}
	},
	[408] = {
		name = "Fort Carson 11",
		gameInterior = 18,
		type = "house",
		price = 91000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-56.708316802979, 935.73754882813, 21.207431793213},
			rotation = {0, 0, 185.09133911133},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 408
		}
	},
	[409] = {
		name = "Fort Carson 12",
		gameInterior = 18,
		type = "house",
		price = 92500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-15.484088897705, 933.88482666016, 21.105869293213},
			rotation = {0, 0, 359.65249633789},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 409
		}
	},
	[410] = {
		name = "Fort Carson 13",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {17.725999832153, 909.64392089844, 23.918962478638},
			rotation = {0, 0, 191.05422973633},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 410
		}
	},
	[411] = {
		name = "Fort Carson 14",
		gameInterior = 18,
		type = "house",
		price = 91000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {31.780309677124, 923.84606933594, 23.598424911499},
			rotation = {0, 0, 101.75343322754},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 411
		}
	},
	[412] = {
		name = "Fort Carson 15",
		gameInterior = 18,
		type = "house",
		price = 93000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {20.652338027954, 949.20935058594, 20.316806793213},
			rotation = {0, 0, 180.98071289063},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 412
		}
	},
	[413] = {
		name = "Fort Carson 16",
		gameInterior = 18,
		type = "house",
		price = 93000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-4.1358313560486, 951.32775878906, 19.703125},
			rotation = {0, 0, 177.22064208984},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 413
		}
	},
	[414] = {
		name = "Fort Carson 17",
		gameInterior = 18,
		type = "house",
		price = 91000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-11.896862030029, 975.02581787109, 19.80278968811},
			rotation = {0, 0, 92.306503295898},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 414
		}
	},
	[415] = {
		name = "Fort Carson 18",
		gameInterior = 18,
		type = "house",
		price = 93000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {22.807985305786, 968.78430175781, 19.816402435303},
			rotation = {0, 0, 176.59396362305},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 415
		}
	},
	[416] = {
		name = "Fort Carson 19",
		gameInterior = 18,
		type = "house",
		price = 93000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-37.244903564453, 962.32287597656, 20.051181793213},
			rotation = {0, 0, 87.293151855469},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 416
		}
	},
	[417] = {
		name = "Fort Carson 20",
		gameInterior = 18,
		type = "house",
		price = 91000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-67.1142578125, 971.49597167969, 19.888328552246},
			rotation = {0, 0, 272.78826904297},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 417
		}
	},
	[418] = {
		name = "Fort Carson 21",
		gameInterior = 18,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-92.564018249512, 970.28387451172, 19.974182128906},
			rotation = {0, 0, 183.19750976563},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 418
		}
	},
	[419] = {
		name = "Fort Carson 22",
		gameInterior = 18,
		type = "house",
		price = 94000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-127.04960632324, 974.56530761719, 19.8515625},
			rotation = {0, 0, 89.509910583496},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 419
		}
	},
	[420] = {
		name = "Fort Carson 23",
		gameInterior = 18,
		type = "house",
		price = 94000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-150.88647460938, 933.69805908203, 19.723056793213},
			rotation = {0, 0, 10.54917049408},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 420
		}
	},
	[421] = {
		name = "Fort Carson 24",
		gameInterior = 18,
		type = "house",
		price = 92000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {70.337440490723, 973.41265869141, 15.824726104736},
			rotation = {0, 0, 357.07577514648},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 421
		}
	},
	[422] = {
		name = "Fort Carson 25",
		gameInterior = 18,
		type = "house",
		price = 91000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {64.918472290039, 1005.6228637695, 13.735394477844},
			rotation = {0, 0, 185.68077087402},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 422
		}
	},
	[423] = {
		name = "Fort Carson 40",
		gameInterior = 2,
		type = "house",
		price = 150000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-32.079246520996, 1038.0174560547, 20.939867019653},
			rotation = {0, 0, 12.724168777466},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {223.125, 1287.0751953125, 1082.140625},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 423
		}
	},
	[424] = {
		name = "Las Barrancas 1",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-886.39343261719, 1514.5562744141, 25.9140625},
			rotation = {0, 0, 167.75093078613},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 424
		}
	},
	[425] = {
		name = "Las Barrancas 2",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-881.73657226563, 1532.091796875, 25.9140625},
			rotation = {0, 0, 180.83076477051},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 425
		}
	},
	[426] = {
		name = "Las Barrancas 3",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-884.24920654297, 1537.9379882813, 25.9140625},
			rotation = {0, 0, 13.260468482971},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 426
		}
	},
	[427] = {
		name = "Las Barrancas 4",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-884.05871582031, 1553.0880126953, 25.9140625},
			rotation = {0, 0, 16.213256835938},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 427
		}
	},
	[428] = {
		name = "Las Barrancas 5",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-881.45935058594, 1562.0725097656, 25.9140625},
			rotation = {0, 0, 358.55807495117},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 428
		}
	},
	[429] = {
		name = "Las Barrancas 6",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-906.12512207031, 1514.5340576172, 26.316806793213},
			rotation = {0, 0, 74.812347412109},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 429
		}
	},
	[430] = {
		name = "Las Barrancas 7",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-905.31884765625, 1528.1246337891, 25.9140625},
			rotation = {0, 0, 9.0950355529785},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 430
		}
	},
	[431] = {
		name = "Las Barrancas 8",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-905.65405273438, 1543.2557373047, 25.9140625},
			rotation = {0, 0, 183.66221618652},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 431
		}
	},
	[432] = {
		name = "Las Barrancas 9",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-939.11962890625, 1425.2574462891, 30.433994293213},
			rotation = {0, 0, 88.508094787598},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 432
		}
	},
	[433] = {
		name = "Las Barrancas 10",
		gameInterior = 52,
		type = "house",
		price = 150000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1051.2863769531, 1549.4659423828, 33.437610626221},
			rotation = {0, 0, 37.670162200928},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {261.01953125, 1284.294921875, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 4,
			dimension = 433
		}
	},
	[434] = {
		name = "Las Barrancas 11",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-743.212890625, 1432.1923828125, 16.0888671875},
			rotation = {0, 0, 326.10733032227},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 434
		}
	},
	[435] = {
		name = "Las Barrancas 12",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-715.81915283203, 1438.6569824219, 18.887119293213},
			rotation = {0, 0, 358.25726318359},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 435
		}
	},
	[436] = {
		name = "Las Barrancas 13",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-689.81878662109, 1444.2569580078, 17.808994293213},
			rotation = {0, 0, 166.86227416992},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 436
		}
	},
	[437] = {
		name = "Las Barrancas 14",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-658.01599121094, 1447.0026855469, 13.6171875},
			rotation = {0, 0, 88.80583190918},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 437
		}
	},
	[438] = {
		name = "Las Barrancas 15",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-650.67822265625, 1450.4796142578, 13.6171875},
			rotation = {0, 0, 264.05331420898},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 438
		}
	},
	[439] = {
		name = "Las Barrancas 16",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-636.51257324219, 1446.6796875, 13.996495246887},
			rotation = {0, 0, 131.96853637695},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 439
		}
	},
	[440] = {
		name = "Las Payasdas 1",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-150.15376281738, 2688.4157714844, 62.4296875},
			rotation = {0, 0, 180.6512298584},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 440
		}
	},
	[441] = {
		name = "Las Payasdas 2",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-168.83755493164, 2707.2790527344, 62.533241271973},
			rotation = {0, 0, 285.39904785156},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 441
		}
	},
	[442] = {
		name = "Las Payasdas 3",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-161.33293151855, 2728.0864257813, 62.203762054443},
			rotation = {0, 0, 98.106185913086},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 442
		}
	},
	[443] = {
		name = "Las Payasdas 4",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-155.54138183594, 2758.7238769531, 62.635429382324},
			rotation = {0, 0, 325.87454223633},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 443
		}
	},
	[444] = {
		name = "Las Payasdas 5",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-165.31492614746, 2763.56640625, 62.6875},
			rotation = {0, 0, 91.286544799805},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 444
		}
	},
	[445] = {
		name = "Las Payasdas 6",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-201.6685333252, 2771.9270019531, 62.345779418945},
			rotation = {0, 0, 174.98307800293},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 445
		}
	},
	[446] = {
		name = "Las Payasdas 7",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-219.65364074707, 2767.3305664063, 62.6875},
			rotation = {0, 0, 108.86626434326},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 446
		}
	},
	[447] = {
		name = "Las Payasdas 8",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-232.67041015625, 2807.5708007813, 62.0546875},
			rotation = {0, 0, 274.9762878418},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 447
		}
	},
	[448] = {
		name = "Las Payasdas 9",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-258.09585571289, 2782.4050292969, 62.6875},
			rotation = {0, 0, 354.12780761719},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 448
		}
	},
	[449] = {
		name = "Las Payasdas 10",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-268.92138671875, 2769.4426269531, 61.867115020752},
			rotation = {0, 0, 269.83938598633},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 449
		}
	},
	[450] = {
		name = "Las Payasdas 11",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-287.64178466797, 2758.0361328125, 62.512119293213},
			rotation = {0, 0, 89.426742553711},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 450
		}
	},
	[451] = {
		name = "Las Payasdas 12",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-275.2795715332, 2736.2651367188, 62.754306793213},
			rotation = {0, 0, 18.334941864014},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 451
		}
	},
	[452] = {
		name = "Las Payasdas 13",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-279.27874755859, 2721.8913574219, 62.790626525879},
			rotation = {0, 0, 159.04106140137},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 452
		}
	},
	[453] = {
		name = "Las Payasdas 14",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-311.26803588867, 2726.8596191406, 63.072341918945},
			rotation = {0, 0, 277.84066772461},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 453
		}
	},
	[454] = {
		name = "Junk Yard",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {370.5615234375, 2615.2260742188, 16.484375},
			rotation = {0, 0, 36.858291625977},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 454
		}
	},
	[455] = {
		name = "Fort Carson 30",
		gameInterior = 52,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-247.75364685059, 1001.7393188477, 20.939865112305},
			rotation = {0, 0, 178.16062927246},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {261.13940429688, 1284.9796142578, 1080.2578125},
			rotation = {0, 0, 183.44050598145},
			interior = 4,
			dimension = 455
		}
	},
	[456] = {
		name = "Fort Carson 31",
		gameInterior = 60,
		type = "house",
		price = 150000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-279.0446472168, 1003.4526367188, 20.939867019653},
			rotation = {0, 0, 182.79043579102},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 456
		}
	},
	[458] = {
		name = "Fort Carson 32",
		gameInterior = 60,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-362.58648681641, 1110.6009521484, 20.939865112305},
			rotation = {0, 0, 84.41227722168},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 458
		}
	},
	[460] = {
		name = "Valle Ocultado 1",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-582.96563720703, 2712.7976074219, 71.822547912598},
			rotation = {0, 0, 282.73452758789},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 460
		}
	},
	[461] = {
		name = "Valle Ocultado 2",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-604.28527832031, 2716.6208496094, 72.72306060791},
			rotation = {0, 0, 290.23458862305},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 461
		}
	},
	[462] = {
		name = "Valle Ocultado 3",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-624.55242919922, 2709.9270019531, 72.375},
			rotation = {0, 0, 290.14605712891},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 462
		}
	},
	[463] = {
		name = "Fort Carson 33",
		gameInterior = 89,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-360.67758178711, 1141.6619873047, 20.939867019653},
			rotation = {0, 0, 87.868591308594},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {260.642578125, 1237.58203125, 1084.2578125},
			rotation = {0, 0, 0},
			interior = 9,
			dimension = 463
		}
	},
	[464] = {
		name = "Valle Ocultado 4",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-673.14227294922, 2705.8259277344, 70.663284301758},
			rotation = {0, 0, 154.37135314941},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 464
		}
	},
	[466] = {
		name = "Fort Carson 35",
		gameInterior = 120,
		type = "house",
		price = 180000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-324.43609619141, 1165.1158447266, 20.939863204956},
			rotation = {0, 0, 357.26751708984},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {294.990234375, 1472.7744140625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 466
		}
	},
	[467] = {
		name = "El Quebrados 1",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1450.6716308594, 2690.8869628906, 56.176181793213},
			rotation = {0, 0, 286.75927734375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 467
		}
	},
	[468] = {
		name = "El Quebrados 2",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1466.3072509766, 2693.1325683594, 56.269931793213},
			rotation = {0, 0, 179.28314208984},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 468
		}
	},
	[469] = {
		name = "El Quebrados 3",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1482.5659179688, 2702.5229492188, 56.254306793213},
			rotation = {0, 0, 76.648208618164},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 469
		}
	},
	[470] = {
		name = "Fort Carson 36",
		gameInterior = 80,
		type = "house",
		price = 170000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-290.63619995117, 1176.7801513672, 20.939867019653},
			rotation = {0, 0, 86.834930419922},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-68.701171875, 1351.806640625, 1080.2109375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 470
		}
	},
	[471] = {
		name = "El Quebrados 4",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1491.5496826172, 2685.7038574219, 55.859375},
			rotation = {0, 0, 351.38555908203},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 471
		}
	},
	[472] = {
		name = "El Quebrados 5",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1511.8773193359, 2695.6267089844, 56.072341918945},
			rotation = {0, 0, 1.8365669250488},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 472
		}
	},
	[473] = {
		name = "El Quebrados 6",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1529.4722900391, 2686.2138671875, 55.8359375},
			rotation = {0, 0, 92.087173461914},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 473
		}
	},
	[474] = {
		name = "El Quebrados 7",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1550.7060546875, 2699.7609863281, 56.269931793213},
			rotation = {0, 0, 346.24868774414},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 474
		}
	},
	[475] = {
		name = "El Quebrados 8",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1564.5391845703, 2712.0563964844, 55.859375},
			rotation = {0, 0, 92.795761108398},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 475
		}
	},
	[476] = {
		name = "El Quebrados 9",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1577.6218261719, 2686.6245117188, 55.8359375},
			rotation = {0, 0, 353.98226928711},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 476
		}
	},
	[477] = {
		name = "Fort Carson 37",
		gameInterior = 96,
		type = "house",
		price = 170000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-259.10968017578, 1168.888671875, 20.939863204956},
			rotation = {0, 0, 269.48657226563},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 477
		}
	},
	[478] = {
		name = "El Quebrados 10",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1589.8752441406, 2706.1240234375, 56.176181793213},
			rotation = {0, 0, 359.29638671875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 478
		}
	},
	[479] = {
		name = "El Quebrados 11",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1603.9912109375, 2689.4841308594, 55.285556793213},
			rotation = {0, 0, 357.76989746094},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 479
		}
	},
	[480] = {
		name = "Fort Carson 38",
		gameInterior = 120,
		type = "house",
		price = 170000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-258.55679321289, 1151.0810546875, 20.939865112305},
			rotation = {0, 0, 272.93334960938},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {294.990234375, 1472.7744140625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 480
		}
	},
	[481] = {
		name = "El Quebrados 12",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1587.4105224609, 2650.2104492188, 55.859375},
			rotation = {0, 0, 236.56970214844},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 481
		}
	},
	[482] = {
		name = "El Quebrados 13",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1563.4178466797, 2651.0812988281, 55.923439025879},
			rotation = {0, 0, 66.459136962891},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 482
		}
	},
	[483] = {
		name = "El Quebrados 14",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1568.1486816406, 2630.0046386719, 55.8359375},
			rotation = {0, 0, 5.6130805015564},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 483
		}
	},
	[484] = {
		name = "Fort Carson 39",
		gameInterior = 96,
		type = "house",
		price = 150000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-260.46365356445, 1120.0069580078, 20.939867019653},
			rotation = {0, 0, 271.99334716797},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 484
		}
	},
	[485] = {
		name = "El Quebrados 15",
		gameInterior = 52,
		type = "house",
		price = 100000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1532.7244873047, 2656.6115722656, 56.281360626221},
			rotation = {0, 0, 268.36563110352},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {261.01953125, 1284.294921875, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 4,
			dimension = 485
		}
	},
	[486] = {
		name = "El Quebrados 16",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1512.7896728516, 2646.7607421875, 56.176181793213},
			rotation = {0, 0, 283.15643310547},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 486
		}
	},
	[487] = {
		name = "El Quebrados 17",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1459.4710693359, 2653.4260253906, 55.8359375},
			rotation = {0, 0, 88.423965454102},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 487
		}
	},
	[488] = {
		name = "Fort Carson 40",
		gameInterior = 80,
		type = "house",
		price = 150000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-328.63726806641, 1118.8011474609, 20.939863204956},
			rotation = {0, 0, 281.94976806641},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-68.701171875, 1351.806640625, 1080.2109375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 488
		}
	},
	[489] = {
		name = "El Quebrados 18",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1444.9862060547, 2653.07421875, 56.269931793213},
			rotation = {0, 0, 170.55448913574},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 489
		}
	},
	[490] = {
		name = "El Quebrados 19",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1446.6594238281, 2637.1608886719, 56.254306793213},
			rotation = {0, 0, 358.0244140625},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 490
		}
	},
	[491] = {
		name = "Fort Carson 41",
		gameInterior = 71,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-298.25933837891, 1115.1075439453, 20.939865112305},
			rotation = {0, 0, 4.287061214447},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 491
		}
	},
	[492] = {
		name = "El Quebrados 20",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1476.2341308594, 2563.0043945313, 56.176181793213},
			rotation = {0, 0, 348.72479248047},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 492
		}
	},
	[493] = {
		name = "El Quebrados 21",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1478.8125, 2547.1970214844, 56.254306793213},
			rotation = {0, 0, 155.35108947754},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 493
		}
	},
	[494] = {
		name = "El Quebrados 22",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1450.0373535156, 2562.5783691406, 55.8359375},
			rotation = {0, 0, 190.98547363281},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 494
		}
	},
	[495] = {
		name = "El Quebrados 23",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1669.5083007813, 2597.8815917969, 81.4453125},
			rotation = {0, 0, 162.14054870605},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 495
		}
	},
	[496] = {
		name = "Fort Carson 42",
		gameInterior = 71,
		type = "house",
		price = 170000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-258.7780456543, 1083.912109375, 20.939867019653},
			rotation = {0, 0, 177.51507568359},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 496
		}
	},
	[497] = {
		name = "El Quebrados 24",
		gameInterior = 73,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1670.1524658203, 2546.2387695313, 85.237335205078},
			rotation = {0, 0, 296.23223876953},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 497
		}
	},
	[498] = {
		name = "Fort Carson 43",
		gameInterior = 60,
		type = "house",
		price = 165000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-258.84732055664, 1043.8371582031, 20.939863204956},
			rotation = {0, 0, 264.62265014648},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 498
		}
	},
	[499] = {
		name = "Fort Carson 50",
		gameInterior = 23,
		type = "house",
		price = 175000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-36.175899505615, 1115.2567138672, 20.939863204956},
			rotation = {0, 0, 359.8303527832},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {447.21826171875, 1397.8334960938, 1084.3046875},
			rotation = {0, 0, 180.3120880127},
			interior = 2,
			dimension = 499
		}
	},
	[500] = {
		name = "Fort Carson 51",
		gameInterior = 72,
		type = "house",
		price = 185000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-18.368272781372, 1115.5970458984, 20.939865112305},
			rotation = {0, 0, 0.14368417859077},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 500
		}
	},
	[501] = {
		name = "Fort Carson 52",
		gameInterior = 23,
		type = "house",
		price = 175000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {12.787519454956, 1112.9451904297, 20.939867019653},
			rotation = {0, 0, 6.7004809379578},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {447.47, 1398.348, 1084.305},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 501
		}
	},
	[502] = {
		name = "Fort Carson 53",
		gameInterior = 80,
		type = "house",
		price = 170000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1.5275647640228, 1075.9460449219, 20.939865112305},
			rotation = {0, 0, 276.79641723633},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-68.701171875, 1351.806640625, 1080.2109375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 502
		}
	},
	[503] = {
		name = "Fort Carson 54",
		gameInterior = 80,
		type = "house",
		price = 170000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-45.098152160645, 1081.3516845703, 20.939863204956},
			rotation = {0, 0, 179.95205688477},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-68.701171875, 1351.806640625, 1080.2109375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 503
		}
	},
	[507] = {
		name = "Fort Carson 60",
		gameInterior = 52,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {510.56311035156, 1116.2908935547, 14.937091827393},
			rotation = {0, 0, 183.68846130371},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {261.01953125, 1284.294921875, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 4,
			dimension = 507
		}
	},
	[508] = {
		name = "Fort Carson 61",
		gameInterior = 73,
		type = "house",
		price = 125000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {501.6123046875, 1116.2574462891, 15.035557746887},
			rotation = {0, 0, 83.374046325684},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 508
		}
	},
	[509] = {
		name = "Fort Carson 62",
		gameInterior = 73,
		type = "house",
		price = 135000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {710.33795166016, 1194.7164306641, 13.396438598633},
			rotation = {0, 0, 88.317306518555},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 509
		}
	},
	[510] = {
		name = "Fort Carson 63",
		gameInterior = 73,
		type = "house",
		price = 145000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {710.2431640625, 1207.2619628906, 13.848057746887},
			rotation = {0, 0, 357.76312255859},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 510
		}
	},
	[511] = {
		name = "Fort Carson 64",
		gameInterior = 73,
		type = "house",
		price = 155000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {397.70846557617, 1157.5805664063, 8.3480567932129},
			rotation = {0, 0, 84.847183227539},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2308.6064453125, -1212.41796875, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 511
		}
	},
	[512] = {
		name = "Fort Carson 65",
		gameInterior = 71,
		type = "house",
		price = 165000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {300.51831054688, 1141.3367919922, 9.1374855041504},
			rotation = {0, 0, 96.127296447754},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 512
		}
	},
	[515] = {
		name = "Bone County- St. Ivan.1",
		gameInterior = 18,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {750.92047119141, 1958.4442138672, 5.3359375},
			rotation = {0, 0, 352.14343261719},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 515
		}
	},
	[516] = {
		name = "Bone County- St.Ivan.2",
		gameInterior = 18,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {782.83703613281, 1938.3157958984, 5.4824142456055},
			rotation = {0, 0, 178.24182128906},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 516
		}
	},
	[517] = {
		name = "Bone County- St.Ivan.3",
		gameInterior = 18,
		type = "house",
		price = 110000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {784.11657714844, 1953.7288818359, 5.70743227005},
			rotation = {0, 0, 343.99673461914},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 517
		}
	},
	[518] = {
		name = "Bone County- St.Ivan.4",
		gameInterior = 18,
		type = "house",
		price = 110000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {753.51208496094, 1972.6645507813, 5.69961977005},
			rotation = {0, 0, 354.02349853516},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 518
		}
	},
	[519] = {
		name = "Bone County- St.Ivan.5",
		gameInterior = 18,
		type = "house",
		price = 110000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {790.1181640625, 1974.4173583984, 5.73868227005},
			rotation = {0, 0, 185.76187133789},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 519
		}
	},
	[520] = {
		name = "Bone County- St.Ivan.7",
		gameInterior = 18,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {767.77593994141, 1989.2900390625, 5.3359375},
			rotation = {0, 0, 64.21076965332},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 520
		}
	},
	[521] = {
		name = "Bone County- St.Ivan.6",
		gameInterior = 18,
		type = "house",
		price = 110000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {793.0732421875, 1991.2238769531, 5.79336977005},
			rotation = {0, 0, 322.37637329102},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 521
		}
	},
	[522] = {
		name = "Bone County- St.Ivan.8",
		gameInterior = 18,
		type = "house",
		price = 110000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {767.54925537109, 2007.0229492188, 6.06680727005},
			rotation = {0, 0, 356.8200378418},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 522
		}
	},
	[526] = {
		name = "Bayside Marina 1",
		gameInterior = 24,
		type = "house",
		price = 210000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2349.1892089844, 2422.4643554688, 7.3320684432983},
			rotation = {0, 0, 323.38665771484},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 526
		}
	},
	[527] = {
		name = "Bayside Marina 2",
		gameInterior = 24,
		type = "house",
		price = 205000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2379.3940429688, 2444.5659179688, 10.169355392456},
			rotation = {0, 0, 344.01989746094},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 527
		}
	},
	[528] = {
		name = "Bayside Marina 3",
		gameInterior = 24,
		type = "house",
		price = 205000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2386.4548339844, 2447.3046875, 10.169355392456},
			rotation = {0, 0, 337.7532043457},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 528
		}
	},
	[529] = {
		name = "Bayside Marina 4",
		gameInterior = 24,
		type = "house",
		price = 235000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2424.8310546875, 2447.7553710938, 13.184839248657},
			rotation = {0, 0, 0.29007562994957},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 529
		}
	},
	[530] = {
		name = "Bayside Marina 5",
		gameInterior = 24,
		type = "house",
		price = 235000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2472.4289550781, 2450.9267578125, 17.323022842407},
			rotation = {0, 0, 11.883563041687},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 530
		}
	},
	[531] = {
		name = "Bayside Marina 6",
		gameInterior = 24,
		type = "house",
		price = 235000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2479.806640625, 2449.3771972656, 17.323022842407},
			rotation = {0, 0, 8.7502059936523},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 531
		}
	},
	[532] = {
		name = "Bayside Marina 7",
		gameInterior = 24,
		type = "house",
		price = 235000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2634.8559570313, 2402.3559570313, 11.250295639038},
			rotation = {0, 0, 175.75836181641},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 532
		}
	},
	[533] = {
		name = "Bayside Marina 8",
		gameInterior = 24,
		type = "house",
		price = 235000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2632.3994140625, 2375.5708007813, 9.0294055938721},
			rotation = {0, 0, 174.818359375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 533
		}
	},
	[534] = {
		name = "Bayside Marina 9",
		gameInterior = 24,
		type = "house",
		price = 235000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2636.4143066406, 2351.677734375, 8.5133724212646},
			rotation = {0, 0, 179.8317565918},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 534
		}
	},
	[535] = {
		name = "Bayside Marina 10",
		gameInterior = 24,
		type = "house",
		price = 225000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2597.5747070313, 2364.6430664063, 9.8829956054688},
			rotation = {0, 0, 271.32595825195},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 535
		}
	},
	[536] = {
		name = "Bayside Marina 11",
		gameInterior = 24,
		type = "house",
		price = 225000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2597.6066894531, 2357.0490722656, 9.8829956054688},
			rotation = {0, 0, 271.01281738281},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 536
		}
	},
	[537] = {
		name = "Bayside Marina 12",
		gameInterior = 24,
		type = "house",
		price = 215000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2626.9362792969, 2318.7797851563, 8.309232711792},
			rotation = {0, 0, 92.411140441895},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 537
		}
	},
	[538] = {
		name = "Bayside Marina 13",
		gameInterior = 24,
		type = "house",
		price = 225000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2627.3356933594, 2310.0756835938, 8.3124504089355},
			rotation = {0, 0, 91.15779876709},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 538
		}
	},
	[539] = {
		name = "Bayside Marina 14",
		gameInterior = 24,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2627.3803710938, 2291.9221191406, 8.3128108978271},
			rotation = {0, 0, 89.90446472168},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 539
		}
	},
	[540] = {
		name = "Bayside Marina 15",
		gameInterior = 24,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2627.111328125, 2283.2482910156, 8.3106422424316},
			rotation = {0, 0, 85.831100463867},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 540
		}
	},
	[541] = {
		name = "Bayside Marina 16",
		gameInterior = 88,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2583.1604003906, 2307.865234375, 7.0028858184814},
			rotation = {0, 0, 93.014541625977},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {82.8525390625, 1322.6796875, 1083.8662109375},
			rotation = {0, 0, 0},
			interior = 9,
			dimension = 541
		}
	},
	[542] = {
		name = "Bayside Marina 17",
		gameInterior = 88,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2582.89453125, 2300.2939453125, 7.0028858184814},
			rotation = {0, 0, 93.641235351563},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {82.8525390625, 1322.6796875, 1083.8662109375},
			rotation = {0, 0, 0},
			interior = 9,
			dimension = 542
		}
	},
	[543] = {
		name = "Bayside Marina 18",
		gameInterior = 88,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2420.9055175781, 2406.5847167969, 13.02704334259},
			rotation = {0, 0, 86.677688598633},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {82.8525390625, 1322.6796875, 1083.8662109375},
			rotation = {0, 0, 0},
			interior = 9,
			dimension = 543
		}
	},
	[544] = {
		name = "Bayside 19",
		gameInterior = 88,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2398.5100097656, 2409.025390625, 8.9107646942139},
			rotation = {0, 0, 240.47904968262},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {82.8525390625, 1322.6796875, 1083.8662109375},
			rotation = {0, 0, 0},
			interior = 9,
			dimension = 544
		}
	},
	[545] = {
		name = "Bayside 20",
		gameInterior = 96,
		type = "house",
		price = 270000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2437.4401855469, 2354.935546875, 5.4430656433105},
			rotation = {0, 0, 12.660177230835},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 545
		}
	},
	[547] = {
		name = "Bayside Marina 22",
		gameInterior = 72,
		type = "house",
		price = 300000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2523.31640625, 2240.14453125, 5.2880935668945},
			rotation = {0, 0, 160.86817932129},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 547
		}
	},
	[548] = {
		name = "Bayside Marina 23",
		gameInterior = 72,
		type = "house",
		price = 280000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2552.0114746094, 2266.5610351563, 5.4755249023438},
			rotation = {0, 0, 158.36145019531},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 548
		}
	},
	[549] = {
		name = "Bayside Marina 30",
		gameInterior = 18,
		type = "house",
		price = 110000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2422.3562011719, 2491.3955078125, 13.143207550049},
			rotation = {0, 0, 178.72819519043},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 549
		}
	},
	[550] = {
		name = "Bayside Marina 31",
		gameInterior = 18,
		type = "house",
		price = 110000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2446.0979003906, 2491.6018066406, 15.3203125},
			rotation = {0, 0, 177.78811645508},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 550
		}
	},
	[551] = {
		name = "Bayside Marina 32",
		gameInterior = 18,
		type = "house",
		price = 105000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2464.4641113281, 2490.5832519531, 16.8125},
			rotation = {0, 0, 281.50241088867},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 551
		}
	},
	[552] = {
		name = "Bayside Marina 33",
		gameInterior = 18,
		type = "house",
		price = 115000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2478.9887695313, 2489.0620117188, 18.229986190796},
			rotation = {0, 0, 270.24572753906},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 552
		}
	},
	[553] = {
		name = "Bayside Marina 34",
		gameInterior = 18,
		type = "house",
		price = 115000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2479.0759277344, 2508.8923339844, 17.79528427124},
			rotation = {0, 0, 2.6798906326294},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 553
		}
	},
	[554] = {
		name = "Bayside Marina 35",
		gameInterior = 18,
		type = "house",
		price = 115000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-2446.6159667969, 2512.3364257813, 15.700329780579},
			rotation = {0, 0, 89.497444152832},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 554
		}
	},
	[555] = {
		name = "Jays",
		gameInterior = 90,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1941.5162353516, 2379.6291503906, 49.6953125},
			rotation = {0, 0, 112.97440338135},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {364.74380493164, -11.157381057739, 1001.8515625},
			rotation = {0, 0, 178.75164794922},
			interior = 9,
			dimension = 555
		}
	},
	[561] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1751.5452880859, 2747.1401367188, 11.34375},
			rotation = {0, 0, 19.600536346436},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 561
		}
	},
	[562] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1752.0506591797, 2745.1955566406, 11.34375},
			rotation = {0, 0, 197.26223754883},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 562
		}
	},
	[563] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1749.0231933594, 2756.4270019531, 11.34375},
			rotation = {0, 0, 199.14225769043},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 563
		}
	},
	[564] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1748.5434570313, 2758.4052734375, 11.34375},
			rotation = {0, 0, 15.237294197083},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 564
		}
	},
	[565] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1746.0382080078, 2767.7431640625, 11.34375},
			rotation = {0, 0, 193.21226501465},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 565
		}
	},
	[566] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1745.5487060547, 2769.6716308594, 11.34375},
			rotation = {0, 0, 15.550590515137},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 566
		}
	},
	[567] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1781.53125, 2747.1069335938, 11.34375},
			rotation = {0, 0, 348.31381225586},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 567
		}
	},
	[568] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1780.9317626953, 2745.0454101563, 11.34375},
			rotation = {0, 0, 164.09550476074},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 568
		}
	},
	[569] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1784.5012207031, 2758.4389648438, 11.34375},
			rotation = {0, 0, 346.43383789063},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 569
		}
	},
	[570] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1783.9224853516, 2756.2614746094, 11.34375},
			rotation = {0, 0, 169.08543395996},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 570
		}
	},
	[571] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1787.4968261719, 2769.6735839844, 11.34375},
			rotation = {0, 0, 341.39706420898},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 571
		}
	},
	[572] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1786.9338378906, 2767.4016113281, 11.34375},
			rotation = {0, 0, 162.81880187988},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 572
		}
	},
	[573] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1796.4840087891, 2803.25390625, 11.34375},
			rotation = {0, 0, 345.13366699219},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 573
		}
	},
	[574] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1795.9665527344, 2801.2536621094, 11.34375},
			rotation = {0, 0, 170.0020904541},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 574
		}
	},
	[575] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1798.9096679688, 2812.7136230469, 11.34375},
			rotation = {0, 0, 166.21878051758},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 575
		}
	},
	[576] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1799.6588134766, 2814.7570800781, 11.34375},
			rotation = {0, 0, 343.54376220703},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 576
		}
	},
	[577] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1802.4465332031, 2825.6999511719, 11.34375},
			rotation = {0, 0, 342.60375976563},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 577
		}
	},
	[578] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1801.8703613281, 2823.8549804688, 11.34375},
			rotation = {0, 0, 158.07208251953},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 578
		}
	},
	[579] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1796.1512451172, 2861.8669433594, 11.3359375},
			rotation = {0, 0, 236.69607543945},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 579
		}
	},
	[580] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1794.5831298828, 2863.0510253906, 11.3359375},
			rotation = {0, 0, 59.057773590088},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 580
		}
	},
	[581] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1785.8909912109, 2868.0236816406, 11.3359375},
			rotation = {0, 0, 241.70944213867},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 581
		}
	},
	[582] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1783.982421875, 2868.6733398438, 11.3359375},
			rotation = {0, 0, 71.567802429199},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 582
		}
	},
	[583] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1774.68359375, 2870.900390625, 11.3359375},
			rotation = {0, 0, 264.24621582031},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 583
		}
	},
	[584] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1772.4283447266, 2871.3044433594, 11.3359375},
			rotation = {0, 0, 85.667877197266},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 584
		}
	},
	[585] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1760.7464599609, 2871.0119628906, 11.3359375},
			rotation = {0, 0, 100.08135223389},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 585
		}
	},
	[586] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1762.5051269531, 2871.2954101563, 11.3359375},
			rotation = {0, 0, 272.70620727539},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 586
		}
	},
	[587] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1751.2114257813, 2868.5861816406, 11.3359375},
			rotation = {0, 0, 291.48300170898},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 587
		}
	},
	[588] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1748.9664306641, 2867.7189941406, 11.3359375},
			rotation = {0, 0, 113.50798034668},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 588
		}
	},
	[589] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1738.6450195313, 2861.7995605469, 11.3359375},
			rotation = {0, 0, 122.28141021729},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 589
		}
	},
	[590] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1740.5411376953, 2863.1774902344, 11.3359375},
			rotation = {0, 0, 303.67980957031},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 590
		}
	},
	[591] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1730.9981689453, 2823.5737304688, 11.34375},
			rotation = {0, 0, 194.32545471191},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 591
		}
	},
	[592] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1730.3410644531, 2825.8381347656, 11.34375},
			rotation = {0, 0, 14.493745803833},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 592
		}
	},
	[593] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1733.9907226563, 2812.333984375, 11.34375},
			rotation = {0, 0, 193.07202148438},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 593
		}
	},
	[594] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1733.5100097656, 2814.6948242188, 11.34375},
			rotation = {0, 0, 13.217000961304},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 594
		}
	},
	[595] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1737.0716552734, 2801.1645507813, 11.34375},
			rotation = {0, 0, 193.36196899414},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 595
		}
	},
	[596] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1736.5383300781, 2803.4208984375, 11.34375},
			rotation = {0, 0, 17.893623352051},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 596
		}
	},
	[597] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1780.8197021484, 2744.7941894531, 14.273517608643},
			rotation = {0, 0, 163.23474121094},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 597
		}
	},
	[598] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1781.3718261719, 2747.2221679688, 14.273517608643},
			rotation = {0, 0, 349.66983032227},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 598
		}
	},
	[599] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1783.9891357422, 2756.0749511719, 14.273517608643},
			rotation = {0, 0, 166.36811828613},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 599
		}
	},
	[600] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1784.54296875, 2758.5935058594, 14.273517608643},
			rotation = {0, 0, 347.45309448242},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 600
		}
	},
	[601] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1787.5283203125, 2769.7041015625, 14.273517608643},
			rotation = {0, 0, 345.25970458984},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 601
		}
	},
	[602] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1786.8671875, 2767.5520019531, 14.273517608643},
			rotation = {0, 0, 165.11471557617},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 602
		}
	},
	[603] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1796.5687255859, 2803.2946777344, 14.273517608643},
			rotation = {0, 0, 343.37969970703},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 603
		}
	},
	[604] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1795.9155273438, 2801.0559082031, 14.273517608643},
			rotation = {0, 0, 161.64468383789},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 604
		}
	},
	[605] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1799.6118164063, 2814.4582519531, 14.273517608643},
			rotation = {0, 0, 348.0563659668},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 605
		}
	},
	[606] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1798.9525146484, 2812.4086914063, 14.273517608643},
			rotation = {0, 0, 166.03134155273},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 606
		}
	},
	[607] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1802.3800048828, 2825.8332519531, 14.273517608643},
			rotation = {0, 0, 338.65621948242},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 607
		}
	},
	[608] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1801.9682617188, 2823.7348632813, 14.273517608643},
			rotation = {0, 0, 162.24787902832},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 608
		}
	},
	[609] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1796.4046630859, 2861.7202148438, 14.265625},
			rotation = {0, 0, 231.47183227539},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 609
		}
	},
	[610] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1794.5330810547, 2863.0061035156, 14.265625},
			rotation = {0, 0, 54.75016784668},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 610
		}
	},
	[611] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1784.0603027344, 2868.6057128906, 14.265625},
			rotation = {0, 0, 71.356986999512},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 611
		}
	},
	[612] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1786.2385253906, 2867.681640625, 14.265625},
			rotation = {0, 0, 251.83871459961},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 612
		}
	},
	[613] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1772.4483642578, 2871.1948242188, 14.265625},
			rotation = {0, 0, 84.830505371094},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 613
		}
	},
	[614] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1774.9869384766, 2870.9379882813, 14.265625},
			rotation = {0, 0, 260.27542114258},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 614
		}
	},
	[615] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1760.5164794922, 2870.9436035156, 14.265625},
			rotation = {0, 0, 98.907234191895},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 615
		}
	},
	[616] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1762.7720947266, 2871.2619628906, 14.265625},
			rotation = {0, 0, 276.23217773438},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 616
		}
	},
	[617] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1748.7606201172, 2867.6909179688, 14.265625},
			rotation = {0, 0, 111.4172744751},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 617
		}
	},
	[618] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1751.1713867188, 2868.6166992188, 14.265625},
			rotation = {0, 0, 291.89898681641},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 618
		}
	},
	[619] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1738.5557861328, 2861.7380371094, 14.265625},
			rotation = {0, 0, 123.32404327393},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 619
		}
	},
	[620] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1740.5877685547, 2863.1000976563, 14.257873535156},
			rotation = {0, 0, 302.23910522461},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 620
		}
	},
	[621] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1730.9108886719, 2823.5930175781, 14.273517608643},
			rotation = {0, 0, 196.33145141602},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 621
		}
	},
	[622] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1730.3310546875, 2826.1848144531, 14.273517608643},
			rotation = {0, 0, 12.113085746765},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 622
		}
	},
	[623] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1734.2093505859, 2812.4799804688, 14.273517608643},
			rotation = {0, 0, 194.13807678223},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 623
		}
	},
	[624] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1733.5059814453, 2814.4936523438, 14.273517608643},
			rotation = {0, 0, 13.993141174316},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 624
		}
	},
	[625] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1736.9844970703, 2801.1589355469, 14.273517608643},
			rotation = {0, 0, 195.07806396484},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 625
		}
	},
	[626] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1736.4091796875, 2803.107421875, 14.273517608643},
			rotation = {0, 0, 10.523003578186},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 626
		}
	},
	[627] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1745.4787597656, 2769.8330078125, 14.273517608643},
			rotation = {0, 0, 12.066372871399},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 627
		}
	},
	[628] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1746.0828857422, 2767.4736328125, 14.273517608643},
			rotation = {0, 0, 187.19804382324},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 628
		}
	},
	[629] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1749.1119384766, 2756.0886230469, 14.273517608643},
			rotation = {0, 0, 194.09136962891},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 629
		}
	},
	[630] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1748.4992675781, 2758.6418457031, 14.273517608643},
			rotation = {0, 0, 10.789653778076},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 630
		}
	},
	[631] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1752.1809082031, 2744.7419433594, 14.273517608643},
			rotation = {0, 0, 195.94795227051},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 631
		}
	},
	[632] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1751.5002441406, 2747.1574707031, 14.273517608643},
			rotation = {0, 0, 15.489696502686},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 632
		}
	},
	[633] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1831.9230957031, 2742.4619140625, 14.2734375},
			rotation = {0, 0, 314.99221801758},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 633
		}
	},
	[635] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1840.6135253906, 2750.962890625, 14.2734375},
			rotation = {0, 0, 314.67892456055},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 635
		}
	},
	[636] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1839.0250244141, 2749.5471191406, 14.2734375},
			rotation = {0, 0, 134.53395080566},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 636
		}
	},
	[637] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1847.3483886719, 2757.7182617188, 14.2734375},
			rotation = {0, 0, 128.55717468262},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 637
		}
	},
	[638] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1849.0187988281, 2759.2478027344, 14.2734375},
			rotation = {0, 0, 317.78887939453},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 638
		}
	},
	[639] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1873.2869873047, 2783.7978515625, 14.2734375},
			rotation = {0, 0, 314.02886962891},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 639
		}
	},
	[640] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1871.9841308594, 2782.1831054688, 14.2734375},
			rotation = {0, 0, 128.84713745117},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 640
		}
	},
	[641] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1880.1287841797, 2790.4714355469, 14.2734375},
			rotation = {0, 0, 138.8504486084},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 641
		}
	},
	[642] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1881.8924560547, 2792.2485351563, 14.2734375},
			rotation = {0, 0, 313.06546020508},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 642
		}
	},
	[643] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1890.1292724609, 2800.5810546875, 14.2734375},
			rotation = {0, 0, 314.94552612305},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 643
		}
	},
	[644] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1888.3892822266, 2798.7504882813, 14.2734375},
			rotation = {0, 0, 127.28048706055},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 644
		}
	},
	[645] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1830.6701660156, 2741.0805664063, 14.2734375},
			rotation = {0, 0, 133.54722595215},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 645
		}
	},
	[646] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1812.8760986328, 2820.7607421875, 14.273517608643},
			rotation = {0, 0, 162.32733154297},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 646
		}
	},
	[647] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1813.4123535156, 2822.6994628906, 14.273517608643},
			rotation = {0, 0, 348.76239013672},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 647
		}
	},
	[648] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1809.9620361328, 2809.6193847656, 14.273517608643},
			rotation = {0, 0, 163.2673034668},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 648
		}
	},
	[649] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1810.3360595703, 2811.6975097656, 14.273517608643},
			rotation = {0, 0, 343.43566894531},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 649
		}
	},
	[650] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1806.8616943359, 2798.3273925781, 14.273517608643},
			rotation = {0, 0, 166.40072631836},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 650
		}
	},
	[651] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1807.4039306641, 2800.2980957031, 14.273517608643},
			rotation = {0, 0, 344.37576293945},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 651
		}
	},
	[652] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1797.8225097656, 2764.57421875, 14.273517608643},
			rotation = {0, 0, 163.58071899414},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 652
		}
	},
	[653] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1798.4816894531, 2766.9086914063, 14.273517608643},
			rotation = {0, 0, 345.94244384766},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 653
		}
	},
	[654] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1794.736328125, 2753.3854980469, 14.273517608643},
			rotation = {0, 0, 170.1607208252},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 654
		}
	},
	[655] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1795.3228759766, 2755.1418457031, 14.273517608643},
			rotation = {0, 0, 344.37567138672},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 655
		}
	},
	[656] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1791.7470703125, 2742.0207519531, 14.273517608643},
			rotation = {0, 0, 163.89392089844},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 656
		}
	},
	[657] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1792.3664550781, 2744.1611328125, 14.273517608643},
			rotation = {0, 0, 342.80889892578},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 657
		}
	},
	[658] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1741.3458251953, 2741.658203125, 14.273517608643},
			rotation = {0, 0, 199.30097961426},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 658
		}
	},
	[659] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1740.5599365234, 2744.1313476563, 14.273517608643},
			rotation = {0, 0, 12.575912475586},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 659
		}
	},
	[660] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1737.6730957031, 2755.6708984375, 14.273517608643},
			rotation = {0, 0, 18.215961456299},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 660
		}
	},
	[661] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1738.1730957031, 2753.2612304688, 14.273517608643},
			rotation = {0, 0, 194.62428283691},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 661
		}
	},
	[662] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1734.5345458984, 2766.7902832031, 14.273517608643},
			rotation = {0, 0, 14.142594337463},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 662
		}
	},
	[663] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1735.2521972656, 2764.5634765625, 14.273517608643},
			rotation = {0, 0, 190.84088134766},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 663
		}
	},
	[664] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1725.5256347656, 2800.6254882813, 14.273517608643},
			rotation = {0, 0, 15.372477531433},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 664
		}
	},
	[665] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1726.1352539063, 2798.1484375, 14.273517608643},
			rotation = {0, 0, 189.25073242188},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 665
		}
	},
	[666] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1722.4545898438, 2811.7487792969, 14.273517608643},
			rotation = {0, 0, 15.975694656372},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 666
		}
	},
	[667] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1723.1556396484, 2809.4389648438, 14.273517608643},
			rotation = {0, 0, 198.33743286133},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 667
		}
	},
	[668] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1719.4959716797, 2823.279296875, 14.273517608643},
			rotation = {0, 0, 13.155762672424},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 668
		}
	},
	[669] = {
		name = "Prickle Pine Hotel szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1720.1590576172, 2820.7272949219, 14.273517608643},
			rotation = {0, 0, 192.9874420166},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 669
		}
	},
	[670] = {
		name = "Prickle Pine 1",
		gameInterior = 105,
		type = "house",
		price = 300000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1550.4820556641, 2845.1850585938, 10.8203125},
			rotation = {0, 0, 358.96212768555},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2324.499, -1147.071, 1050.71},
			rotation = {0, 0, 0},
			interior = 12,
			dimension = 670
		}
	},
	[671] = {
		name = "Prickle Pine 2",
		gameInterior = 105,
		type = "house",
		price = 310000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1575.8651123047, 2843.5756835938, 10.8203125},
			rotation = {0, 0, 4.2420778274536},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2324.499, -1147.071, 1050.71},
			rotation = {0, 0, 0},
			interior = 12,
			dimension = 671
		}
	},
	[672] = {
		name = "Prickle Pine 3",
		gameInterior = 94,
		type = "house",
		price = 310000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1601.7708740234, 2846.0766601563, 10.8203125},
			rotation = {0, 0, 359.18197631836},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {24.0498046875, 1340.3623046875, 1084.375},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 672
		}
	},
	[673] = {
		name = "Prickle Pine 4",
		gameInterior = 94,
		type = "house",
		price = 310000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1622.7640380859, 2846.0776367188, 10.826543807983},
			rotation = {0, 0, 358.24182128906},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {24.0498046875, 1340.3623046875, 1084.375},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 673
		}
	},
	[674] = {
		name = "Prickle Pine 5",
		gameInterior = 42,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1632.77734375, 2843.8134765625, 10.8203125},
			rotation = {0, 0, 2.6519618034363},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {235.2529296875, 1186.6806640625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 3,
			dimension = 674
		}
	},
	[675] = {
		name = "Prickle Pine 6",
		gameInterior = 42,
		type = "house",
		price = 325000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1664.7204589844, 2846.076171875, 10.826543807983},
			rotation = {0, 0, 0.12195734679699},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {235.2529296875, 1186.6806640625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 3,
			dimension = 675
		}
	},
	[676] = {
		name = "Prickle Pine 7",
		gameInterior = 24,
		type = "house",
		price = 325000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1673.0323486328, 2800.8210449219, 10.8203125},
			rotation = {0, 0, 177.4468536377},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 676
		}
	},
	[677] = {
		name = "Prickle Pine 8",
		gameInterior = 24,
		type = "house",
		price = 325000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1654.9487304688, 2801.5268554688, 10.8203125},
			rotation = {0, 0, 173.68685913086},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 677
		}
	},
	[678] = {
		name = "Prickle Pine 9",
		gameInterior = 24,
		type = "house",
		price = 305000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1637.9792480469, 2802.3305664063, 10.8203125},
			rotation = {0, 0, 181.52024841309},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 678
		}
	},
	[679] = {
		name = "Prickle Pine 10",
		gameInterior = 24,
		type = "house",
		price = 305000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1618.3376464844, 2801.0668945313, 10.8203125},
			rotation = {0, 0, 181.18350219727},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 679
		}
	},
	[680] = {
		name = "Prickle Pine 11",
		gameInterior = 94,
		type = "house",
		price = 310000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1588.3560791016, 2797.3278808594, 10.826543807983},
			rotation = {0, 0, 177.11010742188},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {24.0498046875, 1340.3623046875, 1084.375},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 680
		}
	},
	[681] = {
		name = "Prickle Pine 12",
		gameInterior = 50,
		type = "house",
		price = 310000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1565.1716308594, 2793.728515625, 10.8203125},
			rotation = {0, 0, 260.77087402344},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-260.65234375, 1456.9775390625, 1084.3671875},
			rotation = {0, 0, 0},
			interior = 4,
			dimension = 681
		}
	},
	[682] = {
		name = "Prickle Pine 12",
		gameInterior = 88,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1563.9227294922, 2776.5178222656, 10.8203125},
			rotation = {0, 0, 268.26766967773},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {82.8525390625, 1322.6796875, 1083.8662109375},
			rotation = {0, 0, 0},
			interior = 9,
			dimension = 682
		}
	},
	[683] = {
		name = "Prickle Pine 13",
		gameInterior = 88,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1564.9310302734, 2757.2478027344, 10.8203125},
			rotation = {0, 0, 269.2077331543},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {82.8525390625, 1322.6796875, 1083.8662109375},
			rotation = {0, 0, 0},
			interior = 9,
			dimension = 683
		}
	},
	[684] = {
		name = "Prickle Pine 14",
		gameInterior = 79,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1570.1573486328, 2711.1105957031, 10.8203125},
			rotation = {0, 0, 178.34027099609},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 684
		}
	},
	[685] = {
		name = "Prickle Pine 15",
		gameInterior = 79,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1580.3470458984, 2708.8547363281, 10.826543807983},
			rotation = {0, 0, 177.35346984863},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 685
		}
	},
	[686] = {
		name = "Prickle Pine 16",
		gameInterior = 79,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1601.2294921875, 2708.8518066406, 10.826543807983},
			rotation = {0, 0, 179.54679870605},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 686
		}
	},
	[687] = {
		name = "Prickle Pine 18",
		gameInterior = 79,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1627.22265625, 2711.0197753906, 10.8203125},
			rotation = {0, 0, 178.29347229004},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 687
		}
	},
	[688] = {
		name = "Prickle Pine 19",
		gameInterior = 79,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1652.4608154297, 2708.853515625, 10.826543807983},
			rotation = {0, 0, 178.58329772949},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 688
		}
	},
	[689] = {
		name = "Prickle Pine 20",
		gameInterior = 79,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1678.4753417969, 2691.4084472656, 10.8203125},
			rotation = {0, 0, 179.83666992188},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 689
		}
	},
	[690] = {
		name = "Prickle Pine 21",
		gameInterior = 79,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1703.7858886719, 2688.8515625, 10.826543807983},
			rotation = {0, 0, 180.12661743164},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 690
		}
	},
	[691] = {
		name = "Prickle Pine 22",
		gameInterior = 79,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1735.703125, 2691.1098632813, 10.8203125},
			rotation = {0, 0, 181.66984558105},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 691
		}
	},
	[692] = {
		name = "Prickle Pine 24",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1663.1804199219, 2753.4143066406, 10.8203125},
			rotation = {0, 0, 359.01818847656},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 692
		}
	},
	[693] = {
		name = "Prickle Pine 25",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1643.6870117188, 2753.3078613281, 10.8203125},
			rotation = {0, 0, 358.06427001953},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 693
		}
	},
	[694] = {
		name = "Prickle Pine 26",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1626.8543701172, 2753.974609375, 10.8203125},
			rotation = {0, 0, 357.72772216797},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 694
		}
	},
	[695] = {
		name = "Prickle Pine 27",
		gameInterior = 72,
		type = "house",
		price = 335000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1608.4771728516, 2754.0578613281, 10.8203125},
			rotation = {0, 0, 355.84774780273},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 695
		}
	},
	[696] = {
		name = "Prickle Pine 27",
		gameInterior = 24,
		type = "house",
		price = 335000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1599.6329345703, 2757.5263671875, 10.826543807983},
			rotation = {0, 0, 1.7776976823807},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 696
		}
	},
	[697] = {
		name = "Prickle Pine 30",
		gameInterior = 79,
		type = "house",
		price = 385000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1929.4584960938, 2774.2255859375, 10.8203125},
			rotation = {0, 0, 272.4299621582},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 697
		}
	},
	[698] = {
		name = "Prickle Pine 31",
		gameInterior = 79,
		type = "house",
		price = 380000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1967.3333740234, 2766.54296875, 10.826543807983},
			rotation = {0, 0, 0.81414926052094},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 698
		}
	},
	[699] = {
		name = "Prickle Pine 32",
		gameInterior = 79,
		type = "house",
		price = 390000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1992.498046875, 2764.4997558594, 10.8203125},
			rotation = {0, 0, 3.3208835124969},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 699
		}
	},
	[700] = {
		name = "Prickle Pine 33",
		gameInterior = 79,
		type = "house",
		price = 380000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2018.5999755859, 2766.5290527344, 10.826543807983},
			rotation = {0, 0, 359.56088256836},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 700
		}
	},
	[701] = {
		name = "Prickle Pine 34",
		gameInterior = 79,
		type = "house",
		price = 380000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2039.365234375, 2766.3510742188, 10.826543807983},
			rotation = {0, 0, 0.1875681579113},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 701
		}
	},
	[702] = {
		name = "Prickle Pine 35",
		gameInterior = 79,
		type = "house",
		price = 380000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2049.5712890625, 2764.2221679688, 10.8203125},
			rotation = {0, 0, 358.62091064453},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 702
		}
	},
	[703] = {
		name = "Prickle Pine 36",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1931.3758544922, 2721.9038085938, 10.8203125},
			rotation = {0, 0, 180.01927185059},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 703
		}
	},
	[704] = {
		name = "Prickle Pine 37",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1950.5404052734, 2722.6862792969, 10.8203125},
			rotation = {0, 0, 188.74176025391},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 704
		}
	},
	[705] = {
		name = "Prickle Pine 38",
		gameInterior = 72,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1969.8031005859, 2721.7917480469, 11.298933029175},
			rotation = {0, 0, 179.97253417969},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 705
		}
	},
	[706] = {
		name = "Prickle Pine 39",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1998.6844482422, 2722.0217285156, 10.8203125},
			rotation = {0, 0, 178.40586853027},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 706
		}
	},
	[707] = {
		name = "Prickle Pine 40",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2018.0026855469, 2722.2785644531, 10.8203125},
			rotation = {0, 0, 179.03245544434},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 707
		}
	},
	[708] = {
		name = "Prickle Pine 41",
		gameInterior = 72,
		type = "house",
		price = 340000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2037.0936279297, 2720.8149414063, 11.543558120728},
			rotation = {0, 0, 178.86396789551},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 708
		}
	},
	[709] = {
		name = "Prickle Pine 42",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2066.1159667969, 2721.9011230469, 10.8203125},
			rotation = {0, 0, 177.12884521484},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 709
		}
	},
	[710] = {
		name = "Prickle Pine 50",
		gameInterior = 71,
		type = "house",
		price = 150000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2108.9897460938, 2652.693359375, 10.812969207764},
			rotation = {0, 0, 270.81646728516},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 710
		}
	},
	[711] = {
		name = "Prickle Pine 51",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2056.5207519531, 2664.5100097656, 10.8203125},
			rotation = {0, 0, 0.11729233711958},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 711
		}
	},
	[712] = {
		name = "Prickle Pine 52",
		gameInterior = 72,
		type = "house",
		price = 310000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2037.0310058594, 2664.0378417969, 10.8203125},
			rotation = {0, 0, 359.15399169922},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 712
		}
	},
	[713] = {
		name = "Prickle Pine 53",
		gameInterior = 72,
		type = "house",
		price = 340000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2018.0063476563, 2664.6643066406, 11.298933029175},
			rotation = {0, 0, 359.73388671875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 713
		}
	},
	[714] = {
		name = "Prickle Pine 54",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1989.0825195313, 2664.8278808594, 10.8203125},
			rotation = {0, 0, 358.14385986328},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 714
		}
	},
	[715] = {
		name = "Prickle Pine 55",
		gameInterior = 72,
		type = "house",
		price = 320000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1969.6435546875, 2664.0607910156, 10.8203125},
			rotation = {0, 0, 0.00055074080592021},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 715
		}
	},
	[716] = {
		name = "Prickle Pine 56",
		gameInterior = 72,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1950.4309082031, 2664.6647949219, 11.298933029175},
			rotation = {0, 0, 355.92724609375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 716
		}
	},
	[717] = {
		name = "Prickle Pine 57",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1921.6512451172, 2664.9741210938, 10.8203125},
			rotation = {0, 0, 358.43392944336},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 717
		}
	},
	[718] = {
		name = "Prickle Pine 60",
		gameInterior = 72,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1666.9399414063, 2609.5717773438, 11.054918289185},
			rotation = {0, 0, 2.7971444129944},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 718
		}
	},
	[719] = {
		name = "Prickle Pine 61",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1638.2620849609, 2610.5219726563, 10.8203125},
			rotation = {0, 0, 357.76040649414},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 719
		}
	},
	[720] = {
		name = "Prickle Pine 63",
		gameInterior = 24,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1556.0089111328, 2660.0336914063, 10.8203125},
			rotation = {0, 0, 183.05256652832},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 720
		}
	},
	[721] = {
		name = "Prickle Pine 64",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1573.1176757813, 2658.6923828125, 10.8203125},
			rotation = {0, 0, 177.70249938965},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 721
		}
	},
	[722] = {
		name = "Prickle Pine 65",
		gameInterior = 50,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1611.5931396484, 2648.1166992188, 10.826543807983},
			rotation = {0, 0, 267.94351196289},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-260.65234375, 1456.9775390625, 1084.3671875},
			rotation = {0, 0, 0},
			interior = 4,
			dimension = 722
		}
	},
	[723] = {
		name = "Prickle Pine 66",
		gameInterior = 72,
		type = "house",
		price = 340000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1607.0063476563, 2679.263671875, 10.8203125},
			rotation = {0, 0, 270.44995117188},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 723
		}
	},
	[724] = {
		name = "Prickle Pine 70",
		gameInterior = 72,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1618.7276611328, 2609.4460449219, 10.8203125},
			rotation = {0, 0, 0.087533205747604},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 724
		}
	},
	[725] = {
		name = "Prickle Pine 72",
		gameInterior = 60,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1600.5697021484, 2608.9357910156, 10.8203125},
			rotation = {0, 0, 1.6542760133743},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 725
		}
	},
	[726] = {
		name = "Prickle Pine 73",
		gameInterior = 61,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1554.4222412109, 2610.4616699219, 10.8203125},
			rotation = {0, 0, 0.087594665586948},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 726
		}
	},
	[727] = {
		name = "Prickle Pine 74",
		gameInterior = 60,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1535.0430908203, 2609.3696289063, 10.8203125},
			rotation = {0, 0, 359.12423706055},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 727
		}
	},
	[728] = {
		name = "Prickle Pine 75",
		gameInterior = 61,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1515.9196777344, 2609.9208984375, 11.298933029175},
			rotation = {0, 0, 3.4876625537872},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 728
		}
	},
	[729] = {
		name = "Prickle Pine 76",
		gameInterior = 60,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1344.6685791016, 2609.9038085938, 11.298933029175},
			rotation = {0, 0, 359.10092163086},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 729
		}
	},
	[730] = {
		name = "Prickle Pine 77",
		gameInterior = 72,
		type = "house",
		price = 360000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1313.9013671875, 2609.7687988281, 11.298933029175},
			rotation = {0, 0, 0.35428619384766},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 730
		}
	},
	[731] = {
		name = "Prickle Pine 78",
		gameInterior = 60,
		type = "house",
		price = 360000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1265.3375244141, 2609.0119628906, 10.8203125},
			rotation = {0, 0, 358.16091918945},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 731
		}
	},
	[732] = {
		name = "Prickle Pine 79",
		gameInterior = 61,
		type = "house",
		price = 350000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1284.8353271484, 2610.0151367188, 10.8203125},
			rotation = {0, 0, 356.59439086914},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 732
		}
	},
	[733] = {
		name = "Prickle Pine 80",
		gameInterior = 24,
		type = "house",
		price = 380000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1274.6590576172, 2522.3579101563, 10.8203125},
			rotation = {0, 0, 90.885261535645},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {491.33203125, 1398.4990234375, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 733
		}
	},
	[734] = {
		name = "Prickle Pine 81",
		gameInterior = 50,
		type = "house",
		price = 400000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1316.4700927734, 2524.6845703125, 10.8203125},
			rotation = {0, 0, 263.84683227539},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-260.65234375, 1456.9775390625, 1084.3671875},
			rotation = {0, 0, 0},
			interior = 4,
			dimension = 734
		}
	},
	[735] = {
		name = "Prickle Pine 82",
		gameInterior = 62,
		type = "house",
		price = 400000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1269.8031005859, 2554.2214355469, 10.826543807983},
			rotation = {0, 0, 89.341979980469},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {140.5107421875, 1365.939453125, 1083.859375},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 735
		}
	},
	[736] = {
		name = "Prickle Pine 84",
		gameInterior = 88,
		type = "house",
		price = 380000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1271.8836669922, 2564.3012695313, 10.8203125},
			rotation = {0, 0, 87.461936950684},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {82.8525390625, 1322.6796875, 1083.8662109375},
			rotation = {0, 0, 0},
			interior = 9,
			dimension = 736
		}
	},
	[737] = {
		name = "Prickle Pine 85",
		gameInterior = 94,
		type = "house",
		price = 380000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1223.2124023438, 2616.7644042969, 10.826543807983},
			rotation = {0, 0, 89.318634033203},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {24.0498046875, 1340.3623046875, 1084.375},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 737
		}
	},
	[738] = {
		name = "Prickle Pine 86",
		gameInterior = 94,
		type = "house",
		price = 380000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1225.2738037109, 2584.8271484375, 10.8203125},
			rotation = {0, 0, 88.981918334961},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {24.0498046875, 1340.3623046875, 1084.375},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 738
		}
	},
	[739] = {
		name = "Prickle Pine 90",
		gameInterior = 62,
		type = "house",
		price = 420000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1325.5939941406, 2567.7731933594, 10.8203125},
			rotation = {0, 0, 180.13931274414},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {140.5107421875, 1365.939453125, 1083.859375},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 739
		}
	},
	[740] = {
		name = "Prickle Pine 91",
		gameInterior = 79,
		type = "house",
		price = 400000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1349.7673339844, 2567.6882324219, 10.8203125},
			rotation = {0, 0, 179.82600402832},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 740
		}
	},
	[741] = {
		name = "Prickle Pine 92",
		gameInterior = 79,
		type = "house",
		price = 400000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1359.7834472656, 2565.6027832031, 10.826543807983},
			rotation = {0, 0, 180.7425994873},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 741
		}
	},
	[742] = {
		name = "Prickle Pine 93",
		gameInterior = 105,
		type = "house",
		price = 400000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1362.6910400391, 2525.6403808594, 10.8203125},
			rotation = {0, 0, 90.188461303711},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2324.499, -1147.071, 1050.71},
			rotation = {0, 0, 0},
			interior = 12,
			dimension = 742
		}
	},
	[743] = {
		name = "Prickle Pine 94",
		gameInterior = 105,
		type = "house",
		price = 400000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1408.1021728516, 2524.48046875, 10.8203125},
			rotation = {0, 0, 268.47698974609},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2324.499, -1147.071, 1050.71},
			rotation = {0, 0, 0},
			interior = 12,
			dimension = 743
		}
	},
	[744] = {
		name = "Prickle Pine 95",
		gameInterior = 62,
		type = "house",
		price = 420000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1417.8846435547, 2567.8115234375, 10.8203125},
			rotation = {0, 0, 179.80278015137},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {140.5107421875, 1365.939453125, 1083.859375},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 744
		}
	},
	[745] = {
		name = "Prickle Pine 96",
		gameInterior = 79,
		type = "house",
		price = 400000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1441.6759033203, 2567.751953125, 10.8203125},
			rotation = {0, 0, 179.80281066895},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {234.220703125, 1064.42578125, 1084.2111816406},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 745
		}
	},
	[746] = {
		name = "Prickle Pine 97",
		gameInterior = 88,
		type = "house",
		price = 400000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1451.5150146484, 2565.6516113281, 10.826543807983},
			rotation = {0, 0, 179.1761932373},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {82.8525390625, 1322.6796875, 1083.8662109375},
			rotation = {0, 0, 0},
			interior = 9,
			dimension = 746
		}
	},
	[747] = {
		name = "Prickle Pine 100",
		gameInterior = 105,
		type = "house",
		price = 450000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1500.6896972656, 2535.4438476563, 10.8203125},
			rotation = {0, 0, 268.45373535156},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2324.499, -1147.071, 1050.71},
			rotation = {0, 0, 0},
			interior = 12,
			dimension = 747
		}
	},
	[748] = {
		name = "Prickle Pine 99",
		gameInterior = 94,
		type = "house",
		price = 400000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1503.1676025391, 2567.8718261719, 10.8203125},
			rotation = {0, 0, 178.18939208984},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {24.0498046875, 1340.3623046875, 1084.375},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 748
		}
	},
	[749] = {
		name = "Prickle Pine 101",
		gameInterior = 94,
		type = "house",
		price = 400000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1513.3054199219, 2565.4294433594, 10.826543807983},
			rotation = {0, 0, 175.99606323242},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {24.0498046875, 1340.3623046875, 1084.375},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 749
		}
	},
	[750] = {
		name = "Prickle Pine 102",
		gameInterior = 94,
		type = "house",
		price = 410000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1551.3634033203, 2567.5427246094, 10.8203125},
			rotation = {0, 0, 180.04592895508},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {24.0498046875, 1340.3623046875, 1084.375},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 750
		}
	},
	[751] = {
		name = "Prickle Pine 103",
		gameInterior = 62,
		type = "house",
		price = 410000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1564.5930175781, 2565.6579589844, 10.826543807983},
			rotation = {0, 0, 179.7325592041},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {140.5107421875, 1365.939453125, 1083.859375},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 751
		}
	},
	[752] = {
		name = "Prickle Pine 104",
		gameInterior = 94,
		type = "house",
		price = 420000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1596.4798583984, 2567.6870117188, 10.8203125},
			rotation = {0, 0, 181.2992401123},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {24.0498046875, 1340.3623046875, 1084.375},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 752
		}
	},
	[753] = {
		name = "Prickle Pine 105",
		gameInterior = 94,
		type = "house",
		price = 435000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1623.4742431641, 2567.8452148438, 10.8203125},
			rotation = {0, 0, 177.85261535645},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {24.0498046875, 1340.3623046875, 1084.375},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 753
		}
	},
	[754] = {
		name = "Prickle Pine 106",
		gameInterior = 60,
		type = "house",
		price = 330000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1646.6448974609, 2570.6030273438, 10.8203125},
			rotation = {0, 0, 177.85264587402},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 754
		}
	},
	[755] = {
		name = "Prickle Pine 107",
		gameInterior = 61,
		type = "house",
		price = 340000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1665.5213623047, 2569.7453613281, 11.298933029175},
			rotation = {0, 0, 178.76919555664},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 755
		}
	},
	[756] = {
		name = "Creek-1",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2787.95703125, 2261.5559082031, 14.661463737488},
			rotation = {0, 0, 182.84210205078},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 756
		}
	},
	[757] = {
		name = "Creek-2",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2787.9370117188, 2268.1298828125, 14.661463737488},
			rotation = {0, 0, 359.87710571289},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 757
		}
	},
	[758] = {
		name = "Creek-3",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2794.2138671875, 2261.2927246094, 14.661463737488},
			rotation = {0, 0, 182.52886962891},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 758
		}
	},
	[759] = {
		name = "Creek-4",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2794.1374511719, 2267.9763183594, 14.661463737488},
			rotation = {0, 0, 2.0705626010895},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 759
		}
	},
	[760] = {
		name = "Creek-5",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2794.3591308594, 2261.1525878906, 10.8203125},
			rotation = {0, 0, 169.36871337891},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 760
		}
	},
	[761] = {
		name = "Creek-6",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2787.9284667969, 2261.4948730469, 10.8203125},
			rotation = {0, 0, 183.46887207031},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 761
		}
	},
	[762] = {
		name = "Creek-7",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2787.8986816406, 2268.0185546875, 10.8203125},
			rotation = {0, 0, 354.84039306641},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 762
		}
	},
	[763] = {
		name = "Creek-8",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2794.1359863281, 2268.03125, 10.8203125},
			rotation = {0, 0, 1.733793258667},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 763
		}
	},
	[764] = {
		name = "Creek-9",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2816.8996582031, 2268.70703125, 10.8203125},
			rotation = {0, 0, 89.467895507813},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 764
		}
	},
	[765] = {
		name = "Creek-10",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2816.9516601563, 2274.5681152344, 10.8203125},
			rotation = {0, 0, 82.261199951172},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 765
		}
	},
	[766] = {
		name = "Creek-11",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2823.6420898438, 2274.9360351563, 10.8203125},
			rotation = {0, 0, 265.85287475586},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 766
		}
	},
	[767] = {
		name = "Creek-12",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2823.4650878906, 2268.7458496094, 10.8203125},
			rotation = {0, 0, 271.49298095703},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 767
		}
	},
	[768] = {
		name = "Creek-13",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2823.1674804688, 2268.6389160156, 14.661463737488},
			rotation = {0, 0, 268.67297363281},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 768
		}
	},
	[769] = {
		name = "Creek-14",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2823.5908203125, 2274.7360839844, 14.661463737488},
			rotation = {0, 0, 286.21981811523},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 769
		}
	},
	[770] = {
		name = "Creek-15",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2817.0983886719, 2274.8413085938, 14.661463737488},
			rotation = {0, 0, 87.251235961914},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 770
		}
	},
	[771] = {
		name = "Creek-16",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2817.0688476563, 2268.8540039063, 14.661463737488},
			rotation = {0, 0, 91.324577331543},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 771
		}
	},
	[772] = {
		name = "Creek-17",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2794.3212890625, 2223.0341796875, 10.8203125},
			rotation = {0, 0, 179.05874633789},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 772
		}
	},
	[773] = {
		name = "Creek-18",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2794.3920898438, 2229.109375, 10.8203125},
			rotation = {0, 0, 357.01037597656},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 773
		}
	},
	[774] = {
		name = "Creek-19",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2788.0422363281, 2222.3269042969, 10.8203125},
			rotation = {0, 0, 177.80541992188},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 774
		}
	},
	[775] = {
		name = "Creek-20",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2787.8869628906, 2229.0588378906, 10.8203125},
			rotation = {0, 0, 0.14373199641705},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 775
		}
	},
	[776] = {
		name = "Creek-21",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2787.8830566406, 2229.3364257813, 14.661463737488},
			rotation = {0, 0, 0.48046714067459},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 776
		}
	},
	[778] = {
		name = "Creek-22",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2788.0073242188, 2222.3767089844, 14.661463737488},
			rotation = {0, 0, 179.05867004395},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 778
		}
	},
	[779] = {
		name = "Creek-23",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2794.3078613281, 2229.02734375, 14.661463737488},
			rotation = {0, 0, 2.0470869541168},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 779
		}
	},
	[780] = {
		name = "Creek-24",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2794.2463378906, 2222.3706054688, 14.661463737488},
			rotation = {0, 0, 183.46879577637},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 780
		}
	},
	[781] = {
		name = "Creek-25",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2825.7802734375, 2140.8857421875, 10.8203125},
			rotation = {0, 0, 268.98635864258},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 781
		}
	},
	[782] = {
		name = "Creek-26",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2818.9799804688, 2140.8413085938, 10.8203125},
			rotation = {0, 0, 90.698013305664},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 782
		}
	},
	[783] = {
		name = "Creek-27",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2825.5476074219, 2134.2651367188, 10.8203125},
			rotation = {0, 0, 269.61303710938},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 783
		}
	},
	[784] = {
		name = "Creek-28",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2818.7009277344, 2134.2915039063, 10.8203125},
			rotation = {0, 0, 87.87801361084},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 784
		}
	},
	[785] = {
		name = "Creek-29",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2818.8474121094, 2134.4055175781, 14.661464691162},
			rotation = {0, 0, 90.408096313477},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 785
		}
	},
	[786] = {
		name = "Creek-30",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2818.8107910156, 2140.6943359375, 14.661464691162},
			rotation = {0, 0, 96.361503601074},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 786
		}
	},
	[787] = {
		name = "Creek-31",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2825.6206054688, 2140.8781738281, 14.661464691162},
			rotation = {0, 0, 266.79309082031},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 787
		}
	},
	[788] = {
		name = "Creek-32",
		gameInterior = 96,
		type = "house",
		price = 160000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2825.900390625, 2134.4006347656, 14.661464691162},
			rotation = {0, 0, 275.56652832031},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 788
		}
	},
	[789] = {
		name = "Rockshore East-1",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2660.2912597656, 749.72967529297, 10.8203125},
			rotation = {0, 0, 3.2774364948273},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 789
		}
	},
	[790] = {
		name = "Rockshore East-2",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2666.5278320313, 749.71856689453, 10.8203125},
			rotation = {0, 0, 0.14401887357235},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 790
		}
	},
	[791] = {
		name = "Rockshore East-3",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2666.2932128906, 742.67846679688, 10.8203125},
			rotation = {0, 0, 181.22900390625},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 791
		}
	},
	[792] = {
		name = "Rockshore East-1",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2660.423828125, 742.70123291016, 10.8203125},
			rotation = {0, 0, 188.43572998047},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 792
		}
	},
	[793] = {
		name = "Rockshore East-5",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2660.2817382813, 749.73559570313, 14.739588737488},
			rotation = {0, 0, 358.2639465332},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 793
		}
	},
	[794] = {
		name = "Rockshore East-6",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2666.2041015625, 749.7998046875, 14.739588737488},
			rotation = {0, 0, 357.95062255859},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 794
		}
	},
	[795] = {
		name = "Rockshore East-7",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2666.6525878906, 742.64312744141, 14.739588737488},
			rotation = {0, 0, 178.72227478027},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 795
		}
	},
	[796] = {
		name = "Rockshore East-8",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2660.330078125, 743.38922119141, 14.739588737488},
			rotation = {0, 0, 179.34893798828},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 796
		}
	},
	[797] = {
		name = "Rockshore East-9",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2659.7048339844, 719.59857177734, 10.8203125},
			rotation = {0, 0, 265.82983398438},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 797
		}
	},
	[798] = {
		name = "Rockshore East-10",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2659.642578125, 713.12994384766, 10.8203125},
			rotation = {0, 0, 274.28994750977},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 798
		}
	},
	[799] = {
		name = "Rockshore East-11",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2652.8627929688, 713.3779296875, 10.8203125},
			rotation = {0, 0, 93.808219909668},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 799
		}
	},
	[800] = {
		name = "Rockshore East-12",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2652.8298339844, 719.52276611328, 10.8203125},
			rotation = {0, 0, 90.04817199707},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 800
		}
	},
	[801] = {
		name = "Rockshore East-13",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2659.9633789063, 719.52435302734, 14.739588737488},
			rotation = {0, 0, 270.2165222168},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 801
		}
	},
	[802] = {
		name = "Rockshore East-14",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2659.5358886719, 713.28692626953, 14.739588737488},
			rotation = {0, 0, 272.40991210938},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 802
		}
	},
	[803] = {
		name = "Rockshore East-15",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2652.6069335938, 713.16021728516, 14.739588737488},
			rotation = {0, 0, 91.638290405273},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 803
		}
	},
	[804] = {
		name = "Rockshore East-16",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2652.6962890625, 719.56286621094, 14.739588737488},
			rotation = {0, 0, 93.20499420166},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 804
		}
	},
	[805] = {
		name = "Rockshore East-17",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.6354980469, 719.53253173828, 10.8203125},
			rotation = {0, 0, 270.89013671875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 805
		}
	},
	[806] = {
		name = "Rockshore East-18",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.7783203125, 713.38269042969, 10.8203125},
			rotation = {0, 0, 269.95010375977},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 806
		}
	},
	[808] = {
		name = "Rockshore East-19",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.9729003906, 713.23181152344, 10.8203125},
			rotation = {0, 0, 92.288444519043},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 808
		}
	},
	[809] = {
		name = "Rockshore East-2",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.9594726563, 719.50573730469, 10.8203125},
			rotation = {0, 0, 91.975090026855},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 809
		}
	},
	[810] = {
		name = "Rockshore East-21",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.6010742188, 719.5712890625, 14.739588737488},
			rotation = {0, 0, 270.26348876953},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 810
		}
	},
	[811] = {
		name = "Rockshore East-22",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.7211914063, 713.33685302734, 14.739588737488},
			rotation = {0, 0, 274.02374267578},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 811
		}
	},
	[812] = {
		name = "Rockshore East-23",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.798828125, 713.23345947266, 14.739588737488},
			rotation = {0, 0, 91.685409545898},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 812
		}
	},
	[813] = {
		name = "Rockshore East-24",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.8439941406, 719.51959228516, 14.739588737488},
			rotation = {0, 0, 90.745399475098},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 813
		}
	},
	[814] = {
		name = "Rockshore East-25",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2578.6840820313, 719.63037109375, 10.8203125},
			rotation = {0, 0, 271.22705078125},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 814
		}
	},
	[815] = {
		name = "Rockshore East-26",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2571.8586425781, 719.32476806641, 10.8203125},
			rotation = {0, 0, 87.925369262695},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 815
		}
	},
	[816] = {
		name = "Rockshore East-27",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2578.78125, 713.21429443359, 10.8203125},
			rotation = {0, 0, 274.36038208008},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 816
		}
	},
	[817] = {
		name = "Rockshore East-28",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2572.0148925781, 713.14068603516, 10.8203125},
			rotation = {0, 0, 90.431991577148},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 817
		}
	},
	[818] = {
		name = "Rockshore East-29",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2578.7763671875, 713.32196044922, 14.739588737488},
			rotation = {0, 0, 271.83029174805},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 818
		}
	},
	[819] = {
		name = "Rockshore East-30",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2578.8510742188, 719.5146484375, 14.739588737488},
			rotation = {0, 0, 271.51696777344},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 819
		}
	},
	[820] = {
		name = "Rockshore East-31",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2571.8276367188, 719.611328125, 14.739588737488},
			rotation = {0, 0, 90.408615112305},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 820
		}
	},
	[821] = {
		name = "Rockshore East-32",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2571.90625, 713.16003417969, 14.739588737488},
			rotation = {0, 0, 90.721969604492},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 821
		}
	},
	[822] = {
		name = "Rockshore East-33",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2539.7578125, 719.42913818359, 10.8203125},
			rotation = {0, 0, 270.5537109375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 822
		}
	},
	[823] = {
		name = "Rockshore East-34",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2533.1157226563, 719.34136962891, 10.8203125},
			rotation = {0, 0, 84.74528503418},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 823
		}
	},
	[824] = {
		name = "Rockshore East-35",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2539.8505859375, 713.31799316406, 10.8203125},
			rotation = {0, 0, 270.24041748047},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 824
		}
	},
	[825] = {
		name = "Rockshore East-36",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2532.6833496094, 713.13537597656, 10.8203125},
			rotation = {0, 0, 92.892082214355},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 825
		}
	},
	[826] = {
		name = "Rockshore East-37",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2539.5600585938, 713.33221435547, 14.739588737488},
			rotation = {0, 0, 268.36047363281},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 826
		}
	},
	[827] = {
		name = "Rockshore East-38",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2539.7062988281, 719.52624511719, 14.739588737488},
			rotation = {0, 0, 268.0471496582},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 827
		}
	},
	[828] = {
		name = "Rockshore East-39",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2532.8132324219, 719.48162841797, 14.739588737488},
			rotation = {0, 0, 91.638786315918},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 828
		}
	},
	[829] = {
		name = "Rockshore East-40",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2532.9125976563, 713.23052978516, 14.739588737488},
			rotation = {0, 0, 89.445404052734},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 829
		}
	},
	[830] = {
		name = "Rockshore East-41",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2532.4006347656, 742.67938232422, 10.8203125},
			rotation = {0, 0, 181.87951660156},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 830
		}
	},
	[831] = {
		name = "Rockshore East-42",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2532.2734375, 749.85705566406, 10.8203125},
			rotation = {0, 0, 2.6745765209198},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 831
		}
	},
	[832] = {
		name = "Rockshore East-43",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2526.0014648438, 742.75457763672, 10.8203125},
			rotation = {0, 0, 184.09628295898},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 832
		}
	},
	[834] = {
		name = "Rockshore East-44",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2526.0163574219, 749.78741455078, 10.8203125},
			rotation = {0, 0, 2.6745150089264},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 834
		}
	},
	[835] = {
		name = "Rockshore East-45",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2526.0134277344, 749.76965332031, 14.739588737488},
			rotation = {0, 0, 359.54116821289},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 835
		}
	},
	[836] = {
		name = "Rockshore East-46",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2526.0344238281, 742.76531982422, 14.739588737488},
			rotation = {0, 0, 181.25283813477},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 836
		}
	},
	[837] = {
		name = "Rockshore East-47",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2532.2436523438, 749.53851318359, 14.739588737488},
			rotation = {0, 0, 358.91452026367},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 837
		}
	},
	[838] = {
		name = "Rockshore East-48",
		gameInterior = 96,
		type = "house",
		price = 140000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2532.3657226563, 743.02056884766, 14.739588737488},
			rotation = {0, 0, 179.99948120117},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 838
		}
	},
	[839] = {
		name = "Rockshore West-1",
		gameInterior = 72,
		type = "house",
		price = 240000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2449.5131835938, 742.73681640625, 11.4609375},
			rotation = {0, 0, 269.59039306641},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 839
		}
	},
	[840] = {
		name = "Rockshore West-2",
		gameInterior = 72,
		type = "house",
		price = 240000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2450.0483398438, 714.19848632813, 11.468292236328},
			rotation = {0, 0, 272.09713745117},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 840
		}
	},
	[841] = {
		name = "Rockshore West-3",
		gameInterior = 72,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2448.5764160156, 689.70196533203, 11.4609375},
			rotation = {0, 0, 277.71377563477},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 841
		}
	},
	[842] = {
		name = "Rockshore West-4",
		gameInterior = 60,
		type = "house",
		price = 240000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2450.0356445313, 662.66033935547, 11.4609375},
			rotation = {0, 0, 269.25381469727},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 842
		}
	},
	[843] = {
		name = "Rockshore West-5",
		gameInterior = 60,
		type = "house",
		price = 240000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2397.4978027344, 655.75817871094, 11.4609375},
			rotation = {0, 0, 359.15789794922},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 843
		}
	},
	[844] = {
		name = "Rockshore West-6",
		gameInterior = 61,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2368.4963378906, 654.44360351563, 11.4609375},
			rotation = {0, 0, 359.76116943359},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 844
		}
	},
	[845] = {
		name = "Rockshore West-7",
		gameInterior = 60,
		type = "house",
		price = 240000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2346.1687011719, 655.82922363281, 11.460479736328},
			rotation = {0, 0, 0.38787710666656},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 845
		}
	},
	[846] = {
		name = "Rockshore West-8",
		gameInterior = 61,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2317.8071289063, 655.50366210938, 11.453125},
			rotation = {0, 0, 358.82122802734},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 846
		}
	},
	[847] = {
		name = "Rockshore West-9",
		gameInterior = 61,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2258.0187988281, 655.77294921875, 11.453125},
			rotation = {0, 0, 359.13455200195},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 847
		}
	},
	[848] = {
		name = "Rockshore West-10",
		gameInterior = 60,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2228.9641113281, 654.10418701172, 11.4609375},
			rotation = {0, 0, 2.2445545196533},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 848
		}
	},
	[849] = {
		name = "Rockshore West-11",
		gameInterior = 61,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2206.4177246094, 655.70953369141, 11.468292236328},
			rotation = {0, 0, 0.051237571984529},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 849
		}
	},
	[850] = {
		name = "Rockshore West-12",
		gameInterior = 61,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2178.0283203125, 655.65490722656, 11.4609375},
			rotation = {0, 0, 1.3046659231186},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 850
		}
	},
	[851] = {
		name = "Rockshore West-13",
		gameInterior = 72,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2123.3557128906, 652.35809326172, 11.4609375},
			rotation = {0, 0, 178.02632141113},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 851
		}
	},
	[852] = {
		name = "Rockshore West-14",
		gameInterior = 61,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2094.1499023438, 650.78155517578, 11.4609375},
			rotation = {0, 0, 178.96635437012},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 852
		}
	},
	[853] = {
		name = "Rockshore West-15",
		gameInterior = 60,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2065.8942871094, 650.59020996094, 11.468292236328},
			rotation = {0, 0, 178.65301513672},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 853
		}
	},
	[854] = {
		name = "Rockshore West-16",
		gameInterior = 60,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2043.4445800781, 651.92248535156, 11.4609375},
			rotation = {0, 0, 176.45962524414},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 854
		}
	},
	[855] = {
		name = "Rockshore West-17",
		gameInterior = 61,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2014.0847167969, 650.56805419922, 11.4609375},
			rotation = {0, 0, 178.02630615234},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 855
		}
	},
	[856] = {
		name = "Rockshore West-18",
		gameInterior = 61,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2011.4653320313, 694.42907714844, 11.4609375},
			rotation = {0, 0, 357.85794067383},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 856
		}
	},
	[857] = {
		name = "Rockshore West-19",
		gameInterior = 61,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2040.5155029297, 695.86322021484, 11.453125},
			rotation = {0, 0, 359.44805908203},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 857
		}
	},
	[858] = {
		name = "Rockshore West-20",
		gameInterior = 61,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2068.9487304688, 696.14837646484, 11.468292236328},
			rotation = {0, 0, 0.074733421206474},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 858
		}
	},
	[859] = {
		name = "Rockshore West-21",
		gameInterior = 61,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2091.1489257813, 694.76031494141, 11.4609375},
			rotation = {0, 0, 357.88137817383},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 859
		}
	},
	[860] = {
		name = "Rockshore West-22",
		gameInterior = 60,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2120.3161621094, 695.92425537109, 11.453125},
			rotation = {0, 0, 358.82138061523},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 860
		}
	},
	[861] = {
		name = "Rockshore West-23",
		gameInterior = 60,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2177.6240234375, 735.15661621094, 11.4609375},
			rotation = {0, 0, 0.36464762687683},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 861
		}
	},
	[862] = {
		name = "Rockshore West-24",
		gameInterior = 60,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2205.9321289063, 735.89239501953, 11.468292236328},
			rotation = {0, 0, 4.7514390945435},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 862
		}
	},
	[863] = {
		name = "Rockshore West-25",
		gameInterior = 60,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2228.4638671875, 734.40887451172, 11.4609375},
			rotation = {0, 0, 2.2447595596313},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 863
		}
	},
	[864] = {
		name = "Rockshore West-26",
		gameInterior = 60,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2257.5517578125, 735.50592041016, 11.4609375},
			rotation = {0, 0, 358.17150878906},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 864
		}
	},
	[865] = {
		name = "Rockshore West-27",
		gameInterior = 61,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2346.5734863281, 735.72222900391, 11.468292236328},
			rotation = {0, 0, 358.79824829102},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 865
		}
	},
	[866] = {
		name = "Rockshore West-28",
		gameInterior = 61,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2369.0620117188, 734.45166015625, 11.4609375},
			rotation = {0, 0, 2.2449643611908},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 866
		}
	},
	[867] = {
		name = "Rockshore West-29",
		gameInterior = 60,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2398.2778320313, 735.61968994141, 11.4609375},
			rotation = {0, 0, 1.6183015108109},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 867
		}
	},
	[868] = {
		name = "Rockshore West-30",
		gameInterior = 60,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2396.9321289063, 691.01776123047, 11.453125},
			rotation = {0, 0, 178.96672058105},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 868
		}
	},
	[869] = {
		name = "Rockshore West-31",
		gameInterior = 61,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2368.5703125, 690.49566650391, 11.460479736328},
			rotation = {0, 0, 178.65338134766},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 869
		}
	},
	[870] = {
		name = "Rockshore West-32",
		gameInterior = 60,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2346.4245605469, 691.84417724609, 11.4609375},
			rotation = {0, 0, 178.9666595459},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 870
		}
	},
	[871] = {
		name = "Rockshore West-33",
		gameInterior = 61,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2317.1137695313, 690.56793212891, 11.4609375},
			rotation = {0, 0, 185.86006164551},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 871
		}
	},
	[872] = {
		name = "Rockshore West-34",
		gameInterior = 61,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2256.9609375, 690.68511962891, 11.453125},
			rotation = {0, 0, 177.71328735352},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 872
		}
	},
	[873] = {
		name = "Rockshore West-35",
		gameInterior = 60,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2228.6279296875, 690.60522460938, 11.460479736328},
			rotation = {0, 0, 183.6667175293},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 873
		}
	},
	[874] = {
		name = "Rockshore West-36",
		gameInterior = 61,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2206.4331054688, 691.88861083984, 11.4609375},
			rotation = {0, 0, 176.14659118652},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 874
		}
	},
	[875] = {
		name = "Rockshore West-37",
		gameInterior = 60,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2177.2731933594, 691.30505371094, 11.4609375},
			rotation = {0, 0, 179.90657043457},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 875
		}
	},
	[876] = {
		name = "Rockshore West-38",
		gameInterior = 60,
		type = "house",
		price = 240000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2168.7751464844, 772.31774902344, 11.4609375},
			rotation = {0, 0, 276.39068603516},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 876
		}
	},
	[877] = {
		name = "Rockshore West-39",
		gameInterior = 60,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2123.4597167969, 775.49011230469, 11.4453125},
			rotation = {0, 0, 358.17150878906},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 877
		}
	},
	[878] = {
		name = "Rockshore West-40",
		gameInterior = 61,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2043.1751708984, 775.48260498047, 11.453125},
			rotation = {0, 0, 1.6182812452316},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 878
		}
	},
	[879] = {
		name = "Rockshore West-41",
		gameInterior = 61,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2014.0004882813, 774.64239501953, 11.4609375},
			rotation = {0, 0, 1.2814980745316},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 879
		}
	},
	[880] = {
		name = "Rockshore West-42",
		gameInterior = 60,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2013.3576660156, 730.59826660156, 11.453125},
			rotation = {0, 0, 181.4499206543},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 880
		}
	},
	[881] = {
		name = "Rockshore West-43",
		gameInterior = 61,
		type = "house",
		price = 220000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2042.4742431641, 731.84130859375, 11.4609375},
			rotation = {0, 0, 178.9197845459},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 881
		}
	},
	[882] = {
		name = "Rockshore West-44",
		gameInterior = 60,
		type = "house",
		price = 230000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2093.5061035156, 730.76800537109, 11.453125},
			rotation = {0, 0, 180.48643493652},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 882
		}
	},
	[883] = {
		name = "Rockshore West-50",
		gameInterior = 72,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1846.5428466797, 741.20758056641, 11.4609375},
			rotation = {0, 0, 90.245590209961},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 883
		}
	},
	[884] = {
		name = "Rockshore West-51",
		gameInterior = 72,
		type = "house",
		price = 240000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1844.9008789063, 718.71514892578, 11.468292236328},
			rotation = {0, 0, 91.498962402344},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 884
		}
	},
	[885] = {
		name = "Rockshore West-52",
		gameInterior = 72,
		type = "house",
		price = 240000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1844.9008789063, 690.34063720703, 11.453125},
			rotation = {0, 0, 89.305641174316},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 885
		}
	},
	[886] = {
		name = "Rockshore West-53",
		gameInterior = 72,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1846.1213378906, 661.01373291016, 11.4609375},
			rotation = {0, 0, 87.738960266113},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 886
		}
	},
	[887] = {
		name = "Whitewood Estates-1",
		gameInterior = 72,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1029.8592529297, 1847.9204101563, 11.468292236328},
			rotation = {0, 0, 270.6806640625},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 887
		}
	},
	[888] = {
		name = "Whitewood Estates-2",
		gameInterior = 118,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1029.9211425781, 1876.4497070313, 11.46875},
			rotation = {0, 0, 267.86077880859},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {375.572, 1417.439, 1081.328},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 888
		}
	},
	[889] = {
		name = "Whitewood Estates-3",
		gameInterior = 119,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1028.7821044922, 1905.9897460938, 11.4609375},
			rotation = {0, 0, 269.09072875977},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {384.644, 1471.479, 1080.195},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 889
		}
	},
	[890] = {
		name = "Whitewood Estates-4",
		gameInterior = 120,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1030.0516357422, 1928.00390625, 11.468292236328},
			rotation = {0, 0, 268.15069580078},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {294.990234375, 1472.7744140625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 890
		}
	},
	[891] = {
		name = "Whitewood Estates-5",
		gameInterior = 120,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1030.2741699219, 1976.1309814453, 11.46875},
			rotation = {0, 0, 269.40365600586},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {294.990234375, 1472.7744140625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 891
		}
	},
	[892] = {
		name = "Whitewood Estates-6",
		gameInterior = 72,
		type = "house",
		price = 280000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1028.6282958984, 2005.6030273438, 11.4609375},
			rotation = {0, 0, 273.79034423828},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 892
		}
	},
	[893] = {
		name = "Whitewood Estates-7",
		gameInterior = 119,
		type = "house",
		price = 270000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1029.9674072266, 2028.1312255859, 11.4609375},
			rotation = {0, 0, 267.52334594727},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {384.644, 1471.479, 1080.195},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 893
		}
	},
	[894] = {
		name = "Whitewood Estates-8",
		gameInterior = 120,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {985.01312255859, 2030.0942382813, 11.46875},
			rotation = {0, 0, 91.428352355957},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {294.990234375, 1472.7744140625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 894
		}
	},
	[895] = {
		name = "Whitewood Estates-9",
		gameInterior = 119,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {986.15576171875, 2000.5072021484, 11.4609375},
			rotation = {0, 0, 88.921699523926},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {384.644, 1471.479, 1080.195},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 895
		}
	},
	[896] = {
		name = "Whitewood Estates-10",
		gameInterior = 120,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {984.57873535156, 1978.4722900391, 11.4609375},
			rotation = {0, 0, 91.428382873535},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {294.990234375, 1472.7744140625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 896
		}
	},
	[897] = {
		name = "Whitewood Estates-11",
		gameInterior = 118,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {985.44055175781, 1930.7176513672, 11.46875},
			rotation = {0, 0, 93.621810913086},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {375.572, 1417.439, 1081.328},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 897
		}
	},
	[898] = {
		name = "Whitewood Estates-12",
		gameInterior = 60,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {986.34393310547, 1901.1322021484, 11.4609375},
			rotation = {0, 0, 90.488471984863},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 898
		}
	},
	[899] = {
		name = "Whitewood Estates-13",
		gameInterior = 61,
		type = "house",
		price = 240000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {984.73712158203, 1878.865234375, 11.4609375},
			rotation = {0, 0, 87.981788635254},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 899
		}
	},
	[900] = {
		name = "Whitewood Estates-14",
		gameInterior = 61,
		type = "house",
		price = 240000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {929.97833251953, 1928.3511962891, 11.4609375},
			rotation = {0, 0, 263.71658325195},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 900
		}
	},
	[901] = {
		name = "Whitewood Estates-15",
		gameInterior = 60,
		type = "house",
		price = 240000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {928.34564208984, 2006.6162109375, 11.4609375},
			rotation = {0, 0, 265.28326416016},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 901
		}
	},
	[902] = {
		name = "Whitewood Estates-16",
		gameInterior = 119,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {930.21551513672, 2027.8862304688, 11.4609375},
			rotation = {0, 0, 267.78997802734},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {384.644, 1471.479, 1080.195},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 902
		}
	},
	[903] = {
		name = "Whitewood Estates-17",
		gameInterior = 120,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {886.20837402344, 2047.1442871094, 11.4609375},
			rotation = {0, 0, 88.585021972656},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {294.990234375, 1472.7744140625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 903
		}
	},
	[904] = {
		name = "Whitewood Estates-18",
		gameInterior = 72,
		type = "house",
		price = 270000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {886.29516601563, 1980.7973632813, 11.4609375},
			rotation = {0, 0, 97.045150756836},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 904
		}
	},
	[905] = {
		name = "Whitewood Estates-20",
		gameInterior = 60,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1085.0440673828, 1976.6763916016, 11.46875},
			rotation = {0, 0, 90.151741027832},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 905
		}
	},
	[906] = {
		name = "Whitewood Estates-21",
		gameInterior = 61,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1086.3500976563, 2000.9428710938, 11.4609375},
			rotation = {0, 0, 92.34504699707},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 906
		}
	},
	[907] = {
		name = "Whitewood Estates-22",
		gameInterior = 119,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1084.6726074219, 2031.7117919922, 11.4609375},
			rotation = {0, 0, 90.151664733887},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {384.644, 1471.479, 1080.195},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 907
		}
	},
	[908] = {
		name = "Whitewood Estates-30",
		gameInterior = 119,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {986.42504882813, 2271.8967285156, 11.4609375},
			rotation = {0, 0, 179.45236206055},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {384.644, 1471.479, 1080.195},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 908
		}
	},
	[909] = {
		name = "Whitewood Estates-31",
		gameInterior = 60,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {956.98400878906, 2270.6435546875, 11.46875},
			rotation = {0, 0, 181.33232116699},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 909
		}
	},
	[910] = {
		name = "Whitewood Estates-32",
		gameInterior = 61,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1032.5526123047, 2315.6362304688, 11.4609375},
			rotation = {0, 0, 354.89730834961},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 910
		}
	},
	[911] = {
		name = "Whitewood Estates-35",
		gameInterior = 118,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {986.11730957031, 2314.1115722656, 11.4609375},
			rotation = {0, 0, 89.524841308594},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {375.572, 1417.439, 1081.328},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 911
		}
	},
	[912] = {
		name = "Whitewood Estates-36",
		gameInterior = 60,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {984.93914794922, 2343.4794921875, 11.46875},
			rotation = {0, 0, 92.36824798584},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 912
		}
	},
	[913] = {
		name = "Redsand-1",
		gameInterior = 60,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1309.3757324219, 1932.3676757813, 11.4609375},
			rotation = {0, 0, 177.32946777344},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 913
		}
	},
	[914] = {
		name = "Redsand-2",
		gameInterior = 85,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1336.2806396484, 1932.1529541016, 11.4609375},
			rotation = {0, 0, 188.92282104492},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 914
		}
	},
	[915] = {
		name = "Redsand-3",
		gameInterior = 80,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1364.9588623047, 1931.6497802734, 11.468292236328},
			rotation = {0, 0, 86.133544921875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-68.701171875, 1351.806640625, 1080.2109375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 915
		}
	},
	[916] = {
		name = "Redsand-4",
		gameInterior = 85,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1365.2622070313, 1896.6987304688, 11.46875},
			rotation = {0, 0, 90.450233459473},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 916
		}
	},
	[917] = {
		name = "Redsand-5",
		gameInterior = 80,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1409.9204101563, 1897.0675048828, 11.4609375},
			rotation = {0, 0, 269.34173583984},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-68.701171875, 1351.806640625, 1080.2109375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 917
		}
	},
	[918] = {
		name = "Redsand-6",
		gameInterior = 60,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1409.3486328125, 1919.9770507813, 11.46875},
			rotation = {0, 0, 269.94476318359},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 918
		}
	},
	[919] = {
		name = "Redsand-7",
		gameInterior = 118,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1412.7066650391, 1952.001953125, 11.453125},
			rotation = {0, 0, 169.99060058594},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {375.572, 1417.439, 1081.328},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 919
		}
	},
	[920] = {
		name = "Redsand-8",
		gameInterior = 119,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1439.6224365234, 1952.0167236328, 11.4609375},
			rotation = {0, 0, 179.39073181152},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {384.644, 1471.479, 1080.195},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 920
		}
	},
	[921] = {
		name = "Redsand-9",
		gameInterior = 120,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1462.3032226563, 1951.0155029297, 11.468292236328},
			rotation = {0, 0, 179.07737731934},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {294.990234375, 1472.7744140625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 921
		}
	},
	[922] = {
		name = "Redsand-10",
		gameInterior = 119,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1464.9503173828, 1920.0532226563, 11.4609375},
			rotation = {0, 0, 88.209945678711},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {384.644, 1471.479, 1080.195},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 922
		}
	},
	[923] = {
		name = "Redsand-11",
		gameInterior = 85,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1464.7785644531, 1895.0678710938, 11.4609375},
			rotation = {0, 0, 88.209945678711},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 923
		}
	},
	[924] = {
		name = "Redsand-12",
		gameInterior = 80,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1366.1705322266, 2028.1148681641, 11.4609375},
			rotation = {0, 0, 84.426460266113},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-68.701171875, 1351.806640625, 1080.2109375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 924
		}
	},
	[925] = {
		name = "Redsand-13",
		gameInterior = 85,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1364.7744140625, 2003.7095947266, 11.4609375},
			rotation = {0, 0, 88.499885559082},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 925
		}
	},
	[926] = {
		name = "Redsand-14",
		gameInterior = 118,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1366.2150878906, 1974.4136962891, 11.4609375},
			rotation = {0, 0, 96.936622619629},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {375.572, 1417.439, 1081.328},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 926
		}
	},
	[927] = {
		name = "Redsand-15",
		gameInterior = 60,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1319.6624755859, 1976.0673828125, 11.46875},
			rotation = {0, 0, 268.62167358398},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 927
		}
	},
	[928] = {
		name = "Redsand-16",
		gameInterior = 61,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1318.8675537109, 2005.7805175781, 11.4609375},
			rotation = {0, 0, 269.56158447266},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 928
		}
	},
	[929] = {
		name = "Redsand-18",
		gameInterior = 118,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1320.041015625, 2028.1800537109, 11.468292236328},
			rotation = {0, 0, 268.62139892578},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {375.572, 1417.439, 1081.328},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 929
		}
	},
	[930] = {
		name = "Redsand-20",
		gameInterior = 119,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1595.6450195313, 2038.412109375, 11.46875},
			rotation = {0, 0, 94.38306427002},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {384.644, 1471.479, 1080.195},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 930
		}
	},
	[931] = {
		name = "Redsand-21",
		gameInterior = 120,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1595.7297363281, 2071.2299804688, 11.319854736328},
			rotation = {0, 0, 92.18970489502},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {294.990234375, 1472.7744140625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 931
		}
	},
	[932] = {
		name = "Redsand-22",
		gameInterior = 72,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1597.0810546875, 2093.6389160156, 11.3125},
			rotation = {0, 0, 95.009788513184},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 932
		}
	},
	[933] = {
		name = "Redsand-23",
		gameInterior = 72,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1595.9478759766, 2123.1030273438, 11.4609375},
			rotation = {0, 0, 88.116386413574},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 933
		}
	},
	[934] = {
		name = "Redsand-24",
		gameInterior = 85,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1640.9975585938, 2149.7692871094, 11.3125},
			rotation = {0, 0, 272.02136230469},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 934
		}
	},
	[935] = {
		name = "Redsand-25",
		gameInterior = 120,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1645.3896484375, 2127.390625, 11.203125},
			rotation = {0, 0, 193.37384033203},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {294.990234375, 1472.7744140625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 935
		}
	},
	[936] = {
		name = "Redsand-26",
		gameInterior = 60,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1639.8297119141, 2103.0634765625, 11.3125},
			rotation = {0, 0, 264.18780517578},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 936
		}
	},
	[937] = {
		name = "Redsand-27",
		gameInterior = 120,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1639.6158447266, 2075.8664550781, 11.3125},
			rotation = {0, 0, 268.88793945313},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {294.990234375, 1472.7744140625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 937
		}
	},
	[938] = {
		name = "Redsand-28",
		gameInterior = 60,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1641.2093505859, 2044.8450927734, 11.319854736328},
			rotation = {0, 0, 268.59808349609},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 938
		}
	},
	[939] = {
		name = "Redsand-30",
		gameInterior = 118,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1684.8364257813, 2123.3120117188, 11.4609375},
			rotation = {0, 0, 83.706298828125},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {375.572, 1417.439, 1081.328},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 939
		}
	},
	[940] = {
		name = "Redsand-31",
		gameInterior = 119,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1686.0582275391, 2093.8337402344, 11.4609375},
			rotation = {0, 0, 90.576316833496},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {384.644, 1471.479, 1080.195},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 940
		}
	},
	[941] = {
		name = "Redsand-32",
		gameInterior = 85,
		type = "house",
		price = 260000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1680.09375, 2069.0883789063, 11.359375},
			rotation = {0, 0, 356.88879394531},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 941
		}
	},
	[942] = {
		name = "Redsand-33",
		gameInterior = 80,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1684.7498779297, 2046.62890625, 11.46875},
			rotation = {0, 0, 88.986251831055},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-68.701171875, 1351.806640625, 1080.2109375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 942
		}
	},
	[943] = {
		name = "Redsand-35",
		gameInterior = 60,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1549.9173583984, 2096.4099121094, 11.4609375},
			rotation = {0, 0, 267.54098510742},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 943
		}
	},
	[944] = {
		name = "Redsand-36",
		gameInterior = 85,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1549.0101318359, 2125.6799316406, 11.4609375},
			rotation = {0, 0, 269.73422241211},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 944
		}
	},
	[945] = {
		name = "Redsand-37",
		gameInterior = 120,
		type = "house",
		price = 250000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1554.357421875, 2074.3203125, 11.359375},
			rotation = {0, 0, 183.88014221191},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {294.990234375, 1472.7744140625, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 15,
			dimension = 945
		}
	},
	[959] = {
		name = "Lil Probe-8",
		gameInterior = 18,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-30.293399810791, 1364.5174560547, 9.171875},
			rotation = {0, 0, 218.03570556641},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 959
		}
	},
	[960] = {
		name = "Lil Probe-2",
		gameInterior = 18,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-17.557880401611, 1391.8338623047, 9.171875},
			rotation = {0, 0, 221.79583740234},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 960
		}
	},
	[961] = {
		name = "Lil Probe-3",
		gameInterior = 18,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1.8930650949478, 1395.5717773438, 9.171875},
			rotation = {0, 0, 214.87899780273},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 961
		}
	},
	[962] = {
		name = "Lil Probe-4",
		gameInterior = 18,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {8.8645458221436, 1383.1470947266, 9.171875},
			rotation = {0, 0, 204.8522644043},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 962
		}
	},
	[963] = {
		name = "Lil Probe-5",
		gameInterior = 18,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {26.250667572021, 1362.5491943359, 9.171875},
			rotation = {0, 0, 223.33901977539},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 963
		}
	},
	[964] = {
		name = "Lil Probe-6",
		gameInterior = 18,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {25.398626327515, 1347.1806640625, 9.171875},
			rotation = {0, 0, 203.28544616699},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 964
		}
	},
	[965] = {
		name = "Lil Probe-7",
		gameInterior = 18,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {3.768054485321, 1344.8269042969, 9.171875},
			rotation = {0, 0, 244.04254150391},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 965
		}
	},
	[966] = {
		name = "Lil Probe-8",
		gameInterior = 18,
		type = "rentable",
		price = 1000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-21.386865615845, 1349.2601318359, 9.171875},
			rotation = {0, 0, 192.65534973145},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 966
		}
	},
	[967] = {
		name = "Redsands West 100",
		gameInterior = 60,
		type = "house",
		price = 180000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1542.5213623047, 2003.5631103516, 10.8203125},
			rotation = {0, 0, 1.8437043428421},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 967
		}
	},
	[968] = {
		name = "Redsands West 101",
		gameInterior = 60,
		type = "house",
		price = 180000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1548.6949462891, 2003.5231933594, 10.8203125},
			rotation = {0, 0, 0.30038920044899},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 968
		}
	},
	[969] = {
		name = "Redsands West 102",
		gameInterior = 60,
		type = "house",
		price = 180000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1548.6745605469, 1996.6921386719, 10.8203125},
			rotation = {0, 0, 176.37196350098},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 969
		}
	},
	[970] = {
		name = "Redsands West 103",
		gameInterior = 60,
		type = "house",
		price = 180000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1542.4426269531, 1996.5246582031, 10.8203125},
			rotation = {0, 0, 182.3253326416},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 970
		}
	},
	[971] = {
		name = "Redsands West 104",
		gameInterior = 61,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1542.4445800781, 2003.6402587891, 14.739588737488},
			rotation = {0, 0, 1.5536879301071},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 971
		}
	},
	[972] = {
		name = "Redsands West 105",
		gameInterior = 61,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1548.6949462891, 2003.3312988281, 14.739588737488},
			rotation = {0, 0, 359.98706054688},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 972
		}
	},
	[973] = {
		name = "Redsands West 106",
		gameInterior = 61,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1548.7669677734, 1996.5823974609, 14.739588737488},
			rotation = {0, 0, 179.21537780762},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 973
		}
	},
	[974] = {
		name = "Redsands West 107",
		gameInterior = 61,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1542.4893798828, 1996.4451904297, 14.739588737488},
			rotation = {0, 0, 181.09536743164},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 974
		}
	},
	[975] = {
		name = "Redsands West 108",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1534.9207763672, 2026.8371582031, 10.8203125},
			rotation = {0, 0, 85.841232299805},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 975
		}
	},
	[976] = {
		name = "Redsands West 109",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1541.9147949219, 2026.9517822266, 10.8203125},
			rotation = {0, 0, 267.23956298828},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 976
		}
	},
	[977] = {
		name = "Redsands West 110",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1535.2933349609, 2033.1538085938, 10.8203125},
			rotation = {0, 0, 90.227912902832},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 977
		}
	},
	[978] = {
		name = "Redsands West 111",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1541.6962890625, 2033.3194580078, 10.8203125},
			rotation = {0, 0, 266.61288452148},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 978
		}
	},
	[979] = {
		name = "Redsands West 112",
		gameInterior = 72,
		type = "house",
		price = 200000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1541.7095947266, 2033.23046875, 14.739588737488},
			rotation = {0, 0, 268.49291992188},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 979
		}
	},
	[980] = {
		name = "Redsands West 113",
		gameInterior = 72,
		type = "house",
		price = 200000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1535.1140136719, 2033.0893554688, 14.739588737488},
			rotation = {0, 0, 86.131202697754},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 980
		}
	},
	[981] = {
		name = "Redsands West 114",
		gameInterior = 72,
		type = "house",
		price = 200000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1541.9523925781, 2026.8687744141, 14.739588737488},
			rotation = {0, 0, 271.62637329102},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 981
		}
	},
	[982] = {
		name = "Redsands West 115",
		gameInterior = 72,
		type = "house",
		price = 200000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1535.0131835938, 2027.0874023438, 14.739588737488},
			rotation = {0, 0, 95.868103027344},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 982
		}
	},
	[983] = {
		name = "Redsands West 116",
		gameInterior = 72,
		type = "house",
		price = 200000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1503.1671142578, 2026.7984619141, 14.739588737488},
			rotation = {0, 0, 264.73300170898},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 983
		}
	},
	[984] = {
		name = "Redsands West 117",
		gameInterior = 72,
		type = "house",
		price = 200000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1502.7890625, 2033.1872558594, 14.739588737488},
			rotation = {0, 0, 272.56637573242},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 984
		}
	},
	[985] = {
		name = "Redsands West 118",
		gameInterior = 72,
		type = "house",
		price = 200000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1495.9802246094, 2033.2485351563, 14.739588737488},
			rotation = {0, 0, 90.541374206543},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 985
		}
	},
	[986] = {
		name = "Redsands West 119",
		gameInterior = 72,
		type = "house",
		price = 200000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1495.9296875, 2026.8651123047, 14.739588737488},
			rotation = {0, 0, 90.854713439941},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 986
		}
	},
	[987] = {
		name = "Redsands West 120",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1496.1873779297, 2026.9024658203, 10.8203125},
			rotation = {0, 0, 91.794738769531},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 987
		}
	},
	[988] = {
		name = "Redsands West 121",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1502.8771972656, 2026.9528808594, 10.8203125},
			rotation = {0, 0, 268.80639648438},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 988
		}
	},
	[989] = {
		name = "Redsands West 122",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1496.0778808594, 2033.1032714844, 10.8203125},
			rotation = {0, 0, 88.348106384277},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 989
		}
	},
	[990] = {
		name = "Redsands West 123",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1502.7452392578, 2033.5281982422, 10.8203125},
			rotation = {0, 0, 264.10638427734},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 990
		}
	},
	[991] = {
		name = "Redsands West 124",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1453.9926757813, 2026.9052734375, 10.8203125},
			rotation = {0, 0, 91.458168029785},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 991
		}
	},
	[992] = {
		name = "Redsands West 125",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1460.9794921875, 2027.0209960938, 10.8203125},
			rotation = {0, 0, 266.90316772461},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 992
		}
	},
	[993] = {
		name = "Redsands West 126",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1454.1606445313, 2033.0798339844, 10.8203125},
			rotation = {0, 0, 87.071510314941},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 993
		}
	},
	[994] = {
		name = "Redsands West 127",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1460.9259033203, 2033.1411132813, 10.8203125},
			rotation = {0, 0, 272.85656738281},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 994
		}
	},
	[995] = {
		name = "Redsands West 128",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1460.7166748047, 2033.2774658203, 14.739588737488},
			rotation = {0, 0, 272.25323486328},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 995
		}
	},
	[996] = {
		name = "Redsands West 129",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1453.8848876953, 2033.1398925781, 14.739588737488},
			rotation = {0, 0, 86.758148193359},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 996
		}
	},
	[997] = {
		name = "Redsands West 130",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1460.8514404297, 2027.2547607422, 14.739588737488},
			rotation = {0, 0, 270.05990600586},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 997
		}
	},
	[998] = {
		name = "Redsands West 131",
		gameInterior = 71,
		type = "house",
		price = 190000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1454.0056152344, 2026.8668212891, 14.739588737488},
			rotation = {0, 0, 90.518226623535},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2333.033, -1073.96, 1049.023},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 998
		}
	},
	[999] = {
		name = "Redsands West 132",
		gameInterior = 60,
		type = "house",
		price = 185000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1415.0086669922, 2027.0146484375, 10.8203125},
			rotation = {0, 0, 92.398254394531},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 999
		}
	},
	[1000] = {
		name = "Redsands West 133",
		gameInterior = 60,
		type = "house",
		price = 185000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1421.7147216797, 2026.9875488281, 10.8203125},
			rotation = {0, 0, 269.09655761719},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1000
		}
	},
	[1001] = {
		name = "Redsands West 134",
		gameInterior = 60,
		type = "house",
		price = 185000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1414.7673339844, 2033.1334228516, 10.8203125},
			rotation = {0, 0, 90.831573486328},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1001
		}
	},
	[1002] = {
		name = "Redsands West 135",
		gameInterior = 60,
		type = "house",
		price = 185000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1422.0081787109, 2033.146484375, 10.8203125},
			rotation = {0, 0, 274.10995483398},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1002
		}
	},
	[1003] = {
		name = "Redsands West 136",
		gameInterior = 60,
		type = "house",
		price = 185000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1421.8829345703, 2033.2087402344, 14.739588737488},
			rotation = {0, 0, 271.31338500977},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1003
		}
	},
	[1004] = {
		name = "Redsands West 137",
		gameInterior = 60,
		type = "house",
		price = 185000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1415.1712646484, 2033.1918945313, 14.739588737488},
			rotation = {0, 0, 91.145027160645},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1004
		}
	},
	[1005] = {
		name = "Redsands West 138",
		gameInterior = 60,
		type = "house",
		price = 185000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1421.8934326172, 2026.9010009766, 14.739588737488},
			rotation = {0, 0, 267.86669921875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1005
		}
	},
	[1006] = {
		name = "Redsands West 138",
		gameInterior = 60,
		type = "house",
		price = 185000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1415.2122802734, 2027.0157470703, 14.739588737488},
			rotation = {0, 0, 91.795104980469},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {22.79996, 1404.642, 1084.43},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1006
		}
	},
	[1007] = {
		name = "Redsands West 140",
		gameInterior = 61,
		type = "house",
		price = 195000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1414.4233398438, 1996.5866699219, 10.8203125},
			rotation = {0, 0, 182.66261291504},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1007
		}
	},
	[1008] = {
		name = "Redsands West 141",
		gameInterior = 61,
		type = "house",
		price = 195000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1414.6201171875, 2003.4836425781, 10.8203125},
			rotation = {0, 0, 359.67422485352},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1008
		}
	},
	[1009] = {
		name = "Redsands West 142",
		gameInterior = 61,
		type = "house",
		price = 195000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1408.1645507813, 1996.5474853516, 10.8203125},
			rotation = {0, 0, 178.27583312988},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1009
		}
	},
	[1010] = {
		name = "Redsands West 143",
		gameInterior = 61,
		type = "house",
		price = 195000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1408.3154296875, 2003.6488037109, 10.8203125},
			rotation = {0, 0, 2.8075330257416},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1010
		}
	},
	[1011] = {
		name = "Redsands West 144",
		gameInterior = 61,
		type = "house",
		price = 195000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1408.2132568359, 2003.587890625, 14.739588737488},
			rotation = {0, 0, 0.32426071166992},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1011
		}
	},
	[1012] = {
		name = "Redsands West 145",
		gameInterior = 61,
		type = "house",
		price = 195000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1408.2810058594, 1996.6175537109, 14.739588737488},
			rotation = {0, 0, 182.66261291504},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1012
		}
	},
	[1013] = {
		name = "Redsands West 146",
		gameInterior = 61,
		type = "house",
		price = 195000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1414.4652099609, 2003.5236816406, 14.739588737488},
			rotation = {0, 0, 0.010918967425823},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1013
		}
	},
	[1014] = {
		name = "Redsands West 147",
		gameInterior = 61,
		type = "house",
		price = 195000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1414.5223388672, 1996.8793945313, 14.739588737488},
			rotation = {0, 0, 181.74598693848},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {227.0888671875, 1114.2666015625, 1080.9969482422},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1014
		}
	},
	[1016] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2659.1967773438, 1979.2034912109, 14.116060256958},
			rotation = {0, 0, 183.57936096191},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1016
		}
	},
	[1017] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2651.6271972656, 1979.4156494141, 14.116060256958},
			rotation = {0, 0, 182.03610229492},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1017
		}
	},
	[1018] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2650.0981445313, 1979.4559326172, 14.116060256958},
			rotation = {0, 0, 182.66275024414},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1018
		}
	},
	[1019] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2642.2834472656, 1979.1345214844, 14.116060256958},
			rotation = {0, 0, 178.27601623535},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1019
		}
	},
	[1020] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2640.4135742188, 1979.2080078125, 14.116060256958},
			rotation = {0, 0, 178.27601623535},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1020
		}
	},
	[1021] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2633.3098144531, 1979.1710205078, 14.116060256958},
			rotation = {0, 0, 173.57598876953},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1021
		}
	},
	[1022] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2631.1923828125, 1979.2052001953, 14.116060256958},
			rotation = {0, 0, 178.58934020996},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1022
		}
	},
	[1023] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2623.75, 1979.2517089844, 14.116060256958},
			rotation = {0, 0, 177.02265930176},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1023
		}
	},
	[1024] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2623.8071289063, 1979.3415527344, 10.8203125},
			rotation = {0, 0, 176.08267211914},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1024
		}
	},
	[1025] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2631.1779785156, 1979.2144775391, 10.8203125},
			rotation = {0, 0, 181.43292236328},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1025
		}
	},
	[1026] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2633.1647949219, 1979.2172851563, 10.8203125},
			rotation = {0, 0, 181.43292236328},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1026
		}
	},
	[1027] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2640.583984375, 1979.3293457031, 10.8203125},
			rotation = {0, 0, 183.28950500488},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1027
		}
	},
	[1028] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2642.3933105469, 1979.2873535156, 10.8203125},
			rotation = {0, 0, 181.09614562988},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1028
		}
	},
	[1029] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2650.0002441406, 1979.05078125, 10.8203125},
			rotation = {0, 0, 179.81941223145},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1029
		}
	},
	[1030] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2651.5329589844, 1979.2105712891, 10.8203125},
			rotation = {0, 0, 180.4461517334},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1030
		}
	},
	[1031] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2659.2875976563, 1979.1429443359, 10.820188522339},
			rotation = {0, 0, 167.64849853516},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1031
		}
	},
	[1032] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2653.0510253906, 2018.7608642578, 10.818664550781},
			rotation = {0, 0, 2.7610261440277},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1032
		}
	},
	[1033] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2645.3842773438, 2018.8037109375, 10.816792488098},
			rotation = {0, 0, 1.1943517923355},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1033
		}
	},
	[1034] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2643.8725585938, 2018.9036865234, 10.816423416138},
			rotation = {0, 0, 358.06100463867},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1034
		}
	},
	[1035] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2636.2521972656, 2018.8677978516, 10.8203125},
			rotation = {0, 0, 358.97760009766},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1035
		}
	},
	[1036] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2634.3571777344, 2018.6964111328, 10.8203125},
			rotation = {0, 0, 356.15759277344},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1036
		}
	},
	[1037] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2626.8857421875, 2018.8963623047, 10.8203125},
			rotation = {0, 0, 358.66430664063},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1037
		}
	},
	[1038] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2624.9697265625, 2019.0041503906, 10.8203125},
			rotation = {0, 0, 354.27758789063},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1038
		}
	},
	[1039] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2617.3947753906, 2019.0557861328, 10.8203125},
			rotation = {0, 0, 359.29104614258},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1039
		}
	},
	[1040] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2617.625, 2018.9290771484, 14.116060256958},
			rotation = {0, 0, 2.0877265930176},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1040
		}
	},
	[1041] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2624.9304199219, 2018.9599609375, 14.116060256958},
			rotation = {0, 0, 0.83438020944595},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1041
		}
	},
	[1042] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2626.7014160156, 2018.8510742188, 14.116060256958},
			rotation = {0, 0, 0.52104526758194},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1042
		}
	},
	[1043] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2634.603515625, 2018.7879638672, 14.116060256958},
			rotation = {0, 0, 2.7143895626068},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1043
		}
	},
	[1044] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2636.0578613281, 2018.7481689453, 14.116060256958},
			rotation = {0, 0, 357.38766479492},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1044
		}
	},
	[1045] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2643.5712890625, 2018.7576904297, 14.116060256958},
			rotation = {0, 0, 356.13433837891},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1045
		}
	},
	[1046] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2645.3015136719, 2018.6815185547, 14.116060256958},
			rotation = {0, 0, 11.487767219543},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1046
		}
	},
	[1047] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2652.9860839844, 2019.0168457031, 14.116060256958},
			rotation = {0, 0, 359.58096313477},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1047
		}
	},
	[1048] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2650.5427246094, 2029.7200927734, 14.116060256958},
			rotation = {0, 0, 177.24258422852},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1048
		}
	},
	[1049] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2648.2277832031, 2029.6003417969, 14.116060256958},
			rotation = {0, 0, 177.24258422852},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1049
		}
	},
	[1050] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2640.9814453125, 2029.5971679688, 14.116060256958},
			rotation = {0, 0, 181.00263977051},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1050
		}
	},
	[1051] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2639.19140625, 2029.6242675781, 14.116060256958},
			rotation = {0, 0, 181.31596374512},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1051
		}
	},
	[1052] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2631.5356445313, 2029.5408935547, 14.116060256958},
			rotation = {0, 0, 179.74922180176},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1052
		}
	},
	[1053] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2629.9235839844, 2029.5723876953, 14.116060256958},
			rotation = {0, 0, 181.00256347656},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1053
		}
	},
	[1054] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2621.9377441406, 2029.6619873047, 14.116060256958},
			rotation = {0, 0, 184.76268005371},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1054
		}
	},
	[1055] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2700,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2619.8850097656, 2029.7370605469, 14.116060256958},
			rotation = {0, 0, 173.1692199707},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1055
		}
	},
	[1056] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.435546875, 2030.0008544922, 10.8203125},
			rotation = {0, 0, 183.17259216309},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1056
		}
	},
	[1057] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2622.2426757813, 2029.7436523438, 10.8203125},
			rotation = {0, 0, 183.17259216309},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1057
		}
	},
	[1058] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2629.6437988281, 2029.6000976563, 10.8203125},
			rotation = {0, 0, 177.82246398926},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1058
		}
	},
	[1059] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2631.7963867188, 2029.9028320313, 10.8203125},
			rotation = {0, 0, 182.52252197266},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1059
		}
	},
	[1060] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2639.1491699219, 2029.5089111328, 10.8203125},
			rotation = {0, 0, 180.64250183105},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1060
		}
	},
	[1061] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2640.8193359375, 2029.5197753906, 10.8203125},
			rotation = {0, 0, 187.53596496582},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1061
		}
	},
	[1062] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2648.2687988281, 2029.4215087891, 10.812986373901},
			rotation = {0, 0, 180.64260864258},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1062
		}
	},
	[1063] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2650.0703125, 2029.5334472656, 10.812986373901},
			rotation = {0, 0, 181.26927185059},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1063
		}
	},
	[1064] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2624.1298828125, 2039.3630371094, 14.116060256958},
			rotation = {0, 0, 92.955223083496},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1064
		}
	},
	[1065] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2624.1059570313, 2047.0080566406, 14.116060256958},
			rotation = {0, 0, 91.388534545898},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1065
		}
	},
	[1066] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2624.0988769531, 2048.8530273438, 14.116060256958},
			rotation = {0, 0, 90.448516845703},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1066
		}
	},
	[1067] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2624.0151367188, 2056.0847167969, 14.116060256958},
			rotation = {0, 0, 90.135139465332},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1067
		}
	},
	[1068] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2623.8903808594, 2057.9450683594, 14.116060256958},
			rotation = {0, 0, 92.015167236328},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1068
		}
	},
	[1069] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2623.9887695313, 2065.671875, 14.116060256958},
			rotation = {0, 0, 88.568450927734},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1069
		}
	},
	[1070] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2623.8779296875, 2067.4035644531, 14.116060256958},
			rotation = {0, 0, 84.495086669922},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1070
		}
	},
	[1071] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2623.9675292969, 2074.9846191406, 14.116060256958},
			rotation = {0, 0, 93.581840515137},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1071
		}
	},
	[1072] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.4482421875, 2071.9814453125, 14.116060256958},
			rotation = {0, 0, 274.37686157227},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1072
		}
	},
	[1073] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.333984375, 2070.2424316406, 14.116060256958},
			rotation = {0, 0, 259.33673095703},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1073
		}
	},
	[1074] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.4421386719, 2062.6540527344, 14.116060256958},
			rotation = {0, 0, 275.63018798828},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1074
		}
	},
	[1075] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.3557128906, 2061.0270996094, 14.116060256958},
			rotation = {0, 0, 272.18353271484},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1075
		}
	},
	[1076] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.2873535156, 2053.5209960938, 14.116060256958},
			rotation = {0, 0, 272.18362426758},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1076
		}
	},
	[1077] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.314453125, 2051.6904296875, 14.116060256958},
			rotation = {0, 0, 268.11029052734},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1077
		}
	},
	[1078] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.248046875, 2043.9827880859, 14.116060256958},
			rotation = {0, 0, 274.37701416016},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1078
		}
	},
	[1079] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.2634277344, 2042.0812988281, 14.116060256958},
			rotation = {0, 0, 275.63034057617},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1079
		}
	},
	[1080] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2624.0637207031, 2039.1499023438, 10.8203125},
			rotation = {0, 0, 89.218605041504},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1080
		}
	},
	[1081] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2623.9841308594, 2046.974609375, 10.812986373901},
			rotation = {0, 0, 90.47193145752},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1081
		}
	},
	[1082] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2624.0803222656, 2048.6765136719, 10.812986373901},
			rotation = {0, 0, 80.758491516113},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1082
		}
	},
	[1083] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2623.8322753906, 2056.0427246094, 10.812986373901},
			rotation = {0, 0, 90.785270690918},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1083
		}
	},
	[1084] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2624.1276855469, 2058.0070800781, 10.812986373901},
			rotation = {0, 0, 93.291961669922},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1084
		}
	},
	[1085] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2624.0048828125, 2065.494140625, 10.8203125},
			rotation = {0, 0, 90.471908569336},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1085
		}
	},
	[1086] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2624.0178222656, 2067.2160644531, 10.8203125},
			rotation = {0, 0, 88.591888427734},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1086
		}
	},
	[1087] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2624.1938476563, 2074.8181152344, 10.812986373901},
			rotation = {0, 0, 92.978637695313},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1087
		}
	},
	[1088] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.3571777344, 2072.1569824219, 10.8203125},
			rotation = {0, 0, 269.67700195313},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1088
		}
	},
	[1089] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.1645507813, 2070.0695800781, 10.8203125},
			rotation = {0, 0, 275.31701660156},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1089
		}
	},
	[1090] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.5966796875, 2062.7268066406, 10.812986373901},
			rotation = {0, 0, 269.990234375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1090
		}
	},
	[1091] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.4887695313, 2060.8732910156, 10.812986373901},
			rotation = {0, 0, 268.42358398438},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1091
		}
	},
	[1092] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.4763183594, 2053.4541015625, 10.812986373901},
			rotation = {0, 0, 273.75048828125},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1092
		}
	},
	[1093] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.2971191406, 2051.578125, 10.8203125},
			rotation = {0, 0, 270.30377197266},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1093
		}
	},
	[1094] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.515625, 2044.3531494141, 10.8203125},
			rotation = {0, 0, 269.36386108398},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1094
		}
	},
	[1095] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.4001464844, 2042.3503417969, 10.8203125},
			rotation = {0, 0, 264.35052490234},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1095
		}
	},
	[1096] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2610.1760253906, 2133.1606445313, 14.116060256958},
			rotation = {0, 0, 269.96722412109},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1096
		}
	},
	[1097] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2610.2202148438, 2134.994140625, 14.116060256958},
			rotation = {0, 0, 269.02722167969},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1097
		}
	},
	[1098] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2610.220703125, 2142.4213867188, 14.116060256958},
			rotation = {0, 0, 270.28057861328},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1098
		}
	},
	[1099] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2610.1877441406, 2144.1452636719, 14.116060256958},
			rotation = {0, 0, 269.65390014648},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1099
		}
	},
	[1100] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2610.2280273438, 2151.7504882813, 14.116060256958},
			rotation = {0, 0, 270.9072265625},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1100
		}
	},
	[1101] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2610.27734375, 2153.4970703125, 14.116060256958},
			rotation = {0, 0, 268.08721923828},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1101
		}
	},
	[1102] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2610.2607421875, 2160.9946289063, 14.116060256958},
			rotation = {0, 0, 272.78729248047},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1102
		}
	},
	[1103] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2610.2912597656, 2162.7211914063, 14.116060256958},
			rotation = {0, 0, 269.02722167969},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1103
		}
	},
	[1104] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.7580566406, 2165.6650390625, 14.116060256958},
			rotation = {0, 0, 90.738929748535},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1104
		}
	},
	[1105] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.5959472656, 2158.0966796875, 14.116060256958},
			rotation = {0, 0, 93.558975219727},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1105
		}
	},
	[1106] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.5905761719, 2156.3901367188, 14.116060256958},
			rotation = {0, 0, 89.798927307129},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1106
		}
	},
	[1108] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.8596191406, 2148.7468261719, 14.116060256958},
			rotation = {0, 0, 94.812309265137},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1108
		}
	},
	[1109] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.9477539063, 2146.9750976563, 14.116060256958},
			rotation = {0, 0, 92.618957519531},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1109
		}
	},
	[1110] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.5397949219, 2139.6103515625, 14.116060256958},
			rotation = {0, 0, 92.932281494141},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1110
		}
	},
	[1111] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.6540527344, 2137.5185546875, 14.116060256958},
			rotation = {0, 0, 84.158866882324},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1111
		}
	},
	[1112] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.7509765625, 2130.2463378906, 14.116060256958},
			rotation = {0, 0, 91.992263793945},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1112
		}
	},
	[1113] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2609.853515625, 2162.9306640625, 10.8203125},
			rotation = {0, 0, 271.80056762695},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1113
		}
	},
	[1114] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2609.8552246094, 2160.9821777344, 10.8203125},
			rotation = {0, 0, 265.22052001953},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1114
		}
	},
	[1115] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2609.8840332031, 2153.4267578125, 10.8203125},
			rotation = {0, 0, 272.74044799805},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1115
		}
	},
	[1116] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2609.9128417969, 2151.9096679688, 10.8203125},
			rotation = {0, 0, 258.64031982422},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1116
		}
	},
	[1117] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2609.7678222656, 2144.1069335938, 10.8203125},
			rotation = {0, 0, 268.98037719727},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1117
		}
	},
	[1118] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2609.9497070313, 2142.5776367188, 10.8203125},
			rotation = {0, 0, 262.08706665039},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1118
		}
	},
	[1119] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2610.0439453125, 2134.7346191406, 10.8203125},
			rotation = {0, 0, 273.68054199219},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1119
		}
	},
	[1120] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2609.8637695313, 2133.3334960938, 10.8203125},
			rotation = {0, 0, 266.78717041016},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1120
		}
	},
	[1121] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.8256835938, 2130.3142089844, 10.8203125},
			rotation = {0, 0, 88.812225341797},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1121
		}
	},
	[1122] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.7756347656, 2137.630859375, 10.8203125},
			rotation = {0, 0, 92.572257995605},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1122
		}
	},
	[1123] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.8686523438, 2139.609375, 10.8203125},
			rotation = {0, 0, 86.618858337402},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1123
		}
	},
	[1124] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.6687011719, 2146.8745117188, 10.8203125},
			rotation = {0, 0, 91.63224029541},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1124
		}
	},
	[1125] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.7390136719, 2148.8088378906, 10.8203125},
			rotation = {0, 0, 91.945579528809},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1125
		}
	},
	[1126] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.5244140625, 2156.3937988281, 10.8203125},
			rotation = {0, 0, 92.258888244629},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1126
		}
	},
	[1127] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.5256347656, 2158.2941894531, 10.8203125},
			rotation = {0, 0, 83.485481262207},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1127
		}
	},
	[1128] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.5842285156, 2165.5009765625, 10.812986373901},
			rotation = {0, 0, 87.26887512207},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1128
		}
	},
	[1129] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2608.1857910156, 2195.7717285156, 14.116060256958},
			rotation = {0, 0, 178.47319030762},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1129
		}
	},
	[1130] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2616.0561523438, 2195.6843261719, 14.116060256958},
			rotation = {0, 0, 180.03987121582},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1130
		}
	},
	[1132] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2617.8205566406, 2195.6479492188, 14.116060256958},
			rotation = {0, 0, 179.09983825684},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1132
		}
	},
	[1133] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2625.59765625, 2195.7980957031, 14.116060256958},
			rotation = {0, 0, 181.29315185547},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1133
		}
	},
	[1134] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2627.46875, 2195.6633300781, 14.116060256958},
			rotation = {0, 0, 172.83305358887},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1134
		}
	},
	[1135] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2634.4619140625, 2195.6640625, 14.116060256958},
			rotation = {0, 0, 179.72647094727},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1135
		}
	},
	[1136] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2636.0600585938, 2195.5954589844, 14.116060256958},
			rotation = {0, 0, 179.72647094727},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1136
		}
	},
	[1137] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2643.7990722656, 2195.83984375, 14.116060256958},
			rotation = {0, 0, 176.59310913086},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1137
		}
	},
	[1138] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2640.8017578125, 2185.3278808594, 14.116060256958},
			rotation = {0, 0, 0.18485653400421},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1138
		}
	},
	[1139] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2639.095703125, 2185.1870117188, 14.116060256958},
			rotation = {0, 0, 0.18485653400421},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1139
		}
	},
	[1140] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2631.3630371094, 2185.4802246094, 14.116060256958},
			rotation = {0, 0, 4.2582583427429},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1140
		}
	},
	[1141] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2629.9318847656, 2185.4294433594, 14.116060256958},
			rotation = {0, 0, 0.1849180161953},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1141
		}
	},
	[1142] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2622.5219726563, 2185.1928710938, 14.116060256958},
			rotation = {0, 0, 352.66488647461},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1142
		}
	},
	[1143] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.5969238281, 2185.2399902344, 14.116060256958},
			rotation = {0, 0, 2.0649683475494},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1143
		}
	},
	[1144] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2612.7744140625, 2185.2214355469, 14.116060256958},
			rotation = {0, 0, 2.3783512115479},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1144
		}
	},
	[1145] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2611.1110839844, 2185.2880859375, 14.116060256958},
			rotation = {0, 0, 7.0784025192261},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1145
		}
	},
	[1146] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2601.93359375, 2183.3029785156, 14.116060256958},
			rotation = {0, 0, 93.55916595459},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1146
		}
	},
	[1147] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2602.0493164063, 2185.2502441406, 14.116060256958},
			rotation = {0, 0, 92.932495117188},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1147
		}
	},
	[1148] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2602.0478515625, 2192.658203125, 14.116060256958},
			rotation = {0, 0, 93.559158325195},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1148
		}
	},
	[1149] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2602.0341796875, 2194.453125, 14.116060256958},
			rotation = {0, 0, 79.459022521973},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1149
		}
	},
	[1150] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2601.9409179688, 2202.1870117188, 14.116060256958},
			rotation = {0, 0, 92.305816650391},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1150
		}
	},
	[1151] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2602.0971679688, 2203.8017578125, 14.116060256958},
			rotation = {0, 0, 94.812507629395},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1151
		}
	},
	[1152] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2601.9528808594, 2211.2309570313, 14.116060256958},
			rotation = {0, 0, 91.052467346191},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1152
		}
	},
	[1153] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2602.0151367188, 2213.1652832031, 14.116060256958},
			rotation = {0, 0, 89.799125671387},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1153
		}
	},
	[1154] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.1159667969, 2216.0563964844, 14.116060256958},
			rotation = {0, 0, 269.34078979492},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1154
		}
	},
	[1155] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.318359375, 2208.5825195313, 14.116060256958},
			rotation = {0, 0, 269.65417480469},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1155
		}
	},
	[1156] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.3850097656, 2206.7600097656, 14.116060256958},
			rotation = {0, 0, 270.59414672852},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1156
		}
	},
	[1157] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.453125, 2199.3884277344, 14.116060256958},
			rotation = {0, 0, 271.84753417969},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1157
		}
	},
	[1158] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.6201171875, 2197.3781738281, 14.116060256958},
			rotation = {0, 0, 270.28091430664},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1158
		}
	},
	[1159] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.3820800781, 2189.8525390625, 14.116060256958},
			rotation = {0, 0, 266.83422851563},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1159
		}
	},
	[1160] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.2990722656, 2187.8637695313, 14.116060256958},
			rotation = {0, 0, 274.98107910156},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1160
		}
	},
	[1161] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.4692382813, 2180.55859375, 14.116060256958},
			rotation = {0, 0, 267.77432250977},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1161
		}
	},
	[1162] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2577.0166015625, 2202.8017578125, 14.116060256958},
			rotation = {0, 0, 356.76184082031},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1162
		}
	},
	[1163] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2575.1044921875, 2202.6560058594, 14.116060256958},
			rotation = {0, 0, 8.355278968811},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1163
		}
	},
	[1164] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2567.734375, 2203.0080566406, 14.116060256958},
			rotation = {0, 0, 0.52196055650711},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1164
		}
	},
	[1165] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2565.5856933594, 2202.7644042969, 14.116060256958},
			rotation = {0, 0, 5.5353398323059},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1165
		}
	},
	[1166] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2558.3627929688, 2202.7043457031, 14.116060256958},
			rotation = {0, 0, 10.86209487915},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1166
		}
	},
	[1167] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2556.4113769531, 2202.7434082031, 14.116060256958},
			rotation = {0, 0, 358.32864379883},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1167
		}
	},
	[1168] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2548.6867675781, 2202.8312988281, 14.116060256958},
			rotation = {0, 0, 4.2820620536804},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1168
		}
	},
	[1169] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2547.0478515625, 2202.9582519531, 14.116060256958},
			rotation = {0, 0, 357.388671875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1169
		}
	},
	[1170] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2544.4792480469, 2213.3957519531, 14.116060256958},
			rotation = {0, 0, 181.92031860352},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1170
		}
	},
	[1171] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2551.958984375, 2213.1826171875, 14.116060256958},
			rotation = {0, 0, 177.84690856934},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1171
		}
	},
	[1172] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2553.5083007813, 2213.2250976563, 14.116060256958},
			rotation = {0, 0, 181.60697937012},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1172
		}
	},
	[1173] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2561.2553710938, 2213.2944335938, 14.116060256958},
			rotation = {0, 0, 179.41348266602},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1173
		}
	},
	[1174] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2562.9838867188, 2213.2734375, 14.116060256958},
			rotation = {0, 0, 175.65350341797},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1174
		}
	},
	[1175] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2570.2124023438, 2213.1687011719, 14.116060256958},
			rotation = {0, 0, 180.35353088379},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1175
		}
	},
	[1176] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2572.3071289063, 2213.2937011719, 14.116060256958},
			rotation = {0, 0, 175.3399810791},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1176
		}
	},
	[1177] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2579.9565429688, 2213.3542480469, 14.116060256958},
			rotation = {0, 0, 175.34001159668},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1177
		}
	},
	[1178] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.8591308594, 2233.2937011719, 14.116060256958},
			rotation = {0, 0, 269.94421386719},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1178
		}
	},
	[1179] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.9584960938, 2240.453125, 14.116060256958},
			rotation = {0, 0, 271.82415771484},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1179
		}
	},
	[1180] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2647.0688476563, 2242.4145507813, 14.116060256958},
			rotation = {0, 0, 271.82415771484},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1180
		}
	},
	[1181] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.9235839844, 2249.8674316406, 14.116060256958},
			rotation = {0, 0, 268.06396484375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1181
		}
	},
	[1182] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.9575195313, 2251.7841796875, 14.116060256958},
			rotation = {0, 0, 269.31726074219},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1182
		}
	},
	[1183] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2647.0710449219, 2259.0786132813, 14.116060256958},
			rotation = {0, 0, 272.76403808594},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1183
		}
	},
	[1184] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.9975585938, 2261.0307617188, 14.116060256958},
			rotation = {0, 0, 271.82400512695},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1184
		}
	},
	[1185] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2647.0463867188, 2268.482421875, 14.116060256958},
			rotation = {0, 0, 269.00384521484},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1185
		}
	},
	[1186] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.3549804688, 2265.7111816406, 14.116060256958},
			rotation = {0, 0, 86.328750610352},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1186
		}
	},
	[1187] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.3359375, 2263.7785644531, 14.116060256958},
			rotation = {0, 0, 86.328750610352},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1187
		}
	},
	[1188] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.15625, 2256.4379882813, 14.116060256958},
			rotation = {0, 0, 88.522163391113},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1188
		}
	},
	[1189] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.2177734375, 2254.2932128906, 14.116060256958},
			rotation = {0, 0, 87.582160949707},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1189
		}
	},
	[1190] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.4167480469, 2247.0432128906, 14.116060256958},
			rotation = {0, 0, 86.015480041504},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1190
		}
	},
	[1191] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.3393554688, 2245.2216796875, 14.116060256958},
			rotation = {0, 0, 89.462181091309},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1191
		}
	},
	[1192] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.3435058594, 2237.6945800781, 14.116060256958},
			rotation = {0, 0, 90.402191162109},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1192
		}
	},
	[1193] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.3830566406, 2235.7609863281, 14.116060256958},
			rotation = {0, 0, 88.835502624512},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1193
		}
	},
	[1194] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.7556152344, 2232.8842773438, 10.75414276123},
			rotation = {0, 0, 277.75390625},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1194
		}
	},
	[1195] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.8515625, 2240.3500976563, 10.753439903259},
			rotation = {0, 0, 271.48718261719},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1195
		}
	},
	[1196] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.9753417969, 2242.3334960938, 10.752532958984},
			rotation = {0, 0, 266.16046142578},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1196
		}
	},
	[1197] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.8557128906, 2249.7646484375, 10.786413192749},
			rotation = {0, 0, 270.86044311523},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1197
		}
	},
	[1198] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2647.1108398438, 2251.49609375, 10.804156303406},
			rotation = {0, 0, 269.92047119141},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1198
		}
	},
	[1199] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.794921875, 2259.1442871094, 10.797163963318},
			rotation = {0, 0, 270.86047363281},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1199
		}
	},
	[1200] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.9597167969, 2260.8898925781, 10.806541442871},
			rotation = {0, 0, 267.10040283203},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1200
		}
	},
	[1201] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.8134765625, 2268.7170410156, 10.8203125},
			rotation = {0, 0, 270.23364257813},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1201
		}
	},
	[1202] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.4521484375, 2265.6896972656, 10.8203125},
			rotation = {0, 0, 83.485176086426},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1202
		}
	},
	[1203] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.4143066406, 2263.7758789063, 10.8203125},
			rotation = {0, 0, 90.065246582031},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1203
		}
	},
	[1204] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.5571289063, 2256.3796386719, 10.78231048584},
			rotation = {0, 0, 91.005241394043},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1204
		}
	},
	[1205] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.3813476563, 2254.6708984375, 10.77313041687},
			rotation = {0, 0, 92.885269165039},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1205
		}
	},
	[1206] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.3198242188, 2247.2282714844, 10.725331306458},
			rotation = {0, 0, 93.51197052002},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1206
		}
	},
	[1207] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2800,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.2043457031, 2245.2502441406, 10.71470451355},
			rotation = {0, 0, 90.065277099609},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1207
		}
	},
	[1208] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.3708496094, 2237.5712890625, 10.779106140137},
			rotation = {0, 0, 89.125267028809},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1208
		}
	},
	[1209] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2657.2529296875, 2235.7236328125, 10.79998588562},
			rotation = {0, 0, 89.125267028809},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1209
		}
	},
	[1210] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2643.6770019531, 2196.0510253906, 10.8203125},
			rotation = {0, 0, 181.24612426758},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1210
		}
	},
	[1211] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2636.3681640625, 2196.203125, 10.8203125},
			rotation = {0, 0, 182.49945068359},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1211
		}
	},
	[1212] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2634.5002441406, 2196.1821289063, 10.8203125},
			rotation = {0, 0, 172.47265625},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1212
		}
	},
	[1213] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2627.0935058594, 2195.8955078125, 10.8203125},
			rotation = {0, 0, 181.87278747559},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1213
		}
	},
	[1214] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2625.2263183594, 2195.9719238281, 10.8203125},
			rotation = {0, 0, 172.78602600098},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1214
		}
	},
	[1215] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2617.7836914063, 2196.0556640625, 10.8203125},
			rotation = {0, 0, 183.75282287598},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1215
		}
	},
	[1216] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2615.8937988281, 2195.9436035156, 10.812986373901},
			rotation = {0, 0, 177.48606872559},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1216
		}
	},
	[1217] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2608.2390136719, 2195.7976074219, 10.812986373901},
			rotation = {0, 0, 176.23275756836},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1217
		}
	},
	[1218] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2602.1833496094, 2213.0642089844, 10.8203125},
			rotation = {0, 0, 90.088844299316},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1218
		}
	},
	[1219] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2601.8679199219, 2211.4311523438, 10.8203125},
			rotation = {0, 0, 90.088844299316},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1219
		}
	},
	[1220] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2601.8581542969, 2203.9487304688, 10.8203125},
			rotation = {0, 0, 91.342193603516},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1220
		}
	},
	[1221] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2601.8542480469, 2202.0444335938, 10.826347351074},
			rotation = {0, 0, 90.088836669922},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1221
		}
	},
	[1222] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2602.0627441406, 2194.2709960938, 10.812986373901},
			rotation = {0, 0, 86.955497741699},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1222
		}
	},
	[1223] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2602.2331542969, 2192.8015136719, 10.812986373901},
			rotation = {0, 0, 94.788909912109},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1223
		}
	},
	[1224] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2601.8881835938, 2185.4587402344, 10.812986373901},
			rotation = {0, 0, 92.908889770508},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1224
		}
	},
	[1225] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2602.0075683594, 2183.3168945313, 10.812986373901},
			rotation = {0, 0, 100.42895507813},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1225
		}
	},
	[1226] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2610.9924316406, 2185.3735351563, 10.812986373901},
			rotation = {0, 0, 3.318103313446},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1226
		}
	},
	[1227] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2613.1711425781, 2185.3393554688, 10.812986373901},
			rotation = {0, 0, 350.78463745117},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1227
		}
	},
	[1228] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2620.5393066406, 2185.083984375, 10.8203125},
			rotation = {0, 0, 2.6915018558502},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1228
		}
	},
	[1229] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2622.1228027344, 2185.1198730469, 10.8203125},
			rotation = {0, 0, 356.73809814453},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1229
		}
	},
	[1230] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2629.9169921875, 2185.5434570313, 10.8203125},
			rotation = {0, 0, 1.1248340606689},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1230
		}
	},
	[1231] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2631.8159179688, 2185.5107421875, 10.8203125},
			rotation = {0, 0, 0.81153321266174},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1231
		}
	},
	[1232] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2639.2082519531, 2185.31640625, 10.8203125},
			rotation = {0, 0, 0.18491120636463},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1232
		}
	},
	[1233] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2641.009765625, 2185.3359375, 10.8203125},
			rotation = {0, 0, 353.60485839844},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1233
		}
	},
	[1234] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 85,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.44921875, 2180.5134277344, 10.812986373901},
			rotation = {0, 0, 268.69079589844},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-42.49, 1407.644, 1084.43},
			rotation = {0, 0, 0},
			interior = 8,
			dimension = 1234
		}
	},
	[1235] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.4018554688, 2187.9221191406, 10.82531452179},
			rotation = {0, 0, 281.53762817383},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1235
		}
	},
	[1236] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.3835449219, 2189.8532714844, 10.8203125},
			rotation = {0, 0, 263.99084472656},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1236
		}
	},
	[1237] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.1293945313, 2197.4282226563, 10.8203125},
			rotation = {0, 0, 266.18420410156},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1237
		}
	},
	[1238] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.0385742188, 2199.3369140625, 10.8203125},
			rotation = {0, 0, 264.93078613281},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1238
		}
	},
	[1239] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.3657226563, 2206.6215820313, 10.8203125},
			rotation = {0, 0, 265.244140625},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1239
		}
	},
	[1240] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.3071289063, 2208.6813964844, 10.8203125},
			rotation = {0, 0, 273.70416259766},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1240
		}
	},
	[1241] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2591.4118652344, 2215.8703613281, 10.8203125},
			rotation = {0, 0, 269.94415283203},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1241
		}
	},
	[1242] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2579.634765625, 2213.2819824219, 10.8203125},
			rotation = {0, 0, 182.21002197266},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1242
		}
	},
	[1243] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2572.1010742188, 2213.3742675781, 10.8203125},
			rotation = {0, 0, 178.44990539551},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1243
		}
	},
	[1244] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2570.4294433594, 2213.4709472656, 10.8203125},
			rotation = {0, 0, 170.61651611328},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1244
		}
	},
	[1245] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2562.9194335938, 2213.34765625, 10.8203125},
			rotation = {0, 0, 181.89665222168},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1245
		}
	},
	[1246] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2561.2316894531, 2213.4448242188, 10.8203125},
			rotation = {0, 0, 177.82327270508},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1246
		}
	},
	[1247] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2553.6479492188, 2213.5380859375, 10.8203125},
			rotation = {0, 0, 178.13661193848},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1247
		}
	},
	[1248] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2551.9780273438, 2213.47265625, 10.8203125},
			rotation = {0, 0, 179.38995361328},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1248
		}
	},
	[1249] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 96,
		type = "rentable",
		price = 2900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2544.3439941406, 2213.4582519531, 10.8203125},
			rotation = {0, 0, 176.25653076172},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2269.576171875, -1210.4306640625, 1047.5625},
			rotation = {0, 0, 0},
			interior = 10,
			dimension = 1249
		}
	},
	[1257] = {
		name = "V Rock Hotel-6",
		gameInterior = 72,
		type = "rentable",
		price = 3500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2212.0876464844, -1194.376953125, 1029.796875},
			rotation = {0, 0, 267.79803466797},
			interior = 15,
			dimension = 1250
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 1257
		}
	},
	[1260] = {
		name = "V Rock Hotel-9",
		gameInterior = 72,
		type = "rentable",
		price = 3500,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2223.2492675781, -1182.705078125, 1029.796875},
			rotation = {0, 0, 89.533111572266},
			interior = 15,
			dimension = 1250
		},
		exit = {
			position = {2196.7109375, -1204.205078125, 1049.0234375},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 1260
		}
	},
	[1269] = {
		name = "Sheriff",
		gameInterior = 4,
		type = "building",
		price = 4,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-217.66738891602, 979.12060546875, 19.503040313721},
			rotation = {0, 0, 67.020927429199},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {242.59721374512, -6.2908816337585, 20941.302734375},
			rotation = {0, 0, 62.947559356689},
			interior = 0,
			dimension = 0
		}
	},
	[1270] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2626.5083007813, 1968.4604492188, 14.116060256958},
			rotation = {0, 0, 355.76159667969},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1270
		}
	},
	[1271] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2628.4223632813, 1968.2521972656, 14.116060256958},
			rotation = {0, 0, 0.14830821752548},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1271
		}
	},
	[1272] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2636.0361328125, 1968.0959472656, 14.116060256958},
			rotation = {0, 0, 6.1016917228699},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1272
		}
	},
	[1273] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2637.7739257813, 1968.1079101563, 14.116060256958},
			rotation = {0, 0, 359.2082824707},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1273
		}
	},
	[1274] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2645.1472167969, 1968.3846435547, 14.116060256958},
			rotation = {0, 0, 1.4016273021698},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1274
		}
	},
	[1275] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2646.9138183594, 1968.4638671875, 14.116060256958},
			rotation = {0, 0, 5.4024615287781},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1275
		}
	},
	[1276] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2654.4943847656, 1968.5423583984, 14.116060256958},
			rotation = {0, 0, 2.6549875736237},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1276
		}
	},
	[1277] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2656.4250488281, 1968.3623046875, 14.116060256958},
			rotation = {0, 0, 357.01495361328},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1277
		}
	},
	[1278] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2656.1042480469, 1968.3383789063, 10.8203125},
			rotation = {0, 0, 8.8983268737793},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1278
		}
	},
	[1279] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2654.1735839844, 1968.3463134766, 10.8203125},
			rotation = {0, 0, 8.8983268737793},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1279
		}
	},
	[1280] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2647.0458984375, 1968.1744384766, 10.8203125},
			rotation = {0, 0, 7.3316798210144},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1280
		}
	},
	[1281] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2645.2097167969, 1968.404296875, 10.8203125},
			rotation = {0, 0, 1.3782749176025},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1281
		}
	},
	[1282] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2637.6242675781, 1968.3116455078, 10.8203125},
			rotation = {0, 0, 0.1249558031559},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1282
		}
	},
	[1283] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2636.0185546875, 1968.2484130859, 10.8203125},
			rotation = {0, 0, 8.5850391387939},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1283
		}
	},
	[1284] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2628.3000488281, 1968.4293212891, 10.8203125},
			rotation = {0, 0, 355.71487426758},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1284
		}
	},
	[1285] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2626.6357421875, 1968.5928955078, 10.8203125},
			rotation = {0, 0, 4.8016209602356},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1285
		}
	},
	[1286] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1830.716796875, 2740.9438476563, 11.34375},
			rotation = {0, 0, 132.59593200684},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1286
		}
	},
	[1287] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1832.4066162109, 2742.6403808594, 11.34375},
			rotation = {0, 0, 315.56100463867},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1287
		}
	},
	[1288] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1840.6649169922, 2750.8811035156, 11.34375},
			rotation = {0, 0, 319.97100830078},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1288
		}
	},
	[1289] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1838.9851074219, 2749.5537109375, 11.350912094116},
			rotation = {0, 0, 138.25933837891},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1289
		}
	},
	[1290] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1848.861328125, 2759.279296875, 11.34375},
			rotation = {0, 0, 318.09100341797},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1290
		}
	},
	[1291] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1847.1243896484, 2757.6201171875, 11.34375},
			rotation = {0, 0, 141.05601501465},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1291
		}
	},
	[1292] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1791.8892822266, 2741.9426269531, 11.34375},
			rotation = {0, 0, 167.97958374023},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1292
		}
	},
	[1293] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1792.2984619141, 2744.171875, 11.34375},
			rotation = {0, 0, 348.43792724609},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1293
		}
	},
	[1294] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1794.701171875, 2753.1320800781, 11.34375},
			rotation = {0, 0, 171.11294555664},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1294
		}
	},
	[1295] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1795.4245605469, 2755.7807617188, 11.34375},
			rotation = {0, 0, 346.89459228516},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1295
		}
	},
	[1296] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1797.9233398438, 2764.66015625, 11.34375},
			rotation = {0, 0, 167.0629119873},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1296
		}
	},
	[1297] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1798.4549560547, 2766.9577636719, 11.34375},
			rotation = {0, 0, 345.95449829102},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1297
		}
	},
	[1298] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1806.7491455078, 2798.1088867188, 11.34375},
			rotation = {0, 0, 164.55609130859},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1298
		}
	},
	[1299] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1807.4194335938, 2800.2619628906, 11.34375},
			rotation = {0, 0, 348.77444458008},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1299
		}
	},
	[1300] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1809.794921875, 2809.3664550781, 11.34375},
			rotation = {0, 0, 166.43606567383},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1300
		}
	},
	[1301] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1810.4691162109, 2811.791015625, 11.34375},
			rotation = {0, 0, 341.25433349609},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1301
		}
	},
	[1302] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1812.8796386719, 2820.7880859375, 11.34375},
			rotation = {0, 0, 159.5426940918},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1302
		}
	},
	[1303] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 10,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1813.5711669922, 2823.0881347656, 11.34375},
			rotation = {0, 0, 342.1943359375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2216.54, -1076.29, 1050.484},
			rotation = {0, 0, 0},
			interior = 1,
			dimension = 1303
		}
	},
	[1304] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1873.4931640625, 2783.9040527344, 11.34375},
			rotation = {0, 0, 316.81411743164},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1304
		}
	},
	[1305] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1871.7286376953, 2782.1730957031, 11.34375},
			rotation = {0, 0, 135.10243225098},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1305
		}
	},
	[1306] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1881.8262939453, 2792.0627441406, 11.34375},
			rotation = {0, 0, 317.44082641602},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1306
		}
	},
	[1307] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1879.98046875, 2790.4255371094, 11.34375},
			rotation = {0, 0, 137.29582214355},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1307
		}
	},
	[1308] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1890.1136474609, 2800.3254394531, 11.34375},
			rotation = {0, 0, 324.96075439453},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1308
		}
	},
	[1309] = {
		name = "Old Venturas Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 3000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1888.5205078125, 2798.8493652344, 11.34375},
			rotation = {0, 0, 129.4623260498},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1309
		}
	},
	[1311] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1824.3807373047, 2734.2729492188, 11.34375},
			rotation = {0, 0, 320.86392211914},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1311
		}
	},
	[1312] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1823.7639160156, 2734.3310546875, 14.2734375},
			rotation = {0, 0, 312.40371704102},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1312
		}
	},
	[1313] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1865.154296875, 2775.4780273438, 14.2734375},
			rotation = {0, 0, 320.23706054688},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1313
		}
	},
	[1314] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1864.9039306641, 2775.486328125, 11.34375},
			rotation = {0, 0, 323.05718994141},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1314
		}
	},
	[1315] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1897.1354980469, 2807.1811523438, 14.2734375},
			rotation = {0, 0, 133.82556152344},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1315
		}
	},
	[1316] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1896.9432373047, 2807.1528320313, 11.350912094116},
			rotation = {0, 0, 139.77896118164},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1316
		}
	},
	[1317] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1855.5604248047, 2766.1391601563, 14.265686035156},
			rotation = {0, 0, 137.5856628418},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1317
		}
	},
	[1318] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1789.8031005859, 2732.5004882813, 11.34375},
			rotation = {0, 0, 16.951263427734},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1318
		}
	},
	[1319] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1789.1301269531, 2732.3903808594, 14.273517608643},
			rotation = {0, 0, 342.79766845703},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1319
		}
	},
	[1320] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1778.4307861328, 2735.2302246094, 11.34375},
			rotation = {0, 0, 350.94448852539},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1320
		}
	},
	[1321] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1778.2689208984, 2735.6520996094, 14.273517608643},
			rotation = {0, 0, 340.29113769531},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1321
		}
	},
	[1322] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1754.4173583984, 2735.8491210938, 14.273517608643},
			rotation = {0, 0, 7.8645639419556},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1322
		}
	},
	[1323] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1754.5477294922, 2735.6647949219, 11.34375},
			rotation = {0, 0, 7.5512294769287},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1323
		}
	},
	[1324] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1743.7504882813, 2732.8173828125, 11.34375},
			rotation = {0, 0, 22.904741287231},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1324
		}
	},
	[1325] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1743.7174072266, 2732.3933105469, 14.273517608643},
			rotation = {0, 0, 17.867900848389},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1325
		}
	},
	[1326] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1740.6774902344, 2744.0849609375, 11.34375},
			rotation = {0, 0, 18.494434356689},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1326
		}
	},
	[1327] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1741.2034912109, 2741.9455566406, 11.34375},
			rotation = {0, 0, 194.56605529785},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1327
		}
	},
	[1328] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1737.568359375, 2755.5375976563, 11.34375},
			rotation = {0, 0, 17.21760559082},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1328
		}
	},
	[1329] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1738.1032714844, 2753.353515625, 11.34375},
			rotation = {0, 0, 196.44599914551},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1329
		}
	},
	[1330] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1734.6351318359, 2766.6850585938, 11.34375},
			rotation = {0, 0, 21.291055679321},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1330
		}
	},
	[1331] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1734.859375, 2764.7529296875, 11.34375},
			rotation = {0, 0, 196.4460144043},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1331
		}
	},
	[1332] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1731.8951416016, 2775.9089355469, 11.34375},
			rotation = {0, 0, 203.0026550293},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1332
		}
	},
	[1333] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1731.7778320313, 2776.1672363281, 14.273517608643},
			rotation = {0, 0, 197.67596435547},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1333
		}
	},
	[1334] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1728.7244873047, 2789.0363769531, 14.273517608643},
			rotation = {0, 0, 9.3608522415161},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1334
		}
	},
	[1335] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1728.7467041016, 2789.0249023438, 11.34375},
			rotation = {0, 0, 15.940921783447},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1335
		}
	},
	[1336] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1725.5756835938, 2800.4389648438, 11.34375},
			rotation = {0, 0, 17.50756072998},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1336
		}
	},
	[1337] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1725.9317626953, 2797.9689941406, 11.34375},
			rotation = {0, 0, 197.9892578125},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1337
		}
	},
	[1338] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1722.5626220703, 2811.7707519531, 11.34375},
			rotation = {0, 0, 20.327554702759},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1338
		}
	},
	[1339] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1723.1022949219, 2809.4416503906, 11.34375},
			rotation = {0, 0, 198.61587524414},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1339
		}
	},
	[1340] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1719.7159423828, 2822.8093261719, 11.34375},
			rotation = {0, 0, 15.000678062439},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1340
		}
	},
	[1341] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1719.9577636719, 2820.8999023438, 11.34375},
			rotation = {0, 0, 197.98905944824},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1341
		}
	},
	[1342] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1717.046875, 2832.3430175781, 11.34375},
			rotation = {0, 0, 197.02557373047},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1342
		}
	},
	[1343] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1716.9952392578, 2832.173828125, 14.273517608643},
			rotation = {0, 0, 202.35224914551},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1343
		}
	},
	[1344] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1816.2055664063, 2832.5908203125, 14.27351474762},
			rotation = {0, 0, 151.89978027344},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1344
		}
	},
	[1345] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1805.3275146484, 2835.5610351563, 14.27351474762},
			rotation = {0, 0, 161.30537414551},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1345
		}
	},
	[1346] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1805.0629882813, 2835.3200683594, 11.34375},
			rotation = {0, 0, 157.85848999023},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1346
		}
	},
	[1347] = {
		name = "Prickle Pine Hotel Szoba",
		gameInterior = 67,
		type = "rentable",
		price = 2750,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1816.1273193359, 2832.1872558594, 11.34375},
			rotation = {0, 0, 155.66525268555},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2233.650390625, -1114.6142578125, 1050.8828125},
			rotation = {0, 0, 0},
			interior = 5,
			dimension = 1347
		}
	},
	[1348] = {
		name = "Bell Station Porta",
		gameInterior = 67,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1390.2102050781, 2684.4558105469, 10.8203125},
			rotation = {0, 0, 273.18975830078},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {1392.2006835938, 2684.3698730469, 10.8203125},
			rotation = {0, 0, 84.537788391113},
			interior = 0,
			dimension = 0
		}
	},
	[1351] = {
		name = "Garázs - Közepes",
		gameInterior = 135,
		type = "garage",
		price = 18000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {427.13394165039, 2546.6970214844, 16.276908874512},
			rotation = {0, 0, 88.150146484375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {613.193359375, -76.302734375, 998},
			rotation = {0, 0, 270},
			interior = 2,
			dimension = 1351
		}
	},
	[1352] = {
		name = "Garázs - Közepes",
		gameInterior = 135,
		type = "garage",
		price = 18000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-257.13123, 1159.00842, 19.74929},
			rotation = {0, 0, 90},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {613.193359375, -76.302734375, 998},
			rotation = {0, 0, 270},
			interior = 2,
			dimension = 1352
		}
	},
	[1354] = {
		name = "Verdant Meadows",
		gameInterior = 52,
		type = "house",
		price = 100000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {423.63952636719, 2536.5393066406, 16.1484375},
			rotation = {0, 0, 87.50415802002},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {261.01953125, 1284.294921875, 1080.2578125},
			rotation = {0, 0, 0},
			interior = 4,
			dimension = 1354
		}
	},
	[1355] = {
		name = "Bone Country",
		gameInterior = 18,
		type = "house",
		price = 100000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {538.01318359375, 2359.4577636719, 30.799320220947},
			rotation = {0, 0, 35.322902679443},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1355
		}
	},
	[1360] = {
		name = "Roosevelt Auto Care Center Iroda",
		gameInterior = 40,
		type = "building2",
		price = 10,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-134.74572753906, 1226.1314697266, 19.7421875},
			rotation = {0, 0, 265.36163330078},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-2027.92, -105.183, 1035.172},
			rotation = {0, 0, 0},
			interior = 3,
			dimension = 1360
		}
	},
	[1361] = {
		name = "Lil Probe Inn",
		gameInterior = 129,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-89.12134552002, 1378.2337646484, 10.469839096069},
			rotation = {0, 0, 97.135131835938},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-228.796875, 1401.177734375, 27.765625},
			rotation = {0, 0, 0},
			interior = 18,
			dimension = 1361
		}
	},
	[1363] = {
		name = "Electric Store",
		gameInterior = 75,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1515.5842285156, 2591.3747558594, 55.8359375},
			rotation = {0, 0, 175.87725830078},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-27.365234375, -57.5771484375, 1003.546875},
			rotation = {0, 0, 0},
			interior = 6,
			dimension = 1363
		}
	},
	[1364] = {
		name = "Bank",
		gameInterior = 4,
		type = "building",
		price = 4,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-179.77874755859, 1133.1885986328, 19.7421875},
			rotation = {0, 0, 159.97227478027},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-178.04180908203, 1133.0228271484, 13.118314743042},
			rotation = {0, 0, 179.5442199707},
			interior = 0,
			dimension = 0
		}
	},
	[1366] = {
		name = "General Store",
		gameInterior = 48,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-271.67904663086, 2691.9094238281, 62.6875},
			rotation = {0, 0, 174.99671936035},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-27.0751953125, -31.7607421875, 1003.5572509766},
			rotation = {0, 0, 0},
			interior = 4,
			dimension = 1366
		}
	},
	[1367] = {
		name = "Lakóautó",
		gameInterior = 18,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1235.5778808594, 1825.8536376953, 41.546443939209},
			rotation = {0, 0, 343.43115234375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1367
		}
	},
	[1368] = {
		name = "Robada-1",
		gameInterior = 18,
		type = "house",
		price = 90000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1500.0698242188, 1960.5109863281, 49.0234375},
			rotation = {0, 0, 179.57962036133},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1368
		}
	},
	[1369] = {
		name = "Barrancas-2",
		gameInterior = 18,
		type = "house",
		price = 110000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-821.16827392578, 1603.2961425781, 27.1171875},
			rotation = {0, 0, 352.83111572266},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1369
		}
	},
	[1370] = {
		name = "Barrancas-1",
		gameInterior = 18,
		type = "house",
		price = 110000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-828.21594238281, 1603.9920654297, 27.1171875},
			rotation = {0, 0, 89.965339660645},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1370
		}
	},
	[1371] = {
		name = "Lakóautó-Barrancas",
		gameInterior = 18,
		type = "rentable",
		price = 900,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-830.09753417969, 1589.521484375, 26.948112487793},
			rotation = {0, 0, 131.32574462891},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1371
		}
	},
	[1372] = {
		name = "Barrancas-3",
		gameInterior = 18,
		type = "house",
		price = 110000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-800.48724365234, 1596.6589355469, 27.063854217529},
			rotation = {0, 0, 271.07385253906},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1372
		}
	},
	[1373] = {
		name = "Barrancas-5",
		gameInterior = 18,
		type = "house",
		price = 110000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-797.70086669922, 1525.8013916016, 27.079135894775},
			rotation = {0, 0, 80.612190246582},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1373
		}
	},
	[1374] = {
		name = "Barrancas-6",
		gameInterior = 18,
		type = "house",
		price = 130000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-788.5146484375, 1519.4398193359, 26.921226501465},
			rotation = {0, 0, 354.15490722656},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1374
		}
	},
	[1375] = {
		name = "Robada-2",
		gameInterior = 18,
		type = "house",
		price = 130000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1802.7447509766, 2038.2770996094, 9.5902452468872},
			rotation = {0, 0, 205.25021362305},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1375
		}
	},
	[1376] = {
		name = "Robada-1",
		gameInterior = 18,
		type = "house",
		price = 130000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-1827.4366455078, 2042.2917480469, 8.6605567932129},
			rotation = {0, 0, 294.21435546875},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1376
		}
	},
	[1379] = {
		name = "Fort Carson-102",
		gameInterior = 18,
		type = "house",
		price = 95000,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {-233.86894226074, 1052.0061035156, 19.734390258789},
			rotation = {0, 0, 102.12674713135},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2.0595703125, -3.0146484375, 999.42840576172},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1379
		}
	},
	[1380] = {
		name = "Gyár",
		gameInterior = 21,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {966.49322509766, 2160.7094726563, 10.8203125},
			rotation = {0, 0, 91.396125793457},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {2541.5400390625, -1303.8642578125, 1025.0703125},
			rotation = {0, 0, 0},
			interior = 2,
			dimension = 1380
		}
	},
	[1381] = {
		name = "General Store",
		gameInterior = 48,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1557.2679443359, 935.48278808594, 10.8203125},
			rotation = {0, 0, 89.810646057129},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-27.0751953125, -31.7607421875, 1003.5572509766},
			rotation = {0, 0, 0},
			interior = 4,
			dimension = 1381
		}
	},
	[1382] = {
		name = "Beer&Tabbacco&Restaurant",
		gameInterior = 126,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {1557.3092041016, 959.55102539063, 10.8203125},
			rotation = {0, 0, 88.557266235352},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {377.003, -192.507, 1000.633},
			rotation = {0, 0, 0},
			interior = 17,
			dimension = 1382
		}
	},
	[1383] = {
		name = "24/7",
		gameInterior = 48,
		type = "building",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2194.6379394531, 1990.9412841797, 12.296875},
			rotation = {0, 0, 273.57543945313},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {-27.0751953125, -31.7607421875, 1003.5572509766},
			rotation = {0, 0, 0},
			interior = 4,
			dimension = 1383
		}
	},
	[1384] = {
		name = "F.B.I",
		gameInterior = 5,
		type = "building2",
		price = 0,
		dummy = "N",
		ownerId = 0,
		entrance = {
			position = {2447.3693847656, 2376.2980957031, 12.163512229919},
			rotation = {0, 0, 270.40234375},
			interior = 0,
			dimension = 0
		},
		exit = {
			position = {6179.8359375, 1154.9360351563, 19943.86328125},
			rotation = {0, 0, 92.113861083984},
			interior = 0,
			dimension = 0
		}
	},
}

function getInteriorPosition(interiorId)
	if availableInteriors[interiorId] then
		return availableInteriors[interiorId].entrance.position
	end

	return false
end

function getInteriorName(interiorId)
	if availableInteriors[interiorId] then
		return availableInteriors[interiorId].name
	end

	return false
end

function getInteriorOwner(interiorId)
	if availableInteriors[interiorId] then
		return availableInteriors[interiorId].ownerId
	end

	return false
end

function getInteriorEntrance(interiorId)
	if interiorId then
		if availableInteriors[interiorId] then
			return availableInteriors[interiorId].entrance
		else
			return false
		end
	else
		return false
	end
end

function getInteriorEntrancePosition(interiorId)
	if interiorId then
		if availableInteriors[interiorId] then
			return availableInteriors[interiorId].entrance.position[1], availableInteriors[interiorId].entrance.position[2], availableInteriors[interiorId].entrance.position[3]
		else
			return false
		end
	else
		return false
	end
end

function getInteriorExit(interiorId)
	if interiorId then
		if availableInteriors[interiorId] then
			return availableInteriors[interiorId].exit
		else
			return false
		end
	else
		return false
	end
end

function getInteriorExitPosition(interiorId)
	if interiorId then
		if availableInteriors[interiorId] then
			return availableInteriors[interiorId].exit.position[1], availableInteriors[interiorId].exit.position[2], availableInteriors[interiorId].exit.position[3]
		else
			return false
		end
	else
		return false
	end
end

function getInteriorEntranceIntDim(interiorId)
	if interiorId then
		if availableInteriors[interiorId] then
			return availableInteriors[interiorId].entrance.interior, availableInteriors[interiorId].entrance.dimension
		else
			return false
		end
	else
		return false
	end
end

function getInteriorExitIntDim(interiorId)
	if interiorId then
		if availableInteriors[interiorId] then
			return availableInteriors[interiorId].exit.interior, availableInteriors[interiorId].exit.dimension
		else
			return false
		end
	else
		return false
	end
end

function getInteriorEditable(interiorId)
	if interiorId then
		if availableInteriors[interiorId] then
			if availableInteriors[interiorId].editable ~= "N" then
				return availableInteriors[interiorId].editable
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end