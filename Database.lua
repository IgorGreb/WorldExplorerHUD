local addonName, WE = ...

WE.ZoneData = {
    -- EASTERN KINGDOMS
    ["Tirisfal Glades"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 1, 10 },
        mapIDs = { 1420 },
        quests = {},
        discoveryPoints = {
            { name = "Deathknell", x = 32.5, y = 65.5 },
            { name = "Brill", x = 61.5, y = 52.0 },
            { name = "Agamand Mills", x = 47.0, y = 36.0 },
            { name = "Scarlet Watch Post", x = 79.0, y = 25.0 },
            { name = "Garren's Haunt", x = 59.0, y = 31.0 },
            { name = "Crusader Outpost", x = 78.5, y = 56.0 },
            { name = "Solliden Farmstead", x = 37.5, y = 49.0 },
            { name = "Bulwark", x = 83.5, y = 68.5 },
            { name = "Bandarion Keep", x = 22.8, y = 48.2 },
            { name = "Shadowvale", x = 13.8, y = 64.5 },
        },
    },
    ["Silverpine Forest"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 10, 20 },
        mapIDs = { 1421 },
        quests = {},
        discoveryPoints = {
            { name = "The Sepulcher", x = 44.0, y = 42.5 },
            { name = "Ambermill", x = 57.5, y = 70.0 },
            { name = "Pyrewood Village", x = 45.5, y = 72.5 },
            { name = "Fenris Isle", x = 68.0, y = 12.0 },
            { name = "Olsen's Farthing", x = 50.0, y = 30.0 },
            { name = "Beren's Peril", x = 62.0, y = 42.5 },
            { name = "Deep Elem Mine", x = 56.0, y = 50.0 },
            { name = "The Greymane Wall", x = 43.0, y = 88.0 },
        },
    },
    ["Western Plaguelands"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 35, 45 },
        mapIDs = { 1422 },
        quests = {},
        discoveryPoints = {
            { name = "Andorhal", x = 45.0, y = 68.0 },
            { name = "Hearthglen", x = 45.5, y = 18.0 },
            { name = "Sorrow Hill", x = 53.0, y = 65.0 },
            { name = "Dalson's Tears", x = 48.0, y = 52.0 },
            { name = "Felstone Field", x = 38.0, y = 55.0 },
            { name = "Writhing Haunt", x = 52.0, y = 34.0 },
            { name = "Northridge Lumber Camp", x = 48.5, y = 31.5 },
            { name = "The Bulwark", x = 29.5, y = 57.0 },
        },
    },
    ["Eastern Plaguelands"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 45, 55 },
        mapIDs = { 1423 },
        quests = {},
        discoveryPoints = {
            { name = "Light's Hope Chapel", x = 81.5, y = 59.5 },
            { name = "Stratholme", x = 30.0, y = 14.5 },
            { name = "Tyr's Hand", x = 83.0, y = 77.0 },
            { name = "Corin's Crossing", x = 61.0, y = 76.0 },
            { name = "Darrowshire", x = 36.0, y = 85.0 },
            { name = "Plaguewood", x = 18.0, y = 35.0 },
            { name = "Northpass Tower", x = 43.0, y = 19.0 },
            { name = "Crown Guard Tower", x = 39.5, y = 74.5 },
            { name = "Eastwall Tower", x = 61.0, y = 59.5 },
        },
    },
    ["Hillsbrad Foothills"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 20, 30 },
        mapIDs = { 1424 },
        quests = {},
        discoveryPoints = {
            { name = "Tarren Mill", x = 62.0, y = 20.0 },
            { name = "Southshore", x = 51.0, y = 58.0 },
            { name = "Hillsbrad Fields", x = 32.0, y = 46.0 },
            { name = "Durnholde Keep", x = 79.0, y = 42.0 },
            { name = "Azurelode Mine", x = 48.0, y = 32.0 },
            { name = "Nethander Stead", x = 61.0, y = 57.0 },
            { name = "Dun Garok", x = 63.5, y = 73.5 },
            { name = "Tower Point", x = 51.5, y = 51.0 },
        },
    },
    ["The Hinterlands"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 40, 50 },
        mapIDs = { 1425 },
        quests = {},
        discoveryPoints = {
            { name = "Aerie Peak", x = 14.0, y = 44.0 },
            { name = "Revantusk Village", x = 78.0, y = 79.0 },
            { name = "Jintha'Alor", x = 63.0, y = 70.0 },
            { name = "Shaol'watha", x = 44.0, y = 48.0 },
            { name = "Plaguemist Ravine", x = 33.0, y = 64.0 },
            { name = "Quel'Danil Lodge", x = 32.0, y = 46.0 },
            { name = "Skulk Rock", x = 57.0, y = 42.0 },
        },
    },
    ["Arathi Highlands"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 30, 40 },
        mapIDs = { 1417 },
        quests = { 638, 639, 640, 642, 643, 644, 651, 652, 653, 655, 656, 657, 658, 659, 660, 661, 662, 663, 664, 665, 666, 667, 668, 669, 670, 676, 677, 678, 679, 680, 681, 682, 684, 685, 691, 692, 693, 694, 695, 696, 697, 702 },
        discoveryPoints = {
            { name = "Refuge Pointe", x = 45.2, y = 46.5 },
            { name = "Stromgarde Keep", x = 27.5, y = 63.0 },
            { name = "Hammerfall", x = 73.5, y = 36.8 },
            { name = "Go'Shek Farm", x = 60.2, y = 53.8 },
            { name = "Witherbark Village", x = 68.5, y = 70.4 },
            { name = "Boulderfist Hall", x = 53.6, y = 74.2 },
            { name = "Northfold Manor", x = 31.8, y = 28.4 },
            { name = "Boulder'gor", x = 32.5, y = 44.0 },
            { name = "Dabyrie's Farmstead", x = 55.4, y = 40.2 },
            { name = "Circle of East Binding", x = 66.8, y = 29.5 },
            { name = "Circle of West Binding", x = 25.4, y = 30.2 },
            { name = "Faldir's Cove", x = 31.2, y = 81.5 },
            { name = "Circle of Inner Binding", x = 34.5, y = 46.8 },
            { name = "Thoradin's Wall", x = 22.8, y = 24.5 },
            { name = "Arathi Basin", x = 73.2, y = 29.5 },
        },
        secrets = {
            {
                id = "arathi_01",
                name = "Sunken Ring Cache",
                description = "An ancient Arathi strongbox containing old coins, a war relic, and notes from Stromgarde's scouts.",
                description_uk = "Старовинна скриня Араті зі старими монетами, реліквією війни та нотатками розвідників Стронгарду.",
                hint = "Hidden in the ruins of Stromgarde",
                hint_uk = "Сховано в руїнах Стронгарду",
                x = 24.8,
                y = 58.6,
            },
            {
                id = "arathi_02",
                name = "Thandol Span Lookout",
                description = "A weathered bridge watchpost overlooking the southern border with a logbook of passing caravans.",
                description_uk = "Старий вартовий пост на мосту над південним кордоном із журналом проходячих караванів.",
                hint = "Southern bridge tower",
                hint_uk = "Південна вежа мосту",
                x = 45.5,
                y = 88.2,
            },
            {
                id = "arathi_03",
                name = "Witherbark Totem",
                description = "A carved forest-troll fetish bound with ancient charms and remnants of ritual offerings.",
                description_uk = "Різьблений тотем лісових тролів, обв'язаний давніми оберегами та залишками ритуальних дарів.",
                hint = "Deep inside the troll cave",
                hint_uk = "У глибині печери тролів",
                x = 71.2,
                y = 68.9,
            },
        },
    },
    ["Wetlands"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 20, 30 },
        mapIDs = { 1437 },
        quests = {},
        discoveryPoints = {
            { name = "Menethil Harbor", x = 9.0, y = 58.0 },
            { name = "Dun Modr", x = 47.0, y = 17.0 },
            { name = "Whelgar's Excavation Site", x = 34.0, y = 41.0 },
            { name = "Greenwarden's Grove", x = 56.0, y = 40.0 },
            { name = "Mosshide Fen", x = 62.0, y = 28.0 },
            { name = "Sundown Marsh", x = 17.0, y = 38.0 },
            { name = "Angerfang Encampment", x = 48.0, y = 78.0 },
            { name = "Ironbeard's Tomb", x = 45.0, y = 45.0 },
        },
    },
    ["Dun Morogh"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 1, 10 },
        mapIDs = { 1426 },
        quests = {},
        discoveryPoints = {
            { name = "Kharanos", x = 46.5, y = 52.0 },
            { name = "Coldridge Valley", x = 28.5, y = 72.5 },
            { name = "Gol'Bolar Quarry", x = 76.0, y = 36.0 },
            { name = "Gnomeregan", x = 24.5, y = 39.5 },
            { name = "Frostmane Hold", x = 22.5, y = 51.0 },
            { name = "Amberstill Ranch", x = 68.5, y = 59.5 },
            { name = "Helm's Bed Lake", x = 60.5, y = 44.5 },
            { name = "Brewnall Village", x = 30.0, y = 45.5 },
        },
    },
    ["Loch Modan"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 10, 20 },
        mapIDs = { 1432 },
        quests = {},
        discoveryPoints = {
            { name = "Thelsamar", x = 35.0, y = 49.0 },
            { name = "Algaz Station", x = 24.0, y = 18.0 },
            { name = "Silver Stream Mine", x = 35.0, y = 19.0 },
            { name = "Farstrider Lodge", x = 82.0, y = 64.0 },
            { name = "Stonewrought Dam", x = 47.0, y = 11.0 },
            { name = "Mo'grosh Stronghold", x = 72.0, y = 47.0 },
            { name = "Valley of Kings", x = 23.0, y = 75.0 },
        },
    },
    ["Badlands"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 35, 45 },
        mapIDs = { 1418 },
        quests = {},
        discoveryPoints = {
            { name = "Kargath", x = 4.0, y = 45.0 },
            { name = "Uldaman", x = 42.5, y = 11.5 },
            { name = "Angor Fortress", x = 42.0, y = 31.0 },
            { name = "Lethlor Ravine", x = 61.0, y = 54.0 },
            { name = "Agmond's End", x = 50.0, y = 62.0 },
            { name = "Dustwind Gulch", x = 26.0, y = 66.0 },
            { name = "Hammertoe's Digsite", x = 53.0, y = 34.0 },
        },
    },
    ["Searing Gorge"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 43, 50 },
        mapIDs = { 1427 },
        quests = {},
        discoveryPoints = {
            { name = "Thorium Point", x = 38.0, y = 27.0 },
            { name = "Blackrock Mountain", x = 34.5, y = 78.5 },
            { name = "The Cauldron", x = 64.0, y = 58.0 },
            { name = "Firewatch Ridge", x = 25.0, y = 33.0 },
            { name = "Slag Pit", x = 43.0, y = 54.0 },
            { name = "Grimesilt Dig Site", x = 65.0, y = 44.0 },
        },
    },
    ["Burning Steppes"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 50, 58 },
        mapIDs = { 1428 },
        quests = {},
        discoveryPoints = {
            { name = "Morgan's Vigil", x = 84.5, y = 68.5 },
            { name = "Flame Crest", x = 65.0, y = 24.0 },
            { name = "Blackrock Stronghold", x = 23.0, y = 35.0 },
            { name = "Altar of Storms", x = 27.0, y = 62.0 },
            { name = "Ruin of Thaurissan", x = 65.0, y = 42.0 },
            { name = "Terror Wing Path", x = 79.0, y = 45.0 },
            { name = "Dreadmaul Rock", x = 80.0, y = 35.0 },
        },
    },
    ["Elwynn Forest"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 1, 10 },
        mapIDs = { 1429 },
        quests = { 783, 7, 15, 18, 21, 33, 39, 40, 47, 54, 59, 60, 62, 71, 83, 84, 85, 86, 87, 88, 106, 107, 111, 112, 114, 215, 239, 244, 3101, 3102, 3103, 3104, 3105 },
        discoveryPoints = {
            { name = "Northshire Valley", x = 48.2, y = 41.5 },
            { name = "Goldshire", x = 42.1, y = 65.8 },
            { name = "Eastvale Logging Camp", x = 81.4, y = 66.2 },
            { name = "Tower of Azora", x = 64.8, y = 69.4 },
            { name = "Stone Cairn Lake", x = 74.5, y = 51.2 },
            { name = "Jerod's Landing", x = 48.5, y = 86.2 },
        },
        secrets = {
            {
                id = "elv_01",
                name = "Abandoned Camp",
                description = "A long-forgotten ranger campsite with a half-burned journal, cooking pot, and tracking marks.",
                description_uk = "Давно покинутий табір слідопита з напівзгорілим щоденником, казаном і слідами на землі.",
                hint = "North of the logging camp",
                hint_uk = "На північ від лісопилки",
                x = 79.5,
                y = 58.2,
            },
        },
    },
    ["Westfall"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 10, 20 },
        mapIDs = { 1436 },
        quests = {},
        discoveryPoints = {
            { name = "Sentinel Hill", x = 56.0, y = 47.5 },
            { name = "Moonbrook", x = 45.5, y = 70.5 },
            { name = "Furlbrow's Pumpkin Farm", x = 49.5, y = 19.5 },
            { name = "Saldean's Farm", x = 56.5, y = 31.0 },
            { name = "Gold Coast Quarry", x = 31.5, y = 48.0 },
            { name = "Jansen Stead", x = 56.0, y = 47.0 },
            { name = "The Dead Acre", x = 60.0, y = 52.0 },
            { name = "Westfall Lighthouse", x = 26.5, y = 86.5 },
        },
    },
    ["Redridge Mountains"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 15, 25 },
        mapIDs = { 1433 },
        quests = {},
        discoveryPoints = {
            { name = "Lakeshire", x = 26.5, y = 45.0 },
            { name = "Stonewatch Keep", x = 74.5, y = 41.5 },
            { name = "Render's Valley", x = 63.0, y = 17.5 },
            { name = "Alther's Mill", x = 52.0, y = 56.0 },
            { name = "Tower of Ilgalar", x = 65.0, y = 69.0 },
            { name = "Three Corners", x = 15.0, y = 71.0 },
            { name = "Redridge Canyons", x = 33.0, y = 26.0 },
        },
    },
    ["Duskwood"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 18, 30 },
        mapIDs = { 1431 },
        quests = {},
        discoveryPoints = {
            { name = "Darkshire", x = 73.5, y = 46.5 },
            { name = "Raven Hill", x = 18.0, y = 56.0 },
            { name = "Twilight Grove", x = 46.0, y = 36.0 },
            { name = "The Rotting Orchard", x = 64.0, y = 21.0 },
            { name = "Brightwood Grove", x = 61.0, y = 60.0 },
            { name = "Vul'Gol Ogre Mound", x = 35.0, y = 74.0 },
            { name = "Tranquil Gardens Cemetery", x = 80.0, y = 72.0 },
        },
    },
    ["Deadwind Pass"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 55, 60 },
        mapIDs = { 1430 },
        quests = {},
        discoveryPoints = {
            { name = "Karazhan", x = 47.0, y = 75.0 },
            { name = "Ariden's Camp", x = 52.0, y = 34.0 },
            { name = "The Vice", x = 42.0, y = 42.0 },
            { name = "Deadman's Crossing", x = 60.0, y = 41.0 },
        },
    },
    ["Swamp of Sorrows"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 35, 45 },
        mapIDs = { 1435 },
        quests = {},
        discoveryPoints = {
            { name = "Stonard", x = 47.0, y = 55.0 },
            { name = "The Harborage", x = 26.0, y = 32.0 },
            { name = "Splinterspear Junction", x = 54.0, y = 28.0 },
            { name = "Misty Reed Strand", x = 81.0, y = 68.0 },
            { name = "Fallow Sanctuary", x = 63.0, y = 46.0 },
            { name = "Atal'ai Ruins", x = 64.0, y = 77.0 },
        },
    },
    ["Blasted Lands"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 45, 55 },
        mapIDs = { 1419 },
        quests = {},
        discoveryPoints = {
            { name = "The Dark Portal", x = 55.0, y = 54.0 },
            { name = "Surwich", x = 45.0, y = 88.0 },
            { name = "Dreadmaul Hold", x = 40.0, y = 14.0 },
            { name = "Nethergarde Keep", x = 66.0, y = 23.0 },
            { name = "Serpent's Coil", x = 33.0, y = 48.0 },
            { name = "Rise of the Defiler", x = 51.0, y = 29.0 },
            { name = "Altar of Storms", x = 34.0, y = 62.0 },
        },
    },
    ["Stranglethorn Vale"] = {
        category = "CLASSIC",
        continent = "Eastern Kingdoms",
        levelRange = { 30, 45 },
        mapIDs = { 1434 },
        quests = {},
        discoveryPoints = {
            { name = "Booty Bay", x = 27.0, y = 77.0 },
            { name = "Grom'gol Base Camp", x = 32.0, y = 29.0 },
            { name = "Rebel Camp", x = 38.0, y = 11.0 },
            { name = "Nesingwary's Expedition", x = 35.5, y = 10.5 },
            { name = "Zul'Gurub", x = 54.0, y = 17.0 },
            { name = "Kurzen's Compound", x = 44.0, y = 9.0 },
            { name = "Bal'lal Ruins", x = 29.0, y = 20.0 },
            { name = "Ruins of Zul'Kunda", x = 24.0, y = 14.0 },
            { name = "Ruins of Aboraz", x = 21.0, y = 23.0 },
            { name = "Crystalvein Mine", x = 41.0, y = 42.0 },
            { name = "Mistvale Valley", x = 33.0, y = 50.0 },
            { name = "The Vile Reef", x = 25.0, y = 62.0 },
        },
    },

    -- KALIMDOR
    ["Teldrassil"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 1, 10 },
        mapIDs = { 1438 },
        quests = {},
        discoveryPoints = {
            { name = "Dolanaar", x = 55.5, y = 59.5 },
            { name = "Aldrassil", x = 29.5, y = 41.5 },
            { name = "Darnassus", x = 38.5, y = 22.0 },
            { name = "Shadowglen", x = 58.5, y = 44.5 },
            { name = "Starbreeze Village", x = 68.0, y = 56.0 },
            { name = "Wellspring Lake", x = 42.5, y = 31.0 },
            { name = "Ban'ethil Hollow", x = 44.0, y = 54.0 },
            { name = "Pool of Alar'ambala", x = 55.0, y = 26.0 },
        },
    },
    ["Darkshore"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 10, 20 },
        mapIDs = { 1439 },
        quests = {},
        discoveryPoints = {
            { name = "Auberdine", x = 37.0, y = 44.0 },
            { name = "Ameth'Aran", x = 43.0, y = 18.0 },
            { name = "Bashal'Aran", x = 44.0, y = 36.0 },
            { name = "Grove of the Ancients", x = 41.0, y = 78.0 },
            { name = "Ruins of Mathystra", x = 59.0, y = 24.0 },
            { name = "Tower of Althalaxx", x = 55.0, y = 25.0 },
            { name = "Cliffspring River", x = 49.0, y = 55.0 },
            { name = "Remtravel's Cabin", x = 47.0, y = 62.0 },
        },
    },
    ["Ashenvale"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 18, 30 },
        mapIDs = { 1440 },
        quests = {},
        discoveryPoints = {
            { name = "Astranaar", x = 37.0, y = 49.0 },
            { name = "Splintertree Post", x = 73.0, y = 65.0 },
            { name = "Zoram'gar Outpost", x = 12.0, y = 34.0 },
            { name = "Silverwind Refuge", x = 50.0, y = 67.0 },
            { name = "Warsong Lumber Camp", x = 90.0, y = 57.0 },
            { name = "Maestra's Post", x = 26.0, y = 38.0 },
            { name = "Raynewood Retreat", x = 61.0, y = 51.0 },
            { name = "Bough Shadow", x = 94.0, y = 38.0 },
            { name = "Forest Song", x = 85.0, y = 44.0 },
            { name = "The Howling Vale", x = 54.0, y = 30.0 },
        },
    },
    ["Felwood"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 45, 55 },
        mapIDs = { 1448 },
        quests = {},
        discoveryPoints = {
            { name = "Emerald Sanctuary", x = 51.0, y = 82.0 },
            { name = "Jaedenar", x = 36.0, y = 58.0 },
            { name = "Bloodvenom Post", x = 34.0, y = 52.0 },
            { name = "Talonbranch Glade", x = 62.0, y = 25.0 },
            { name = "Irontree Woods", x = 51.0, y = 8.0 },
            { name = "Deadwood Village", x = 47.0, y = 22.0 },
            { name = "Felpaw Village", x = 61.0, y = 9.0 },
            { name = "Jadefire Run", x = 39.0, y = 85.0 },
        },
    },
    ["Winterspring"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 53, 60 },
        mapIDs = { 1452 },
        quests = {},
        discoveryPoints = {
            { name = "Everlook", x = 61.0, y = 38.0 },
            { name = "Timbermaw Post", x = 27.0, y = 34.0 },
            { name = "Mazthoril", x = 62.0, y = 73.0 },
            { name = "Frostsaber Rock", x = 52.0, y = 28.0 },
            { name = "Owl Wing Thicket", x = 66.0, y = 70.0 },
            { name = "Lake Kel'Theril", x = 52.0, y = 42.0 },
            { name = "Starfall Village", x = 51.0, y = 11.0 },
            { name = "Winterfall Village", x = 68.0, y = 35.0 },
        },
    },
    ["Stonetalon Mountains"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 15, 27 },
        mapIDs = { 1442 },
        quests = {},
        discoveryPoints = {
            { name = "Stonetalon Peak", x = 37.5, y = 14.5 },
            { name = "Sun Rock Retreat", x = 47.0, y = 61.0 },
            { name = "Charred Vale", x = 32.0, y = 67.0 },
            { name = "Mirkfallon Lake", x = 49.0, y = 41.0 },
            { name = "Grimtotem Post", x = 73.0, y = 88.0 },
            { name = "Windshear Crag", x = 63.0, y = 44.0 },
            { name = "Webwinder Hollow", x = 60.0, y = 72.0 },
            { name = "Farwatcher's Glen", x = 35.0, y = 15.0 },
        },
    },
    ["Durotar"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 1, 10 },
        mapIDs = { 1411 },
        quests = { 784, 788, 789, 790, 792, 794, 804, 805, 806, 808, 809, 815, 816, 817, 818, 823, 825, 826, 827, 828, 829, 830, 832, 833, 834, 835, 837, 840 },
        discoveryPoints = {
            { name = "Valley of Trials", x = 43.2, y = 68.5 },
            { name = "Sen'jin Village", x = 55.8, y = 74.2 },
            { name = "Razor Hill", x = 52.4, y = 42.1 },
            { name = "Tiragarde Keep", x = 57.5, y = 55.0 },
            { name = "Echo Isles", x = 62.0, y = 82.4 },
            { name = "Skull Rock", x = 54.5, y = 11.2 },
        },
        secrets = {
            {
                id = "dur_01",
                name = "Cliffside Stash",
                description = "A concealed supply crate tucked into the ridge above Razor Hill with provisioning gear and maps.",
                description_uk = "Прихований ящик із припасами на скелі над Резор-Гілл зі спорядженням і картами.",
                hint = "Above Razor Hill",
                hint_uk = "Над Резор-Гілл",
                x = 51.2,
                y = 43.0,
            },
        },
    },
    ["The Barrens"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 10, 25 },
        mapIDs = { 1413 },
        quests = {},
        discoveryPoints = {
            { name = "The Crossroads", x = 52.0, y = 30.0 },
            { name = "Ratchet", x = 62.5, y = 37.5 },
            { name = "Camp Taurajo", x = 45.0, y = 59.0 },
            { name = "Wailing Caverns", x = 46.0, y = 36.0 },
            { name = "Bael Modan", x = 47.0, y = 86.0 },
            { name = "The Mor'shan Rampart", x = 48.0, y = 19.0 },
            { name = "Honor's Stand", x = 39.0, y = 10.0 },
            { name = "Lushwater Oasis", x = 48.0, y = 40.0 },
            { name = "Forgotten Pools", x = 45.0, y = 22.0 },
            { name = "Agama'gor", x = 45.0, y = 76.0 },
            { name = "Northwatch Hold", x = 62.0, y = 55.0 },
            { name = "Sludge Fen", x = 56.0, y = 8.0 },
            { name = "Merchant Coast", x = 68.0, y = 68.0 },
            { name = "Razorfen Kraul", x = 42.0, y = 89.0 },
        },
    },
    ["Desolace"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 30, 40 },
        mapIDs = { 1443 },
        quests = {},
        discoveryPoints = {
            { name = "Shadowprey Village", x = 23.0, y = 72.0 },
            { name = "Ghost Walker Post", x = 52.0, y = 53.0 },
            { name = "Kodo Graveyard", x = 47.0, y = 54.0 },
            { name = "Magram Village", x = 73.0, y = 72.0 },
            { name = "Mannoroc Coven", x = 53.0, y = 21.0 },
            { name = "Sargeron", x = 75.0, y = 21.0 },
            { name = "Thunder Axe Fortress", x = 55.0, y = 30.0 },
            { name = "Valley of Spears", x = 30.0, y = 55.0 },
        },
    },
    ["Mulgore"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 1, 10 },
        mapIDs = { 1412 },
        quests = {},
        discoveryPoints = {
            { name = "Bloodhoof Village", x = 47.0, y = 60.0 },
            { name = "Thunder Bluff", x = 45.5, y = 55.5 },
            { name = "Red Cloud Mesa", x = 45.0, y = 76.0 },
            { name = "Bael'dun Digsite", x = 31.0, y = 49.0 },
            { name = "The Golden Plains", x = 53.0, y = 48.0 },
            { name = "Windfury Ridge", x = 56.0, y = 25.0 },
        },
    },
    ["Feralas"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 40, 50 },
        mapIDs = { 1444 },
        quests = {},
        discoveryPoints = {
            { name = "Feathermoon Stronghold", x = 30.5, y = 43.5 },
            { name = "Camp Mojache", x = 74.5, y = 43.0 },
            { name = "Dire Maul", x = 59.0, y = 44.0 },
            { name = "Ruins of Isildien", x = 37.0, y = 8.0 },
            { name = "Gordunni Outpost", x = 75.0, y = 31.0 },
            { name = "The Twin Colossals", x = 44.0, y = 42.0 },
            { name = "Lower Wilds", x = 78.0, y = 62.0 },
            { name = "Lariss Pavilion", x = 89.0, y = 46.0 },
            { name = "Woodpaw Hills", x = 71.0, y = 64.0 },
        },
    },
    ["Dustwallow Marsh"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 35, 45 },
        mapIDs = { 1445 },
        quests = {},
        discoveryPoints = {
            { name = "Theramore Isle", x = 66.0, y = 45.0 },
            { name = "Brackenwall Village", x = 35.0, y = 30.0 },
            { name = "Mudsprocket", x = 42.0, y = 72.0 },
            { name = "Onyxia's Lair", x = 52.0, y = 76.0 },
            { name = "Witch Hill", x = 46.0, y = 24.0 },
            { name = "Dreadmur Spirit Roost", x = 30.0, y = 48.0 },
            { name = "Alcaz Island", x = 78.0, y = 17.0 },
            { name = "Wyrmbog", x = 54.0, y = 72.0 },
        },
    },
    ["Thousand Needles"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 25, 35 },
        mapIDs = { 1441 },
        quests = {},
        discoveryPoints = {
            { name = "Freewind Post", x = 45.5, y = 50.5 },
            { name = "The Shimmering Flats", x = 78.0, y = 77.0 },
            { name = "Highperch", x = 12.0, y = 32.0 },
            { name = "Splithoof Crag", x = 44.0, y = 36.0 },
            { name = "Darkcloud Pinnacle", x = 31.0, y = 33.0 },
            { name = "Whitereach Post", x = 21.0, y = 32.0 },
            { name = "Mirage Raceway", x = 78.0, y = 77.0 },
        },
    },
    ["Tanaris"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 40, 50 },
        mapIDs = { 1446 },
        quests = {},
        discoveryPoints = {
            { name = "Gadgetzan", x = 52.5, y = 28.0 },
            { name = "Zul'Farrak", x = 38.5, y = 19.5 },
            { name = "Steamwheedle Port", x = 67.0, y = 23.0 },
            { name = "Caverns of Time", x = 64.0, y = 50.0 },
            { name = "Lost Rigger Cove", x = 73.0, y = 47.0 },
            { name = "Lands of Displacement", x = 52.0, y = 45.0 },
            { name = "Eastmoon Ruins", x = 47.0, y = 69.0 },
            { name = "Dunemaul Compound", x = 41.0, y = 73.0 },
            { name = "Thistleshrub Valley", x = 28.0, y = 64.0 },
        },
    },
    ["Un'Goro Crater"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 48, 55 },
        mapIDs = { 1449 },
        quests = {},
        discoveryPoints = {
            { name = "Marshal's Refuge", x = 43.0, y = 9.5 },
            { name = "Fire Plume Ridge", x = 50.0, y = 49.0 },
            { name = "Golakka Hot Springs", x = 31.0, y = 50.0 },
            { name = "The Slithering Scar", x = 50.0, y = 78.0 },
            { name = "Terror Run", x = 68.0, y = 31.0 },
            { name = "Lakkari Tar Pits", x = 46.0, y = 13.0 },
            { name = "The Screaming Reaches", x = 68.0, y = 57.0 },
        },
    },
    ["Silithus"] = {
        category = "CLASSIC",
        continent = "Kalimdor",
        levelRange = { 55, 60 },
        mapIDs = { 1451 },
        quests = {},
        discoveryPoints = {
            { name = "Cenarion Hold", x = 49.0, y = 37.0 },
            { name = "Ahn'Qiraj", x = 29.0, y = 96.0 },
            { name = "Hive'Ashi", x = 23.0, y = 15.0 },
            { name = "Hive'Regal", x = 52.0, y = 69.0 },
            { name = "Hive'Zora", x = 32.0, y = 82.0 },
            { name = "Twilight's Run", x = 25.0, y = 54.0 },
            { name = "Valor's Rest", x = 75.0, y = 17.0 },
        },
    },

    -- WOW: FOREVER NEW ZONES
    ["Isle of Zefris"] = {
        category = "FOREVER_NEW",
        continent = "Kalimdor",
        levelRange = { 1, 12 },
        mapIDs = {}, -- custom zone: resolved by name, then learned at runtime
        quests = {},
        discoveryPoints = {
            { name = "Skyhaven Landing", x = 34.2, y = 62.5 },
            { name = "Windward Pass", x = 48.0, y = 49.0 },
            { name = "Cloudspire Sanctum", x = 61.5, y = 32.8 },
            { name = "Galecliff", x = 25.4, y = 35.1 },
            { name = "Forgotten Gardens", x = 72.0, y = 55.4 },
            { name = "Southern Beacon", x = 52.3, y = 78.6 },
        },
        secrets = {
            {
                id = "zeph_01",
                name = "Altar of Skywinds",
                description = "An elevated wind-chime shrine resonating with sky-magic and lore of the floating isle.",
                description_uk = "Високогірне святилище з вітряними дзвонами, що резонує магією неба та історією ширяючого острова.",
                hint = "Northern cliff edge",
                hint_uk = "Північний край скелі",
                x = 42.5,
                y = 18.2,
            },
            {
                id = "zeph_02",
                name = "Forgotten Windshaper Scroll",
                description = "A sealed arcane scroll containing early notes on stabilizing Zefris's floating currents.",
                description_uk = "Запечатаний магічний сувій із ранніми нотатками про стабілізацію повітряних потоків Зефріса.",
                hint = "Cave behind the waterfall",
                hint_uk = "Печера за водоспадом",
                x = 61.0,
                y = 54.8,
            },
        },
    },
    ["Mount Hyjal"] = {
        category = "FOREVER_NEW",
        continent = "Kalimdor",
        levelRange = { 55, 60 },
        mapIDs = {}, -- custom zone: resolved by name, then learned at runtime
        quests = {},
        discoveryPoints = {
            { name = "Nordrassil", x = 48.5, y = 33.2 },
            { name = "Shrine of Malorne", x = 35.0, y = 52.4 },
            { name = "Throne of the Chosen", x = 64.2, y = 45.8 },
            { name = "Ashen Slope", x = 57.8, y = 74.0 },
            { name = "Ancient Pass", x = 27.6, y = 68.5 },
        },
        secrets = {
            {
                id = "hyjal_01",
                name = "Wellspring of the World Tree",
                description = "A serene sacred pool fed by ancient nature energies at the roots of Nordrassil.",
                description_uk = "Тихе священне джерело, живлене давньою силою природи біля коріння Нордрассілу.",
                hint = "Beneath Nordrassil",
                hint_uk = "Під Нордрассілом",
                x = 48.0,
                y = 35.5,
            },
        },
    },
}

-- Legacy / alternative zone names that must resolve to a canonical ZoneData key.
-- Covers old duplicate entries and saved data recorded under them before v0.5.0.
WE.ZoneAliases = {
    ["Mul Gore"] = "Mulgore",
    ["Zephras Isle"] = "Isle of Zefris",
}

local mapIDIndex = nil   -- [uiMapID] = zoneKey, from static mapIDs
local nameIndex = nil    -- [lowercased name] = zoneKey, from keys, aliases and names_* fields

local function BuildIndexes()
    mapIDIndex, nameIndex = {}, {}
    for key, meta in pairs(WE.ZoneData) do
        nameIndex[key:lower()] = key
        for _, id in ipairs(meta.mapIDs or {}) do
            mapIDIndex[id] = key
        end
        for _, alt in ipairs(meta.altNames or {}) do
            nameIndex[alt:lower()] = key
        end
        -- Derived values: never hand-maintained totals.
        meta.totalSubzones = meta.discoveryPoints and #meta.discoveryPoints or 0
        meta.questSet = {}
        for _, qid in ipairs(meta.quests or {}) do
            meta.questSet[qid] = true
        end
        meta.pointByName = {}
        for _, pt in ipairs(meta.discoveryPoints or {}) do
            meta.pointByName[pt.name:lower()] = pt
            if pt.name_uk then meta.pointByName[pt.name_uk:lower()] = pt end
        end
    end
    for alias, key in pairs(WE.ZoneAliases) do
        nameIndex[alias:lower()] = key
    end
end

function WE:GetZoneMeta(zoneKey)
    if not zoneKey then return nil end
    return self.ZoneData[zoneKey]
end

-- Name -> canonical zone key (or nil if the zone is not in the database).
function WE:ResolveZoneKeyByName(name)
    if not name or name == "" then return nil end
    if not nameIndex then BuildIndexes() end
    return nameIndex[name:lower()]
end

-- Learned uiMapID -> zoneKey cache (for custom zones without static IDs).
local function LearnedCache()
    if WorldExplorerDB then
        WorldExplorerDB.mapIDCache = WorldExplorerDB.mapIDCache or {}
        return WorldExplorerDB.mapIDCache
    end
    return nil
end

local function GetMapInfoSafe(mapID)
    if mapID and C_Map and C_Map.GetMapInfo then
        return C_Map.GetMapInfo(mapID)
    end
    return nil
end

local function ResolveSingleMap(mapID, info)
    local byName = info and WE:ResolveZoneKeyByName(info.name) or nil
    local static = mapIDIndex[mapID]
    -- Name wins on conflict: protects against a static ID that means something
    -- else on this client/server.
    if byName then
        local cache = LearnedCache()
        if cache and not static then cache[mapID] = byName end
        return byName
    end
    if static then return static end
    local cache = LearnedCache()
    return cache and cache[mapID] or nil
end

-- uiMapID -> zoneKey. Walks up through micro-dungeon / sub-maps to the parent zone.
-- Returns zoneKey (canonical, or "map:<id>" for unknown zones), zone-level mapID, display name.
-- exact = true: do not walk up to parent maps (used for the map the player is *viewing*,
-- where pins must only be drawn on the zone map itself).
function WE:ResolveZoneKeyByMapID(mapID, exact)
    if not mapID then return nil end
    if not mapIDIndex then BuildIndexes() end

    local firstInfo = GetMapInfoSafe(mapID)
    local id, info, depth = mapID, firstInfo, 0
    while id and depth < 6 do
        local key = ResolveSingleMap(id, info)
        if key then
            return key, id, (info and info.name) or key
        end
        if exact then
            return "map:" .. tostring(mapID), mapID, firstInfo and firstInfo.name
        end
        local mt = info and info.mapType
        local isSubMap = Enum and Enum.UIMapType and mt and mt > Enum.UIMapType.Zone
        if not isSubMap or not info.parentMapID or info.parentMapID == 0 then break end
        id = info.parentMapID
        info = GetMapInfoSafe(id)
        depth = depth + 1
    end

    -- Unknown zone: key by the zone-level mapID so it is locale-independent.
    local zoneID, zoneInfo = mapID, firstInfo
    if Enum and Enum.UIMapType then
        local guard = 0
        while zoneInfo and zoneInfo.mapType and zoneInfo.mapType > Enum.UIMapType.Zone
            and zoneInfo.parentMapID and zoneInfo.parentMapID ~= 0 and guard < 6 do
            zoneID = zoneInfo.parentMapID
            zoneInfo = GetMapInfoSafe(zoneID)
            guard = guard + 1
        end
    end
    return "map:" .. tostring(zoneID), zoneID, (zoneInfo and zoneInfo.name) or nil
end

-- The player's current zone: { key, meta, mapID, name }.
function WE:GetCurrentZone()
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    local key, zoneMapID, name
    if mapID then
        key, zoneMapID, name = self:ResolveZoneKeyByMapID(mapID)
    end
    local realText = GetRealZoneText and GetRealZoneText() or nil
    if not key then
        -- Very old clients without C_Map: fall back to the zone text.
        key = self:ResolveZoneKeyByName(realText) or ((realText and realText ~= "") and realText or nil)
    end
    if not key then return nil end
    return {
        key = key,
        meta = self:GetZoneMeta(key),
        mapID = zoneMapID or mapID,
        name = (realText and realText ~= "") and realText or name or key,
    }
end

-- Localized display name for a stored zone key.
function WE:GetZoneDisplayName(zoneKey)
    if not zoneKey then return "?" end
    local meta = self:GetZoneMeta(zoneKey)
    local id = meta and meta.mapIDs and meta.mapIDs[1]
    if not id then
        id = tonumber(zoneKey:match("^map:(%d+)$"))
        if not id and WorldExplorerDB and WorldExplorerDB.mapIDCache then
            for cachedID, k in pairs(WorldExplorerDB.mapIDCache) do
                if k == zoneKey then id = cachedID break end
            end
        end
    end
    local info = GetMapInfoSafe(id)
    if info and info.name and info.name ~= "" then return info.name end
    local acc = WorldExplorerDB and WorldExplorerDB.account and WorldExplorerDB.account.zones and WorldExplorerDB.account.zones[zoneKey]
    if acc and acc.displayName then return acc.displayName end
    return zoneKey
end

-- Resolves a discovery point by any of its names (canonical English or localized).
function WE:FindDiscoveryPoint(meta, subZoneText)
    if not meta or not subZoneText or subZoneText == "" then return nil end
    if not meta.pointByName then BuildIndexes() end
    return meta.pointByName[subZoneText:lower()]
end

function WE:GetLocalizedPointName(pt)
    if not pt then return "" end
    if WE.Locale and WE.Locale:GetLang() == "ukUA" and pt.name_uk and pt.name_uk ~= "" then
        return pt.name_uk
    end
    return pt.name
end

function WE:GetLocalizedSecretField(sec, field)
    if not sec then return "" end
    if WE.Locale and WE.Locale:GetLang() == "ukUA" then
        local ukVal = sec[field .. "_uk"]
        if ukVal and ukVal ~= "" then
            return ukVal
        end
    end
    return sec[field] or ""
end

-- Build derived fields eagerly at load (ZoneData is static).
BuildIndexes()
