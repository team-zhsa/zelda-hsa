local steps={
  "game_started",
  "ocarina_obtained",
  "lamp_obtained",
  "sword_obtained",
  "world_map_obtained",
  "priest_met",
  "dungeon_1_started",
  "dungeon_1_completed",
  "sahasrahla_lost_woods_map",
  "lost_woods_mapper_met",
  "dungeon_2_started",
  "dungeon_2_completed",
  "priest_kidnapped",
  "agahnim_met",
  "dungeon_3_started",
  "dungeon_3_completed",
  "master_sword_obtained",
  "zelda_kidnapped",
  "castle_unlocked",
  "castle_completed",
  -- ...
  "dungeon_5_started",
  "dungeon_5_completed",
  "zora_flippers_obtained",
  "dungeon_6_started",
  "dungeon_6_completed",
  "gerudo_bridge_rebuilt",
  "lighthouse_key_obtained",
  "lighthouse_unlocked",
  "book_of_mudora_obtained",
  "dungeon_7_started",
  "dungeon_7_completed"
}

local index={}
for k,v in ipairs(steps) do
  index[v]=k
end
return index