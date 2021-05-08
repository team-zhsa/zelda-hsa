local steps={
  "game_started",
  "hero_awakened",
  "shield_obtained",
  "sword_obtained",
  "story_learned",
  "dungeons_1_discovered",
  "dungeon_1_completed",
  "bowwow_dognapped",
  "bowwow_joined",
  "dungeon_2_completed",
  "bowwow_returned",
  "castle_bridge_built",
  "golden_leaved_returned",
  "dungeon_3_key_obtained",
  "dungeon_3_opened",
  "dungeon_3_completed",
  "tarin_bee_event_over",
  "started_looking_for_marin",
  "marin_joined",
  "walrus_awakened",
  "sandworm_killed",
  "dungeon_4_key_obtained",
  "dungeon_4_opened",
  "dungeon_4_completed",
}

local index={}
for k,v in ipairs(steps) do
  index[v]=k
end
return index