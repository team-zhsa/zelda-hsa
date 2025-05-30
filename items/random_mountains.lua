local item = ...

-- When it is created, this item creates another item randomly chosen
-- and then destroys itself.

-- Probability of each item between 0 and 200.
local probabilities = {
  [{ "rupee", 1 }]      = 8,   -- 1 rupee.
  [{ "rupee", 2 }]      = 6,   -- 5 rupees.
  [{ "rupee", 3 }]      = 4,   -- 20 rupees.
  [{ "heart", 1 }]      = 12,   -- Heart.
  [{ "bomb", 1}]        = 10,   -- Bomb.
  [{ "bomb", 2}]        = 8,  -- 3 Bombs.
  [{ "arrow", 1 }]      = 10,   --  Arrow.
  [{ "arrow", 2 }]      = 4,   --  5 Arrows.
  [{ "magic_flask", 1 }]      = 12,   --  Magic Flask.
}

function item:on_pickable_created(pickable)

  local treasure_name, treasure_variant = self:choose_random_item()
  if treasure_name ~= nil then
    local map = pickable:get_map()
    local x, y, layer = pickable:get_position()
    map:create_pickable{
      layer = layer,
      x = x,
      y = y,
      treasure_name = treasure_name,
      treasure_variant = treasure_variant,
    }
  end
  pickable:remove()
end

-- Returns an item name and variant.
function item:choose_random_item()

  local random = math.random(200)
  local sum = 0

  for key, probability in pairs(probabilities) do
    sum = sum + probability
    if random < sum then
      return key[1], key[2]
    end
  end

  return nil
end