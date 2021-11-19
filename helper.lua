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






-- parse the input escaped strings \u is treated as if it was \0x
function sendForProcess(text)
	texts = string.gsub(text, "\\u", "\\0x")
	local allinput=half(texts,"\\")

	local toProcess = {}
	if allinput == nil then
		displayError(interface,"Please input some text!")
		return false
	else
		for i,line in ipairs(allinput) do
			local lineTemp = utf8(tonumber(line))
			table.insert(toProcess,lineTemp)
		end
		local finalOut = table.concat(toProcess)

		return finalOut
	end

end

-- split the input escaped strings
function half(inStr, inToken)
	if inStr == nil then
		return nil
	else
		local TableWord = {}
		local fToken = "(.-)" .. inToken
		local l_end = 1
		local w, t, halfPos = inStr:find(fToken, 1)
		while w do
			if w ~= 1 or halfPos ~= "" then
				table.insert(TableWord,halfPos)
			end
			l_end = t+1
			w, t, halfPos = inStr:find(fToken, l_end)
		end
		if l_end <= #inStr then
			halfPos = inStr:sub(l_end)
			table.insert(TableWord, halfPos)
		end
		return TableWord
	end
end

-- convert a number to equivalent utf8 string_char
function utf8(codep)
	if codep < 128 then
		return string.char(codep)
	end
	local s = ""
	local max_pf = 32
	while true do
		local suffix = codep % 64
		s = string.char(128 + suffix)..s
		codep = (codep - suffix) / 64
		if codep < max_pf then
			return string.char((256 - (2 * max_pf)) + codep)..s
		end
		max_pf = max_pf / 2
	end
end

