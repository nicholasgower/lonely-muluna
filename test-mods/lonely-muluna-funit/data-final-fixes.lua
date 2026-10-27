-- Final data-stage fixtures for the Lonely Muluna FUnit suite.
--
-- This file runs after lonely-muluna's data-final-fixes (the test mod depends
-- on lonely-muluna), so these checks see the final prototype state that ships
-- to players.
if settings.startup["lonely-muluna-funit-enable-data-fixtures"].value then
  local manifest = require("prototypes.fixtures.manifest")
  for _, fixture in ipairs(manifest.data_final_fixes or {}) do
    require("prototypes.fixtures." .. fixture)
  end
end
