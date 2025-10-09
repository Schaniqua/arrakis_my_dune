local TICK_LOOP = 50
-- spice blow scan building script logic
local spice_blow_amount = {
    type = "virtual",
    name = "spice-blow-amount",
    quality = "normal",
    comparator = "="
}
local zone_box_blue = {
    type = "virtual",
    name = "zone-box-blue",
    quality = "normal",
    comparator = "="
}

-- call function on every build event, player and robot
-- first check if storage table is ready and if data object is ready
-- then insert built spice-scanner entity into table
local function scanning(event)
    -- table definition to track used colors
    storage.AAI_ZONES = storage.AAI_ZONES or {
        ["zone-box-blue"] = {
            used = false,
            reference_position = {}
        },
        ["zone-box-cyan"] = {
            used = false,
            reference_position = {}
        },
        ["zone-box-green"] = {
            used = false,
            reference_position = {}
        },
        ["zone-box-magenta"] = {
            used = false,
            reference_position = {}
        },
        ["zone-box-olive"] = {
            used = false,
            reference_position = {}
        },
        ["zone-box-orange"] = {
            used = false,
            reference_position = {}
        },
        ["zone-box-purple"] = {
            used = false,
            reference_position = {}
        },
        ["zone-box-red"] = {
            used = false,
            reference_position = {}
        },
        ["zone-box-teal"] = {
            used = false,
            reference_position = {}
        },
        ["zone-box-white"] = {
            used = false,
            reference_position = {}
        },
        ["zone-box-yellow"] = {
            used = false,
            reference_position = {}
        }
    }
    local entity = event.created_entity or event.entity
    if entity.name == "spice_scanner" then
        entity.combinator_description = "info.spice-scanner-groupinfo"
        storage.arrakis_spice_scanners = storage.arrakis_spice_scanners or {}
        table.insert(storage.arrakis_spice_scanners, entity)
    end
end


local function remove_scanner(entity, i)
    entity.destroy()
    table.remove(storage.arrakis_spice_scanners, i)
end


-- call on player built
script.on_event(defines.events.on_built_entity, scanning)
-- call on on robot built
script.on_event(defines.events.on_robot_built_entity, scanning)

script.on_nth_tick(TICK_LOOP, function()
    -- stop event loop immediately if storage table is empty
    if not storage.arrakis_spice_scanners then return end
    for i = #storage.arrakis_spice_scanners, 1, -1 do
        -- try to read spice scanner table entry, remove entity and table entry if not OK
        local spice_scanner = storage.arrakis_spice_scanners[i]
        if not spice_scanner.valid then
            remove_scanner(spice_scanner, i)
            goto EOL
        end
        -- try to read spice scanner control_behavior, remove entity and table entry if not OK
        local control_behavior = spice_scanner.get_or_create_control_behavior()
        if not control_behavior then
            remove_scanner(spice_scanner, i)
            goto EOL
        end

        -- make changes to the logi_section of the combinator to output signals on the circuit network
        logi_section = control_behavior.get_section(1)
        logi_section.set_slot(1, {
            value = spice_blow_amount,
            min = #storage.arrakis_spice_blows
        })

        -- translate group info for localisation, needs to capture the fired event but i cant be assed right now
        -- local translated_text = spice_scanner.last_user.request_translation({"info.spice-scanner-groupinfo"})
        logi_section.group = "SPICE SCANNER SIGNAL OUTPUT"

        -- remove all existing signals not active
        for i = 2, logi_section.filters_count do logi_section.clear_slot(i) end

        -- this is the actual scanning logic
        if not storage.AAI_ZONES then goto EOL end

        local entity_pos = spice_scanner.position
        local distances = {}

        -- collect all used zones with their distances
        for tile_name, data in pairs(storage.AAI_ZONES) do
            if data.used and data.reference_position then
                local dx = data.reference_position.x - entity_pos.x
                local dy = data.reference_position.y - entity_pos.y
                local dist = math.sqrt(dx * dx + dy * dy)
                table.insert(distances, {
                    tile = tile_name,
                    distance = dist
                })
            end
        end

        if #distances == 0 then return end

        -- find min and max distances for normalization
        local min_dist, max_dist = distances[1].distance, distances[1].distance
        for _, d in ipairs(distances) do
            if d.distance < min_dist then min_dist = d.distance end
            if d.distance > max_dist then max_dist = d.distance end
        end

        -- avoid divide by zero (if all same distance)
        local range = math.max(1, max_dist - min_dist)

        -- normalize to 0–100 range
        for _, d in ipairs(distances) do
            local normalized = (d.distance - min_dist) / range
            d.signal_strength = math.floor((1 - normalized) * 99) + 1
        end

        -- sort by distance (so nearest appear leftmost)
        table.sort(distances, function(a, b) return a.distance < b.distance end
)

        -- write to combinator slots
        game.print("tracked distances: " .. #distances)
        local section = control_behavior.get_section(1)
        for i, data in ipairs(distances) do

            logi_section.set_slot((1 + i), {
                value = {
                    type = "virtual",
                    name = data.tile,
                    quality = "normal",
                    comparator = "="
                },
                min = data.signal_strength
            })
        end

        ::EOL:: -- jump to End Of Loop, dont come @ me because i use loops
    end

end
)
