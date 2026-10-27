-- Startup setting for the Lonely Muluna FUnit data fixtures.
--
-- Keeping the fixtures behind a setting lets a test save still load when they
-- are intentionally disabled. The runtime suite fails if they are disabled, so
-- a skipped data run cannot look successful.
data:extend({
  {
    type = "bool-setting",
    setting_type = "startup",
    name = "lonely-muluna-funit-enable-data-fixtures",
    default_value = true,
    order = "a",
  },
})
