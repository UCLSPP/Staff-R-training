###########################################################################
# R sessions for UCL SPP staff
#
# Week 2 Seminar: Panel data models, logit, further data manipulation and visualisation
#
#



## ------------------------------------------------------------------------
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
guns_data <- read.csv("http://uclspp.github.io/PUBLG100/data/guns.csv")

## ------------------------------------------------------------------------
guns_data$shall_law <- factor(guns_data$shall, levels = c(0, 1), labels =c("NO", "YES"))

## ------------------------------------------------------------------------
fixed_effects <- 
  plm(mur ~ shall_law + incarc_rate + pm1029, 
      data = guns_data, 
      index = c("stateid", "year"), 
      model = "within", 
      effect = "individual")

summary(fixed_effects)

## ------------------------------------------------------------------------
plmtest(fixed_effects, effect="individual")

## ------------------------------------------------------------------------
twoway_effects <- 
  plm(mur ~ shall_law + incarc_rate + pm1029, 
      data = guns_data, 
      index = c("stateid", "year"), 
      model = "within", 
      effect = "twoways")

summary(twoway_effects)

## ------------------------------------------------------------------------
pbgtest(twoway_effects)

## ------------------------------------------------------------------------
twoway_effects_hac <- coeftest(twoway_effects, vcov = vcovHC(twoway_effects, method = "arellano", type = "HC3"))

screenreg(list(twoway_effects, twoway_effects_hac),
          custom.model.names = c("Twoway Fixed Effects", "Twoway Fixed Effects (HAC)"))

## ------------------------------------------------------------------------
ldv_model <- 
  plm(mur ~ lag(mur) + shall_law + incarc_rate + pm1029, 
      data = guns_data, 
      index = c("stateid", "year"), 
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
screenreg(list(fixed_effects, twoway_effects, ldv_model, twoway_effects_pcse, twoway_effects_scc), 
          custom.model.names = c("Country Effects", "Twoway Fixed Effects", "LDV", "PCSE", "SCC"))

## ------------------------------------------------------------------------
bes <- read.dta("http://uclspp.github.io/PUBLG100/data/bes.dta")
bes <- na.omit(bes)
head(bes)

## ------------------------------------------------------------------------
m1 <- glm(factor(Turnout) ~ Income + polinfoindex + Gender + edu15 + edu17 + edu18 + 
            edu19plus + in_school + in_uni, family = binomial(link = "logit"),
          data = bes)
screenreg(m1)

## ------------------------------------------------------------------------
y.latent <- predict(m1)

## ------------------------------------------------------------------------
head(y.latent)

## ------------------------------------------------------------------------
pred.probs <- 1 / (1 + exp(-y.latent))
summary(pred.probs)

## ------------------------------------------------------------------------
observed <- bes$Turnout # those are the observed outcomes
exp.vals <- rep(0,length(observed))
# threshold to translate predicted probabilities into outcomes
threshold <- .5 
# everyone with a predicted prob > .5 is predicted to turnout
exp.vals[which(pred.probs > threshold)] <- 1
# puttint observed and predicted into a table
qual.pred <- table(observed,exp.vals)
qual.pred


## ------------------------------------------------------------------------
(qual.pred[1,1] + qual.pred[2,2]) / sum(qual.pred)
# we correctly predict 63.5% of the cases in the data set


median(bes$Turnout) # the modal category of Turnout is 1
mean(bes$Turnout)

## ------------------------------------------------------------------------
m2 <- glm(Turnout ~ Income + polinfoindex + Influence + Gender + Age +edu15 + 
            edu17 + edu18 + edu19plus + in_school + in_uni, 
          family = binomial(link = "logit"), data = bes)

summary(m2)
screenreg(list(m1, m2))

## ------------------------------------------------------------------------
lrtest(m1, m2)

## ------------------------------------------------------------------------
AIC(m1, m2)
BIC(m1, m2) 

## ------------------------------------------------------------------------
# z.out is identical to m2
z.out <- zelig(Turnout ~ Income + polinfoindex + Influence + Gender + Age + edu15 + 
            edu17 + edu18 + edu19plus + in_school + in_uni, model = "logit", 
            data = bes, cite = F)

## ------------------------------------------------------------------------

x.fem.18 <- setx(z.out, Income = median(bes$Income), polinfoindex = median(bes$polinfoindex), 
                 Influence = median(bes$Influence), Gender = 1, Age = median(bes$Age), 
                 edu15 = 0, edu17 = 0, edu18 = 1, edu19plus = 0, in_school = 0, in_uni = 0)
x.fem.18$values # check the values you have set

x.male.18 <- setx(z.out, Income = median(bes$Income), polinfoindex = median(bes$polinfoindex), 
                 Influence = median(bes$Influence), Gender = 0, Age = median(bes$Age), 
                 edu15 = 0, edu17 = 0, edu18 = 1, edu19plus = 0, in_school = 0, in_uni = 0)
x.male.18$values

## ------------------------------------------------------------------------
s.out <- sim(z.out, x = x.fem.18, x1 = x.male.18)
# let's check the quantities of interest
names(s.out$qi)
# expected values express the probability of assigning a 1 to the response variable (Turnout)
# predicted values express our model prediction (0 or 1) for the response variable (Turnout)

## ----fig.width=13, fig.height=11-----------------------------------------

ev.fem <- sort(s.out$qi$ev1); ev.men <- sort(s.out$qi$ev2) 
women <- c(ev.fem[25], ev.fem[500], ev.fem[975])
men <- c(ev.men[25], ev.men[500], ev.men[975])
final <- rbind(round(women,2), round(men,2))
colnames(final) = c("2.5%", "Mean", "97.5%")
rownames(final) = c("female","male")
final

# or in 1 line
summary(s.out)

# graphically
plot(s.out)

## ------------------------------------------------------------------------
x.fem <- setx(z.out, Income = 1:13, polinfoindex = median(bes$polinfoindex), 
             Influence = median(bes$Influence), Gender = 1, Age =median(bes$Age), 
             edu15 = 1, edu17 = 0, edu18 = 0, edu19plus = 0, in_school = 0, in_uni = 0)
x.mal <- setx(z.out, Income = 1:13, polinfoindex = median(bes$polinfoindex), 
              Influence = median(bes$Influence), Gender = 0, Age =median(bes$Age), 
              edu15 = 1, edu17 = 0, edu18 = 0, edu19plus = 0, in_school = 0, in_uni = 0)
names(x.fem)
names(x.mal)
s.out2 <- sim(z.out, x = x.fem, x1 = x.mal)

# illustrate
plot.ci(s.out2, 
        xlab = "income", 
        ylab = "predicted probability of Voting (ev in Zelig)",
        main = "effect of income by gender")
text(x=2,y=.75,labels="women")
text(x=7,y=.68,labels="men")

