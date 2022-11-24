panelState = false

baseCategories = {
	{"Sapkák/Kalapok", "caps"},
	{"Szemüvegek", "glasses"},
	{"Maszkok", "masks"},
	{"Karórák", "watches"},
	{"Táskák", "bags"},
	{"Nyakláncok", "necklaces"},
	{"Egyéb kiegészítők", "misc"}
}

alpha = 1
alphaAnim = false

screenSource = false
screenShader = false

Roboto = false
RobotoL = false
RobotoB = false

buttons = {}
activeButton = false

selectedTab = 1
tabCaptions = {"Információ", "Vagyon", "Prémium", "Frakciók", "Adminok", "Háziállatok", "Kiegészítők", "Beállítások"}
tabPictures = {
	"files/images/tabs/0.png",
	"files/images/tabs/1.png",
	--"files/images/tabs/2.png",
	"files/images/tabs/3.png",
	"files/images/tabs/4.png",
	"files/images/tabs/5.png",
	"files/images/tabs/6.png"
}

playerVehicles = {}
playerInteriors = {}
playerGroups = {}
playerGroupsKeyed = {}
playerGroupsCount = 0

groups = {}
groupTypes = {}

rankCount = {}

groupMembers = {}
meInGroup = {}

groupVehicles = {}
monitoredGroupVeh = {}

myDatas = {}
myMonitoredDatas = {
	["char.Name"] = true,
	["visibleName"] = true,
	--["char.Age"] = true,
	["char.Job"] = true,
	["char.accID"] = true,
	["char.ID"] = true,
	["char.Skin"] = true,
	["char.playedMinutes"] = true,
	["char.playTimeForPayday"] = true,
	["char.Money"] = true,
	["char.bankMoney"] = true,
	["char.slotCoins"] = true,
	["acc.premiumPoints"] = true,
	["acc.adminLevel"] = true,
	["char.maxVehicles"] = true,
	["char.interiorLimit"] = true,
	--["char.Description"] = true
}

vehicleDatas = {}
monitoredDatasForVehicle = {
	["vehicle.dbID"] = true,
	["vehicle.owner"] = true,
	["vehicle.group"] = true,
	["vehicle.maxFuel"] = true,
	["vehicle.fuel"] = true,
	["vehicle.distance"] = true,
	["vehicle.engine"] = true,
	["vehicle.locked"] = true,
	["vehicle.lights"] = true,
	["vehicle.nitroLevel"] = true,
	["vehicle.handBrake"] = true,
	["vehicle.tuning.Engine"] = true,
	["vehicle.tuning.Turbo"] = true,
	["vehicle.tuning.ECU"] = true,
	["vehicle.tuning.Transmission"] = true,
	["vehicle.tuning.Suspension"] = true,
	["vehicle.tuning.Brakes"] = true,
	["vehicle.tuning.Tires"] = true,
	["vehicle.tuning.WeightReduction"] = true,
	["vehicle.tuning.Optical"] = true,
	["vehicle.tuning.AirRide"] = true,
	["tuning.neon"] = true
}

jobNames = {}

selectedVeh = 1
offsetVeh = 0
tuningName = {"Alap", "Profi", "Verseny", "Venom", "Venom + SC"}
tuningName[0] = "Gyári"

selectedInt = 1
offsetInt = 0
interiorTypes = {
	business_passive = "Passzív Biznisz",
	business_active = "Aktív Biznisz",
	building = "Középület",
	garage = "Garázs",
	building2 = "Zárható Középület",
	rentable = "Bérlakás",
	house = "Ház"
}

buyingVehicleSlot = false
buyingInteriorSlot = false

fakeInputText = ""
activeFakeInput = false
fakeInputError = false

selectedGroup = 1
offsetGroup = 0

groupTabs = {"Tagok", "Rangok", "Járművek", "Egyéb"}
selectedGroupTab = 1

selectedMember = 1
offsetMember = 0
groupButtonCaptions = {"Előléptetés", "Lefokozás", "Kirúgás", "Új tag hozzáadása"}

selectedRank = 1
offsetRank = 0
groupButtonCaptions2 = {"Átnevezés", "Fizetés módosítása"}

memberFirePrompt = false
fireErrorText = ""

selectedGroupVeh = 1
offsetGroupVeh = 0

lastChangeCursorState = 0
cursorState = true

renderData = {}

renderData.openedTime = 0

renderData.loadedAnimals = {}
renderData.selectedAnimal = 1
renderData.spawnedAnimal = 0
renderData.offsetAnimal = 0
renderData.petDatas = {}

renderData.petNameTypes = {}
renderData.petTypes = {
	["Husky"] = 1,
	["Rottweiler"] = 2,
	["Doberman"] = 3,
	["Bull Terrier"] = 4,
	["Boxer"] = 5,
	["Francia Bulldog"] = 6,
}