function getLevel(player, minutes)
	if not minutes then
		minutes = (getElementData(player, "char.playedMinutes") or 0) / 60
	else
		minutes = (minutes or 0) / 60
	end
	
	if minutes then
		if minutes < 5 then
			return 1
		elseif minutes >= 5 and minutes < 10 then
			return 2
		elseif minutes >= 10 and minutes < 15 then
			return 3
		elseif minutes >= 15 and minutes < 20 then
			return 4
		elseif minutes >= 20 and minutes < 30 then
			return 5
		elseif minutes >= 30 and minutes < 40 then
			return 6
		elseif minutes >= 40 and minutes < 50 then
			return 7
		elseif minutes >= 50 and minutes < 60 then
			return 8
		elseif minutes >= 60 and minutes < 70 then
			return 9
		elseif minutes >= 70 and minutes < 90 then
			return 10
		elseif minutes >= 90 and minutes < 110 then
			return 11
		elseif minutes >= 110 and minutes < 120 then
			return 12
		elseif minutes >= 120 and minutes < 140 then
			return 13
		elseif minutes >= 140 and minutes < 160 then
			return 14
		elseif minutes >= 160 and minutes < 190 then
			return 15
		elseif minutes >= 190 and minutes < 220 then
			return 16
		elseif minutes >= 220 and minutes < 250 then
			return 17
		elseif minutes >= 250 and minutes < 280 then
			return 18
		elseif minutes >= 280 and minutes < 310 then
			return 19
		elseif minutes >= 310 and minutes < 350 then
			return 20
		elseif minutes >= 350 and minutes < 390 then
			return 21
		elseif minutes >= 390 and minutes < 430 then
			return 22
		elseif minutes >= 430 and minutes < 470 then
			return 23
		elseif minutes >= 470 and minutes < 500 then
			return 24
		elseif minutes >= 500 and minutes < 550 then
			return 25
		elseif minutes >= 550 and minutes < 600 then
			return 26
		elseif minutes >= 600 and minutes < 650 then
			return 27
		elseif minutes >= 650 and minutes < 700 then
			return 28
		elseif minutes >= 700 and minutes < 750 then
			return 29
		elseif minutes >= 750 and minutes < 800 then
			return 30
		elseif minutes >= 800 and minutes < 850 then
			return 31
		elseif minutes >= 850 and minutes < 900 then
			return 32
		elseif minutes >= 900 and minutes < 950 then
			return 33
		elseif minutes >= 950 and minutes < 1000 then
			return 34
		elseif minutes >= 1000 and minutes < 1050 then
			return 35
		elseif minutes >= 1050 and minutes < 1100 then
			return 36
		elseif minutes >= 1100 and minutes < 1150 then
			return 37
		elseif minutes >= 1150 and minutes < 1200 then
			return 38
		elseif minutes >= 1200 and minutes < 1250 then
			return 39
		elseif minutes >= 1250 and minutes < 1300 then
			return 40
		elseif minutes >= 1300 and minutes < 1350 then
			return 41
		elseif minutes >= 1350 and minutes < 1400 then
			return 42
		elseif minutes >= 1400 and minutes < 1450 then
			return 43
		elseif minutes >= 1450 and minutes < 1500 then
			return 44
		elseif minutes >= 1500 and minutes < 1600 then
			return 45
		elseif minutes >= 1600 and minutes < 1700 then
			return 46
		elseif minutes >= 1700 and minutes < 1800 then
			return 47
		elseif minutes >= 1800 and minutes < 1900 then
			return 48
		elseif minutes >= 1900 and minutes < 2000 then
			return 49
		elseif minutes >= 2000 and minutes < 2100 then
			return 50
		elseif minutes >= 2100 and minutes < 2200 then
			return 51
		elseif minutes >= 2200 and minutes < 2300 then
			return 52
		elseif minutes >= 2300 and minutes < 2400 then
			return 53
		elseif minutes >= 2400 and minutes < 2500 then
			return 54
		elseif minutes >= 2500 and minutes < 2600 then
			return 55
		elseif minutes >= 2600 and minutes < 2700 then
			return 56
		elseif minutes >= 2700 and minutes < 2800 then
			return 57
		elseif minutes >= 2800 and minutes < 2900 then
			return 58
		elseif minutes >= 2900 and minutes < 3000 then
			return 59
		elseif minutes >= 3000 and minutes < 3100 then
			return 60
		elseif minutes >= 3100 and minutes < 3200 then
			return 61
		elseif minutes >= 3200 and minutes < 3300 then
			return 62
		elseif minutes >= 3300 and minutes < 3400 then
			return 63
		elseif minutes >= 3400 and minutes < 3500 then
			return 64
		elseif minutes >= 3500 and minutes < 3600 then
			return 65
		elseif minutes >= 3600 and minutes < 3700 then
			return 66
		elseif minutes >= 3700 and minutes < 3800 then
			return 67
		elseif minutes >= 3800 and minutes < 3900 then
			return 68
		elseif minutes >= 3900 and minutes < 4000 then
			return 69
		elseif minutes >= 4000 and minutes < 4200 then
			return 70
		elseif minutes >= 4200 and minutes < 4400 then
			return 71
		elseif minutes >= 4400 and minutes < 4600 then
			return 72
		elseif minutes >= 4600 and minutes < 4800 then
			return 73
		elseif minutes >= 4800 and minutes < 5000 then
			return 74
		elseif minutes >= 5000 and minutes < 5500 then
			return 75
		elseif minutes >= 5500 and minutes < 6000 then
			return 76
		elseif minutes >= 6000 and minutes < 6500 then
			return 77
		elseif minutes >= 6500 and minutes < 7000 then
			return 78
		elseif minutes >= 7000 and minutes < 7500 then
			return 79
		elseif minutes >= 7500 and minutes < 8500 then
			return 80
		elseif minutes >= 8500 and minutes < 9500 then
			return 81
		elseif minutes >= 9500 and minutes < 10500 then
			return 82
		elseif minutes >= 10500 and minutes < 11500 then
			return 83
		elseif minutes >= 11500 and minutes < 12500 then
			return 84
		elseif minutes >= 12500 and minutes < 13500 then
			return 85
		elseif minutes >= 13500 and minutes < 14500 then
			return 86
		elseif minutes >= 14500 and minutes < 15500 then
			return 87
		elseif minutes >= 15500 and minutes < 16500 then
			return 88
		elseif minutes >= 16500 and minutes < 17500 then
			return 89
		elseif minutes >= 17500 and minutes < 18500 then
			return 90
		elseif minutes >= 18500 and minutes < 19500 then
			return 91
		elseif minutes >= 19500 and minutes < 20500 then
			return 92
		elseif minutes >= 20500 and minutes < 21500 then
			return 93
		elseif minutes >= 21500 and minutes < 22500 then
			return 94
		elseif minutes >= 22500 and minutes < 23500 then
			return 95
		elseif minutes >= 23500 and minutes < 24500 then
			return 96
		elseif minutes >= 24500 and minutes < 25500 then
			return 97
		elseif minutes >= 25500 and minutes < 30000 then
			return 98
		else
			return 99
		end
		
		return 99
	else
		return false
	end
end

function getMoney(player)
	return getElementData(player, "char.Money") or 0
end

function takeMoneyEx(player, amount, economy)
	if amount then
		amount = math.abs(amount)

		local newValue = (getElementData(player, "char.Money") or 0) - tonumber(amount)

		if newValue >= 0 then
			setElementData(player, "char.Money", newValue, true)

			if economy then
				exports.see_logs:logEconomy(player, "takeex:" .. economy, -amount)
			end

			return true
		else
			return false
		end
	end
end

function takeMoney(player, amount, economy)
	if amount then
		amount = math.abs(amount)

		setElementData(player, "char.Money", getElementData(player, "char.Money") - tonumber(amount), true)

		if economy then
			exports.see_logs:logEconomy(player, "take:" .. economy, -amount)
		end

		return true
	end

	return false
end

function giveMoney(player, amount, economy)
	if amount then
		setElementData(player, "char.Money", getElementData(player, "char.Money") + tonumber(amount), true)

		if economy then
			exports.see_logs:logEconomy(player, "give:" .. economy, amount)
		end

		return true
	end

	return false
end

function setMoney(player, amount, economy)
	if amount then
		setElementData(player, "char.Money", tonumber(amount), true)

		if economy then
			exports.see_logs:logEconomy(player, "setmoney:" .. economy, amount)
		end

		return true
	end

	return false
end