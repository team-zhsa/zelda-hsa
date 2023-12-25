local waypoint_positions = { -- Indicates the coordinates in the entire world of the next step goal (when negative, the waypoint isn't displayed).
  -- Game started
  {x = 07040, y = 04424}, -- Hyrule Castle (Ocarina)
  -- "ocarina_obtained",
  {x = 07040, y = 04424}, -- Hyrule Castle (Lamp)
  -- "lamp_obtained",
  {x = 09856, y = 02416}, -- Blacksmith
  -- "sword_obtained",
  {x = 00656, y = 03048}, -- Sahasrahla's house in Kakarico
  -- "world_map_obtained",
  {x = 01808, y = 01736}, -- Priest in sanctuary
  -- "priest_met",
  {x = 00904, y = 00080}, -- Ruins
  -- "dungeon_1_started",
  {x = 00904, y = 00080}, -- Ruins (completing)
  -- "dungeon_1_completed",
  {x = 00656, y = 03048}, -- Ruins completed, go to Sahasrahla's house in Kakarico
  -- "sahasrahla_lost_woods_map",
  {x = 04472, y = 07792}, -- Sahasrahla met, go to Lost Woods mapper
  -- "lost_woods_map_obtained",
  {x = 02336, y = 04520}, -- Forest Temple
  -- "dungeon_2_started",
  {x = 02336, y = 04520}, -- Forest Temple (completing)
  -- "dungeon_2_completed",
  {x = 01808, y = 01736}, -- Forest Temple completed, show Sanctuary
  -- "priest_kidnapped",
  {x = 01808, y = 01736}, -- Forest Temple completed, go to Sanctuary
  -- "agahnim_met",
  {x = 01736, y = 00408}, -- Fire Temple
  -- "dungeon_3_started",
  {x = 01736, y = 00408}, -- Fire Temple (completing)
  -- "dungeon_3_completed",
  {x = 08320, y = 05112}, -- Fire Temple completed, go to  Temple of Time
  -- "master_sword_obtained",
  {x = 07040, y = 04424}, -- Hyrule Castle
  -- "zelda_kidnapped",
  {x = 07040, y = 04424}, -- Hyrule Castle
  -- "castle_unlocked",
  {x = 07040, y = 04424}, -- Hyrule Castle
  -- "castle_completed",
  {x = 00000, y = 05760} -- Deku Tree
  
}

return waypoint_positions