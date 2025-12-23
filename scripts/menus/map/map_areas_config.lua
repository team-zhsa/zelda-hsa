local map_area_config = { -- Indicates the minimum and maximum coordinates of a given area, then assigns the corresponding name

	[1] = {-- A Row
		{id = "out/a1", region = "north_field", key = "maps.out.ruins"},-- A1 (N Field, Ruins)
		{id = "out/a2", region = "north_field", key = "maps.out.hylia_lake"}, -- A2 (N Field, Hylia Lake, Water Temple)
		{id = "out/a3", region = "kakarico", key = "maps.out.kakarico_village"}, -- A3 (Kakariko Village)
		{id = "out/a4", region = "lost_woods", key = "maps.out.lost_woods"}, -- A4 (Lost Woods)
		{id = "out/a5", region = "lost_woods", key = "maps.out.kokiri_village"}, -- A5 (Kokiri Forest)
		{id = "out/a6", region = "parapa", key = "maps.out.parapa_valley"}, -- A6 (Parapa Valley)
		{id = "out/a7", region = "parapa", key = "maps.out.parapa_town"}, -- A7 (Parapa Town)
		{id = "out/a8", region = "sea", key = "maps.out.great_sea"}, -- A8 (Sea)
		{id = "out/a9", region = "sea", key = "maps.out.great_sea"}, -- A9 (Sea)
		{id = "out/a9", region = "sea", key = "maps.out.great_sea"}, -- A9 (Sea)
		},
	[2] = {-- B Row
		{id = "out/b1", region = "west_mountains", key = "maps.out.west_mountains"}, -- B1 (W Mountains)
		{id = "out/b2", region = "north_field", key = "maps.out.north_field"}, -- B2 (N Field, Sanctuary)"
		{id = "out/b3", region = "kakarico", key = "maps.out.kakarico_village"}, -- B3 (Kakariko Village)
		{id = "out/b4", region = "lost_woods", key = "maps.out.sacred_grove"}, -- B4 (Sacred Grove, Forest Temple)
		{id = "out/b5", region = "gerudo", key = "maps.out.gerudo_desert"}, -- B5 (Gerudo Desert, Desert Palace)
		{id = "out/b6", region = "parapa", key = "maps.out.parapa_valley"}, -- B6 (Parapa Valley)
		{id = "out/b7", region = "parapa", key = "maps.out.parapa_bay"}, -- B7 (Parapa Bay)
		{id = "out/b8", region = "sea", key = "maps.out.great_sea"}, -- B8 (Sea)
		{id = "out/b9", region = "sea", key = "maps.out.great_sea"}, -- B9 (Sea)
		{id = "out/b9", region = "sea", key = "maps.out.great_sea"}, -- B9 (Sea)
		},
	[3] = {-- C Row
		{id = "out/c1", region = "west_mountains", key = "maps.out.west_mountains"}, -- C1 (W Mountains)
		{id = "out/c2", region = "north_field", key = "maps.out.north_field"}, -- C2 (N Field)
		{id = "out/c3", region = "north_field", key = "maps.out.north_field"}, -- C3 (N Field)
		{id = "out/c4", region = "gerudo", key = "maps.out.gerudo_village"}, -- C4 (Gerudo Village)
		{id = "out/c5", region = "gerudo", key = "maps.out.gerudo_desert"}, -- C5 (Gerudo Desert)
		{id = "out/c6", region = "gerudo", key = "maps.out.gerudo_desert"}, -- C6 (Gerudo River)
		{id = "out/c7", region = "miracles_coast", key = "maps.out.miracles_coast"}, -- C7 (Miracles Coast)
		{id = "out/c8", region = "sea", key = "maps.out.great_sea"}, -- C8 (Sea)
		{id = "out/c9", region = "sea", key = "maps.out.great_sea"}, -- C9 (Sea)
		{id = "out/c9", region = "sea", key = "maps.out.great_sea"}, -- C9 (Sea)
		},
	[4] = {-- D Row
		{id = "out/d1", region = "death_mountains", key = "maps.out.death_mountains"}, -- D1 (Death Mountains)
		{id = "out/d2", region = "north_field", key = "maps.out.north_field"}, -- D2 (N Field)
		{id = "out/d3", region = "north_field", key = "maps.out.north_field"}, -- D3 (N Field)
		{id = "out/d4", region = "around_castle", key = "maps.out.around_castle"}, -- D4 (Around the Castle)
		{id = "out/d5", region = "south_field", key = "maps.out.south_field"}, -- D5 (S Field)
		{id = "out/d6", region = "south_field", key = "maps.out.south_field"}, -- D6 (S Field)
		{id = "out/d7", region = "miracles_coast", key = "maps.out.miracles_coast"}, -- D7 (Miracles Coast)
		{id = "out/d8", region = "sea", key = "maps.out.great_sea"}, -- D8 (Sea)
		{id = "out/d9", region = "sea", key = "maps.out.great_sea"}, -- D9 (Sea)
		{id = "out/d9", region = "sea", key = "maps.out.great_sea"}, -- D9 (Sea)
	},
	[5] = {-- E Row
		{id = "out/e1", region = "north_field", key = "maps.out.death_mountains"}, -- E1 (Death Mountains)
		{id = "out/e2", region = "north_field", key = "maps.out.north_field"}, -- E2 (N Field)
		{id = "out/e3", region = "around_castle", key = "maps.out.around_castle"}, -- E3 (Around the Castle)
		{id = "out/e4", region = "around_castle", key = "maps.out.around_castle"}, -- E4 (Around the Castle)
		{id = "out/e5", region = "south_field", key = "maps.out.south_field"}, -- E5 (S Field, Vah'Naboris)
		{id = "out/e6", region = "south_field", key = "maps.out.south_field"}, -- E6 (S Field)
		{id = "out/e7", region = "miracles_coast", key = "maps.out.miracles_coast"}, -- E7 (Miracles Coast)
		{id = "out/e8", region = "miracles_coast", key = "maps.out.miracles_coast"}, -- E8 (Miracles Coast)
		{id = "out/e9", region = "sea", key = "maps.out.great_sea"}, -- E9 (Sea)
		{id = "out/e9", region = "sea", key = "maps.out.great_sea"}, -- E9 (Sea)
		},
	[6] = {-- F Row
		{id = "out/f1", region = "death_mountains", key = "maps.out.death_mountains"}, -- F1 (Death Mountain, Dodongo's Cavern)
		{id = "out/f2", region = "north_field", key = "maps.out.north_field"}, -- F2 (N Field)
		{id = "out/f3", region = "north_field", key = "maps.out.around_castle"}, -- F3 (North West Castle)
		{id = "out/f4", region = "castle_town", key = "maps.out.castle_town"}, -- F4 (Castle Town)
		{id = "out/f5", region = "south_field", key = "maps.out.south_field"}, -- F5 (S Field)
		{id = "out/f6", region = "south_field", key = "maps.out.south_field"}, -- F6 (S Field)
		{id = "out/f7", region = "swamp", key = "maps.out.swamp"}, -- F7 (Great Swamp)
		{id = "out/f8", region = "miracles_coast", key = "maps.out.miracles_coast"}, -- F8 (Miracles Coast)
		{id = "out/f9", region = "sea", key = "maps.out.great_sea"}, -- F9 (Sea)
		{id = "out/f9", region = "sea", key = "maps.out.great_sea"}, -- F9 (Sea)
		},
	[7] = {-- G Row
		{id = "out/g1", region = "east_mountains", key = "maps.out.east_mountains"}, -- G1 (East Mountains, Cesar's Peak)
		{id = "out/g2", region = "north_field", key = "maps.out.zora_river"}, -- G2 (Zora River)
		{id = "out/g3", region = "north_field", key = "maps.out.east_castle"}, -- G3 (N Field)
		{id = "out/g4", region = "east_castle", key = "maps.out.east_castle"}, -- G4 (East of the Castle, Temple of Time)
		{id = "out/g5", region = "south_field", key = "maps.out.south_field"}, -- G5 (S Field)
		{id = "out/g6", region = "south_field", key = "maps.out.south_field"}, -- G6 (S Field)
		{id = "out/g7", region = "miracles_coast", key = "maps.out.miracles_coast"}, -- G7 (Garnet Coast)
		{id = "out/g8", region = "miracles_coast", key = "maps.out.miracles_coast"}, -- G8 (Garnet Coast)
		{id = "out/g9", region = "sea", key = "maps.out.great_sea"}, -- G9 (Sea)
		{id = "out/g9", region = "sea", key = "maps.out.great_sea"}, -- G9 (Sea)
		},
	[8] = {-- H Row
		{id = "out/h1", region = "east_mountains", key = "maps.out.east_mountains"}, -- H1 (East Mountains)
		{id = "out/h2", region = "north_field", key = "maps.out.zora_river"}, -- H2 (Zora River)
		{id = "out/h3", region = "north_field", key = "maps.out.east_swamp"}, -- H3 (East Swamp)
		{id = "out/h4", region = "south_field", key = "maps.out.lonlon_ranch"}, -- H4 (Lon Lon Ranch, needs to be redone with better graphics)
		{id = "out/h5", region = "south_field", key = "maps.out.south_field"}, -- H5 (S Field)
		{id = "out/h6", region = "south_field", key = "maps.out.south_field"}, -- H6 (S Field, Flower house)
		{id = "out/h7", region = "miracles_coast", key = "maps.out.miracles_coast"}, -- H7 (Miracles Coast)
		{id = "out/h8", region = "sea", key = "maps.out.great_sea"}, -- H8 (Sea)
		{id = "out/h9", region = "sea", key = "maps.out.great_sea"}, -- H9 (Sea)
		{id = "out/h9", region = "sea", key = "maps.out.great_sea"}, -- H9 (Sea)
		},
	[9] = {-- I Row
		{id = "out/i1", region = "snowpeaks", key = "maps.out.snowpeaks"}, -- I1 (Snowpeaks, Ice Temple)
		{id = "out/i2", region = "lanayru_forest", key = "maps.out.lanayru_forest"}, -- I2 (Lanayru Forest)
		{id = "out/i3", region = "cordinia", key = "maps.out.cordinia_town"}, -- I3 (Cordinia Town)
		{id = "out/i4", region = "cordinia", key = "maps.out.haunted_forest"}, -- I4 (Haunted Forest)
		{id = "out/i5", region = "south_field", key = "maps.out.south_field"}, -- I5 (S Field)
		{id = "out/i6", region = "south_field", key = "maps.out.south_field"}, -- I6 (S Field)
		{id = "out/i7", region = "cliffs_coast", key = "maps.out.cliffs_coast"}, -- I7 (Cliffs Coast)
		{id = "out/i8", region = "sea", key = "maps.out.great_sea"}, -- I8 (Sea)
		{id = "out/i9", region = "sea", key = "maps.out.great_sea"}, -- I9 (Sea)
		{id = "out/i9", region = "sea", key = "maps.out.great_sea"}, -- I9 (Sea)
	 },
	[10] = {-- J Row
		{id = "out/j1", region = "snowpeaks", key = "maps.out.snowpeaks"}, -- J1 (Snowpeaks)
		{id = "out/j2", region = "lanayru_forest", key = "maps.out.lanayru_forest"}, -- J2 (Lanayru Forest)
		{id = "out/j3", region = "lanayru_forest", key = "maps.out.lanayru_forest"}, -- J3 (Lanayru Forest)
		{id = "out/j4", region = "south_field", key = "maps.out.south_field"}, -- J4 (S Field)
		{id = "out/j5", region = "faron_woods", key = "maps.out.faron_woods"}, -- J5 (Faron Woods)
		{id = "out/j6", region = "faron_woods", key = "maps.out.faron_woods"}, -- J6 (Faron Woods)
		{id = "out/j7", region = "faron_woods", key = "maps.out.faron_woods"}, -- J7 (Faron Woods)
		{id = "out/j8", region = "sea", key = "maps.out.great_sea"}, -- J8 (Sea)
		{id = "out/j9", region = "sea", key = "maps.out.great_sea"}, -- J9 (Sea)
		{id = "out/j9", region = "sea", key = "maps.out.great_sea"}, -- J9 (Sea)
	 },
	[11] = {-- K Row
		{id = "out/k1", region = "zora_village", key = "maps.out.zora_village"}, -- K1 (Zora Village)
		{id = "out/k2", region = "zora_village", key = "maps.out.zora_river"}, -- K2 (Zora River)
		{id = "out/k3", region = "lanayru_forest", key = "maps.out.rito_village"}, -- K3 (Rito Village)
		{id = "out/k4", region = "lanayru_forest", key = "maps.out.lanayru_forest"}, -- K4 (Woods Coast)
		{id = "out/k5", region = "faron_woods", key = "maps.out.faron_woods"}, -- K5 (Faron Woods)
		{id = "out/k6", region = "faron_woods", key = "maps.out.faron_woods"}, -- K6 (Faron Woods)
		{id = "out/k7", region = "faron_woods", key = "maps.out.faron_woods"}, -- K7 (Faron Woods)
		{id = "out/k8", region = "sea", key = "maps.out.great_sea"}, -- K8 (Sea)
		{id = "out/k9", region = "sea", key = "maps.out.great_sea"}, -- K9 (Sea)
		{id = "out/k9", region = "sea", key = "maps.out.great_sea"}, -- K9 (Sea)
	 },
	[12] = {-- L Row
		{id = "out/l1", region = "zora_village", key = "maps.out.zora_falls"}, -- L1 (Zora Falls)
		{id = "out/l2", region = "zora_village", key = "maps.out.zora_river"}, -- L2 (Zora River)
		{id = "out/l3", region = "sea", key = "maps.out.great_sea"}, -- L3 (Sea)
		{id = "out/l4", region = "sea", key = "maps.out.great_sea"}, -- L4 (Sea)
		{id = "out/l5", region = "sea", key = "maps.out.great_sea"}, -- L5 (Sea)
		{id = "out/l6", region = "sea", key = "maps.out.great_sea"}, -- L6 (Sea)
		{id = "out/l7", region = "sea", key = "maps.out.great_sea"}, -- L7 (Sea)
		{id = "out/l8", region = "sea", key = "maps.out.great_sea"}, -- L8 (Sea)
		{id = "out/l9", region = "eventide", key = "maps.out.eventide_island"}, -- L9 (Eventide Island, Forgotten Temple)
		{id = "out/l9", region = "sea", key = "maps.out.great_sea"}, -- L8 (Sea)
	 },
	[13] = {-- M Row
	{id = "out/m1", region = "sea", key = "maps.out.great_sea"}, -- L3 (Sea)
	{id = "out/m2", region = "sea", key = "maps.out.great_sea"}, -- L4 (Sea)
	{id = "out/m3", region = "sea", key = "maps.out.great_sea"}, -- L5 (Sea)
	{id = "out/m4", region = "sea", key = "maps.out.great_sea"}, -- L6 (Sea)
	{id = "out/m5", region = "sea", key = "maps.out.great_sea"}, -- L7 (Sea)
	{id = "out/m6", region = "sea", key = "maps.out.great_sea"}, -- L8 (Sea)		{key = "maps.out.great_sea"}, -- L3 (Sea)
	{id = "out/m7", region = "sea", key = "maps.out.great_sea"}, -- L4 (Sea)
	{id = "out/m8", region = "sea", key = "maps.out.great_sea"}, -- L5 (Sea)
	{id = "out/m9", region = "sea", key = "maps.out.great_sea"}, -- L6 (Sea)
	{id = "out/m9", region = "sea", key = "maps.out.great_sea"}, -- L6 (Sea)
	 },
	
}

return map_area_config