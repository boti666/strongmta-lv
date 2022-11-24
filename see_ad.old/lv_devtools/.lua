addEvent("tuneRadioAnim", true)
addEventHandler("tuneRadioAnim", getRootElement(),
	function()
		setPedAnimation(source, "ped", "car_tune_radio", -1, false, false, true, false)
	end
)