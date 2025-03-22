head(TBdata)
str(TBdata)
colSums(is.na(TBdata))

# Since we want rate of TB per unit popualtion, We will create this new variable for EDA

TBdata$TB_Rate <- (TBdata$TB/TBdata$Population)*100000

# List of variables and their brief descriptions
covariate_labels <- c(
  "Indigenous",
  "Illiteracy",
  "Urbanisation",
  "Density",
  "Poverty",
  "Poor Sanitation",
  "Unemployment",
  "Timeliness",
  "TB Rate"
)

# Variables for summarisation
variables <- c("Indigenous", "Illiteracy", "Urbanisation", "Density", 
               "Poverty", "Poor_Sanitation", "Unemployment", "Timeliness", "TB_Rate")

# Summarising with explicit naming
summary_stats <- TBdata %>%
  summarise(across(all_of(variables), list(
    Mean = ~mean(.x, na.rm = TRUE),
    SD = ~sd(.x, na.rm = TRUE),
    Min = ~min(.x, na.rm = TRUE),
    Q1 = ~quantile(.x, 0.25, na.rm = TRUE),
    Median = ~median(.x, na.rm = TRUE),
    Q3 = ~quantile(.x, 0.75, na.rm = TRUE),
    Max = ~max(.x, na.rm = TRUE)
  ), .names = "{.col}__{.fn}")) %>%
  pivot_longer(cols = everything(),
               names_to = c("Variable", "Statistic"),
               names_sep = "__",
               values_to = "Value") %>%
  pivot_wider(names_from = Statistic, values_from = Value) %>%
  mutate(Variable = covariate_labels)

# Create the professional GT table
summary_stats %>%
  gt() %>%
  tab_header(
    title = md("**Summary Statistics of Socio-Economic Covariates and TB Rate**")
  ) %>%
  fmt_number(columns = where(is.numeric), decimals = 2) %>%
  cols_label(
    Variable = "Covariate",
    Mean = "Mean",
    SD = "Std Dev",
    Min = "Min",
    Q1 = "25th Percentile",
    Median = "Median",
    Q3 = "75th Percentile",
    Max = "Max"
  ) %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_labels(everything())
  ) %>%
  tab_style(
    style = list(cell_fill(color = "gray95")),
    locations = cells_body(rows = Variable == "TB Rate (Cases per 100,000 population)")
  ) %>%
  tab_options(
    table.font.names = "Times New Roman",
    table.font.size = 13,  # Slightly larger text for better readability
    heading.align = "center",
    column_labels.font.size = 13,  # Increase column header size
    column_labels.font.weight = "bold",
    row.striping.include_table_body = TRUE,
    data_row.padding = px(10),  # Increase row padding for more height
    column_labels.border.top.width = px(3),
    column_labels.border.bottom.width = px(3),
    table.border.top.width = px(2),
    table.border.bottom.width = px(2),
    table.border.bottom.color = "black",
    table.border.top.color = "black",
    table.width = pct(100)
  ) %>%
  tab_caption("Table 1: Summary Statistics of Socio-Economic Covariates and TB Rate")



###############################################
# Convert data to long format for faceted plotting
TBdata_long <- TBdata %>%
  pivot_longer(cols = c(Indigenous, Illiteracy, Urbanisation, Density, 
                        Poverty, Poor_Sanitation, Unemployment, Timeliness),
               names_to = "Covariate",
               values_to = "Value")

# Facet labels
facet_labels <- c(
  Indigenous = "Indigenous (%)",
  Illiteracy = "Illiteracy (%)",
  Urbanisation = "Urbanisation (%)",
  Density = "Dwelling Density (Dwellers/Room)",
  Poverty = "Poverty (%)",
  Poor_Sanitation = "Poor Sanitation (Higher = Worse)",
  Unemployment = "Unemployment (%)",
  Timeliness = "TB Notification Delay (Days)"
)

# Faceted Plot
ggplot(TBdata_long, aes(x = Value, y = TB_Rate)) +
  geom_point(alpha = 0.4, color = "darkblue") +  # Scatterplot points
  geom_smooth(method = "loess", color = "red", se = FALSE) +  # Smoothed trend line
  facet_wrap(~ Covariate, scales = "free_x", labeller = labeller(Covariate = facet_labels), nrow = 4, ncol = 2) + 
  labs(title = "Relationship Between Socio-Economic Covariates and TB Rate",
       x = "Covariate Value",
       y = "TB Rate per 100,000") +
  custom_theme+
  theme(plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
        strip.text = element_text(size = 16, face = "bold") 
  )



# Correlation Matric of Covariates

# # Load necessary packages
library(ggcorrplot)
library(corrr)

# Select relevant variables
cor_data <- TBdata[, c("Indigenous", "Illiteracy", "Urbanisation", "Density",
                       "Poverty", "Poor_Sanitation", "Unemployment", "Timeliness")]

# Compute correlation matrix
cor_matrix <- cor(cor_data, use = "pairwise.complete.obs")

# Plot correlation heatmap
ggcorrplot(cor_matrix, method="circle", type="lower", 
           lab=TRUE, lab_size=3, colors=c("blue", "white", "red"),
           title="Correlation Matrix of Socio-Economic Factors")