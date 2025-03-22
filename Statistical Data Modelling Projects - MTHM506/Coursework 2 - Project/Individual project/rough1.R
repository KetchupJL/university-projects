# Initial Model Fitting (GAMs)

# Checking for overdispersion:
observed_var <- var(TBdata$TB)
expected_var <- mean(TBdata$TB)
dispersion <- observed_var / expected_var
print(dispersion)

# 2223.535 We can confirm overdispersion


# Fitting Model in R
# Load  package
library(mgcv)

# Fit the Negative Binomial GAM with population offset. Base Model
TBdata$Year <- factor(TBdata$Year)
TBdata$Region <- factor(TBdata$Region)

TBdata$logPop <- log(TBdata$Population)

# Ensure categorical variables are factors
TBdata$fYear <- factor(TBdata$Year)


# First GAM model
gam_model_initial <- gam(TB ~ 
                   s(Indigenous, bs = "tp", k=10) +
                   s(Illiteracy, bs = "tp", k=10) +
                   s(Urbanisation, bs = "tp", k=10) +
                   s(Density, bs = "tp", k=10) +
                   s(Poverty, bs = "cr", k=5) +
                   s(Unemployment, bs = "cr", k=5) +
                   s(Poor_Sanitation, k = 10, bs = "cr") +
                   s(Timeliness, bs = "tp", k=10) +
                   te(lon, lat, by = Year, bs = c("tp", "cr"), k = c(20, 20, 5)) +
                   offset(logPop),
                 data = TBdata, 
                 family = nb(link = "log"), 
                 method = "REML")

# Used a mix of "cr" and "tp" splines. CR on the covariates with mostly linear trends, as this smooth function is better on them.

par(mfrow = c(2,2))
gam.check(gam_model_initial)

summary(gam_model_initial)

# Take Illiteracy out as it isnt a significant predictor. Since Indigenous is 

# Final NB Model
gam_model <- gam(TB ~ 
                   Year + 
                   Indigenous + # edf value of 1.002, since is more ore less linear, we dont need smoothing term
                   s(Urbanisation) +
                   s(Density) +
                   s(Unemployment) +
                   s(Poor_Sanitation) +
                   s(Poverty) +
                   s(Timeliness) +
                   s(lon,lat, k = 30) +
                 offset(logPop),
                 data = TBdata, 
                 family = nb(link = "log"), 
                 method = "REML",
                 select=TRUE) # Reference to book page 406, this is used as "reduced tendency to under-smooth"


par(mfrow = c(2,2))
gam.check(gam_model_tw)

summary(gam_model)

#### Final Model : Tweedie family

gam_model_tw <- gam(TB ~ 
                   Year + 
                   Indigenous + 
                   s(Urbanisation) +
                   s(Density) +
                   s(Unemployment) +
                   s(Poor_Sanitation) +
                   s(Poverty) +
                   s(Timeliness) +
                   s(lon,lat, k = 30) +
                   offset(logPop),
                 data = TBdata, 
                 family = tw, 
                 method = "REML",
                 select=TRUE)

par(mfrow = c(2,2))
gam.check(gam_model_tw)

summary(gam_model_tw)


## Check residuals
par(mfrow=c(1,2))
# QQplot
qq.gam(gam_model_tw,pch=20)
# deviance residualsvs linearpredictor

xx <-gam_model_tw$linear.predictors
yy <-residuals(gam_model_tw,type="deviance")
14
plot(xx,yy,pch=20,xlab="Linear predictor",ylab="Deviance residuals")
abline(h=0) 


# Generate predicted TB cases from the GAM
TBdata$predicted_cases <- predict(gam_model_tw, type = "response")

# Convert to TB rate per 100,000 population
TBdata$predicted_rate <- (TBdata$predicted_cases / TBdata$Population) * 100000



# We can note that Illiteracy isnt a significant predictor, and neither is year
# R^2 Very strong model fit—the model explains ~85% of the variation in TB rates
# Deviance explained = 56.5%: the model explains over half of the variation in TB cases, which is reasonable for epidemiological data.


k.check(gam_model_tw)
plot(gam_model_tw, pages = 1, all.terms = TRUE, shade = TRUE)


vis.gam(gam_model_tw, view = c("lon", "lat"), plot.type = "contour", color = "heat")
#################################################################################

# GAM with Temporal/Spatial

gam_model_SP <- gam(TB ~ Year +
                      s(Indigenous, by = Year) +
                      s(Illiteracy, by = Year) +
                      s(Urbanisation, by = Year) +
                      s(Density, by = Year) +
                      s(Unemployment, by = Year) +
                      s(Poor_Sanitation, by = Year) +
                      s(Poverty, by = Year) +
                      s(Timeliness, by = Year) +
                      s(lon,lat, by = Year) +
                      offset(logPop),
                    data = TBdata, 
                    family = tw, 
                    method = "REML",
                    select=TRUE)

summary(gam_model_SP)
AIC(gam_model)
plot(gam_model_temp, pages = 1, all.terms = TRUE, shade = TRUE)



vis.gam(gam_model_temp, view = c("lon", "lat"), plot.type = "contour", color = "heat")


plot.map(TBdata$TB_Rate[TBdata$Year==2014],n.levels=7,main="TB (data)rates for 2014")
plot.map(gam_model_tw$fitted.values[TBdata$Year==2014],n.levels=7,main="TB (model)counts for 2014")


TBdata$predicted_risk <- predict(gam_model, type = "response")

plot.map(TBdata$TB_Rate, n.levels = 6, main = "Predicted TB Risk across Microregions")

## 

