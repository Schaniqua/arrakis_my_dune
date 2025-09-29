data:extend({
  {
    type = "resource-category",
    name = "spice-ore"
  }
})

local spice_ore = table.deepcopy(data.raw.resource["iron-ore"])

spice_ore.name = "spice-ore"
spice_ore.icons = {
  { icon = "__base__/graphics/icons/iron-ore.png", icon_size = 64, tint = {r=0.8,g=0,b=0.6} } -- placeholder because i am ass with graphics
}
spice_ore.minable.result = "iron-ore"   -- when mined, give regular iron-ore for now
spice_ore.autoplace = nil               -- don’t generate naturally
spice_ore.category = "spice-ore"            -- only let spice ore be mined by aai miners
spice_ore.infinite = false
spice_ore.order = "z[spice-ore]"

data:extend{spice_ore}