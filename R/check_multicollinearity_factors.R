
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


