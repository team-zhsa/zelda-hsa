local raft_manager = {}

function raft_manager:init(map)

  local game = map:get_game()
  local hero = map:get_hero()
  local raft = false
  local sprite = nil
  local model = nil
  local x,y, layer = hero:get_position()
    raft = true
    sprite = "entities/raft"
    model = "raft"
  if raft then --and hero:get_ground_below() == "deep_water" then
    map:create_custom_entity({
        name = "raft",
        sprite = sprite,
        x = x,
        y = y,
        width = 32,
        height = 32,
        layer = layer,
        direction = 0,
        model =  model
      })
  end
end


return raft_manager