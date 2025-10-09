local TICK_LOOP_SPICE = 50
local TICK_LOOP_SEISMIC = 50


local spice_blow_amount = {
    type = "virtual",
    name = "spice-blow-amount",
    quality = "normal",
    comparator = "="
}

-- this function handles built events for the mod entities
local function built_event(event)
    local entity = event.created_entity or event.entity
    -- handler for each scanner built event
    local handlers = {
        -- handle spice_scanner built
        spice_scanner = function()
            storage.arrakis_spice_scanners = storage.arrakis_spice_scanners or {}
            table.insert(storage.arrakis_spice_scanners, entity)
        end
,
        -- handle seismic_scanner built
        seismic_scanner = function()
            storage.arrakis_seismic_scanners = storage.arrakis_seismic_scanners or {}
            table.insert(storage.arrakis_seismic_scanners, entity)
        end

    }

    -- Execute handler for built entity if handler exists
    local handler = handlers[entity.name]
    if handler then handler() end
end


-- remove scanner entity and table entry
local function remove_scanner(entity, i)
    entity.destroy()
    table.remove(storage.arrakis_spice_scanners, i)
end


-- call when player built and when robot built
script.on_event(defines.events.on_built_entity, built_event, {{
    filter = "name",
    name = "spice_scanner"
}, {
    filter = "name",
    name = "seismic_scanner"
}})
script.on_event(defines.events.on_robot_built_entity, built_event, {{
    filter = "name",
    name = "spice_scanner"
}, {
    filter = "name",
    name = "seismic_scanner"
}})

-- processing loop for spice scanner logic
script.on_nth_tick(TICK_LOOP_SPICE, function()
    -- stop event loop immediately if storage table is empty
    if not storage.arrakis_spice_scanners then return end
    -- go through storage table in reverse order
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

        -- make changes to the logi_section of the combinator to output number of active spice blows in a logi group
        logi_section = control_behavior.get_section(1)
        logi_section.group = "SIGNAL OUTPUT"
        logi_section.set_slot(1, {
            value = spice_blow_amount,
            min = #storage.arrakis_spice_blows
        })

        -- remove existing signals except the first one (number of active spice blows)
        for i = 2, logi_section.filters_count do logi_section.clear_slot(i) end

        -- this is the actual scanning logic ------------------------------------------------------------------------
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
        table.sort(distances, function(a, b) return a.distance < b.distance end)

        -- populate logi group with active spice blows as virtual signals, signal value is 1-100 distance from scanner to spice blow
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


-- processing loop for seismic scanner logic
script.on_nth_tick(TICK_LOOP_SEISMIC, function()
    -- stop event loop immediately if storage table is empty
    if not storage.arrakis_seismic_scanners then return end
    -- go through storage table in reverse order
    for i = #storage.arrakis_seismic_scanners, 1, -1 do
        -- try to read spice scanner table entry, remove entity and table entry if not OK
        local spice_scanner = storage.arrakis_seismic_scanners[i]
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

        -- make changes to the logi_section of the combinator to output number of active spice blows in a logi group
        logi_section = control_behavior.get_section(1)
        logi_section.group = "SIGNAL OUTPUT"
        --logi_section.set_slot(1, {
        --    value = spice_blow_amount,
        --    min = #storage.arrakis_spice_blows
        --})

        -- remove existing signals except the first one (number of active spice blows)
        for i = 1, logi_section.filters_count do logi_section.clear_slot(i) end

        -- this is the actual scanning logic ------------------------------------------------------------------------
        --if not storage.AAI_ZONES then goto EOL end

        

        ::EOL:: -- jump to End Of Loop, dont come @ me because i use loops

    end
end
)