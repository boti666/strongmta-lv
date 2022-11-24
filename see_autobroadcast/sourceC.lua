local messages = {
	"Prémium pont vásárlásról minden infót megtudhatsz a dashboard ('Home' gomb) PP füle alatt, melyet a /ppinfo paranccsal is elérsz.",
	"Lerobbantál? Hívd a vontatókat a telefonon, csak tárcsázd a 3612/222-222-es számot.",
	"Taxira van szükséged? Hívd a taxisokat a telefonon, csak tárcsázd a 3612/333-333-as számot.",
	"Sérültet látsz az utcán, vagy neked van szükséged a mentőkre? Tárcsázd a telefonon a 104-es számot.",
	"Bűncselekményt láttál, esetleg egy járőrre lenne szükséged? Tárcsázd a 107-es számot a telefonon.",
	"Segítségre van szükséged és adminnak akarsz írni? Használd a /pm parancsot! Kisebb kérdésekkel keresd az adminsegédeket.",
	"Figyelj mindig az éhség szintedre, hisz ha túl alacsony, akkor a HP-d is csökkenni fog!",
	--"Weboldalunk: lv.see-game.com. A fórumra külön kell regisztrálnod, elérése: forum.lv.see-game.com",
	"Közlekedj mindig óvatosan, hisz az ütközés, súlyos hatással lehet a karakteredre is!",
	"A dashboardot, azaz a StrongMTA vezérlőpultját a 'HOME' gomb megnyomásával tudod aktiválni.",
	"A biztonsági övet, az 'F5'-ös gomb megnyomásával tudod bekötni.",
	"A járműveken az ablakot le-és felhúzni is tudod, ehhez használd az 'F4'-es gombot.",
	"A prémiumpontokat az Itemshopban is le tudod vásárolni, ehhez használd a /pp parancsot vagy az F7-es gombot.",
	"Minden járművet meg tudsz vásárolni az autókereskedésben prémiumpontból is. Ilyenkor a rendszer figyelmen kívül hagyja a limiteket!",
	"Háziállatot szeretnél? Nyisd meg a Dashboardot a 'HOME' gombbal és menj a PET kezelés panelra.",
	"Ha van PET-ed, és le van spawnolva, akkor meg is véd téged, ha esetleg valaki rád támadna.",
}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		setTimer(doMsg, 1000 * 60 * 60, 0)
		doMsg()
	end
)

local doTips = true

addCommandHandler("togtips",
	function ()
		if doTips then
			doTips = false
			outputChatBox("#3d7abc[StrongMTA]: #ffffffKikapcsoltad a tippeket.", 255, 255, 255, true)
		else
			doTips = true
			outputChatBox("#3d7abc[StrongMTA]: #ffffffBekapcsoltad a tippeket.", 255, 255, 255, true)
		end
	end)

function doMsg()
	if doTips then
		local message = messages[math.random(1, #messages)]
		if message then
			outputChatBox("#32b3ef[Tipp]: #ffffff" .. message, 255, 255, 255, true)
		end
	end
end