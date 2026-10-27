-- Runtime FUnit scenario for lonely-muluna.
--
-- The scenario lives inside the development-only companion mod so it is not
-- included in release builds. Run it locally with:
--   --start-server-load-scenario lonely-muluna-funit/__funit__lonely_muluna
require("__base__/script/freeplay/control.lua")

local runner = require("__funit__.test_runner")
runner.register("lonely-muluna")
runner.report("lonely-muluna")

local manifest = require("__lonely-muluna-funit__.tests.manifest")
for _, suite in ipairs(manifest) do
  require(suite)
end
