-- Defines the dungeon information of a game.

-- Usage:
-- require("scripts/dungeons")

require("scripts/multi_events")
local parchment = require("scripts/menus/parchment")

local function initialise_dungeon_features(game)

  if game.get_dungeon ~= nil then
    -- Already done.
    return
  end

  -- Define the existing dungeons and their floors for the minimap menu.
  local dungeons_info = {

    [1] = { -- North Ruins
      floor_width = 1600,
      floor_height = 1680,
			minimap_width = 40,
			minimap_height = 56,
      lowest_floor = -1,
      highest_floor = 0,
      maps = {
        "dungeons/1/0f",
				"dungeons/1/b1",
      },
      boss = {
        floor = -1,
				breed = "boss/tentacle_boss",
        savegame_variable = "dungeon_1_boss",
        x = 1120,
        y = 104,
      },
      main_entrance = {
        map_id = "dungeons/1/0f",
        destination_name = "from_outside"
      },
      main_exit = {
        map_id = "out/a1",
        destination_name = "from_dungeon"
      },
      completing_sequence = "simple", -- See Enemy manager script for more infos.
    },

    [2] = { -- Forest Temple
      floor_width = 1600,
      floor_height = 1680,
			minimap_width = 40,
			minimap_height = 56,
      lowest_floor = -3,
      highest_floor = 1,
      maps = {
        "dungeons/2/0f",
        "dungeons/2/1f",
        "dungeons/2/b1",
        "dungeons/2/b2",
        "dungeons/2/b3",
      },
      boss = {
        floor = 1,
        savegame_variable = "dungeon_2_boss",
        x = 800,
        y = 1080,
      },
      main_entrance = {
        map_id = "dungeons/2/0f",
        destination_name = "from_outside"
      },
      main_exit = {
        map_id = "out/b4",
        destination_name = "from_dungeon"
      },
      completing_sequence = "simple",
    },

    [3] = { -- Fire Temple
      floor_width = 1920,
      floor_height = 1440,
			minimap_width = 48,
			minimap_height = 48,
      lowest_floor = -4,
      highest_floor = 0,
      maps = {
        "dungeons/3/0f",
        "dungeons/3/b1",
        "dungeons/3/b2",
        "dungeons/3/b3",
        "dungeons/3/b4",
      },
      boss = {
        floor = -4,
        savegame_variable = "dungeon_3_boss",
        x = 1448,
        y = 320,
      },
      main_entrance = {
        map_id = "dungeons/3/0f",
        destination_name = "from_outside"
      },
      main_exit = {
        map_id = "out/b1",
        destination_name = "from_crater_3"
      },
      completing_sequence = "simple",
    },

    [5] = { -- Dodongo's Cavern
    floor_width = 1920,
    floor_height = 1440,
    minimap_width = 48,
    minimap_height = 48,
    lowest_floor = 0,
    highest_floor = 2,
    maps = {
      "dungeons/5/0f",
      "dungeons/5/1f",
      "dungeons/5/2f",
    },
    boss = {
      floor = 0,
      savegame_variable = "dungeon_5_boss",
      x = 1448,
      y = 320,
    },
    main_entrance = {
      map_id = "dungeons/5/0f",
      destination_name = "from_outside"
    },
    main_exit = {
      map_id = "out/f1",
      destination_name = "from_temple"
    },
    completing_sequence = "simple",
    },

    [6] = { -- Water Temple
    floor_width = 1920,
    floor_height = 1440,
    minimap_width = 48,
    minimap_height = 48,
    lowest_floor = -1,
    highest_floor = 0,
    maps = {
      "dungeons/6/0f",
      "dungeons/6/b1",
    },
    boss = {
      floor = -1,
      savegame_variable = "dungeon_6_boss",
      x = 1448,
      y = 320,
    },
    main_entrance = {
      map_id = "dungeons/6/0f",
      destination_name = "from_outside"
    },
    main_exit = {
      map_id = "out/b2",
      destination_name = "from_temple"
    },
    completing_sequence = "simple",
    },

    [7] = { -- Desert Temple
    floor_width = 1600,
    floor_height = 1200,
    minimap_width = 40,
    minimap_height = 40,
    lowest_floor = 0,
    highest_floor = 1,
    maps = {
      "dungeons/7/0f",
      "dungeons/7/1f",
    },
    boss = {
      floor = 1,
      savegame_variable = "dungeon_7_boss",
      x = 1448,
      y = 320,
    },
    main_entrance = {
      map_id = "dungeons/7/0f",
      destination_name = "from_outside"
    },
    main_exit = {
      map_id = "out/b5",
      destination_name = "from_dungeon"
    },
    completing_sequence = "simple",
    },

    [8] = { -- Jabu Jabu's Belly
    floor_width = 1920,
    floor_height = 1440,
    minimap_width = 48,
    minimap_height = 48,
    lowest_floor = -1,
    highest_floor = 0,
    maps = {
      "dungeons/8/0f",
      "dungeons/8/b1",
    },
    boss = {
      floor = -1,
      savegame_variable = "dungeon_8_boss",
      x = 1448,
      y = 320,
    },
    main_entrance = {
      map_id = "dungeons/8/0f",
      destination_name = "from_outside"
    },
    main_exit = {
      map_id = "out/l1",
      destination_name = "from_dungeon"
    },
    completing_sequence = "simple",
    },

    [9] = { -- Caesar's Peak
    floor_width = 1280,
    floor_height = 960,
    minimap_width = 32,
    minimap_height = 32,
    lowest_floor = 0,
    highest_floor = 5,
    maps = {
      "dungeons/9/0f",
      "dungeons/9/1f",
      "dungeons/9/2f",
      "dungeons/9/3f",
      "dungeons/9/4f",
      "dungeons/9/5f",
    },
    boss = {
      floor = 1,
      savegame_variable = "dungeon_9_boss",
      x = 1448,
      y = 320,
    },
    main_entrance = {
      map_id = "dungeons/9/0f",
      destination_name = "from_outside"
    },
    main_exit = {
      map_id = "out/g1",
      destination_name = "from_dungeon"
    },
    completing_sequence = "simple",
    },

    [11] = { -- Ice Temple
    floor_width = 1600,
    floor_height = 1200,
    minimap_width = 40,
    minimap_height = 40,
    lowest_floor = -1,
    highest_floor = 0,
    maps = {
      "dungeons/11/0f",
      "dungeons/11/b1",
    },
    boss = {
      floor = 0,
      savegame_variable = "dungeon_11_boss",
      x = 1448,
      y = 320,
    },
    main_entrance = {
      map_id = "dungeons/11/0f",
      destination_name = "from_outside"
    },
    main_exit = {
      map_id = "out/i1",
      destination_name = "from_temple"
    },
    completing_sequence = "simple",
    },
    
    [13] = { -- Cavern
    floor_width = 1280,
    floor_height = 960,
    minimap_width = 32,
    minimap_height = 32,
    lowest_floor = 0,
    highest_floor = 0,
    maps = {
      "dungeons/13/0f",
    },
    boss = {
      floor = 0,
      savegame_variable = "dungeon_13_boss",
      x = 1448,
      y = 320,
    },
    main_entrance = {
      map_id = "dungeons/13/0f",
      destination_name = "from_outside"
    },
    main_exit = {
      map_id = "out/i3",
      destination_name = "from_dungeon"
    },
    completing_sequence = "simple",
    },
        
    [14] = { -- Kakarico Well
    floor_width = 1600,
    floor_height = 1680,
    minimap_width = 40,
    minimap_height = 56,
    lowest_floor = -2,
    highest_floor = 0,
    maps = {
      "dungeons/14/0f",
      "dungeons/14/b1",
      "dungeons/14/b2",
    },
    boss = {
      floor = 0,
      savegame_variable = "dungeon_14_boss",
      x = 1448,
      y = 320,
    },
    main_entrance = {
      map_id = "dungeons/14/0f",
      destination_name = "from_outside"
    },
    main_exit = {
      map_id = "out/a3",
      destination_name = "from_dungeon"
    },
    completing_sequence = "simple",
    },
            
    [16] = { -- Hyrule Castle
    floor_width = 640,
    floor_height = 640,
    minimap_width = 16,
    minimap_height = 16,
    lowest_floor = 2,
    highest_floor = 4,
    maps = {
      "dungeons/16/2f",
      "dungeons/16/3f",
      "dungeons/16/4f",
    },
    boss = {
      floor = 4,
      savegame_variable = "dungeon_16_boss",
      x = 1448,
      y = 320,
    },
    main_entrance = {
      map_id = "dungeons/16/2f",
      destination_name = "from_outside"
    },
    main_exit = {
      map_id = "out/f4",
      destination_name = "from_tower"
    },
    completing_sequence = "simple",
    },
  }

  -- Returns the index of the current dungeon if any, or nil.
  function game:get_dungeon_index()

    local world = game:get_map():get_world()
    if world == nil then
      return nil
    end
    local index = tonumber(world:match("^dungeon_([0-9]+)$"))
    return index
  end

  -- Returns the current dungeon if any, or nil.
  function game:get_dungeon()

    local index = game:get_dungeon_index()
    return dungeons_info[index]
  end

  function game:is_dungeon_finished(dungeon_index)
    return game:get_value("dungeon_" .. dungeon_index .. "_finished")
  end

  function game:set_dungeon_finished(dungeon_index, finished)
    if finished == nil then
      finished = true
    end
    game:set_value("dungeon_" .. dungeon_index .. "_finished", finished)
  end

  function game:has_dungeon_map(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_map")
  end

  function game:has_dungeon_compass(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_compass")
  end

  function game:has_dungeon_big_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_big_key")
  end

  function game:has_dungeon_green_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_green_key")
  end

  function game:has_dungeon_red_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_red_key")
  end

  function game:has_dungeon_blue_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_blue_key")
  end

  function game:has_dungeon_silver_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_silver_key")
  end

  function game:has_dungeon_boss_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_boss_key")
  end

  -- Returns the name of the boolean variable that stores the exploration
  -- of dungeon room, or nil.
  function game:get_explored_dungeon_room_variable(dungeon_index, floor, room)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    room = room or 1

    if floor == nil then
      if game:get_map() ~= nil then
        floor = game:get_map():get_floor()
      else
        floor = 0
      end
    end

    local room_name
    if floor >= 0 then
      room_name = tostring(floor) .. "f_" .. room
    else
      room_name = "b" .. math.abs(floor) .. "_" .. room
    end

    return "dungeon_" .. dungeon_index .. "_explored_" .. room_name
  end

  -- Returns whether a dungeon room has been explored.
  function game:has_explored_dungeon_room(dungeon_index, floor, room)

    return self:get_value(
      self:get_explored_dungeon_room_variable(dungeon_index, floor, room)
    )
  end

  -- Changes the exploration state of a dungeon room.
  function game:set_explored_dungeon_room(dungeon_index, floor, room, explored)

    if explored == nil then
      explored = true
    end

    self:set_value(
      self:get_explored_dungeon_room_variable(dungeon_index, floor, room),
      explored
    )
  end

   -- Show the dungeon name when entering a dungeon.
  game:register_event("on_world_changed", function()

      local map = game:get_map()
      local dungeon_index = game:get_dungeon_index()

      if dungeon_index ~= nil then

        function map.do_after_transition()
          game:set_suspended(true)
          local timer = sol.timer.start(map, 10, function()
            -- Show parchment with dungeon name.
            local line_1 = sol.language.get_string("map.dungeons.dungeon_" .. dungeon_index .. "_name")
            local line_2 = sol.language.get_dialog("maps.dungeons." .. dungeon_index .. ".welcome_description").text
            parchment:show(map, "default", "center", 1500, line_1, line_2, nil, function()
              game:set_suspended(false)
            end)
          end)
          timer:set_suspended_with_map(false)
        end

      end
    end)

end

-- Set up dungeon features on any game that starts.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialise_dungeon_features)

return true
