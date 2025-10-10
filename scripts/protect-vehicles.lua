require("scripts.helper-functions")
local TICK_LOOP = 30

local MIN_SPEED_FOR_TARGET = 0.01

local vehicle_protectors = {}
function out_of_range(x, spd) return x < -(spd) or x > spd end


script.on_nth_tick(TICK_LOOP, function()
    -- if storage is initialised
    if storage and game.surfaces["arrakis"] then

        -- find every instance of vehicle by type
        local vehicles = game.surfaces["arrakis"].find_entities_filtered {
            type = {"car", "spider-vehicle"}
        }

        -- for each existing vehicle on the surface of arrakis
        for _, vehicle in ipairs(vehicles) do
            -- if vehicle is valid data object
            if vehicle.valid then
                -- disable lightning protection if vehicle is standing
                if vehicle_protectors[vehicle.unit_number] and not out_of_range(vehicle.speed, MIN_SPEED_FOR_TARGET) then
                    local lightning_protector_unit_number = vehicle_protectors[vehicle.unit_number]
                    local target = game.get_entity_by_unit_number(lightning_protector_unit_number)
                    if target and target.valid then target.destroy() end

                else
                    -- if vehicle has entry teleport the existing protector with it
                    if vehicle_protectors[vehicle.unit_number] then
                        local lightning_protector = game.get_entity_by_unit_number(vehicle_protectors[vehicle.unit_number])
                        -- if vehicle is valid and has accompanying lightning protector teleport it after the vehicle
                        if lightning_protector and lightning_protector.valid then
                            lightning_protector.teleport(vehicle.position)
                        -- else create a new lightning protector in the already existing storage slot
                        else
                            local new = game.surfaces["arrakis"].create_entity {
                                name = "HIDDEN_LIGHTNING_ATTRACTOR",
                                position = vehicle.position,
                                force = vehicle.force
                            }
                            new.destructible = false
                            -- assign new lightning protector to vehicle
                            vehicle_protectors[vehicle.unit_number] = new.unit_number
                        end
                    -- if vehicle doesnt have entry create new lightning protector
                    else
                        local new = game.surfaces["arrakis"].create_entity {
                            name = "HIDDEN_LIGHTNING_ATTRACTOR",
                            position = vehicle.position,
                            force = vehicle.force
                        }
                        new.destructible = false
                        -- assign new lightning protector to vehicle
                        vehicle_protectors[vehicle.unit_number] = new.unit_number
                    end
                end
                -- cleanup of stale references in storage
                for vehicle_unit_number, attractor_unit_number in pairs(vehicle_protectors) do
                    local vehicle = game.get_entity_by_unit_number(vehicle_unit_number)
                    local attractor = game.get_entity_by_unit_number(attractor_unit_number)

                    -- If the vehicle no longer exists, destroy its attractor and remove the mapping
                    if (not vehicle) or (not vehicle.valid) then
                        if attractor and attractor.valid then attractor.destroy() end
                        vehicle_protectors[vehicle_unit_number] = nil
                    end
                end
            end
        end
    end
end
)
