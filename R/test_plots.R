
library(tidyverse)

metrics <- tribble(
    ~Model, ~Split, ~Accuracy, ~AUC, ~BalancedAccuracy, ~Kappa,
    "Logistic", "Train", 0.8945, 0.9627, 0.8940, 0.7881,
    "RF",       "Train", 0.9983, 0.9999, 0.9982, 0.9966,
    "Logistic", "Validate", 0.8480, 0.9377, 0.8463, 0.6941,
    "RF",       "Validate", 0.8720, 0.9405, 0.8751, 0.7448,
    "Logistic", "Test", 0.8916, 0.9408, 0.8880, 0.7808,
    "RF",       "Test", 0.8635, 0.9420, 0.8628, 0.7256
) %>%
    mutate(Split = factor(Split, levels = c("Train", "Validate", "Test")))


ggplot(metrics, aes(x = Split, y = Accuracy, color = Model, group = Model)) +
    geom_line(size = 1.2) +
    geom_point(size = 3) +
    labs(title = "Bias-Variance Tradeoff: Accuracy",
         y = "Accuracy", x = "Data Split") +
    theme_minimal()


ggplot(metrics, aes(x = Split, y = Kappa, color = Model, group = Model)) +
    geom_line(size = 1.2) +
    geom_point(size = 3) +
    labs(title = "Bias-Variance Tradeoff: Kappa",
         y = "Kappa", x = "Data Split") +
    theme_minimal()

