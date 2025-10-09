script.on_event(defines.events.on_chunk_generated, function(event)
    local area = event.area
    local surface = event.surface
    -- if not arrakis stop immediately
    if (surface.name == "arrakis") then
        -- scan every 8th tile in a grid on the map (non overlapping)
        -- i thought this solution was naive and absolute ass but it works wayyyyy better than i expected
        for x = (area.left_top.x + 4), area.right_bottom.x - 5, 8 do
            for y = (area.left_top.y + 4), area.right_bottom.y - 5, 8 do
                local tile = surface.get_tile(x, y)
                -- if tile is rock plateau
                if tile.name == "arrakis-rocky-plateau" then
                    -- place invisible & intangible lightning attractor on it to protect machines built there
                    surface.create_entity{name="HIDDEN_LIGHTNING_ATTRACTOR", position={x,y}}         
                end
            end
        end
    end
end)