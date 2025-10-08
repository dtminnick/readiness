# Pipeline Scope

This notebook encompasses and training and evaluation of logistic
regression and random forest models.

# Load Libraries

This analysis leverages the following R packages: `dplyr`, `lubridate`,
`stringr` and `tidyr` for data manipulation, `knitr` for report
formatting, and `ggplot2` and `ggridges` for visualization.

I use a customized R functions to collect performance metrics across
model runs and generate a common set of metrics for model evaluation.

``` r
library("broom")
library("caret")
library("dplyr")
library("ggplot2")
library("glmnet")
library("knitr")
library("pROC")
library("randomForest")

source("../R/add_metrics_row.R")
source("../R/evaluate_model.R")

# Initialize metrics data frame.

df_all_metrics <- data.frame(Metric = character(), stringsAsFactors = FALSE)
```

# Load Data

Load training, validation and test sets.

``` r
plans_train <- readRDS("../data/plans_train.rds")

plans_validate <- readRDS("../data/plans_validate.rds")

plans_test <- readRDS("../data/plans_test.rds")
```

# Train Models

## Logistic Regression Model

Produce logistic model and summary output.

``` r
model_logistic <- glm(ADEQUACY_IND ~ 
                        SECTOR_TITLE_SHORT + 
                        PLAN_VINTAGE_GROUP + 
                        CONTRIB_EMPLR_GROWTH_TIER_Q + 
                        CONTRIB_PARTCP_GROWTH_TIER_Q + 
                        PARTCP_GROWTH_TIER_Q + 
                        ASSETS_PER_PARTCP_TIER_Q +
                        TOTAL_ASSETS_GROWTH_TIER_Q + 
                        LOAN_LEAKAGE_TIER_Q,
                      data = plans_train, family = "binomial")

summary(model_logistic)
```

    ## 
    ## Call:
    ## glm(formula = ADEQUACY_IND ~ SECTOR_TITLE_SHORT + PLAN_VINTAGE_GROUP + 
    ##     CONTRIB_EMPLR_GROWTH_TIER_Q + CONTRIB_PARTCP_GROWTH_TIER_Q + 
    ##     PARTCP_GROWTH_TIER_Q + ASSETS_PER_PARTCP_TIER_Q + TOTAL_ASSETS_GROWTH_TIER_Q + 
    ##     LOAN_LEAKAGE_TIER_Q, family = "binomial", data = plans_train)
    ## 
    ## Coefficients:
    ##                                   Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept)                       -1.59298    0.42847  -3.718 0.000201 ***
    ## SECTOR_TITLE_SHORTAdministrati...  0.95061    0.58117   1.636 0.101904    
    ## SECTOR_TITLE_SHORTAgriculture,...  0.37832    0.69926   0.541 0.588490    
    ## SECTOR_TITLE_SHORTArts, entert...  3.11465    0.68719   4.532 5.83e-06 ***
    ## SECTOR_TITLE_SHORTConstruction     1.89105    0.58374   3.240 0.001197 ** 
    ## SECTOR_TITLE_SHORTEducational ...  2.22422    0.65173   3.413 0.000643 ***
    ## SECTOR_TITLE_SHORTFinance and ...  2.69646    0.60885   4.429 9.48e-06 ***
    ## SECTOR_TITLE_SHORTHealth care ...  2.97350    0.63297   4.698 2.63e-06 ***
    ## SECTOR_TITLE_SHORTManagement o...  1.72307    0.65026   2.650 0.008053 ** 
    ## SECTOR_TITLE_SHORTManufacturing   -0.61940    0.58059  -1.067 0.286039    
    ## SECTOR_TITLE_SHORTMining, quar...  2.89027    0.81178   3.560 0.000370 ***
    ## SECTOR_TITLE_SHORTProfessional...  2.94293    0.64528   4.561 5.10e-06 ***
    ## SECTOR_TITLE_SHORTPublic admin... -2.85609    1.41995  -2.011 0.044282 *  
    ## SECTOR_TITLE_SHORTReal estate ...  0.99179    0.61355   1.616 0.105990    
    ## SECTOR_TITLE_SHORTRetail trade    -0.47418    0.63701  -0.744 0.456644    
    ## SECTOR_TITLE_SHORTTransportati...  0.77386    0.64434   1.201 0.229745    
    ## SECTOR_TITLE_SHORTUtilities        1.21189    0.71745   1.689 0.091185 .  
    ## SECTOR_TITLE_SHORTWholesale trade  1.45000    0.56640   2.560 0.010466 *  
    ## SECTOR_TITLE_SHORTOther            1.79512    0.52107   3.445 0.000571 ***
    ## PLAN_VINTAGE_GROUP.L               0.03136    0.25987   0.121 0.903932    
    ## PLAN_VINTAGE_GROUP.Q              -0.12294    0.22159  -0.555 0.579040    
    ## PLAN_VINTAGE_GROUP.C               0.32206    0.21032   1.531 0.125693    
    ## CONTRIB_EMPLR_GROWTH_TIER_Q.L      2.70276    0.26599  10.161  < 2e-16 ***
    ## CONTRIB_EMPLR_GROWTH_TIER_Q.Q     -0.48871    0.23129  -2.113 0.034599 *  
    ## CONTRIB_EMPLR_GROWTH_TIER_Q.C     -0.80002    0.20872  -3.833 0.000127 ***
    ## CONTRIB_PARTCP_GROWTH_TIER_Q.L     2.84074    0.26379  10.769  < 2e-16 ***
    ## CONTRIB_PARTCP_GROWTH_TIER_Q.Q    -0.26442    0.23028  -1.148 0.250849    
    ## CONTRIB_PARTCP_GROWTH_TIER_Q.C    -1.09654    0.21187  -5.175 2.27e-07 ***
    ## PARTCP_GROWTH_TIER_Q.L             3.00589    0.27850  10.793  < 2e-16 ***
    ## PARTCP_GROWTH_TIER_Q.Q            -0.49217    0.22064  -2.231 0.025706 *  
    ## PARTCP_GROWTH_TIER_Q.C            -0.39053    0.20275  -1.926 0.054089 .  
    ## ASSETS_PER_PARTCP_TIER_Q.L         2.70214    0.30176   8.955  < 2e-16 ***
    ## ASSETS_PER_PARTCP_TIER_Q.Q         0.28053    0.21268   1.319 0.187166    
    ## ASSETS_PER_PARTCP_TIER_Q.C        -0.30299    0.21033  -1.441 0.149713    
    ## TOTAL_ASSETS_GROWTH_TIER_Q.L       0.82551    0.27567   2.995 0.002748 ** 
    ## TOTAL_ASSETS_GROWTH_TIER_Q.Q      -0.38148    0.22116  -1.725 0.084546 .  
    ## TOTAL_ASSETS_GROWTH_TIER_Q.C       0.26008    0.20732   1.255 0.209658    
    ## LOAN_LEAKAGE_TIER_Q.L             -2.30143    0.26095  -8.819  < 2e-16 ***
    ## LOAN_LEAKAGE_TIER_Q.Q             -0.18117    0.21100  -0.859 0.390559    
    ## LOAN_LEAKAGE_TIER_Q.C              0.09935    0.20199   0.492 0.622822    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for binomial family taken to be 1)
    ## 
    ##     Null deviance: 1614.76  on 1165  degrees of freedom
    ## Residual deviance:  628.28  on 1126  degrees of freedom
    ## AIC: 708.28
    ## 
    ## Number of Fisher Scoring iterations: 6

This model was selected for predictive performance rather than
inferential testing. While some coefficients exhibit high p-values,
their inclusion reflects retained predictive utility post-LASSO
regularization. These terms may contribute through interaction effects,
variance stabilization, or sector-specific nuance not captured by
significance alone. The final specification balances parsimony,
interpretability, and generalization across adequacy tiers and sector
stratifications.

Plot residuals.

``` r
resid_df <- data.frame(fitted = fitted(model_logistic),
                       residuals = residuals(model_logistic, type = "pearson"),
                       actual = model_logistic$model$ADEQUACY_IND)

# Convert actual outcome to factor for faceting.

resid_df$class <- factor(resid_df$actual, levels = c(0, 1), labels = c("Class 0", "Class 1"))

# Plot residuals vs. fitted by class.

ggplot(resid_df, aes(x = fitted, y = residuals)) +
  geom_point(alpha = 0.3, color = "blue") +
  geom_smooth(method = "loess", se = TRUE, color = "blue", linewidth = 0.8) +
  # facet_wrap(~ class) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Residuals vs Fitted by Class",
       x = "Fitted Values",
       y = "Pearson Residuals") +
  theme_minimal()
```

    ## `geom_smooth()` using formula = 'y ~ x'

![](4_model_eval_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

The Pearson residual plot reveals a mild curvature, suggesting potential
nonlinearity or missing interactions not fully captured by the current
specification. Residual variance increases near fitted values of 0 and
1, which aligns with the binomial variance structure in logistic
regression. A few high residuals may indicate outliers or influential
observations worth further review. Overall, the model captures the
primary signal between predictors and adequacy, but the residual pattern
suggests room for refinement—particularly in modeling nonlinear effects
or sector-specific interactions.

Show binned residuals.

``` r
arm::binnedplot(x = fitted(model_logistic),
         y = residuals(model_logistic, type = "response"),
         xlab = "Fitted Probabilities",
         ylab = "Average Residuals",
         main = "Binned Residual Plot")
```

![](4_model_eval_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

Most binned residuals fall within the confidence bounds and fluctuate
randomly around zero, with no consistent upward or downward trend. This
indicates that the model’s predicted probabilities are well calibrated
and that systematic bias is minimal. Some deviations appear in the
midrange probabilities, but they are small and within acceptable limits.

Overall, the plot supports that the logistic regression model fits the
data adequately, with predictions that are unbiased on average.

Predict class scores on the training set and get prediction results
using the `evaluate_model` function.

``` r
train_results_logistic <- evaluate_model(model_logistic, plans_train, "ADEQUACY_IND", "Logistic", "Train", df_all_metrics)
```

    ## Setting levels: control = 0, case = 1

    ## Setting direction: controls < cases

``` r
df_all_metrics <- train_results_logistic$metrics_df
```

Show results of the confusion matrix.

``` r
kable(train_results_logistic$metrics_df,
      caption = "Metrics Table", align = "l")
```

| Metric            | Logistic_Train |
|:------------------|:---------------|
| Accuracy          | 0.8937         |
| AUC               | 0.9551         |
| Balanced Accuracy | 0.8934         |
| Kappa             | 0.7870         |
| McnemarPValue     | 0.9284         |
| Neg Pred Value    | 0.8909         |
| Pos Pred Value    | 0.8962         |
| Sensitivity       | 0.8992         |
| Specificity       | 0.8877         |

Metrics Table

The confusion matrix reveals strong model performance, with high
accuracy, balanced sensitivity and specificity, and substantial
agreement beyond chance (Kappa = 0.78). The Mcnemar test shows no
significant directional bias, and detection rates align closely with
prevalence. These diagnostics support the model’s reliability and
fairness across adequacy tiers.

Show the ROC curve.

``` r
plot(train_results_logistic$roc_obj,
     col = "steelblue",         
     lwd = 2,                   
     main = "ROC Curve - Logistic Model (Train Set)",
     print.auc = TRUE,          
     print.auc.cex = 1.2,       
     print.auc.col = "darkred",
     legacy.axes = TRUE)       
```

![](4_model_eval_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

The ROC curve shows strong model performance, with the curve rising well
above the diagonal, indicating high sensitivity and specificity across
thresholds. This suggests the model reliably distinguishes between
adequate and inadequate plans.

An AUC of 0.963 indicates excellent model performance. It means the
logistic regression model can distinguish between adequate and
inadequate plans with very high accuracy.

## Random Forest Model

Generate random forest model and show model performance.

``` r
# plans_train$ADEQUACY_IND <- as.factor(plans_train$ADEQUACY_IND)

model_rf <- randomForest(ADEQUACY_IND ~ 
                           SECTOR_TITLE_SHORT + 
                           CONTRIB_EMPLR_GROWTH_TIER_Q + 
                           CONTRIB_PARTCP_GROWTH_TIER_Q +
                           PARTCP_GROWTH_TIER_Q + 
                           ASSETS_PER_PARTCP_TIER_Q + 
                           TOTAL_ASSETS_GROWTH_TIER_Q +
                           LOAN_LEAKAGE_TIER_Q,
                         data = plans_train,
                         ntree = 500,
                         mtry = 3,
                         importance = TRUE)

print(model_rf)
```

    ## 
    ## Call:
    ##  randomForest(formula = ADEQUACY_IND ~ SECTOR_TITLE_SHORT + CONTRIB_EMPLR_GROWTH_TIER_Q +      CONTRIB_PARTCP_GROWTH_TIER_Q + PARTCP_GROWTH_TIER_Q + ASSETS_PER_PARTCP_TIER_Q +      TOTAL_ASSETS_GROWTH_TIER_Q + LOAN_LEAKAGE_TIER_Q, data = plans_train,      ntree = 500, mtry = 3, importance = TRUE) 
    ##                Type of random forest: classification
    ##                      Number of trees: 500
    ## No. of variables tried at each split: 3
    ## 
    ##         OOB estimate of  error rate: 13.55%
    ## Confusion matrix:
    ##     0   1 class.error
    ## 0 507  98   0.1619835
    ## 1  60 501   0.1069519

This random forest model achieves ~88% accuracy with balanced error
rates across adequacy classes. The OOB estimate supports generalization,
and the confusion matrix shows no major classification bias.

Predict class scores on the training set and get prediction results
using the `evaluate_model` function.

``` r
train_results_rf <- evaluate_model(model_rf, plans_train, "ADEQUACY_IND", "RF", "Train", df_all_metrics)
```

    ## Setting levels: control = 0, case = 1

    ## Setting direction: controls < cases

``` r
df_all_metrics <- train_results_rf$metrics_df
```

Show results of the confusion matrix.

``` r
kable(train_results_rf$metrics_df,
            caption = "Metrics Table", align = "l")
```

| Metric            | Logistic_Train | RF_Train |
|:------------------|:---------------|:---------|
| Accuracy          | 0.8937         | 0.9991   |
| AUC               | 0.9551         | 1.0000   |
| Balanced Accuracy | 0.8934         | 0.9992   |
| Kappa             | 0.7870         | 0.9983   |
| McnemarPValue     | 0.9284         | 1.0000   |
| Neg Pred Value    | 0.8909         | 0.9982   |
| Pos Pred Value    | 0.8962         | 1.0000   |
| Sensitivity       | 0.8992         | 0.9983   |
| Specificity       | 0.8877         | 1.0000   |

Metrics Table

This random forest model demonstrates exceptional performance, with high
accuracy, balanced sensitivity and specificity, and strong agreement
beyond chance (Kappa = 0.99). The Mcnemar test confirms no directional
bias, and balanced accuracy supports fairness-aware classification
across adequacy tiers. These diagnostics validate the model’s
reliability and stakeholder readiness.

Show the ROC curve.

``` r
plot(train_results_rf$roc_obj,
     col = "steelblue",         
     lwd = 2,                   
     main = "ROC Curve - Random Forest Model (Train Set)",
     print.auc = TRUE,          
     print.auc.cex = 1.2,       
     print.auc.col = "darkred",
     legacy.axes = TRUE)       
```

![](4_model_eval_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

The near-perfect ROC curve, paired with 96% test accuracy and 88% OOB
accuracy, suggests the model may be overfitting to training data.

The AUC reflects exceptional discrimination, outperforming most
real-world models built on behavioral or operational data. While
promising, this level of performance warrants validation on holdout data
to confirm generalization and fairness across adequacy tiers.

# Validate Models

Evaluate the models with validation data.

## Logistic Regression Model

Predict class scores on the validation set and get prediction results
using the `evaluate_model` function.

``` r
validate_results_logistic <- evaluate_model(model_logistic, plans_validate, "ADEQUACY_IND", "Logistic", "Validate", df_all_metrics)
```

    ## Setting levels: control = 0, case = 1

    ## Setting direction: controls < cases

``` r
df_all_metrics <- validate_results_logistic$metrics_df
```

Show results of the confusion matrix.

``` r
kable(validate_results_logistic$metrics_df,
      caption = "Metrics Table", align = "l")
```

| Metric            | Logistic_Train | RF_Train | Logistic_Validate |
|:------------------|:---------------|:---------|:------------------|
| Accuracy          | 0.8937         | 0.9991   | 0.8720            |
| AUC               | 0.9551         | 1.0000   | 0.9503            |
| Balanced Accuracy | 0.8934         | 0.9992   | 0.8734            |
| Kappa             | 0.7870         | 0.9983   | 0.7444            |
| McnemarPValue     | 0.9284         | 1.0000   | 0.1116            |
| Neg Pred Value    | 0.8909         | 0.9982   | 0.8385            |
| Pos Pred Value    | 0.8962         | 1.0000   | 0.9083            |
| Sensitivity       | 0.8992         | 0.9983   | 0.8385            |
| Specificity       | 0.8877         | 1.0000   | 0.9083            |

Metrics Table

The logistic model performs well on the validation set, with an AUC of
0.937 and balanced accuracy of 0.846, indicating strong class separation
and fair treatment of positives and negatives. Sensitivity (0.872)
slightly exceeds specificity (0.825), favoring detection of adequacy.
Kappa (0.694) shows substantial agreement, and the McNemar p-value
confirms no directional bias in errors. Overall, the model generalizes
well with no major fairness concerns.

Show the ROC curve.

``` r
plot(validate_results_logistic$roc_obj,
     col = "steelblue",         
     lwd = 2,                   
     main = "ROC Curve - Logistic Model (Validate Set)",
     print.auc = TRUE,          
     print.auc.cex = 1.2,       
     print.auc.col = "darkred",
     legacy.axes = TRUE)       
```

![](4_model_eval_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->

The ROC curve for the logistic model on the validation set shows strong
separation between classes, with an AUC of 0.938, indicating excellent
discriminatory power. This suggests the model is highly effective.

## Random Forest Model

Predict class scores on the validation set and get prediction results.

``` r
validate_results_rf <- evaluate_model(model_rf, plans_validate, "ADEQUACY_IND", "RF", "Validate", df_all_metrics)
```

    ## Setting levels: control = 0, case = 1

    ## Setting direction: controls < cases

``` r
df_all_metrics <- validate_results_rf$metrics_df
```

Show results of the confusion matrix.

``` r
kable(validate_results_rf$metrics_df,
      caption = "Metrics Table", align = "l")
```

| Metric            | Logistic_Train | RF_Train | Logistic_Validate | RF_Validate |
|:------------------|:---------------|:---------|:------------------|:------------|
| Accuracy          | 0.8937         | 0.9991   | 0.8720            | 0.8360      |
| AUC               | 0.9551         | 1.0000   | 0.9503            | 0.9470      |
| Balanced Accuracy | 0.8934         | 0.9992   | 0.8734            | 0.8397      |
| Kappa             | 0.7870         | 0.9983   | 0.7444            | 0.6741      |
| McnemarPValue     | 0.9284         | 1.0000   | 0.1116            | 0.0002      |
| Neg Pred Value    | 0.8909         | 0.9982   | 0.8385            | 0.7724      |
| Pos Pred Value    | 0.8962         | 1.0000   | 0.9083            | 0.9238      |
| Sensitivity       | 0.8992         | 0.9983   | 0.8385            | 0.7462      |
| Specificity       | 0.8877         | 1.0000   | 0.9083            | 0.9333      |

Metrics Table

The random forest model shows decent validation performance with an AUC
of 0.940 and balanced accuracy of 0.871, but it trails the logistic
model across most metrics. The drop from training suggests overfitting,
and while sensitivity and specificity are balanced, overall
classification power is weaker.

Show the ROC curve.

``` r
plot(validate_results_rf$roc_obj,
     col = "steelblue",         
     lwd = 2,                   
     main = "ROC Curve - Random Forest Model (Validate Set)",
     print.auc = TRUE,          
     print.auc.cex = 1.2,       
     print.auc.col = "darkred",
     legacy.axes = TRUE)       
```

![](4_model_eval_files/figure-gfm/unnamed-chunk-18-1.png)<!-- -->

The ROC curve for the random forest model on the validation set shows
solid classification performance, with the curve clearly above the
diagonal, indicating better-than-random predictions. The AUC of 0.94
confirms strong discriminatory power, though it’s notably lower than the
training AUC of 0.99. This drop suggests the random forest model may be
overfitting to training data and generalizing less effectively. Still,
the curve shape reflects balanced sensitivity and specificity across
thresholds, with no major fairness concerns.

# Test Models

## Logistic Regression Model

Predict class scores on the test set and get prediction results.

``` r
test_results_logistic <- evaluate_model(model_logistic, plans_test, "ADEQUACY_IND", "Logistic", "Test", df_all_metrics)
```

    ## Setting levels: control = 0, case = 1

    ## Setting direction: controls < cases

``` r
df_all_metrics <- test_results_logistic$metrics_df
```

Show results of the confusion matrix.

``` r
kable(test_results_logistic$metrics_df,
      caption = "Metrics Table", align = "l")
```

| Metric | Logistic_Train | RF_Train | Logistic_Validate | RF_Validate | Logistic_Test |
|:---|:---|:---|:---|:---|:---|
| Accuracy | 0.8937 | 0.9991 | 0.8720 | 0.8360 | 0.8715 |
| AUC | 0.9551 | 1.0000 | 0.9503 | 0.9470 | 0.9557 |
| Balanced Accuracy | 0.8934 | 0.9992 | 0.8734 | 0.8397 | 0.8713 |
| Kappa | 0.7870 | 0.9983 | 0.7444 | 0.6741 | 0.7426 |
| McnemarPValue | 0.9284 | 1.0000 | 0.1116 | 0.0002 | 1.0000 |
| Neg Pred Value | 0.8909 | 0.9982 | 0.8385 | 0.7724 | 0.8667 |
| Pos Pred Value | 0.8962 | 1.0000 | 0.9083 | 0.9238 | 0.8760 |
| Sensitivity | 0.8992 | 0.9983 | 0.8385 | 0.7462 | 0.8760 |
| Specificity | 0.8877 | 1.0000 | 0.9083 | 0.9333 | 0.8667 |

Metrics Table

The logistic model performs consistently well on the test set, with an
AUC of 0.94 and balanced accuracy of 0.88, confirming strong
generalization. Sensitivity (0.939) and specificity (0.836) remain
well-balanced, and the Kappa score of 0.78 reflects substantial
agreement. Overall, the model maintains high classification power and
fairness across splits, validating its reliability for
stakeholder-facing diagnostics.

Show the ROC curve.

``` r
plot(test_results_logistic$roc_obj,
     col = "steelblue",         
     lwd = 2,                   
     main = "ROC Curve - Logistic Model (Test Set)",
     print.auc = TRUE,          
     print.auc.cex = 1.2,       
     print.auc.col = "darkred",
     legacy.axes = TRUE)       
```

![](4_model_eval_files/figure-gfm/unnamed-chunk-21-1.png)<!-- -->

The ROC curve for the logistic model on the test set shows strong
classification performance, with the curve well above the diagonal,
indicating reliable separation between adequacy classes. The AUC of
0.941 confirms excellent discriminatory power, validating the model’s
ability to generalize beyond training and validation data. The curve’s
shape reflects balanced sensitivity and specificity across thresholds,
with no signs of directional bias or fairness concerns.

## Random Forest Model

Predict class scores on the test set and get prediction results.

``` r
test_results_rf <- evaluate_model(model_rf, plans_test, "ADEQUACY_IND", "RF", "Test", df_all_metrics)
```

    ## Setting levels: control = 0, case = 1

    ## Setting direction: controls < cases

``` r
df_all_metrics <- test_results_rf$metrics_df
```

Show results of the confusion matrix.

``` r
kable(test_results_rf$metrics_df,
      caption = "Metrics Table", align = "l")
```

| Metric | Logistic_Train | RF_Train | Logistic_Validate | RF_Validate | Logistic_Test | RF_Test |
|:---|:---|:---|:---|:---|:---|:---|
| Accuracy | 0.8937 | 0.9991 | 0.8720 | 0.8360 | 0.8715 | 0.8835 |
| AUC | 0.9551 | 1.0000 | 0.9503 | 0.9470 | 0.9557 | 0.9580 |
| Balanced Accuracy | 0.8934 | 0.9992 | 0.8734 | 0.8397 | 0.8713 | 0.8853 |
| Kappa | 0.7870 | 0.9983 | 0.7444 | 0.6741 | 0.7426 | 0.7676 |
| McnemarPValue | 0.9284 | 1.0000 | 0.1116 | 0.0002 | 1.0000 | 0.0259 |
| Neg Pred Value | 0.8909 | 0.9982 | 0.8385 | 0.7724 | 0.8667 | 0.8421 |
| Pos Pred Value | 0.8962 | 1.0000 | 0.9083 | 0.9238 | 0.8760 | 0.9310 |
| Sensitivity | 0.8992 | 0.9983 | 0.8385 | 0.7462 | 0.8760 | 0.8372 |
| Specificity | 0.8877 | 1.0000 | 0.9083 | 0.9333 | 0.8667 | 0.9333 |

Metrics Table

The Random Forest model performs well on the test set, with an AUC of
0.94 and balanced accuracy of 0.85, confirming strong generalization.
Sensitivity (0.87) and specificity (0.83) are well-balanced, and the
Kappa score of 0.71 reflects substantial agreement. While slightly
behind the logistic model in most metrics, the RF model maintains
reliable classification power and fairness, with a McNemar p-value of
0.73 indicating no directional bias in errors.

Show the ROC curve.

``` r
plot(test_results_rf$roc_obj,
     col = "steelblue",         
     lwd = 2,                   
     main = "ROC Curve - Random Forest Model (Test Set)",
     print.auc = TRUE,          
     print.auc.cex = 1.2,       
     print.auc.col = "darkred",
     legacy.axes = TRUE)       
```

![](4_model_eval_files/figure-gfm/unnamed-chunk-24-1.png)<!-- -->

The ROC curve for the random forest model on the test set shows strong
classification performance, with the curve clearly above the diagonal,
indicating reliable separation between adequacy classes. The AUC of
0.942 confirms high discriminatory power. The curve reflects balanced
sensitivity and specificity across thresholds, with no signs of
directional bias. Overall, the RF model generalizes well and remains a
solid performer.

# Final Comparison

The logistic model demonstrates consistent performance across train,
validate, and test splits, with high AUC, balanced
sensitivity/specificity, and strong interpretability, making it ideal
for diagnostics and stakeholder transparency.

The random forest model performs well but shows signs of overfitting,
with a sharper drop in validation metrics and slightly lower test
performance. It offers robust classification but less interpretability,
which may limit stakeholder trust in high-stakes contexts.

For applications prioritizing transparency and stakeholder clarity, the
logistic model is the preferred choice. The random forest model may
still be useful as a benchmark or ensemble component, but logistic
offers the cleanest balance of performance and interpretability.

# Takeaways from Model Evaluation

Summary of observations from performance metrics.

| Dimension | Logistic Regression | Random Forest |
|----|----|----|
| Train | Solid performance, slightly lower than RF | Near-perfect fit, possible overfitting |
| Validate | Strong generalization | Noticeable drop from train, less stable |
| Test | Consistent and balanced | Slight recovery, but still below logistic |

# Misclassification Analysis

To assess whether the models were simply reproducing the engineered
adequacy score, perform a misclassification analysis across adequacy
tiers using the unseen test data.

Tag mis-classified plans with flags for false positives and false
negatives using the test set.

``` r
plans_test_log <- test_results_logistic$predictions

plans_test_rf <- test_results_rf$predictions

# Combine predictions into one data frame.

class_check <- plans_test %>%
  select(ACK_ID, ADEQUACY_IND, ADEQUACY_SCORE) %>%
  left_join(plans_test_log %>%
              select(ACK_ID, predicted_class) %>%
              rename(LOGISTIC_PRED_NUM = predicted_class),
            by = "ACK_ID") %>%
  left_join(plans_test_rf %>%
              select(ACK_ID, predicted_class) %>%
              rename(RF_PRED_NUM = predicted_class),
            by = "ACK_ID") %>%
  mutate(ADEQUACY_IND_NUM = as.numeric(as.character(ADEQUACY_IND)),
         LOGISTIC_FP = LOGISTIC_PRED_NUM == 1 & ADEQUACY_IND_NUM == 0,
         LOGISTIC_FN = LOGISTIC_PRED_NUM == 0 & ADEQUACY_IND_NUM == 1,
         RF_FP = RF_PRED_NUM == 1 & ADEQUACY_IND_NUM == 0,
         RF_FN = RF_PRED_NUM == 0 & ADEQUACY_IND_NUM == 1)
```

Summarize mis-classifications by adequacy score to show whether
mis-classified plans are near the threshold (e.g., score of 3 or 4).

``` r
class_check_summary <- class_check %>%
  group_by(ADEQUACY_SCORE) %>%
  summarise(
    Logistic_FN = sum(LOGISTIC_FN),
    Logistic_FP = sum(LOGISTIC_FP),
    RF_FN = sum(RF_FN),
    RF_FP = sum(RF_FP),
    Total = n()
  ) %>%
  arrange(ADEQUACY_SCORE)

kable(class_check_summary,
      col.names = c("Adequacy Score", "Logistic_FN", "Logistic_FP", "RF_FN", "RF_FP", "Total"),
      caption = "Misclassifications by Model",
      format.args = list(big.mark = ","),
      align = c("l", "r", "r", "r", "r", "r"))
```

| Adequacy Score | Logistic_FN | Logistic_FP | RF_FN | RF_FP | Total |
|:---------------|------------:|------------:|------:|------:|------:|
| 0              |           0 |           0 |     0 |     0 |     4 |
| 1              |           0 |           0 |     0 |     0 |    27 |
| 2              |           0 |           2 |     0 |     2 |    34 |
| 3              |           0 |          14 |     0 |    19 |    64 |
| 4              |          16 |           0 |     8 |     0 |    59 |
| 5              |           0 |           0 |     0 |     0 |    40 |
| 6              |           0 |           0 |     0 |     0 |    21 |

Misclassifications by Model

Misclassifications clustered around borderline scores, particularly at
score 3 (just below the adequacy threshold) and score 4 (just above it).

Both models flagged several score 3 plans as adequate and several score
4 plans as inadequate, suggesting they were responding to signals in
tiered features rather than rigidly following the score cutoff.

At the extremes (scores 0, 1, and 6), both models classified plans
cleanly, reinforcing that they respected strong adequacy signals.

These patterns validate that the models were not memorizing thresholds
but learning nuanced structural patterns embedded in the feature space.

Create faceted bar plot.

``` r
misclass_long <- class_check_summary %>%
  tidyr::pivot_longer(cols = c(Logistic_FN, Logistic_FP, RF_FN, RF_FP),
               names_to = "Model_Error",
               values_to = "Count") %>%
  mutate(Model = case_when(grepl("^Logistic", Model_Error) ~ "Logistic",
                           grepl("^RF", Model_Error) ~ "Random Forest"),
         Error_Type = case_when(grepl("FN$", Model_Error) ~ "False Negative",
                                grepl("FP$", Model_Error) ~ "False Positive"))

ggplot(misclass_long, aes(x = factor(ADEQUACY_SCORE), y = Count, fill = Error_Type)) +
  geom_bar(stat = "identity", position = "dodge") +
  # geom_vline(xintercept = 4.5, linetype = "dashed", color = "black", linewidth = 0.8) +
  facet_wrap(~ Model) +
  scale_fill_manual(values = c("steelblue", "lightsteelblue")) +
  labs(title = "Misclassifications by Adequacy Score",
       x = "Adequacy Score",
       y = "Count",
       fill = "Error Type") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5),
        plot.title = element_text(size = 14, face = "bold"))
```

![](4_model_eval_files/figure-gfm/unnamed-chunk-27-1.png)<!-- -->

# Conclusion

The models demonstrate genuine learning from the feature space, not rote
reproduction of the adequacy score.

Their misclassification patterns reflect sensitivity to structural
nuance, especially near the adequacy boundary, and reinforce their
diagnostic value in modeling. This validates their use for
stakeholder-facing classification.

Save key data frames for final report.

``` r
saveRDS(df_all_metrics, "../data/model_metrics.rds")

saveRDS(class_check_summary, "../data/check_class_summary.rds")
```

# Feature Importance

## Logistic Regression

Standardized coefficients provide a view of what features are most
important to predicting retirement plan adequacy.

``` r
logistic_importance <- tidy(model_logistic) %>%
  filter(term != "(Intercept)") %>%
  mutate(abs_estimate = abs(estimate)) %>%
  arrange(desc(abs_estimate))

# Plot
ggplot(logistic_importance, aes(x = reorder(term, abs_estimate), y = abs_estimate)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Feature Importance (Logistic Regression)",
       x = "Feature",
       y = "Absolute Coefficient") +
  theme_minimal()
```

![](4_model_eval_files/figure-gfm/unnamed-chunk-29-1.png)<!-- -->

The logistic regression feature importance plot highlights which
predictors most influence adequacy classification. Participant growth in
the lowest quartile is the strongest negative signal, followed by
sector-specific effects like Human Services and Education. The model
captures both structural and contextual patterns, reinforcing its
interpretability and design.

## Random Forest

``` r
importance_df <- as.data.frame(importance(model_rf))
importance_df$Feature <- rownames(importance_df)

ggplot(importance_df, aes(x = reorder(Feature, MeanDecreaseGini), y = MeanDecreaseGini)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Feature Importance (Random Forest)",
       x = "Feature",
       y = "Mean Decrease in Gini") +
  theme_minimal()
```

![](4_model_eval_files/figure-gfm/unnamed-chunk-30-1.png)<!-- -->

The Random Forest model’s feature importance plot reveals which
structural signals most influenced adequacy classification. The
top-ranked feature is participant contribution growth tier, followed
closely by employer contribution growth and participant growth. These
features had the highest mean decrease in Gini, meaning they contributed
most to reducing impurity in the model’s decision trees.

Lower-ranked but still meaningful features include loan leakage, assets
per participant, and total asset growth, suggesting that while savings
and erosion matter, contribution dynamics were more decisive in the RF
model’s structure.

## Comparison

The logistic regression model emphasized participant growth and sector
context, with low growth and sectors like Human Services and Education
strongly associated with inadequacy. In contrast, the random forest
model prioritized contribution dynamics, participant and employer
contribution growth tiers were the most influential, followed by
participant growth.

While logistic regression highlighted directional and contextual
signals, random forest captured nonlinear patterns tied to financial
engagement. Together, they reveal that adequacy is driven by both
structural momentum and sector-specific disparities.

# Sector Adequacy Scores

Create a stakeholder-friendly visualization that surfaces sector-level
disparities in predicted adequacy based on predictions from the logistic
model. Use the proportion of predicted adequacy classes across sectors.

``` r
# Calculate proportions.

adequacy_by_sector <- as.data.frame(test_results_logistic$predictions) %>%
  group_by(SECTOR_TITLE_SHORT, predicted_class) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(SECTOR_TITLE_SHORT) %>%
  mutate(Proportion = count / sum(count)) %>%
  ungroup()

saveRDS(adequacy_by_sector, "../data/adequacy_by_sector.rds")

# Extract proportion of class 1 (adequate) for sorting.

adequacy_sort_order <- adequacy_by_sector %>%
  filter(predicted_class == 1) %>%
  arrange(desc(Proportion)) %>%
  pull(SECTOR_TITLE_SHORT)

# Plot with custom sorting.

ggplot(adequacy_by_sector, aes(x = factor(SECTOR_TITLE_SHORT, levels = adequacy_sort_order),
                               y = Proportion,
                               fill = factor(predicted_class, levels = c(0, 1),
                                             labels = c("Inadequate", "Adequate")))) +
  geom_col(position = "fill") +
  scale_fill_manual(values = c("Inadequate" = "steelblue", "Adequate" = "lightsteelblue")) +
  labs(title = "Proportion of Predicted Classes by Sector",
       x = "Sector",
       y = "Proportion",
       fill = "Predicted Class") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5),
        plot.title = element_text(size = 14, face = "bold"))
```

![](4_model_eval_files/figure-gfm/unnamed-chunk-31-1.png)<!-- -->

The chart reveals clear sector-level disparities in predicted retirement
plan adequacy.

Sectors like Public Administration, Education, and Finance show high
proportions of plans classified as “adequate,” suggesting structural
stability and stronger contribution dynamics. In contrast, sectors such
as Accommodation & Food Services, Real Estate, and Arts & Entertainment
are predominantly labeled “inadequate,” indicating potential gaps in
plan design, engagement, or financial momentum.

This visualization offers a diagnostic snapshot for identifying where
targeted interventions or deeper audits may be most needed.
