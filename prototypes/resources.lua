local resource_autoplace = require("resource-autoplace")
local sounds = require("__base__.prototypes.entity.sounds")

local function resource(resource_parameters, autoplace_parameters)
  return
  {
    type = "resource",
    name = resource_parameters.name,
    icon = icons .. "" .. resource_parameters.name .. ".png",
    flags = {"placeable-neutral"},
    order="a-b-"..resource_parameters.order,
    tree_removal_probability = 0.8,
    tree_removal_max_distance = 32 * 32,
    minable = resource_parameters.minable or
    {
      mining_particle = "iron-ore-particle",
      mining_time = resource_parameters.mining_time,
      result = resource_parameters.name
    },
    category = resource_parameters.category,
    subgroup = resource_parameters.subgroup,
    walking_sound = resource_parameters.walking_sound,
    collision_mask = resource_parameters.collision_mask,
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    resource_patch_search_radius = resource_parameters.resource_patch_search_radius,
    autoplace = autoplace_parameters.probability_expression ~= nil and
    {
      --control = resource_parameters.name,
      order = resource_parameters.order,
      probability_expression = autoplace_parameters.probability_expression,
      richness_expression = autoplace_parameters.richness_expression
    }
    or resource_autoplace.resource_autoplace_settings
    {
      name = resource_parameters.name,
      order = resource_parameters.order,
      autoplace_control_name = resource_parameters.autoplace_control_name,
      base_density = autoplace_parameters.base_density,
      base_spots_per_km = autoplace_parameters.base_spots_per_km2,
      regular_rq_factor_multiplier = autoplace_parameters.regular_rq_factor_multiplier,
      starting_rq_factor_multiplier = autoplace_parameters.starting_rq_factor_multiplier,
      candidate_spot_count = autoplace_parameters.candidate_spot_count,
      tile_restriction = autoplace_parameters.tile_restriction
    },
    stage_counts = {15000, 9500, 5500, 2900, 1300, 400, 150, 80},
    stages =
    {
      sheet =
      {
        filename = "__arrakis_my_dune__/graphics/entity/" .. resource_parameters.name .. "/" .. resource_parameters.name .. ".png",
        priority = "extra-high",
        size = 128,
        frame_count = 8,
        variation_count = 8,
        scale = 0.5
      }
    },
    map_color = resource_parameters.map_color,
    mining_visualisation_tint = resource_parameters.mining_visualisation_tint,
    factoriopedia_simulation = resource_parameters.factoriopedia_simulation
  }
end


data:extend({
  --AUTOPLACE CONTROLS
  {
    type = "autoplace-control",
    name = "black_acid_geyser",
    localised_name = {"", "[entity=black-acid-geyser] ", {"entity-name.black-acid-geyser"}},
    richness = true,
    order = "m-e",
    category = "resource"
  },
  {
    type = "autoplace-control",
    name = "molten_copper_geyser",
    localised_name = {"", "[entity=molten-copper-geyser] ", {"entity-name.molten-copper-geyser"}},
    richness = true,
    order = "m-b",
    category = "resource"
  },
  {
    type = "autoplace-control",
    name = "steam_geyser",
    localised_name = {"", "[entity=steam-geyser] ", {"entity-name.steam-geyser"}},
    richness = true,
    order = "m-c",
    category = "resource"
  },

  {
    type = "resource",
    name = "black-acid-geyser",
    icon = icons .. "black-acid-geyser.png",
    flags = {"placeable-neutral"},
    category = "basic-fluid",
    subgroup = "mineable-fluids",
    order="a-b-a",
    infinite = true,
    highlight = true,
    minimum = 600000,
    normal = 3000000,
    infinite_depletion_amount = 10,
    resource_patch_search_radius = 10,
    tree_removal_probability = 0.7,
    tree_removal_max_distance = 32 * 32,
    draw_stateless_visualisation_under_building = false,
    minable =
    {
      mining_time = 1,
      results =
      {
        {
          type = "fluid",
          name = "black-acid",
          amount_min = 10,
          amount_max = 10,
          probability = 1
        }
      }
    },
    walking_sound = sounds.oil,
    working_sound =
    {
      sound =
      {
        category = "world-ambient", variations = sound_variations("__space-age__/sound/world/resources/sulfuric-acid-geyser", 1, 0.3),
        advanced_volume_control =
        {
          fades = {fade_in = {curve_type = "S-curve", from = {control = 0.3, volume_percentage = 0.0}, to = {2.0, 100.0}}}
        },
        audible_distance_modifier = 0.3,
      },
      max_sounds_per_prototype = 3,
    },
    --collision_mask = {layers={is_object = true, is_lower_object = true, water_tile = true}},
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    autoplace =
    {
      --control = "sulfuric-acid-geyser",
      order = "a", -- Other resources are "b"; oil won't get placed if something else is already there.
      probability_expression = 0
    },
    stage_counts = {0},
    stages =
    {
      layers =
      {
        {
          filename = "__arrakis_my_dune__/graphics/entity/black-acid-geyser/black-acid-geyser.png",
          width = 254,
          height = 178,
          shift = util.by_pixel( 9.5, 5.0),
          priority = "high",
          line_length = 4,
          frame_count = 4,
          scale = 0.5,
        },
      }
    },
    stateless_visualisation =
    {
      -- expanded 2 animation layers into 2 visualisations to demo multiple visualisations
      {
        count = 1,
        render_layer = "smoke",
        animation =
        {
          filename = "__arrakis_my_dune__/graphics/entity/black-acid-geyser/black-acid-geyser-gas-outer.png",
          frame_count = 47,
          line_length = 16,
          width = 40,
          height = 84,
          animation_speed = 0.3,
          shift = util.by_pixel(-4, -30),
          scale = 1,
          tint = util.multiply_color({r=1, g=1, b=1}, 0.15)
        }
      },
      {
        count = 1,
        render_layer = "smoke",
        animation =
        {
           filename = "__arrakis_my_dune__/graphics/entity/black-acid-geyser/black-acid-geyser-gas-inner.png",
           frame_count = 47,
           line_length = 16,
           width = 40,
           height = 84,
           animation_speed = 0.3,
           shift = util.by_pixel(-4, -30),
           scale = 1,
           tint = util.multiply_color({r=1, g=1, b=1}, 0.2)
        }
      }
    },
    map_color = {r = 20, g = 10, b = 140, a = 255},
    map_grid = false
  },
})
    --[[
  {
    type = "resource",
    name = "molten-copper-geyser",
    icon = icons .. "molten-copper-geyser.png",
    flags = {"placeable-neutral"},
    category = "basic-fluid",
    subgroup = "mineable-fluids",
    order="a-b-a",
    infinite = true,
    highlight = true,
    minimum = 600000,
    normal = 3000000,
    infinite_depletion_amount = 10,
    resource_patch_search_radius = 10,
    tree_removal_probability = 0.7,
    tree_removal_max_distance = 32 * 32,
    draw_stateless_visualisation_under_building = false,
    minable =
    {
      mining_time = 1,
      results =
      {
        {
          type = "fluid",
          name = "molten-copper",
          amount_min = 10,
          amount_max = 10,
          probability = 1
        }
      }
    },
    walking_sound = sounds.oil,
    working_sound =
    {
      sound =
      {
        category = "world-ambient", variations = sound_variations("__space-age__/sound/world/resources/sulfuric-acid-geyser", 1, 0.3),
        advanced_volume_control =
        {
          fades = {fade_in = {curve_type = "S-curve", from = {control = 0.3, volume_percentage = 0.0}, to = {2.0, 100.0}}}
        },
        audible_distance_modifier = 0.3,
      },
      max_sounds_per_prototype = 3,
    },
    --collision_mask = {layers={is_object = true, is_lower_object = true, water_tile = true}},
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    autoplace =
    {
      --control = "sulfuric-acid-geyser",
      order = "a", -- Other resources are "b"; oil won't get placed if something else is already there.
      probability_expression = 0
    },
    stage_counts = {0},
    stages =
    {
      layers =
      {
        {
          filename = "__arrakis_my_dune__/graphics/entity/molten-copper-geyser/molten-copper-geyser.png",
          width = 254,
          height = 178,
          shift = util.by_pixel( 9.5, 5.0),
          priority = "high",
          line_length = 4,
          frame_count = 4,
          scale = 0.5,
        },
        {
          filename = "__arrakis_my_dune__/graphics/entity/molten-copper-geyser/molten-copper-geyser-glow.png",
          width = 254,
          height = 178,
          shift = util.by_pixel( 9.5, 5.0),
          priority = "high",
          frame_count = 4,
          line_length = 4,
          scale = 0.5,
          draw_as_glow = true,
          blend_mode = "additive",
        }
      }
    },
    stateless_visualisation =
    {
      -- expanded 2 animation layers into 2 visualisations to demo multiple visualisations
      {
        count = 1,
        render_layer = "smoke",
        animation =
        {
          filename = "__arrakis_my_dune__/graphics/entity/molten-copper-geyser/molten-copper-geyser-gas-outer.png",
          frame_count = 47,
          line_length = 16,
          width = 90,
          height = 188,
          animation_speed = 0.3,
          shift = util.by_pixel(-6, -89),
          scale = 1,
          tint = util.multiply_color({r=1, g=1, b=1}, 0.15)
        }
      },
      {
        count = 1,
        render_layer = "smoke",
        animation =
        {
           filename = "__arrakis_my_dune__/graphics/entity/molten-copper-geyser/molten-copper-geyser-gas-inner.png",
           frame_count = 47,
           line_length = 16,
           width = 40,
           height = 84,
           animation_speed = 0.3,
           shift = util.by_pixel(-4, -30),
           scale = 1,
           tint = util.multiply_color({r=1, g=1, b=1}, 0.2)
        }
      }
    },
    map_color = {r = 250, g = 126, b = 58, a = 255},
    map_grid = false
  },


  {
    type = "resource",
    name = "steam-geyser",
    icon = icons .. "steam-geyser.png",
    flags = {"placeable-neutral"},
    category = "basic-fluid",
    subgroup = "mineable-fluids",
    order="a-b-a",
    infinite = true,
    highlight = true,
    minimum = 700000,
    normal = 70000000,
    infinite_depletion_amount = 10,
    resource_patch_search_radius = 9,
    tree_removal_probability = 0.7,
    tree_removal_max_distance = 32 * 32,
    draw_stateless_visualisation_under_building = false,
    minable =
    {
      mining_time = 1,
      results =
      {
        {
          type = "fluid",
          name = "steam",
          temperature = 500,
          amount_min = 10,
          amount_max = 100,
          probability = 1,
        }
      }
    },
    walking_sound = sounds.oil,
    working_sound =
    {
      sound =
      {
        category = "world-ambient", variations = sound_variations("__arrakis_my_dune__/sound/geyser/geyser", 1, 0.7),
        advanced_volume_control =
        {
          fades = {fade_in = {curve_type = "S-curve", from = {control = 0.3, volume_percentage = 0.0}, to = {2.0, 100.0}}}
        },
        audible_distance_modifier = 0.3,
      },
      max_sounds_per_prototype = 3,
    },
    --collision_mask = {layers={is_object = true, is_lower_object = true, water_tile = true}},
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    autoplace =
    {
      --control = "sulfuric-acid-geyser",
      order = "b", -- Other resources are "b"; oil won't get placed if something else is already there.
      probability_expression = 0
    },
    stage_counts = {0},
    stages =
    {
      layers =
      {
        util.sprite_load("__arrakis_my_dune__/graphics/entity/steam-geyser/steam-geyser",
        {
          priority = "high",
          frame_count = 4,
          scale = 0.5,
        })
      }
    },
    stateless_visualisation =
    {
      -- expanded 2 animation layers into 2 visualisations to demo multiple visualisations
      {
        count = 1,
        render_layer = "smoke",
        animation =
        {
          filename = "__arrakis_my_dune__/graphics/entity/steam-geyser/steam-geyser-gas-outer.png",
          frame_count = 47,
          line_length = 16,
          width = 90,
          height = 188,
          animation_speed = 2,
          shift = util.by_pixel(0, -89),
          scale = 0.8,
          tint = util.multiply_color({r=1, g=1, b=1}, 0.2)
        }
      },
      {
        count = 1,
        render_layer = "smoke",
        animation =
        {
           filename = "__arrakis_my_dune__/graphics/entity/steam-geyser/steam-geyser-gas-inner.png",
           frame_count = 47,
           line_length = 16,
           width = 40,
           height = 84,
           animation_speed = 2,
           shift = util.by_pixel(0, -30),
           scale = 0.8,
           tint = util.multiply_color({r=1, g=1, b=1}, 0.3)
        }
      }
    },
    map_color = {r = 189/256, g = 189/256, b = 189/256, a = 1.000},
    map_grid = false
  }
})


]]--