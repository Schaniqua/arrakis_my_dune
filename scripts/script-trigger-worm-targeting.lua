helper = require("scripts.helper-functions")

-- Script-Trigger when lightning hits something this gets called and executed
script.on_event("on_script_trigger_effect", function(event)

    -- if random worm attack position got chosen
    if (event.effect_id == "script_trigger_worm_attack") then

        -- destroy spice at the worms position
        helper.destroy(event.target_position, 10, "spice-ore")

        -- track where the attack went
        if storage then
            table.insert(storage.arrakis_attack_history, event.target_position)
            while #storage.arrakis_attack_history > 50 do
                table.remove(storage.arrakis_attack_history, 1) -- remove the oldest value
            end
        end

        -- print attack location (debug)
        game.print("Attack was triggered on Arrakis at Coordinate X: " .. event.target_position.x .. " Y: " ..
                       event.target_position.y, {
            volume_modifier = 0
        })

    end
end)
