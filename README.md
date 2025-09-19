# readiness

## Classifying Retirement Plan Financial Adequacy Using Form 5500 Data

## Overview
This project classifies U.S. employer-sponsored retirement plans as structurally **adequate** or **inadequate** in supporting participant financial readiness. Using 2023 Form 5500 filings, I engineer interpretable features to assess plan-level savings dynamics, leakage, and engagement—offering a diagnostic lens into retirement plan design.

## Learning Question
> Can we classify retirement plans as “adequate” or “inadequate” in supporting participant financial readiness, based on structural indicators such as participation rate, average account balance, contribution stability, and leakage volume?

## Dataset
- Source: [EFAST2 Portal](https://www.dol.gov/agencies/ebsa/about-ebsa/our-activities/public-disclosure/efast2)
- Year: 2023
- Scope: ~12,177 single-employer defined contribution plans
- Variables: 32 plan-level features including:
  - Participant counts (BOY/EOY)
  - Contributions, distributions, loans
  - Plan assets, sponsor metadata, business codes

## Methodology

### Feature Engineering
- Participation rate
- Contribution per participant
- Leakage ratio
- Asset growth and volatility
- Industry and plan size overlays for fairness

### Models Used
| Model               | Purpose                                                 |
|---------------------|---------------------------------------------------------|
| Logistic Regression | Baseline interpretability and fairness audits           |
| Random Forest       | Captures nonlinear relationships and feature importance |

### Evaluation Metrics
- ROC/AUC
- Confusion Matrix
- Residual Diagnostics
- Fairness overlays by industry and plan size

## Data Leakage Avoidance
All features are derived from within-year plan-level data. No post-filing outcomes or external economic indicators are used.

## Ethical Framing
- Classification is **structural**, not behavioral
- No individual-level data used
- Misuse risks documented and mitigated
- Investment-level data excluded for interpretability and consistency

## Limitations
- No participant-level financial context (e.g., income, debt)
- Behavioral inertia and financial stress may confound adequacy signals
- Investment performance excluded due to data inconsistency

## Repository Structure
```
├── data/                 # Cleaned Form 5500 data
├── data-raw/             # Data transformation code
├── inst/extdata/         # External data
├── notebooks/            # Analysis pipeline files
├── reference/            # Project reference files
└── README.md             # Project overview and rationale
```

## Stakeholder Relevance
This project supports sponsors, policymakers, and service providers in identifying structurally vulnerable plans and guiding redesign or outreach efforts.
