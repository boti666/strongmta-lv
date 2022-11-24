function encodeDatabaseId(databaseId)
	local n1 = databaseId % 10
	databaseId = (databaseId - n1) / 10

	local n2 = databaseId % 10
	databaseId = (databaseId - n2) / 10
	
	local c1 = databaseId % 14
	databaseId = (databaseId - c1) / 14

	local c2 = databaseId % 14
	databaseId = (databaseId - c2) / 14
	
	return "-" .. string.format("%c%c%c-%c%c",
		databaseId + string.byte("A"),
		c2 + string.byte("A"),
		c1 + string.byte("A"),
		n2 + string.byte("0"),
		n1 + string.byte("0")
	)
end