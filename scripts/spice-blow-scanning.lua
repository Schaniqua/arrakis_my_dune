local TICK_LOOP_SPICE = 120 -- ticks
local TICK_LOOP_SEISMIC = 90 -- ticks
local TICK_LOOP_ZONE_TILE_CHECK = 300 -- ticks

local DETECTION_RADIUS = 40 -- tiles
local WARNING_TIME = 60 -- seconds

local spice_blow_amount = {
    type = "virtual",
    name = "spice-blow-start",
    quality = "normal",
    comparator = "="
}

local spice_blow_danger = {
    type = "virtual",
    name = "spice-blow-stop",
    quality = "normal",
    comparator = "="
}

-- calculate distance
local function distance(pos1, pos2)
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    return math.sqrt(dx * dx + dy * dy)
end


-- this function handles built events for the mod entities
local function built_event(event)
    local entity = event.created_entity or event.entity
    -- handler for each scanner built event
    local handlers = {
        -- handle spice_scanner built
        spice_scanner = function()
            storage.arrakis_spice_scanners = storage.arrakis_spice_scanners or {}
            table.insert(storage.arrakis_spice_scanners, entity.unit_number)
        end
,
        -- handle seismic_scanner built
        seismic_scanner = function()
            storage.arrakis_seismic_scanners = storage.arrakis_seismic_scanners or {}
            table.insert(storage.arrakis_seismic_scanners, entity.unit_number)
        end


    }
    -- Execute handler for built entity if handler exists
    local handler = handlers[entity.name]
    if handler then handler() end
end


-- define on-event player built and robot built
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

-- removes zone tiles over ore entities that have been mined
script.on_event(defines.events.on_resource_depleted, function(event)
    local entity = event.entity
    if entity.name == "spice-ore" then
        local data = {}
        data.surface_index = game.surfaces["arrakis"].index
        data.force = game.forces["player"]
        data.area = {
            left_top = {
                x = entity.position.x,
                y = entity.position.y
            },
            right_bottom = {
                x = entity.position.x,
                y = entity.position.y
            }
        }
        remote.call("aai-zones", "apply_zone_to_area", data)
    end
end
)

-- processing loop for spice scanner logic
script.on_nth_tick(TICK_LOOP_SPICE, function()
    -- stop event loop immediately if storage table is empty
    if not storage.arrakis_spice_scanners then return end
    -- go through storage table in reverse order
    for i = #storage.arrakis_spice_scanners, 1, -1 do
        -- try to read spice scanner table entry, remove entity and table entry if not OK
        local spice_scanner = game.get_entity_by_unit_number(storage.arrakis_spice_scanners[i])
        if not spice_scanner or not spice_scanner.valid then
            table.remove(storage.arrakis_spice_scanners, i)
            goto EOL
        end
        -- try to read spice scanner control_behavior, remove entity and table entry if not OK
        local control_behavior = spice_scanner.get_or_create_control_behavior()
        if not control_behavior then
            table.remove(storage.arrakis_spice_scanners, i)
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
            if data.used and data.references then
                local dist = distance(data.references[1], entity_pos)
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
            d.signal_strength = math.floor((1 - normalized) * 50) + 50
        end

        -- sort by distance (so nearest appear leftmost)
        table.sort(distances, function(a, b) return a.distance < b.distance end
)

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

        ::EOL:: -- jump to End Of Loop, dont come @ me because i use goto

    end
end
)

local function get_signal_count(signals, sig_name)
    if not signals then return nil end
    for _, entry in pairs(signals) do
        local sig = entry.signal
        if sig and sig.name == sig_name then return entry.count end
    end
    return nil
end


-- processing loop for seismic scanner logic
script.on_nth_tick(TICK_LOOP_SEISMIC, function()
    -- stop event loop immediately if storage table is empty
    if not storage.arrakis_seismic_scanners then return end
    -- go through storage table in reverse order
    for i = #storage.arrakis_seismic_scanners, 1, -1 do
        -- try to read spice scanner table entry, remove entity and table entry if not OK
        local seismic_scanner = game.get_entity_by_unit_number(storage.arrakis_seismic_scanners[i])
        if not seismic_scanner or not seismic_scanner.valid then
            table.remove(storage.arrakis_seismic_scanners, i)
            goto EOL
        end
        -- try to read spice scanner control_behavior, remove entity and table entry if not OK
        local control_behavior = seismic_scanner.get_or_create_control_behavior()
        if not control_behavior then
            table.remove(storage.arrakis_seismic_scanners, i)
            goto EOL
        end

        -- make changes to the logi_section of the combinator to output number of active spice blows in a logi group
        logi_section = control_behavior.get_section(1)
        -- logi_section.group = "SIGNAL OUTPUT" DO NOT WRITE SAME SIGNAL GROUP TO MULTIPLE SEISMIC SENSORS -> many problems
        -- logi_section.set_slot(1, {
        --    value = spice_blow_amount,
        --    min = #storage.arrakis_spice_blows
        -- })

        -- remove existing signals except the first one (number of active spice blows)
        for i = 1, logi_section.filters_count do logi_section.clear_slot(i) end

        -- this is the actual scanning logic ------------------------------------------------------------------------

        -- read vehicle ID from circuit network
        local UNIT_ID
        local INPUT_SIGNALS = seismic_scanner.get_signals(defines.wire_connector_id.combinator_input_red, defines.wire_connector_id.combinator_input_green)
        if INPUT_SIGNALS then
            UNIT_ID = get_signal_count(INPUT_SIGNALS, "signal-id")
        else
            goto EOL
        end

        local max_danger = 0
        local data = {}
        data.surface_index = game.surfaces["arrakis"].index
        data.signal_count = {
            signal = {
                type = "virtual",
                name = "signal-id"
            },
            count = UNIT_ID
        }
        local AAI_UNIT = remote.call("aai-programmable-vehicles", "get_unit_by_signal", data)

        if AAI_UNIT then
            for i, spice_blow in ipairs(storage.arrakis_spice_blows) do
                local t_remaining = spice_blow.t_timeout - game.tick
                local t_remaining_sec = t_remaining / 60
                if t_remaining_sec > 0 and t_remaining_sec <= WARNING_TIME then
                    local dist = distance(AAI_UNIT.position, spice_blow.coords)
                    if dist <= DETECTION_RADIUS then
                        -- linear scale: 20s -> 0 danger, 0s -> 100 danger
                        local danger = 100 * (1 - (t_remaining_sec / WARNING_TIME))
                        if danger > max_danger then max_danger = danger end
                    end
                end
            end
            -- logi_section.group = "SIGNAL OUTPUT" no group here, group will sync between combinators, we dont want that
            logi_section.set_slot(1, {
                value = {
                    type = "virtual",
                    name = "signal-A",
                    quality = "normal",
                    comparator = "="
                },
                min = max_danger
            })

            local colors = {
                ["signal-red"] = {
                    amount = 0,
                    slot = 2
                },
                ["signal-green"] = {
                    amount = 0,
                    slot = 3
                }
            }
            colors["signal-red"].amount   = math.min(255, 255 * (max_danger / 50))
            colors["signal-green"].amount = math.min(255, math.max(0, 255 * (1 - ((max_danger - 50) / 50))))

            for color, data in pairs(colors) do
                if data.amount == 0 then
                    logi_section.clear_slot(data.slot)
                else
                    logi_section.set_slot(data.slot, {
                        value = {
                            type = "virtual",
                            name = color,
                            quality = "normal",
                            comparator = "="
                        },
                        min = data.amount
                    })
                end

            end

        end

        ::EOL:: -- jump to End Of Loop, dont come @ me because i use goto
    end
end
)

