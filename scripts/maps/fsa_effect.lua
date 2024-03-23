local fsa = {}

local light_mgr = require("scripts/lights/light_manager")

local quest_w, quest_h = sol.video.get_quest_size()

local tmp = sol.surface.create(sol.video.get_quest_size())
local reflection = sol.surface.create(sol.video.get_quest_size())
local fsa_texture = sol.surface.create(sol.video.get_quest_size())

local half_screen_scale = 1 / 1
local half_screen = sol.surface.create(quest_w * half_screen_scale, quest_h * half_screen_scale)
half_screen:set_scale(1 / half_screen_scale, 1 / half_screen_scale)
half_screen:set_blend_mode("add")
local glow_acc = sol.surface.create(quest_w, quest_h)
glow_acc:set_blend_mode("add")

local blur_shader = sol.shader.create("blur")
local lava_filter = sol.shader.create("lava_filter")

half_screen:set_shader(blur_shader)

local distort_map = sol.surface.create(sol.video.get_quest_size())

local clouds = sol.surface.create("fogs/clouds_reflection.png")
local clouds_shadow = sol.surface.create("fogs/clouds_shadow.png")
clouds_shadow:set_opacity(120)
clouds_shadow:set_blend_mode("multiply")

local effect = sol.surface.create("fogs/fsa_background.png")
effect:set_blend_mode("blend")
local shader = sol.shader.create("water_effect")

shader:set_uniform("reflection", reflection)
shader:set_uniform("fsa_texture", fsa_texture)

local heat_wave = sol.shader.create("heat_wave")
local distort_shader = sol.shader.create("distort")

heat_wave:set_uniform("distort_factor", 1.0/64.0)
heat_wave:set_uniform("wave_factor", 0.3)
heat_wave:set_uniform("speed", 0.003)

distort_shader:set_uniform("distort_factor", {128.0 / quest_w, 128.0 / quest_h})

distort_map:set_shader(distort_shader)

tmp:set_shader(shader)
local ew,eh = effect:get_size()

local clouds_speed = 0.007;
local crw,crh = clouds:get_size()


-- render all needed reflection on reflection map
function fsa:render_reflection(map)
	reflection:clear()
	do
		local t = sol.main.get_elapsed_time() * clouds_speed;
		local x,y = t,t
		local cw,ch = reflection:get_size()
		local tx,ty = x % crw, y % crh
		if self.outside then
			for i=-1,math.ceil(cw/crw) do
				for j=-1,math.ceil(ch/crh) do    
					clouds:draw(reflection,tx+i*crw,ty+j*crh)
				end
			end
		else
			reflection:fill_color{128,128,128}
		end
	end
	
	local cx, cy = map:get_camera():get_position()
	local cw, ch = map:get_camera():get_size()
	
	-- draw an entity's reflection
	local function draw_entity_reflection(ent, sprite_name)
		
		local sprite = ent:get_sprite(sprite_name)
		if not sprite then return end
		
		local osx,osy = sprite:get_scale()
		sprite:set_scale(osx, -osy)
		local hx,hy = ent:get_position()
		
		local tx,ty = hx-cx, hy-cy + (ent.flying_height or 0)
		sprite:draw(reflection, tx, ty)
		sprite:set_scale(osx, osy)
	end
	
	
	local reflection_filter = {
		hero = {'tunic', 'sword', 'shield'}, -- TODO check why shield does not display
		enemy = true,
		npc = true
	}

	-- for each enemy in map
	for ent in map:get_entities_in_rectangle(cx, cy, cw, ch) do --TODO check if margins are necessary
		local filter = reflection_filter[ent:get_type()]
		if filter and not ent.dont_reflect then
			if type(filter) == 'table' then
				for _, name in ipairs(filter) do
					draw_entity_reflection(ent, name)
				end
			else
				draw_entity_reflection(ent)
			end
		end
	end
	
end

local csw,csh = clouds_shadow:get_size()

--draw cloud shadow
function fsa:draw_clouds_shadow(dst,cx,cy)
	local t = sol.main.get_elapsed_time() * clouds_speed;
	local x,y = math.floor(t),math.floor(t)
	local cw,ch = dst:get_size()
	local tx,ty = (-cx+x) % csw, (-cy+y) % csh
	local imax = math.ceil(cw/csw)
	local jmax = math.ceil(ch/csh)
	for i=-1,imax do
		for j=-1,jmax do
			clouds_shadow:draw(dst,tx+i*csw,ty+j*csh)
		end
	end
end

-- read map file again to get lights position
local function get_lights_from_map(map)
	local map_id = map:get_id()
	local lights = {}
	-- Here is the magic: set up a special environment to load map data files.
	local environment = {
	}

	local light_tile_ids = {
		["wall_torch.1"] = true,
		["wall_torch.2"] = true,
		["wall_torch.3"] = true,
		["wall_torch.4"] = true,
		["torch"] = true,
		["torch_big.top"] = true,
		["window.1-1"] = true,
		["window.2-1"] = true,
		["window.3-1"] = true,
		["window.4-1"] = true,
		["window.1-2"] = true,
		["window.2-2"] = true,
		["window.3-2"] = true,
		["window.4-2"] = true,
		["stain_glass.wide.1.top"] = true,
		["stain_glass.wide.2.top"] = true,
		["stain_glass.wide.3.top"] = true,
		["stain_glass.wide.4.top"] = true,
		["stain_glass.wide.1.bottom"] = true,
		["stain_glass.wide.2.bottom"] = true,
		["stain_glass.wide.3.bottom"] = true,
		["stain_glass.wide.4.bottom"] = true,
		["stain_glass.1.top"] = true,
		["stain_glass.2.top"] = true,
		["stain_glass.3.top"] = true,
		["stain_glass.4.top"] = true,
		["stain_glass.1.bottom"] = true,
		["stain_glass.2.bottom"] = true,
		["stain_glass.3.bottom"] = true,
		["stain_glass.4.bottom"] = true,
	}

	local big = "110"
	local small = "80"

	local radii = {
		["torch"] = small,
		["torch_big.top"] = small,
	}

	local win_cut = "0.1"
	local win_aperture = "0.707"

	local dirs = {
		["window.1-1"] = "0,1",
		["window.2-1"] = "0,-1",
		["window.3-1"] = "1,0",
		["window.4-1"] = "-1,0",
		["window.1-2"] = "0,1",
		["window.2-2"] = "0,-1",
		["window.3-2"] = "1,0",
		["window.4-2"] = "-1,0",
		["stain_glass.wide.1.top"] = "0,1",
		["stain_glass.wide.2.top"] = "0,-1",
		["stain_glass.wide.3.top"] = "1,0",
		["stain_glass.wide.4.top"] = "-1,0",
		["stain_glass.wide.1.bottom"] = "0,1",
		["stain_glass.wide.2.bottom"] = "0,-1",
		["stain_glass.wide.3.bottom"] = "1,0",
		["stain_glass.wide.4.bottom"] = "-1,0",
		["stain_glass.1.top"] = "0,1",
		["stain_glass.2.top"] = "0,-1",
		["stain_glass.3.top"] = "1,0",
		["stain_glass.4.top"] = "-1,0",
		["stain_glass.1.bottom"] = "0,1",
		["stain_glass.2.bottom"] = "0,-1",
		["stain_glass.3.bottom"] = "1,0",
		["stain_glass.4.bottom"] = "-1,0",
	}

	local win_col = "128,128,255"
	local colors = {
		["window.1-1"] = win_col,
		["window.2-1"] = win_col,
		["window.3-1"] = win_col,
		["window.4-1"] = win_col,
		["window.1-2"] = win_col,
		["window.2-2"] = win_col,
		["window.3-2"] = win_col,
		["window.4-2"] = win_col,
		["stain_glass.wide.1.top"] = win_col,
		["stain_glass.wide.2.top"] = win_col,
		["stain_glass.wide.3.top"] = win_col,
		["stain_glass.wide.4.top"] = win_col,
		["stain_glass.wide.1.bottom"] = win_col,
		["stain_glass.wide.2.bottom"] = win_col,
		["stain_glass.wide.3.bottom"] = win_col,
		["stain_glass.wide.4.bottom"] = win_col,
		["stain_glass.1.top"] = win_col,
		["stain_glass.2.top"] = win_col,
		["stain_glass.3.top"] = win_col,
		["stain_glass.4.top"] = win_col,
		["stain_glass.1.bottom"] = win_col,
		["stain_glass.2.bottom"] = win_col,
		["stain_glass.3.bottom"] = win_col,
		["stain_glass.4.bottom"] = win_col,
		
	}
	
	local distort_angle = {
		["wall_torch.1"] = 0,
		["wall_torch.2"] = math.pi,
		["wall_torch.3"] = math.pi*0.5,
		["wall_torch.4"] = math.pi*1.5,
		["torch"] = 0,
		["torch_big.top"] = 0,
	}

	function environment.tile(props)
		if light_tile_ids[props.pattern] then
			--tile is considered as a light
			table.insert(lights,
				{
					layer = props.layer,
					x = props.x + props.width*0.5,
					y = props.y + props.height*0.5,
					radius = radii[props.pattern] or big,
					dir = dirs[props.pattern],
					cut = dirs[props.pattern] and win_cut or "0",
					aperture = dirs[props.pattern] and win_aperture or "1.5",
					color = colors[props.pattern],
					distort_angle = distort_angle[props.pattern]
				}
			)
		end
	end

	-- Make any other function a no-op (tile(), enemy(), block(), etc.).
	setmetatable(environment, {
		__index = function()
			return function() end
		end
	})

	-- Load the map data file as Lua.
	local chunk = sol.main.load_file("maps/" .. map_id .. ".dat")

	-- Apply our special environment (with functions properties() and chest()).
	setfenv(chunk, environment)

	-- Run it.
	chunk()
	return lights
end

--render fsa texture to fsa effect map
function fsa:render_fsa_texture(map)
	fsa_texture:clear()
	if false and not self.outside then
		fsa_texture:fill_color{255,255,255}
		return
	end
	local cw,ch = fsa_texture:get_size()
	local camera = map:get_camera()
	local dx,dy = camera:get_position()
	local tx = ew - dx % ew
	local ty = eh - dy % eh
	for i=-1,math.ceil(cw/ew) do
		for j=-1,math.ceil(ch/eh) do
			effect:draw(fsa_texture,tx+i*ew,ty+j*eh)
		end
	end
end


-- create a light that will automagically register to the light_manager
local function create_light(map, x, y, layer, radius, color, dir, cut, aperture, distort_angle)
	local function dircutappprops()
		if dir and cut and aperture then
			return {key="direction",value=dir},
			{key="cut",value=cut},
			{key="aperture",value=aperture}
		end
	end
	return map:create_custom_entity{
		direction=0,
		layer = layer,
		x = x,
		y = y,
		width = 16,
		height = 16,
		sprite = "entities/fire_mask",
		model = "light",
		properties = {
			{key="radius",value = radius},
			{key="color",value = color},
			{key=distort_angle and "distort_angle" or "no_distort", value = tostring(distort_angle) or "0"}, -- TODO find better way
			dircutappprops()
		}
	}
end

local function setup_inside_lights(map)
	local house = map:get_id():match("^inside/houses/") ~= nil
	light_mgr:init(map,
		(function()
			if house then
				return {200,190,180}
			else
				return {105,100,95}
			end
		end)())
	light_mgr:add_occluder(map:get_hero())


	if not house then
		local hero = map:get_hero()
		--create hero light
		local hl = create_light(map,-64,-64,0,"80","196,128,200")
		function hl:on_update()
			if map:get_game():has_item("lamp") then
				hl:set_position(hero:get_position())
			end
		end
		hl.excluded_occs = {[hero]=true}
	end

	--add a static light for each torch pattern in the map
	local map_lights = get_lights_from_map(map)
	local default_radius = "160"            
	local default_color = "193,185,80"

	for _,l in ipairs(map_lights) do
		create_light(map,l.x,l.y,l.layer,l.radius or default_radius,l.color or default_color,
								 l.dir,l.cut,l.aperture,l.distort_angle)
	end


	--TODO add other non-satic occluders
	for en in map:get_entities_by_type("enemy") do
		light_mgr:add_occluder(en)
	end
	
	for en in map:get_entities_by_type("npc") do
		light_mgr:add_occluder(en)
	end

	--generate lights for dynamic torches
	for en in map:get_entities_by_type("custom_entity") do
		if en:get_model() == "torch" then
			local tx,ty,tl = en:get_position()
			local tw,th = en:get_size()
			local yoff = -8
			local light = create_light(map,tx+tw*0.5,ty+th*0.5+yoff,tl,default_radius,default_color)
			en:register_event("on_unlit",function()
				light:set_enabled(false)
			end)
			en:register_event("on_lit",function()
				  light:set_enabled(true)
			end)
			light:set_enabled(en:is_lit())
		end
	end
end

local water_grounds = {deep_water=true,shallow_water=true}
local col = {255,0,0}
local function water_predicate(ground)
	return water_grounds[ground], col
end

function fsa:on_map_changed(map)
	if self.current_map == map then
		return -- already registered and created
	end
	local outside = map:get_world() == "outside_world"
	if not outside then
		setup_inside_lights(map)
	end
	self.outside = outside
	self.current_map = map
	--self.water_mask_provider = chunk_provider.create(map, water_predicate)
end

function fsa:on_map_draw(map, dst)
	--dst:set_shader(shader)
	dst:draw(tmp)
	
	local old_shad = dst:get_shader()
	if map.fsa_lava then
		dst:set_shader(lava_filter)
		dst:set_scale(half_screen_scale, half_screen_scale)
		dst:draw(half_screen) -- downsample the screen
		dst:set_scale(1,1)
		dst:set_shader(old_shad)
	end
	
	fsa:render_reflection(map)
	fsa:render_fsa_texture(map)

	
	local camera = map:get_camera()
	local dx,dy = camera:get_position()
	local cw, ch = camera:get_size()
	local layer = map:get_hero():get_layer()
 

	tmp:set_shader(shader)
	tmp:draw(dst)
	if self.outside then
		if not map.fsa_no_clouds then
			fsa:draw_clouds_shadow(dst,dx,dy)
		end
	else
		light_mgr:draw(dst,map)
	end
	
	if map.fsa_lava then
		glow_acc:fill_color({0,0,0,10})
		half_screen:draw(glow_acc)
		glow_acc:draw(dst)
	end
	
	if true then
		-- draw heatwave on tmp
		if map.fsa_heat_wave then
			tmp:set_shader(heat_wave)
			heat_wave:set_uniform('camera_pos', {dx, dy})
			tmp:draw(distort_map)
		end
		
		for ent in map:get_entities_in_rectangle(dx, dy, cw, ch) do
			local dist_m = ent.on_draw_distort
			if dist_m then
				dist_m(ent, distort_map)
			end
		end
		
		-- copy dst on tmp
		dst:draw(tmp)
		
		distort_shader:set_uniform('diffuse', tmp)
		
		-- draw distorted tmp
		distort_map:draw(dst)
		
		-- clear distortion
		distort_map:fill_color({128,128,0,255})
	end
end

function fsa:clean()

end

return fsa
