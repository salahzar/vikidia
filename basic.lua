-- Named Parameters in Table
-- http://lua-users.org/wiki/StringInterpolation 
-- string named interpolation "the name of {obj} is {value}" % {obj="object",value="value"}
minetest.log("Loading interp..")
function interp(s, tab)
  return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end
--print( interp("${name} is ${value}", {name = "foo", value = "bar"}) )
-- this substitute mod symbol with interp
getmetatable("").__mod = interp

-- this allows to do inspect(table) for showing easy
-- https://github.com/kikito/inspect.lua
-- needs inspect.lua on main directory
inspect = require('inspect') 

