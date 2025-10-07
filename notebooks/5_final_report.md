``` r
library("knitr")
```

# Pipeline Overview

This project investigates whether employer-sponsored retirement plans
structurally support participant financial readiness. Using 2023 Form
5500 filings, I classify plans as “adequate” or “inadequate” based on
engineered features like participation rate, contribution stability, and
leakage burden. Two models, logistic regression and random forest, were
trained and evaluated for interpretability and diagnostic clarity.

Access \[this markdown
document(<https://github.com/dtminnick/readiness/blob/main/notebooks/1_overview.md>)
from my Github repository for an overview of this project.

# Exploratory Data Analysis and Data Transformation

The baseline dataset includes 5,579 single-employer defined contribution
plans. Initial checks confirmed no missing or zero values, ensuring a
clean foundation for modeling. Feature engineering focused on structural
signals of adequacy: participation rate, contribution per participant,
leakage burden, and asset growth. Plans were grouped into vintage
cohorts based on effective year, and industry codes were collapsed into
broader sectors to support benchmarking and fairness overlays.

Full analysis is documented
(here)\[<https://github.com/dtminnick/readiness/blob/main/notebooks/2_eda_transform.md>\]

# Structural Adequacy Scoring and Tiered Feature Engineering

To classify plans as structurally “adequate,” I developed a composite
adequacy score based on six interpretable indicators: assets per
participant, asset growth, participant growth, contribution growth
(participant and employer), and loan leakage ratio. Each condition
contributes one point, yielding a score from 0 to 6. Plans scoring 4 or
higher were labeled “Adequate.”

To prevent circularity and promote generalization, predictive features
were converted into sector-stratified ordinal tiers using intra-sector
quartiles. For example, instead of using the raw threshold of \$59K
assets per participant, the model learned from a tiered factor (Low,
Moderate, Typical, High) based on sector-specific distributions. This
separation ensured that models learned relative structural signals
rather than memorizing rule logic.

**Insert sample by sector and plot.**

See **Appendix A** for additional details.

# Stratified Sampling and Data Splits

Given the dominance of a few sectors (e.g., Manufacturing, Professional
Services), I implemented a stratified sampling strategy to ensure
balanced representation. Plans were grouped by sector and vintage, and
sample sizes were proportionally allocated with a minimum floor. Sector
caps were applied to prevent over-representation, resulting in a
structurally balanced sample of 1,665 plans across 27 variables.

I split the sample into training (70%), validation (15%), and test (15%)
sets for model training and evaluation.

``` r
data_splits <- readRDS("../data/data_splits.rds")

kable(data_splits,
      col.names = c("Split", "Adequacy Indicator", "Observations", "Percent"),
      caption = "Sample Records by Data Split",
      format.args = list(big.mark = ","),
      align = c("l", "r", "r", "r"))
```

| Split      | Adequacy Indicator | Observations | Percent |
|:-----------|-------------------:|-------------:|--------:|
| Train      |                  0 |          621 |    0.53 |
| Train      |                  1 |          545 |    0.47 |
| Validation |                  0 |          133 |    0.53 |
| Validation |                  1 |          117 |    0.47 |
| Test       |                  0 |          133 |    0.53 |
| Test       |                  1 |          116 |    0.47 |

Sample Records by Data Split

Predictor association, multicollinearity checks, subset selection, and
data splitting steps are documented
(here)\[<https://github.com/dtminnick/readiness/blob/main/notebooks/3_multicol_split.md>\]

# Model Training and Evaluation

Two classification models were trained:

- **Logistic Regression**: Chosen for interpretability and fairness
  audits.
- **Random Forest**: Used to capture nonlinear relationships and feature
  interactions.

Models were evaluated on training, validation, and test sets using
ROC/AUC curves, confusion matrices, and residual diagnostics. The
logistic model showed consistent generalization and strong
interpretability, while the RF model offered robust classification but
showed signs of overfitting.

``` r
model_metrics <- readRDS("../data/model_metrics.rds")

kable(model_metrics,
      col.names = c("Metric", 
                    "Logistic Train", 
                    "RF Train", 
                    "Logistic Validate", 
                    "RF Validate", 
                    "Logistic Test", 
                    "RF Test"),
      caption = "Model Metrics by Model and Data Split",
      format.args = list(big.mark = ","),
      align = c("l", "r", "r", "r", "r", "r", "r"))
```

| Metric | Logistic Train | RF Train | Logistic Validate | RF Validate | Logistic Test | RF Test |
|:---|---:|---:|---:|---:|---:|---:|
| Accuracy | 0.9108 | 0.9648 | 0.8680 | 0.8280 | 0.8795 | 0.8514 |
| AUC | 0.9701 | 0.9958 | 0.9514 | 0.9149 | 0.9349 | 0.9254 |
| Balanced Accuracy | 0.9103 | 0.9644 | 0.8671 | 0.8278 | 0.8783 | 0.8508 |
| Kappa | 0.8210 | 0.9294 | 0.7351 | 0.6553 | 0.7580 | 0.7019 |
| McnemarPValue | 0.6239 | 0.3487 | 0.7277 | 1.0000 | 0.5839 | 1.0000 |
| Neg Pred Value | 0.9104 | 0.9689 | 0.8707 | 0.8167 | 0.8860 | 0.8462 |
| Pos Pred Value | 0.9111 | 0.9613 | 0.8657 | 0.8385 | 0.8741 | 0.8561 |
| Sensitivity | 0.9201 | 0.9723 | 0.8855 | 0.8321 | 0.9008 | 0.8626 |
| Specificity | 0.9005 | 0.9566 | 0.8487 | 0.8235 | 0.8559 | 0.8390 |

Model Metrics by Model and Data Split

The logistic regression model demonstrated consistent and reliable
performance across all data splits, validating its strength as a
classifier. On the test set, it achieved an AUC of 0.935, balanced
accuracy of 0.878, and a Kappa score of 0.758, indicating strong
discriminatory power and substantial agreement beyond chance.
Sensitivity and specificity remained well-balanced at 0.901 and 0.856,
respectively, confirming the model’s ability to identify both adequate
and inadequate plans without directional bias (Mcnemar p-value: 0.584).

Compared to the random forest model, logistic regression showed slightly
lower training metrics but superior generalization on validation and
test sets. This suggests lower overfitting risk and greater
interpretability, which are key advantages for stakeholder-facing
diagnostics. Its stable performance across splits make it the preferred
model for structural adequacy classification in this context.

Complete model training and evaluation steps are documented
(here)\[<https://github.com/dtminnick/readiness/blob/main/notebooks/4_model_eval.md>\]

# Misclassification Analysis

Misclassification analysis revealed that both models performed cleanly
at adequacy score extremes (0, 1, and 6), while errors clustered around
borderline scores (3 and 4). This pattern suggests that models were not
simply reproducing the adequacy score but learning latent structural
signals embedded in the feature space.

``` r
check_class_summary <- readRDS("../data/check_class_summary.rds")

kable(check_class_summary,
      col.names = c("Adequacy Score", 
                    "Logistic FN", 
                    "Logistic FP", 
                    "RF FN", 
                    "RF FP", 
                    "Total"),
      caption = "Misclassifications on Test Set by Adequacy Score and Model",
      format.args = list(big.mark = ","),
      align = c("l", "r", "r", "r", "r", "r"))
```

| Adequacy Score | Logistic FN | Logistic FP | RF FN | RF FP | Total |
|:---------------|------------:|------------:|------:|------:|------:|
| 0              |           0 |           0 |     0 |     0 |     9 |
| 1              |           0 |           0 |     0 |     0 |    21 |
| 2              |           0 |           0 |     0 |     3 |    43 |
| 3              |           0 |          13 |     0 |    15 |    58 |
| 4              |          16 |           0 |    18 |     0 |    70 |
| 5              |           1 |           0 |     1 |     0 |    34 |
| 6              |           0 |           0 |     0 |     0 |    14 |

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

# Key Insights and Implications

- Plans with high leakage and low contribution stability were
  consistently flagged as inadequate.
- Sector disparities revealed structural gaps in plan design and
  participant engagement.
- Feature importance diagnostics highlighted participation rate and
  leakage burden as dominant signals.
- The logistic model is preferred for stakeholder-facing diagnostics due
  to its interpretability and consistent performance.

# Model Extention Opportunities

- **Aggregate-Level Data**: Form 5500 filings offer plan-level metrics,
  not participant-level insights.
- **Engineered Thresholds**: Adequacy thresholds are heuristic and could
  benefit from stakeholder calibration.
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
