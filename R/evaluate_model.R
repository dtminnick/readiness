
# Evaluates a fitted classification model on a given dataset, computes key metrics (including AUC), 
# and appends results to a shared metrics table for benchmarking across model runs.

# Inputs:
#   
#   model: a fitted model (e.g., random forest, logistic regression).
#   data: dataset to evaluate.
#   label_col: name of the true label column.
#   model_name: identifier for the model (e.g., "rf", "glm").
#   split_name: identifier for the data split (e.g., "train", "test").
#   metrics_df: existing metrics table to append to.
#   threshold: classification cutoff (default = 0.5).
# 
# Prediction Logic:
#   
#   Detects model type:
#     For randomForest, extracts class 1 probability via type = "prob".
#     For GLMs, uses type = "response" for predicted probabilities.
# 
#   Classifies observations using the specified threshold.
# 
# Diagnostics:
#   
#   Computes confusion matrix using predicted vs. actual labels.
# 
#   Calculates ROC curve and AUC using pROC::roc().
# 
# Metric Aggregation:
#   
#   Calls add_metrics_row() to append metrics (including AUC) to the shared table.
# 
# Output:
#   
#   Returns a list containing:
#     Updated metrics_df
#     roc_obj for plotting or further analysis
#     predictions with appended probability and class columns

evaluate_model <- function(model, data, label_col, model_name, split_name, metrics_df, threshold = 0.5) {
  
  # Detect model type and extract predicted probabilities.
  
  if ("randomForest" %in% class(model)) {
    
    # For random forest, use type = "prob" and extract class 1 probability.
    
    data$predicted_prob <- predict(model, newdata = data, type = "prob")[, "1"]
    
  } else {
    
    # For logistic regression or other GLMs.
    
    data$predicted_prob <- predict(model, newdata = data, type = "response")
    
  }
  
  # Classify based on threshold.
  
  data$predicted_class <- ifelse(data$predicted_prob > threshold, 1, 0)
  
  # Confusion matrix.
  
  cm <- confusionMatrix(factor(data$predicted_class), factor(data[[label_col]]))
  
  # ROC and AUC.
  
  roc_obj <- roc(response = data[[label_col]], predictor = data$predicted_prob)
  
  auc_val <- as.numeric(auc(roc_obj))
  
  # Add metrics row (including AUC).
  
  metrics_df <- add_metrics_row(cm, model_name, split_name, metrics_df, auc_val)
  
  # Return updated metrics and predictions.
  
  return(list(metrics_df = metrics_df, roc_obj = roc_obj, predictions = data))
  
}


