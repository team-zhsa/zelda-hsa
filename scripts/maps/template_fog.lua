-- For use in a map script!!
local fog = sol.surface.create("fogs/desert_fog.png") -- Fog image

function map:on_draw(dst_surface)
	fog:draw(dst_surface)
	fog:set_opacity(120) -- Feel free to change that value, default 255
end