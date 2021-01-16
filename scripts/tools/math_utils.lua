--Math utility functions


local math_utils={}
function math_utils.get_offset_from_direction4(direction)
    local offsets={{1,0},{0,-1},{-1,0},{0,1}}
    return offsets[direction+1]
end
function math_utils.get_offset_from_direction(direction)
  
end

return math_utils
