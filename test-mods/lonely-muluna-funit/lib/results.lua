-- Shared helper for recording data-stage fixture results.
--
-- The data stage runs before the FUnit scenario, so failures are stored in a
-- mod-data prototype and reported by the runtime suite.

local results = {}

---Record the outcome of one fixture check.
---@param suite string Namespace to store the entry under.
---@param id string Unique id of the check.
---@param ok boolean Whether the check succeeded.
---@param err any Error message/value when ok is false.
---@return boolean ok
function results.record(suite, id, ok, err)
  local bag = data.raw["mod-data"]["lonely-muluna-funit-results"]
  assert(
    bag,
    "lonely-muluna-funit: 'lonely-muluna-funit-results' mod-data prototype was not created before lib.results.record() was called."
  )

  bag.data[suite] = bag.data[suite] or {}
  bag.data[suite][id] = {
    ok = ok and true or false,
    err = err ~= nil and tostring(err) or nil,
  }
  if not ok then
    log("[funit] data fixture " .. suite .. " / " .. id .. " failed: " .. tostring(err))
  end

  return ok and true or false
end

---Run a check inside pcall and record its result.
---@param suite string
---@param id string
---@param fn fun()
---@return boolean
function results.check(suite, id, fn)
  local ok, err = pcall(fn)
  return results.record(suite, id, ok, err)
end

return results
