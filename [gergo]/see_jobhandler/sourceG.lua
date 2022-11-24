availableJobs = {
	[1] = {
		name = "Gyártósori összeszerelő",
		instructions = {
			"A feladatod az, hogy összeszereld a termékeket a #d75959gyárban#ffffff.",
			"Menj az irodába, és vedd fel a munkát a műszakvezetőtől. (Kattints az NPC-re.)"
		}
	},
	[2] = {
		name = "Áruszállító",
		instructions = {
			"A feladatod az, hogy elszállítsd az árut a #598ed7depókból#ffffff.",
			"Az utad állomásait a fuvarlevelen láthatod (#598ed7/fuvarlevel#ffffff).",
			"#F0E76CMunkajármű#ffffff kéréséhez menj a kis, #F0E76Cteherautó#ffffff jelzéshez."
		},
		driverLicense = true
	},
	[3] = {
		name = "Postás",
		instructions = {
			"Szállítsd ki a #3d7abcküldeményeket#ffffff.",
			"#F0E76CMunkajármű#ffffff kéréséhez menj a kis, #F0E76Cteherautó#ffffff jelzéshez."
		},
		driverLicense = true
	},
	[4] = {
		name = "Pizzafutár",
		instructions = {
			"A feladatod, hogy szállítsd ki a #d75959pizzákat#ffffff.",
			"Menj a pizzázóhoz, és vedd fel a rendeléseket a főnöködtől, #598ed7Joe#ffffff-tól. (Kattints az NPC-re.)",
			"#F0E76CMunkajármű#ffffff kéréséhez menj a kis, #F0E76Cteherautó#ffffff jelzéshez."
		},
		driverLicense = true
	},
	[5] = {
		name = "Buszsofőr (Városi)",
		instructions = {
			"Menj végig a #3d7abcbuszmegállókon#ffffff és szállítsd az utasokat.",
			"#F0E76CMunkajármű#ffffff kéréséhez menj a kis, #F0E76Cteherautó#ffffff jelzéshez."
		},
		driverLicense = true
	},
	[6] = {
		name = "Buszsofőr (Vidéki)",
		instructions = {
			"Menj végig a #3d7abcbuszmegállókon#ffffff és szállítsd az utasokat.",
			"#F0E76CMunkajármű#ffffff kéréséhez menj a kis, #F0E76Cteherautó#ffffff jelzéshez."
		},
		driverLicense = true
	},

}

function getJobName(id)
	if id and availableJobs[id] then
		return availableJobs[id].name
	end

	return "Ismeretlen"
end

function getJobNames()
	local jobNames = {}

	for k, v in pairs(availableJobs) do
		jobNames[k] = availableJobs[k].name
	end

	return jobNames
end
