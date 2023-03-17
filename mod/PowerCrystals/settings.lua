data:extend({
  {
    type = "bool-setting",
    name = "power-crystals-tag-new-crystals",
    setting_type = "runtime-global",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "power-crystals-enable-negative",
    setting_type = "runtime-global",
    default_value = true
  },
  {
    type = "int-setting",
    name = "power-crystals-frequency-tier-1",
    setting_type = "runtime-global",
    default_value = 400, -- 4% chance to spawn in a chunk
    minimum_value = 0, -- 0% chance to spawn
    maximum_value =2000 -- 20% chance to spawn in a chunk. Can't be more than 20% because bad crystals need to spawn as well. But this number is ridiculously big already
  },
  {
    type = "int-setting",
    name = "power-crystals-frequency-tier-2",
    setting_type = "runtime-global",
    default_value = 200, -- 2% chance to spawn in a chunk
    minimum_value = 0, -- 0% chance to spawn
    maximum_value = 2000 -- 20% chance to spawn in a chunk
  },
  {
    type = "int-setting",
    name = "power-crystals-frequency-tier-3",
    setting_type = "runtime-global",
    default_value = 100, -- 1% chance to spawn in a chunk
    minimum_value = 0, -- 0% chance to spawn
    maximum_value = 2000 -- 20% chance to spawn in a chunk
  },
})
