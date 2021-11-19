
-- parse the input escaped strings \u is treated as if it was \0x
function getUtf8(text)
	local texts = string.gsub(text, "\\u", "\\0x")
	out, n = string.gsub(texts,'\\0x(%w+)',function(w) return utf8(tonumber(w,16)) end)
	return out
end

-- convert a number to equivalent utf8 string_char
-- for instance utf8(2000) ==> "ߐ"
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


--print(getUtf8("la citt\\u00e0 \\u00e8 d'oro."))
