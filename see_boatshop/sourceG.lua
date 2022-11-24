vehiclesTable = {
	{model = 453, price = 31000, limit = -1, premium = 2000},
	{model = 452, price = 184500, limit = 350, premium = 15000},
	{model = 446, price = 246000, limit = 5, premium = 30000},
	{model = 484, price = 82000, limit = 150, premium = 9000},
	{model = 454, price = 615000, limit = 20, premium = 22000},
}

function getBoatPrice(modelId)
	for i = 1, #vehiclesTable do
		if vehiclesTable[i].model == modelId then
			return vehiclesTable[i].price
		end
	end
	return 8000
end