-- Suites are loaded in order. Data fixtures are registered first so a
-- load-time data regression is reported before the runtime checks.
return {
  "__lonely-muluna-funit__.tests.suites.data_fixtures",
  "__lonely-muluna-funit__.tests.suites.runtime",
}
