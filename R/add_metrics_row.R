
add_metrics_row <- function(cm_object, model_name, data_split, df_metrics = NULL) {
  # Extract metrics
  overall <- cm_object$overall
  byclass <- cm_object$byClass
  
  # Select key metrics
  metrics_overall <- c("Accuracy", "Kappa", "McnemarPValue")
  metrics_byclass <- c("Sensitivity", "Specificity", "Pos Pred Value", "Neg Pred Value", "Balanced Accuracy")
  
  # Combine metrics
  metrics <- c(overall[metrics_overall], byclass[metrics_byclass])
  
  # Create a named column
  col_name <- paste(model_name, data_split, sep = "_")
  new_col <- round(as.numeric(metrics), 4)
  names(new_col) <- names(metrics)
  
  # Convert to data frame
  new_df <- data.frame(Metric = names(new_col), Value = new_col)
  names(new_df)[2] <- col_name
  
  # Merge with existing wide-format table
  if (is.null(df_metrics)) {
    return(new_df)
  } else {
    return(merge(df_metrics, new_df, by = "Metric", all = TRUE))
  }
}