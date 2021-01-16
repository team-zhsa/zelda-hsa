local lib={}

function lib.replace_char(pos, source, replacement, num_chars)
  num_chars=num_chars or 1
  return source:sub(1,pos-1)..replacement..source:sub(pos+num_chars)
end

function lib.split(source, delimiters, context)
  
  context=(context~=nil) and context or "<some operation>"
  --print("Splicing string for "..context)

  local elements = {}
  local pattern = '([^'..delimiters..']+)'
  string.gsub(source, pattern, function(value)
    elements[#elements + 1] = value
  end)
  return elements
end

return lib