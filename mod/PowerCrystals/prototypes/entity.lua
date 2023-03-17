--entity.lua

-- crystal types:
-- red, green, blue crystals
-- rgb crystals but negative
-- power generating crystals


local function by_pixel(x, y)
  return { x / 32, y / 32 }
end

--- Get map color based on the type and tier of the crystal
---@param type string
---@param tier integer
---@return {r: integer, g: integer, b: integer}
local function get_map_color(type, tier)
  if type == "speed" then
    if tier == 1 then
      return { r = 0.5, g = 0.8, b = 1 } -- lightskyblue rgb(135,206,250)
    elseif tier == 2 then
      return { g = 0.75, b = 1 }         -- deepskyblue rgb(0,191,255)
    else
      return { b = 1 }                   -- blue
    end
  elseif type == "productivity" then
    if tier == 1 then
      return { r = 1, g = 0.85 } -- gold rgb(255,215,0)
    elseif tier == 2 then
      return { r = 1, g = 0.65 } -- orange rgb(255,165,0)
    else
      return { r = 1, g = 0.55 } -- dark orange rgb(255,140,0)
    end
  elseif type == "effectivity" then
    if tier == 1 then
      return { r = 0.2, g = 0.8, b = 0.2 } -- limegreen rgb(50,205,50)
    elseif tier == 2 then
      return { g = 0.5 }                   -- green rgb(0,128,0)
    else
      return { g = 0.4 }                   -- darkgreen rgb(0,100,0)
    end
  elseif type == "instability" then
    if tier == 1 then
      return { r = 0.93, g = 0.51, b = 0.93 } -- violet rgb(238,130,238)
    elseif tier == 2 then
      return { r = 0.85, g = 0.44, b = 0.84 } -- orchid rgb(218,112,214)
    else                                      -- tier 3 doesn't exist
      return { r = 0.29, b = 0.51 }           -- indigo rgb(75,0,130)
    end
  end
  return { r = 1, g = 1 } -- default yellow
end

-- original definition:
-- C:\Program Files (x86)\Steam\steamapps\common\Factorio\data\base\prototypes\entity search for beacon

--- generates the invisible and not-clickable beacon that has slots
---@param tier any
---@param positive any
---@return table|unknown
local function generateBasePowerCrystal(tier, positive)
  local basePowerCrystal = table.deepcopy(data.raw.beacon["beacon"])
  basePowerCrystal.name = "base-power-crystal-" .. tier
  basePowerCrystal.is_military_target = false
  basePowerCrystal.energy_source = { type = "void" }
  basePowerCrystal.selectable_in_game = true -- but you should never be able to get to it through the model crystal
  basePowerCrystal.minable = nil
  basePowerCrystal.allowed_effects = { "speed", "productivity", "consumption", "pollution" }
  basePowerCrystal.graphics_set = nil

  local supply_area_distance, max_health, module_slots
  if tier == 1 then
    supply_area_distance = 24
    max_health = 200
    module_slots = 1
  elseif tier == 2 then
    supply_area_distance = 40
    max_health = 500
    module_slots = 2
  else
    supply_area_distance = 64
    max_health = 1000
    module_slots = 4
  end

  basePowerCrystal.supply_area_distance = supply_area_distance
  basePowerCrystal.max_health = max_health

  basePowerCrystal.distribution_effectivity = 1
  basePowerCrystal.module_specification.module_slots = module_slots
  basePowerCrystal.map_color = { a = 0 } -- invisible
  basePowerCrystal.working_sound = nil
  basePowerCrystal.corpse = nil
  basePowerCrystal.healing_per_tick = 1
  basePowerCrystal.icon = "__PowerCrystals__/graphics/power-crystal/crystal-icon.png"

  basePowerCrystal.resistances =
  {
    {
      type = "physical",
      decrease = 100,
    },
    {
      type = "explosion",
      percent = 0
    },
    {
      type = "acid",
      decrease = 100,
    },
    {
      type = "fire",
      decrease = 0,
      percent = 0
    }
  }

  -- modify for bad crystals. Make them almost unkillable
  if positive == false then
    basePowerCrystal.name = "base-power-crystal-negative-" .. tier
    basePowerCrystal.max_health = 1000
    basePowerCrystal.resistances =
    {
      {
        type = "physical",
        decrease = 100,
        percent = 50
      },
      {
        type = "explosion",
        decrease = 50,
        percent = 50
      },
      {
        type = "acid",
        decrease = 100,
        percent = 50
      },
      {
        type = "fire",
        decrease = 100,
        percent = 50
      }
    }
  end

  return basePowerCrystal
end

local base_tier_1 = generateBasePowerCrystal(1, true)
local base_tier_2 = generateBasePowerCrystal(2, true)
local base_tier_3 = generateBasePowerCrystal(3, true)

data:extend { base_tier_1, base_tier_2, base_tier_3 }


local base_tier_1_negative = generateBasePowerCrystal(1, false)
local base_tier_2_negative = generateBasePowerCrystal(2, false)
data:extend { base_tier_1_negative, base_tier_2_negative }


--- "model" means that this entity only does the graphics.
--- I had to do implement the beacon this way so that a player could hover over
--- the entity, but when clicking on it no modules would show. Otherwise,
--- players could just remove the modules and use them in other places
---@param type string
---@param tier integer
---@param positive boolean
-- -@return table|unknown
local function generateModelPowerCrystal(type, tier, positive)
  local modelPowerCrystal = table.deepcopy(data.raw.beacon["beacon"])

  local supply_area_distance, max_health
  if tier == 1 then
    supply_area_distance = 24
    max_health = 200
  elseif tier == 2 then
    supply_area_distance = 40
    max_health = 500
  else
    supply_area_distance = 64
    max_health = 1000
  end

  modelPowerCrystal.name = "model-power-crystal-" .. type .. "-" .. tier
  modelPowerCrystal.is_military_target = false
  modelPowerCrystal.supply_area_distance = supply_area_distance
  modelPowerCrystal.energy_source = { type = "void" }
  modelPowerCrystal.max_health = max_health
  modelPowerCrystal.selectable_in_game = true
  modelPowerCrystal.minable = nil
  modelPowerCrystal.allowed_effects = nil
  modelPowerCrystal.module_specification.module_slots = 0
  modelPowerCrystal.map_color = get_map_color(type, tier)
  modelPowerCrystal.distribution_effectivity = 1

  modelPowerCrystal.working_sound =
  {
    sound = { filename = "__base__/sound/accumulator-working.ogg", volume = 0.4 },
    apparent_volume = 0.3,
  }
  modelPowerCrystal.graphics_set = {
    draw_animation_when_idle = true,
    draw_light_when_idle = true,
    module_icons_suppressed = true,
    animation_list =
    {
      {
        render_layer = "object",
        always_draw = true,
        animation =
        {
          filename = "__PowerCrystals__/graphics/power-crystal/crystal-" .. type .. "-" .. tier .. ".png",
          -- width = 98,
          -- height = 87,
          width = 214,
          height = 214,
          frame_count = 8,
          line_length = 8,
          scale = 0.4,
          animation_speed = 1 / 12,
          shift = by_pixel(0, 1.5),
          -- hr_version =
          -- {
          --   filename = "__base__/graphics/entity/beacon/hr-beacon-top.png",
          --   width = 96,
          --   height = 140,
          --   scale = 0.5,
          --   repeat_count = 45,
          --   animation_speed = 0.5,
          --   shift = by_pixel(3, -19)
          -- }
        }
      }
    },
  }
  modelPowerCrystal.icon = "__PowerCrystals__/graphics/power-crystal/crystal-icon.png"

  modelPowerCrystal.corpse = nil -- so nothing is left after it is destroyed
  modelPowerCrystal.dying_explosion = "big-explosion"
  modelPowerCrystal.dying_trigger_effect = {
    {
      type = "nested-result",
      action = {
        type = "area",
        radius = 5,
        action_delivery = { type = "instant",
          target_effects = { { type = "damage", damage = { amount = 1000, type = "explosion" } } } },
      }
    },
  }

  modelPowerCrystal.healing_per_tick = 1

  modelPowerCrystal.resistances =
  {
    {
      type = "physical",
      decrease = 100,
    },
    {
      type = "explosion",
      percent = 0
    },
    {
      type = "acid",
      decrease = 100,
    },
    {
      type = "fire",
      decrease = 0,
      percent = 0
    }
  }

  if positive == false then
    modelPowerCrystal.max_health = 1000
    modelPowerCrystal.resistances =
    {
      {
        type = "physical",
        decrease = 100,
        percent = 50
      },
      {
        type = "explosion",
        decrease = 100,
        percent = 50
      },
      {
        type = "acid",
        decrease = 100,
        percent = 50
      },
      {
        type = "fire",
        decrease = 100,
        percent = 50
      }
    }
    modelPowerCrystal.dying_trigger_effect = {
      {
        type = "nested-result",
        action = {
          type = "area",
          radius = 5,
          action_delivery = { type = "instant",
            target_effects = { { type = "damage", damage = { amount = 10000, type = "explosion" } } } },
        }
      },
    }
  end


  return modelPowerCrystal
end


local crystal_productivity_1 = generateModelPowerCrystal("productivity", 1, true)
local crystal_productivity_2 = generateModelPowerCrystal("productivity", 2, true)
local crystal_productivity_3 = generateModelPowerCrystal("productivity", 3, true)

local crystal_effectivity_1 = generateModelPowerCrystal("effectivity", 1, true)
local crystal_effectivity_2 = generateModelPowerCrystal("effectivity", 2, true)
local crystal_effectivity_3 = generateModelPowerCrystal("effectivity", 3, true)

local crystal_speed_1 = generateModelPowerCrystal("speed", 1, true)
local crystal_speed_2 = generateModelPowerCrystal("speed", 2, true)
local crystal_speed_3 = generateModelPowerCrystal("speed", 3, true)

data:extend { crystal_productivity_1, crystal_productivity_2, crystal_productivity_3 }
data:extend { crystal_effectivity_1, crystal_effectivity_2, crystal_effectivity_3 }
data:extend { crystal_speed_1, crystal_speed_2, crystal_speed_3 }

-- bad crystals
local crystal_instability_1 = generateModelPowerCrystal("instability", 1, false)
local crystal_instability_2 = generateModelPowerCrystal("instability", 2, false)

data:extend { crystal_instability_1, crystal_instability_2 }

local moduleCategory = table.deepcopy(data.raw["module-category"]["speed"])
moduleCategory.name = "crystal"
-- moduleCategory.type = defines.prototypes.
data:extend { moduleCategory }


local productivityModule = table.deepcopy(data.raw.module["productivity-module"])
productivityModule.name = "productivity-power-crystal-module"
productivityModule.category = "crystal"
productivityModule.localised_name = "Red crystal"
productivityModule.tier = 1
productivityModule.effect = { productivity = { bonus = 0.25 } }
productivityModule.icons = {
  {
    icon = "__PowerCrystals__/graphics/power-crystal/crystal-icon.png",
      tint = {r = 1, g = 0, b = 0, a = 0.2}
  },
}

data:extend { productivityModule }

local effectivityModule = table.deepcopy(data.raw.module["effectivity-module"])
effectivityModule.name = "effectivity-power-crystal-module"
effectivityModule.category = "crystal"
effectivityModule.localised_name = "Green crystal"
effectivityModule.tier = 2
effectivityModule.effect = { consumption = { bonus = -1 }, pollution = { bonus = -0.2 } }
effectivityModule.icons = {
  {
    icon = "__PowerCrystals__/graphics/power-crystal/crystal-icon.png",
      tint = {r = 0, g = 1, b = 0, a = 0.2}
  },
}

data:extend { effectivityModule }


local speedModule = table.deepcopy(data.raw.module["speed-module"])
speedModule.name = "speed-power-crystal-module"
speedModule.category = "crystal"
speedModule.localised_name = "Blue crystal"
speedModule.tier = 3
speedModule.effect = { speed = { bonus = 0.5 } }
speedModule.icons = {
  {
    icon = "__PowerCrystals__/graphics/power-crystal/crystal-icon.png",
      tint = {r = 0, g = 0, b = 1, a = 0.2}
  },
}

data:extend { speedModule }


local instabilityModule = table.deepcopy(data.raw.module["speed-module"])
instabilityModule.name = "instability-power-crystal-module"
instabilityModule.category = "crystal"
instabilityModule.localised_name = "Purple crystal"
instabilityModule.tier = 4
instabilityModule.effect = { speed = { bonus = -0.5 }, consumption = { bonus = 1 }, pollution = { bonus = 0.2 } }
instabilityModule.icons = {
  {
    icon = "__PowerCrystals__/graphics/power-crystal/crystal-icon.png",
      tint = {r = 0.85, g = 0.44, b = 0.84, a = 0.2}
  },
}

data:extend { instabilityModule }
