
# This function calculates Variance Inflation Factors (VIFs) for a set of predictors 
# to detect multicollinearity, using a one-hot encoded design matrix.

# Input:
#   
#   data: a data frame containing the predictors.
#   predictors: a character vector of column names to assess.
# 
# Encoding:
#   
#   Uses model.matrix to one-hot encode categorical variables.
#   Drops the intercept and first dummy column to avoid redundancy (reference level dropped).
# 
# VIF Calculation:
#   
#   For each encoded variable:
#   Regress it on all other encoded variables.
#   Compute R2 from the regression.
#   Calculate VIF.
#   Round to two decimal places.
# 
# Output:
#   
#   Returns a data frame of variables and their VIFs, sorted in descending order of VIF.

library("dplyr")

check_multicollinearity_factors <- function(data, predictors) {
  
  # One-hot encode with reference levels dropped
  encoded <- model.matrix(~ . , data = data[predictors])[, -1]  # drops intercept and first dummy
  
  encoded_df <- as.data.frame(encoded)
  
  vif_results <- sapply(colnames(encoded_df), function(var) {
    
    others <- encoded_df[, colnames(encoded_df) != var]
    
    model <- lm(encoded_df[[var]] ~ ., data = others)
    
    r2 <- summary(model)$r.squared
    
    vif <- 1 / (1 - r2)
    
    return(round(vif, 2))
    
  })
  
  vif_df <- data.frame(Variable = names(vif_results), VIF = vif_results)
  
  vif_df <- vif_df[order(-vif_df$VIF), ]
  
  return(vif_df)
}


# Example usage.

# predictors <- c("Career_stage", "Marital_status_group", "Hours_group", 
#                 "Education_group", "Has_investment_activity")
# 
# vif_summary <- check_multicollinearity_factors(your_data, predictors)
# 
# print(vif_summary)


