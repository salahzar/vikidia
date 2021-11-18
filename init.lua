
local MOD_NAME = minetest.get_current_modname();
local MOD_PATH = minetest.get_modpath(MOD_NAME);
local http_api = minetest.request_http_api and minetest.request_http_api()

inspect = require('inspect') 
-- should define a kind of object which when 'used present something'
-- 1st define object



minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "prova" then
		return false
	end
  
  local player_name = player:get_player_name()
  --minetest.close_formspec(player_name,"prova")
  minetest.log("called with fields\n"..inspect(fields))
  local vikidiasearch = fields.search
  local url = "https://it.vikidia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles="..vikidiasearch
  
  local function fetch_callback(result)
		if not result.completed then
			return
		end
		local desc = result.data:match('.*extract":"(.*)"}}}}')
		if(desc) then
			local desc = desc:gsub( "\\u00e8", "è")
			local formspec = 
			"formspec_version[4]size[10.5,11]button_exit[7.5,0.1;3,1;;Exit]button[6.7,2.5;3,1.1;;Ricerca Vikidia]field[1.4,2.6;5,0.8;search;search;"..vikidiasearch.."]textarea[0.9,4.5;9,5.9;;trovato;"..desc.."]"
		
		
			minetest.show_formspec(player_name, "prova", formspec)
		end
	end  

  http_api.fetch({url = url, timeout = receive_interval}, fetch_callback)  
    

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
     
     local formspec = 
		"formspec_version[4]size[10.5,11]button_exit[7.5,0.1;3,1;;Exit]button[6.7,2.5;3,1.1;;Ricerca Vikidia]field[1.4,2.6;5,0.8;search;search;]textarea[0.9,4.5;9,5.9;;trovato;]"
    -- table.concat is faster than string concatenation - `..`
	-- table.concat(formspec, "")
    
    minetest.show_formspec(player_name, "prova", formspec)
  end	

})
