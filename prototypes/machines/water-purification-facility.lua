local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local config = require("__arrakis_my_dune__.prototypes.-config")

data:extend({
    -- SAND REFINERY PROTOTYPE -------------------------------------------------------------------------------------------------

    {
    type = "assembling-machine",
    name = "water-purification-facility",
    icon = icons .. "water-purification-facility.png",
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 0.2, result = "water-purification-facility"},
    max_health = 350,
    corpse = "foundry-remnants",
    dying_explosion = "foundry-explosion",
    circuit_wire_max_distance = assembling_machine_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions["foundry"],
    collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    heating_energy = "300kW",
    damaged_trigger_effect = hit_effects.entity(),
    drawing_box_vertical_extension = 0.4,
    module_slots = 2,
    icon_draw_specification = {scale = 2, shift = {0, -0.3}},
    icons_positioning =
    {
      {inventory_index = defines.inventory.assembling_machine_modules, shift = {0, 1.25}}
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution", "quality"},
    crafting_categories = {"water-purification"},
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { humidity = config.HUMIDITY_WATER_PURIFICATION_FACILITY }
    },
    energy_usage = "200kW",
    perceived_performance = {minimum = 0.25, maximum = 10},
    graphics_set = require("__arrakis_my_dune__.prototypes.machines.machine-pictures.water-purification-facility-pictures").graphics_set,
    open_sound = sounds.steam_open,
    close_sound = sounds.steam_close,
    working_sound =
    {
      sound =
      {
        filename = "__arrakis_my_dune__/sound/entity/water-purification-facility/water-purification.ogg",
        volume = 0.5,
        audible_distance_modifier = 0.6
      },
      fade_in_ticks = 4,
      fade_out_ticks = 20,
      sound_accents =
      {
        {sound = {filename = "__arrakis_my_dune__/sound/entity/water-purification-facility/tank-fall.ogg", volume = 0.9, audible_distance_modifier = 0.4}, frame = 5},
        {sound = {filename = "__arrakis_my_dune__/sound/entity/water-purification-facility/steam-jets.ogg", volume = 0.65, audible_distance_modifier = 0.4}, frame = 10},
        {sound = {filename = "__arrakis_my_dune__/sound/entity/water-purification-facility/clonk.ogg", volume = 0.45, audible_distance_modifier = 0.3}, frame = 1},
        {sound = {filename = "__arrakis_my_dune__/sound/entity/water-purification-facility/steam-jet2.ogg", volume = 0.7, audible_distance_modifier = 0.4}, frame = 56},
        {sound = {filename = "__arrakis_my_dune__/sound/entity/water-purification-facility/tank-lift.ogg", volume = 0.65, audible_distance_modifier = 0.4}, frame = 20},
        {sound = {filename = "__arrakis_my_dune__/sound/entity/water-purification-facility/water-pressured.ogg", volume = 0.65, audible_distance_modifier = 0.3}, frame = 35},
      },
      max_sounds_per_prototype = 2
    },
    fluid_boxes =
    {
      {
        production_type = "input",
        pipe_picture = util.empty_sprite(),
        pipe_picture_frozen = require("__space-age__.prototypes.entity.foundry-pictures").pipe_picture_frozen,
        pipe_covers = pipecoverspictures(),
        always_draw_covers = false,
        enable_working_visualisations = { "input-pipe" },
        volume = 1000,
        pipe_connections = {{ flow_direction = "input", direction = defines.direction.south, position = {0, 2} }}
      },
      {
        production_type = "output",
        pipe_picture = util.empty_sprite(),
        pipe_covers = pipecoverspictures(),
        always_draw_covers = false,
        enable_working_visualisations = { "output-pipe" },
        volume = 100,
        pipe_connections = {{ flow_direction = "output", direction = defines.direction.north, position = {0, -2} }}
      },
    },
    fluid_boxes_off_when_no_fluid_recipe = true,
    water_reflection =
    {
      pictures = util.sprite_load("__space-age__/graphics/entity/foundry/foundry-reflection",
      {
          scale = 7,
          shift = {0,2}
      }),
      rotate = false
    }
  }
})