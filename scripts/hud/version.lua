-- Functions

function map:set_overlay()

  map.overlay = sol.surface.create("hud/version_text.png")
  map.overlay:set_opacity(255)

end

-- Events

function game:on_started()
  map:set_overlay()
end
