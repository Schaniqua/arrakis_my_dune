-- gui handler with language localisation
script.on_event(defines.events.on_gui_opened, function(event)
    local player = game.get_player(event.player_index)
    local entity = event.entity
    if not player or not player.connected then return end
    if entity and entity.name == "spice_scanner" then
        local localised_info = {"info.spice-scanner-groupinfo"}
        local translation_id = player.request_translation(localised_info)
        storage.pending_translations = storage.pending_translations or {}
        storage.pending_translations[translation_id] = {
            entity = entity,
            player = event.player_index
        }
        if entity.combinator_description == "" then
            player.opened = nil
        end
    else 
        -- add other entities to localize at runtime here via elsif entity.name
    end
end)

script.on_event(defines.events.on_string_translated, function(event)
    local entity = storage.pending_translations and storage.pending_translations[event.id].entity
    local player = storage.pending_translations[event.id].player
    if entity and entity.valid and event.translated then
        if entity.name == "spice_scanner" then
            entity.combinator_description = event.result
            game.get_player(storage.pending_translations[event.id].player).opened = entity
        else
            game.print("wtf was just translated?: " .. event.result)
        end
    end
    if storage.pending_translations then storage.pending_translations[event.id] = nil end
end
)
