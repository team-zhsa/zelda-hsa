-- Sets up all non built-in gameplay features specific to this quest.

-- Usage: require("scripts/features")

-- Features can be enabled to disabled independently by commenting
-- or uncommenting lines below.

require("scripts/debug")
require("scripts/chronometer")
require("scripts/equipment")
require("scripts/dungeons")
require("scripts/hero_condition")
require("scripts/coroutine_helper")
require("scripts/hud/hud")
require("scripts/maps/sidequest_manager")
require("scripts/maps/companion_manager")
require("scripts/maps/cinematic_manager")
require("scripts/maps/main_quest_manager")
require("scripts/maps/teletransporter_manager")
require("scripts/maps/ceiling_drop_manager")
require("scripts/maps/daytime_manager")
require("scripts/maps/field_music_manager")
require("scripts/menus/dialog_box")
require("scripts/menus/pause/pause.lua")
require("scripts/menus/map/map.lua")
require("scripts/menus/game_over")
require("scripts/menus/version_check")
require("scripts/meta/dynamic_tile")
require("scripts/meta/camera")
require("scripts/meta/carried_object")
require("scripts/meta/block")
require("scripts/meta/destructible")
require("scripts/meta/door")
require("scripts/meta/enemy")
require("scripts/meta/hero")
require("scripts/meta/map")
require("scripts/meta/npc")
require("scripts/meta/sensor")
require("scripts/meta/switch")
require("scripts/meta/separator")
require("scripts/meta/teletransporter")
require("scripts/tools/iter.lua")() --adds iterlua to _G
require("scripts/tools/debug_utils")
require("scripts/weather/weather_manager")

return true