library(gdata)  
library(ggplot2)
library(psych)

sink()
setwd("/Users/arunkaly/My_research_Not_in_Box/pypi/csv")
getwd()

#df = read.csv("pypi_final_issue_dataset.csv")
#df = read.csv("pypi_final_issue_new.csv")
df = read.csv("CombinedDataset_pypi.csv")

#mean(df[df$is_external=="True",]$comments)
#mean(df[df$is_external=="False",]$comments)

#summary(df)

names(df)
dim(df)

##### Write dataset to another file for sharing ####

names(df)

df$repo_age_years = df$repo_age_secs / 3600
df$repo_age_years = df$repo_age_years / 24 #days
df$repo_age_years = df$repo_age_years / 30 #months
df$repo_age_years = df$repo_age_years / 12 #years


df$is_external_certain = df$is_external_wo_eng_words
df$is_external_ambiguous = "False"
df[df$is_external=="True" & df$is_external_wo_eng_words=="False",]$is_external_ambiguous = "True"
df$depends_on_vetted = 'Yes'
df[df$is_external_wo_eng_words_wo_builtin == "True" ,]$depends_on_vetted = "No"
df[df$is_external_wo_eng_words_wo_builtin == "True" & df$is_external_wo_eng_words_with_builtin == 'True',]$depends_on_vetted = "Both"
df[df$is_external_ambiguous == "True" ,]$depends_on_vetted = "AMBIGUOUS"
df$is_contributor_submitted = df$is_reporter_developer
df$dependencies_count = df$deps_count
keeps =  c("issue_id", "repo", "is_open","time_in_secs", "comments", "users", "is_external_certain",
           "is_external_ambiguous", "depends_on_vetted", "is_pullrequest", "is_feature", "is_contributor_submitted",
           "crossrefs","dependencies_count","repo_stars","repo_age_years", "repo_contributors",  "repo_size_kb")
df_dataset = df[keeps]
dim(df_dataset)
dim(df[df$is_external_certain == "False",])
write.csv(df_dataset, file = "Coordination_Costs_Dataset_PyPI.csv")
##########################


################# To get Fractions ######

dim(subset(df,is_open == "True"))
dim(subset(df,is_pullrequest == "False"))

### All Ext
allExt = subset(df,is_external == "True")
dim(allExt)
issueSet = subset(allExt,is_pullrequest == "False")
dim(issueSet)
set1 = subset(issueSet,is_open == "True")
dim(set1)
set1 = subset(issueSet,is_open == "False")
dim(set1)

issueSet = subset(allExt,is_pullrequest == "True")
dim(issueSet)
set1 = subset(issueSet,is_open == "True")
dim(set1)
set1 = subset(issueSet,is_open == "False")
dim(set1)

#### WO eng words
names(df)
allExt = subset(df,df$is_external_wo_eng_words  == "True" )
dim(allExt)
issueSet = subset(allExt,is_pullrequest == "False")
dim(issueSet)
set1 = subset(issueSet,is_open == "True")
dim(set1)
set1 = subset(issueSet,is_open == "False")
dim(set1)

issueSet = subset(allExt,is_pullrequest == "True")
dim(issueSet)
set1 = subset(issueSet,is_open == "True")
dim(set1)
set1 = subset(issueSet,is_open == "False")
dim(set1)

### WO ENG Words and WO BuiltINs
names(df)
allExt = subset(df, is_external_wo_eng_words_wo_builtin == "True")
dim(allExt)
issueSet = subset(allExt,is_pullrequest == "False")
dim(issueSet)
set1 = subset(issueSet,is_open == "True")
dim(set1)
set1 = subset(issueSet,is_open == "False")
dim(set1)

issueSet = subset(allExt,is_pullrequest == "True")
dim(issueSet)
set1 = subset(issueSet,is_open == "True")
dim(set1)
set1 = subset(issueSet,is_open == "False")
dim(set1)

### WITHOUT ENG dictionary words and WITH BuiltIns
names(df)
allExt = subset(df, is_external_wo_eng_words_with_builtin == "True")
dim(allExt)
issueSet = subset(allExt,is_pullrequest == "False")
dim(issueSet)
set1 = subset(issueSet,is_open == "True")
dim(set1)
set1 = subset(issueSet,is_open == "False")
dim(set1)

issueSet = subset(allExt,is_pullrequest == "True")
dim(issueSet)
set1 = subset(issueSet,is_open == "True")
dim(set1)
set1 = subset(issueSet,is_open == "False")
dim(set1)
##############################

### For Model

names(df)
#filter closed issues
df1 = subset(df,is_open=="False")
dim(df1)

#Remove issues that have time to close <= 0, these are just anamolies
df1 = subset(df1, time_in_secs>0)
dim(df1)


#repo age convert to in years
df1$repo_age_years = df1$repo_age_secs / 3600
df1$repo_age_years = df1$repo_age_years / 24 #days
df1$repo_age_years = df1$repo_age_years / 30 #months
df1$repo_age_years = df1$repo_age_years / 12 #years
summary((df1$repo_age_years))


####Log transform variables
incr = 0.5
intIncr = 1
df1$time_in_secs_log = log(df1$time_in_secs+intIncr)
df1$users_log = log(df1$users+intIncr)
df1$comments_log = log(df1$comments+intIncr)

summary(df1$users_log)
df1$repo_age_years_log = log(df1$repo_age_years + incr)
df1$repo_stars_log = log(df1$repo_stars+intIncr)
df1$repo_forks_log = log(df1$repo_forks+intIncr)
df1$repo_watchers_log = log(df1$repo_watchers+intIncr)
df1$repo_contributors_log = log(df1$repo_contributors+intIncr)
df1$repo_size_kb_log = log(df1$repo_size_kb+intIncr)
df1$crossrefs_log = log(df1$crossrefs+intIncr)

df1$deps_count_log = log(df1$deps_count+intIncr)


dim(df1)
names(df1)
library("MuMIn")
df1$time_in_days = (df1$time_in_secs) / 86400
df1$time_in_days_log = log(df1$time_in_days+incr)
library (stats)
##### convert categorical variables to factor
df1$is_pullrequest<-as.factor(df1$is_pullrequest)
df1$is_feature<-as.factor(df1$is_feature)
df1$is_external<-as.factor(df1$is_external)
df1$is_reporter_developer <- as.factor(df1$is_reporter_developer)

### Removing the % ambiguous set (ones with dictionary words) - gives significant improvent in Fit.
df2 = subset(df1, is_external == "False" | (is_external_wo_eng_words == "True"))



##Insanely really big issues
subset(df1, users>300)

###Unique repos:: 24468 among the closed issues
df1UniqRepos = (df1[!duplicated(df1[,c("repo")]),])
dim(df1UniqRepos)
df1UniqUsers  = (df1[!duplicated(df1[,c("reporter")]),])
dim(df1UniqUsers)
"Forks: doesnt matter for now"
dim(subset(df1UniqRepos, df1UniqRepos$repo_is_fork == "True"))



###### Multi Collinearity repo level variables
keep = c("repo_age_years_log","repo_stars_log","repo_watchers_log","repo_forks_log","repo_contributors_log","repo_size_kb_log","comments_log","users_log")
dfCor = df1UniqRepos[keep]
corM = cor (dfCor)
print(corM)
library(corrplot)
corrplot(corM, method = "circle") #plot matrix
corM1 <- apply(corM,2,function(x) ifelse((x>0.6),1,0))
corrplot(corM1, method = "circle") #plot matrix



library(car)
### VIF ###
library("lmerTest")
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

mycenter <- function (x) {
  return(scale(x,center=TRUE, scale=FALSE))
}


df2$users_log = mycenter(df2$users_log)
df2$crossrefs_log = mycenter(df2$crossrefs_log)
df2$repo_stars_log = mycenter(df2$repo_stars_log) 
df2$repo_contributors_log = mycenter(df2$repo_contributors_log)
df2$repo_size_kb_log = mycenter(df2$repo_size_kb_log) 
df2$repo_age_years_log = mycenter(df2$repo_age_years_log) 
df2$deps_count_log = mycenter(df2$deps_count_log)


###############################


### Total
dim(df2)


### External
dim(df2[df2$is_external=="True",])
### Internal
dim(df2[df2$is_external=="False",])
## Descriptives for coordinaton costs
describe(df1$time_in_days)
describe(df1[df1$is_external=="True" ,]$time_in_days)
describe(df1[df1$is_external=="False" ,]$time_in_days)

describe(df1$comments)
describe(df1[df1$is_external=="True" ,]$comments)
describe(df1[df1$is_external=="False" ,]$comments)

describe(df1$users)
describe(df1[df1$is_external=="True" ,]$users)
describe(df1[df1$is_external=="False" ,]$users)

#==================

describe(df2$time_in_days)
describe(df2[df2$is_external=="True" ,]$time_in_days)
describe(df2[df2$is_external=="False" ,]$time_in_days)


describe(df2$comments)
describe(df2[df2$is_external=="True" ,]$comments)
describe(df2[df2$is_external=="False" ,]$comments)

describe(df2$users)
describe(df2[df2$is_external=="True" ,]$users)
describe(df2[df2$is_external=="False" ,]$users)


sink()
######mann whitney test or wilcosxon ran-sum test
sink("MODEL_OUTPUT_pypi_wilcoxon.txt",append=TRUE, split = TRUE)
extTime = df2[df2$is_external=="True",]$time_in_days
intTime = df2[df2$is_external=="False",]$time_in_days
summary(intTime)
summary(extTime)
wilcox.test(extTime,intTime,conf.int=TRUE, paired =FALSE)

extTime = df2[df2$is_external=="True",]$time_in_secs
intTime = df2[df2$is_external=="False",]$time_in_secs
summary(intTime)
summary(extTime)
wilcox.test(extTime,intTime,conf.int=TRUE, paired =FALSE)


extTime = df2[df2$is_external=="True",]$comments
intTime = df2[df2$is_external=="False",]$comments
summary(intTime)
summary(extTime)
wilcox.test(extTime,intTime,conf.int=TRUE, paired =FALSE)


extTime = df2[df2$is_external=="True",]$users
intTime = df2[df2$is_external=="False",]$users
summary(intTime)
summary(extTime)
wilcox.test(extTime,intTime,conf.int=TRUE, paired =FALSE)


####### Mixed effect Models ####

sink("MODEL_OUTPUT_pypi.txt",append=TRUE, split = TRUE)


##Using users as a covariate is the way to go
dim(df2)

### With filtered data
mean(df2[df2$is_external=="False" & df2$is_pullrequest=="True",]$time_in_days)
length(df2[ df2$is_external == "False" & df2$is_pullrequest=="False" &df2$is_reporter_developer=="False",]$time_in_days)
mean(df2[ df2$is_external == "False" & df2$is_pullrequest=="True" &df2$is_reporter_developer=="True",]$time_in_days)
##### Time model
fit = lmerTest::lmer(time_in_secs_log ~   users_log  + is_external +  is_pullrequest + is_feature + is_reporter_developer + 
                       crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                   is_pullrequest*is_external + is_pullrequest*is_reporter_developer + is_external*is_reporter_developer +
                   (1+ is_external|repo) ,  data = df2, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)
library("lsmeans")
lsmeans(fit, specs = c("is_external"))

####^%&^%#&^@%^*&%^&*@!@@! Comments Model

fit = lmerTest::lmer(comments_log ~   users_log + is_external +  is_pullrequest + is_feature + is_reporter_developer + 
                       crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                   is_pullrequest*is_external + is_pullrequest*is_reporter_developer + is_external*is_reporter_developer +
                   (1+ is_external|repo) ,  data = df2, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)
lsmeans(fit, specs = c("is_external"))


####^%&^%#&^@%^*&%^&*@!@@! Users Model


fit = lmerTest::lmer(users_log ~  comments_log + is_external +  is_pullrequest + is_feature + is_reporter_developer + 
                   crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                   is_pullrequest*is_external + is_pullrequest*is_reporter_developer + is_external*is_reporter_developer +
                   (1+ is_external|repo) ,  data = df2, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)

###@#@^&#%@@@@@@@@!!&^*&^### All above wth the un-filtered data :: i.e. ambiguous set treated as external

##### Time model
fit = lmerTest::lmer(time_in_secs_log ~   users_log  + is_external +  is_pullrequest + is_feature + is_reporter_developer + 
                       crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                       is_pullrequest*is_external + is_pullrequest*is_reporter_developer + is_external*is_reporter_developer +
                       is_external*repo_contributors_log + 
                       (1+ is_external|repo) ,  data = df1, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)

####^%&^%#&^@%^*&%^&*@!@@! Comments Model



fit = lmerTest::lmer(comments_log ~  users_log + is_external +  is_pullrequest + is_feature + is_reporter_developer + 
                   crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                   is_pullrequest*is_external + is_pullrequest*is_reporter_developer + is_external*is_reporter_developer +
                   is_external*repo_contributors_log + 
                   (1+ is_external|repo) ,  data = df1, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)

####^%&^%#&^@%^*&%^&*@!@@! Users Model



fit = lmerTest::lmer(users_log ~  comments_log + is_external +  is_pullrequest + is_feature + is_reporter_developer + 
                   crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                   is_pullrequest*is_external + is_pullrequest*is_reporter_developer + is_external*is_reporter_developer +
                   is_external*repo_contributors_log + 
                   (1+ is_external|repo) ,  data = df1, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)


###@#@^&#%@@@@@@@@!!&^*&^### All above wth the un-filtered data BUT ambiguous set treated as internal

##### Time model

fit = lmerTest::lmer(time_in_secs_log ~   users_log  + is_external_wo_eng_words +  is_pullrequest + is_feature + is_reporter_developer + 
                       crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                       is_pullrequest*is_external_wo_eng_words + is_pullrequest*is_reporter_developer + is_external_wo_eng_words*is_reporter_developer +
                       is_external_wo_eng_words*repo_contributors_log + 
                       (1+ is_external_wo_eng_words|repo) ,  data = df1, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)

####^%&^%#&^@%^*&%^&*@!@@! Comments Model



fit = lmerTest::lmer(comments_log ~  users_log + is_external_wo_eng_words +  is_pullrequest + is_feature + is_reporter_developer + 
                   crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                   is_pullrequest*is_external_wo_eng_words + is_pullrequest*is_reporter_developer + is_external_wo_eng_words*is_reporter_developer +
                   is_external_wo_eng_words*repo_contributors_log + 
                   (1+ is_external_wo_eng_words|repo) ,  data = df1, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)

####^%&^%#&^@%^*&%^&*@!@@! Users Model



fit = lmerTest::lmer(users_log ~  comments_log + is_external_wo_eng_words +  is_pullrequest + is_feature + is_reporter_developer + 
                   crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                   is_pullrequest*is_external_wo_eng_words + is_pullrequest*is_reporter_developer + is_external_wo_eng_words*is_reporter_developer +
                   is_external_wo_eng_words*repo_contributors_log + 
                   (1+ is_external_wo_eng_words|repo) ,  data = df1, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)



###########  Models  to compare different types of packages ####



sink("MODEL_OUTPUT_pypi_vetted.txt",append=TRUE, split = TRUE)

##### First WITH only data from DF2 ####

df2$depends_on_vetted = 'Yes'
df2[df2$is_external_wo_eng_words_wo_builtin == "True" ,]$depends_on_vetted = "No"
df2[df2$is_external_wo_eng_words_wo_builtin == "True" & df2$is_external_wo_eng_words_with_builtin == 'True',]$depends_on_vetted = "Both"
dim(df2[df2$depends_on_vetted == 'Both',])
dim(df2[df2$is_external_wo_eng_words_with_builtin == 'True' & df2$is_external_wo_eng_words_wo_builtin == 'True',])

### DF3 is after filtering is_external == True
df3 = df2[df2$is_external == "True", ]
dim(df2)
dim(df3)
dim(df3[df3$depends_on_vetted == 'Both',])
dim(df3[df3$depends_on_vetted == 'Yes',])
dim(df3[df3$depends_on_vetted == 'No',])


describe(df3$deps_count)
describe(df2$deps_count)

fit = lmerTest::lmer(time_in_secs_log ~   users_log  + deps_count_log + depends_on_vetted +  is_pullrequest + is_feature + is_reporter_developer + 
                       crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                       is_pullrequest*depends_on_vetted +     is_pullrequest*is_reporter_developer + 
                       depends_on_vetted*is_reporter_developer +
                       (1+ depends_on_vetted|repo) ,  data = df3, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)
lsmeans(fit, specs = c("depends_on_vetted"))

fit = lmerTest::lmer(comments_log ~   users_log  + deps_count_log + depends_on_vetted +  is_pullrequest + is_feature + is_reporter_developer + 
                       crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                       is_pullrequest*depends_on_vetted +     is_pullrequest*is_reporter_developer + 
                       depends_on_vetted*is_reporter_developer +
                       (1+ depends_on_vetted|repo) ,  data = df3, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)
lsmeans(fit, specs = c("depends_on_vetted"))


fit = lmerTest::lmer(users_log ~   comments_log  + deps_count_log + depends_on_vetted +  is_pullrequest + is_feature + is_reporter_developer + 
                       crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                       is_pullrequest*depends_on_vetted +     is_pullrequest*is_reporter_developer + 
                       depends_on_vetted*is_reporter_developer +
                       (1+ depends_on_vetted|repo) ,  data = df3, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)

####### do this without removing internal ones. so now depends_on_vetted has four values
df2$depends_on_vetted = 'Neither'
df2[df2$is_external == "True" ,]$depends_on_vetted = "Yes"
df2[df2$is_external_wo_eng_words_wo_cran == "True" ,]$depends_on_vetted = "No"
df2[df2$is_external_wo_eng_words_wo_cran == "True" & df2$is_external_wo_eng_words_with_cran == 'True',]$depends_on_vetted = "Both"
dim(df2[df2$depends_on_vetted == 'Both',])
dim(df2[df2$is_external_wo_eng_words_with_cran == 'True' & df2$is_external_wo_eng_words_wo_cran == 'True',])


fit = lmerTest::lmer(time_in_secs_log ~   users_log + deps_count_log  + depends_on_vetted +  is_pullrequest + is_feature + is_reporter_developer + 
                       crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                       is_pullrequest*depends_on_vetted +     is_pullrequest*is_reporter_developer + 
                       depends_on_vetted*is_reporter_developer +
                       (1+ depends_on_vetted|repo) ,  data = df2, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)



fit = lmerTest::lmer(comments_log ~   users_log + deps_count_log  + depends_on_vetted +  is_pullrequest + is_feature + is_reporter_developer + 
                       crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                       is_pullrequest*depends_on_vetted +     is_pullrequest*is_reporter_developer + 
                       depends_on_vetted*is_reporter_developer +
                       (1+ depends_on_vetted|repo) ,  data = df2, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)




fit = lmerTest::lmer(users_log ~   comments_log + deps_count_log  + depends_on_vetted +  is_pullrequest + is_feature + is_reporter_developer + 
                       crossrefs_log + repo_stars_log + repo_contributors_log + repo_size_kb_log + repo_age_years_log + 
                       is_pullrequest*depends_on_vetted +     is_pullrequest*is_reporter_developer + 
                       depends_on_vetted*is_reporter_developer +
                       (1+ depends_on_vetted|repo) ,  data = df2, REML = FALSE )
summary(fit)
r.squaredGLMM(fit)
anova(fit)



##### Next WITH data from DF1 :: so we will not filter out eng_words -> Treat them as external ####
##******** But this does NOT seem right :: We must not include the ambiguous ones in ur analysis ##***##

###################################################################################################

## Descriptive stats

df2UniqRepos = (df2[!duplicated(df2[,c("repo")]),])
dim(df2UniqRepos)

fact<-as.factor(c("True","False"))
vals <- c(1,0)
vlookup<-function(fact,vals,x) {
  #probably should do an error checking to make sure fact 
  #   and vals are the same length
  
  out<-rep(vals[1],length(x)) 
  for (i in 1:length(x)) {
    out[i]<-vals[levels(fact)==x[i]]
  }
  return(out)
}
#describe(vlookup(fact,vals,df2$is_pullrequest))

#recode Categorical

df2$Num_1<-0
df2[df2$is_external == "True",]$Num_1 = 1
describe(df2$Num_1)


df2$Num_1<-0
df2[df2$is_pullrequest == "True",]$Num_1 = 1
describe(df2$Num_1)

df2$Num_1<-0
df2[df2$is_feature == "True",]$Num_1 = 1
describe(df2$Num_1)


df2$Num_1<-0
df2[df2$is_reporter_developer == "True",]$Num_1 = 1
describe(df2$Num_1)

describe(df2$crossrefs)
describe(df2$deps_count)

describe(df2UniqRepos$repo_stars)
#describe(df2$repo_age_years)

describe(df2UniqRepos$repo_age_years)

describe(df2UniqRepos$repo_contributors)

describe(df2UniqRepos$repo_size_kb)

dim(df2)

dim(df2UniqRepos)

#### RQ1 stats ####

dim(df)
df0 = df[df$is_open == "True" | (df$is_open == "False" & df$time_in_secs>0),]
dim(df0)

#Discarde
len1 = dim(df0[df0$is_external=="True" & df0$is_external_wo_eng_words == "False",])
len1
len1/dim(df0)

#After discarding issues
df0 = df0[df0$is_external=="False" | df0$is_external_wo_eng_words == "True",]
len1 = dim(df0)
len1/dim(df)

len1 = dim(df0[df0$is_external=="True" & df0$is_open == "True" & df0$is_pullrequest == "True",])
len1
len1 / dim(df0[df0$is_open == "True" & df0$is_pullrequest == "True",])

len1 = dim(df0[df0$is_external=="True" & df0$is_open == "False" & df0$is_pullrequest == "True",])
len1
len1 / dim(df0[df0$is_open == "False" & df0$is_pullrequest == "True",])


len1 = dim(df0[df0$is_external=="True" & df0$is_open == "True" & df0$is_pullrequest == "False",])
len1
len1 / dim(df0[df0$is_open == "True" & df0$is_pullrequest == "False",])

len1 = dim(df0[df0$is_external=="True" & df0$is_open == "False" & df0$is_pullrequest == "False",])
len1
len1 / dim(df0[df0$is_open == "False" & df0$is_pullrequest == "False",])


##Total
len1 = dim(df0[df0$is_external=="True" &  df0$is_pullrequest == "False",])
len1
len1 / dim(df0[df0$is_pullrequest == "False",])


len1 = dim(df0[df0$is_external=="True" &  df0$is_pullrequest == "True",])
len1
len1 / dim(df0[df0$is_pullrequest == "True",])

##Overall
len1 = dim(df0[df0$is_external=="True" ,])
len1
len1 / dim(df0)
######################## Aggregate coord cost

dim(df2)


mE = sum(df2[df2$is_external == "True" & df2$is_pullrequest == "False",]$time_in_days)
mT = sum(df2[df2$is_pullrequest == "False",]$time_in_days)
mE/mT

mE = sum(df2[df2$is_external == "True" & df2$is_pullrequest == "False",]$comments)
mT = sum(df2[df2$is_pullrequest == "False",]$comments)
mE/mT

mE = sum(df2[df2$is_external == "True" & df2$is_pullrequest == "False",]$users)
mT = sum(df2[df2$is_pullrequest == "False",]$users)
mE/mT



mE = sum(df2[df2$is_external == "True" & df2$is_pullrequest == "True",]$time_in_days)
mT = sum(df2[df2$is_pullrequest == "True",]$time_in_days)
mE/mT

mE = sum(df2[df2$is_external == "True" & df2$is_pullrequest == "True",]$comments)
mT = sum(df2[df2$is_pullrequest == "True",]$comments)
mE/mT

mE = sum(df2[df2$is_external == "True" & df2$is_pullrequest == "True",]$users)
mT = sum(df2[df2$is_pullrequest == "True",]$users)
mE/mT



mE = sum(df2[df2$is_external == "True",]$time_in_days)
mT = sum(df2$time_in_days)
mE/mT

mE = sum(df2[df2$is_external == "True",]$comments)
mT = sum(df2$comments)
mE/mT

mE = sum(df2[df2$is_external == "True",]$users)
mT = sum(df2$users)
mE/mT


