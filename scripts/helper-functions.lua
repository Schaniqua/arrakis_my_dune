local helper = {}

-- make sure not to use helper-functions before storage is initialized otherwise problems will ensue
local function check_defined_dict()
    storage.AAI_ZONES = storage.AAI_ZONES or {
        ["zone-box-blue"] = {
            used = false
        },
        ["zone-box-cyan"] = {
            used = false
        },
        ["zone-box-green"] = {
            used = false
        },
        ["zone-box-magenta"] = {
            used = false
        },
        ["zone-box-olive"] = {
            used = false
        },
        ["zone-box-orange"] = {
            used = false
        },
        ["zone-box-purple"] = {
            used = false
        },
        ["zone-box-red"] = {
            used = false
        },
        ["zone-box-teal"] = {
            used = false
        },
        ["zone-box-white"] = {
            used = false
        },
        ["zone-box-yellow"] = {
            used = false
        }
    }
end

function helper.free_zone_tile(entities)
    local tile_name = entities[1].name
    check_defined_dict()
    for _, ent in ipairs(entities) do
        if ent.valid then
            ent.destroy()
        end
    end
    storage.AAI_ZONES[tile_name].used = false
end

-- helper function for creating a ore patch on the spice blow location
function helper.create_ore_patch(pos, size, ore, amount)
    check_defined_dict()
    local patch_size = size or 5
    local ore = ore or "spice-ore"
    local base_amount = amount or 200

    local zone_tile_to_apply
    local zone_tiles = {}

    if ore == "spice-ore" then
        for tile_name, data in pairs(storage.AAI_ZONES) do
            if not data.used then
                data.used = true
                zone_tile_to_apply = tile_name
                break
            end
        end
    end
    
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
                    table.insert(zone_tiles, game.surfaces["arrakis"].create_entity {
                        name = zone_tile_to_apply,
                        force = "neutral",
                        position = {pos.x + dx, pos.y + dy}
                    })

                end
            end
        end
    end
    if ore == "spice-ore" then
        return zone_tiles
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

    for _, entity in pairs(entities) do
        entity.destroy()
    end
end

-- helper function to check if adjecent chunks are generated so i dont place spice blows in the black map zone
function helper.adjacent_chunks_generated(pos)
    local cx = math.floor(pos.x / 32)
    local cy = math.floor(pos.y / 32)
    local offsets = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}}

    for _, o in pairs(offsets) do
        if not game.surfaces["arrakis"].is_chunk_generated({cx + o[1], cy + o[2]}) then
            return false
        end
    end
    return true
end

return helper
