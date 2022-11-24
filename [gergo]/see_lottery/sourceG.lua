scratchItems = {
	[293] = true, -- Black Jack
	[296] = true, -- Money Mania
	[374] = true, -- Szerencsemalac
	[375] = true -- Pénzlift
}

function getScratchItems()
	return scratchItems
end

function isScratchTicket(itemId)
	return scratchItems[itemId]
end