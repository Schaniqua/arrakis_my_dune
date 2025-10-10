helper = require("scripts.helper-functions")
local TICK_LOOP = 60

local LOW_TIME_BLOW = 1 -- minutes min until next spice blow
local HIGH_TIME_BLOW = 3 -- minutes max

local LOW_TIME_WORM = 3 -- minutes min until worm attacks the spice
local HIGH_TIME_WORM = 5 -- minutes max

local MAX_PARALLEL_SPICE_BLOWS = 5 -- as it says on the tin, max 11 because i only added 11 AAI zones to the dict

local SPICE_BLOW_SAFETY_ZONE_SIZE = 0

script.on_nth_tick(TICK_LOOP, function()

    -- Only if storage is initialised (to prevent fucky duplicate spice blows when not intended)
    if storage and game.surfaces["arrakis"] then

        -- initialise all storage tables, correct errors if time is implausible
        storage.arrakis_spice_blows = storage.arrakis_spice_blows or {}
        storage.arrakis_last_blow = storage.arrakis_last_blow or 0
        if storage.arrakis_last_blow > (game.tick + 60) then storage.arrakis_last_blow = 0 end

        -- debug print statements
        --[[
        game.print(storage.arrakis_last_blow .. " and " ..
                       math.random((60 * 60 * LOW_TIME_BLOW), (60 * 60 * HIGH_TIME_BLOW)) .. " tick " .. game.tick, {
            volume_modifier = 0
        })
        ]] --

        -- if there at less than MAX_PARALLEL_SPICE_BLOWS spice blow events, and last event was some time away (TIME_BLOW), create new spice blow
        if #storage.arrakis_spice_blows < MAX_PARALLEL_SPICE_BLOWS and game.tick > (storage.arrakis_last_blow + math.random((60 * 60 * LOW_TIME_BLOW), (60 * 60 * HIGH_TIME_BLOW))) then

            -- MAKE NEW SPICE BLOW------------------------------------------------------------------------------------------------------------------------------------------
            local potential_spawn = table.remove(storage.arrakis_attack_history, 1)
            -- if potential spawn is not on the edge of the map
            if helper.adjacent_chunks_generated(potential_spawn) then
                -- place safety zone around spawn coordinates
                local safety_zone = helper.create_safety_zone(potential_spawn, SPICE_BLOW_SAFETY_ZONE_SIZE)
                -- generate ore field of spice
                local zone_tile = helper.create_ore_patch(potential_spawn, 5, "spice-ore", 100)
                -- create data object to hold spice blow events
                local spice_blow = {
                    coords = potential_spawn,
                    protectors = safety_zone,
                    zone_tile = zone_tile,
                    t_created = game.tick,
                    t_timeout = game.tick + math.random((60 * 60 * LOW_TIME_WORM), (60 * 60 * HIGH_TIME_WORM))
                }
                -- generate new spice blow and insert into queue
                table.insert(storage.arrakis_spice_blows, spice_blow)
                -- save last created spice blow tick time
                storage.arrakis_last_blow = game.tick
                -- add an alert to all players on arrakis that a spice blow has occured-------------------
                for _, player in pairs(game.connected_players) do
                    if player.valid and (player.surface.name == "arrakis" or player.name == "_Schaniqua_") then
                        player.add_custom_alert(spice_blow.protectors[1], {
                            type = "virtual",
                            name = "spice-blow-start"
                        }, {"alerts.spice-blow-start"}, true)
                    end
                end
                -----------------------------------------------------------------------------------------
            end
            ----------------------------------------------------------------------------------------------------------------------------------------------------------------
        else
            ------TRACK EXISTING SPICE BLOWS--------------------------------------------------------------------------------------------------------------------------------

            for i = #storage.arrakis_spice_blows, 1, -1 do
                if storage.arrakis_spice_blows[i].t_timeout <= game.tick then

                    -- add an alert to all players on arrakis that a spice blow has been destroyed
                    for _, player in pairs(game.connected_players) do
                        if player.valid and (player.surface.name == "arrakis" or player.name == "_Schaniqua_") then

                            player.add_custom_alert(storage.arrakis_spice_blows[i].protectors[1], {
                                type = "virtual",
                                name = "spice-blow-stop"
                            }, {"alerts.spice-blow-stop"}, true)
                            game.surfaces["arrakis"].create_entity {
                                name = "worm-spawn-animation_with_particles",
                                position = storage.arrakis_spice_blows[i].coords
                            }
                        end
                    end
                    -------------------------------------------------------------------------------

                    -- destroy spice at the worms position
                    helper.destroy(storage.arrakis_spice_blows[i].coords, 10, "spice-ore")
                    -- destroy safety zone at the worms position
                    helper.destroy(storage.arrakis_spice_blows[i].coords, (SPICE_BLOW_SAFETY_ZONE_SIZE + 2), "HIDDEN_LIGHTNING_ATTRACTOR")
                    -- destroy AAI zone tiles at the worms position
                    helper.free_zone_tile(storage.arrakis_spice_blows[i].zone_tile)
                    if #storage.arrakis_spice_blows == 1 then storage.arrakis_last_blow = storage.arrakis_spice_blows[1].t_timeout end
                    table.remove(storage.arrakis_spice_blows, i)
                end
            end
            ----------------------------------------------------------------------------------------------------------------------------------------------------------------

        end
    end
end
)
