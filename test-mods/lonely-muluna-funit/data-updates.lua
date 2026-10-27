-- Data-updates fixtures for the Lonely Muluna FUnit suite.
if settings.startup["lonely-muluna-funit-enable-data-fixtures"].value then
  local manifest = require("prototypes.fixtures.manifest")
  for _, fixture in ipairs(manifest.data_updates or {}) do
    require("prototypes.fixtures." .. fixture)
  end
end
