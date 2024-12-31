local map_area_config = { -- Indicates the minimum and maximum coordinates of a given area, then assigns the corresponding name
	[1] = {-- A Row
		{key = "map.out.ruins"}, -- A1 (Ruins)
		{key = "map.out.hylia_lake"}, -- A2 (Hylia Lake, Water Temple)
		{key = "map.out.kakarico_village"}, -- A3 (Kakariko Village)
		{key = "map.out.lost_woods"}, -- A4 (Lost Woods)
		{key = "map.out.kokiri_village"}, -- A5 (Kokiri Forest)
		{key = "map.out.parapa_valley"}, -- A6 (Parapa Valley)
		{key = "map.out.parapa_town"}, -- A7 (Parapa Town)
		{key = "map.out.great_sea"}, -- A8 (Sea)
		{key = "map.out.great_sea"}, -- A9 (Sea)
		{key = "map.out.great_sea"}, -- A9 (Sea)
		},
	[2] = {-- B Row
		{key = "map.out.west_mountains"}, -- B1 (West Mountains)
		{key = "map.out.north_field"}, -- B2 (Sanctuary)
		{key = "map.out.kakarico_village"}, -- B3 (Kakariko Village)
		{key = "map.out.east_lost_woods"}, -- B4 (Sacred Grove, Forest Temple)
		{key = "map.out.gerudo_desert"}, -- B5 (Gerudo Desert, Desert Palace)
		{key = "map.out.parapa_valley"}, -- B6 (Parapa Valley)
		{key = "map.out.parapa_bay"}, -- B7 (Parapa Bay)
		{key = "map.out.great_sea"}, -- B8 (Sea)
		{key = "map.out.great_sea"}, -- B9 (Sea)
		{key = "map.out.great_sea"}, -- B9 (Sea)
		},
	[3] = {-- C Row
		{key = "map.out.west_mountains"}, -- C1 (West Mountains)
		{key = "map.out.north_field"}, -- C2 (Hyrule Field)
		{key = "map.out.north_field"}, -- C3 (Hyrule Field)
		{key = "map.out.gerudo_village"}, -- C4 (Gerudo Village)
		{key = "map.out.gerudo_desert"}, -- C5 (Desert)
		{key = "map.out.gerudo_desert"}, -- C6 (Gerudo River)
		{key = "map.out.miracles_coast"}, -- C7 (Miracles Coast)
		{key = "map.out.great_sea"}, -- C8 (Sea)
		{key = "map.out.great_sea"}, -- C9 (Sea)
		{key = "map.out.great_sea"}, -- C9 (Sea)
		},
	[4] = {-- D Row
		{key = "map.out.death_mountains"}, -- D1 (Death Mountains)
		{key = "map.out.north_field"}, -- D2 (Hyrule Field)
		{key = "map.out.north_field"}, -- D3 (Hyrule Field)
		{key = "map.out.north_west_castle"}, -- D4 (Hyrule Field)
		{key = "map.out.south_field"}, -- D5 (Hyrule Field)
		{key = "map.out.south_field"}, -- D6 (Hyrule Field)
		{key = "map.out.miracles_coast"}, -- D7 (Miracles Coast)
		{key = "map.out.great_sea"}, -- D8 (Sea)
		{key = "map.out.great_sea"}, -- D9 (Sea)
		{key = "map.out.great_sea"}, -- D9 (Sea)
	},
	[5] = {-- E Row
		{key = "map.out.death_mountains"}, -- E1 (Death Mountains)
		{key = "map.out.north_field"}, -- E2 (Hyrule Field)
		{key = "map.out.north_west_castle"}, -- E3 (North West Castle)
		{key = "map.out.north_west_castle"}, -- E4 (Hyrule Field)
		{key = "map.out.south_field"}, -- E5 (Hyrule Field, Vah'Naboris)
		{key = "map.out.south_field"}, -- E6 (Hyrule Field)
		{key = "map.out.miracles_coast"}, -- E7 (Miracles Coast)
		{key = "map.out.miracles_coast"}, -- E8 (Miracles Coast)
		{key = "map.out.great_sea"}, -- E9 (Sea)
		{key = "map.out.great_sea"}, -- E9 (Sea)
		},
	[6] = {-- F Row
		{key = "map.out.death_mountains"}, -- F1 (Death Mountain, Dodongo's Cavern)
		{key = "map.out.north_field"}, -- F2 (Hyrule Field)
		{key = "map.out.north_west_castle"}, -- F3 (North West Castle)
		{key = "map.out.hyrule_town"}, -- F4 (Hyrule Town)
		{key = "map.out.south_field"}, -- F5 (Hyrule Field)
		{key = "map.out.south_field"}, -- F6 (Hyrule Field)
		{key = "map.out.swamp"}, -- F7 (Great Swamp)
		{key = "map.out.miracles_coast"}, -- F8 (Miracles Coast)
		{key = "map.out.great_sea"}, -- F9 (Sea)
		{key = "map.out.great_sea"}, -- F9 (Sea)
		},
	[7] = {-- G Row
		{key = "map.out.east_mountains"}, -- G1 (East Mountains, Cesar's Peak)
		{key = "map.out.zora_river"}, -- G2 (Zora River)
		{key = "map.out.east_castle"}, -- G3 (Hyrule Field)
		{key = "map.out.east_castle"}, -- G4 (Hyrule Field, Temple of Time)
		{key = "map.out.south_field"}, -- G5 (Hyrule Field)
		{key = "map.out.south_field"}, -- G6 (Hyrule Field)
		{key = "map.out.miracles_coast"}, -- G7 (Garnet Coast)
		{key = "map.out.miracles_coast"}, -- G8 (Garnet Coast)
		{key = "map.out.great_sea"}, -- G9 (Sea)
		{key = "map.out.great_sea"}, -- G9 (Sea)
		},
	[8] = {-- H Row
		{key = "map.out.east_mountains"}, -- H1 (East Mountains)
		{key = "map.out.zora_river"}, -- H2 (Zora River)
		{key = "map.out.east_swamp"}, -- H3 (East Swamp)
		{key = "map.out.lonlon_ranch"}, -- H4 (Lon Lon Ranch, needs to be redone with better graphics)
		{key = "map.out.south_field"}, -- H5 (Hyrule Field)
		{key = "map.out.south_field"}, -- H6 (Flower house)
		{key = "map.out.miracles_coast"}, -- H7 (Miracles Coast)
		{key = "map.out.great_sea"}, -- H8 (Sea)
		{key = "map.out.great_sea"}, -- H9 (Sea)
		{key = "map.out.great_sea"}, -- H9 (Sea)
		},
	[9] = {-- I Row
		{key = "map.out.snowpeaks"}, -- I1 (Snowpeaks, Ice Temple)
		{key = "map.out.zora_forest"}, -- I2 (Zora Forest)
		{key = "map.out.cordinia_town"}, -- I3 (Cordinia Town)
		{key = "map.out.haunted_forest"}, -- I4 (Haunted Forest)
		{key = "map.out.south_field"}, -- I5 (Hyrule Field)
		{key = "map.out.south_field"}, -- out/i6
		{key = "map.out.cliffs_coast"}, -- I7 (Forests Coast)
		{key = "map.out.great_sea"}, -- I8 (Sea)
		{key = "map.out.great_sea"}, -- I9 (Sea)
		{key = "map.out.great_sea"}, -- I9 (Sea)
	 },
	[10] = {-- J Row
		{key = "map.out.snowpeaks"}, -- J1 (Snowpeaks)
		{key = "map.out.zora_forest"}, -- J2 (Zora Forest)
		{key = "map.out.zora_forest"}, -- J3 (Zora Forest)
		{key = "map.out.south_field"}, -- J4 (Hyrule Field)
		{key = "map.out.faron_woods"}, -- J5 (Faron Woods)
		{key = "map.out.faron_woods"}, -- J6 (Faron Woods)
		{key = "map.out.faron_woods"}, -- J7 (Faron Woods)
		{key = "map.out.great_sea"}, -- J8 (Sea)
		{key = "map.out.great_sea"}, -- J9 (Sea)
		{key = "map.out.great_sea"}, -- J9 (Sea)
	 },
	[11] = {-- K Row
		{key = "map.out.zora_village"}, -- K1 (Zora Village)
		{key = "map.out.zora_river"}, -- K2 (Zora River)
		{key = "map.out.rito_village"}, -- K3 (Rito Village)
		{key = "map.out.zora_forest"}, -- K4 (Woods Coast)
		{key = "map.out.faron_woods"}, -- K5 (Faron Woods)
		{key = "map.out.faron_woods"}, -- K6 (Faron Woods)
		{key = "map.out.faron_woods"}, -- K7 (Faron Woods)
		{key = "map.out.great_sea"}, -- K8 (Sea)
		{key = "map.out.great_sea"}, -- K9 (Sea)
		{key = "map.out.great_sea"}, -- K9 (Sea)
	 },
	[12] = {-- L Row
		{key = "map.out.zora_falls"}, -- L1 (Zora Falls)
		{key = "map.out.zora_river"}, -- L2 (Zora River)
		{key = "map.out.great_sea"}, -- L3 (Sea)
		{key = "map.out.great_sea"}, -- L4 (Sea)
		{key = "map.out.great_sea"}, -- L5 (Sea)
		{key = "map.out.great_sea"}, -- L6 (Sea)
		{key = "map.out.great_sea"}, -- L7 (Sea)
		{key = "map.out.great_sea"}, -- L8 (Sea)
		{key = "map.out.eventide_island"}, -- L9 (Eventide Island, Forgotten Temple)
		{key = "map.out.great_sea"}, -- L8 (Sea)
	 },
	[13] = {-- L Row
	{key = "map.out.great_sea"}, -- L3 (Sea)
	{key = "map.out.great_sea"}, -- L4 (Sea)
	{key = "map.out.great_sea"}, -- L5 (Sea)
	{key = "map.out.great_sea"}, -- L6 (Sea)
	{key = "map.out.great_sea"}, -- L7 (Sea)
	{key = "map.out.great_sea"}, -- L8 (Sea)		{key = "map.out.great_sea"}, -- L3 (Sea)
	{key = "map.out.great_sea"}, -- L4 (Sea)
	{key = "map.out.great_sea"}, -- L5 (Sea)
	{key = "map.out.great_sea"}, -- L6 (Sea)
	{key = "map.out.great_sea"}, -- L6 (Sea)
	 },
	
}

return map_area_config