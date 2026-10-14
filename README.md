# EROSHIELD-15

**Preliminary leading-edge erosion protection and aerodynamic trade study for the public IEA 15-MW reference wind turbine**

![EROSHIELD assembly](images/eroshield_outer_blade_assembly.png)

## Project summary

EROSHIELD-15 explores a removable/conformal leading-edge protection concept for the outer region
of the IEA 15-MW reference blade. The project combines SolidWorks CAD, GNU Octave differential
BEM calculations, aerodynamic sensitivity studies, mass/centrifugal-load screening, simple
attachment-load checks, span-placement studies, and engineering change control.

The project is intentionally closed at the **preliminary design / screening** stage. It is not a
validated commercial LEP design.

## What was built

- Public IEA 15-MW outer-blade reference geometry
- 9.551 m leading-edge protection concept
- Nominal shield thickness: ~2 mm
- Approximate installed shield mass from Rev-A screening: 15.90 kg/blade
- Rev-A parametric aerodynamic model
- Station-specific IEA outer-blade polar model
- Literature-informed V2 erosion / LEP analogue screening
- Numerical convergence and induction-clipping audit
- PLM / ECN documentation

## Final aerodynamic screening

### V2 nominal rated-point results

| Case | Power [MW] | Delta from clean [kW] |
|---|---:|---:|
| Clean | 16.204000 | 0.00 |
| Erosion A1 | 16.152040 | -51.96 |
| Erosion A2 | 15.929537 | -274.46 |
| Erosion B3 | 15.608354 | -595.65 |
| LEP tape analogue | 16.179509 | -24.49 |
| LEP chamfer analogue | 16.149004 | -55.00 |
| LEP step analogue | 16.085062 | -118.94 |

Selected net-benefit results:

| Comparison | Net benefit [kW] | Recovery |
|---|---:|---:|
| A1 -> tape analogue | +27.47 | 52.86% |
| A1 -> chamfer analogue | -3.04 | -5.84% |
| A2 -> tape analogue | +249.97 | 91.08% |
| A2 -> chamfer analogue | +219.47 | 79.96% |
| B3 -> chamfer analogue | +540.65 | 90.77% |
| B3 -> step analogue | +476.71 | 80.03% |

The important result is the trade-off: a protection system can impose a penalty relative to a
perfectly clean blade while still being beneficial relative to a sufficiently eroded blade.

## Numerical audit

The final V2 run solved three AoA-transfer windows across seven aerodynamic states and twelve
outer-blade stations:

- 252 / 252 solutions converged
- maximum 76 / 200 iterations
- 21 axial-induction clipping flags
- 0 tangential-induction clipping flags

The clipping flags are documented as a limitation rather than hidden or treated as validation.

## Repository structure

```text
analysis/
  EROSHIELD15_literature_screening_v2.m
  legacy/EROSHIELD15_revA_parametric_screening.m

data/
  IEA15_AF45_polar.dat
  IEA-15-240-RWT_AeroDyn15_blade.dat
  IEA-15-240-RWT_AF45_Coords.txt

results/
  EROSHIELD15_revA_final_results.csv
  EROSHIELD15_v2_nominal_summary.csv
  EROSHIELD15_v2_nominal_comparisons.csv
  EROSHIELD15_v2_numerical_audit.txt

docs/
  source/license record
  aerodynamic analysis PDF
  engineering change record PDF

cad-reference/
  profile/reference packages and CAD notes

images/
  selected SolidWorks screenshots
```

## Historical Rev-A result

The released Rev-A parametric model used an assumed `-5% Cl`, `+50% Cd`, and prescribed
`80%` coefficient recovery. It produced approximately **124.5 kW modeled rated-point recovery**
and **80.85% rotor-level recovery**.

That result is retained only as historical concept-screening evidence. The later V2 model calculates
recovery as an output instead of prescribing it.

## Limitations

- Erosion and LEP analogue data are transferred from different airfoils / Reynolds numbers.
- LEP branches are not direct measurements of the actual 2 mm EROSHIELD geometry.
- AoA transfer windows remain engineering assumptions.
- Healthy LEP branches represent prevention / clean+LEP, not repair of existing erosion.
- Rated-point results are not integrated AEP.
- No geometry-specific aerodynamic validation, final adhesive qualification, rain-erosion
  qualification, or final structural FEA was completed.
- Early SU2 CFD was rejected because it failed physical-consistency checks and is not used as
  quantitative evidence.

## Status

**Closed — preliminary engineering concept and screening study.**

See [`PROJECT_CLOSEOUT.md`](PROJECT_CLOSEOUT.md) for the final scope boundary and retained conclusions.

## Attribution

This is an independent project and is not affiliated with or endorsed by IEA Wind, NREL, DTU,
or other organizations associated with the reference turbine.

See [`THIRD_PARTY_NOTICE.md`](THIRD_PARTY_NOTICE.md) and the source/license record in `docs/`.