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


--require("mobdebug").start()
dofile(MOD_PATH.."/basic.lua")
dofile(MOD_PATH.."/utf8.lua")


--
-- local environment is held for each position
--


--
-- globals for this mod for handling general constants
--
local vikidia = {
  nodeEnvs = {},
  formname = "vikidia.prova",
  --site = "it.vikidia.org",
  site = 'it.wikipedia.org',
  composeUrl = "https://${site}/w/api.php?format=json&action=query&prop=extracts"..
  "&exintro&explaintext&redirects=1&titles=${title}",
  -- if you want to change form better to ask help at this page for single fields
  -- use https://luk3yx.gitlab.io/minetest-formspec-editor/ for changing formspec
  composeFormspec = [[
    formspec_version[4]
    size[10.5,12]
    button_exit[7.5,0.1;3,1;exit;Exit]
    button[6.7,2.5;3,1.1;;Search]
    field[1.4,2.6;5,0.8;search;search;${search}]
    textarea[0.9,4.5;9,5.9;;;${desc}]
    textarea[0.5,10.9;9.8,0.9;position;                                                POS;${position}]
    ]],
  api = http_api,

}


-- whenever a form with our name is filled by a player

minetest.register_on_player_receive_fields(function(player, formname, fields)
  -- be sure to check this is really our formname to not pollute and receive others
  if formname ~= vikidia.formname then
    return false
  end
  local nodepos = fields.position
  -- if exit button just exits
  if fields.exit then
    minetest.log("form quit")
    return false
  end

  -- try to persist the searches and description made by the same player
  -- this can be changed to persist this information on the position instead of
  -- the player
  local player_name = player:get_player_name()
  
  local key = fields.position
  if not key then 
    return
  end
  local env = vikidia.nodeEnvs[key];
  if not env then
    env={}
    vikidia.nodeEnvs[key]=env
  end

  -- compose the formspec with search and previous fetched information
  env.search = fields.search
  env.position = key

  local url = vikidia.composeUrl %
    { site = vikidia.site,
      title = urlencode(env.search)
    }

  -- when http finishes we must collect the data
  local function fetch_callback(result)
    if not result.completed then
      minetest.log("request still uncomplete")
      return
    end
    minetest.log("finished request")
    -- extract only what appears after extract
    local desc = result.data:match('.*extract":"(.*)"}}}}')
    -- only if some information extracted
    if(not desc) then
      desc = "Questa voce su Vikidia non esiste, prova a scriverla!"
    end
    -- be sure to replace newlines with separators
    -- and to interpret correctly json handling utf8
    env.desc = string.gsub(getUtf8(desc),"\\n"," ")

    -- show the search and what found in the form with scrolling bars if needed
    local formspec = vikidia.composeFormspec %
      {
        position = env.position,
        search = env.search,
        desc = minetest.formspec_escape(env.desc)
      }

    minetest.show_formspec(player_name, vikidia.formname, formspec)

  end

  -- this is the actual http call
  http_api.fetch({url = url, timeout = 10}, fetch_callback)


end)



minetest.register_node("vikidia:sign", {
  description = "cartello vikidia",
  inventory_image = "vikidia.png",
  tiles = {"vikidia.png"},
  is_ground_content = false,
  groups = {oddly_breakable_by_hand = 1},
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    local player_name = player:get_player_name()
    local key = minetest.pos_to_string(pos)
    local env = vikidia.nodeEnvs[key];
    if not env then
      env={}
      env.search = ""
      env.desc = ""
      env.position = key
      vikidia.nodeEnvs[key]=env
    end

    local formspec = vikidia.composeFormspec % {
      position = key,
      search = env.search,
      desc = minetest.formspec_escape(env.desc)
    }
    minetest.log(formspec)
    minetest.show_formspec(player_name, vikidia.formname, formspec)
  end

})
