
local MOD_NAME = minetest.get_current_modname();
local MOD_PATH = minetest.get_modpath(MOD_NAME);

-- should define a kind of object which when 'used present something'
-- 1st define object

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "prova" then
		return false
	end
  require("mobdebug").start()
  local player_name = player:get_player_name()
  minetest.close_formspec(player_name,"prova")
  minetest.log("called with fields\n"..inspect(fields))

end)

minetest.register_node("vikidia:sign", {
	description = "cartello vikidia",
  inventory_image = "vikidia.png",
  tiles = {"vikidia.png"},
  is_ground_content = false,
	groups = {oddly_breakable_by_hand = 1},
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    local player_name = player:get_player_name()
     local text = "Hello world how are you? Città"
     local formspec = {
        "formspec_version[4]",
        "size[6,5]",
        "label[0.375,0.5;", minetest.formspec_escape(text), "]",
        "textarea[0.375,1.25;5.25,3;number;Number;]",
        "button[1.5,4.3;3,0.8;exit;Guess]"
    }

    -- table.concat is faster than string concatenation - `..`
    
    minetest.show_formspec(player_name, "prova", table.concat(formspec, ""))
  end	

})
