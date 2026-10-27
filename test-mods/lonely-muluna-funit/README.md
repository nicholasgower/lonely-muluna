# lonely-muluna-funit

Development-only FUnit test suite for **lonely-muluna**. This companion mod is
not part of a normal install: `test-mods/**` is marked `export-ignore` in
`.gitattributes`, so it is excluded from release zips. The harness is adapted
from planet-muluna's `test-mods/planet-muluna-funit` FUnit suite.

The suite has two parts:

1. **Data-stage fixtures** in `prototypes/fixtures/` inspect the final prototype
   set and record pass/fail results in the `lonely-muluna-funit-results`
   mod-data prototype. They are controlled by the
   `lonely-muluna-funit-enable-data-fixtures` startup setting (enabled by
   default); the runtime suite fails if it is disabled, so fixtures cannot be
   skipped silently.
2. **Runtime tests** in `tests/suites/` read those results and exercise live
   scenario state (planets, surfaces, settings, and event handlers).

`scenarios/__funit__lonely_muluna/control.lua` starts FUnit, converts the
recorded data fixtures into FUnit tests, and loads every runtime suite in
`tests/manifest.lua`.

## Running

From the repository root:

```sh
test-mods/lonely-muluna-funit/run.sh
```

The runner is headless and self-contained:

- links the **current worktree** as `lonely-muluna` (not an installed copy);
- links the local dependency pack from `FACTORIO_MODS`;
- writes a scratch mod directory, config, and log under `TMP_ROOT`;
- disables server auto-pause so FUnit can advance ticks without a player;
- supports both the full client and the dedicated headless server build;
- stops Factorio after FUnit prints `====END====`;
- exits non-zero on any FUnit `FAILURE` or `ERROR`.

Useful environment variables:

| Variable | Default | Meaning |
| --- | --- | --- |
| `FACTORIO_BIN` | `/opt/factorio_space_age_21/bin/x64/factorio` | Factorio executable |
| `FACTORIO_MODS` | `/opt/factorio_space_age_21/mods` | Directory containing dependency mods |
| `TMP_ROOT` | `/tmp/opencode/lonely-muluna-funit` | Scratch mod directory, config, log, and report |
| `TIMEOUT` | `900` | Seconds to wait for `====END====` |
| `FACTORIO_PORT` | `34199` | Local server port used by the headless instance |

The full log is `$TMP_ROOT/stdout.log`; on failure the runner prints the
relevant FUnit lines and the tail of the log. The JSON report is written to
`$TMP_ROOT/write-data/script-output/funit-report-lonely-muluna.json`.

## Requirements

- Factorio 2.1.23 with Space Age.
- The `funit` mod.
- `planet-muluna`, `PlanetsLib`, `muluna-graphics`, `enhanced-shadows`,
  `any-planet-start`, `corrundum`, `secretas`, `Redrawn-Space-Connections`,
  `aai-signal-transmission`, `alien-biomes-graphics`, `flib`, `bplib`, and the
  space-exploration graphics mods, as listed in `info.json`.
- The optional `eradicators-hand-crank-redux` is not required. The published
  3.0.0 release is Factorio 2.0-only; the `er-hcg` data fixture checks the patch
  only when a compatible build is present.

The scenario is started with:

```text
--start-server-load-scenario lonely-muluna-funit/__funit__lonely_muluna
```

## Layout

```text
info.json, settings.lua     companion-mod metadata and fixture setting
data.lua                    creates the result bag, runs data-stage fixtures
data-updates.lua            data-updates fixtures
data-final-fixes.lua        data-final-fixes fixtures (after lonely-muluna)
prototypes/fixtures/        prototype-level checks
lib/results.lua             records fixture results in mod-data
scenarios/__funit__lonely_muluna/  FUnit scenario entry point
tests/helpers.lua           shared scenario/surface helpers
tests/manifest.lua          runtime suite load order
tests/suites/               data-fixture bridge and runtime tests
run.sh                      headless local runner
```

## Adding a test

1. **Prototype-only check:** add `results.check("suite", "id", function() ... end)`
   to a file in `prototypes/fixtures/` and list it in the matching stage array in
   `prototypes/fixtures/manifest.lua`.
2. **Runtime behavior:** add a suite under `tests/suites/`, register it in
   `tests/manifest.lua`, and use `runner.test` / `runner.assert`.
3. Clean up created surfaces/entities and restore state changed by a test.
4. Run the local runner and check both `SUCCESS` lines and the exit code.

The headless scenario has no connected player. Avoid tests that require a real
player unless you add a test-only interface to the production mod; prefer
creating surfaces/entities directly and asserting the resulting state.

## Coverage notes and limitations

Covered:

- The forced Muluna starting planet and map-gen preset.
- Fulgora's conversion from a planet to a space-location and the final space
  routes.
- Nauvis's scrap-only map generation and removed water/trees/grass.
- The global solar multiplier, Gleba lightning, and Fulgora render parameters.
- Fulgora's technology gate, prerequisite rewiring, lightning-rod move, and
  recycling scrap trigger.
- Removed rail-support technology, cleared magnetic-field surface conditions,
  Muluna's orbit, and the discovery icons.
- The optional `er-hcg` patch.
- Runtime scenario settings, Muluna's planet/surface, absence of Fulgora as a
  runtime planet, Muluna's solar property, and the new-surface evolution
  handler.

Not covered:

- Player-driven respawn behavior (the headless scenario has no player).
- A real player's first spawn, which is handled by
  `any-planet-start` rather than this mod.
- GUI/graphics-only behavior.
- New-game map generation contents beyond the prototype-level map-gen settings.
