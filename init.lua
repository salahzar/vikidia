MOD_NAME = minetest.get_current_modname();
MOD_PATH = minetest.get_modpath(MOD_NAME);
--require("debugger")("127.0.0.1", 10000,"luaidekey")
-- request http_api for being able to send httprequest
-- note you MUST give the http 
local http_api = minetest.request_http_api and minetest.request_http_api()
if not http_api then
	minetest.log("MOD ${mod}: ERROR You must provide http right to this mod to work" % {mod = MOD_NAME})
	minetest.log("===================================================================")
	return false
end
-- debugger for eclipse!

--require("mobdebug").start()
dofile(MOD_PATH.."/basic.lua")
dofile(MOD_PATH.."/utf8.lua")

--
-- globals for this mod
--
vikidia = {
	search = "",
	formname = "vikidia.prova",
	--site = "it.vikidia.org",
	site = 'hu.wikipedia.org',
	composeUrl = "https://${site}/w/api.php?format=json&action=query&prop=extracts"..
	"&exintro&explaintext&redirects=1&titles=${title}",
	composeFormspec = table.concat({
			"formspec_version[4]",
			"size[10.5,11]",
			"button_exit[7.5,0.1;3,1;exit;Exit]",
			"button[6.7,2.5;3,1.1;;Ricerca Vikidia]",
			"field[1.4,2.6;5,0.8;search;search;${search}]",
			"textarea[0.9,4.5;9,5.9;;trovato;${desc}]"},""),
	api = http_api,
	desc = "",

}



minetest.register_on_player_receive_fields(function(player, formname, fields)
		if formname ~= vikidia.formname then
			return false
		end
		if fields.exit then
			return false
		end

		local player_name = player:get_player_name()
		--minetest.close_formspec(player_name,"prova")
		--minetest.log("called with fields\n"..inspect(fields))
		local vikidiasearch = fields.search
		
		local url = vikidia.composeUrl % { site = vikidia.site, title = vikidiasearch }

		local function fetch_callback(result)
			if not result.completed then
				return
			end
			local desc = result.data:match('.*extract":"(.*)"}}}}')
			if(desc) then
				vikidia.desc = string.gsub(getUtf8(desc),"\\n"," ")
				local formspec = vikidia.composeFormspec % { search = vikidia.search, desc = vikidia.desc }

				minetest.show_formspec(player_name, vikidia.formname, formspec)
			end
		end  

		http_api.fetch({url = url, timeout = 10}, fetch_callback)  


	end)

-- use https://luk3yx.gitlab.io/minetest-formspec-editor/ for changing formspec

minetest.register_node("vikidia:sign", {
		description = "cartello vikidia",
		inventory_image = "vikidia.png",
		tiles = {"vikidia.png"},
		is_ground_content = false,
		groups = {oddly_breakable_by_hand = 1},
		on_rightclick = function(pos, node, player, itemstack, pointed_thing)
			local player_name = player:get_player_name()

			local formspec = vikidia.composeFormspec % { search = vikidia.search, desc = vikidia.desc }	
      minetest.log(formspec)
			minetest.show_formspec(player_name, vikidia.formname, formspec)
		end	

	})
