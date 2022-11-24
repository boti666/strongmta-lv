maxItems = {}

local nonStackableItems = exports.see_items:getNonStackableItems()

for i = 1, #nonStackableItems do
	maxItems[nonStackableItems[i]] = 1
end

mainTypes = {
	[0] = {1, 3},
	[1] = {7, 8, 9},
	[2] = {7, 8, 9, 10},
	[3] = {6, 8, 9},
	[4] = {6, 8, 9, 10},
	[5] = {7, 6, 8, 9},
	[6] = {7, 6, 8, 9, 10},
	[7] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
	[8] = {3, 8, 9, 4, 5},
	[9] = {2, 3},
	[10] = {11},
	[11] = {12},
	[12] = {13},
	[13] = {14},
	[14] = {15}
}

categories = {
	"Műszaki",			-- 1
	"Szerszámok",		-- 2
	"Hobby",			-- 3
	"Kisállat",			-- 4
	"Egészség",			-- 5
	"Gyorsételek",		-- 6
	"Főtt ételek",		-- 7
	"Üditők",			-- 8
	"Forró italok",		-- 9
	"Alkohol/Cigaretta",-- 10
	"Fegyver",			-- 11
	"Pirotechnika",		-- 12
	"Horgászos",		-- 13
	"Tombola árus",		-- 14
	"Sorsjegy"			-- 15
}

itemsForChoosePlain = {
	{4, 9, 150, 99},
	{72, 100, 164, 216, 245, 125, 34, 99},
	{99, 382, 34, 362, 68, 71, 97, 104, 151, 204, 205, 211, 212, 214, 213, 72, 100, 164, 216, 245, 195, 20, 23, 22, 24, 21, 312, 366},
	{99, 160, 161, 162},
	{99, 372, 148, 149, 153, 26, 27, 25},
	{99, 6, 7, 8, 126, 167, 168, 169, 173, 174, 175, 176, 177, 178, 179, 180, 181},
	{99, 170, 171, 172},
	{99, 39, 41, 42, 186},
	{99, 182, 183, 184, 185},
	{99, 40, 43, 44, 45, 46, 191, 28},
	{99, 109, 110, 111, 112, 113, 114},
	{99, 165, 166, 297, 298},
	{99, 219, 211, 212, 213, 214},
	{99, 370},
	{}
}

itemBasePrices = {
	[362] = 50,
	[219] = 50,
	[165] = 100,
	[166] = 100,
	[297] = 100,
	[382] = 100000,
	[298] = 100,
	[76] = 100,
	[109] = 100,
	[1] = 100,
	[2] = 100,
	[3] = 100,
	[4] = 70,
	[5] = 710,
	[6] = 3,
	[7] = 4,
	[8] = 5,
	[9] = 600,
	[39] = 1,
	[40] = 5,
	[41] = 3,
	[42] = 3,
	[43] = 5,
	[44] = 5,
	[45] = 10,
	[46] = 5,
	[67] = 4500,
	[68] = 1200,
	[71] = 2400,
	[72] = 600,
	[97] = 1400,
	[100] = 60,
	[104] = 500,
	[125] = 100,
	[126] = 5,
	[148] = 100,
	[149] = 80,
	[150] = 150,
	[151] = 1,
	[153] = 120,
	[160] = 40,
	[161] = 30,
	[162] = 40,
	[164] = 75,
	[165] = 120,
	[166] = 150,
	[167] = 5,
	[168] = 4,
	[169] = 5,
	[170] = 6,
	[171] = 5,
	[172] = 4,
	[173] = 3,
	[174] = 5,
	[175] = 6,
	[176] = 3,
	[177] = 4,
	[178] = 5,
	[179] = 4,
	[180] = 5,
	[181] = 2,
	[182] = 2,
	[183] = 2,
	[184] = 3,
	[185] = 2,
	[186] = 2,
	[191] = 8,
	[195] = 10,
	[204] = 5,
	[205] = 6,
	[211] = 85,
	[212] = 10,
	[214] = 5,
	[213] = 7,
	[216] = 60,
	[245] = 120,
	[20] = 100,
	[28] = 1,
	[23] = 50,
	[26] = 5,
	[27] = 10,
	[22] = 50,
	[25] = 10,
	[24] = 5,
	[21] = 10,
	[34] = 50,
	[373] = 30,
	[312] = 10,
	[109] = 10,
	[110] = 10,
	[111] = 10,
	[112] = 10,
	[113] = 10,
	[114] = 10,
	[366] = 20,
	[103] = 50,
	[99] = 4000,
	[370] = 1000,
	[372] = 120,
	[99] = 50000
}

scratchItems = {}

function addScratchItems()
	itemsForChoosePlain[15] = {}

	for k, v in pairs(scratchItems) do
		maxItems[k] = 1
		itemBasePrices[k] = 5
		table.insert(itemsForChoosePlain[15], k)
	end
end

function resourceStart(res)
	if getResourceName(res) == "see_lottery" then
		scratchItems = exports.see_lottery:getScratchItems()
		addScratchItems()
	else
		if source == resourceRoot then
			local see_lottery = getResourceFromName("see_lottery")

			if see_lottery and getResourceState(see_lottery) == "running" then
				scratchItems = exports.see_lottery:getScratchItems()
				addScratchItems()
			end
		end
	end
end
addEventHandler("onResourceStart", root, resourceStart)
addEventHandler("onClientResourceStart", root, resourceStart)