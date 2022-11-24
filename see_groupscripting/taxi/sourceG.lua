function getVehicleSpeed(vehicle)
	if isElement(vehicle) then
		local vx, vy, vz = getElementVelocity(vehicle)
		return math.sqrt(vx*vx + vy*vy + vz*vz) * 187.5
	end
end