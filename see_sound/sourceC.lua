local soundPositions = {
	{"files/oil.mp3", 353.06411743164, 1299.5303955078, 13.362517356873, 120, 0, 0},
	{"files/oil.mp3", 375.23858642578, 1334.4288330078, 11.547019958496, 120, 0, 0},
	{"files/oil.mp3", 435.25442504883, 1269.0617675781, 10.023582458496, 120, 0, 0},
	{"files/oil.mp3", 490.88159179688, 1304.4932861328, 10.065642356873, 120, 0, 0},
	{"files/oil.mp3", 499.90148925781, 1389.1496582031, 4.8985824584961, 120, 0, 0},
	{"files/oil.mp3", 628.16375732422, 1351.9979248047, 13.182829856873, 120, 0, 0},
	{"files/oil.mp3", 587.87042236328, 1340.3139648438, 11.187644958496, 120, 0, 0},
	{"files/oil.mp3", 563.23193359375, 1306.5915527344, 11.268767356873, 120, 0, 0},
	{"files/oil.mp3", 578.55462646484, 1422.2110595703, 12.331267356873, 120, 0, 0},
	{"files/oil.mp3", 600.89953613281, 1497.7462158203, 9.0578298568726, 120, 0, 0},
	{"files/oil.mp3", 534.57238769531, 1468.6925048828, 5.6047048568726, 120, 0, 0},
	{"files/oil.mp3", 419.63116455078, 1409.4727783203, 8.5656423568726, 120, 0, 0},
	{"files/oil.mp3", 405.61489868164, 1461.4282226563, 8.1906423568726, 120, 0, 0},
	{"files/oil.mp3", 422.62023925781, 1512.7668457031, 12.047019958496, 120, 0, 0},
	{"files/oil.mp3", 486.80703735352, 1527.5793457031, 1.4532699584961, 120, 0, 0},
	{"files/oil.mp3", 434.06246948242, 1563.5668945313, 12.784392356873, 120, 0, 0},
}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in ipairs(soundPositions) do
			soundPositions.soundElement = playSound3D(v[1], v[2], v[3], v[4], true)

			if isElement(soundPositions.soundElement) then
				setSoundMaxDistance(soundPositions.soundElement, v[5])
				setElementInterior(soundPositions.soundElement, v[6])
				setElementDimension(soundPositions.soundElement, v[7])
			end
		end
	end
)

-- local oilTexture = dxCreateTexture("files/oil.jpg", "dxt3")

-- addEventHandler("onClientRender", getRootElement(),
-- 	function ()
-- 		dxDrawMaterialLine3D(616.37109375, 1569.1669921875, 1, 440.4462890625, 1525.287109375, 1, oilTexture, 150, tocolor(100, 100, 100, 255), 528.40869140625, 1547.22705078125, 100)
-- 	end
-- )
