# N-Level Design Diagnostics

## Current implementation

The N-level factorial section is implemented in:

- `ui/03_ui_factorial_n_level_tab.R`
- `server/02_server_factorial_n_level_tab.R`
- `functions_factorial.R`
- `R/interaction_coverage.R`

This section does not use `FrF2`. It uses `DoE.base`:

- `DoE.base::fac.design()` for full factorial N-level designs.
- `DoE.base::oa.design()` for mixed/N-level orthogonal-array designs.
- `DoE.base::show.oas()` and `DoE.base::GR()` in the higher-strength fractional search path.

User input such as `3,3,4,4` is parsed as level counts per attribute. The app currently allows 2 to 7 attributes and 2 to 4 levels per attribute.

## Current N-level criteria

The former UI label `Resolution` was misleading for this section. Classical Resolution III/IV/V belongs to regular two-level fractional factorial designs. The N-level section instead searches mixed-level orthogonal arrays and reports pairwise coverage and balance.

The existing choices map to:

- `main_effects`: direct `oa.design(nlevels = ..., columns = "min3")`.
- `two-way`: searches the orthogonal-array catalogue with `show.oas()` and checks generalized resolution via `GR()`.

These choices are not equivalent to two-level FrF2 Resolution III/IV/V.

## What happens for 3,3,4,4

For `3,3,4,4`, the full factorial size is:

```text
3 x 3 x 4 x 4 = 144
```

The current generator produces:

| Input | Criterion | Full factorial size | Generated profiles | Reduction achieved |
|---|---:|---:|---:|---|
| 3,3,4,4 | main_effects | 144 | 144 | FALSE |
| 3,3,4,4 | two-way | 144 | 144 | FALSE |

So when the user selects `Fractional`, the generated design is effectively full factorial. The Interaction Coverage table is mathematically correct: all six attribute pairs are fully observed and balanced because all profiles are present.

## Interaction Coverage interpretation

The Interaction Coverage table checks pairwise level-combination coverage:

- whether every two-way level combination appears at least once,
- whether the pairwise cells are balanced,
- the smallest and largest pairwise cell counts.

It does not describe classical fractional-factorial aliasing or FrF2-style confounding.

For a full factorial design, all two-way combinations are observed and balanced by construction.

## Smaller fractional N-level designs

Exploration script:

```text
dev/explore_n_level_designs.R
```

Generated summaries:

```text
dev/n_level_examples/generated_summary.csv
dev/n_level_examples/available_arrays.csv
```

Observed current-package behavior:

| Input | Criterion | Full size | Generated profiles | Reduction |
|---|---|---:|---:|---|
| 3,3,4,4 | main_effects | 144 | 144 | no |
| 3,3,4,4 | two-way | 144 | 144 | no |
| 3,3,3,3 | main_effects | 81 | 9 | yes |
| 3,3,3,3 | two-way | 81 | 27 | yes |
| 2,3,4,4 | main_effects | 96 | 48 | yes |
| 2,3,4,4 | two-way | 96 | 96 | no |
| 4,4,4,4 | main_effects | 256 | 16 | yes |
| 4,4,4,4 | two-way | 256 | 64 | yes |
| 2,2,3,3,4 | main_effects | 144 | 72 | yes |
| 2,2,3,3,4 | two-way | 144 | 144 | no |

For some inputs, reduced mixed-level orthogonal arrays are available. For others, the current stack either cannot find a suitable reduced design or returns a full-factorial-sized design.

Examples from `show.oas()`:

- `3,3,3,3`: reduced arrays such as `L27.3.4` are available.
- `4,4,4,4`: reduced arrays such as `L64.4.6` are available.
- `3,3,4,4`: no suitable smaller catalogue array was found in this exploration.
- `2,2,3,3,4`: no suitable higher-strength catalogue array was found in this exploration.

## UI/output recommendations

Implemented in the app:

- Rename the N-level selector from `Resolution` to `OA criterion`.
- Add design metadata to the Factorial Design tab:
  - full factorial size,
  - generated number of profiles,
  - whether profile reduction was achieved.
- If `Fractional` is selected but the generated design equals the full factorial size, show a clear warning.
- Clarify the Interaction Coverage tab:
  - pairwise coverage and balance are reported,
  - classical aliasing is not reported,
  - the lower-bound wording now states that balanced designs may require more profiles.

Further possible later work:

- Expose the selected OA catalogue name when available.
- Allow users to choose between smallest available OA and higher-strength OA when both exist.
- Consider a dedicated pairwise covering-array package if the goal becomes minimum-profile pairwise coverage rather than orthogonal-array balance.
