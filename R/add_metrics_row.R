
# This function appends a column of performance metrics to a shared metrics data frame, 
# enabling side-by-side comparison across models and data splits.

# Inputs:
#   
#   cm_object: a confusion matrix object (from caret::confusionMatrix) containing overall and byClass metrics.
#   model_name: name of the model (e.g., "rf", "lasso").
#   data_split: identifier for the data split (e.g., "train", "test", "fold1").
#   df_metrics: existing metrics data frame (optional).
#   auc_val: optional AUC value to include.
# 
# Metric Selection:
#   
#   From overall: "Accuracy", "Kappa", "McnemarPValue".
#   From byClass: "Sensitivity", "Specificity", "Pos Pred Value", "Neg Pred Value", "Balanced Accuracy".
# 
# Column Construction:
#   
#   Combines selected metrics and optional AUC.
#   Rounds values to 4 decimal places.
#   Names the column using model_name_data_split.
# 
# Output:
#   
#   If no prior metrics frame exists, returns a new one.
#   If df_metrics is provided, merges the new column into it by "Metric".

add_metrics_row <- function(cm_object, model_name, data_split, df_metrics = NULL, auc_val = NA) {
  
  # Extract metrics.
  
  overall <- cm_object$overall
  byclass <- cm_object$byClass
  
  # Select key metrics.
  
  metrics_overall <- c("Accuracy", "Kappa", "McnemarPValue")
  metrics_byclass <- c("Sensitivity", "Specificity", "Pos Pred Value", "Neg Pred Value", "Balanced Accuracy")
  
  # Combine metrics.
  
  metrics <- c(overall[metrics_overall], byclass[metrics_byclass])
  
  # Add AUC if provided.
  
  if (!is.na(auc_val)) {
    metrics <- c(metrics, AUC = auc_val)
  }
  
  # Create a named column.
  
  col_name <- paste(model_name, data_split, sep = "_")
  new_col <- round(as.numeric(metrics), 4)
  names(new_col) <- names(metrics)
  
  # Convert to data frame.
  
  new_df <- data.frame(Metric = names(new_col), Value = new_col)
  names(new_df)[2] <- col_name
  
  # Merge with existing wide-format table.
  
  if (is.null(df_metrics)) {
    return(new_df)
  } else {
    return(merge(df_metrics, new_df, by = "Metric", all = TRUE))
  }
  
}
