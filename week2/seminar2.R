###########################################################################
# R sessions for UCL SPP staff
#
# Week 2 Seminar: Panel data models, logit, further data manipulation and visualisation
#
#



## ---- message=FALSE, warning=FALSE, cite = FALSE-------------------------
library(foreign) 
library(car)
library(readxl) 
library(texreg)
library(Zelig)
library(sandwich)
library(plm)
library(ggplot2)
library(tidyr)
library(lmtest)
library(dplyr)

## ------------------------------------------------------------------------
wdi <- read.csv("https://raw.githubusercontent.com/UCLSPP/Staff-R-training/master/Week1/wdi.csv")

## ------------------------------------------------------------------------
# We first estimate the OLS model, as a baseline

ols <- lm(MaternalMortality ~ SafeWaterAccess + HealthExpenditure + PregnantWomenWithAnemia, data = wdi)
summary(ols)

fixed_effects <- plm(MaternalMortality ~ SafeWaterAccess + HealthExpenditure + PregnantWomenWithAnemia, 
                     data = wdi, 
                     index = c("CountryCode", "Year"), 
                     model = "within", 
                     effect = "individual")
summary(fixed_effects)
fixef(fixed_effects)

screenreg(list(ols, fixed_effects))


## ------------------------------------------------------------------------
plmtest(fixed_effects, effect="individual")

## ------------------------------------------------------------------------
time_effects <- plm(MaternalMortality ~ SafeWaterAccess + HealthExpenditure + PregnantWomenWithAnemia , 
                    data = wdi, 
                    index = c("CountryCode", "Year"), 
                    model = "within", 
                    effect = "time")
summary(time_effects)

screenreg(list(ols, fixed_effects, time_effects))

## ------------------------------------------------------------------------
plmtest(time_effects, effect="time")

## ------------------------------------------------------------------------
twoway_effects <- plm(MaternalMortality ~ SafeWaterAccess + HealthExpenditure + PregnantWomenWithAnemia, 
                      data = wdi, 
                      index = c("CountryCode", "Year"), 
                      model = "within", 
                      effect = "twoways")
summary(twoway_effects)

## ------------------------------------------------------------------------
screenreg(list(fixed_effects, time_effects, twoway_effects), 
          custom.model.names = c("Country Fixed Effects", "Time Fixed Effects", "Twoway Fixed Effects"))

## ------------------------------------------------------------------------
pbgtest(twoway_effects)

## ------------------------------------------------------------------------
twoway_effects_hac <- coeftest(twoway_effects, vcov = vcovHC(twoway_effects, method = "arellano", type = "HC3"))

screenreg(list(twoway_effects, twoway_effects_hac),
          custom.model.names = c("Twoway Fixed Effects", "Twoway Fixed Effects (HAC)"))

## ------------------------------------------------------------------------
ldv_model <- 
  plm(MaternalMortality ~ lag(MaternalMortality) + SafeWaterAccess + HealthExpenditure 
      + PregnantWomenWithAnemia, 
                      data = wdi, 
                      index = c("CountryCode", "Year"), 
                      model = "within", 
                      effect = "twoways")
summary(ldv_model)

## ------------------------------------------------------------------------
pcdtest(twoway_effects)

## ------------------------------------------------------------------------
twoway_effects_pcse <- coeftest(twoway_effects, vcov = vcovBK(twoway_effects, type="HC3", cluster = "group")) 

## ------------------------------------------------------------------------
twoway_effects_scc <- coeftest(twoway_effects, vcov = vcovSCC(twoway_effects, type="HC3", cluster = "group"))

## ------------------------------------------------------------------------
screenreg(list(ols, fixed_effects, twoway_effects, ldv_model, twoway_effects_pcse, twoway_effects_scc), 
          custom.model.names = c("Pooled","Country Effects", "Twoway Fixed Effects", "LDV", "PCSE", "SCC"))

## ----message=FALSE-------------------------------------------------------

# clear environment
rm(list = ls())

## ------------------------------------------------------------------------
# load British post election study
bes <- read.dta("http://uclspp.github.io/PUBLG100/data/bes.dta")
head(bes)

# frequency table of voter turnout
table(bes$Turnout) 

# rename Gender to male b/c 1 = male & remove missings
bes <- bes %>%
  rename(male = Gender) %>%
  na.omit() 

## ------------------------------------------------------------------------
# mean and standard deviation for Turnout by gender
bes %>%
  group_by(male) %>%
  summarise(avg_turnout = mean(Turnout), sd_turnout = sd(Turnout))

# mean for multiple columns using "summarise_each"
bes %>% 
  group_by(male) %>%
  summarise_each(funs(mean), Turnout, Vote2001, Age, LeftrightSelf, 
                 CivicDutyIndex, polinfoindex)

## ------------------------------------------------------------------------
# logit model
model1 <- glm(Turnout ~ Income + polinfoindex + male + edu15 + edu17 + edu18 + 
                edu19plus + in_school + in_uni, family = binomial(link = "logit"),
              data = bes)

# regression output
screenreg(model1)

## ------------------------------------------------------------------------
# predicted probabilities for all respondents
predicted.probabilities <- predict(model1, type = "response")

## ------------------------------------------------------------------------
# threshold to translate predicted probabilities into outcomes
threshold <- .5 

## ------------------------------------------------------------------------
# set prediction to 1 if predicted probability is larger than 0.5 and put 0 otherwise
expected.values <- ifelse(predicted.probabilities > threshold, yes = 1, no = 0)

## ------------------------------------------------------------------------
 # actually observed outcomes
observed <- bes$Turnout

# putting observed outcomes and predicted outcomes into a table
outcome.table <- table(observed,expected.values)
outcome.table

# correctly predicted cases:
# (correct negatives + correct positives) / total number of outcomes
correctly.predicted <- (outcome.table[1,1] + outcome.table[2,2]) / sum(outcome.table)
correctly.predicted

# comparing rate of correctly predicted to naive guess
mean(bes$Turnout)

## ------------------------------------------------------------------------
# esimate the new model 2 including Influence and Age
model2 <- glm(Turnout ~ Income + polinfoindex + Influence + male + Age + 
                edu15 + edu17 + edu18 + edu19plus + in_school + in_uni, 
              family = binomial(link = "logit"), data = bes)

# regression table comparing model 1 and model 2
screenreg( list(model1, model2) )

## ------------------------------------------------------------------------
# the likelihood ratio test
lrtest(model1, model2)

# Akaike's Information Criterion
AIC(model1, model2)

# Bayesian Infromation Criterion
BIC(model1, model2) 

## ------------------------------------------------------------------------
# re-estimate model 2 using Zelig
z.m2 <- zelig(Turnout ~ Income + polinfoindex + Influence + male + Age + edu15 + 
                edu17 + edu18 + edu19plus + in_school + in_uni, model = "logit", 
              data = bes, cite = FALSE)

## ------------------------------------------------------------------------
# average man with 18 years of education
x.male.18edu <- setx(z.m2, male = 1, edu18 = 1, Income = mean(bes$Income), 
                     polinfoindex = mean(bes$polinfoindex), Influence = mean(bes$Influence),  
                     Age = mean(bes$Age), edu15 = 0, edu17 = 0,  edu19plus = 0, 
                     in_school = 0, in_uni = 0)

# check covariate values (if you have missings here, the simulation will not work)
t(x.male.18edu$values) 

# average woman with 18 years of education
x.female.18edu <- setx(z.m2, male = 0, edu18 = 1, Income = mean(bes$Income), 
                       polinfoindex = mean(bes$polinfoindex), Influence = mean(bes$Influence),  
                       Age = mean(bes$Age), edu15 = 0, edu17 = 0,  edu19plus = 0,
                       in_school = 0, in_uni = 0)

# check covariate values (if you have missings here, the simulation will not work)
t(x.female.18edu$values)

## ---- , fig.width=13, fig.height=11--------------------------------------
# make simulation replicable, the values in set.seed() do not matter
set.seed(123)

# simulate with our two scenarios
s.out <- sim(z.m2, x = x.female.18edu, x1 = x.male.18edu)

# outcomes, check especially first differences
summary(s.out)

plot(s.out)

## ------------------------------------------------------------------------
# women with income levels from lowest to highest (notice we put education to the mode)
x.fem <- setx(z.m2, male = 0, Income = 1:13, polinfoindex = mean(bes$polinfoindex), 
              Influence = mean(bes$Influence), Age = mean(bes$Age), 
              edu15 = 1, edu17 = 0, edu18 = 0, edu19plus = 0, in_school = 0, in_uni = 0)

# men with income levels from lowest to highest (notice we put education to the mode)
x.mal <- setx(z.m2, male = 1, Income = 1:13, polinfoindex = mean(bes$polinfoindex), 
              Influence = mean(bes$Influence), Age = mean(bes$Age), 
              edu15 = 1, edu17 = 0, edu18 = 0, edu19plus = 0, in_school = 0, in_uni = 0)

## ------------------------------------------------------------------------
# simulation
s.out2 <- sim(z.m2, x = x.fem, x1 = x.mal)

## ------------------------------------------------------------------------
# final plot
plot.ci (s.out2, 
         ci = 95,
         xlab = "income", 
         ylab = "predicted probability of Voting",
         main = "effect of income by gender")

# add labels manually
text( x = 2, y = .75, labels = "women" )
text( x = 7, y = .68, labels = "men" )

## ---- eval=FALSE---------------------------------------------------------
## install.packages("devtools")
## install.packages("ggmap")
## install.packages("leafletR")

## ------------------------------------------------------------------------
library(ggmap)
devtools::install_github("dill/emoGG")
library(emoGG)

sppmap <- qmap("WC1H 9QU", zoom = 16, maptype="hybrid")
coffee_shops <- data.frame(lat=c(51.526259,51.523253, 51.525874, 51.525748, 51.5243248, 51.525302),
                           lon=c(-0.129560,-0.131100, -0.125719, -0.125088, -0.124673, -0.126386),
                           name=c("Fleet River", "Lever & Bloom", "Fork", "Continental Stores", "Petit A", "Bloomsbury Coffee House"))
sppmap + geom_point(data=coffee_shops, aes(x=coffee_shops$lon, y=coffee_shops$lat, colour=name), size=3)


## We can also use emojis!!

sppmap + geom_emoji(data=coffee_shops, aes(x=coffee_shops$lon, y=coffee_shops$lat, colour=name), emoji="2615")

## ---- eval=FALSE---------------------------------------------------------
## library(leafletR)
## 
## q.dat <- toGeoJSON(data = coffee_shops, dest=tempdir(), name="coffee")
## q.style <- styleSingle(col=2, lwd=1, alpha=1)
## q.map <- leaflet(data = q.dat, base.map = "tls", popup = "name", dest=tempdir(), controls=c("all"), incl.data = TRUE, title = "Javier's favourite coffee shops", style=q.style, size = c(500,500))
## q.map

