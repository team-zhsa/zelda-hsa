local map= ...
local game = map:get_game()

function map:on_started()
  a6_key:set_enabled(false)
end

for enemy in map:get_entities("enemy_a6") do
  function enemy:on_dead()
    if not map:has_entities("enemy_a6")
      and not a6_key:is_enabled() then
        a6_key:set_enabled(true)
    end
  end
end