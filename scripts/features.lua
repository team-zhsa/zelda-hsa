-- Sets up all non built-in gameplay features specific to this quest.

-- Usage: require("scripts/features")

-- Features can be enabled to disabled independently by commenting
-- or uncommenting lines below.

require("scripts/debug")
require("scripts/equipment")
require("scripts/dungeons")
require("scripts/menus/dialog_box")
require("scripts/menus/pause")
require("scripts/menus/game_over")
require("scripts/hud/hud")
require("scripts/meta/dynamic_tile")
require("scripts/meta/camera")
require("scripts/meta/enemy")
require("scripts/meta/hero")
require("scripts/meta/npc")
require("scripts/meta/sensor")
require("scripts/maps/light_manager")
require("scripts/weather/weather_manager")
require("scripts/weather/rain_manager")
require("scripts/maps/light_manager")
require("scripts/maps/unstable_floor_manager")
require("scripts/maps/companion_manager")
require("scripts/maps/teletransporter_manager")
require("scripts/maps/cinematic_manager")
require("scripts/maps/ceiling_drop_manager")
require("scripts/coroutine_helper")
require("scripts/lib/iter.lua")() --adds iterlua to _G
require("scripts/tools/debug_utils")

return true
