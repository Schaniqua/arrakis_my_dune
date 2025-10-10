data:extend(
  -- only difference between these two prototypes is where they are used and whether they are indexed into .unit_number
{{
    type = "lightning-attractor",
    name = "HIDDEN_LIGHTNING_ATTRACTOR",
    efficiency = 0,
    range_elongation = 22.0,
    icon = "__core__/graphics/empty.png",
    flags = {"not-on-map","placeable-off-grid","not-repairable","not-blueprintable","not-deconstructable","not-flammable","not-selectable-in-game","not-upgradable","get-by-unit-number"},
    max_health = 999999,
    collision_box = nil,
    collision_mask = { layers = {} },
    selection_box = nil,
    lightning_strike_offset = {0, -4.1},
  }})