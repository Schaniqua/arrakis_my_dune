helper = require("scripts.helper-functions")

local LOW_TIME_BLOW = 1 -- minutes min until next spice blow
local HIGH_TIME_BLOW = 3 -- minutes max

local LOW_TIME_WORM = 1 -- minutes min until worm attacks the spice
local HIGH_TIME_WORM = 2 -- minutes max

local MAX_PARALLEL_SPICE_BLOWS = 1 -- as it says on the tin

script.on_nth_tick(60, function()

    -- Only if storage is initialised (to prevent fucky duplicate spice blows when not intended)
    if storage then

        storage.arrakis_spice_blows = storage.arrakis_spice_blows or {}
        storage.arrakis_last_blow = storage.arrakis_last_blow or 0
        if storage.arrakis_last_blow > (game.tick + 60) then
            storage.arrakis_last_blow = 0
        end
        game.print(#storage.arrakis_spice_blows, {
            volume_modifier = 0
        })
        game.print(storage.arrakis_last_blow .. " and " .. math.random((60 * 60 * LOW_TIME_BLOW), (60 * 60 * HIGH_TIME_BLOW)) .. " tick " .. game.tick, {
            volume_modifier = 0
        })

        -- if there at less than MAX_PARALLEL_SPICE_BLOWS spice blow events, and last event was some time away (TIME_BLOW), create new spice blow
        if #storage.arrakis_spice_blows < MAX_PARALLEL_SPICE_BLOWS and game.tick >
            (storage.arrakis_last_blow + math.random((60 * 60 * LOW_TIME_BLOW), (60 * 60 * HIGH_TIME_BLOW))) then

            -- MAKE NEW SPICE BLOW------------------------------------------------------------------------------------------------------------------------------------------
            local potential_spawn = table.remove(storage.arrakis_attack_history, 1)
            -- if potential spawn is not on the edge of the map
            if helper.adjacent_chunks_generated(potential_spawn) then
                local spice_blow = {
                    coords = potential_spawn,
                    t_created = game.tick,
                    t_timeout = game.tick + math.random((60 * 60 * LOW_TIME_WORM), (60 * 60 * HIGH_TIME_WORM))
                }
                -- generate new spice blow and insert into queue
                table.insert(storage.arrakis_spice_blows, spice_blow)
                -- generate ore field of spice
                helper.create_ore_patch(potential_spawn, 5, "spice-ore", 100)
                -- save last created spice blow tick time
                storage.arrakis_last_blow = game.tick
                -- add an alert to all players on arrakis that a spice blow has occured-------------------
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
                -----------------------------------------------------------------------------------------
            end
            ----------------------------------------------------------------------------------------------------------------------------------------------------------------
        else
            ------TRACK EXISTING SPICE BLOWS--------------------------------------------------------------------------------------------------------------------------------
            for i = #storage.arrakis_spice_blows, 1, -1 do
                if storage.arrakis_spice_blows[i].t_timeout <= game.tick then
                    



                    --[[ ALERT NOT YET WORKING
                    -- add an alert to all players on arrakis that a spice blow has been destroyed
                    for _, player in pairs(game.connected_players) do
                        if player.valid and (player.surface.name == "arrakis" or player.name == "_Schaniqua_") then
                            local alert_entity = game.surfaces["arrakis"].get_tile {
                                x = storage.arrakis_spice_blows[i].coords.x,
                                y = storage.arrakis_spice_blows[i].coords.y
                            }
                            player.add_alert(alert_entity, defines.alert_type.entity_destroyed)
                        end
                    end
                    -------------------------------------------------------------------------------
                    --]]

                    
                    if #storage.arrakis_spice_blows == 1 then
                        storage.arrakis_last_blow = storage.arrakis_spice_blows[1].t_timeout
                    end

                    table.remove(storage.arrakis_spice_blows, i)
                    
                    game.print("FOUND TIMED OUT", {
                        volume_modifier = 0
                    })

                end
            end
            ----------------------------------------------------------------------------------------------------------------------------------------------------------------

        end
    end
end)