library(gdata)  
library(ggplot2)

#setwd("/home/abc")
getwd()
df = read.csv("issues_mixed-effects-dataset.csv")
summary(df)

names(df)
dim(subset(df,isExternal=="True"))
dim(df)
drops=c("X","upstreamIssueContributions","upstreamIssueContributionsFraction","upstreamAllContributions","upstreamAllContributionsFraction", "upstreamContributions");
drops=c("X");
df<-df[, !(names(df) %in% drops)]
dim(df)
names(df)
#Remove any missing data - ideally this is cleaned data so nothing should be missing at this point
df1 <- na.exclude(df)
dim(df1)
names(df1)
#df1 <- na.omit(df)
df<-df1
dim(df)

#This is for log transformations for Independent variables. For response variables we dont add this because affects interpretation
#Ideally one should add the smallest non-zero value by 2 plus that value to each element. 
#log(0.5)
#log(1000000.5)
#log(1500000)
#log(1000000+1500000)

increment<-0.5
intIncr<-increment


#COmpute time taken to close since it is not in the raw data
df$timeTakenToClose <- (df$closedAtMillisIssue/1000) - (df$createdAtMillisIssue/1000)
#in hours
df$timeTakenToClose<-df$timeTakenToClose/3600
#in days
df$timeTakenToClose<-df$timeTakenToClose/24
summary(df$timeTakenToClose)

df$totalDependencies <- df$cranDependencies + df$nonCranDependencies




#Compute the age in years
#df$age <- 1459985777000 - df$createdAtMillis
#We take the date from June 27, however our mined data is upto Feb 
df$age <-1466986634000 -  df$createdAtMillis
df$age <- df$age / 1000
df$age <- df$age / (3600)
df$age <- df$age / 24 #num days
df$age <- df$age/30 #months
df$ageInMonths<-df$age
df$age <- df$age/12 #years
df$ageInYears<-df$age
summary(df$ageInYears)
df$ageInYearsLog <- log(df$ageInYears+increment)
hist(df$ageInYears)

#Not using this variable - basicaly the total number of issues in the repository
df$totalIssuesPR <- df$dependencyProblems + df$nonDependencyProblems
df$totalIssuesPRLog <- log(df$totalIssuesPR + increment)
#Again total dependencies is something we dont have to use in the model
totalDependencies <- df$cranDependencies+df$nonCranDependencies
df$totalDependencies <- totalDependencies
names(df)
#hist(df$totalDependencies)

#Calculate the description file churn per year for each repo -> Not used in the model
df$descriptionFileChurnPerYear <- df$descriptionChurn / df$ageInYears
df$descriptionFileChurnPerMonth <- df$descriptionChurn/(df$ageInYears*12)
##Best example of the log transformation resulting in a normal distribution
df$descriptionFileChurnPerYearLog <- log(df$descriptionFileChurnPerYear+increment)
## === Log transformations , skip this and see how results come
hist(df$descriptionFileChurnPerYearLog)

#We Log transform all variables but not all log transformed are used since we use a glm
df$dependencyProblemsLog <- log(df$dependencyProblems+intIncr)
df$nonDependencyProblemsLog <- log(df$nonDependencyProblems+intIncr)
hist(df$dependencyProblemsLog)
names(df)

#The data is already in per year data in the csv file (TD: Need to rename the column in the raw csv )
#We have removed this data during filtering
df$averageUpstreamReleasesPerYear <- df$averageUpstreamReleases
df$averageUpstreamReleasesPerYearLog<-log(df$averageUpstreamReleasesPerYear+increment)
hist(df$averageUpstreamReleasesPerYearLog)
summary(df$averageUpstreamVersion)
#min is 1 so n oneed increment
df$averageUpstreamVersionLog<-log(df$averageUpstreamVersion + intIncr)
hist(df$averageUpstreamVersionLog)
#Raw data is in years (TD: Rename in csv saying it is age in days)
df$averageUpstreamAgeInYears <- df$averageUpstreamAge/365
summary(df$averageUpstreamAgeInYears)#Min is >0 so no need increment actually
df$averageUpstreamAgeInYearsLog <- log(df$averageUpstreamAgeInYears + increment)
hist(df$averageUpstreamAgeInYearsLog)


#Log transform other variables
summary(df$sourceContributors)#Min is 1 so no need intIncr but we still add because we are doing for all log transformed independent vars
df$sourceContributorsLog <- log(df$sourceContributors + intIncr)
hist(df$sourceContributorsLog)
df$starsCountLog <- log(df$starsCount+intIncr)
summary(df$sourceLOC)
df$sourceLOCLog <- log(df$sourceLOC+intIncr)
hist(df$sourceLOCLog,breaks=10)
df$downstreamProjectsLog <- log(df$downstreamProjects+intIncr)
df$cranDependenciesLog<-log(df$cranDependencies+intIncr)
df$nonCranDependenciesLog<-log(df$nonCranDependencies+intIncr)

df$averageContributionsToUpstream <- df$upstreamContributionsFraction
df$averageContributionsToUpstreamLog<-log(df$averageContributionsToUpstream+increment)

hist(df$totalDependencies)
max(df$totalIssuesPR)

##==== Issue level variables ===
df$crossReferences = df$numIntCrossReferences + df$numExtCrossReferences
hist(df$crossReferences)
hist(log(df$crossReferences+intIncr))
df$crossReferencesLog <- log(df$crossReferences+intIncr)

### == Comments decrement by 1 because we have included the body as default one comment in the dataset
df$comments = df$comments - 1

### ======= Filter out open issues ====
dim(df)
df1<-subset(df, isOpen == "False")
dim(df1)
df<-df1


### ============= Filter out timeTakenToClose : 0 =====

min(df$timeTakenToClose)
#Remove rows where time taken to close is 0
dim(df)
df1<-subset(df, timeTakenToClose == 0)
dim(df1)
names(df1)
df1<-subset(df, timeTakenToClose > 0)
dim(df1)
df<-df1
dim(df)
min(df$timeTakenToClose)

####=== Compute the arithmetic and geometric mean of response variables before subsetting
print("overall mean of response variables")
colsSummary <- c("timeTakenToClose","comments","users");
dfSummary <- df[colsSummary]
dim(dfSummary)
library(stargazer)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)
library(psych)
geometric.mean(dfSummary)

#filter only external ones
print("Mean of External type response vars")
dfExternal <- subset(df,isExternal == "True")
dfSummary <- dfExternal[colsSummary]  
dim(dfSummary)
library(stargazer)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)
library(psych)
geometric.mean(dfSummary)

#filter only internal ones 
print("Mean of Internal type response vars")
dfInternal <- subset(df,isExternal == "False")
dfSummary <- dfInternal[colsSummary]  
dim(dfSummary)
library(stargazer)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)
library(psych)
geometric.mean(dfSummary)

#install.packages("car")
library(car)
names(df)
fit <- NULL
summary(df$isExternal)
dim(df)
names(df)

#mixed effects - Random intercept: User and Repo
#+ (1 | userLogin)
### ===== convert all categorical to factor =========
df$isCRAN<-as.factor(df$isCRAN)
df$isPullRequest<- as.factor(df$isPullRequest)
df$isEnhancement <- as.factor(df$isEnhancement)
df$isExternal <- as.factor(df$isExternal)
df$submittedByContributor <- as.factor(df$submittedByContributor)
require(lme4)
#Log transform response variables
#Note dont add increment as all are greater than zero
df$timeTakenToCloseLog <- log(df$timeTakenToClose)
df$commentsLog<-log(df$comments+increment)
df$usersLog <- log(df$users+increment)
hist(((df$usersLog)))

#
### Very interesting: The negative correlation in our random effects is very high: indicating that slope and intercept are negatively correlated across repositories
## Continued: So for repos with high baseline the effect of isexternal is lower, or the effect of is external is more pronounced for when the baseline time is shorter (i.e. for internal problems)
#fit <- lmerTest::lmer(df$usersLog ~  isPullRequest + isEnhancement + isExternal +  crossReferencesScaled + submittedByContributor  +  cranDependenciesLog + nonCranDependenciesLog + ageInYearsScaled + starsCountScaled + sourceContributorsScaled  + downstreamProjectsLog + sourceLOCLog + totalIssuesPRLog   + (1 | project)  +  (1 | userLogin) , data=df, REML = FALSE)
##No need lmerTest because any T-value is automatically statistically significant with ***. So it only adds an overhead looks like.

fit <- lmerTest::lmer(df$timeTakenToCloseLog ~  usersLog  + isPullRequest + isEnhancement + isExternal +  submittedByContributor + crossReferencesLog + isCRAN + ageInYearsLog + starsCountLog + sourceContributorsLog + sourceLOCLog   + (1+ isExternal |project)+ (1 + isExternal |userLogin)  , data=df, REML = FALSE)
lmerTest::summary(fit)
lmerTest::anova(fit)
#install.packages("MuMIn")
library("MuMIn")
## Report R2m and R2C => See bogdan ICSE 2016 paper
# we get about 0.35, 0.5
r.squaredGLMM(fit)
library("lmerTest")
help("pvalues",package="lme4") 
car::Anova(fit)

residFit <- resid(fit)
plot(density(residFit))
#Normality test is pretty good
qqnorm(residFit)
qqline(residFit)

##Effect size
anova(fit)
fixef(fit)

##=== Check multi collinearity , if categorical then just do chisquare test of indep for all pairs
library(car)
car::vif(fit)

library(usdm)
#"isPullRequest", "isEnhancement", "isExternal",  "submittedByContributor",isCRAN
keep = c("usersLog",  "crossReferencesLog","ageInYearsLog","starsCountLog","sourceContributorsLog","sourceLOCLog","totalIssuesPRLog")
dfForVif = df[keep]
#Unfortunately we have to convert categorical To continuous for VIF calculation
index <- df$submittedByContributor=="True"
dfForVif$submittedByContributorTrue = 0
dfForVif$submittedByContributorTrue[index] = 1
index <- df$isCRAN=="True"
dfForVif$isCRANTrue = 0
dfForVif$isCRANTrue[index] = 1
index <- df$isExternal=="True"
dfForVif$isExternalTrue= 0
dfForVif$isExternalTrue[index] = 1
index <- df$isEnhancement=="True"
dfForVif$isEnhancementTrue= 0
dfForVif$isEnhancementTrue[index] = 1
index <- df$isPullRequest=="True"
dfForVif$isPullRequestTrue= 0
dfForVif$isPullRequestTrue[index] = 1

usdm::vif(dfForVif)
warnings()
#install.packages("rms")
library(rms)
rms::vif.mer
car::vif.lm
###Following adopted from https://github.com/aufrank/R-hacks/blob/master/mer-utils.R
vif.mer <- function (fit) {
  ## adapted from rms::vif
  v <- vcov(fit)
  nam <- names(fixef(fit))
  ## exclude intercepts
  ns <- sum(1 * (nam == "Intercept" | nam == "(Intercept)"))
  if (ns > 0) {
    v <- v[-(1:ns), -(1:ns), drop = FALSE]
    nam <- nam[-(1:ns)] }
  d <- diag(v)^0.5
  v <- diag(solve(v/(d %o% d)))
  names(v) <- nam 
  v
}

vif.mer(fit)

names(df)
keep=c("isEnhancement","numExtCrossReferences")
dfCorCoeff=df[keep]
names(dfCorCoeff)
corM = cor (dfCorCoeff)
summary(dfCorCoeff)
print(corM)
library(MASS)
chisq.test(table(df$isEnhancement,df$isCRAN))
#### =========

dim(df)

######## Mean of different categories

colsSummary <- c("timeTakenToClose","comments","users");
dfExternal <- subset(df,isExternal == "False")
dim(dfExternal)
library(stargazer)

###
print("Category: All")
df1<-dfExternal
dfSummary <- df1[colsSummary]  
dim(dfSummary)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)
min(df$timeTakenToClose)

#####
print("Category: PRs")
df1<-subset(dfExternal,(isPullRequest == "True"))
dfSummary <- df1[colsSummary]  
dim(dfSummary)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)

#####
print("Category: Bug reports")
df1<-subset(dfExternal,isPullRequest == "False" )
dfSummary <- df1[colsSummary]  
dim(dfSummary)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)

#####
print("Category: is Enhancement")
df1<-subset(dfExternal, isEnhancement == "True")
dfSummary <- df1[colsSummary]  
dim(dfSummary)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)
####
print("Category: is CRAN")
df1<-subset(dfExternal, isCRAN == "True")
dfSummary <- df1[colsSummary]  
dim(dfSummary)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)

###
summary(df$sourceContributors)
dim(subset(dfExternal,sourceContributors > 10))
####
#### More people = more coordination = Longer
print("Category: Large projects")
df1<-subset(dfExternal, sourceContributors > 10)
dfSummary <- df1[colsSummary]  
dim(dfSummary)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)
#####

#### More people = more coordination = Longer
print("Category: Small projects")
df1<-subset(dfExternal, sourceContributors <= 10)
dfSummary <- df1[colsSummary]  
dim(dfSummary)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)
#####

summary(df$ageInYears)

print("Category: Old projects")
dim(subset(dfExternal,ageInYears > 4))
df1<-subset(dfExternal, ageInYears > 4)
dfSummary <- df1[colsSummary]  
dim(dfSummary)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)
######

print("Category: New projects")
dim(subset(dfExternal,ageInYears <= 4))
df1<-subset(dfExternal, ageInYears <= 4)
dfSummary <- df1[colsSummary]  
dim(dfSummary)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)
######


#########
keep=c("timeTakenToCloseLog","commentsLog","usersLog");
dfCorCoeff = df[keep]
names(dfCorCoeff)
corM = cor (dfCorCoeff)
print(corM)
#install.packages("corrplot")
library(corrplot) #package corrplot
corrplot(corM, method = "circle") #plot matrix
corM1 <- apply(corM,2,function(x) ifelse((x>0.4),1,0))
corrplot(corM1, method = "circle") #plot matrix

####### 1-sample t-test
df1<-subset(dfExternal, isEnhancement == "True")
dfSummary <- df1[colsSummary]  
dim(dfSummary)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)
t.test(dfSummary$timeTakenToClose, alternative="greater",mu=49.07)

df1<-subset(dfExternal, sourceContributors > 10)
dfSummary <- df1[colsSummary]  
names(dfSummary)
stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)
t.test(dfSummary$timeTakenToClose, alternative="greater",mu=49.07)
t.test(dfSummary$comments, alternative="greater",mu=3.88)

citation(package="lmerTest",lib.loc=NULL)
citation(package="rms",lib.loc=NULL)
citation(package="MuMIn",lib.loc=NULL)

dev.off()

