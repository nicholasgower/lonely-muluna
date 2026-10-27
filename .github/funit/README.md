# FUnit CI helpers

These scripts are adapted from the
[FUnit](https://gitlab.com/jfletcher94/funit) CI template via
[planet-muluna](https://github.com/nicholasgower/planet-muluna)'s
`.github/funit/` helpers. They are licensed under
`LGPL-3.0-or-later WITH FUnit-CI-Exception`; the exception permits
project-specific CI adaptations to be copied and modified without applying
copyleft to this repository.

## How the workflow works

`.github/workflows/funit.yml` runs on every push (and on manual dispatches). It
has three jobs:

1. **Build test artifacts** — packages the repository root as `lonely-muluna`,
   packages `test-mods/lonely-muluna-funit` as `lonely-muluna-funit`, clones
   FUnit at a pinned commit, and copies the
   `__funit__lonely_muluna` scenario to the top-level scenarios directory.
2. **Run FUnit scenario** — starts a headless `factoriotools/factorio` server
   with the scenario and the Space Age mods built into the image. Required
   dependencies are downloaded from the mod portal by
   `download_mods.py` from `info.json` and the test mod's `info.json`.
3. **Parse results** — converts the FUnit JSON report into JUnit XML and uploads
   it as a workflow artifact.

`entrypoint.sh` renames `funit-report-lonely-muluna.json` to
`funit-report-__funit__lonely_muluna.json`, so each scenario has its own report.
It also treats `recycler` as a built-in mod, like `base`, `space-age`,
`quality`, and `elevated-rails`.

## Local runner

The same tests can be run without Docker from the repository root:

```sh
test-mods/lonely-muluna-funit/run.sh
```

The runner links the current worktree as `lonely-muluna`, links the test mod
and the local dependency pack (`FACTORIO_MODS`, default
`/opt/factorio_space_age_21/mods`), starts the scenario, and exits non-zero on
any FUnit `FAILURE` or `ERROR`. It skips the optional
`eradicators-hand-crank-redux` dependency because the published release is
Factorio 2.0-only.

Useful environment variables:

| Variable | Default | Meaning |
| --- | --- | --- |
| `FACTORIO_BIN` | `/opt/factorio_space_age_21/bin/x64/factorio` | Factorio executable |
| `FACTORIO_MODS` | `/opt/factorio_space_age_21/mods` | Dependency mod directory |
| `TMP_ROOT` | `/tmp/opencode/lonely-muluna-funit` | Scratch mod directory, config, log, and report |
| `TIMEOUT` | `900` | Seconds to wait for `====END====` |
| `FACTORIO_PORT` | `34199` | Local server port |

The report is written to
`$TMP_ROOT/write-data/script-output/funit-report-lonely-muluna.json`.

## Credentials

Downloading public mods requires a Factorio account that owns the game. The
workflow reads:

- `FACTORIO_USERNAME` — repository variable or secret; falls back to
  `MeteorSwarm`.
- `FACTORIO_PLAYER_TOKEN` — repository secret containing the `service-token`
  from the Factorio client's `player-data.json`.

This is a *player* token, not the ModPortal upload API key used by the release
workflow (`FACTORIO_TOKEN`). If the secret is missing or invalid, the test job
fails before running Factorio with an actionable error. The paid Space Age mods
are supplied by the Docker image and are not downloaded from the portal.

## What the suite covers

Data-stage fixtures inspect the final prototype set after
`lonely-muluna`'s `data-final-fixes`:

- the forced Muluna start and the single map-gen preset;
- Nauvis's scrap world (no water, trees, or grass);
- Fulgora's conversion to a `space-location` and the Muluna/Fulgora/
  solar-system-edge routes;
- the solar multiplier and Gleba's lightning/render parameters;
- the Fulgora discovery gate, technology prerequisites, recycling scrap trigger,
  and removed rail-support technology;
- cleared magnetic-field surface conditions and the moved lightning rod;
- Muluna's orbit, discovery icons, and the optional `er-hcg` patch.

The runtime suite checks the active scenario settings, the Muluna planet and
surface, the absence of Fulgora as a runtime planet, the solar value on Muluna,
and the `on_surface_created` evolution handler on a freshly created surface.

The optional `eradicators-hand-crank-redux` integration is tested only when a
compatible build is present. The public 3.0.0 release is Factorio 2.0-only, so
it is deliberately not a required test dependency.
