-- prototype definition for seismic_scanner building
local seismic_scanner = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
seismic_scanner.name = "seismic-sensor"
seismic_scanner.icon = "__base__/graphics/icons/constant-combinator.png"
seismic_scanner.minable = {
    mining_time = 0.1,
    result = "seismic-sensor"
}
seismic_scanner.alert_icon_scale = 0


-- prototype definition for seismic_scanner item
local seismic_scanner_item = table.deepcopy(data.raw["item"]["constant-combinator"])
seismic_scanner_item.name = "seismic-sensor"
seismic_scanner_item.place_result = "seismic-sensor"
seismic_scanner_item.icon = icons .. "spice-blow-start.png"
seismic_scanner_item.subgroup = "arrakis-processes"

data:extend({seismic_scanner, seismic_scanner_item})