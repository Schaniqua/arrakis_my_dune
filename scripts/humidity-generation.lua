local config = require("__arrakis_my_dune__.prototypes.-config")
local TICK_LOOP = 60

local MINIMUM_POLLUTION_FOR_OPERATION = 0.01 --Currently set to produce water only when humidity in chunk > 0.01
local ADDED_POLLUTION_PER_CHUNK = 0.1
local POLLUTION_ADD_INTERVAL_SECONDS = 5
local MAX_POLLUTION_PER_NIGHT = 10



--DUMMY DO NOT REMOVE -----------------------------
local ticks = 60 * config.POLLUTION_ADD_INTERVAL_SECONDS
---------------------------------------------------

--Run once per second to update water condensators
script.on_nth_tick(TICK_LOOP, function()

    --Check if Arrakis even exists
    if game.surfaces["arrakis"] then
        -- this is not optimised at all but can be remade later if needed, low hanging fruit changing find_entities to references in memory
        for key, entity in pairs(game.surfaces["arrakis"].find_entities_filtered({name="water-condenser"})) do
            --game.print("test")
            --game.print(key)
            --game.print(entity.position)
            --game.print(entity)
            
            if (game.surfaces["arrakis"].get_pollution(entity.position)) > config.MINIMUM_POLLUTION_FOR_OPERATION then
                entity.disabled_by_script = false
                entity.custom_status = {
                    diode = defines.entity_status_diode.green,
                    label = {"entity-status.working"}
                }
            else
                entity.disabled_by_script = true
                entity.custom_status = {
                    diode = defines.entity_status_diode.red,
                    label = {"arrakis-tooltip.no-moisture"}
                }

            end        
        end
    end
end)




--On every update check if its night on arrakis, if it is generate humidity in all generated chunks
script.on_nth_tick(ticks, function()
    local arrakis_night = false
    --Check if Arrakis even exists
    if game.surfaces["arrakis"] then
        local arrakis_time = game.surfaces["arrakis"].daytime
        --Check if it is nighttime on arrakis
        if (arrakis_time > 0.29) and (arrakis_time < 0.71) then
            arrakis_night = true
            -- When nighttime add pollution to generated chunk-------------------------------------------------------------------------------------
            for chunk in game.surfaces["arrakis"].get_chunks() do
                -- game.print("x: " .. chunk.x .. ", y: " .. chunk.y)
                -- game.print("area: " .. serpent.line(chunk.area))
                -- game.print("test: " .. chunk.area.left_top.x)
                if game.surfaces["arrakis"].get_pollution({chunk.area.left_top.x, chunk.area.left_top.y}) < config.MAX_POLLUTION_PER_NIGHT then
                    game.surfaces["arrakis"].pollute({chunk.area.left_top.x, chunk.area.left_top.y}, config.ADDED_POLLUTION_PER_CHUNK, humidity)
                end
            end
        end


            -- Disable dew collectors if it is not nighttime---------------------------------------------------------------------------------------
        for key, entity in pairs(game.surfaces["arrakis"].find_entities_filtered({name="dew-collector"})) do
            if not arrakis_night then
                entity.disabled_by_script = true
                entity.custom_status = {
                    diode = defines.entity_status_diode.red,
                    label = {"arrakis-tooltip.too-hot"}
                }
            else
                entity.disabled_by_script = false
                entity.custom_status = {
                    diode = defines.entity_status_diode.green,
                    label = {"entity-status.working"}
                }
            end
        end






    end
end)











