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

minetest.log("loading vikidia table..")
local vikidia = {
  kind_vikidia = "vikidia",
  kind_wikipedia = "wikipedia",
  site_vikidia = 'it.vikidia.org',
  site_wikipedia = 'it.wikipedia.org',
  composeUrl = "http://alisl.org/proxy.php?name=${title}&site=${site}",
  -- if you want to change form better to ask help at this page for single fields
  -- use https://luk3yx.gitlab.io/minetest-formspec-editor/ for changing formspec
  composeFormspec = [[
      formspec_version[4]
      size[10.5,12]
      button_exit[0.5,2.8;3,1;exit;Esci]
      button[6.7,0.7;3,1.1;;Leggi la pagina!]
      field[0.6,0.9;5,0.8;search;Ricerca Voce ${site};${search}]
      textarea[0.9,4.5;9,5.9;;;${desc}]
      textarea[0.5,10.9;9.8,0.9;position;;${position}]
      field_close_on_enter[search;false]
    ]],
  api = http_api,
}

minetest.log("loading callWikipedia..")
local function callWikipedia(kind,search)
  minetest.log("Calling wikipedia")
  if search then
    local site
    if kind == vikidia.kind_vikidia then
      site = vikidia.site_vikidia
    else
      site = vikidia.site_wikipedia
    end
    minetest.log("calling "..site.." with "..search)

    local url = vikidia.composeUrl %
      { site = site,
        title = urlencode(search)
      }
    local handle = vikidia.api.fetch_async({url = url, timeout = 10})
    local result
    repeat
      result = vikidia.api.fetch_async_get(handle)
    until (result.completed)
    if(result.code~=200) then
      minetest.log("Not found")
      return false,""
    end
    minetest.log("Raw result :"..result.data)

    -- extract only what appears after extract
    local desc = result.data:match('.*extract":"(.*)"}}}}')
    local status
    status,desc = pcall(getUtf8,desc)
    if status then
      local desc1 = string.gsub(desc,"\\n"," ")
      minetest.log("Found "..desc1)
      return true,desc1
    else
      minetest.log("Error decoding "..desc)
      return false,""
    end
  else
    return false,""
  end
end
minetest.log("function getInfoText...")
local function getInfoText(position)
  local nodepos = minetest.string_to_pos(position)
  local meta = minetest.get_meta(nodepos)
  local desc = meta.get_string(meta,"infotext")
  return desc
end

minetest.log("function setInfoText...")
local function setInfoText(position,value)
  minetest.log("set info for pos "..position.." to "..value)
  local nodepos = minetest.string_to_pos(position)
  local meta = minetest.get_meta(nodepos)
  meta.set_string(meta,"infotext",value)
end

minetest.log("function showForm...")
local function showForm(kind,player_name,position,search,desc)
  local site
  if kind == vikidia.kind_vikidia then
    site = vikidia.site_vikidia
  else
    site = vikidia.site_wikipedia
  end
  -- show the search and what found in the form with scrolling bars if needed
  local formspec = vikidia.composeFormspec %
    {
      site = site,
      position = position,
      search = search,
      desc = minetest.formspec_escape(desc)
    }
  minetest.show_formspec(player_name, kind, formspec)
end

minetest.log("registering vikidia:sign...")
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
    local status
    
    if not(key == "") then
      status,desc = callWikipedia(vikidia.kind_vikidia,key)
    end
    showForm(vikidia.kind_vikidia,player_name,position,key,desc)
  end
})

minetest.log("registering vikidia:wikipedia...")
minetest.register_node("vikidia:wikipedia", {
  description = "cartello wikipedia",
  inventory_image = "wikipedia.jpg",
  tiles = {"wikipedia.jpg"},
  is_ground_content = false,
  groups = {oddly_breakable_by_hand = 1},
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    local player_name = player:get_player_name()
    local position = minetest.pos_to_string(pos)
    local key = getInfoText(position)
    local desc = ""
    local status
    if not(key == "") then
      status,desc = callWikipedia(vikidia.kind_wikipedia,key)
    end
    showForm(vikidia.kind_wikipedia,player_name,position,key,desc)
  end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
  -- be sure to check this is really our formname to not pollute and receive others
  if formname ~= vikidia.kind_vikidia and formname~=vikidia.kind_wikipedia then
    return false
  end
  -- if exit button just exits
  if fields.exit or fields.quit then
    minetest.log("form quit")
    return false
  end
  local position = fields.position
  local search = fields.search
  local status,desc = callWikipedia(formname,search)
  if(not status) then
    desc = "Questa voce su "..formname.." non esiste, prova a scriverla!"
  else
    pcall(setInfoText,position,search)
  end
  local player_name=player:get_player_name()
  showForm(formname, player_name,position,search,desc)
end)
