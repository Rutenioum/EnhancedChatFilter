-- Lua 5.1 syntax check; file paths are supplied by the caller.
local count = 0
for _, path in ipairs(arg) do
 local f = assert(io.open(path, 'rb'))
 local source = f:read('*a'); f:close()
 assert(loadstring((source:gsub('^\239\187\191', '')), '@'..path))
 count = count + 1
end
print('Syntax OK: '..count..' Lua files')
