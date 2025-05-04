--[[settings.lua
	version 1.0
	15 Mar 2020
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script reads and writes key/value pairs from the "settings.dat" file in the quest
	write directory, supporting the built-in values as well as custom user-defined values.
	Key names must contain only alpha-numeric or underscore characters, where the starting
	character must be a letter.
	
	NOTE: Do not call sol.main.load_settings() or sol.main.save_settings() when using this
	script. Use settings:load() or settings:save() instead.
	
	Usage:
	local settings = require("scripts/settings")
	settings:load() --equivalent to sol.main.load_settings()
	settings:save() --equivalent to sol.main.save_settings()
	settings:get_value(key) --get a saved settings value (or nil if does not exist)
	settings:set_value(key, value) --set a saved settings value
--]]

local settings = {}

local FILE_NAME = "settings.dat" --name to use for settings file

--functions to read the built-in settings current values
local BUILT_IN_READ = {
	--video_mode = sol.video.get_mode,
	fullscreen = sol.video.is_fullscreen,
	sound_volume = sol.audio.get_sound_volume,
	music_volume = sol.audio.get_music_volume,
	language = sol.language.get_language,
	joypad_enabled = sol.input.is_joypad_enabled,
}

--functions to write the built-in settings current values (pass current value as first argument)
local BUILT_IN_WRITE = {
	--video_mode = sol.video.set_mode,
	fullscreen = sol.video.set_fullscreen,
	sound_volume = sol.audio.set_sound_volume,
	music_volume = sol.audio.set_music_volume,
	language = sol.language.set_language,
	joypad_enabled = sol.input.set_joypad_enabled,
}

--initial settings when creating new settings.dat file
local INITIAL_SETTINGS = {
	--video_mode = "normal",
	fullscreen = true,
	sound_volume = 100,
	music_volume = 100,
	language = nil,
	joypad_enabled = true,
}

local data = {} --store settings values in memory until file is written

local ALLOWED_TYPES = {"boolean", "number", "string", "nil"} --only these types are valid value types in saved settings values
for _,allowed_type in ipairs(ALLOWED_TYPES) do ALLOWED_TYPES[allowed_type]=true end --reverse lookup

--// Checks whether string name is valid, beginning with a letter and contains only alpha-numeric/underscore characters
local function is_valid_name(name)
	assert(type(name)=="string", "Bad argument #1 to 'is_valid_name' (string expected)")
	return not not name:match"^%a[%w_]*$"
end

--// Loads settings values from file into memory (creates new file if does not exist)
	--call one time initially in main.lua, behaves similarly to sol.main.load_settings()
function settings:load()
	data = {} --clear any existing data
	
	if sol.file.exists(FILE_NAME) then
		local env = setmetatable({}, {__newindex = function(self, key, value)
			data[key] = value
		end})
		
		local chunk = sol.main.load_file(FILE_NAME)
		setfenv(chunk, env)
		chunk()
	else
		for k,v in pairs(INITIAL_SETTINGS) do
      data[k]=v
    end --copy initial settings

  	--apply initial settings
  	for key,func in pairs(BUILT_IN_WRITE) do
  		local value = data[key]
  		if value ~= nil then func(value) end
  	end
		self:save() --write file with initial values
	end

	--apply built-in settings
	for key,func in pairs(BUILT_IN_WRITE) do
		local value = data[key]
		if value ~= nil then func(value) end
	end
end

--// Writes settings values from memory to file, overwriting existing file
	--call before program exits, behaves similarly to sol.main.save_settings()
function settings:save()
	for key,func in pairs(BUILT_IN_READ) do
    data[key] = func()
  end --update current values of built-in variables
	
	local file = sol.file.open(FILE_NAME, "w")
	
	for key,value in pairs(data) do
		if type(value)=="string" then
			value = string.format("%q", value) --add quotes and escape characters to string
		else value = tostring(value) end
		
		file:write(string.format("%s = %s\n", key, value))
	end
	
	file:flush()
	file:close()
end

--// Returns a saved settings value (excluding built-in values, use API instead to access value)
	--key (string) - Name of the settings value to retrieve
	--returns (string, number or boolean) - The corresponding value (nil if no value is defined with this key)
function settings:get_value(key)
	assert(is_valid_name(key), "Bad argument #1 to 'get_value' (string must contain only alpha-numeric or underscore characters and must begin with a letter)")
	return data[key]
end

--// Saves a settings value (key/value pair)
	--key (string) - Name of the value to save (must contain alphanumeric characters or '_' only, and must start with a letter)
	--value (string, number or boolean) - The value to set, or nil to unset this value
	--NOTE: This method changes a value in memory, but settings:save() must be called to write it to the settings file
function settings:set_value(key, value)
	assert(is_valid_name(key), "Bad argument #1 to 'set_value' (string must contain only alpha-numeric or underscore characters and must begin with a letter)")
	assert(not BUILT_IN_READ[key], "Bad argument #1 to 'set_value' ("..key.." is a built-in variable name that cannot be used)")
	assert(ALLOWED_TYPES[type(value)], "Bad argument #2 to 'set_value' (expected "..table.concat(ALLOWED_TYPES, ", ")..")")
	
	data[key] = value
end

return settings

--[[ Copyright 2020 Llamazing
  []
  [] This program is free software: you can redistribute it and/or modify it under the
  [] terms of the GNU General Public License as published by the Free Software Foundation,
  [] either version 3 of the License, or (at your option) any later version.
  []
  [] It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  [] without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  [] PURPOSE.  See the GNU General Public License for more details.
  []
  [] You should have received a copy of the GNU General Public License along with this
  [] program.  If not, see <http://www.gnu.org/licenses/>.
  ]]
