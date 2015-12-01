###########################################################################
# R sessions for UCL SPP staff
#
# Week 1 Seminar: Introduction to R, OLS, data manipulation and basic visualisations
#
#



## ------------------------------------------------------------------------
# Create a numeric and a character variable
a <- 5 
class(a) # a is a numeric variable
a
b <- "Yay stats class"
class(b) # b is a string variable
b

## ------------------------------------------------------------------------
# Create a vector
my.vector <- c(10,-7,99,34,0,-5) # a vector
my.vector
length(my.vector) # how many elements?
# subsetting
my.vector[1] # 1st vector element
my.vector[-1] # all elements but the 1st
my.vector[2:4] # the 2nd to the 4th elements
my.vector[c(2,5)] # 2nd and 5th element
my.vector[length(my.vector)] # the last element

# delete variable 'a' from workspace
rm(a)
# delete everything from workspace
rm(list=ls())

## ------------------------------------------------------------------------
# create a matrix
# type help("matrix") into the console and press ENTER
# read Description, Usage and Arguments
my.matrix1 <- matrix(data = c(1,2,30,40,500,600), nrow = 3, ncol = 2, byrow = TRUE,
                     dimnames = NULL)
my.matrix2 <- matrix(data = c(1,2,30,40,500,600), nrow = 2, ncol = 3, byrow = FALSE)
# How are the matrices different?
my.matrix1
my.matrix2

# subsetting a matrix
my.matrix1[1,2] # element in row 1 and column 2
my.matrix1[2,1] # element in row 2 and column 1
my.matrix1[,1] # 1st column only
my.matrix1[1:2,] # rows 1 to 2
my.matrix1[c(1,3),] # rows 1 and 3 

## ---- eval=FALSE---------------------------------------------------------
## install.packages("texreg") # Creates tables both in ASCII text, LaTeX or Word, similar to outreg
## install.packages("lmtest") # Provides different tests of linear models
## install.packages("readxl") # Opens and writes Excel files
## install.packages("sandwich") # Calculates heteroskedasticity consistent SEs
## install.packages("car") # General functions to run regressions and manage data
## install.packages("plm") # Panel data models
## install.packages("dplyr") # General data manipulation
## install.packages("tidyr") # Further data manipulations
## install.packages("ggplot2") # Advanced graphical machine
## install.packages("effects")

## ---- eval=FALSE---------------------------------------------------------
## 
## install.packages("https://cran.r-project.org/src/contrib/Archive/Zelig/Zelig_4.2-1.tar.gz",
##                  repos=NULL,
##                  type="source")
## 

## ------------------------------------------------------------------------
library(foreign) ## comes with the basic installation and allows us to open files in other formats such as Stata, SPSS or SAS
library(car)
library(readxl) 
library(texreg)
library(Zelig)
library(sandwich)
library(plm)
library(effects)
library(ggplot2)
library(tidyr)
library(lmtest)
library(dplyr)

## ------------------------------------------------------------------------
# load the Polity IV dataset
my.data <- read.csv("http://uclspp.github.io/PUBLG100/data/polity.csv")

# View(my.data) # opens a window with the data set
head(my.data) # retrieves the first 6 observations
head(my.data, n=10) # you can manually set up the amount of observations shown

tail(my.data) # retrieves the last 6 observations

levels(my.data$country) # levels displays levels of a factor variable

# we drop all oberservations which are not from 1946
my.data <- my.data[my.data$year==1946,]
head(my.data)

summary(my.data$polity2) # descriptive statistics of polity variable

# now lets check if western countries were more democratic than the other countries in 1946
table(my.data$nato, my.data$polity2)
# descriptive summary stats of polity variable by nato membership 
summary(my.data$polity2[my.data$nato==0]) # not in nato
summary(my.data$polity2[my.data$nato==1]) # nato member

## illustration
boxplot(my.data$polity2 ~ as.factor(my.data$nato),
        frame = FALSE,
        main = "Polity IV Scores of NATO founders vs others in 1946",
        xlab = "NATO member",
        ylab = "Polity Score")


## ------------------------------------------------------------------------
student_data <- read_excel("hsb2.xlsx")

head(student_data)


## ------------------------------------------------------------------------
world.data <- read.dta("http://uclspp.github.io/PUBLG100/data/QoG2012.dta")
head(world.data)

## ------------------------------------------------------------------------

mean(student_data$science) # Mean 
sd(student_data$science) # Standard deviation
sd(student_data$science)^2 # Variance
median(student_data$science) # Median
range(student_data$science) # Minimum and Maximum value

summary(student_data$science)

hist(student_data$science, main = "Histogram of Science Scores", xlab = "Science Score")

## ------------------------------------------------------------------------
max(student_data$science)
which.max(student_data$science)

## ------------------------------------------------------------------------
quantile(student_data$science, c(0.25, 0.5, 0.75))

## ------------------------------------------------------------------------
student_data$sex <- factor(student_data$female, labels = c("Male", "Female")) 
student_data$socioeconomic_status <- factor(student_data$ses, labels = c("Low", "Middle", "High")) 
student_data$racial_group <- factor(student_data$race, labels = c("Black", "Asian", "Hispanic", "White")) 

## ------------------------------------------------------------------------
race_table <- table(student_data$racial_group) # This tabulates the frequency per value
race_table
sort(race_table, decreasing = TRUE)

## ------------------------------------------------------------------------
table(student_data$sex)

## ------------------------------------------------------------------------
table(student_data$socioeconomic_status)

## ------------------------------------------------------------------------
table(student_data$socioeconomic_status, student_data$racial_group)

## ------------------------------------------------------------------------
# bar charts
barplot(table(student_data$socioeconomic_status))

## ------------------------------------------------------------------------
# science score by gender, race and socioeconomic status
par(mfrow=c(1,3))

# categorical variables are plotted as boxplots
plot(student_data$sex, student_data$science, main = "Gender", las = 2)
plot(student_data$racial_group, student_data$science, main = "Race", las = 2)
plot(student_data$socioeconomic_status, student_data$science, main = "Socioeconomic Status", las = 2)

## ------------------------------------------------------------------------
par(mfrow=c(1,1))
plot(student_data$math, student_data$science)

## ------------------------------------------------------------------------
student_data$english <- apply(student_data[c("read", "write")], 1, mean)

## ------------------------------------------------------------------------
head(student_data)

## ------------------------------------------------------------------------
normal_dist <- rnorm(1000, mean = 0, sd = 1)
head(normal_dist)
hist(normal_dist)

## ------------------------------------------------------------------------
num_rolls <- 10 # number of times to roll the dice
rolls <- as.integer(runif(num_rolls, min = 1, max = 7))
rolls

## ------------------------------------------------------------------------
# load the communities datasets
communities <- read.csv("http://uclspp.github.io/PUBLG100/data/communities.csv")
communities_employment <- read.csv("http://uclspp.github.io/PUBLG100/data/communities_employment.csv")

## ------------------------------------------------------------------------
# merge the two datasets
communities <- merge(communities, communities_employment, by = c("state", "communityname"))

# explore dataset
names(communities)

## ----eval = FALSE--------------------------------------------------------
## View(communities)

## ------------------------------------------------------------------------
communities <- select(communities, 
                      state, 
                      Community = communityname, 
                      UnemploymentRate = PctUnemployed, 
                      NoHighSchool = PctNotHSGrad,
                      White = racePctWhite)

## ------------------------------------------------------------------------
plot(communities$NoHighSchool, communities$UnemploymentRate,
     xlab = "Adults without High School education (%)",
     ylab = "Unemployment Rate")

## ------------------------------------------------------------------------
model1 <- lm(UnemploymentRate ~ NoHighSchool, data = communities)

summary(model1)

## ------------------------------------------------------------------------
plot(communities$NoHighSchool, communities$UnemploymentRate,
     xlab = "Adults without High School education (%)",
     ylab = "Unemployment Rate")
abline(model1, col = "red")

## ------------------------------------------------------------------------
screenreg(model1)

## ------------------------------------------------------------------------
model2 <- lm(UnemploymentRate ~ NoHighSchool + White, data = communities)
summary(model2)
screenreg(list(model1, model2))
htmlreg(list(model1, model2), file="models.doc")

## ------------------------------------------------------------------------
g <- ggplot(data = communities, aes(y = UnemploymentRate, x = NoHighSchool))
g + geom_smooth(method = "lm")
g + geom_point() + geom_smooth(method = "lm") + 
  labs(title = "Model1", x = "Not on High School", y = "Unemployment Rate")


## ------------------------------------------------------------------------
z.out <- zelig(UnemploymentRate ~ NoHighSchool + White, data = communities, 
               model = "ls", cite=FALSE)
summary(z.out)

x.out <- setx(z.out, White = seq(0, 1, 0.1))
s.out <- sim(z.out, x=x.out)
summary(s.out)
plot(s.out, main = "Model 2")

## ------------------------------------------------------------------------
bptest(model2)

vcov(model2) # This function displays the variance-covariance matrix from model1

## ------------------------------------------------------------------------

coeftest(model2) # Shows the coefficients and their corresponding t-tests

coeftest(model2, vcov=vcovHC(model2))


## ------------------------------------------------------------------------
rm(list=ls()) # To clean our environment

# load quality of government institute 2015 dataset
world.data <- read.dta("http://uclspp.github.io/PUBLG100/data/QoG2012.dta")

# we remove NA's
world.data <- na.omit(world.data)

# let's transform the former_col variable into a factor
world.data$former_col <- factor(world.data$former_col, levels=c(0,1), labels = c("No", "Yes"))

# run the multiple regression
m1 <- lm(undp_hdi ~ wbgi_cce + former_col, data = world.data)

# regression table
screenreg(m1)

## ------------------------------------------------------------------------

m2 <- lm(undp_hdi ~ wbgi_cce * former_col, data = world.data)
summary(m2)
# F-test 
anova(m1, m2) 

# regression table
screenreg(list(m1, m2))

## ---- warning=FALSE------------------------------------------------------
# Using the plot function with the effects package
plot(effect(term= "wbgi_cce:former_col", mod=m2, x.var = "wbgi_cce"), multiline = TRUE)

# Using ggplot2
g <- ggplot(world.data, aes(x = wbgi_cce, y = undp_hdi, group = former_col, colour = former_col))
g + geom_smooth(method="lm")

# Using Zelig
z.out <- zelig(undp_hdi ~ wbgi_cce * former_col, data = world.data, model="ls", cite=FALSE)
# set covariates for countries that weren't colonised
x.out1 <- setx(z.out, former_col = "No", wbgi_cce = -3:2)
# set covariates for colonised countries
x.out2 <- setx(z.out, former_col = "Yes", wbgi_cce = -3:2)
# simulate 
s.out <- sim(z.out, x = x.out1, x1 = x.out2)
summary(s.out)
plot(s.out)

## ------------------------------------------------------------------------

# plot of relationship b/w income & the human development index
plot( undp_hdi ~ wdi_gdpc,
      data = world.data,
      xlim = c( xmin = 0, xmax = 65000),
      ylim = c( ymin = 0, ymax = 1),
      frame = FALSE,
      xlab = "World Bank GDP/captia",
      ylab = "Human Development Index",
      main = "Relationship b/w Income and Quality of Life")

# add the regression line 
abline(lm(undp_hdi ~ wdi_gdpc, data = world.data))

# lowess line
lines(lowess(world.data$wdi_gdpc, world.data$undp_hdi), col="red")

## ------------------------------------------------------------------------
# we include a quadradic term for income
m3 <- lm(undp_hdi ~ wdi_gdpc + I(wdi_gdpc^2), 
               data = world.data)

# regression output
summary(m3)

## ------------------------------------------------------------------------
# Easiest way is with Zelig
z.out <- zelig(undp_hdi ~ wdi_gdpc + I(wdi_gdpc^2), 
               data = world.data, model = "ls", cite = F)

# setting covariates; GDP/captia is a sequence from 0 to 45000 by steps of 1000
x.out <- setx(z.out, wdi_gdpc = seq(0, 60000, 1000))

# simulate using our model and our covariates
s.out <- sim(z.out, x = x.out)

# plot the results
plot(s.out)

## ------------------------------------------------------------------------
# we order by ex-colony and then hdi 
head(arrange(world.data, former_col, undp_hdi))
# note: to change the data set you would have to assign it:
# world.data <- arrange(world.data, former_col, undp_hdi)

# the default order is ascending, for descending use:
head(arrange(world.data, desc(former_col, undp_hdi)))

