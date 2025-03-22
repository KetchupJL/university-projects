# Model Fitting

library(mgcv)

# Ensure categorical variables are factors
TBdata$fYear <- factor(TBdata$Year)


# First GAM model
gam_model <- gam(TB ~ 
                   s(Indigenous, bs = "tp", k=10) +
                   s(Urbanisation, bs = "tp", k=10) +
                   s(Density, bs = "tp", k=10) +
                   s(Poverty, bs = "cr", k=5) +
                   s(Unemployment, bs = "cr", k=5) +
                   s(Poor_Sanitation, k = 10, bs = "cr") +
                   te(lon, lat, by = fYear, bs = c("tp", "cr"), k = c(20, 20, 5)) +
                   Unemployment +  
                   Timeliness +
                   offset(logPop),
                 data = TBdata, 
                 family = nb(link = "log"), 
                 method = "REML")

# Used a mix of "cr" and "tp" splines. CR on the covariates with mostly linear trends, as this smooth function is better on them.


Bdata$predicted_cases <- predict(nb_gam_final, type = "response")

# Convert to TB rate per 100,000 population
TBdata$predicted_rate <- (TBdata$predicted_cases / TBdata$Population) * 100000

# Compare means
mean(TBdata$predicted_rate)  # Should be close to observed mean TB rate (23.5)

# 3D Perspective plot
vis.gam(nb_gam_tw, view = c("lon", "lat"), theta = 30, phi = 20, 
        color = "heat", ticktype = "detailed")

# Contour plot alternative
vis.gam(nb_gam_final, view = c("lon", "lat"), plot.type = "contour", 
        color = "heat")
plot(nb_gam_final, contour.col = 'white', too.far = 0.10, scheme = 2, rug = T)


#################################

#####################################################




# Load necessary packages
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



# Plot component-wise smooth effects
plot(gam_model_tw, pages=1, scheme=2, rug=TRUE, shade=TRUE, seWithMean=TRUE)





# Load necessary package
library(GGally)

# Create TB category
TBdata$TB_Category <- cut(TBdata$TB, 
                          breaks = quantile(TBdata$TB, probs = c(0, 0.33, 0.67, 1), na.rm = TRUE),
                          labels = c("Low", "Medium", "High"), include.lowest = TRUE)

# Select socio-economic and TB data
pair_data <- TBdata[, c("TB", "TB_Category", "Indigenous", "Illiteracy", "Urbanisation",
                        "Density", "Poverty", "Poor_Sanitation", "Unemployment", "Timeliness")]

# Convert TB_Category to a factor
pair_data$TB_Category <- as.factor(pair_data$TB_Category)

# Create pairwise scatterplot matrix with categorical color
ggpairs(pair_data, aes(color=TB_Category), 
        title="Pairwise Scatterplots of TB and Socio-Economic Factors")
