mod = "__arrakis_my_dune__"
icons = "__arrakis_my_dune__/graphics/icons/"

-- add this to recipe/entity surface_conditions
--arrakis_exlusive = {{ property = "temperature-celcius", min = 77, max = 77}},

-- require virtual signals for alerts, icons usw.
require "prototypes.sandworms.virtual-signals"
require "prototypes.sandworms.seismic-scanner"
require "prototypes.sandworms.spice-scanner"

--Planet and Environment Prototypes
require "prototypes.planet.planet-arrakis-map-gen"
require "prototypes.planet.planet-map-gen"
require "prototypes.planet.tiles"
require "prototypes.planet.planet"
require "prototypes.decoratives"
require "prototypes.resources"
require "prototypes.chunk-humidity"
--require "prototypes.music"    -- The music Prototype is commented out because the files are missing


--Technology/Recipe/Item Prototypes
require "prototypes.technology"
require "prototypes.items"
require "prototypes.recipes"


--Enemy Prototypes
require "prototypes.sandworms.worm-targeting"
require "prototypes.sandworms.attack"
require "prototypes.sandworms.worm-protection"


-- spice prototypes
require "prototypes.spice.spice-ore"


--Machine Prototypes
require "prototypes.machines.dew-collector"
require "prototypes.machines.water-condenser"
require "prototypes.machines.sand-refinery"
require "prototypes.machines.basic-sand-refinery"
require "prototypes.machines.sand-collector"
require "prototypes.machines.water-purification-facility"

--Vehicle Prototypes
require("prototypes.vehicle.ornithopter")