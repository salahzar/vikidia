MOD_NAME = minetest.get_current_modname();
MOD_PATH = minetest.get_modpath(MOD_NAME);
--require("debugger")("127.0.0.1", 10000,"luaidekey")
local http_api = minetest.request_http_api and minetest.request_http_api()
if not http_api then
  minetest.log("MOD ${mod}: ERROR You must provide http right to this mod to work" % {mod = MOD_NAME})
  minetest.log("===================================================================")
  return false
end
dofile(MOD_PATH.."/basic.lua")
dofile(MOD_PATH.."/utf8.lua")

local vikidia = {
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
    textarea[0.5,10.9;9.8,0.9;position;;${position}]
    ]],
  api = http_api,
}

local function callWikipedia(search)
  local url = vikidia.composeUrl %
    { site = vikidia.site,
      title = urlencode(search)
    }
  local handle = vikidia.api.fetch_async({url = url, timeout = 10})
  local result
  repeat
    result = vikidia.api.fetch_async_get(handle)
  until (result.completed)

  -- extract only what appears after extract
  local desc = result.data:match('.*extract":"(.*)"}}}}')
  return string.gsub(getUtf8(desc),"\\n"," ")
end

local function getInfoText(position)
  local nodepos = minetest.string_to_pos(position)
  local meta = minetest.get_meta(nodepos)
  local desc = meta.get_string(meta,"infotext")
  return desc
end

local function setInfoText(position,value)
  local nodepos = minetest.string_to_pos(position)
  local meta = minetest.get_meta(nodepos)
  meta.set_string(meta,"infotext",value)
end

local function showForm(player_name,position,search,desc)
  -- show the search and what found in the form with scrolling bars if needed
  local formspec = vikidia.composeFormspec %
    {
      position = position,
      search = search,
      desc = minetest.formspec_escape(desc)
    }
  minetest.show_formspec(player_name, vikidia.formname, formspec)
end

minetest.register_node("vikidia:sign", {
  description = "cartello vikidia",
  inventory_image = "vikidia.png",
  tiles = {"vikidia.png"},
  is_ground_content = false,
  groups = {oddly_breakable_by_hand = 1},
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    local player_name = player:get_player_name()
    local position = minetest.pos_to_string(pos)
    local key = getInfoText(position)
    local desc = ""
    if not(key == "") then
        desc = callWikipedia(key)
    end
    showForm(player_name,position,key,desc)
  end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
  -- be sure to check this is really our formname to not pollute and receive others
  if formname ~= vikidia.formname then
    return false
  end
  -- if exit button just exits
  if fields.exit then
    minetest.log("form quit")
    return false
  end
  local position = fields.position
  local search = fields.search
  local desc = callWikipedia(search)
  if(not desc) then
    desc = "Questa voce su Vikidia non esiste, prova a scriverla!"
  else
    setInfoText(position,search)
  end
  local player_name=player:get_player_name()
  showForm(player_name,position,search,desc)
end)
