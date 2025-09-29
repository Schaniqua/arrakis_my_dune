local techicons = "__arrakis_my_dune__/graphics/technology/"

-- STARTUP SETTING DISABLE AAI TECH INITIALLY FOR ARRAKIS TECH TREE TO MAKE SENSE
local startup_setting_hide_aai_vehicles_initially = settings.startup["hide-default-aai-vehicles"].value
if startup_setting_hide_aai_vehicles_initially then
    data.raw.technology["vehicle-miner-1"].hidden = true
    data.raw.technology["vehicle-miner-2"].hidden = true
    data.raw.technology["vehicle-miner-3"].hidden = true
    data.raw.technology["vehicle-miner-4"].hidden = true
    data.raw.technology["vehicle-miner-5"].hidden = true
    data.raw.technology["vehicle-miner-5"].hidden = false
    data.raw.technology["programmable-structures"].hidden = true
    data.raw.technology["vehicle-deployment"].hidden = true
    data.raw.technology["vehicle-depot"].hidden = true
    data.raw.technology["position-beacon"].hidden = true
    data.raw.technology["programmable-vehicle-structures"].hidden = true
    data.raw.technology["basic-vehicles"].hidden = true -- HAULER
end

-- RESEARCH TO UNLOCK MODIFIED MINER VEHICLE ON ARRAKIS
data:extend({{
    type = "technology",
    name = "spice-miner-1",
    icons = util.technology_icon_constant_planet(techicons .. "arrakis-tech-arrakis.png"),
    icon_size = 256,
    essential = true,
    effects = {{
        type = "unlock-recipe",
        recipe = "vehicle-miner-mk5"
    }},
    prerequisites = {"planet-discovery-arrakis"},
    unit = {
        count = 600,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1},
                       {"space-science-pack", 1}},
        time = 60
    }
}})


-- STARTUP SETTING ENABLE MINING VEHICLE RESKIN FOR PLANET ARRAKIS
local startup_setting_miner_reskin = settings.startup["enable_aai_miners_planet_skin"].value
if startup_setting_miner_reskin then
    for i = 1, 5 do
        local real_suffix = ("-mk" .. i)
        local suffix = (i > 1) and real_suffix or ""
        local earendel_aai_miners_planet_skin = util.table.deepcopy(data.raw["car"]["vehicle-miner" .. suffix])



        -- THIS IS THE MINER ANIMATION FOR MK1-5 --------------------------------------------------------------------
        -- THIS CURRENTLY IS JUST A COPY PASTE OF THE CAR ANIMATION ANYONE FEEL FREE TO MAKE SOMETHING NICER
        earendel_aai_miners_planet_skin.animation = {
            layers = {{
                priority = "low",
                width = 201,
                height = 172,
                frame_count = 2,
                scale = 0.5,
                direction_count = 64,
                shift = util.by_pixel(0 + 2, -11.5 + 8.5),
                animation_speed = 8,
                max_advance = 0.2,
                stripes = {{
                    filename = "__base__/graphics/entity/car/car-1.png",
                    width_in_frames = 2,
                    height_in_frames = 11
                }, {
                    filename = "__base__/graphics/entity/car/car-2.png",
                    width_in_frames = 2,
                    height_in_frames = 11
                }, {
                    filename = "__base__/graphics/entity/car/car-3.png",
                    width_in_frames = 2,
                    height_in_frames = 11
                }, {
                    filename = "__base__/graphics/entity/car/car-4.png",
                    width_in_frames = 2,
                    height_in_frames = 11
                }, {
                    filename = "__base__/graphics/entity/car/car-5.png",
                    width_in_frames = 2,
                    height_in_frames = 11
                }, {
                    filename = "__base__/graphics/entity/car/car-6.png",
                    width_in_frames = 2,
                    height_in_frames = 9
                }}
            }, {
                priority = "low",
                width = 199,
                height = 147,
                frame_count = 2,
                apply_runtime_tint = true,
                scale = 0.5,
                direction_count = 64,
                max_advance = 0.2,
                shift = util.by_pixel(0 + 2, -11 + 8.5),
                line_length = 1,
                stripes = util.multiplystripes(2, {{
                    filename = "__base__/graphics/entity/car/car-mask-1.png",
                    width_in_frames = 1,
                    height_in_frames = 13
                }, {
                    filename = "__base__/graphics/entity/car/car-mask-2.png",
                    width_in_frames = 1,
                    height_in_frames = 13
                }, {
                    filename = "__base__/graphics/entity/car/car-mask-3.png",
                    width_in_frames = 1,
                    height_in_frames = 13
                }, {
                    filename = "__base__/graphics/entity/car/car-mask-4.png",
                    width_in_frames = 1,
                    height_in_frames = 13
                }, {
                    filename = "__base__/graphics/entity/car/car-mask-5.png",
                    width_in_frames = 1,
                    height_in_frames = 12
                }})
            }, {
                priority = "low",
                width = 114,
                height = 76,
                frame_count = 2,
                draw_as_shadow = true,
                direction_count = 64,
                shift = {0.28125, 0.25},
                max_advance = 0.2,
                stripes = util.multiplystripes(2, {{
                    filename = "__base__/graphics/entity/car/car-shadow-1.png",
                    width_in_frames = 1,
                    height_in_frames = 22
                }, {
                    filename = "__base__/graphics/entity/car/car-shadow-2.png",
                    width_in_frames = 1,
                    height_in_frames = 22
                }, {
                    filename = "__base__/graphics/entity/car/car-shadow-3.png",
                    width_in_frames = 1,
                    height_in_frames = 20
                }})
            }}
        }
        -- THIS IS THE MINER ANIMATION FOR MK1-5 --------------------------------------------------------------------
        data:extend({earendel_aai_miners_planet_skin})
    end
end

