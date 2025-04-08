local block_manager={}

function block_manager:init_block_riddle(map, group_prefix, callback)
  if map.blocks_remaining == nil then
    map.blocks_remaining={}
  end
  map.blocks_remaining[group_prefix] = map:get_entities_count(group_prefix)
  local game = map:get_game()

  for block in map:get_entities(group_prefix) do
    block.group=group_prefix
    block:register_event("on_moved", function() 
      local remaining=map.blocks_remaining[block.group]
      remaining = remaining - 1
      map.blocks_remaining[block.group] = remaining
      if remaining == 0 then
        if callback then
          callback()
        end
      end
    end)
  end
end
return block_manager