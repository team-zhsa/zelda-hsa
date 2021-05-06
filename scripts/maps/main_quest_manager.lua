--Main quest steps manager


local main_steps=require("scripts/maps/lib/main_quest_steps_config")

local game_meta=sol.main.get_metatable("game")

function game_meta:get_step_index(step_id)
  if not main_steps[step_id] then
    error("No such quest step: "..step_id)
    return
  end
  return main_steps[step_id]
end

function game_meta:is_step_done(step_id)
  if not main_steps[step_id] then
    error("No such quest step: "..step_id)
    return
  end
  return self:get_value("main_quest_step") >= main_steps[step_id]
end

function game_meta:is_step_last(step_id)
  if not main_steps[step_id] then
    error("No such quest step: "..step_id)
    return
  end
  return self:get_value("main_quest_step") == main_steps[step_id]
end

function game_meta:set_step_done(step_id)
  if not main_steps[step_id] then
    error("No such quest step: "..step_id)
    return
  end
  return self:set_value("main_quest_step", main_steps[step_id])
end