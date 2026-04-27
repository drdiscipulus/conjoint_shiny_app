# Alias Diagnostics Exploration

## Summary

This exploration investigated whether Conjoint Companion can supplement the existing correlation heatmap with a clearer aliasing/confounding diagnostic for two-level fractional factorial designs. The answer is yes: the app can add an "Interaction estimability" table without removing the heatmap or changing design generation.

The exploratory code is in `dev/explore_alias_structure.R`. Example CSV outputs are in `dev/alias_examples/`.

## Current Implementation

Design generation is implemented in `functions_factorial.R`.

- Two-level full factorial designs use `DoE.base::fac.design()`.
- Two-level fractional factorial designs use `FrF2::FrF2()`.
- The app passes the number of two-level attributes as `nfactors = attributes`.
- Current two-level fractional options map to:
  - `main_effects` -> `resolution = 3`
  - `two-way` -> `resolution = 4`
- N-level and mixed-level full designs use `DoE.base::fac.design()`.
- N-level and mixed-level fractional designs use `DoE.base::oa.design()`, `show.oas()`, and `GR()`.
- The current correlation heatmap uses `get_cor_table()` in `functions_factorial.R`, which calls `custom_corr_plot()` from `custom_corr_plot.R`.
- `custom_corr_plot()` builds model matrices up to two-way interactions by default and returns absolute correlations among effect columns.

The production app does not currently call `FrF2::aliases()` or `FrF2::aliasprint()`. The local package stack includes `FrF2::aliases()`, `FrF2::aliasprint()`, `FrF2::FrF2Large()`, and `FrF2` support for requested clear two-factor interactions via the `estimable` argument.

Local package versions used for the exploration:

- `FrF2` 2.3.4
- `DoE.base` 1.2.5

## Resolution Feasibility

`FrF2::FrF2()` can generate Resolution III, IV, and V designs for the tested 4-10 attribute range. Resolution VI is not reliably available as a fractional design through the current automatic call. For 4 and 5 attributes, the requested Resolution VI setting returns a full factorial design. For 6-10 attributes, the call succeeds but the actual generalized resolution remains V.

Compact results from `dev/alias_examples/resolution_feasibility.csv`:

| Attributes | Res III profiles | Res IV profiles | Res V profiles | Res VI request |
|---:|---:|---:|---:|---|
| 4 | 8, actual IV | 8, actual IV | 16, full | 16, full |
| 5 | 8, actual III | 16, actual V | 16, actual V | 32, full |
| 6 | 8, actual III | 16, actual IV | 32, actual V | 32, actual V, does not meet VI |
| 7 | 8, actual III | 16, actual IV | 64, actual V | 64, actual V, does not meet VI |
| 8 | 16, actual IV | 16, actual IV | 64, actual V | 128, actual V, does not meet VI |
| 9 | 16, actual III | 32, actual IV | 128, actual V | 128, actual V, does not meet VI |
| 10 | 16, actual III | 32, actual IV | 128, actual V | 256, actual V, does not meet VI |

`FrF2Large()` is not relevant for the app's current 4-10 attribute range. Its documented purpose is large designs, with at least 8192 runs. The exploration did not find a loaded `FrF2.catlg128` object; documented catalogue examples such as `catlg128.17` were also not available as local data objects in this installed package.

## Prototype Alias Table

The exploration prototypes these helper functions in `dev/explore_alias_structure.R`:

- `summarize_alias_structure(design)`
- `list_aliased_main_effects(design)`
- `list_aliased_2fis(design)`
- `list_clear_2fis(design)`
- `list_aliased_3fis(design)`
- `design_resolution_feasibility(n_attributes, resolution)`

The app-ready table shape is:

```text
effect | effect_order | status | aliased_with | interpretation
```

Example from a 5-attribute Resolution III design:

| effect | effect_order | status | aliased_with | interpretation |
|---|---:|---|---|---|
| Attribute 1 | 1 | aliased | Attribute 2:Attribute 4; Attribute 3:Attribute 5 | main effect may include a two-way interaction |
| Attribute 1:Attribute 2 | 2 | aliased | Attribute 4; Attribute 2:Attribute 3:Attribute 5 | do not interpret separately |
| Attribute 2:Attribute 3 | 2 | aliased | Attribute 4:Attribute 5; ... | do not interpret separately |

The prototype uses `clear`, `aliased`, and `conditionally_clear`:

- `clear`: no aliasing found in the checked effect space.
- `aliased`: confounded with a main effect or same-order/lower-order effect.
- `conditionally_clear`: clear from main effects and same-order effects, but aliased with higher-order terms; interpretation assumes those higher-order interactions are negligible.

This distinction is useful for Resolution V designs, where two-way interactions can be clear from other two-way interactions but still depend on the usual assumption that higher-order interactions are negligible.

## Resolution-Specific Messages

The script prototypes these user-facing messages:

- Resolution III: "This design is suitable for estimating main effects under the assumption that two-way interactions between manipulated attributes are negligible. Two-way interactions should not be interpreted because main effects may be aliased with two-way interactions."
- Resolution IV: "Main effects are clear from two-way interactions. Some two-way interactions may be aliased with other two-way interactions. Check the alias table before interpreting interaction effects."
- Resolution V: "Main effects and two-way interactions are clear from each other and two-way interactions are not aliased with other two-way interactions. Interpretation still assumes that higher-order interactions are negligible."
- Resolution VI or higher: "Some three-way interaction diagnostics may be possible, but feasibility depends on the number of attributes and runs. Report clearly which higher-order interactions are estimable."

## Important Interactions

`FrF2::FrF2()` supports requesting selected two-way interactions through the `estimable` argument. This could let users mark theoretically important interactions before generating a design.

Prototype result from `dev/alias_examples/selected_interaction_probe.csv`:

- Automatic run-size search for clear `att_1:att_2` and `att_1:att_3` failed because FrF2 initially tried 16 runs.
- Explicitly requesting 32 runs for 6 attributes succeeded.

Recommendation:

- A later UI could let users mark important two-way interactions.
- The server can pass those interactions as an `estimable` formula to `FrF2()`.
- If a clear design cannot be found at the current or automatic run size, the app should warn and recommend a larger number of profiles.
- Even without pre-generation marking, the app can warn after generation when selected or all two-way interactions are aliased.

## Recommendation

Keep the current correlation heatmap, but supplement it. The heatmap remains useful for technical inspection, but it is too indirect for applied conjoint users who need to know what can be interpreted.

Recommended later implementation:

1. Add an "Interaction estimability" table to the two-level factorial output.
2. Use the prototype table columns: `effect`, `effect_order`, `status`, `aliased_with`, `interpretation`.
3. Show main effects and two-way interactions by default.
4. Add an optional toggle for three-way interaction diagnostics.
5. Add Resolution V as an option for two-level fractional designs, but only show it with a clear profile-count implication.
6. Do not add Resolution VI as a simple dropdown option yet. Treat it as advanced or full-factorial only unless further package/catalogue support is verified.
7. Later, consider an optional "important interactions" selector that requests clear two-way interactions via `FrF2(..., estimable = ..., clear = TRUE)`.

## Files Produced

- `dev/explore_alias_structure.R`
- `dev/alias_examples/resolution_feasibility.csv`
- `dev/alias_examples/selected_interaction_probe.csv`
- `dev/alias_examples/alias_summary_*_attributes_resolution_*.csv`
