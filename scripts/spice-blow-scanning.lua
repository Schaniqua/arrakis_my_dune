local TICK_LOOP = 50
-- spice blow scan building script logic
local spice_blow_amount = {type = "virtual", name = "spice-blow-amount", quality="normal", comparator="="}

-- call function on every build event, player and robot
-- first check if storage table is ready and if data object is ready
-- then insert built spice-scanner entity into table
local function scanning(event)
    local entity = event.created_entity or event.entity
    if entity.name == "spice_scanner" then
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
        if not spice_scanner.valid then remove_scanner(spice_scanner, i) goto EOL end
        -- try to read spice scanner control_behavior, remove entity and table entry if not OK
        local control_behavior = spice_scanner.get_or_create_control_behavior()
        if not control_behavior then remove_scanner(spice_scanner, i) goto EOL end
        
        -- make changes to the logi_section of the combinator to output signals on the circuit network
        logi_section = control_behavior.get_section(1)
        logi_section.set_slot(1, {value = spice_blow_amount, min = #storage.arrakis_spice_blows})

        -- translate group info for localisation, needs to capture the fired event but i cant be assed right now
        --local translated_text = spice_scanner.last_user.request_translation({"info.spice-scanner-groupinfo"})
        logi_section.group = "SPICE SCANNER SIGNAL OUTPUT"


        ::EOL:: -- jump to End Of Loop, dont come @ me because i use loops
    end

end)