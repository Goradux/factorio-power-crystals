local customModule = require("customModule")

customModule.sampleVariable = 2

script.on_init(function()
  global.generator = game.create_random_generator()
  global.chunks_with_crystals = {}
  ---@type boolean
  global.tag_crystals = settings.global["power-crystals-tag-new-crystals"].value
end
)

-- don't know if I want this
-- script.on_load(function()
--   global.tag_crystals = settings.global["power-crystals-tag-new-crystals"].value
-- end)

local function generate_crystal_tier()
  local roll = global.generator(0, 100) -- includes both ends

  local tier = 1
  if roll < 70 then     -- 70%
    tier = 1
  elseif roll < 95 then -- 25%
    tier = 2
  else
    tier = 3
  end
  return tier
end

---comment
---@param positive boolean
---@return string
local function generate_crystal_type(positive)
  local roll = global.generator(0, 2) -- includes both ends
  game.get_player("Goradux").print("The crystal type roll is: " .. roll)

  local tier
  if positive then
    if roll == 0 then     -- 1/3
      tier = "speed"
    elseif roll == 1 then -- 1/3
      tier = "productivity"
    else                  -- 1/3
      tier = "effectivity"
    end
  else
    -- game.print("This is supposed to be a purple crystal")
    -- tier = "speed"
    -- TODO: implement
    tier = "instability" -- the purple crystal
  end
  return tier
end

---comment
---@param surface LuaSurface
---@param spawn_location {x: number, y: number}
---@param force_name string
---@param tier integer
---@param positive boolean
local function generate_one_crystal(surface, spawn_location, force_name, tier, positive)
  -- local tier = generate_crystal_tier()
  local exact_type = generate_crystal_type(positive)
  local pc

  local name
  if positive == true then
    name = "base-power-crystal-" .. tier
  else
    name = "base-power-crystal-negative-" .. tier
  end

  pc = surface.create_entity {
    name = name,
    amount = 1,
    force = force_name,
    position = { spawn_location.x, spawn_location.y },
  }

  if pc then
    if tier == 1 then
      pc.insert { name = exact_type .. "-power-crystal-module", count = 1 }
    elseif tier == 2 then
      pc.insert { name = exact_type .. "-power-crystal-module", count = 2 }
    else
      pc.insert { name = exact_type .. "-power-crystal-module", count = 4 }
    end
  end

  local maskCrystal = surface.create_entity {
    name = "model-power-crystal-" .. exact_type .. "-" .. tier,
    amount = 1,
    force = force_name,
    position = { spawn_location.x, spawn_location.y },
  }

  return { tier = tier, type = exact_type }
end

-- ---comment
-- ---@param surface LuaSurface
-- ---@param location {x: number, y: number}
-- ---@param force_name string
-- local function generate_mask_crystal(surface, location, force_name)
--   ---@type LuaEntity?
--   local maskCrystal = surface.create_entity {
--     name = "mask-crystal",
--     amount = 1,
--     force = force_name,
--     position = { location.x, location.y },
--   }
-- end

-- on_player_joined_game
script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)

  if player ~= nil then
    player.cheat_mode = true
    game.print(tostring(player.name) .. " has joined the game!")

    generate_one_crystal(player.surface, { x = 50, y = 50 }, "player", 1, true)
  end
end
)

-- development only
script.on_event(defines.events.on_player_crafted_item, function(event)
  if event.item_stack.name == "wooden-chest" then
    game.reload_mods()
    game.print("MOD RELOADED")
  elseif event.item_stack.name == "iron-chest" then
    for _, f in pairs(game.forces) do game.print(f.name); end
  elseif event.item_stack.name == "transport-belt" then
    game.get_player("Goradux").force = "player"
  elseif event.item_stack.name == "burner-inserter" then
    game.print(game.get_player("Goradux").force.name)
    game.print(game.get_player("Goradux").surface.name)
    game.print("the number is: " .. tostring(global.generator(0, 2)))
  elseif event.item_stack.name == "small-electric-pole" then
    generate_one_crystal(game.get_player("Goradux").surface, { x = 50, y = 50 }, "player", 1, true)
  end
end
)


---comment
---@return boolean
local function to_generate_beacon()
  if global.generator(0, 24) == 0 then -- 1/25 chunks should contain a beacon
    return true
  end
  return false
end

---comment
---@return {tier: integer, positive: boolean?}
local function to_generate_beacon_v2()
  local roll = global.generator(1, 100)
  if roll == 1 then -- 1/25 chunks should contain a beacon
    return { tier = 3, positive = true }
  elseif roll >= 2 and roll <= 3 then
    return { tier = 2, positive = true }
  elseif roll >= 4 and roll <= 7 then
    return { tier = 1, positive = true }
  elseif roll >= 8 and roll <= 9 then
    return { tier = 2, positive = false }
  elseif roll >= 10 and roll <= 13 then
    return { tier = 1, positive = false }
  end
  return { tier = 0 } -- no generation
end

-- ---comment
-- ---@param surface LuaSurface
-- ---@param placement_position MapPosition
-- ---@return boolean
-- local function allowed_placement(surface, placement_position)
--   local pp = placement_position
--   local other_entities = surface.find_entities({ { pp.x - 1, pp.y - 1 }, { pp.x + 1, pp.y + 1 } })
--   if #other_entities > 0 then
--     return false
--   end
--   return true
-- end

script.on_event(defines.events.on_chunk_generated, function(event)
  -- event.area example: {{-2, -3}, {5, 8}} short or {left_top = {x = -2, y = -3}, right_bottom = {x = 5, y = 8}} long
  -- event.position also x and y, but must be multiplied by 32 to get map location


  local to_generate = to_generate_beacon_v2()
  -- if to_generate.tier > 0 then
  --   -- do stuff
  -- end

  -- RNG decide if needs to have a beacon or not
  -- if to_generate_beacon() then
  if to_generate.tier > 0 then
    -- game.print(tostring(event.position.x)..", "..tostring(event.position.y))
    -- event.surface.set_tiles(global.custom_tiles, true)
    local map_position = {
      x = event.position.x * 32 + global.generator(0, 29),
      y = event.position.y * 32 + global.generator(0, 29)
    }

    local allowed = false
    local attempt = 0
    while attempt < 3 do
      if event.surface.can_place_entity({ name = "beacon", position = map_position }) then
        allowed = true
        break
      end
      map_position = {
        x = event.position.x * 32 + global.generator(0, 29),
        y = event.position.y * 32 + global.generator(0, 29)
      }
      attempt = attempt + 1
    end

    if allowed then
      game.get_player("Goradux").print("Generating a crystal at" ..
        (map_position.x) .. " " .. (map_position.y))

      -- spawn the crystal
      local generated_crystal = generate_one_crystal(event.surface, map_position, "player", to_generate.tier, to_generate.positive)

      -- save meta info for tagging
      if global.tag_crystals then
        global.chunks_with_crystals[tostring(event.position.x) .. tostring(event.position.y)] = {
          map_position = map_position, tier = generated_crystal.tier, type = generated_crystal.type }
      end
    end
  end
end
)

-- on_chunk_charted event and force.is_chunk_charted to check

script.on_event(defines.events.on_chunk_charted, function(event)
  if global.chunks_with_crystals[tostring(event.position.x) .. tostring(event.position.y)] then
    -- game.print(tostring(event.position.x)..", "..tostring(event.position.y))
    local crystal_data = global.chunks_with_crystals[tostring(event.position.x) .. tostring(event.position.y)]
    local map_position = crystal_data.map_position
    local tier = crystal_data.tier
    local type = crystal_data.type
    local size
    if tier == 1 then
      size = "Small"
    elseif tier == 2 then
      size = "Medium"
    else
      size = "Big"
    end

    local color
    if type == "speed" then
      color = "blue"
    elseif type == "productivity" then
      color = "red"
    else
      color = "green"
    end

    global.chunks_with_crystals[tostring(event.position.x) .. tostring(event.position.y)] = nil

    if global.tag_crystals then
      local charTagSpec = {
        position = map_position,
        text = size .. " " .. color .. " crystal",
        icon = { type = "item", name = type .. "-module" }
      }
      game.forces["player"].add_chart_tag(game.surfaces[event.surface_index], charTagSpec)
    end
    -- game.get_player("Goradux").print("generating a chart tag!")
  end
end
)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == "power-crystals-tag-new-crystals" then
    global.tag_crystals = settings.global["power-crystals-tag-new-crystals"].value
    game.get_player("Goradux").print("Changed tag settings!")
  end
end
)
