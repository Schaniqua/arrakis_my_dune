helper = require("scripts.helper-functions")

local LOW_TIME_BLOW = 70 -- minutes min until next spice blow
local HIGH_TIME_BLOW = 100 -- minutes max

local LOW_TIME_WORM = 30 -- minutes min until worm attacks the spice
local HIGH_TIME_WORM = 50 -- minutes max

local MAX_PARALLEL_SPICE_BLOWS = 5 -- as it says on the tin

script.on_nth_tick(60, function()

    -- Only if storage is initialised (to prevent fucky duplicate spice blows when not intended)
    if storage then

        storage.arrakis_spice_blows = storage.arrakis_spice_blows or {}

        game.print(helper.table_count(storage.arrakis_spice_blows), {
            volume_modifier = 0
        })

        -- if spice blows > 0 check if any are timed out, if so remove them from the queue
        if helper.table_count(storage.arrakis_spice_blows) > 0 then
            for i = #storage.arrakis_spice_blows, 1, -1 do
                if storage.arrakis_spice_blows[i].duration >= game.tick then

                    table.remove(storage.arrakis_spice_blows, i)

                    game.print("FOUND TIMED OUT", {
                        volume_modifier = 0
                    })

                end
            end

            -- add new spice blow
        else
            local potential_spawn = table.remove(storage.arrakis_attack_history, 1)
            -- if potential spawn is not on the edge of the map
            if helper.adjacent_chunks_generated(potential_spawn) then
                local spice_blow = {
                    coords = potential_spawn,
                    duration = game.tick + math.random((60 * 60 * LOW_TIME_WORM), (60 * 60 * HIGH_TIME_WORM))
                }
                -- generate new spice blow and insert into queue
                table.insert(storage.arrakis_spice_blows, spice_blow)
                -- generate ore field of spice
                helper.create_ore_patch(potential_spawn, 5, "spice-ore", 100)

                -- add an alert to all players on arrakis that a spice blow has occured
                for _, player in pairs(game.connected_players) do
                    if player.valid and (player.surface.name == "arrakis" or player.name == "_Schaniqua_") then
                        local alert_entity = game.surfaces["arrakis"].find_entities_filtered {
                            position = {potential_spawn.x, potential_spawn.y},
                            name = {"spice-ore"},
                            radius = 1
                        }
                        player.add_alert(alert_entity[1], defines.alert_type.unclaimed_cargo)
                    end
                end

            end

        end
    end
end)
