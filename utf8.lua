-- pakkio November 2011
-- it might be useful in many cases
-- parse the input escaped strings \u is treated as if it was \0x

-- convert a number to equivalent utf8 string_char
-- for instance utf8(2000) ==> "ߐ"
-- this is one if not the fastest according to https://stackoverflow.com/a/26237757
local function utf8(codep)
  -- if ascii number then just do string.char
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

local char_to_hex = function(c)
  return string.format("%%%02X", string.byte(c))
end
function urlencode(url)
  if url == nil then
    return
  end
  --url = url:gsub("\n", "\r\n")
  url = string.gsub(url,"([^%w ])", char_to_hex)
  url = url:gsub(" ", "+")
  return url
end

function getUtf8(text)
	local texts = string.gsub(text, "\\u", "\\0x")
	local out, n = string.gsub(texts,"\\0x(%x%x%x%x)",
		function(w) 
		  local number = tonumber(w,16)
			--print("w="..number)
			return utf8(number) 
		end
	)
	return out
end


--print(getUtf8([[A narancs vagy \u00e9des narancs (Citrus sinensis), n\u00e9pies neve auranci, or\u00e1nzs d\u00e9ligy\u00fcm\u00f6lcs a citrusform\u00e1k alcsal\u00e1dj\u00e1b\u00f3l. Nem azonos a keser\u0171 naranccsal (Citrus \u00d7 aurantium), ami a pomelo (Citrus maxima) \u00e9s a mandarin (Citrus reticulata) hibridje. A VIII. Magyar Gy\u00f3gyszerk\u00f6nyvben a keser\u0171 narancs drogjai a Citrus aurantium subsp. aurantium (syn. C. aurantium subsp. amara) n\u00e9vhez kapcsol\u00f3d\u00f3an szerepelnek, m\u00edg a Citrus sinensis (syn. Citrus aurantium var. dulcis) \u00e9des narancs n\u00e9ven van megk\u00fcl\u00f6nb\u00f6ztetve. Az \u00e9des narancsnak a gy\u00f3gyszerk\u00f6nyvben egy drogja, az ill\u00f3olaja szerepel Aurantii dulcis aetheroleum n\u00e9ven.A narancsbogy\u00f3 k\u00fcls\u0151 r\u00e9teg\u00e9t, a jellegzetes s\u00e1rga sz\u00edn\u0171 h\u00e9j\u00e1t a kereskedelemben \u2013 sz\u00edne alapj\u00e1n \u2013 \u201eflaved\u00f3\u201d-nak nevezik. A k\u00fcls\u0151 h\u00e9j (Aurantii cortex) ill\u00f3olajat, keser\u0171anyagot, karotinoidot \u00e9s narancssavat tartalmaz, k\u00f6zkedvelt arom\u00e1j\u00fa \u00edzes\u00edt\u0151 f\u0171szert k\u00e9sz\u00edtenek bel\u0151le. A h\u00e9j bels\u0151bb, feh\u00e9r r\u00e9tege tapl\u00f3szer\u0171, melyet \u201ealbed\u00f3\u201d-nak neveznek. A bogy\u00f3 belseje s\u00e1rga \u00e9s l\u00e9d\u00fas. Az \u00e9rett gy\u00fcm\u00f6lcs\u00f6k magjai b\u00e1rmikor elvethet\u0151k.]]))
