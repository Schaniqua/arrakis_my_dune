local helper = {}

-- helper function for freeing aai zone tile
function helper.free_zone_tile(tile_name)
    if not tile_name then return end
    for _, zone_tile_pos in ipairs(storage.AAI_ZONES[tile_name].references) do
        if zone_tile_pos and zone_tile_pos.x and zone_tile_pos.y then
            local data = {}
            data.surface_index = game.surfaces["arrakis"].index
            data.force = game.forces["player"]
            data.area = {
                left_top = {
                    x = zone_tile_pos.x,
                    y = zone_tile_pos.y
                },
                right_bottom = {
                    x = zone_tile_pos.x,
                    y = zone_tile_pos.y
                }
            }
            remote.call("aai-zones","apply_zone_to_area", data)
        end
    end
    storage.AAI_ZONES[tile_name].used = false
    storage.AAI_ZONES[tile_name].references = {}
end


-- helper function for creating a ore patch on the spice blow location
function helper.create_ore_patch(pos, size, ore, amount)
    local patch_size = size or 5
    local ore = ore or "spice-ore"
    local base_amount = amount or 200
    local zone_tile_to_apply
    local reference_tiles

    storage.AAI_ZONES = storage.AAI_ZONES or {
        ["zone-box-blue"] = {
            used = false,
            references = {}
        },
        ["zone-box-cyan"] = {
            used = false,
            references = {}
        },
        ["zone-box-green"] = {
            used = false,
            references = {}
        },
        ["zone-box-magenta"] = {
            used = false,
            references = {}
        },
        ["zone-box-olive"] = {
            used = false,
            references = {}
        },
        ["zone-box-orange"] = {
            used = false,
            references = {}
        },
        ["zone-box-purple"] = {
            used = false,
            references = {}
        },
        ["zone-box-red"] = {
            used = false,
            references = {}
        },
        ["zone-box-teal"] = {
            used = false,
            references = {}
        },
        ["zone-box-white"] = {
            used = false,
            references = {}
        },
        ["zone-box-yellow"] = {
            used = false,
            references = {}
        }
    }

    if ore == "spice-ore" then
        for tile_name, data in pairs(storage.AAI_ZONES) do
            if not data.used then
                data.used = true
                zone_tile_to_apply = tile_name
                break
            end
        end
    end

    reference_tiles = {}
    for dx = -patch_size, patch_size do
        for dy = -patch_size, patch_size do
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance <= patch_size and math.random() < 1 - (distance / patch_size) then
                game.surfaces["arrakis"].create_entity {
                    name = ore,
                    amount = base_amount * (0.5 + math.random()),
                    force = "neutral",
                    position = {pos.x + dx, pos.y + dy}
                }
                if ore == "spice-ore" then
                    local data = {}
                    local pos = {
                        x = pos.x + dx,
                        y = pos.y + dy
                    }
                    data.surface_index = game.surfaces["arrakis"].index
                    data.force = game.forces["player"]
                    data.type = zone_tile_to_apply
                    data.area = {
                        left_top = pos,
                        right_bottom = pos
                    }
                    remote.call("aai-zones","apply_zone_to_area", data)
                    table.insert(reference_tiles, pos)

                end
            end
        end
    end
    if ore == "spice-ore" then
        storage.AAI_ZONES[zone_tile_to_apply].references = reference_tiles
        return zone_tile_to_apply
    end
end


-- helper function for placing safety zone around designated coordinate
function helper.create_safety_zone(pos, size)
    local zone_size = size or 3
    local created_entities = {}
    local entity = "HIDDEN_LIGHTNING_ATTRACTOR"
    -- handle size = 0
    if zone_size == 0 then
        -- Just place one attractor in the center
        local ent = game.surfaces["arrakis"].create_entity {
            name = entity,
            position = pos
        }
        table.insert(created_entities, ent)
        return created_entities
    end

    -- Offsets for the 4 directions
    local offsets = {{
        x = zone_size,
        y = 0
    }, {
        x = -zone_size,
        y = 0
    }, {
        x = 0,
        y = zone_size
    }, {
        x = 0,
        y = -zone_size
    }}

    -- place and return created entities
    for _, offset in pairs(offsets) do
        local ent = game.surfaces["arrakis"].create_entity {
            name = entity,
            position = {pos.x + offset.x, pos.y + offset.y}
        }
        table.insert(created_entities, ent)
    end

    return created_entities
end


-- helper function for destroying ore patch
function helper.destroy(pos, radius, filter)
    local radius = radius or 10
    local entities = game.surfaces["arrakis"].find_entities_filtered {
        area = {{pos.x - radius, pos.y - radius}, {pos.x + radius, pos.y + radius}},
        name = filter
    }

    for _, entity in pairs(entities) do entity.destroy() end
end


-- helper function to check if adjecent chunks are generated so i dont place spice blows in the black map zone
function helper.adjacent_chunks_generated(pos)
    local cx = math.floor(pos.x / 32)
    local cy = math.floor(pos.y / 32)
    local offsets = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}}

    for _, o in pairs(offsets) do if not game.surfaces["arrakis"].is_chunk_generated({cx + o[1], cy + o[2]}) then return false end end
    return true
end


return helper
