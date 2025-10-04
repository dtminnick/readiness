
test_predictor_associations <- function(data, vars, ordinal_vars = NULL, visualize = TRUE) {
  
  library("psych")
  library("vcd")
  library("corrplot")
  
  results <- list()
  
  n <- length(vars)
  
  for (i in 1:(n-1)) {
    
    for (j in (i+1):n) {
      
      var1 <- vars[i]
      
      var2 <- vars[j]
      
      x <- data[[var1]]
      
      y <- data[[var2]]
      
      pair_name <- paste(var1, var2, sep = " ~ ")
      
      # Ordinal × Ordinal.
      
      if (var1 %in% ordinal_vars && var2 %in% ordinal_vars) {
        
        x_num <- as.numeric(x)
        
        y_num <- as.numeric(y)
        
        rho <- cor(x_num, y_num, method = "spearman")
        
        results[[pair_name]] <- list(type = "Spearman", value = round(rho, 3))
        
        # Nominal × Nominal or Mixed.
        
      } else {
        
        tbl <- table(x, y)
        
        chi <- suppressWarnings(chisq.test(tbl))
        
        cramers_v <- sqrt(chi$statistic / (sum(tbl) * (min(dim(tbl)) - 1)))
        
        results[[pair_name]] <- list(type = "Cramér's V", value = round(cramers_v, 3))
        
      }
      
    }
    
  }
  
  # Convert to data frame.
  
  assoc_df <- do.call(rbind, lapply(names(results), function(name) {
    
    cbind(Pair = name, Type = results[[name]]$type, Value = results[[name]]$value)
    
  }))
  
  assoc_df <- as.data.frame(assoc_df)
  
  # Optional visualization.
  
  if (visualize) {
    
    assoc_matrix <- matrix(NA, nrow = n, ncol = n, dimnames = list(vars, vars))
    
    for (row in 1:nrow(assoc_df)) {
      
      pair <- strsplit(assoc_df$Pair[row], " ~ ")[[1]]
      
      assoc_matrix[pair[1], pair[2]] <- as.numeric(assoc_df$Value[row])
      
      assoc_matrix[pair[2], pair[1]] <- as.numeric(assoc_df$Value[row])
      
    }
    
    corrplot(assoc_matrix, method = "color", tl.col = "black", na.label = " ")
    
  }
  
  return(assoc_df)
  
}

# Example usage

# Define your variables.

# predictors <- c("Career_stage", "Marital_status_group", "Hours_group", 
#                 "Education_group", "Has_investment_activity")
# 
# ordinal_vars <- c("Career_stage", "Hours_group", "Education_group")
# 
# # Run the function.
# 
# assoc_summary <- test_predictor_associations(your_data, predictors, ordinal_vars)
# 
# print(assoc_summary)

