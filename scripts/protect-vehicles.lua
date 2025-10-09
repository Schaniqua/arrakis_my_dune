require("scripts.helper-functions")
local TICK_LOOP = 30

-- prototype names of protected vehicles
local protected_vehicles = {
    ["vehicle-miner"] = true,
    ["vehicle-miner-mk2"] = true,
    ["vehicle-miner-mk3"] = true,
    ["vehicle-miner-mk4"] = true,
    ["vehicle-miner-mk5"] = true,
    ["vehicle-miner-0"] = true,
    ["vehicle-miner-mk2-0"] = true,
    ["vehicle-miner-mk3-0"] = true,
    ["vehicle-miner-mk4-0"] = true,
    ["vehicle-miner-mk5-0"] = true
}

local MIN_SPEED_FOR_TARGET = 0.01

function out_of_range(x, spd)
    return x < -(spd) or x > spd
end

script.on_nth_tick(TICK_LOOP, function()
    -- if storage is initialised
    if storage and game.surfaces["arrakis"] then

        -- read or declare data object to hold vehicle lightning attractors
        storage.vehicle_protectors = storage.vehicle_protectors or {}
        -- iterate through all vehicles that need to be protected
        for name, _ in pairs(protected_vehicles) do
            -- find every instance of vehicle by name "name"
            local vehicles = game.surfaces["arrakis"].find_entities_filtered {
                name = name
            }
            -- for each existing vehicle on the surface of arrakis
            for _, vehicle in ipairs(vehicles) do
                -- if vehicle is valid data object
                if vehicle.valid and out_of_range(vehicle.speed, MIN_SPEED_FOR_TARGET) then
                    -- try to read if vehicle already has an entry in vehicle_protectors
                    local entry = storage.vehicle_protectors[vehicle.unit_number]
                    -- if vehicle has entry and entry is valid lightning attractor luaentity
                    if entry and entry.valid then
                        -- move existing lightning attractor with vehicle
                        entry.teleport(vehicle.position)
                    else
                        -- create new lightning attractor if vehicle has no valid existing attractor
                        game.print("neu")
                        local new = game.surfaces["arrakis"].create_entity {
                            name = "HIDDEN_LIGHTNING_ATTRACTOR",
                            position = vehicle.position,
                            force = vehicle.force
                        }
                        new.destructible = false
                        -- assign storage entry to new lightning attractor attached to vehicle
                        storage.vehicle_protectors[vehicle.unit_number] = new

                    end
                end
            end
        end

        -- if storage entry exists but its ID doesnt correspond to a valid car / miner remove the lightning attractor and destroy the entry
        -- also remove storage entry and lightning_attractor if speed is below MIN_SPEED_FOR_TARGET
        for unit_number, entity in pairs(storage.vehicle_protectors) do

            -- if referenced entity doesnt exist remove lightning attractor and entry
            if not game.get_entity_by_unit_number(unit_number) then
                storage.vehicle_protectors[unit_number].destroy()
                storage.vehicle_protectors[unit_number] = nil
            else
                -- if referenced entity isnt above MIN_SPEED_FOR_TARGET movespeed then remove attractor but leave entry intact so we dont need to search next time
                local unit_speed = game.get_entity_by_unit_number(unit_number).speed
                if not out_of_range(unit_speed, MIN_SPEED_FOR_TARGET) then
                    if storage.vehicle_protectors[unit_number].valid then
                        storage.vehicle_protectors[unit_number].destroy()
                        game.print("destroyer - current speed " .. unit_speed)
                    end
                end

            end
        end
    end
end)
