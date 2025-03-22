
# Checking data and its structure
head(TBdata)
str(TBdata)
colSums(is.na(TBdata))


# Since we want rate of TB per unit popualtion, We will create this new variable

TBdata$TB_rate <- (TBdata$TB/TBdata$Population)*100000


summary(TBdata[, c("Indigenous", "Illiteracy", "Urbanisation", "Density", 
                   "Poverty", "Poor_Sanitation", "Unemployment", "Timeliness", "TB_rate")])


# Distribution of TB rates:
hist(TBdata$TB_rate, 
     main = "Distribution of TB Rates", 
     xlab = "TB Rate per 100,000", 
     col = "skyblue", 
     border = "white")

# Temporatal Distribution of TB rates

boxplot(TB_rate ~ Year, data = TBdata, 
        main = "TB Rates Over Years", 
        ylab = "TB Rate per 100,000", 
        xlab = "Year")

# TB rates for 2014 as an example
plot.map(TBdata$TB_rate[TBdata$Year == 2014], n.levels = 7, main = "TB Rates for 2014")

library(ggplot2)

# Example for Poverty
ggplot(TBdata, aes(x = Poverty, y = TB_rate)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "loess") +
  labs(title = "Poverty vs TB Rate", x = "Poverty Level", y = "TB Rate per 100,000")



# Select relevant columns
covariates <- TBdata[, c("Indigenous", "Illiteracy", "Urbanisation", "Density", 
                         "Poverty", "Poor_Sanitation", "Unemployment", "Timeliness")]

# Compute correlation and plot
cor_matrix <- cor(covariates, use = "complete.obs")
library(corrplot)
corrplot(cor_matrix, method = "circle", type = "upper")




