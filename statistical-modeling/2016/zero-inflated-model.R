### Date: June 26
#install.packages("gdata")
  library(gdata)  
  library(ggplot2)
  #setwd("/home/abc")
  getwd()
  df = read.csv("repos-zero-inflated-dataset.csv") 
  summary(df)
  dfOrig<-df
  
  df<-dfOrig
  names(df)
  dim(df)
  drops=c("X","upstreamIssueContributions","upstreamIssueContributionsFraction","upstreamAllContributions","upstreamAllContributionsFraction", "upstreamContributions");
  df<-df[, !(names(df) %in% drops)]
  dim(df)
  names(df)
  
  #Remove missing values
  df1 <- na.exclude(df)
  #Size after removing records with missing column 
  dim(df1)
  #df1 <- na.omit(df)
  df<-df1
  dim(df)
  #This is for log transformations
  increment<-0.5
  intIncr<-increment
  
  totalDependencies <- df$cranDependencies+df$nonCranDependencies
  df$totalDependencies <- totalDependencies
  names(df)
  #hist(df$totalDependencies)
  
  #Compute the age in years
  #df$age <- 1459985777000 - df$createdAtMillis
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
  
  #Calculate the description file churn per year for each repo
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
  summary(df$sourceContributors)#Min is 1 so no need intIncr but we still add because that is the norm
  df$sourceContributorsLog <- log(df$sourceContributors + intIncr)
  df$starsCountLog <- log(df$starsCount+intIncr)
  summary(df$sourceLOC)
  df$sourceLOCLog <- log(df$sourceLOC+intIncr)
  hist(df$sourceLOCLog,breaks=10)
  df$downstreamProjectsLog <- log(df$downstreamProjects+intIncr)
  df$cranDependenciesLog<-log(df$cranDependencies+intIncr)
  df$nonCranDependenciesLog<-log(df$nonCranDependencies+intIncr)
  ##Trying to convert categorical to continuous but not using this in any model
  df$isCRANNum<-as.character(df$isCRAN)
  df$isCRANNum[df$isCRANNum=="True"]<-1
  df$isCRANNum[df$isCRANNum=="False"]<-0
  df$isCRANNum<-as.numeric(df$isCRANNum)
  
  df$averageContributionsToUpstream <- df$upstreamContributionsFraction
  df$averageContributionsToUpstreamLog<-log(df$averageContributionsToUpstream+increment)
  
  #Convert isCran as Factor
  typeof(df$isCRAN)
  df$isCRAN<-factor(df$isCRAN)
  
  names(df)
  
  ### No point fitting a linear regression - the DV is  count data and it is overdispersed (See bogdan FSE 2015 for more)
  #fit<- lm(df$dependencyProblemsLog  ~    nonDependencyProblemsLog +  ageInYearsLog  + sourceContributorsLog  + starsCountLog + descriptionFileChurnPerYearLog +  sourceLOCLog  + downstreamProjectsLog + cranDependenciesLog + nonCranDependenciesLog + averageContributionsToUpstreamLog  + isCRAN + averageUpstreamVersionLog + averageUpstreamReleasesPerYearLog + averageUpstreamAgeInYearsLog + isCRAN, data=df)
  #summary(fit)
  #vif(fit) # variance inflation factors 
  #sqrt(vif(fit)) > 2 # problem?
  #summary(fit)
  #residuals vs fit plot => Not so good looking with outliers, removing outliers (ones with 0 depedency problems) solves this but does not change the regression model so we keep them
  #residualPlot(fit)
  
  ##### ====== We Model this as a Negative Binomial Regression because overdispersion ===
  
  ## Test for overdispersion of DV
  mean(df$dependencyProblems)
  var(df$dependencyProblems)
  
  
  
  #install.packages("stargazer") #Use this to install it, do this only once
  library(stargazer)
  #df$project<-NULL
  colsSummary <- c("dependencyProblems", "nonDependencyProblems" ,  "ageInYears"  , "sourceContributors"  , "starsCount" , "descriptionFileChurnPerYear" ,  "sourceLOC"  , "downstreamProjects" , "averageContributionsToUpstream" , "totalDependencies" , "cranDependencies" , "nonCranDependencies"   , "averageUpstreamVersion" , "averageUpstreamReleasesPerYear" , "averageUpstreamAgeInYears" )
  dfSummary <- df[colsSummary]  
#?stargazer
  stargazer(dfSummary, type = "text", title="Descriptive statistics", median=TRUE, digits=2)
  
  
  ### variance >> mean , but we could also fit a poisson model and show this using dispersion test
  #First a poisson regression
  fitp<- glm(df$dependencyProblems  ~    nonDependencyProblemsLog +  ageInYearsLog  + sourceContributorsLog  + starsCountLog + descriptionFileChurnPerYearLog +  sourceLOCLog  + downstreamProjectsLog + averageContributionsToUpstreamLog + cranDependencies + nonCranDependencies   + averageUpstreamVersion + averageUpstreamReleasesPerYear + averageUpstreamAgeInYears + isCRAN, family="poisson",data=df)
  summary(fitp)
  # There is over dispersion so we have to use negative binomial model
  library(AER)
  dispersiontest(fitp)
  
  library(MASS)
  
  ## Now we fit the GLM NB 
  fitnb<-NULL
  fitnb<- glm.nb(df$dependencyProblems  ~    nonDependencyProblemsLog +  ageInYearsLog  + sourceContributorsLog  + starsCountLog + descriptionFileChurnPerYearLog +  sourceLOCLog  + downstreamProjectsLog + averageContributionsToUpstreamLog + cranDependencies + nonCranDependencies   + averageUpstreamVersion + averageUpstreamReleasesPerYear + averageUpstreamAgeInYears + isCRAN, data=df)
  summary(fitnb)
  
  #Check model assumptions
  #As we mentioned earlier, negative binomial models assume the conditional means are not equal to the conditional variances.
  #This inequality is captured by estimating a dispersion parameter (not shown in the output) that is held constant in a Poisson model.
  #Thus, the Poisson model is actually nested in the negative binomial model. We can then use a likelihood ratio test to compare these two and test this model assumption. 
  X2 <- 2 * (logLik(fitnb) - logLik(fitp))
  X2
  #pval < 0.05 implies the nb was a better fit
  pchisq(X2, df = 1, lower.tail=FALSE)
  
  ## However our DV has lot of zeros (almost half) 
  ## We could use zero inflated model for a better fit
  ## But having zeros alone is not an indication of using zero infl. 
  ## We have to argue that zeros might be due to other reasons so it might be from a different process
  ## See bogdan fse 2015 paper
  ## TO ensure that this was necessary we compare using vuong's test
  df1<-subset(df,subset=df$dependencyProblems==0)
  dim(df)
  dim(df1)
  
  
  
  ###=== Zero inflated model =====
  
  #install.packages("pscl")
  #install.packages("boot")
  library(pscl)
  require(boot)
  sessionInfo()
  hist(df$nonCranDependenciesLog)
  mean(df$cranDependencies)
  mean(df$nonCranDependencies)
  #geom mean
  #require("psych")
  #geometric.mean(df$nonCranDependencies)
  #geometric.mean(df$cranDependencies)
 cranMean = mean(df$cranDependencies)
 cranSD = sd(df$cranDependencies)
  nonCranSD = sd(df$nonCranDependencies)
  nonCranMean = mean(df$nonCranDependencies)
 
  fitZero <-zeroinfl(dependencyProblems ~ nonDependencyProblemsLog +  ageInYearsLog  + sourceContributorsLog  + starsCountLog + descriptionFileChurnPerYearLog +  sourceLOCLog  + downstreamProjectsLog + averageContributionsToUpstreamLog + cranDependencies + nonCranDependencies   + averageUpstreamVersion + averageUpstreamReleasesPerYear + averageUpstreamAgeInYears + isCRAN | nonDependencyProblemsLog +  ageInYearsLog  + sourceContributorsLog  + starsCountLog + descriptionFileChurnPerYearLog +  sourceLOCLog  + downstreamProjectsLog + averageContributionsToUpstreamLog + cranDependencies + nonCranDependencies   + averageUpstreamVersion + averageUpstreamReleasesPerYear + averageUpstreamAgeInYears + isCRAN, data=df,dist = "negbin")
  #fitZero <-zeroinfl(dependencyProblems ~ nonDependencyProblemsLog +  ageInYearsLog  + sourceContributorsLog  + starsCountLog + descriptionFileChurnPerYearLog +  sourceLOCLog  + downstreamProjectsLog + averageContributionsToUpstreamLog + totalDependencies   + averageUpstreamVersion + averageUpstreamReleasesPerYear + averageUpstreamAgeInYears + isCRAN | nonDependencyProblemsLog +  ageInYearsLog  + sourceContributorsLog  + starsCountLog + descriptionFileChurnPerYearLog +  sourceLOCLog  + downstreamProjectsLog + averageContributionsToUpstreamLog + totalDependencies + averageUpstreamVersion + averageUpstreamReleasesPerYear + averageUpstreamAgeInYears + isCRAN, data=df,dist = "negbin")
  #cor(df$nonCranDependencies, df$totalDependencies)
  summary(fitZero)
  AIC (fitZero)
  dim(df)
  #Deos this predict better than null model with just the intercept
  fitZeroIntr <- update(fitZero, . ~ 1)

  pchisq(2 * (logLik(fitZero) - logLik(fitZeroIntr)), df = 1, lower.tail=FALSE)
  
  #Does this zero infl model fit better than a negative Binomial model
  vuong(fitZero,fitnb)

  ## Passing fitZero is incorrect - either use fitnb or find out how to extract what vif needs correctly
  car::vif(fitnb) 
  ## perfect multi collinearity
  sqrt(vif(fitnb)) > 2 # problem?
  
  
  #install.packages("usdm")
  library(usdm)
  #install.packages("HH")
  library(HH)
  
  HH::vif(fitZero) # variance inflation factors 
  usdm::vif(fitnb)
  sqrt(vif(fitnb)) > 2 # problem?


est <- cbind(Estimate = coef(fitZero), confint(fitZero))
est
exp(est)
cor(df$averageUpstreamAgeInYears,df$averageUpstreamVersion)
  cor(df$averageUpstreamAgeInYears,df$averageUpstreamReleasesPerYear)
  cor(df$averageUpstreamVersion,df$averageUpstreamReleasesPerYear)
  
### Bootstrap confidence interval
coef(fitZero)[10]
coef(fitZero)[11]
library(boot)
## To replicate same set the seed
set.seed(10)
#?boot

  mean(df$nonCranDependencies)
func <- function( data, indices) {
  #Select your own sample of size 90% of 3161 = 2845
  d <- data[sample(nrow(data),2500),]
  #print(dim(d))
  #d <- data[indices,] # allows boot to select sample 
  fit <- zeroinfl(dependencyProblems ~ nonDependencyProblemsLog +  ageInYearsLog  + sourceContributorsLog  + starsCountLog + descriptionFileChurnPerYearLog +  sourceLOCLog  + downstreamProjectsLog + averageContributionsToUpstreamLog + cranDependencies + nonCranDependencies   + averageUpstreamVersion + averageUpstreamReleasesPerYear + averageUpstreamAgeInYears + isCRAN | nonDependencyProblemsLog +  ageInYearsLog  + sourceContributorsLog  + starsCountLog + descriptionFileChurnPerYearLog +  sourceLOCLog  + downstreamProjectsLog + averageContributionsToUpstreamLog + cranDependencies + nonCranDependencies   + averageUpstreamVersion + averageUpstreamReleasesPerYear + averageUpstreamAgeInYears + isCRAN, data=d,dist = "negbin" )
  #print(c(coef(fit)[10], coef(fit)[11]))
  return(c(coef(fit)[10], coef(fit)[11]))
} 

  
  #Iterations = R
#bsResults <- boot(data=df, statistic=func, R=1000)

  print(bsResults)
plot(bsResults,index=2)

boot.ci(bsResults, index = 1, conf = 0.95, type="perc")

####### Test multi collinearity with VIF and pairwise correlation
#install.packages("car")
library(car)

##VIF is not sensible for Zero inflated models
## Bogdan 2015 FSE use VIF 
car::vif(fitZero) # variance inflation factors 
## perfect multi collinearity
sqrt(vif(fitnb)) > 2 # problem?


print(fitZero)
summary(fitZero)
fitZero$coef$count



### pairwise correlation ##


cols=c("nonDependencyProblemsLog" ,  "ageInYearsLog",  "sourceContributorsLog"  , "starsCountLog"  , "descriptionFileChurnPerYearLog"  ,  "sourceLOCLog"  , "downstreamProjectsLog" , "averageContributionsToUpstreamLog" , "cranDependencies" , "nonCranDependencies"   , "averageUpstreamVersion" , "averageUpstreamReleasesPerYear" , "averageUpstreamAgeInYears" )
dfCorCoeff = df[cols]

names(dfCorCoeff)
#cor (dfCorCoeff, use="pairwise.complete.obs")
corM = cor (dfCorCoeff)
print(corM)
#install.packages("corrplot")
library(corrplot) #package corrplot
corrplot(corM, method = "circle") #plot matrix
corM1 <- apply(corM,2,function(x) ifelse((x>0.5),1,0))
corrplot(corM1, method = "circle") #plot matrix


###
#===Goodness of fit and R^2

install.packages("ResourceSelection")
library(ResourceSelection)

#Hoslem GOF test is also for logistic reg or binary data
#TD *** SEE if we can report this in the paper because the nb and poisson are failing this test, so it is good.
hoslemTest<-hoslem.test(df$dependencyProblems, fitted(fitZero))
hoslemTest
hoslemTest<-hoslem.test(df$dependencyProblems, fitted(fitnb))
hoslemTest
hoslemTest<-hoslem.test(df$dependencyProblems, fitted(fitp))
hoslemTest
#This is the R^2 pseudo, the previous value  may be incorrect
rsquare<-cor(df$dependencyProblems,predict(fitZero))^2
rsquare
rsquare<-cor(df$dependencyProblems,predict(fitnb))^2
rsquare
rsquare<-cor(df$dependencyProblems,predict(fitp))^2
rsquare

#Pseudo R-square, but this is for negative binomial logistic regression
rsquare <- 1-(fitnb$deviance/fitnb$null.deviance)
rsquare
rsquare <- 1-(fitZero$deviance/fitZero$null.deviance)
rsquare
rsquare <- 1-(fitp$deviance/fitp$null.deviance)
rsquare

#======================== Multi collinearity


dev.off()

