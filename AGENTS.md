# AGENTS.md

Guidance for AI agents (and humans) working in the **lonely-muluna** repository.

## What this project is

`lonely-muluna` is a small **Factorio mod that delivers the Lonely Muluna
scenario** used on [getcomfy.eu](https://getcomfy.eu). It is a companion/overhaul
for [planet-muluna](https://mods.factorio.com/mod/planet-muluna), not a standalone
total conversion.

There is no application, build step, or compiled artifact. The "code" is Lua that
Factorio runs at specific **load stages**, and the release artifact is a zip that
CI publishes to the Factorio mod portal.

- Language: **Lua 5.2** (Factorio's embedded interpreter).
- Game: **Factorio with Space Age**; `info.json` is the source of truth for the
  declared Factorio version.
- Author/maintainer: MeteorSwarm.
- Version: `info.json` → `"version"`. CI bumps it; do not bump it by hand for a
  normal change.
- "Scenario" here means a **ruleset + map-gen preset**, not a Factorio
  `scenarios/` directory. There is no `scenarios/` folder and no scenario save.

`README.md` is still the stock `factorio-mod-template` README, and
`tools/README.md` was copied from planet-muluna. Neither is an accurate overview
of this repository. Treat this file as the repository guide and the root Lua
files as the source of truth.

## Relationship to planet-muluna

`lonely-muluna` is loaded **after** planet-muluna (it is a declared dependency),
so it can assume planet-muluna's prototypes and libraries exist. The reverse is
not true.

It currently declares these dependencies:

- `planet-muluna` — the planet, its prototypes, and shared libraries.
- `muluna-graphics` — technology/planet artwork.
- `space-age`, `base` — vanilla content.
- `enhanced-shadows` — server visual pack.
- `any-planet-start` — starting-planet selection; this scenario forces Muluna.
- `corrundum`, `secretas` — additional planets/space locations used by the pack
  (`solar-system-edge` comes from Secretas).
- `Redrawn-Space-Connections` — space-connection lengths.
- `eradicators-hand-crank-redux` — optional; supplies the `er-hcg` recipe that
  `data.lua` rewrites. The published 3.0.0 release is Factorio 2.0-only, so it
  cannot be a hard dependency on 2.1.
- `aai-signal-transmission` — server pack requirement.
- `Rocs-Hardcore-Lightning-Storms` is explicitly incompatible (`!` dependency).

`maraxsis` is optional: `data.lua` guards its extra space connection with
`if mods["maraxsis"] then`.

Important consequences:

- Many dependencies are **load-bearing even if their names never appear in the
  Lua source**. Do not prune dependencies because `grep` finds no use.
- The scenario patches dependency prototypes **by name** (`fulgora`, `gleba`,
  `aps-planet`, `rail-support-foundations`, ...). A rename or removal in an
  upstream mod is a load-time crash here. The `er-hcg` patch is the exception: it
  is guarded because that mod is optional.
- `data-final-fixes` is **not globally last**. A mod that depends on
  `lonely-muluna` can run its own final fixes afterwards. Use the data-stage probe
  when a patch appears to be missing or overwritten.

## Current state and known landmines

These are active obstacles, not historical trivia:

- **The mod targets Factorio 2.1.23.** `info.json` declares
  `"factorio_version": "2.1"` and `base >= 2.1.23`. The code also requires
  `planet-muluna >= 2.8.0` and `PlanetsLib >= 2.4.0`; the remaining dependency
  floors pin the tested 2.1 releases. Do not lower those floors without testing
  the data stage against the older releases.
- **`data-updates.lua` and `data-final-fixes.lua` require `rro` explicitly.**
  planet-muluna exposes the helper as `Muluna.rro` and as
  `require("__planet-muluna__.lib.remove-replace-object")`; it does not create a
  global `rro`. Keep the explicit local require in both files.
- **The hand-crank dependency is optional and currently 2.0-only.**
  `eradicators-hand-crank-redux` 3.0.0 declares `factorio_version: "2.0"`, which
  Factorio 2.1 refuses to load. `info.json` therefore declares it optional, and
  `data.lua` guards the `er-hcg` patch. A 2.1-compatible fork can still be
  installed and will receive the cheap starter recipe; do not make it a hard
  dependency again until such a release exists.
- **`control.lua` has no `on_init` handler.** The `init` function is commented
  out, so `script.on_init(init)` registers `nil`. This is legal and simply means
  `storage` is initialized lazily in `on_surface_created`; do not assume an init
  callback exists.
- **Tests live in `test-mods/lonely-muluna-funit/`.** The FUnit companion mod is
  development-only and export-ignored. There are no migrations or
  `api.lua`/`settings.lua`; do not import planet-muluna test instructions
  wholesale.
- **The dev tooling is copied from planet-muluna.** Only part of it applies; see
  [Verification and tooling](#verification-and-tooling).

### Factorio 2.1-specific changes to preserve

These are easy to accidentally revert while editing:

- Technology research triggers use
  `{type = "mine-entity", entities = {"scrap"}}`. The old 2.0 `entity` field is
  invalid in 2.1.
- Recipe categories use `categories = {...}`. `category` and
  `additional_categories` are invalid in 2.1.
- `LuaControl::teleport` takes named parameters in the current API. Use
  `player.teleport{position = {0, 0}, surface = "muluna"}`; the old positional
  call would pass the position table as `build_check_type`.
- Numeric settings use `minimum_value` and `maximum_value`, not `min`/`max`.
- Space locations have an `origin` field in 2.1. `PlanetsLib:update` converts
  orbit data to the new origin format during `data-final-fixes`, so keep the
  `PlanetsLib` dependency at `>= 2.4.0`.
- Fulgora's old `rocket-part-productivity-fulgora` technologies no longer exist
  in the 2.1 dependency set. The rename code in `data-final-fixes.lua` is guarded
  and must stay optional.
- Redrawn-Space-Connections rebuilds and renames connections during
  `data-final-fixes`. The source patch targets `nauvis-muluna`, but the final
  prototype is usually `muluna-fulgora`; assert against the data dump rather than
  the intermediate name.

## Repository layout

```text
info.json                 Mod metadata + dependency list (source of truth for version)
data.lua                  data stage: preset, space connections, optional er-hcg, icons
data-updates.lua          data-updates stage: Muluna orbit, plant resistance, tech removal
data-final-fixes.lua      data-final-fixes stage: solar, Fulgora conversion, tech rewrites
settings-updates.lua      settings-updates stage: adds/forces scenario settings
settings-final-fixes.lua  settings-final-fixes stage: hides/forces all visible settings
control.lua               Runtime stage: evolution pressure and Muluna respawn
locale/<lang>/locale.cfg  Translations (en is authoritative)
graphics/                 Runtime PNGs plus XCF sources (XCFs are export-ignored)
tools/                    Development helpers, mostly copied from planet-muluna
test-mods/lonely-muluna-funit/  FUnit data fixtures, scenario, and runtime tests
.github/workflows/        Release and FUnit workflows
.github/funit/            Vendored/adapted FUnit CI helpers
.releaserc                Commit types, changelog sections, release plugins
.gitattributes            Release-zip export rules
opencode.json             OpenCode agent config copied from planet-muluna
```

Production code has no `prototypes/`, `lib/`, `scripts/`, `compat/`, or
`migrations/` directory. Everything runtime-relevant is in the root stage files
unless you deliberately add a new module. The `test-mods/lonely-muluna-funit/`
tree has its own `lib/`, `prototypes/`, `scenarios/`, and `tests/` for the FUnit
suite only.

## The Factorio load stages

Factorio runs the Lua files multiple times in a fixed order, exposing different
globals each time. Put code in the stage where its globals exist.

1. **settings** — `settings.lua`, `settings-updates.lua`,
   `settings-final-fixes.lua`. Only `data` (settings prototypes) is available.
2. **data / data-updates / data-final-fixes** — `data.raw`, `data:extend`,
   `mods`, `settings`, and prototype libraries. `game`/`script` do not exist.
3. **control** — `control.lua`. `game`, `script`, `storage`, `prototypes`,
   `rendering`, and `remote` exist. `data` does not.

This mod has no `settings.lua`; it adds settings in `settings-updates.lua` so it
sees settings defined by dependencies first.

### What each root file does

- **`settings-updates.lua`** adds startup settings (hardcore restrictions,
  science-pack output, etc.) and forces `any-planet-start`'s `aps-planet` to
  `muluna`. It assumes planet-muluna/APS settings already exist.
- **`settings-final-fixes.lua`** walks every settings prototype. For each setting
  that is visible and not `runtime-per-user`, it sets `hidden = true` and
  `forced_value = default_value`. This is intentional server policy, not an
  accident.
- **`data.lua`** replaces the `default` map-gen preset with the single
  `[planet=muluna] Lonely Muluna` entry and sets richness `0.5` for every
  resource autoplace control not in `muluna_resources`; rewrites and enables the
  `er-hcg` recipe when that optional mod is present; re-orbits/retargets space
  connections; swaps Nauvis/Gleba/Fulgora icons.
- **`data-updates.lua`** moves Muluna's orbit to the star (`PlanetsLib:update`),
  gives yumako trees and jellystems 100% electric resistance, and deletes
  `rail-support-foundations` because the pack has no deep-oil tiles for it.
- **`data-final-fixes.lua`** applies the global solar multiplier, strips Nauvis
  map generation down to a scrap world, converts Fulgora into a `space-location`
  and deletes the planet, moves Fulgora's lightning to Gleba, and rewires
  technologies.
- **`control.lua`** sets enemy evolution by time on every newly created surface
  and teleports respawned players to Muluna.

## What the scenario changes

Keep these behaviors in mind before "fixing" what looks odd:

### Starting planet and map generation

- `aps-planet` is forced to `muluna`; any-planet-start's other choices are
  unavailable. Starting on Muluna is the point of the scenario.
- Muluna orbits the star at distance 45 with `draw_orbit = true`.
- The `default` map-gen preset is replaced by one preset labelled
  `[planet=muluna] Lonely Muluna`.
- Every resource autoplace control not in the `muluna_resources` allowlist gets
  richness `0.5`. The allowlist is `oxide-asteroid-chunk`,
  `metallic-asteroid-chunk`, `carbonic-asteroid-chunk`, `anorthite-chunk`,
  `helium`, `stone`, and `uranium-ore`. When the pack adds a resource, decide
  whether it belongs in that list.

### Space and planets

- `data.lua` retargets the `nauvis-muluna` connection to Fulgora, requests a
  length of 75,000, and copies Corrundum's asteroid definitions, so that route
  now leads to the Shattered Fulgora space location. Redrawn-Space-Connections
  later rebuilds and rescales the edge; the final prototype is normally
  `muluna-fulgora`, and its length is derived from orbital positions.
- A `muluna-solar-system-edge` connection (requested length 100,000) is added to
  Secretas's `solar-system-edge`; Redrawn may rescale it as well.
- If Maraxsis is installed, a 90,000-length `muluna-maraxsis` connection is added.
- Fulgora is **converted from a planet into a `space-location`** and then removed
  from `data.raw.planet`. After `data-final-fixes`, `data.raw.planet.fulgora` is
  `nil`; use `data.raw["space-location"].fulgora` if you need the shattered
  location. Its lightning properties move to Gleba.
- Nauvis and Gleba inherit Fulgora's surface render parameters. Nauvis loses
  trees, water, and grass, and gains scrap autoplace. Yumako trees and jellystems
  get 100% electric resistance so Gleba's lightning does not wipe them out.
- Solar power is multiplied by `1.5` for every planet, both
  `solar_power_in_space` and the `solar-power` surface property. A planet without
  a `solar-power` property is set to `150`. Because this runs in
  `data-final-fixes`, it affects every planet present at that point, including
  modded planets.

### Progression

- `planet-discovery-fulgora` is renamed "System rediscovery Calidus", requires
  100 science, and becomes the gate that used to be `asteroid-collector` for
  every other technology.
- `lightning-rod` moves from Fulgora discovery to Gleba discovery;
  `lightning-collector` and `lightning-rod` lose their surface conditions.
- `steam-power` and `steel-axe` require `metallic-asteroid-crushing`;
  `electronics` requires `muluna-aluminum-processing`.
- All `surface_conditions` consisting **only** of a `magnetic-field` condition
  are replaced with `pressure = 1000` (Nauvis-like pressure). This intentionally
  frees Fulgora-locked recipes without deleting the magnetic-field property
  globally. Multi-condition objects keep their magnetic-field requirement.
- `recycling` now triggers on scrap and requires `planet-discovery-nauvis`, so
  scrap processing arrives with Nauvis.
- `rocket-part-productivity-fulgora` and `-2` are localised as Nauvis variants.

### Runtime

- On every `on_surface_created`, the enemy force gets
  `set_evolution_factor_by_time(0.95, surface)`. When the created surface is
  `muluna`, the same is applied to `nauvis`.
- `on_player_respawned` always teleports the player to `{0, 0}` on `muluna`,
  regardless of where they died. That is the scenario's death loop.
- There is no save-migration directory. Prototype changes apply when an existing
  save loads, but already-generated surfaces and map-gen results do not change.

## Prototype-patching conventions

- **Require `rro` explicitly** when you need it:
  ```lua
  local rro = require("__planet-muluna__.lib.remove-replace-object")
  ```
  Do not rely on a global `rro`. Both `data-updates.lua` and
  `data-final-fixes.lua` use the explicit require.
- Prefer `rro.soft_insert`, `rro.replace`, and `rro.remove` over raw
  `table.insert`/`table.remove` on shared lists. Duplicate ingredients,
  prerequisites, or technology effects break the tech tree.
- Use `table.insert` only where the list is known to be empty or order is
  deliberate (the existing icon/effect code does this).
- Guard optional content with `if mods["..."] then` or
  `if data.raw.<type>["..."] then`. Required dependencies may be assumed, but
  guarding still turns a missing prototype into a skip instead of a crash.
- When changing a prototype's **type** (as with Fulgora), re-fetch it from
  `data.raw` after the conversion; a previously cached table may no longer be the
  live prototype.
- Broad loops over `data.raw` are deliberate here (solar, magnetic-field
  conditions). They affect the whole server pack. Do not add a new broad loop
  without checking which other mods it will touch.
- Keep mod-ID paths consistent: `__lonely-muluna__/graphics/...`, because
  `info.json` names the mod `lonely-muluna`.
- Commented-out blocks are intentional history and abandoned designs, not lint.
  Do not delete or "clean up" them unless the task is specifically that.

## Settings conventions

- `settings-updates.lua` may add startup settings, but
  `settings-final-fixes.lua` will hide them and force them to their defaults
  unless they are `runtime-per-user`.
- If players must be able to change a setting in this scenario, make it
  `runtime-per-user`; otherwise accept that it will be hidden and forced.
- `aps-planet` is forced to `muluna`. Do not add alternative start planets
  without also updating this file and the map-gen preset.
- Do not unhide settings casually: the blanket hide/force pass is the server
  configuration contract.

## Control-stage conventions

- Use `script.on_event` directly; this mod does not use planet-muluna's event bus.
- Use `set_evolution_factor_by_time`, not `set_evolution_factor`. The latter was
  changed historically to avoid instantly applying a huge evolution jump.
- Keep handlers cheap: `on_surface_created` and respawn events run during normal
  play.
- If you add persistent state, initialize it defensively (the existing code uses
  `if not storage.respawn_location then ... end`) and consider existing saves.
  There are no migrations, so a shape change needs a manual compatibility plan.

## Localization and graphics

- English is authoritative: `locale/en/locale.cfg`.
- Other locales (`de`, `fr`, `pl`, `ru`, `zh-CN`) may lag. Do not machine
  translate; add English keys first and leave translations to reviewers who know
  the language.
- Use Factorio `LocalisedString` tables for composed names, for example
  `{"technology-name.rocket-part-productivity-fulgora"}`.
- Runtime art is PNG under `graphics/`; `.xcf` files are editable sources and are
  `export-ignore`d from the release zip. Edit the XCF and re-export the PNG rather
  than replacing only the PNG, and do not delete the sources.
- Planet icons are 512 px; the technology-icon helper overlays a 256 px
  `muluna-graphics` planet-technology image. Preserve the icon stack order when
  touching `technology_icon_moon_complete`.

## Verification and tooling

There **is** an FUnit suite in `test-mods/lonely-muluna-funit/`. It runs
automatically on every push via `.github/workflows/funit.yml` and can be run
locally:

```sh
test-mods/lonely-muluna-funit/run.sh
```

The suite has:

- Data-stage fixtures in `prototypes/fixtures/` that inspect the final prototype
  set after lonely-muluna's `data-final-fixes`.
- Runtime tests in `tests/suites/` that inspect the scenario's planets, surface,
  settings, and the `on_surface_created` handler.
- A result bag (`lonely-muluna-funit-results`) that carries data-stage failures
  into the FUnit runtime report.

The CI workflow needs the `FACTORIO_PLAYER_TOKEN` repository secret (a Factorio
*player* token, not the mod-portal upload key) to download dependency mods.
`FACTORIO_USERNAME` is optional and falls back to `MeteorSwarm`.

### What works here

- Run the full FUnit suite:
  ```sh
  test-mods/lonely-muluna-funit/run.sh
  ```
  The runner links the current worktree, the companion test mod, and the local
  dependency pack, starts the `__funit__lonely_muluna` scenario headlessly, and
  exits non-zero on any FUnit `FAILURE` or `ERROR`. The report is written to
  `/tmp/opencode/lonely-muluna-funit/write-data/script-output/funit-report-lonely-muluna.json`.
- Syntax-check changed Lua and whitespace:
  ```sh
  tools/ci/lua-check.sh
  tools/ci/lua-check.sh --all
  ```
  This uses `luac5.2` when available and also runs `git diff --check`.
- Data-stage probe with a matching 2.1 pack:
  ```sh
  python3 tools/factorio_probe.py dump --add-mod .
  ```
  This builds a scratch mod directory, links the enabled pack, runs Factorio with
  `--dump-data`, and writes
  `/tmp/opencode/factorio-probe/write-data/script-output/data-raw-dump.json`.
  Use `--mod-list` to point at a different pack if the default pack is stale.
- Query the resulting prototypes:
  ```sh
  python3 tools/proto_query.py --dump /tmp/opencode/factorio-probe/write-data/script-output/data-raw-dump.json machines --data-ports
  ```
- Inspect data-stage load order when a patch seems overwritten:
  ```sh
  python3 tools/factorio_probe.py load-order /tmp/opencode/factorio-probe/stdout.log --stage data-final-fixes
  ```
- Look up Factorio API details with `python3 tools/fdoc.py ...` (the docs JSON is
  under the installed Factorio directory).

### What does not work here as-is

The `tools/` tree is a copy of planet-muluna's development tooling. These scripts
assume planet-muluna's layout and will fail or report irrelevant problems:

- `tools/ci/funit.sh` and `tools/ci/funit-seams-check.sh` are planet-muluna's
  helpers and need `test-mods/planet-muluna-funit/` and `scripts/funit.lua`,
  which do not exist here. Use `test-mods/lonely-muluna-funit/run.sh` instead.
- `tools/ci/export-check.sh` expects planet-muluna runtime files (`api.lua`,
  `settings.lua`) and planet-muluna's export boundary. It currently reports this
  repo's layout as a failure.
- `tools/ci/opencode-check.sh` checks prompt files and agent setup copied from
  planet-muluna.
- `opencode.json` references `.github/opencode/bugfix-prompt.md`,
  `prompts/factorio-docs.txt`, and `prompts/lua-docs.txt`, none of which are in
  this repository. Those agents will not work until the files are added.

Do not cite a failing copied helper as evidence that a change is wrong. Use the
source and the game.

### In-game checks

The real gate is loading the scenario with the full server mod pack:

1. Start a **new game** with the pack and select the
   `[planet=muluna] Lonely Muluna` preset.
2. Confirm the player starts on Muluna and the starmap shows the intended
   connections (Shattered Fulgora, solar-system edge, optional Maraxsis).
3. Confirm Fulgora is absent as a planet, Nauvis generates scrap and no
   water/trees/grass, and Gleba has lightning with surviving plants.
4. Check the technology tree for the rewired prerequisites and the renaming of
   the Fulgora discovery technology.
5. Die and confirm the respawn lands on Muluna.
6. Check solar values on every planet in the pack.

Existing saves are less reliable: generated surfaces keep their old map-gen, and
there are no migrations. Back up a save before testing a prototype change on it.

## Commits, changelog, and releases

Releases and `changelog.txt` are generated by **semantic-release** from commit
messages when `main` is pushed (see `.releaserc` and
`.github/workflows/release.yml`). The commit message becomes the changelog entry,
so use **Conventional Commits** with this project's types:

| Type | Changelog section | Release |
| --- | --- | --- |
| `feat`, `feature` | Features | minor |
| `fix` | Bugfixes | patch |
| `perf`, `performance` | Optimizations | patch |
| `compat`, `compatibility` | Compatibility | patch |
| `balance` | Balancing | patch |
| `graphics` | Graphics | patch |
| `sound` | Sounds | patch |
| `gui` | Gui | patch |
| `info` | Info | patch |
| `locale` | Locale | patch |
| `translate` | Translation | patch |
| `control` | Control | patch |
| `other` | Changes | patch |
| breaking change | (major) | major |

Format: `type: Summary sentence.` Examples from this repo's history:

```text
fix: Changed space-connection distances.
compat: Removed restriction on playing scenario in singleplayer.
fix: Added electric resistance to Gleba plants to prevent lightning from destroying all of them.
```

- **Do not hand-edit `changelog.txt` or bump `version` in `info.json`.** CI does
  both. Manually changing `factorio_version` for a port is expected, but it is not
  a release-version bump.
- Do not push to `main` unless you intend to release: the workflow uploads to the
  Factorio mod portal using `FACTORIO_TOKEN`. The configured `build` agent denies
  `git push`.
- Internal documentation and agent-guidance changes are not player-facing. Use a
  plain subject such as `Document the scenario verification steps.` rather than a
  recognized type, so the changelog does not gain a noise entry.
- If you open a pull request, describe what you actually tested and do not check
  boxes for work that was not done. AI-generated pull requests should be marked
  `(AI-generated)` in the title and signed with the model name in the body.

## Working agreements

- Keep changes small and consistent with the surrounding root-file style. Do not
  reformat a whole file while making a targeted patch.
- Preserve the scenario's deliberate oddities: forced settings, global prototype
  loops, deleted Fulgora planet, and commented-out alternatives.
- Do not prune dependencies, delete graphics sources, or remove "unused" code
  without tracing its effect through the full pack.
- `AGENTS.md`, `tools/`, `test-mods/`, `.github/`, and `opencode.json` are
  development-only and are marked `export-ignore` in `.gitattributes`; the
  release zip is built with `git archive`. Use recursive patterns such as
  `tools/**` and `test-mods/**`.
- Do not commit `tools/__pycache__/`, `.zip` artifacts, `.env` files, or other
  local build output.
- When in doubt about upstream behavior, consult planet-muluna's `AGENTS.md` and
  `tools/README.md`, then verify against this repo's actual dependency versions.
