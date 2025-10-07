
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


