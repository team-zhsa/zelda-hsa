local light_mgr = {occluders={},lights={},occ_maps = {},occ_chunks={}}

light_mgr.light_acc = sol.surface.create(sol.video.get_quest_size())
light_mgr.light_acc:set_blend_mode('multiply')

local make_shadow_s = sol.shader.create("make_shadow1d")
local cast_shadow_s = sol.shader.create("cast_shadow1d")

local fire_dist = sol.shader.create('fire_dist')

local angular_resolution = 256
local shadow_map = sol.surface.create(angular_resolution,1)
shadow_map:set_blend_mode("add")
shadow_map:set_shader(cast_shadow_s)
local chunk_size = 512

function light_mgr:add_occluder(occ,sprite)
  self.occluders[occ]=sprite or occ:get_sprite()
end

function light_mgr:add_light(light,name)
  self.lights[name or light] = light
end

function light_mgr:get_fire_shader()
  return fire_dist
end

local blocking_grounds = {
  wall = true
}

function light_mgr:chunk_id(chunk_x,chunk_y,layer)
  return chunk_x +
    chunk_y*self.chunk_width +
    (layer-self.map:get_min_layer())*self.chunk_width*self.chunk_height
end

function light_mgr:get_occ_chunk(chunk_x,chunk_y,layer)
  --don't recompute map_occluder for the same layer
  local cid = self:chunk_id(chunk_x,chunk_y,layer)
  local chunk = self.occ_chunks[cid]
  if not chunk then
    --create chunk as it doesn't exist
    chunk = {surf=sol.surface.create(chunk_size,chunk_size),valid=false}
    self.occ_chunks[cid] = chunk
  end
  if chunk.valid then
    -- chunk is still valid, return it as is
    return chunk.surf
  end
  --chunk is invalid, update it!
  --print(string.format("computing chunk at (%d,%d,%d)",chunk_x,chunk_y,layer))
  local map = self.map
  local cx,cy = chunk_x*chunk_size,chunk_y*chunk_size
  local l = layer
  local dx,dy = cx % 8, cy % 8
  local w,h = chunk_size, chunk_size
  local color = {0,0,0,255}
  chunk.surf:clear()
  for x=0,w,8 do
    for y=0,h,8 do
      local ground = map:get_ground(cx+x,cy+y,l)
      if blocking_grounds[ground] then
        chunk.surf:fill_color(color,x-dx,y-dy,8,8)
      end
    end
  end
  chunk.valid = true
  return chunk.surf
end

function light_mgr:invalidate_occ_chunks()
  for k,chunk in pairs(self.occ_chunks) do
    chunk.valid = false
  end
end

function light_mgr:get_occ_map(radius)
  if not self.occ_maps[radius] then
    self.occ_maps[radius] = sol.surface.create(radius*2,radius*2)
    self.occ_maps[radius]:set_shader(make_shadow_s)
  end
  return self.occ_maps[radius]
end

function light_mgr:compute_light_shadow_map(light)
  local radius = light.radius
  local occ_map = self:get_occ_map(radius)

  local size = radius*2

  --setup shaders for this light
  local resolution = {radius,radius}
  make_shadow_s:set_uniform("resolution",resolution)
  shadow_map:set_scale(size/angular_resolution,size)
  cast_shadow_s:set_uniform("resolution",resolution)
  cast_shadow_s:set_uniform("lcolor",light.color)
  cast_shadow_s:set_uniform("dir",light.direction or {1,0})
  cast_shadow_s:set_uniform("aperture",light.aperture or -1.5)
  cast_shadow_s:set_uniform("halo",light.halo or 0.2)
  cast_shadow_s:set_uniform("cut",light.cut or 0.0)

  --get light geometry
  local lx,ly,ll = light:get_topleft()

  --compute overlapped chunks
  local cxmin = math.floor(lx/chunk_size)
  local cymin = math.floor(ly/chunk_size)

  local cxmax = math.floor((lx+size)/chunk_size)
  local cymax = math.floor((ly+size)/chunk_size)


  occ_map:clear()

  --draw occlusion chunks on the light occlusion map
  for cx = cxmin,cxmax do
    for cy = cymin,cymax do
      local chunk = self:get_occ_chunk(cx,cy,ll)
      local cxx = cx*chunk_size
      local cyy = cy*chunk_size
      local rx,ry = cxx-lx,cyy-ly
      chunk:draw(occ_map,rx,ry)
    end
  end

  --draw non-static occluders on this light
  for ent,occ in pairs(self.occluders) do
    if not light.excluded_occs[ent] and ent:is_enabled() then
      local ex,ey = ent:get_position()
      local x,y = ex-lx,ey-ly
      occ:draw(occ_map,x,y)
    end
    if not ent:exists() then
      self.occluders[ent] = nil
    end
  end


  occ_map:draw(shadow_map)
  return shadow_map
end

local function table_filter(table, pred)
  local res = {}
  for k,v in pairs(table) do
    if pred(k,v) then res[k] = v; print(v) end
  end
  return res
end

function light_mgr:init(map,ambient)
  self.ambient = ambient
  self.occluders = table_filter(self.occluders,
    function(k,v) return k:get_map() == map end)
  self.lights = table_filter(self.lights,
    function(k,v) return v:get_map() == map end)

  --init occlusion chunks cache
  local mw, mh = map:get_size()
  self.occ_chunks = {}
  self.chunk_width = math.ceil(mw / chunk_size)
  self.chunk_height = math.ceil(mh / chunk_size)
  self.map = map

end

local inv_count = 0

function light_mgr:draw(dst,map)
  if inv_count % 50 == 0 then
    self:invalidate_occ_chunks()
  end
  inv_count = inv_count + 1
  self.light_acc:fill_color(self.ambient or {25,25,25,255})
  local camera = map:get_camera()
  for n,l in pairs(self.lights) do
    l:draw_light(self.light_acc,camera)
  end
  self.map_occluder_layer = nil
  self.light_acc:draw(dst,0,0)
  --self.map_occ:draw(dst,0,0)
end

return light_mgr
