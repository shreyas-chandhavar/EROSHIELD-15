# EROSHIELD-15

**Preliminary leading-edge erosion protection and aerodynamic trade study for the public IEA 15-MW reference wind turbine**

![EROSHIELD-15 concept geometry](images/geometry_summary.svg)

## Project objective

EROSHIELD-15 investigates whether a removable / conformal leading-edge protection concept can reduce the aerodynamic penalty associated with outer-blade erosion while keeping added mass and integration effects small enough to remain practical.

The work uses the **public IEA 15-MW reference turbine** as the baseline and combines:

- SolidWorks CAD reconstruction and assembly work;
- GNU Octave differential BEM screening;
- erosion and protection sensitivity cases;
- mass, centrifugal-load and attachment screening;
- span-placement analysis;
- numerical convergence diagnostics;
- TurboPLM requirements, eBOM, ECR/ECN and release-baseline control.

This is a **preliminary engineering / concept-screening study**, not a certified LEP product design.

![Engineering workflow](images/project_workflow.svg)

---

## 1. Engineering problem

Leading-edge erosion can reduce lift-to-drag ratio and increase aerodynamic losses in the high-speed outer region of a wind-turbine blade. A protection system can reduce future erosion exposure, but the protection itself can also introduce an aerodynamic penalty through thickness, surface discontinuity and termination geometry.

The engineering question therefore was not simply:

> “Can a shield protect the blade?”

It was:

> **Can a protection concept provide a net performance benefit once its own aerodynamic penalty, mass, spanwise placement and attachment implications are included?**

This led to a deliberately trade-based project rather than a single “recovery percentage” claim.

---

## 2. Controlled geometry and CAD concept

The Rev-A configuration uses the public IEA 15-MW outer-blade region as the reference geometry.

| Parameter | Rev-A controlled value |
|---|---:|
| Protected physical span | 9.551 m |
| Nominal shield thickness | 2.0 mm |
| CAD thickness check | ~1.98 mm |
| Controlled outer-blade object | `PRT-1310` |
| Protection component | `PRT-1320` |
| Assembly | `ASM-1300` |
| Installed-mass screening estimate | 15.90 kg/blade |

The shield was modeled as a separate conformal component rather than modifying the reference blade directly. This kept the concept removable and made the configuration suitable for assembly-level PLM control.

### CAD work completed

- reconstructed outer-blade reference segment;
- generated the conformal leading-edge protection component;
- created the outer-blade assembly;
- checked alignment and mating of the shield to the blade segment;
- performed interference / coincidence review;
- retained the shield as a separately controlled component.

The proposed later **Phase-12 feathered-termination redesign was not completed** before project closeout, so the released Rev-A concept remains the final controlled CAD baseline.

---

## 3. Aerodynamic screening methodology

The aerodynamic analysis was performed as a **differential outer-segment BEM correction** anchored to the project clean rated-power baseline:

[
P_{total}=P_{baseline}+left(P_{segment,case}-P_{segment,clean}ight)
]

with:

- air density: 1.225 kg/m³;
- rated-point wind speed: 10.59 m/s;
- rotor speed: 7.56 rpm;
- three blades;
- station-specific IEA outer-blade geometry;
- public AeroDyn polar data;
- Prandtl hub/tip losses;
- bounded induction factors;
- relaxation-based fixed-point convergence.

The project evolved through two main analysis generations.

### Rev-A parametric screening

The original controlled Rev-A model used:

- erosion: **−5% (C_L), +50% (C_D)**;
- shield state: prescribed **80% recovery of the sectional coefficient penalty**.

That model produced approximately:

- eroded rated power: **16.050 MW**;
- EROSHIELD rated power: **16.174 MW**;
- modeled recovered rated power: **124.48 kW**;
- rotor-level recovery: **80.85%**;
- AEP proxy recovered: **0.5828 GWh/year**.

These values are retained as **historical Rev-A screening outputs under explicit assumptions**, not as experimental validation.

### V2 literature-informed screening

The later V2 analysis replaced the forced “80% recovery” logic with independent erosion and LEP analogue branches so that recovery became an **output** of the BEM calculation.

The seven aerodynamic states were:

- Clean
- Erosion A1
- Erosion A2
- Erosion B3
- LEP tape analogue
- LEP chamfer analogue
- LEP step analogue

The LEP branches are **analogue sensitivity cases**. They do not represent direct measurements of the actual 2 mm EROSHIELD geometry.

---

## 4. Final V2 rated-point results

![Rated-point power penalty](images/v2_power_penalty.svg)

| Case | Rotor power [MW] | Change vs clean [kW] |
|---|---:|---:|
| Clean | 16.204000 | 0.00 |
| Erosion A1 | 16.152040 | −51.96 |
| Erosion A2 | 15.929537 | −274.46 |
| Erosion B3 | 15.608354 | −595.65 |
| LEP tape analogue | 16.179509 | −24.49 |
| LEP chamfer analogue | 16.149004 | −55.00 |
| LEP step analogue | 16.085062 | −118.94 |

The main design finding is that **protection is not automatically beneficial**. Under mild erosion, a protection system with too much aerodynamic penalty can perform worse than simply leaving the mildly eroded blade untreated.

Under moderate and severe erosion, lower-penalty protection analogues show much larger modeled benefits.

![Recovery screening matrix](images/v2_recovery_matrix.svg)

| Erosion state | LEP analogue | Net benefit [kW] | Recovery |
|---|---|---:|---:|
| A1 mild | Tape | +27.47 | 52.86% |
| A1 mild | Chamfer | −3.04 | −5.84% |
| A1 mild | Step | −66.98 | −128.90% |
| A2 moderate | Tape | +249.97 | 91.08% |
| A2 moderate | Chamfer | +219.47 | 79.96% |
| A2 moderate | Step | +155.53 | 56.67% |
| B3 severe | Tape | +571.15 | 95.89% |
| B3 severe | Chamfer | +540.65 | 90.77% |
| B3 severe | Step | +476.71 | 80.03% |

This is the strongest engineering conclusion from the project:

> **The value of leading-edge protection is condition-dependent. The protection penalty must be low enough relative to the erosion severity for the system to provide a net aerodynamic benefit.**

---

## 5. Numerical audit

The final V2 model was run using three angle-of-attack transfer windows:

- Nominal: ([0,4,9,13]^circ)
- Wide: ([0,3,10,14]^circ)
- Narrow: ([3,6,7,10]^circ)

Across:

- 3 transfer windows;
- 7 aerodynamic states;
- 12 outer-blade stations;

the model solved **252 individual BEM station/case combinations**.

### Numerical status

| Diagnostic | Result |
|---|---:|
| Converged solutions | **252 / 252** |
| Maximum iterations used | **76 / 200** |
| Axial-induction clip flags | **21** |
| Tangential-induction clip flags | **0** |
| Overall convergence status | **PASS** |
| Induction clipping status | **REVIEW REQUIRED** |

The clipping flags were not hidden. They remain a documented limitation because the solver uses bounded induction without a dedicated high-induction correction.

The repository includes:

- V2 screening source code;
- Rev-A result CSV;
- V2 nominal summary CSV;
- V2 comparison CSV;
- numerical audit record.

---

## 6. Span-placement study

A fixed-length **9.551 m protection window** was swept over the outer blade.

Using the later station-specific IEA polars, the existing CAD location captured approximately:

[
oxed{99.98%}
]

of the maximum screened recovered power among the tested fixed-length positions.

The predicted improvement from moving the shield to the best screened location was only about:

[
0.034 	ext{kW}
]

so the engineering decision was to **retain the existing CAD span** rather than redesign the installation for a negligible modeled gain.

---

## 7. Mass and attachment screening

The Rev-A concept-level estimates were:

| Quantity | Screening result |
|---|---:|
| TPU shell mass | 14.46 kg/blade |
| Installed mass incl. allowance | **15.90 kg/blade** |
| Approx. fraction of reference blade mass | 0.0244% |
| Radial mass centroid | 107.89 m |
| Rated centrifugal load | ~1.075 kN/blade |
| Average centrifugal bond shear | ~0.167 kPa |
| Factored average shear, FoS = 3 | ~0.500 kPa |

The important conclusion was that **uniform average centrifugal shear is not the critical attachment problem**.

The more important unresolved risks are:

- edge peel;
- local debond initiation;
- rain / particle impact;
- cyclic blade flexure;
- thermal mismatch;
- moisture ingress;
- adhesive ageing and fatigue.

These were intentionally left as future qualification work rather than presented as solved.

---

## 8. CAD / assembly evidence

The CAD work was controlled around three primary objects:

- `PRT-1310` — IEA15MW Outer Blade Segment
- `PRT-1320` — EROSHIELD Leading-Edge Shield
- `ASM-1300` — EROSHIELD Outer-Blade Assembly

A separate released shield component was important because the concept was intended to remain replaceable / removable rather than becoming an irreversible modification of the reference blade.

The assembly was checked for geometric coincidence / interference before release.

---

## 9. PLM and configuration control

EROSHIELD-15 was also used as a configuration-management exercise in **TurboPLM**, not only as a CAD / analysis project.

![PLM traceability](images/plm_traceability.svg)

### Controlled release objects

| ID | Object | Status |
|---|---|---|
| REF-0001 | IEA 15-MW Reference Blade | Controlled reference |
| PRT-1310 | IEA15MW Outer Blade Segment | Rev A released |
| PRT-1320 | EROSHIELD Leading-Edge Shield | Rev A released |
| ASM-1300 | EROSHIELD Outer-Blade Assembly | Rev A released |
| DOC-2000 | Source and License Record | Controlled |
| DOC-2100 | Aerodynamic & Rotor Impact Analysis | Rev A |
| ECR-10001 | Outer-Blade Leading-Edge Erosion Mitigation | Accepted |
| ECN-10001 | Outer-Blade Leading-Edge Erosion Mitigation | Released |

### PLM work completed

- engineering BOM created for `ASM-1300`;
- requirements linked to controlled product objects;
- six requirements approved;
- six requirements covered;
- zero uncovered requirements;
- ECR created and accepted;
- ECN created and released;
- Rev-A concept baseline released;
- analysis evidence linked to the controlled configuration.

The original TurboPLM database remains the authoritative record. GitHub mirrors the configuration logic and project evidence for portfolio use.

---

## 10. CFD disposition

A small SU2 branch was attempted for direct AF45 erosion-delta prediction.

Some cases converged numerically but produced nonphysical force behavior, including negative drag. Those cases **failed physical-consistency checks** and were rejected.

They are therefore:

- not used for headline results;
- not used as validation evidence;
- explicitly documented in `rejected-cfd/`.

This was an intentional engineering-quality decision: numerical convergence alone was not treated as proof of physical validity.

---

## 11. What was intentionally not completed

The project is closed before production qualification.

Not completed:

- Phase-12 feathered / scarf termination redesign;
- geometry-specific CFD validation of the actual 2 mm shield;
- wind-tunnel validation;
- adhesive peel / fracture testing;
- structural FEA of the final attachment;
- rain-erosion qualification;
- thermal / environmental ageing;
- blade-flexure compatibility testing;
- complete power-curve / wind-distribution AEP integration;
- manufacturing-process qualification.

These are documented as **open validation gates**, not hidden gaps.

---

## 12. Repository structure

```text
EROSHIELD-15/
├── analysis/
│   └── EROSHIELD15_literature_screening_v2.m
├── data/
│   └── README.md
├── results/
│   ├── EROSHIELD15_revA_final_results.csv
│   ├── EROSHIELD15_v2_nominal_summary.csv
│   ├── EROSHIELD15_v2_nominal_comparisons.csv
│   └── EROSHIELD15_v2_numerical_audit.txt
├── docs/
│   └── DOC-2000_Source_and_License_Record.txt
├── plm/
│   ├── README.md
│   ├── CHANGE_CONTROL.md
│   ├── EBOM.md
│   ├── REQUIREMENTS_STATUS.md
│   └── RELEASE_BASELINE.md
├── cad-reference/
│   └── README.md
├── rejected-cfd/
│   └── README.md
├── images/
│   ├── geometry_summary.svg
│   ├── project_workflow.svg
│   ├── v2_power_penalty.svg
│   ├── v2_recovery_matrix.svg
│   └── plm_traceability.svg
├── PROJECT_CLOSEOUT.md
└── THIRD_PARTY_NOTICE.md
```

---

## 13. Tools demonstrated

**CAD / mechanical design**
- SolidWorks
- assembly definition
- conformal component design
- fit / interference review

**Aerodynamics / numerical engineering**
- GNU Octave
- blade-element momentum modelling
- public AeroDyn polar handling
- numerical convergence diagnostics
- sensitivity analysis

**Engineering process**
- requirements traceability
- eBOM
- change control
- ECR / ECN workflow
- released configuration baseline
- evidence-based project closeout

---

## Final project status

[
oxed{	ext{Closed — preliminary engineering concept and screening study}}
]

EROSHIELD-15 is intentionally preserved as a **traceable engineering development project** rather than being presented as a validated commercial product.

See:

- [Project closeout](PROJECT_CLOSEOUT.md)
- [PLM / configuration control](plm/README.md)
- [Third-party attribution](THIRD_PARTY_NOTICE.md)
- [Rejected CFD branch](rejected-cfd/README.md)

---

### Attribution

This is an independent engineering study based on the public IEA 15-MW reference turbine and is not affiliated with or endorsed by IEA Wind, NREL, DTU or other organizations associated with the reference model.
