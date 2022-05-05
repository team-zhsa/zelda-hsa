local steps={
  "game_started",
  "sword_obtained",
  "world_map_obtained",
  "priest_met",
  "dungeon_1_started",
  "dungeon_1_completed",
  "dungeon_2_started",
  "dungeon_2_completed",
  "priest_kidnapped",
  "dungeon_3_started",
  "dungeon_3_completed",
  "master_sword_obtained",
  "zelda_kidnapped",
  "castle_unlocked",
  "castle_completed",
}

local index={}
for k,v in ipairs(steps) do
  index[v]=k
end
return index