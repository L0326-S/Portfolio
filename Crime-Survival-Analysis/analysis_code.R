#데이터 불러오기
crime <- read.csv("범죄발생부터_검거까지의_기간.csv", fileEncoding = "euc-kr")
crime.all <- read.csv("범죄의_발생_검거상황_총괄.csv", fileEncoding = "euc-kr")


#데이터 정리
colnames(crime) <- as.character(crime[1,])
crime <- crime[-1,]
crime[1:3] <- lapply(crime[1:3], as.factor)
crime[4:13] <- lapply(crime[4:13], as.integer)
crime[is.na(crime)]<-0
colnames(crime)[1:4] <- c("crime1", "crime2", "crime3","cases")
library(tidyverse)
library(survival)
library(KMsurv)
library(ggplot2)
library(interval)
library(data.table)

#전체 범죄수 포함 - 행 고르기
colnames(crime.all) <- as.character(crime.all[1,])
crime.all <- crime.all[-1,]
crime.all <- crime.all[crime.all$`범죄별(4)` == "소계",c(1:3,5:8)]
crime.all[1,1]<-"합계"
crime.all[1:3] <- lapply(crime.all[1:3], as.factor)
crime.all[c(4,6)] <- lapply(crime.all[c(4,6)], as.integer)
crime.all[c(5,7)] <- lapply(crime.all[c(5,7)], as.double)
crime.all[is.na(crime.all)]<-0
colnames(crime.all) <- c("crime1", "crime2", "crime3",
                         "cases_all","ratio10","cases","ratio")

crime_full <- inner_join(crime, crime.all, 
                         by = c("crime1", "crime2", "crime3", "cases"))
crime_full <- subset(crime_full, crime1 != "특별법범")

#subset
crime.sub <- subset(crime_full, select = -c(cases_all, ratio10,ratio))

crime.sum <- subset(crime_full, crime3 == "소계", select = -crime3)
crime.id <- subset(crime_full, crime3 != "소계")

total <- subset(crime.sub, crime1 == "합계", select = -c(crime1, crime2, crime3))
total <- total %>% gather(colnames(total)[2:10], key = "time", value = "cases")
total
total <- total %>%
  mutate(left = ifelse(time == "1일 이내", 0, 
                       ifelse(time == "2일 이내", 1,
                              ifelse(time == "3일 이내", 2,
                                     ifelse(time == "10일 이내", 4,
                                            ifelse(time == "1개월 이내", 11,
                                                   ifelse(time == "3개월 이내", 31,
                                                          ifelse(time == "6개월 이내", 93,
                                                                 ifelse(time == "1년 이내", 184,
                                                                        ifelse(time == "1년 초과", 366, NA))))))))),
         right = ifelse(time == "1일 이내", 1, 
                        ifelse(time == "2일 이내", 2,
                               ifelse(time == "3일 이내", 3,
                                      ifelse(time == "10일 이내", 10,
                                             ifelse(time == "1개월 이내", 30,
                                                    ifelse(time == "3개월 이내", 92,
                                                           ifelse(time == "6개월 이내", 183,
                                                                  ifelse(time == "1년 이내", 365,
                                                                         ifelse(time == "1년 초과", Inf, NA))))))))))
total <- data.table(total)

total.expanded <- total[,list(freq=rep(1,cases)), by=c("left","right")]
total.expanded[ ,freq := NULL]

surv.c <- Surv(total.expanded$left, total.expanded$right, type = "interval2")
table(surv.c)
surv.fit <- icfit(surv.c~1)
summary(surv.fit)
plot(surv.fit)
