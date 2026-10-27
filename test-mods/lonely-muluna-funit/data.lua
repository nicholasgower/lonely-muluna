-- Data-stage entry point for the Lonely Muluna FUnit fixtures.
--
-- Data-stage checks cannot talk to the runtime FUnit scenario directly, so
-- they record their results in a mod-data prototype. The scenario converts
-- those entries into FUnit tests.

data:extend({
  {
    type = "mod-data",
    name = "lonely-muluna-funit-results",
    data = {
      -- [suite name][check id] = { ok = boolean, err = string|nil }
    },
  },
})

if settings.startup["lonely-muluna-funit-enable-data-fixtures"].value then
  local manifest = require("prototypes.fixtures.manifest")
  for _, fixture in ipairs(manifest.data or {}) do
    require("prototypes.fixtures." .. fixture)
  end
end
