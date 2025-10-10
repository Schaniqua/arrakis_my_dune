-- prototype definition for spice_scanner building
local spice_scanner = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
spice_scanner.name = "spice_scanner"
spice_scanner.icon = "__base__/graphics/icons/constant-combinator.png"
spice_scanner.flags = {"get-by-unit-number"}
spice_scanner.minable = {
    mining_time = 0.1,
    result = "spice_scanner"
}
spice_scanner.alert_icon_scale = 0
--spice_scanner.selection_box = {{-0.0, -0.0}, {0.0, 0.0}},
spice_scanner.logistic_section_type = defines.logistic_section_type.circuit_controlled


-- prototype definition for spice_scanner item
local spice_scanner_item = table.deepcopy(data.raw["item"]["constant-combinator"])
spice_scanner_item.name = "spice_scanner"
spice_scanner_item.place_result = "spice_scanner"
spice_scanner_item.icon = icons .. "spice-blow-start.png"
spice_scanner_item.subgroup = "arrakis-processes"

data:extend({spice_scanner, spice_scanner_item})


