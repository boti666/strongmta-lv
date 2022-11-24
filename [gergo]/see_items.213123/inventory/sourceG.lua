availableItems = {
	-- [ItemID] = {Név, Leírás, Súly, Stackelhető, Fegyver ID, Töltény item ID, Eldobható, Model, RotX, RotY, RotZ, Z offset}
	[1] = {"Jármű kulcs", "Jármû kulcs, a gépjárművedhez.", 0.1, false, -1, -1},
	[2] = {"Lakás kulcs", "Lakáskulcs a lakásodhoz", 0.1, false, -1, -1},
	[3] = {"Kapu távirányító", "Távirányító egy kapuhoz", 0.1, false, -1, -1},
	[4] = {"Rádió", "Egy kis walki-talkie rádió.", 0.8, false, -1, -1},
	[5] = {"Laptop", "Egy jó laptop", 1, false, -1, -1},
	[6] = {"Hot Dog", "Egy nagyon ízletes hot-dog", 0.8, true, -1, -1},
	[7] = {"Hamburger", "Egy guszta, jól megpakolt hamburger.", 0.8, true, -1, -1},
	[8] = {"Kebab", "Kebab duplaszósszal az élvezet miatt", 1, true, -1, -1},
	[9] = {"Telefon", "Egy okos telefon", 0.8, false, -1, -1},
	[10] = {"Telefonkönyv", "Hogy ha tudni akarod valakinek a számát.", 1.2, false, -1, -1},
	[11] = {"Kokacserje mag", "Mag.", 0.001, true, -1, -1},
	[12] = {"Mák mag", "Egy apró magocska.", 0.001, true, -1, -1},
	[13] = {"Bibe", "Marihuana levél.", 0.001, true, -1, -1},
	[14] = {"Kokalevél", "Kokain levél.", 0.001, true, -1, -1},
	[15] = {"Mákszalma", "Mák levél.", 0.001, true, -1, -1},
	[16] = {"Szárított marihuana", "Szárított marihuana.", 0.001, true, -1, -1},
	[17] = {"Kokain", "Tiszta kokain por.", 0.001, true, -1, -1},
	[18] = {"Heroin", "Heroin por.", 0.001, true, -1, -1},
	[19] = {"Hasis", "Hasis.", 0.003, true, -1, -1},
	[20] = {"UV Lámpa", "Speciális, hordozható UV lámpa.", 0.9, true, -1, -1},
	[21] = {"Öngyújtó", "Fontos, hogy legyen tüzed.", 0.05, true, -1, -1},
	[22] = {"Akkumulátor sav", "Ampullányi akkumulátor sav.", 0.005, true, -1, -1},
	[23] = {"Öngyújtó benzin", "Öngyújtó utántöltő készlet.", 0.005, true, -1, -1},
	[24] = {"Kanál", "Egy kisebb fajta kanál.", 0.09, true, -1, -1},
	[25] = {"Fecskendő", "Üres fecskendő.", 0.09, true, -1, -1},
	[26] = {"Szódabikarbóna", "Egy csipetnyi szódabikarbóna.", 0.001, true, -1, -1},
	[27] = {"Granulátum", "Egy kevés szerves anyag.", 0.001, true, -1, -1},
	[28] = {"Cigipapír", "1db cigipapír.", 0.001, true, -1, -1},
	[29] = {"Cigipapír (rollni)", "20db cigipapír dobozkában.", 0.02, true, -1, -1},
	[30] = {"Zacskó", "Egy átlátszó zacskó.", 0.01, true, -1, -1},
	[31] = {"Megafón", "Megafón.", 1, false, -1, -1},
	[32] = {"Bankkártya", "Bankkártya", 0.001, false, -1, -1},
	[33] = {"Anyag vas", "Egy darab vas.", 0.5, true, -1, -1},
	[34] = {"Kalapács", "Kalapács.", 0.8, true, -1, -1},
	[35] = {"Műanyag", "Műanyag.", 0.08, true, -1, -1},
	[36] = {"Réz", "Réz.", 0.15, true, -1, -1},
	[37] = {"Üvegdarab", "Egy darabka üveg.", 0.15, true, -1, -1},
	[38] = {"Vasérc", "Vasérc.", 2, true, -1, -1},
	[39] = {"Ásványvíz", "Ásványvíz.", 0.5, true, -1, -1},
	[40] = {"Bor", "Bor.", 0.8, true, -1, -1},
	[41] = {"Kóla", "Kóla.", 0.5, true, -1, -1},
	[42] = {"Fanta", "Fanta.", 0.5, true, -1, -1},
	[43] = {"Pálinka", "Pálinka.", 0.7, true, -1, -1},
	[44] = {"Sör", "Sör.", 0.5, true, -1, -1},
	[45] = {"Whiskey", "Whiskey.", 0.7, true, -1, -1},
	[46] = {"Vodka", "Vodka.", 0.8, true, -1, -1},
	[47] = {"Fegyverek A-Zig: AK47", "Fegyverek A-Zig: AK47.", 1, false, -1, -1},
	[48] = {"Fegyverek A-Zig: colt", "Fegyverek A-Zig: colt.", 1, false, -1, -1},
	[49] = {"Fegyverek A-Zig: Vadász puska", "Fegyverek A-Zig: Vadász puska.", 1, false, -1, -1},
	[50] = {"Fegyverek A-Zig: Sörétes puska", "Fegyverek A-Zig: Sörétes puska.", 1, false, -1, -1},
	[51] = {"Tiltott növények hazánkban: Marihuana", "Tiltott növények hazánkban: Marihuana.", 1, false, -1, -1},
	[52] = {"Tiltott növények hazánkban: Kokacserje", "Tiltott növények hazánkban: Kokacserje.", 1, false, -1, -1},
	[53] = {"Tiltott növények hazánkban: Mákvirág", "Tiltott növények hazánkban: Mákvirág.", 1, false, -1, -1},
	[54] = {"Cserép", "Egy üres cserép, kiváló valamit ültetni.", 1, true, -1, -1},
	[55] = {"Vizes kanna", "Egy kis éltető víz.", 1, true, -1, -1},
	[56] = {"Föld", "Egy kisebb fajta zsák föld.", 3, true, -1, -1},
	[57] = {"Marihuana mag", "Mag.", 0.001, true, -1, -1},
	[58] = {"Kemikus szett", "Házi keverőkészlet pár ampullával.", 1, true, -1, -1},
	[59] = {"Crack", "Tiszta crack por.", 0.001, true, -1, -1},
	[60] = {"Heroinos fecskendő", "Fecskendő heroinnal töltve.", 0.09, true, -1, -1},
	[61] = {"Cserép", "Cserép, benne föld és kokacserje.", 2, true, -1, -1},
	[62] = {"Cserép", "Cserép, benne föld és mák mag.", 2, true, -1, -1},
	[63] = {"Cserép", "Cserép, benne föld és marihuana mag.", 2, true, -1, -1},
	[64] = {"Műtrágya", "Speciális föld tele tápanyaggal.", 0.5, true, -1, -1},
	[65] = {"Füves cigi", "Cigi egy kis \"zölddel\" spékelve.", 0.05, true, -1, -1},
	[66] = {"Cigaretta", "Cigi egy kis hasissal.", 0.05, true, -1, -1},
	[67] = {"Boxer", "Kicsit nagyobb pofont lehet vele osztani.", 0.5, false, 1, -1},
	[68] = {"Vipera", "Egy szép darab vipera.", 0.5, false, 2, -1},
	[69] = {"Gumibot", "Gumibot, tartani a rendet.", 0.8, false, 3, -1},
	[70] = {"Kés", "Egy fegyvernek minősülő kés.", 0.8, false, 4, -1},
	[71] = {"Baseball ütő", "Egy szép darab baseball ütő.", 1, false, 5, -1},
	[72] = {"Ásó", "Egy szép darab ásó.", 1.5, false, 6, -1},
	[73] = {"Biliárd dákó", "Egy hosszú biliárd dákó.", 0.8, false, 7, -1},
	[74] = {"Katana", "Ősi japán ereklye.", 3, false, 8, -1},
	[75] = {"Láncfűrész", "Egy benzines motoros láncfűrész.", 2, false, 9, -1},
	[76] = {"Glock 17", "Egy Glock 17-es.", 3, false, 22, 109},
	[77] = {"Hangtompítós Colt 45", "Egy Colt45-ös hangtompítóval szerelve.", 3, false, 23, 109},
	[78] = {"Desert Eagle pisztoly", "Nagy kaliberű Desert Eagle pisztoly.", 3, false, 24, 109},
	[79] = {"Sörétes puska", "Nagy kaliberű sörétes puska.", 6, false, 25, 114},
	[80] = {"Rövid csövű sörétes puska", "Nagy kaliberű sörétes puska levágott csővel", 6, false, 26, 114},
	[81] = {"SPAZ-12 taktikai sörétes puska", "SPAZ-12 taktikai sörétes puska elit fegyver.", 6, false, 27, 114},
	[82] = {"Uzi", "Uzi géppisztoly.", 3, false, 28, 112},
	[83] = {"FN P90", "P90-es fegyver.", 3, false, 29, 112},
	[84] = {"TEC-9", "TEC-9-es gépfegyver.", 3, false, 32, 112},
	[85] = {"AK-47", "AK-47-es gépfegyver.", 5, false, 30, 110},
	[86] = {"M4", "M4-es gépfegyver.", 5, false, 31, 113},
	[87] = {"Vadász puska", "Vadász puska a pontos és határozott lövéshez.", 6, false, 33, 111},
	[88] = {"Remington 700", "Remington 700-as puska.", 6, false, 34, 111},
	[89] = {"Rocket Launcher", "Rocket Launcher.", 1.23, false, 35, -1},
	[90] = {"Heat-Seeking RPG", "Heat-Seeking RPG.", 1.23, false, 36, -1},
	[91] = {"Flamethrower", "Flamethrower.", 1.23, false, 37, -1},
	[92] = {"Minigun", "Minigun.", 1.23, false, 38, -1},
	[93] = {"Flashbang", "Flashbang", 0.5, false, 16, -1},
	[94] = {"Füst gránát", "Füst gránát a tökéletes taktikai fegyver.", 0.54, false, 17, -1},
	[95] = {"Molotov koktél", "Molotov koktél.", 1.23, false, 18, -1},
	[96] = {"Nagy kés", "Nagy kés.", 0.4, false, 39, -1},
	[97] = {"Spray kanna", "Spray kanna.", 0.3, false, 41, 151},
	[98] = {"Poroltó", "Poroltó", 0.001, false, 42, 98},
	[99] = {"Nikon D600", "Camera.", 0.3, false, 43, -1},
	[100] = {"Balta", "Balta", 1.23, false, 10, -1},
	[101] = {"Dildo", "Dildo.", 1.23, false, 11, -1},
	[102] = {"Bárd", "Bárd.", 1.23, false, 12, -1},
	[103] = {"Virágok", "Egy csokor virág.", 0.3, false, 14, -1},
	[104] = {"Sétapálca", "Sétapálca.", 0.2, false, 15, -1},
	[105] = {"Éjjel látó", "Éjjel látó szemüveg.", 1.23, false, 44, -1},
	[106] = {"Infravörös szemüveg", "Infravörös szemüveg.", 1.23, false, 45, -1},
	[107] = {"Ejtőernyő", "Ejtőernyő.", 2.23, false, 46, -1},
	[108] = {"Detonator", "Detonator.", 1.23, false, 40, -1},
	[109] = {"5x9mm-es töltény", "Colt45, Desert 5x9mm-es töltény", 0.001, true, -1, -1},
	[110] = {"AK47-es töltény", "AK47-es töltény", 0.001, true, -1, -1},
	[111] = {"Vadászpuska töltény", "Hosszú Vadászpuska töltény", 0.001, true, -1, -1},
	[112] = {"Kis gépfegyver töltények", "Kis gépfegyver töltények (UZI,MP5)", 0.001, true, -1, -1},
	[113] = {"M4-es gépfegyver töltény", "M4-es gépfegyver töltény", 0.001, true, -1, -1},
	[114] = {"Sörétes töltény", "Sörétes töltény", 0.001, true, -1, -1},
	[115] = {"Faltörő kos", "Faltörő kos", 0.2, true, -1, -1},
	--[[UNUSED]][116] = {"Unused", "Unused slot", 1.23},
	[117] = {"Maszk", "Maszk", 0.2, true, -1, -1},
	[118] = {"Bilincs", "Bilincs", 0.8, false, -1, -1},
	[119] = {"Bilincskulcs", "Bilincskulcs", 0.005, false, -1, -1},
	[120] = {"Ideiglenes fegyverengedély", "A fegyverengedély kiváltása a városházán lehetséges.", 0.005, false, -1, -1},
	[121] = {"Felvágott", "Felvágott", 0.01, true, -1, -1},
	[122] = {"Gázmaszk", "Gázmaszk", 0.1, true, -1, -1},
	[123] = {"GPS", "GPS", 0.3, true, -1, -1},
	[124] = {"Jogosítvány", "Jogosítvány", 0.005, false, -1, -1},
	[125] = {"Benzines kanna", "Benzines kanna", 0.8, false, -1, -1},
	[126] = {"Kész szendvics", "Kész szendvics", 0.02, false, -1, -1},
	[127] = {"Tablet", "Tablet", 0.5, false, -1, -1},
	[128] = {"Cső és előágy", "Cső és előágy", 0.5, true, -1, -1},
	[129] = {"Előágy felső része", "Előágy felső része", 0.5, true, -1, -1},
	[130] = {"Elsütőszerkezet és tus", "Elsütőszerkezet és tus", 0.5, true, -1, -1},
	[131] = {"Nézőke", "Nézőke", 0.5, true, -1, -1},
	[132] = {"Tár", "Tár", 0.5, true, -1, -1},
	[133] = {"Tok", "Tok", 0.5, true, -1, -1},
	[134] = {"Alsó rész", "Alsó rész", 0.2, true, -1, -1},
	[135] = {"Felső rész", "Felső rész", 0.2, true, -1, -1},
	[136] = {"Markolat", "Markolat", 0.2, true, -1, -1},
	[137] = {"Ravasz", "Ravasz", 0.2, true, -1, -1},
	[138] = {"Tár", "Tár", 0.2, true, -1, -1},
	[139] = {"Cső", "Cső", 0.5, true, -1, -1},
	[140] = {"Pumpáló", "Pumpáló", 0.5, true, -1, -1},
	[141] = {"Ravasz és tok", "Ravasz és tok", 0.5, true, -1, -1},
	[142] = {"Tus", "Tus", 0.5, true, -1, -1},
	[143] = {"Cső", "Cső", 0.5, true, -1, -1},
	[144] = {"Ravasz és markolat", "Ravasz és markolat", 0.5, true, -1, -1},
	[145] = {"Tok", "Tok", 0.5, true, -1, -1},
	[146] = {"Tus", "Tus", 0.5, true, -1, -1},
	[147] = {"Zsemle", "Zsemle", 0.05, true, -1, -1},
	[148] = {"Gyógyszer", "Életmentő kapszula", 0.001, true, -1, -1},
	[149] = {"Vitamin", "Fő az egészség", 0.001, true, -1, -1},
	[150] = {"HI-FI", "HI-FI rendszer", 1.12, false, -1, -1},
	[151] = {"Festék patron", "Festék patron fújós spayekhez", 0.001, true, -1, -1},
	[152] = {"Hobby fa", "Hobby fa", 1.12, true, -1, -1},
	[153] = {"Eü. doboz", "Egészségügyi doboz", 0.25, true, -1, -1},
	[154] = {"Széf kulcs", "Széf kulcs", 0.25, false, -1, -1},
	[155] = {"Sokkoló", "Sokkoló pisztoly", 0.25, false, 24, -1},
	[156] = {"Ajándék", "Ajándék, tele meglepetésekkel", 0.25, false, 22, -1},
	[157] = {"Ünnepi süti", "Csak egy harapás és minden jobb lesz", 0.25, false, -1, -1},
	[158] = {"Aranyrúd", "Tömör aranyrúd, add el mihamarabb.", 10, false, -1, -1},
	[159] = {"Kutyasíp", "Legegyszerűbb módja, hogy kutyád megtaláljon", 0.01, false, -1, -1},
	[160] = {"Jutalom falat", "Melyik kutya ne szeretné?", 0.01, true, -1, -1},
	[161] = {"Kutyatáp", "Finom, ízletes kutyakaja", 1, true, -1, -1},
	[162] = {"Kutyasnack", "A kutyák Snickers-e", 0.01, true, -1, -1},
	[163] = {"PPSnack", "Minden ami tápláló, ebben megtalálható", 0.01, true, -1, -1},
	[164] = {"Csákány", "Csákány", 1.23, false, 15, -1},
	[165] = {"Kisebb petárda", "Egy petárda, mely a szilveszter már már hagyományos kelléke.", 0.005, true, -1, -1},
	[166] = {"Nagyobb petárda", "Egy petárda, mely a szilveszter már már hagyományos kelléke.", 0.005, true, -1, -1},
	[167] = {"Magyaros Pizza", "Magyaros Pizza.", 0.5, true, -1, -1},
	[168] = {"Mozerella Pizza", "Mozerella Pizza.", 0.5, true, -1, -1},
	[169] = {"Bolognese Pizza", "Bolognese Pizza.", 0.5, true, -1, -1},
	[170] = {"Spaghetti Bolognese", "Spaghetti Bolognese", 0.5, true, -1, -1},
	[171] = {"Spaghetti Carbonara", "Spaghetti Carbonara", 0.5, true, -1, -1},
	[172] = {"Lasagne", "Lasagne", 0.5, true, -1, -1},
	[173] = {"Dürüm", "Dürüm", 0.2, true, -1, -1},
	[174] = {"Baklava", "Baklava", 0.2, true, -1, -1},
	[175] = {"Tacos", "Tacos", 0.2, true, -1, -1},
	[176] = {"Burritos", "Burritos", 0.2, true, -1, -1},
	[177] = {"Quesadilla", "Quesadilla", 0.2, true, -1, -1},
	[178] = {"Fajitas", "Fajitas", 0.2, true, -1, -1},
	[179] = {"Sajtos Hamburger", "Sajtos Hamburger", 0.2, true, -1, -1},
	[180] = {"Dupla húsos hamburger", "Dupla húsos hamburger", 0.2, true, -1, -1},
	[181] = {"Sültkrumpli", "Sültkrumpli", 0.2, true, -1, -1},
	[182] = {"Presso Caffe", "Presso Caffe", 0.2, true, -1, -1},
	[183] = {"Capucino", "Capucino", 0.2, true, -1, -1},
	[184] = {"Cafe Latte", "Cafe Latte", 0.2, true, -1, -1},
	[185] = {"Fórró csoki", "Fórró csoki", 0.2, true, -1, -1},
	[186] = {"Coca Cola", "Coca Cola", 0.2, true, -1, -1},
	[187] = {"Szentelt Víz", "Visszahozza a kutyádat a pokol legmélyebb bugyraiból.", 0.2, true, -1, -1},
	[188] = {"Instant Fix Kártya", "Amikor egy isteni erő újjáéleszti az autódat, amiben ülsz.", 0, true, -1, -1},
	[189] = {"Instant Üzemanyag Kártya", "S lőn, teli a tank, ha a kocsiba ülsz.", 0, true, -1, -1},
	[190] = {"Instant Gyógyítás", "S lőn, egy isteni csoda felsegít téged.", 0, false, -1, -1},
	[191] = {"Cigaretta", "Egy csomag cigaretta.", 0, true, -1, -1},
	[192] = {"Pénz-kazetta", "Pénz-kazetta.", 10, true, -1, -1},
	[193] = {"Bónusz tojás", "Bónusz tojás", 0, true, -1, -1},
	[194] = {"Speciális locsoló kölni", "Exkluzív termék", 0, true, -1, -1},
	[195] = {"Hagyományos locsoló kölni", "Olcsó és meglehetősen büdös kölni", 0, true, -1, -1},
	[196] = {"Igazi piros tojás", "Ritka mint a fehér holló", 0, true, -1, -1},
	[197] = {"A tökéletes sonka receptje", "Több száz éves titok", 0, true, -1, -1},
	[198] = {"Medve bőr", "Medve bőr", 1, false, -1, -1},
	[199] = {"Medve trófea", "Medve trófea", 1, false, -1, -1},
	[200] = {"Vaddisznó bőr", "Vaddisznó bőr", 1, false, -1, -1},
	[201] = {"Vaddisznó trófea", "Vaddisznó trófea", 1, false, -1, -1},
	[202] = {"Őz bőr", "Őz bőr", 1, false, -1, -1},
	[203] = {"Őz trófea", "Őz trófea", 1, false, -1, -1},
	[204] = {"Dobókocka", "Dobókocka", 0, false, -1, -1},
	[205] = {"Kártyapakli", "Kártyapakli", 0, false, -1, -1},
	[206] = {"Jelvény", "Jelvény", 0, false, -1, -1},
	[207] = {"Személyigazolvány", "Személyigazolvány", 0, false, -1, -1},
	[208] = {"Jogosítvány", "Jogosítvány", 0, false, -1, -1},
	[209] = {"2014-es Hivatalos VB Labda", "2014-es Hivatalos VB Labda", 1, false, -1, -1},
	[210] = {"Karácsonyfa", "Egy díszes karácsonyfa", 1, false, -1, -1},
	[211] = {"Bot", "Horgászbot alapjául szolgáló bot", 1, false, -1, -1},
	[212] = {"Damil", "10 méter damil", 0.01, true, -1, -1},
	[213] = {"Csali és úszó", "Csali és úszó szett", 0.1, true, -1, -1},
	[214] = {"Horog", "Egy hegyes horog", 0.01, true, -1, -1},
	[215] = {"Horgászbot", "Kész horgászbot", 1.1, false, -1, -1},
	[216] = {"Fűrész", "Egy masszív acélból készült fűrész.", 1.1, false, -1, -1},
	[217] = {"Bakancs", "Egy büdös bakancs", 1, false, -1, -1},
	[218] = {"Hínár", "Tenyérnyi csúszós maszat", 0.1, false, -1, -1},
	[219] = {"Döglött hal", "Evésre kevésbé alkalmas hal", 0.5, true, -1, -1},
	[220] = {"Konzervdoboz", "Üres konzervdoboz", 0.3, false, -1, -1},
	[221] = {"Ismeretlen hal", "Senki se tudja mi ez, de aranyat ér", 2, false, -1, -1},
	[222] = {"Cápa", "Bébicápa", 7.5, false, -1, -1},
	[223] = {"Polip", "Polip", 2, false, -1, -1},
	[224] = {"Ördöghal", "Ördöghal", 2, false, -1, -1},
	[225] = {"Kardhal", "Kardhal", 3, false, -1, -1},
	[226] = {"Szamuráj rák", "Szamuráj rák", 0.5, false, -1, -1},
	[227] = {"Lepényhal", "Lepényhal", 1, false, -1, -1},
	[228] = {"Sügér", "Sügér", 2, false, -1, -1},
	[229] = {"Harcsa", "Harcsa", 2, false, -1, -1},
	[230] = {"Ponty", "Ponty", 2, false, -1, -1},
	[231] = {"Tengericsillag", "Tengericsillag", 0.2, false, -1, -1},
	[232] = {"Szárított marihuana", "Szárított marihuana.", 0.001, false, -1, -1},
	[233] = {"Kokain", "Tiszta kokain por.", 0.001, false, -1, -1},
	[234] = {"A fegyvermester: Glock 17", "Az alábbi könyv elolvasásával az adott fegyver mesterévé válhatsz", 1, false, -1, -1},
	[235] = {"A fegyvermester: A hangtompítós Colt-45", "Az alábbi könyv elolvasásával az adott fegyver mesterévé válhatsz", 1, false, -1, -1},
	[236] = {"A fegyvermester: Desert Eagle", "Az alábbi könyv elolvasásával az adott fegyver mesterévé válhatsz", 1, false, -1, -1},
	[237] = {"A fegyvermester: UZI & TEC-9", "Az alábbi könyv elolvasásával az adott fegyver mesterévé válhatsz", 1, false, -1, -1},
	[238] = {"A fegyvermester: P90", "Az alábbi könyv elolvasásával az adott fegyver mesterévé válhatsz", 1, false, -1, -1},
	[239] = {"A fegyvermester: AK-47", "Az alábbi könyv elolvasásával az adott fegyver mesterévé válhatsz", 1, false, -1, -1},
	[240] = {"A fegyvermester: M4", "Az alábbi könyv elolvasásával az adott fegyver mesterévé válhatsz", 1, false, -1, -1},
	[241] = {"A fegyvermester: Vadász-Mesterlövész puska", "Az alábbi könyv elolvasásával az adott fegyver mesterévé válhatsz", 1, false, -1, -1},
	[242] = {"A fegyvermester: Sörétes puska", "Az alábbi könyv elolvasásával az adott fegyver mesterévé válhatsz", 1, false, -1, -1},
	[243] = {"A fegyvermester: Taktikai sörétes puska", "Az alábbi könyv elolvasásával az adott fegyver mesterévé válhatsz", 1, false, -1, -1},
	[244] = {"A fegyvermester: A lefűrészelt sörétes", "Az alábbi könyv elolvasásával az adott fegyver mesterévé válhatsz", 1, false, -1, -1},
	[245] = {"Flex", "Egy flex", 1, false, -1, -1},
	[246] = {"Púpos horgászhal", "Púpos horgászhal", 1, false, -1, -1},
	[247] = {"Láda", "Láda", 3, false, -1, -1},
	[248] = {"Rák", "Rák", 0.5, false, -1, -1},
	[249] = {"Szakadt halászhaló", "Szakadt halászhaló", 0.5, false, -1, -1},
	[250] = {"Óriáspolip", "Óriáspolip", 5, false, -1, -1},
	[251] = {"Pörölycápa", "Pörölycápa", 4, false, -1, -1},
	[252] = {"Koi ponty", "Koi ponty", 2, false, -1, -1},
	[253] = {"Antik törzsi maszk", "Antik törzsi maszk", 2, false, -1, -1},
	[254] = {"Antik szobor", "Antik szobor", 2, false, -1, -1},
	[255] = {"Piranha", "Piranha", 0.5, false, -1, -1},
	[256] = {"Gömbhal", "Gömbhal", 0.5, false, -1, -1},
	[257] = {"Rozsdás vödör", "Rozsdás vödör", 0.5, false, -1, -1},
	[258] = {"Törött deszka", "Törött deszka", 1, false, -1, -1},
	[259] = {"Cápafog nyaklác", "Cápafog nyaklác", 0.1, false, -1, -1},
	[260] = {"Koponya", "Koponya", 2, false, -1, -1},
	[261] = {"Teknős", "Teknős", 2, false, -1, -1},
	[262] = {"Autóbomba", "Autóbomba", 5, false, -1, -1},
	[263] = {"Méreg Injekció", "Méreg Injekció", 0.1, false, -1, -1},
	[264] = {"Útlevél", "Útlevél", 0.1, false, -1, -1},
	[265] = {"Winter AK-47", "Winter Camo AK-47", 6, false, 30, 110},
	[266] = {"Camo AK-47", "Terep mintás AK-47 2", 6, false, 30, 110},
	[267] = {"Digit AK-47", "Digit camo AK-47", 6, false, 30, 110},
	[268] = {"Gold AK-47", "Arany AK-47 ver. 1", 6, false, 30, 110},
	[269] = {"Gold AK-47", "Arany AK-47 ver. 2", 6, false, 30, 110},
	[270] = {"Silver AK-47", "Ezüst AK-47-es", 6, false, 30, 110},
	[271] = {"Hello AK-47", "Pink Camo AK-47", 6, false, 30, 110},
	[272] = {"Camo Desert Eagle", "Terep mintás Desert Eagle pisztoly", 3, false, 24, 109},
	[273] = {"Gold Desert Eagle", "Arany Desert Eagle pisztoly", 3, false, 24, 109},
	[274] = {"Winter Sniper", "Winter Camo Sniper", 6, false, 34, 111},
	[275] = {"Camo Sniper", "Camo Sniper", 6, false, 34, 111},
	[276] = {"Camo P90", "Camo P90-ös fegyver.", 3, false, 29, 112},
	[277] = {"Winter Camo P90", "Winter Camo P90-ös fegyver.", 3, false, 29, 112},
	[278] = {"Black P90", "Black P90-ös fegyver.", 3, false, 29, 112},
	[279] = {"Gold Flow P90", "Gold Flow P90-ös fegyver.", 3, false, 29, 112},
	[280] = {"Camo knife", "Terep mintás kés.", 0.8, false, 4, -1},
	[281] = {"Rust knife", "Rozsdás kés", 0.8, false, 4, -1},
	[282] = {"Carbon knife", "Carbonból készült kés", 0.8, false, 4, -1},
	[283] = {"Bronze UZI", "Bronz UZI gépfegyver.", 3, false, 28, 112},
	[284] = {"Camo UZI", "Terep mintás UZI.", 3, false, 28, 112},
	[285] = {"Gold UZI", "Arany UZI gépfegyver.", 3, false, 28, 112},
	[286] = {"Winter UZI", "Winter style UZI.", 3, false, 28, 112},
	[287] = {"OBD scanner", "OBD scanner", 0.8, false, -1, -1},
	[288] = {"Műszaki adatlap", "Műszaki adatlap", 0.1, false, -1, -1},
	[289] = {"Forgalmi engedély", "Forgalmi engedély", 0.1, false, -1, -1},
	[290] = {"Traffipax radar", "Traffipax radar", 0.8, false, -1, -1},
	[291] = {"Villogó", "Villogó", 0.8, false, -1, -1},
	[292] = {"Villogó (Levétel)", "Villogó", 0.8, false, -1, -1},
	[293] = {"Black Jack Sorsjegy", "Black Jack Sorsjegy", 0.1, false, -1, -1},
	[294] = {"Lottószelvény", "Lottószelvény", 0.1, false, -1, -1},
	[295] = {"Lottó nyugta", "Lottó nyugta", 0.1, false, -1, -1},
	[296] = {"Money Mania Sorsjegy", "Money Mania Sorsjegy", 0.1, false, -1, -1},
	[297] = {"Tüzijáték", "Tüzijáték", 1, false, -1, -1},
	[298] = {"Sikoly tüzijáték", "Sikoly tüzijáték", 1, false, -1, -1},
	[299] = {"Blueprint", "Blueprint", 0.01, false, -1, -1},
	[300] = {"Horgászbot (Csali nélkül)", "Kész horgászbot, csali nélkül", 1.1, true, -1, -1},
	[301] = {"Markolat", "Markolat", 1.1, true, -1, -1},
	[302] = {"Penge", "Penge", 1.1, true, -1, -1},
	[303] = {"Tár", "Tár", 1.1, true, -1, -1},
	[304] = {"Markolat", "Markolat", 1.1, true, -1, -1},
	[305] = {"Cső", "Cső", 1.1, true, -1, -1},
	[306] = {"Felső rész", "Felső rész", 1.1, true, -1, -1},
	[307] = {"Felső rész", "Felső rész", 1.1, true, -1, -1},
	[308] = {"Fegyverengedély", "Fegyverengedély", 0.01, false, -1, -1},
	[309] = {"Adásvételi szerződés", "Adásvételi szerződés", 0.01, false, -1, -1},
	[310] = {"Horgászengedély", "Horgászengedély", 0.01, false, -1, -1},
	[311] = {"Üres adásvételi", "Üres adásvételi", 0.01, false, -1, -1},
	[312] = {"Toll", "Toll", 0.01, false, -1, -1},
	[313] = {"Csekk", "Csekk", 0.01, false, -1, -1},
	[314] = {"Csekkfüzet", "Csekkfüzet", 0.01, false, -1, -1},
	[315] = {"Névcédula", "Névcédula", 0.01, false, -1, -1},
	[316] = {"Taxi lámpa", "Taxi lámpa", 1, false, -1, -1},
	[317] = {"Taxi lámpa (levétel)", "Taxi lámpa (levétel)", 1, false, -1, -1},
	[318] = {"Távirányítós autóbomba", "Távirányítós autóbomba", 3, true, -1, -1},
	[319] = {"Detonátor", "Detonátor", 0.5, false, -1, -1},
	[320] = {"Antenna", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[321] = {"Ventillátor", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[322] = {"Tranzisztor", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[323] = {"NYÁK", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[324] = {"Mikroprocesszor", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[325] = {"Mini kijelző", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[326] = {"Mikrofon", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[327] = {"Elemlámpa LED", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[328] = {"Kondenzátor", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[329] = {"Hangszóró", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[330] = {"Nyomógomb", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[331] = {"Ellenállás", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[332] = {"Elem", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[333] = {"Műanyag doboz", "Alkatrész az elektronikai gyárban", 0.1, false, -1, -1},
	[334] = {"Walkie Talkie", "Kész termék az elektronikai gyárban", 0.1, false, -1, -1},
	[335] = {"Tápegység", "Kész termék az elektronikai gyárban", 0.1, false, -1, -1},
	[336] = {"Számológép", "Kész termék az elektronikai gyárban", 0.1, false, -1, -1},
	[337] = {"Rádió", "Kész termék az elektronikai gyárban", 0.1, false, -1, -1},
	[338] = {"Elemlámpa", "Kész termék az elektronikai gyárban", 0.1, false, -1, -1},
	[339] = {"Diktafon", "Kész termék az elektronikai gyárban", 0.1, false, -1, -1},
	[340] = {"No Limit P90", "No Limit P90-ös fegyver.", 3, false, 29, 112},
	[341] = {"Oni P90", "Oni P90-ös fegyver.", 3, false, 29, 112},
	[342] = {"Fekete sörétes puska", "Nagy kaliberű sörétes puska.", 6, false, 25, 114},
	[343] = {"Fekete 2 sörétes puska", "Nagy kaliberű sörétes puska.", 6, false, 25, 114},
	[344] = {"Arany sörétes puska", "Nagy kaliberű sörétes puska.", 6, false, 25, 114},
	[345] = {"Rozsdás sörétes puska", "Nagy kaliberű sörétes puska.", 6, false, 25, 114},
	[346] = {"Carbon P90", "Carbon P90-ös fegyver.", 3, false, 29, 112},
	[347] = {"Wood P90", "Wood P90-ös fegyver.", 3, false, 29, 112},
	[348] = {"Nike: A nagy bumm", "Egy stílusos táska, ami egy bombát tartalmaz.", 1.5, false, -1, -1},
	[349] = {"Nike detonátor", "Magától értetődő mit tud.", 0.1, false, -1, -1},
	[350] = {"Egy 'Ferrari 250 GTO' kulcsa", "Egy 'Ferrari 250 GTO' kulcsa", 0.1, false, -1, -1},
	[351] = {"Barracuda", "Barracuda", 2.5, false, -1, -1},
	[352] = {"Mahi Mahi", "Mahi Mahi", 3, false, -1, -1},
	[353] = {"Makréla", "Makréla", 1.5, false, -1, -1},
	[354] = {"Pávahal", "Pávahal", 2, false, -1, -1},
	[355] = {"Rája", "Rája", 4, false, -1, -1},
	[356] = {"Piros Snapper", "Piros Snapper", 1, false, -1, -1},
	[357] = {"Kakashal", "Kakashal", 3, false, -1, -1},
	[358] = {"Szakadt damil", "Szakadt damil", 0.1, false, -1, -1},
	[359] = {"Kék tonhal", "Kék tonhal", 3, false, -1, -1},
	[360] = {"Viperahal", "Viperahal", 1, false, -1, -1},
	[361] = {"Pénzkazetta", "Pénzkazetta", 2, false, -1, -1},
	[362] = {"Véső", "Véső", 0.5, true, -1, -1},
	[363] = {"Kakashal (verseny)", "Kakashal (verseny)", 1, false, -1, -1},
	[364] = {"Csipesz", "Csipesz", 0.1, false, -1, -1},
	[365] = {"Kioperált golyó", "Kioperált golyó", 0.1, false, -1, -1},
	[366] = {"Jegyzetfüzet", "Jegyzetfüzet", 0.1, false, -1, -1},
	[367] = {"Füzetlap", "Füzetlap", 0.1, false, -1, -1},
	[368] = {"Tök", "Tök", 5, false, -1, -1},
	[369] = {"Halloween P90", "P90-es fegyver.", 3, false, 29, 112},
	[370] = {"Tombola", "Tembola", 0.1, false, -1, -1},
	[371] = {"Tű", "Tű", 0.1, false, -1, -1},
	[372] = {"Kötszer", "Kötszer", 0.1, false, -1, -1},
	[373] = {"Kutyaátnevező kártya", "Kutyaátnevező kártya", 0.1, false, -1, -1},
	[374] = {"Szerencsemalac sorsjegy", "Szerencsemalac sorsjegy", 0.1, false, -1, -1},
	[375] = {"Pénzlift sorsjegy", "Pénzlift sorsjegy", 0.1, false, -1, -1}
}

scratchItems = {}

function resourceStart(res)
	if getResourceName(res) == "see_lottery" then
		scratchItems = exports.see_lottery:getScratchItems()
	else
		if source == resourceRoot then
			local see_lottery = getResourceFromName("see_lottery")

			if see_lottery and getResourceState(see_lottery) == "running" then
				scratchItems = exports.see_lottery:getScratchItems()
			end
		end
	end
end
addEventHandler("onResourceStart", root, resourceStart)
addEventHandler("onClientResourceStart", root, resourceStart)

function getWeaponNameFromIDNew(id)
	if id == 22 then
		return "Glock-17"
	elseif id == 29 then
		return "P90"
	elseif id == 34 then
		return "Remington 700"
	elseif id == 33 then
		return "Vadászpuska"
	else
		return getWeaponNameFromID(id)
	end
end

specialItems = {
	[7] = {"hamburger", 5},
	[6] = {"kebab", 5},
	[8] = {"kebab", 5},
	[179] = {"hamburger", 5},
	[180] = {"hamburger", 5},
	[126] = {"hamburger", 5},
	[39] = {"drink", 5},
	[41] = {"drink", 5},
	[42] = {"drink", 5},
	[182] = {"drink", 5},
	[183] = {"drink", 5},
	[184] = {"drink", 5},
	[185] = {"drink", 5},
	[186] = {"drink", 5},
	[40] = {"wine", 5},
	[43] = {"wine", 5},
	[45] = {"wine", 5},
	[46] = {"wine", 5},
	[44] = {"beer", 5},
	[65] = {"cigarette", 20},
	[66] = {"cigarette", 20},
	[191] = {"cigarette", 20},
	[167] = {"pizza", 5},
	[168] = {"pizza", 5},
	[169] = {"pizza", 5},
	[170] = {"pizza", 5},
	[171] = {"pizza", 5},
	[172] = {"pizza", 5},
	[173] = {"kebab", 5},
	[174] = {"kebab", 5},
	[175] = {"kebab", 5},
	[176] = {"kebab", 5},
	[177] = {"kebab", 5},
	[178] = {"kebab", 5},
	[181] = {"kebab", 5}
}

copyableItems = {
	[309] = true,
	[367] = true,
	[207] = true,
	[208] = true,
	[308] = true,
	[310] = true,
	[264] = true,
	[289] = true
}

ticketGroups = {
	army = {"Szabad rendvédelmi frakció", 21},
	nav = {"Las Venturas Sheriff Department", 13},
	pd = {"Las Venturas Police Department", 1},
	tek = {"Special Weapons And Tactics", 26},
	nni = {"Federal Bureau of Investigation", 12}
}

perishableItems = {
	[7] = 300,
	[179] = 300,
	[180] = 300,
	[126] = 300,
	[167] = 300,
	[168] = 300,
	[169] = 300,
	[170] = 300,
	[171] = 300,
	[172] = 300,
	[6] = 300,
	[8] = 300,
	[173] = 300,
	[174] = 300,
	[175] = 300,
	[176] = 300,
	[177] = 300,
	[178] = 300,
	[181] = 300,
	[148] = 300,
	[149] = 300,
	[221] = 420,
	[222] = 420,
	[223] = 420,
	[224] = 420,
	[225] = 420,
	[226] = 420,
	[227] = 420,
	[228] = 420,
	[229] = 420,
	[230] = 420,
	[231] = 420,
	[246] = 420,
	[248] = 420,
	[250] = 420,
	[251] = 420,
	[252] = 420,
	[255] = 420,
	[256] = 420,
	[261] = 420,
	[313] = 420,
	[351] = 420,
	[352] = 420,
	[353] = 420,
	[354] = 420,
	[354] = 420,
	[356] = 420,
	[357] = 420,
	[359] = 420,
	[359] = 420,
	[363] = 420
}

perishableEvent = {
	[221] = "fishPerishableEvent",
	[222] = "fishPerishableEvent",
	[223] = "fishPerishableEvent",
	[224] = "fishPerishableEvent",
	[225] = "fishPerishableEvent",
	[226] = "fishPerishableEvent",
	[227] = "fishPerishableEvent",
	[228] = "fishPerishableEvent",
	[229] = "fishPerishableEvent",
	[230] = "fishPerishableEvent",
	[231] = "fishPerishableEvent",
	[246] = "fishPerishableEvent",
	[248] = "fishPerishableEvent",
	[250] = "fishPerishableEvent",
	[251] = "fishPerishableEvent",
	[252] = "fishPerishableEvent",
	[255] = "fishPerishableEvent",
	[256] = "fishPerishableEvent",
	[261] = "fishPerishableEvent",
	[313] = "ticketPerishableEvent",
	[351] = "fishPerishableEvent",
	[352] = "fishPerishableEvent",
	[353] = "fishPerishableEvent",
	[354] = "fishPerishableEvent",
	[354] = "fishPerishableEvent",
	[356] = "fishPerishableEvent",
	[357] = "fishPerishableEvent",
	[359] = "fishPerishableEvent",
	[359] = "fishPerishableEvent",
	[363] = "fishPerishableEvent"
}

for k, v in pairs(perishableItems) do
	availableItems[k][4] = false
end

weaponSkins = {
	[265] = 1,
	[266] = 2,
	[267] = 3,
	[268] = 4,
	[269] = 5,
	[270] = 6,
	[271] = 7,
	[272] = 1,
	[273] = 2,
	[274] = 1,
	[275] = 2,
	[276] = 1,
	[277] = 2,
	[278] = 3,
	[279] = 4,
	[340] = 5,
	[341] = 6,
	[346] = 7,
	[347] = 8,
	[280] = 1,
	[281] = 2,
	[282] = 3,
	[283] = 1,
	[284] = 2,
	[285] = 3,
	[286] = 4,
	[342] = 1,
	[343] = 2,
	[344] = 3,
	[345] = 4,
	[369] = 9
}

function getItemPerishable(itemId)
	if availableItems[itemId] then
		if perishableItems[itemId] then
			return perishableItems[itemId]
		end
	end
	return false
end

function getWeaponSkin(itemId)
	return weaponSkins[itemId]
end

function isKeyItem(itemId)
	if itemId <= 3 or itemId == 154 or itemId == 119 then
		return true
	end
	return false
end

function isPaperItem(itemId)
	if itemId == 206 or itemId == 207 or itemId == 208 or itemId == 264 or itemId == 288 or itemId == 289 or itemId == 120 or itemId == 308 or itemId == 309
	or itemId == 311 or itemId == 313 or itemId == 314 or itemId == 310 or itemId == 366 or itemId == 367 or itemId == 370 or itemId >= 293 and itemId <= 296 or itemId == 299
	or scratchItems[itemId] then
		return true
	end
	return false
end

function getItemInfoForShop(itemId)
	return getItemName(itemId), getItemDescription(itemId), getItemWeight(itemId)
end

function getItemNameList()
	local nameList = {}

	for i = 1, #availableItems do
		nameList[i] = getItemName(i)
	end

	return nameList
end

function getItemDescriptionList()
	local descriptionList = {}

	for i = 1, #availableItems do
		descriptionList[i] = getItemDescription(i)
	end

	return descriptionList
end

function getItemName(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][1]
	end
	return false
end

function getItemDescription(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][2]
	end
	return false
end

function getItemWeight(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][3]
	end
	return false
end

function isItemStackable(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][4]
	end
	return false
end

function getItemWeaponID(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][5] or 0
	end
	return false
end

function getItemAmmoID(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][6]
	end
	return false
end

function isItemDroppable(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][7]
	end
	return false
end

function getItemDropDetails(itemId)
	if availableItems[itemId] and availableItems[itemId][8] then
		return availableItems[itemId][8], availableItems[itemId][9], availableItems[itemId][10], availableItems[itemId][11], availableItems[itemId][12]
	end
	return false
end

function isWeaponItem(itemId)
	if availableItems[itemId] and getItemWeaponID(itemId) > 0 then
		return true
	end
	return false
end

function isAmmoItem(itemId)
	if itemId >= 109 and itemId <= 114 or itemId == 151 then
		return true
	end
	return false
end

serialItems = {}

local weaponTypes = {
	[22] = "P",
	[23] = "P",
	[24] = "P",
	[25] = "S",
	[26] = "S",
	[27] = "S",
	[28] = "SM",
	[29] = "SM",
	[32] = "SM",
	[30] = "AR",
	[31] = "AR",
	[33] = "R",
	[34] = "R",
	[12] = "K",
	[8] = "K",
	[4] = "K"
}

for i = 1, #availableItems do
	if isWeaponItem(i) then
		local weaponId = getItemWeaponID(i)

		if weaponId >= 22 and weaponId <= 39 or weaponId == 12 or weaponId == 8 or weaponId == 4 or weaponId == 1 then
			availableItems[i][4] = false

			if i == 155 then
				serialItems[i] = "T"
			else
				serialItems[i] = weaponTypes[weaponId] or "O"
			end
		end
	end
end

local nonStackableItems = {}

for i = 1, #availableItems do
	if not isItemStackable(i) then
		table.insert(nonStackableItems, i)
	end
end

function getNonStackableItems()
	return nonStackableItems
end

craftDoNotTakeItems = {
	[34] = true,
	[20] = true,
	[245] = true,
	[21] = true,
	[24] = true
}

availableRecipes = {
	[1] = {
		name = "Horgászbot (csali nélkül)",
		items = {
			[1] = {false, 212, 211},
			[2] = {false, 214, false},
			[3] = {false, false, false}
		},
		finalItem = {300, 1},
		category = "Hobby"
	},
	[2] = {
		name = "Horgászbot+csali",
		items = {
			[1] = {false, 300, false},
			[2] = {false, 213, false},
			[3] = {false, false, false}
		},
		finalItem = {215, 1},
		category = "Hobby"
	},
	[3] = {
		name = "Cserepes növény: Mák",
		items = {
			[1] = {false, 12, false},
			[2] = {false, 56, false},
			[3] = {false, 54, false}
		},
		finalItem = {62, 1},
		category = "Cserepes növények"
	},
	[4] = {
		name = "Cserepes növény: Kokacserje",
		items = {
			[1] = {false, 11, false},
			[2] = {false, 56, false},
			[3] = {false, 54, false}
		},
		finalItem = {61, 1},
		category = "Cserepes növények"
	},
	[5] = {
		name = "Cserepes növény: Kender",
		items = {
			[1] = {false, 57, false},
			[2] = {false, 56, false},
			[3] = {false, 54, false}
		},
		finalItem = {63, 1},
		category = "Cserepes növények"
	},
	[6] = {
		name = "Szárított marihuána",
		items = {
			[1] = {false, false, false},
			[2] = {false, 20, false},
			[3] = {false, 13, false}
		},
		finalItem = {16, 1},
		requiredPermission = "drugCraft",
		suitableColShapes = {1, 2},
		category = "Drogok"
	},
	[7] = {
		name = "Füves cigi",
		items = {
			[1] = {false, false, false},
			[2] = {false, 16, 28},
			[3] = {false, false, false}
		},
		finalItem = {65, 1},
		requiredPermission = "drugCraft",
		category = "Drogok"
	},
	[8] = {
		name = "Kokain",
		items = {
			[1] = {false, 14, false},
			[2] = {23, 26, 27},
			[3] = {false, false, false}
		},
		finalItem = {17, 1},
		requiredPermission = "drugCraft",
		suitableColShapes = {1, 2},
		category = "Drogok"
	},
	[9] = {
		name = "Heroin por",
		items = {
			[1] = {false, 15, false},
			[2] = {26, 27, 22},
			[3] = {false, false, false}
		},
		finalItem = {18, 1},
		requiredPermission = "drugCraft",
		suitableColShapes = {1, 2},
		category = "Drogok"
	},
	[10] = {
		name = "Heroinos fecskendő",
		items = {
			[1] = {false, 18, 25},
			[2] = {false, 24, false},
			[3] = {false, 21, false}
		},
		finalItem = {60, 1},
		requiredPermission = "drugCraft",
		suitableColShapes = {1, 2},
		category = "Drogok"
	},
	[11] = {
		name = "Colt-45",
		items = {
			[1] = {139, 135, 134},
			[2] = {false, 137, 136},
			[3] = {34, false, 138}
		},
		finalItem = {76, 1, 25, 52},
		requiredPermission = "weaponCraft",
		suitableColShapes = {1, 2},
		category = "Fegyverek"
	},
	[12] = {
		name = "AK-47",
		items = {
			[1] = {false, 34, false},
			[2] = {128, 129, 130},
			[3] = {false, 137, 132}
		},
		finalItem = {85, 1, 25, 52},
		requiredPermission = "weaponCraft2",
		suitableColShapes = {1, 2},
		category = "Fegyverek"
	},
	[13] = {
		name = "Sörétes puska",
		items = {
			[1] = {false, 34, false},
			[2] = {140, 141, 142},
			[3] = {false, false, false}
		},
		finalItem = {79, 1, 25, 52},
		requiredPermission = "weaponCraft",
		suitableColShapes = {1, 2},
		category = "Fegyverek"
	},
	[14] = {
		name = "Vadászpuska",
		items = {
			[1] = {false, 34, false},
			[2] = {143, 145, 146},
			[3] = {false, 137, false}
		},
		finalItem = {87, 1, 25, 52},
		requiredPermission = "weaponCraft2",
		suitableColShapes = {1, 2},
		category = "Fegyverek"
	},
	[15] = {
		name = "UZI",
		items = {
			[1] = {305, 306, 34},
			[2] = {137, 304, false},
			[3] = {false, 303, false}
		},
		finalItem = {82, 1, 25, 52},
		requiredPermission = "weaponCraft",
		suitableColShapes = {1, 2},
		category = "Fegyverek"
	},
	[16] = {
		name = "TEC-9",
		items = {
			[1] = {false, 307, 34},
			[2] = {137, 304, false},
			[3] = {false, 303, false}
		},
		finalItem = {84, 1, 25, 52},
		requiredPermission = "weaponCraft2",
		suitableColShapes = {1, 2},
		category = "Fegyverek"
	},
	[17] = {
		name = "Kés",
		items = {
			[1] = {34, false, 245},
			[2] = {false, false, 302},
			[3] = {false, 301, false}
		},
		finalItem = {70, 1},
		requiredPermission = "weaponCraft",
		suitableColShapes = {1, 2},
		category = "Fegyverek"
	},
	[18] = {
		name = "Rádió",
		items = {
			[1] = {false, 325, 330},
			[2] = {320, 322, 328},
			[3] = {false, 323, 333}
		},
		finalItem = {337, 1},
		requiredJob = 1,
		suitableColShapes = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
		category = "Elektronika"
	},
	[19] = {
		name = "Walkie Talkie",
		items = {
			[1] = {329, 325, 330},
			[2] = {320, 322, 332},
			[3] = {326, 323, 333}
		},
		finalItem = {334, 1},
		requiredJob = 1,
		suitableColShapes = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
		category = "Elektronika"
	},
	[20] = {
		name = "Diktafon",
		items = {
			[1] = {false, 326, false},
			[2] = {332, 323, 325},
			[3] = {331, 329, 333}
		},
		finalItem = {339, 1},
		requiredJob = 1,
		suitableColShapes = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
		category = "Elektronika"
	},
	[21] = {
		name = "Elemlámpa",
		items = {
			[1] = {false, 327, false},
			[2] = {330, 331, 333},
			[3] = {false, 332, false}
		},
		finalItem = {338, 1},
		requiredJob = 1,
		suitableColShapes = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
		category = "Elektronika"
	},
	[22] = {
		name = "Tápegység",
		items = {
			[1] = {false, 328, false},
			[2] = {330, 331, 333},
			[3] = {323, 321, false}
		},
		finalItem = {335, 1},
		requiredJob = 1,
		suitableColShapes = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
		category = "Elektronika"
	},
	[23] = {
		name = "Számológép",
		items = {
			[1] = {false, 325, 330},
			[2] = {322, 324, 332},
			[3] = {false, 323, 333}
		},
		finalItem = {336, 1},
		requiredJob = 1,
		suitableColShapes = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
		category = "Elektronika"
	}
}
