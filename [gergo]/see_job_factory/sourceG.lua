shelfPositions = {
	{1427.6, 2353.4, -3, 270},
	{1419.2, 2353.4, -3, 270},
	{1419.2, 2368.5, -3, 270},
	{1427.9, 2368.5, -3, 270}
}

function rotateAround(angle, x1, y1, x2, y2)
	angle = math.rad(angle)

	local rotatedX = x1 * math.cos(angle) - y1 * math.sin(angle)
	local rotatedY = x1 * math.sin(angle) + y1 * math.cos(angle)

	return rotatedX + (x2 or 0), rotatedY + (y2 or 0)
end

itemIds = {320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333}

itemNames = {
	[320] = exports.see_items:getItemName(320),
	[321] = exports.see_items:getItemName(321),
	[322] = exports.see_items:getItemName(322),
	[323] = exports.see_items:getItemName(323),
	[324] = exports.see_items:getItemName(324),
	[325] = exports.see_items:getItemName(325),
	[326] = exports.see_items:getItemName(326),
	[327] = exports.see_items:getItemName(327),
	[328] = exports.see_items:getItemName(328),
	[329] = exports.see_items:getItemName(329),
	[330] = exports.see_items:getItemName(330),
	[331] = exports.see_items:getItemName(331),
	[332] = exports.see_items:getItemName(332),
	[333] = exports.see_items:getItemName(333)
}