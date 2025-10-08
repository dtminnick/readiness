# Classifying Retirement Plan Financial Adequacy Using Form 5500 Data: Final Project Report

Donnie Minnick Statistical Learning - Fall A 2025 October 08, 2025

# Executive Summary

This report investigates the structural adequacy of employer-sponsored
retirement plans using 2023 Form 5500 filings. By engineering
interpretable features tied to participant growth, contribution
dynamics, asset accumulation, and leakage burden, I developed a
composite adequacy score and trained two classification models, logistic
regression and random forest, to predict plan adequacy. Sector-aware
tiering and stratified sampling ensured fairness and generalizability
across industries.

Model evaluation revealed that logistic regression offered strong
interpretability and consistent generalization, making it the preferred
tool for stakeholder-facing diagnostics. Feature importance analysis
showed that adequacy is driven by both structural momentum (e.g.,
contribution growth) and sector-specific disparities. Visualization of
predicted adequacy across sectors surfaced clear gaps, with industries
like Public Administration and Finance showing high adequacy rates,
while sectors such as Accommodation and Arts exhibited elevated
inadequacy.

These findings support targeted review and policy intervention, and
highlight the value of principled modeling in advancing retirement plan
transparency and equity.

My Github repository for this project can be accessed
[here](https://github.com/dtminnick/readiness).

# Exploratory Data Analysis and Data Transformation

The baseline dataset includes 5,579 single-employer defined contribution
plans. Initial checks confirmed no missing or zero values, ensuring a
clean foundation for modeling. Feature engineering focused on structural
signals of adequacy: participation rate, contribution per participant,
leakage burden, and asset growth. I grouped plans into vintage cohorts
based on effective year, and industry codes were collapsed into broader
sectors to support benchmarking.

Full exploratory analysis is documented
[here](https://github.com/dtminnick/readiness/blob/main/notebooks/2_eda_transform.md).

# Structural Adequacy Scoring and Tiered Feature Engineering

To classify plans as structurally “adequate,” I developed a composite
adequacy score based on six interpretable indicators: assets per
participant, asset growth, participant growth, contribution growth
(participant and employer), and loan leakage ratio. Each condition
contributes one point, yielding a score from 0 to 6. Plans scoring 4 or
higher were labeled “Adequate.”

To prevent circularity and promote generalization, I converted
predictive features into sector-stratified ordinal tiers using
intra-sector quartiles. For example, instead of using the raw threshold
of \$59K assets per participant, the model learned from a tiered factor
(Low, Moderate, Typical, High) based on sector-specific distributions.
This separation ensured that models learned relative structural signals
rather than memorizing rule logic.

See **Appendix A** for additional details.

# Stratified Sampling and Data Splits

Given the dominance of a few sectors (e.g., Manufacturing, Professional
Services), I implemented a stratified sampling strategy to ensure
balanced representation. Plans were grouped by sector and vintage, and
sample sizes were proportionally allocated with a minimum floor. Sector
caps were applied to prevent over-representation, resulting in a
structurally balanced sample of 1,665 plans.

| Sector Title    | Plans | Percent |
|:----------------|------:|--------:|
| Information     |   101 |    0.06 |
| Accommodatio…   |   100 |    0.06 |
| Administrati…   |   100 |    0.06 |
| Agriculture,…   |    42 |    0.03 |
| Arts, entert…   |    65 |    0.04 |
| Construction    |   100 |    0.06 |
| Educational …   |    69 |    0.04 |
| Finance and …   |   101 |    0.06 |
| Health care …   |    99 |    0.06 |
| Management o…   |    84 |    0.05 |
| Manufacturing   |   100 |    0.06 |
| Mining, quar…   |    42 |    0.03 |
| Other servic…   |   100 |    0.06 |
| Professional…   |    99 |    0.06 |
| Public admin…   |    10 |    0.01 |
| Real estate …   |    99 |    0.06 |
| Retail trade    |   100 |    0.06 |
| Transportati…   |   100 |    0.06 |
| Utilities       |    54 |    0.03 |
| Wholesale trade |   100 |    0.06 |

Summary By Sector Title - Stratified Sample

I split the sample into training (70%), validation (15%), and test (15%)
sets for model training and evaluation.

| Split      | Adequacy Indicator | Observations | Percent |
|:-----------|-------------------:|-------------:|--------:|
| Train      |                  0 |          615 |    0.53 |
| Train      |                  1 |          551 |    0.47 |
| Validation |                  0 |          132 |    0.53 |
| Validation |                  1 |          118 |    0.47 |
| Test       |                  0 |          131 |    0.53 |
| Test       |                  1 |          118 |    0.47 |

Sample Records by Data Split

Predictor association, multicollinearity checks, subset selection, and
data splitting steps are documented
[here](https://github.com/dtminnick/readiness/blob/main/notebooks/3_multicol_split.md).

# Model Training and Evaluation

I trained and evaluated two classification models:

- **Logistic Regression**: Chosen for interpretability and fairness
  audits.
- **Random Forest**: Used to capture nonlinear relationships and feature
  interactions.

Models were evaluated on training, validation, and test sets using
ROC/AUC curves, confusion matrices, and residual diagnostics. The
logistic model showed consistent generalization and strong
interpretability, while the RF model offered robust classification but
showed signs of overfitting.

| Metric | Logistic Train | RF Train | Logistic Validate | RF Validate | Logistic Test | RF Test |
|:---|---:|---:|---:|---:|---:|---:|
| Accuracy | 0.8894 | 0.9974 | 0.8880 | 0.8640 | 0.8876 | 0.9116 |
| AUC | 0.9582 | 1.0000 | 0.9570 | 0.9492 | 0.9616 | 0.9609 |
| Balanced Accuracy | 0.8885 | 0.9974 | 0.8863 | 0.8649 | 0.8872 | 0.9118 |
| Kappa | 0.7778 | 0.9948 | 0.7747 | 0.7279 | 0.7745 | 0.8230 |
| McnemarPValue | 0.3786 | 1.0000 | 0.3447 | 0.3912 | 1.0000 | 0.8312 |
| Neg Pred Value | 0.8907 | 0.9982 | 0.9018 | 0.8387 | 0.8814 | 0.9000 |
| Pos Pred Value | 0.8882 | 0.9968 | 0.8768 | 0.8889 | 0.8931 | 0.9225 |
| Sensitivity | 0.9041 | 0.9984 | 0.9167 | 0.8485 | 0.8931 | 0.9084 |
| Specificity | 0.8730 | 0.9964 | 0.8559 | 0.8814 | 0.8814 | 0.9153 |

Model Metrics by Model and Data Split

The logistic regression model demonstrated consistent and reliable
performance across all data splits, validating its strength as a
classifier. On the test set, it achieved an AUC of 0.94, balanced
accuracy of 0.88, and a Kappa score of 0.78, indicating strong
discriminatory power and substantial agreement beyond chance.
Sensitivity and specificity remained well-balanced at 0.93 and 0.83,
respectively, confirming the model’s ability to identify both adequate
and inadequate plans without directional bias.

Compared to the random forest model, logistic regression showed lower
training metrics but superior generalization on validation and test
sets. This suggests lower overfitting risk and greater interpretability,
which are key advantages for stakeholder-facing diagnostics. Its stable
performance across splits make it the preferred model for structural
adequacy classification in this context.

Complete model training and evaluation steps are documented
[here](https://github.com/dtminnick/readiness/blob/main/notebooks/4_model_eval.md).

# Misclassification Analysis

Mis-classification analysis revealed that both models performed cleanly
at adequacy score extremes (0, 1, and 6), while errors clustered around
borderline scores (3 and 4). This pattern suggests that models were not
simply reproducing the adequacy score but learning latent structural
signals embedded in the feature space.

| Adequacy Score | Logistic FN | Logistic FP | RF FN | RF FP | Total |
|:---------------|------------:|------------:|------:|------:|------:|
| 0              |           0 |           0 |     0 |     0 |     7 |
| 1              |           0 |           0 |     0 |     1 |    16 |
| 2              |           0 |           1 |     0 |     0 |    48 |
| 3              |           0 |          13 |     0 |    11 |    60 |
| 4              |          12 |           0 |     7 |     0 |    64 |
| 5              |           2 |           0 |     3 |     0 |    33 |
| 6              |           0 |           0 |     0 |     0 |    21 |

Misclassifications on Test Set by Adequacy Score and Model

Misclassification patterns on the test set reveal that both models
performed cleanly at the adequacy score extremes — scores 0, 1, and 6 —
with zero false positives or false negatives. This confirms that strong
adequacy signals were consistently recognized. Errors were concentrated
around borderline scores, particularly at score 3 (just below the
adequacy threshold) and score 4 (just above it).

Both models tended to overclassify score 3 plans as adequate and
underclassify score 4 plans, suggesting they were responding to latent
structural signals rather than rigidly replicating the adequacy score
logic. These patterns reinforce that the models learned nuanced
relationships in the feature space and did not simply memorize the
scoring rubric.

# Feature Importance

Feature importance analysis done as part of model evaluation, from both
the logistic regression and random forest models, reveals complementary
insights into the drivers of predicted adequacy.

The logistic model emphasized directional and contextual signals, with
participant growth and sector affiliation, particularly in Human
Services and Education, strongly associated with inadequacy.

In contrast, the random forest model prioritized contribution dynamics,
identifying participant and employer contribution growth tiers as the
most influential features based on mean decrease in Gini. While
lower-ranked features like loan leakage and asset accumulation played a
role, the dominant signals in the random forest structure were tied to
financial engagement.

Together, these models suggest that adequacy is shaped by both
structural momentum and sector-specific disparities, reinforcing the
need for multifaceted diagnostics in plan evaluation.

# Adequacy By Sector

To surface disparities in predicted retirement plan adequacy across
sectors, I developed a stakeholder-friendly visualization using model
outputs. The following chart displays the proportion of plans classified
as “adequate” or “inadequate” within each sector, revealing clear
structural differences.

![](5_final_report_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

Sectors such as Public Administration, Education, and Finance exhibit
higher adequacy rates, suggesting stronger contribution dynamics and
plan stability. In contrast, sectors like Accommodation & Food Services,
Real Estate, and Arts & Entertainment show elevated inadequacy rates,
pointing to potential gaps in plan design or participant engagement.
This visualization provides a diagnostic lens for identifying sectors
that may warrant targeted review or policy intervention.

# Key Insights and Implications

- Plans with high leakage and low contribution stability were
  consistently flagged as inadequate.
- Sector disparities revealed structural gaps in plan design and
  participant engagement.
- Feature importance diagnostics highlighted that adequacy is shaped by
  both structural momentum and sector-specific disparities.
- The logistic model is preferred for stakeholder-facing diagnostics due
  to its interpretability and consistent performance.

# Model Extension Opportunities

- **Aggregate-Level Data**: Form 5500 filings offer plan-level metrics;
  models can benefit from participant-level insights.
- **Engineered Thresholds**: Adequacy thresholds are heuristic and could
  be refined with stakeholder calibration.
- **Single-Year Snapshot**: Future work could incorporate multi-year
  filings and macroeconomic overlays to assess resilience and trends.

# Appendices

## Appendix A: Adequacy Scoring and Tiered Feature Engineering

### Adequacy Scoring

To classify retirement plans as structurally “adequate” or “inadequate,”
I developed a composite Adequacy Score based on six interpretable
indicators of financial readiness:

- **Assets per Participant**: Is the average account balance above
  \$59,000?
- **Asset Growth Rate**: Did total assets grow by more than 10%?
- **Participant Growth Rate**: Did the number of participants grow by
  more than 3%?
- **Participant Contribution Growth**: Did participant contributions
  grow by more than 10%?
- **Employer Contribution Growth**: Did employer contributions grow by
  more than 7%?
- **Loan Leakage Ratio**: Is the ratio of outstanding loans to total
  assets below 1.3%?

Each condition contributes one point to the Adequacy Score, yielding a
range from 0 to 6. Plans scoring 4 or higher were labeled as “Adequate”,
while others are labeled “Inadequate”.

### Sector-Aware Tiering for Predictive Features

To prevent models from memorizing the adequacy rules and to promote
generalization, I engineered sector-stratified tiered features for
prediction.

Each numeric feature was converted into a quartile-based ordinal factor
within its sector:

| Feature                         | Tier Labels (Low to High)    |
|---------------------------------|------------------------------|
| Assets per Participant          | Low, Moderate, Typical, High |
| Asset Growth Rate               | Low, Moderate, Typical, High |
| Participant Growth Rate         | Low, Moderate, Typical, High |
| Participant Contribution Growth | Low, Moderate, Typical, High |
| Employer Contribution Growth    | Low, Moderate, Typical, High |
| Loan Leakage Ratio              | High, Typical, Moderate, Low |

This tiering approach ensures that models learn relative structural
signals rather than absolute thresholds.
