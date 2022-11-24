addEvent("bincoBuy", true)
addEventHandler("bincoBuy", getRootElement(),
	function (buyPrice, skinId)
		if isElement(source) and client and client == source then
			if buyPrice and skinId then
				if exports.see_core:takeMoneyEx(source, buyPrice, "bincoBuy") then
					setElementModel(source, skinId)
					setElementData(source, "char.Skin", skinId)
					triggerClientEvent(source, "bincoBuy", source)
				else
					exports.see_accounts:showInfo(source, "e", "Nincs elég pénzed!")
				end
			end
		end
	end
)

addEvent("setPlayerDimensionForBinco", true)
addEventHandler("setPlayerDimensionForBinco", getRootElement(),
	function (dimension)
		if isElement(source) and client and client == source then
			if dimension then
				setElementDimension(source, dimension)
			end
		end
	end
)