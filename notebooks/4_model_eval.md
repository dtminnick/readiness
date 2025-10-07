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
    ##                                    Estimate Std. Error z value Pr(>|z|)    
    ## (Intercept)                        -0.94807    0.44747  -2.119 0.034115 *  
    ## SECTOR_TITLE_SHORTAdministrati...  -0.62169    0.66754  -0.931 0.351691    
    ## SECTOR_TITLE_SHORTAgriculture,...  -0.49015    0.82153  -0.597 0.550757    
    ## SECTOR_TITLE_SHORTArts, entert...   1.78989    0.71798   2.493 0.012669 *  
    ## SECTOR_TITLE_SHORTEducational ...   2.03610    0.67686   3.008 0.002628 ** 
    ## SECTOR_TITLE_SHORTFinance and ...   1.16204    0.63783   1.822 0.068477 .  
    ## SECTOR_TITLE_SHORTHealth care ...   1.12040    0.66960   1.673 0.094282 .  
    ## SECTOR_TITLE_SHORTManagement o...   0.83619    0.67103   1.246 0.212721    
    ## SECTOR_TITLE_SHORTManufacturing    -0.23856    0.67350  -0.354 0.723183    
    ## SECTOR_TITLE_SHORTMining, quar...   2.87838    0.93604   3.075 0.002105 ** 
    ## SECTOR_TITLE_SHORTProfessional...   1.76129    0.64746   2.720 0.006522 ** 
    ## SECTOR_TITLE_SHORTPublic admin... -19.07158  759.81769  -0.025 0.979975    
    ## SECTOR_TITLE_SHORTRetail trade     -0.95391    0.65486  -1.457 0.145211    
    ## SECTOR_TITLE_SHORTTransportati...  -1.11010    0.69026  -1.608 0.107786    
    ## SECTOR_TITLE_SHORTUtilities         0.07155    0.78010   0.092 0.926926    
    ## SECTOR_TITLE_SHORTWholesale trade  -0.12764    0.65020  -0.196 0.844370    
    ## SECTOR_TITLE_SHORTOther             0.94170    0.50240   1.874 0.060875 .  
    ## PLAN_VINTAGE_GROUP.L               -0.08687    0.28578  -0.304 0.761153    
    ## PLAN_VINTAGE_GROUP.Q               -0.54308    0.24108  -2.253 0.024276 *  
    ## PLAN_VINTAGE_GROUP.C                0.10487    0.23128   0.453 0.650234    
    ## CONTRIB_EMPLR_GROWTH_TIER_Q.L       3.43298    0.31967  10.739  < 2e-16 ***
    ## CONTRIB_EMPLR_GROWTH_TIER_Q.Q      -0.55526    0.25615  -2.168 0.030180 *  
    ## CONTRIB_EMPLR_GROWTH_TIER_Q.C      -1.45784    0.24210  -6.022 1.73e-09 ***
    ## CONTRIB_PARTCP_GROWTH_TIER_Q.L      3.37590    0.30858  10.940  < 2e-16 ***
    ## CONTRIB_PARTCP_GROWTH_TIER_Q.Q     -0.13078    0.26118  -0.501 0.616570    
    ## CONTRIB_PARTCP_GROWTH_TIER_Q.C     -1.18215    0.23056  -5.127 2.94e-07 ***
    ## PARTCP_GROWTH_TIER_Q.L              3.82063    0.33326  11.465  < 2e-16 ***
    ## PARTCP_GROWTH_TIER_Q.Q             -0.47614    0.24566  -1.938 0.052597 .  
    ## PARTCP_GROWTH_TIER_Q.C             -0.75243    0.22360  -3.365 0.000765 ***
    ## ASSETS_PER_PARTCP_TIER_Q.L          3.38099    0.35774   9.451  < 2e-16 ***
    ## ASSETS_PER_PARTCP_TIER_Q.Q          0.50865    0.23836   2.134 0.032845 *  
    ## ASSETS_PER_PARTCP_TIER_Q.C         -0.97624    0.24183  -4.037 5.42e-05 ***
    ## TOTAL_ASSETS_GROWTH_TIER_Q.L        0.86159    0.28298   3.045 0.002330 ** 
    ## TOTAL_ASSETS_GROWTH_TIER_Q.Q       -0.31539    0.24577  -1.283 0.199403    
    ## TOTAL_ASSETS_GROWTH_TIER_Q.C        0.15503    0.22968   0.675 0.499687    
    ## LOAN_LEAKAGE_TIER_Q.L              -2.94462    0.30343  -9.705  < 2e-16 ***
    ## LOAN_LEAKAGE_TIER_Q.Q               0.04130    0.23422   0.176 0.860028    
    ## LOAN_LEAKAGE_TIER_Q.C               0.24491    0.23539   1.040 0.298126    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for binomial family taken to be 1)
    ## 
    ##     Null deviance: 1613.33  on 1165  degrees of freedom
    ## Residual deviance:  515.75  on 1128  degrees of freedom
    ## AIC: 591.75
    ## 
    ## Number of Fisher Scoring iterations: 15

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
midrange probabilities (around 0.2–0.4), but they are small and within
acceptable limits.

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
train_results_logistic$metrics_df
```

    ##              Metric Logistic_Train
    ## 1          Accuracy         0.9108
    ## 2               AUC         0.9701
    ## 3 Balanced Accuracy         0.9103
    ## 4             Kappa         0.8210
    ## 5     McnemarPValue         0.6239
    ## 6    Neg Pred Value         0.9104
    ## 7    Pos Pred Value         0.9111
    ## 8       Sensitivity         0.9201
    ## 9       Specificity         0.9005

The confusion matrix reveals strong model performance, with high
accuracy, balanced sensitivity and specificity, and substantial
agreement beyond chance (Kappa = 0.82). The Mcnemar test shows no
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

An AUC of 0.9701 indicates excellent model performance. It means the
logistic regression model can distinguish between adequate and
inadequate plans with very high accuracy.

## Random Forest Model

Generate random forest model and show model performance.

``` r
# plans_train$ADEQUACY_IND <- as.factor(plans_train$ADEQUACY_IND)

model_rf <- randomForest(ADEQUACY_IND ~ 
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
    ##  randomForest(formula = ADEQUACY_IND ~ CONTRIB_EMPLR_GROWTH_TIER_Q +      CONTRIB_PARTCP_GROWTH_TIER_Q + PARTCP_GROWTH_TIER_Q + ASSETS_PER_PARTCP_TIER_Q +      TOTAL_ASSETS_GROWTH_TIER_Q + LOAN_LEAKAGE_TIER_Q, data = plans_train,      ntree = 500, mtry = 3, importance = TRUE) 
    ##                Type of random forest: classification
    ##                      Number of trees: 500
    ## No. of variables tried at each split: 3
    ## 
    ##         OOB estimate of  error rate: 14.41%
    ## Confusion matrix:
    ##     0   1 class.error
    ## 0 532  81   0.1321370
    ## 1  87 466   0.1573237

This random forest model achieves ~86% accuracy with balanced error
rates across adequacy classes. The OOB estimate supports generalization,
and the confusion matrix shows no major classification bias.

Generate a variable importance plot.

``` r
varImpPlot(model_rf, type = 2, main = "Random Forest Variable Importance")
```

![](4_model_eval_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

The random forest model confirms that contribution growth, especially
participant-driven growth, is the strongest predictor of plan adequacy,
followed closely by employer contributions and loan leakage. This
resonates as industry studies confirm that those who contribute
consistently to retirement savings - and do not draw early on savings -
are generally more financially prepared for this life event.

Asset-based tiers play a supporting role, while total asset growth shows
the least influence.

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
train_results_rf$metrics_df
```

    ##              Metric Logistic_Train RF_Train
    ## 1          Accuracy         0.9108   0.9640
    ## 2               AUC         0.9701   0.9959
    ## 3 Balanced Accuracy         0.9103   0.9634
    ## 4             Kappa         0.8210   0.9277
    ## 5     McnemarPValue         0.6239   0.1649
    ## 6    Neg Pred Value         0.9104   0.9705
    ## 7    Pos Pred Value         0.9111   0.9583
    ## 8       Sensitivity         0.9201   0.9739
    ## 9       Specificity         0.9005   0.9530

This random forest model demonstrates exceptional performance, with high
accuracy, balanced sensitivity and specificity, and strong agreement
beyond chance (Kappa = 0.93). The Mcnemar test confirms no directional
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

![](4_model_eval_files/figure-gfm/unnamed-chunk-13-1.png)<!-- -->

The near-perfect ROC curve, paired with 96% test accuracy and 84% OOB
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
validate_results_logistic$metrics_df
```

    ##              Metric Logistic_Train RF_Train Logistic_Validate
    ## 1          Accuracy         0.9108   0.9640            0.8680
    ## 2               AUC         0.9701   0.9959            0.9514
    ## 3 Balanced Accuracy         0.9103   0.9634            0.8671
    ## 4             Kappa         0.8210   0.9277            0.7351
    ## 5     McnemarPValue         0.6239   0.1649            0.7277
    ## 6    Neg Pred Value         0.9104   0.9705            0.8707
    ## 7    Pos Pred Value         0.9111   0.9583            0.8657
    ## 8       Sensitivity         0.9201   0.9739            0.8855
    ## 9       Specificity         0.9005   0.9530            0.8487

The logistic model performs well on the validation set, with an AUC of
0.951 and balanced accuracy of 0.867, indicating strong class separation
and fair treatment of positives and negatives. Sensitivity (0.886)
slightly exceeds specificity (0.849), favoring detection of adequacy.
Kappa (0.735) shows substantial agreement, and the McNemar p-value
(0.728) confirms no directional bias in errors. Overall, the model
generalizes well with no major fairness concerns.

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

![](4_model_eval_files/figure-gfm/unnamed-chunk-16-1.png)<!-- -->

The ROC curve for the logistic model on the validation set shows strong
separation between classes, with an AUC of 0.951, indicating excellent
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
validate_results_rf$metrics_df
```

    ##              Metric Logistic_Train RF_Train Logistic_Validate RF_Validate
    ## 1          Accuracy         0.9108   0.9640            0.8680      0.8320
    ## 2               AUC         0.9701   0.9959            0.9514      0.9134
    ## 3 Balanced Accuracy         0.9103   0.9634            0.8671      0.8316
    ## 4             Kappa         0.8210   0.9277            0.7351      0.6632
    ## 5     McnemarPValue         0.6239   0.1649            0.7277      1.0000
    ## 6    Neg Pred Value         0.9104   0.9705            0.8707      0.8235
    ## 7    Pos Pred Value         0.9111   0.9583            0.8657      0.8397
    ## 8       Sensitivity         0.9201   0.9739            0.8855      0.8397
    ## 9       Specificity         0.9005   0.9530            0.8487      0.8235

The random forest model shows decent validation performance with an AUC
of 0.914 and balanced accuracy of 0.832, but it trails the logistic
model across most metrics. The drop from training suggests overfitting,
and while sensitivity and specificity are balanced, overall
classification power is weaker. The McNemar p-value of 1.000 indicates
no directional bias, but the model generalizes less effectively than
logistic.

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

![](4_model_eval_files/figure-gfm/unnamed-chunk-19-1.png)<!-- -->

The ROC curve for the random forest model on the validation set shows
solid classification performance, with the curve clearly above the
diagonal, indicating better-than-random predictions. The AUC of 0.914
confirms strong discriminatory power, though it’s notably lower than the
training AUC of 0.996 and slightly behind the logistic model’s
validation AUC of 0.951. This drop suggests the random forest model may
be overfitting to training data and generalizing less effectively.
Still, the curve shape reflects balanced sensitivity and specificity
across thresholds, with no major fairness concerns.

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
test_results_logistic$metrics_df
```

    ##              Metric Logistic_Train RF_Train Logistic_Validate RF_Validate
    ## 1          Accuracy         0.9108   0.9640            0.8680      0.8320
    ## 2               AUC         0.9701   0.9959            0.9514      0.9134
    ## 3 Balanced Accuracy         0.9103   0.9634            0.8671      0.8316
    ## 4             Kappa         0.8210   0.9277            0.7351      0.6632
    ## 5     McnemarPValue         0.6239   0.1649            0.7277      1.0000
    ## 6    Neg Pred Value         0.9104   0.9705            0.8707      0.8235
    ## 7    Pos Pred Value         0.9111   0.9583            0.8657      0.8397
    ## 8       Sensitivity         0.9201   0.9739            0.8855      0.8397
    ## 9       Specificity         0.9005   0.9530            0.8487      0.8235
    ##   Logistic_Test
    ## 1        0.8795
    ## 2        0.9349
    ## 3        0.8783
    ## 4        0.7580
    ## 5        0.5839
    ## 6        0.8860
    ## 7        0.8741
    ## 8        0.9008
    ## 9        0.8559

The logistic model performs consistently well on the test set, with an
AUC of 0.935 and balanced accuracy of 0.878, confirming strong
generalization. Sensitivity (0.901) and specificity (0.856) remain
well-balanced, and the Kappa score of 0.758 reflects substantial
agreement. The McNemar p-value (0.584) shows no directional bias in
errors. Overall, the model maintains high classification power and
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

![](4_model_eval_files/figure-gfm/unnamed-chunk-22-1.png)<!-- -->

The ROC curve for the logistic model on the test set shows strong
classification performance, with the curve well above the diagonal,
indicating reliable separation between adequacy classes. The AUC of
0.935 confirms excellent discriminatory power, validating the model’s
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
test_results_rf$metrics_df
```

    ##              Metric Logistic_Train RF_Train Logistic_Validate RF_Validate
    ## 1          Accuracy         0.9108   0.9640            0.8680      0.8320
    ## 2               AUC         0.9701   0.9959            0.9514      0.9134
    ## 3 Balanced Accuracy         0.9103   0.9634            0.8671      0.8316
    ## 4             Kappa         0.8210   0.9277            0.7351      0.6632
    ## 5     McnemarPValue         0.6239   0.1649            0.7277      1.0000
    ## 6    Neg Pred Value         0.9104   0.9705            0.8707      0.8235
    ## 7    Pos Pred Value         0.9111   0.9583            0.8657      0.8397
    ## 8       Sensitivity         0.9201   0.9739            0.8855      0.8397
    ## 9       Specificity         0.9005   0.9530            0.8487      0.8235
    ##   Logistic_Test RF_Test
    ## 1        0.8795  0.8554
    ## 2        0.9349  0.9276
    ## 3        0.8783  0.8550
    ## 4        0.7580  0.7101
    ## 5        0.5839  1.0000
    ## 6        0.8860  0.8475
    ## 7        0.8741  0.8626
    ## 8        0.9008  0.8626
    ## 9        0.8559  0.8475

The Random Forest model performs well on the test set, with an AUC of
0.923 and balanced accuracy of 0.855, confirming strong generalization.
Sensitivity (0.863) and specificity (0.848) are well-balanced, and the
Kappa score of 0.710 reflects substantial agreement. While slightly
behind the logistic model in most metrics, the RF model maintains
reliable classification power and fairness, with a McNemar p-value of
1.000 indicating no directional bias in errors.

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

![](4_model_eval_files/figure-gfm/unnamed-chunk-25-1.png)<!-- -->

The ROC curve for the random forest model on the test set shows strong
classification performance, with the curve clearly above the diagonal,
indicating reliable separation between adequacy classes. The AUC of
0.923 confirms high discriminatory power, though slightly behind its
training AUC of 0.996 and the logistic model’s test AUC of 0.935. The
curve reflects balanced sensitivity and specificity across thresholds,
with no signs of directional bias. Overall, the RF model generalizes
well and remains a solid performer.

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

# High-Level Takeaways from Model Evaluation

# High-Level Takeaways

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
| 0              |           0 |           0 |     0 |     0 |     9 |
| 1              |           0 |           0 |     0 |     0 |    21 |
| 2              |           0 |           0 |     0 |     3 |    43 |
| 3              |           0 |          13 |     0 |    15 |    58 |
| 4              |          16 |           0 |    17 |     0 |    70 |
| 5              |           1 |           0 |     1 |     0 |    34 |
| 6              |           0 |           0 |     0 |     0 |    14 |

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

![](4_model_eval_files/figure-gfm/unnamed-chunk-28-1.png)<!-- -->

# Conclusion

The models demonstrate genuine learning from the feature space, not rote
reproduction of the adequacy score.

Their misclassification patterns reflect sensitivity to structural
nuance, especially near the adequacy boundary, and reinforce their
diagnostic value in modeling. This validates their use for
stakeholder-facing classification.
