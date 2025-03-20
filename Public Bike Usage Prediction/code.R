rm(list=ls())


library(dplyr)
library(forecast)
library(ggplot2)
library(lubridate) 
library(scales)
library(tseries)
library(rugarch)
library(lmtest)

file_path <- '/Users/joonseonghong/Desktop/홍준성/서울대학교/24-1/시계열분석 및 실습/프로젝트/데이터/rent_use_day_agg_rt_v001.csv' # 파일 경로 
data <- read.csv(file = file_path)
data$대여일자 <- as.Date(data$대여일자, format="%Y-%m-%d")
data$대여구분코드 <- as.character(data$대여구분코드)
data <- data %>% filter(data$대여구분코드 != "단체권")
data$대여구분코드[data$대여구분코드 == "일일권(비회원)" | data$대여구분코드 == "일일권(회원)"] <- "one-day pass"
data$대여구분코드[data$대여구분코드 == "정기권"] <- "season pass"


data_agg <- data %>%
  group_by(대여일자, 대여구분코드) %>%
  summarise(사용자수 = sum(사용자수), 이용건수 = sum(이용건수), .groups = 'drop')

# 기온, 강수량 data loading & preprocessing
weather_data <- read.csv('/Users/joonseonghong/Desktop/홍준성/서울대학교/24-1/시계열분석 및 실습/프로젝트/데이터/weather_v001.csv') # 파일 경로
colnames(weather_data) <- c("날짜", "평균기온_C", "최저기온_C", "최고기온_C", "강수량_mm")
weather_data$날짜 <- as.Date(weather_data$날짜)
weather_data <- weather_data %>% select(날짜, 평균기온_C, 강수량_mm)
weather_data <- weather_data %>% mutate(강수량_mm = ifelse(is.na(강수량_mm), 0, 강수량_mm))

# merging data
data_agg <- merge(data_agg, weather_data, by.x = "대여일자", by.y = "날짜")


# Initial Plotting
## Visualization by day
ggplot(data_agg, aes(x = 대여일자, y = 사용자수, group = 대여구분코드, color = 대여구분코드)) +
  geom_line() +
  labs(title = "Daily User Counts by Rental Category", x = "Date", y = "Number of Users") +
  scale_color_discrete(breaks = c("season pass", "one-day pass")) +    #for aesthetic purpose
  scale_y_continuous(labels = comma_format()) +
  theme_minimal() +
  theme(legend.title = element_blank())

## Visualization by month
data_agg <- data_agg %>%
  mutate(Year = year(대여일자),
         Month = month(대여일자, label = TRUE, abbr = TRUE)) 

monthly_data <- data_agg %>%
  group_by(Year, Month, 대여구분코드) %>%
  summarise(사용자수 = sum(사용자수), .groups = 'drop')

ggplot(monthly_data, aes(x = Month, y = 사용자수, color = 대여구분코드, group = interaction(Year, 대여구분코드))) +
  geom_line(aes(linetype = as.factor(Year))) +
  labs(title = "Monthly User Counts by Rental Category", x = "Month", y = "Number of Users") +
  scale_linetype_manual(values = c("dashed", "solid")) +  
  scale_color_discrete(breaks = c("season pass", "one-day pass")) + 
  scale_y_continuous(labels = comma_format()) +
  theme_minimal() +
  theme(legend.title = element_blank())

## Visualization of (# of rents)/(# of users) by day
ggplot(data_agg, aes(x = 대여일자, y = 이용건수/사용자수, group = 대여구분코드, color = 대여구분코드)) +
  geom_line() +
  labs(title = "Number of Rents per User", x = "Date", y = "Number of Rents per User") +
  scale_color_discrete(breaks = c("season pass", "one-day pass")) + 
  theme_minimal() +
  theme(legend.title = element_blank())


# Trend, Seasonality, & Error decomposition
## Seasonality Check
season_pass_data <- data_agg %>% filter(대여구분코드 == "season pass")
oneday_pass_data <- data_agg %>% filter(대여구분코드 == "one-day pass")
ts_season_pass_data <- ts(season_pass_data$사용자수, start=c(2022,1), frequency=365)
ts_oneday_pass_data <- ts(oneday_pass_data$사용자수, start=c(2022,1), frequency=365)

season_pass_frequency <- findfrequency(ts_season_pass_data) # frequency = 7
oneday_pass_frequency <- findfrequency(ts_oneday_pass_data) # frequency = 7
lag.plot(ts_season_pass_data, set = c(1:16), pch = ".", diag.col = "red", col = "black")
lag.plot(ts_oneday_pass_data, set = c(1:16), pch = ".", diag.col = "red", col = "black")

par(mfrow = c(2,2))
acf(ts_season_pass_data)
acf(diff(ts_season_pass_data))
acf(ts_oneday_pass_data)
acf(diff(ts_oneday_pass_data))
par(mfrow = c(1,1))

## STL decomposition & ADF Test
stl_decomp_season_pass <- stl(ts(season_pass_data$사용자수, frequency = 7), s.window="per")
plot(stl_decomp_season_pass)

season_pass_trend <- ts(stl_decomp_season_pass$time.series[,"trend"], start = c(2022,1), frequency = 365)
season_pass_seasonality <- ts(stl_decomp_season_pass$time.series[,"seasonal"], start = c(2022,1), frequency = 365)
season_pass_error <- ts_season_pass_data - season_pass_trend - season_pass_seasonality
plot(season_pass_error)
adf.test(season_pass_error) #stationary

stl_decomp_oneday_pass <- stl(ts(oneday_pass_data$사용자수, frequency = 7), s.window="per")
plot(stl_decomp_oneday_pass)

oneday_pass_trend <- ts(stl_decomp_oneday_pass$time.series[,"trend"], start = c(2022,1), frequency = 365)
oneday_pass_seasonality <- ts(stl_decomp_oneday_pass$time.series[,"seasonal"], start = c(2022,1), frequency = 365)
oneday_pass_error <- ts_oneday_pass_data - oneday_pass_trend - oneday_pass_seasonality
plot(oneday_pass_error)
adf.test(oneday_pass_error) #stationary

## Outlier check
detect_outliers <- function(ts) {
  
  Q1 <- quantile(ts, 0.25, na.rm = TRUE)
  Q3 <- quantile(ts, 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  outlier_indices <- which(ts < lower_bound | ts > upper_bound)
  
  return (outlier_indices)
}
detect_outliers(ts_season_pass_data) # No outliers in season pass time series
detect_outliers(ts_oneday_pass_data) # No outliers also in one-day pass time series

# Model fitting & residual analysis
arima_season_pass <- auto.arima(ts(ts_season_pass_data, frequency = 7), stepwise = FALSE, lambda = "auto")
summary(arima_season_pass)
ts.plot(ts(ts_season_pass_data, frequency = 7), fitted(arima_season_pass), col = c("black", "red"))
legend("bottomleft", legend = c("Original", "Fitted"), col = c("black", "red"), lty = 1)
res_season_pass <- arima_season_pass$residuals

plot(res_season_pass)
abline(h = 0, col = "red")
par(mfrow = c(2,2))
acf(res_season_pass)
pacf(res_season_pass)
hist(res_season_pass)
qqnorm(res_season_pass)
qqline(res_season_pass, col = "red")
par(mfrow = c(1,1))
Box.test(res_season_pass, type="Ljung-Box") # Ljung-Box test success
jarque.bera.test(res_season_pass) # Jarque-Bera test fail



arima_oneday_pass <- auto.arima(ts(ts_oneday_pass_data, frequency = 7), stepwise = FALSE, lambda = "auto")
summary(arima_oneday_pass)
ts.plot(ts(ts_oneday_pass_data, frequency = 7), fitted(arima_oneday_pass), col = c("black", "red"))
legend("bottomleft", legend = c("Original", "Fitted"), col = c("black", "red"), lty = 1)
res_oneday_pass <- arima_oneday_pass$residuals

plot(res_oneday_pass)
abline(h = 0, col = "red")
par(mfrow = c(2,2))
acf(res_oneday_pass)
pacf(res_oneday_pass)
hist(res_oneday_pass)
qqnorm(res_oneday_pass)
qqline(res_oneday_pass, col = "red")
par(mfrow = c(1,1))
Box.test(res_oneday_pass, type="Ljung-Box") # Ljung-Box test success
jarque.bera.test(res_oneday_pass) # Jarque-Bera test fail


# 5/18 추가 부분


# 외생변수 도입 (평균기온, 강수)
exogenous_vars <- data_agg %>%
  select(평균기온_C, 강수량_mm) %>%
  as.matrix()

# sarimax fitting
# https://direction-f.tistory.com/70 참고
arimax_season_pass <- auto.arima(ts(ts_season_pass_data, frequency = 7), xreg = exogenous_vars[data_agg$대여구분코드 == "season pass", ], lambda = "auto")
summary(arimax_season_pass)
ts.plot(ts(ts_season_pass_data, frequency = 7), fitted(arimax_season_pass), col = c("black", "red"))
legend("bottomleft", legend = c("Original", "Fitted"), col = c("black", "red"), lty = 1)
res2_season_pass <- arimax_season_pass$residuals

plot(res2_season_pass)
abline(h = 0, col = "red")
par(mfrow = c(2,2))
acf(res2_season_pass)
pacf(res2_season_pass)
hist(res2_season_pass)
qqnorm(res2_season_pass)
qqline(res2_season_pass, col = "red")
par(mfrow = c(1,1))
Box.test(res2_season_pass, type="Ljung-Box") # Ljung-Box test success
jarque.bera.test(res2_season_pass) # Jarque-Bera test fail



arimax_oneday_pass <- auto.arima(ts(ts_oneday_pass_data, frequency = 7), xreg = exogenous_vars[data_agg$대여구분코드 == "one-day pass", ], lambda = "auto")
summary(arimax_oneday_pass)
ts.plot(ts(ts_oneday_pass_data, frequency = 7), fitted(arimax_oneday_pass), col = c("black", "red"))
legend("bottomleft", legend = c("Original", "Fitted"), col = c("black", "red"), lty = 1)
res2_oneday_pass <- arimax_oneday_pass$residuals

plot(res2_oneday_pass)
abline(h = 0, col = "red")
par(mfrow = c(2,2))
acf(res2_oneday_pass)
pacf(res2_oneday_pass)
hist(res2_oneday_pass)
qqnorm(res2_oneday_pass)
qqline(res2_oneday_pass, col = "red")
par(mfrow = c(1,1))
Box.test(res2_oneday_pass, type="Ljung-Box") # Ljung-Box test success
jarque.bera.test(res2_oneday_pass) # Jarque-Bera test fail




# Forecast
h <- 100
forecast_season_pass <- forecast(arimax_season_pass, xreg =  exogenous_vars[1:100,], h)

forecast_df <- data.frame(
  Date = seq.Date(from = as.Date("2024-01-01"), by = "day", length.out = h),
  Mean = as.numeric(forecast_season_pass$mean),
  Lower80 = as.numeric(forecast_season_pass$lower[,1]),
  Upper80 = as.numeric(forecast_season_pass$upper[,1]),
  Lower95 = as.numeric(forecast_season_pass$lower[,2]),
  Upper95 = as.numeric(forecast_season_pass$upper[,2])
)
# Create a data frame for the original data
original_df <- data.frame(
  Date = seq.Date(from = as.Date("2022-01-01"), by = "day", length.out = length(ts_season_pass_data)),
  Users = as.numeric(ts_season_pass_data)
)

# Create the plot
ggplot() +
  geom_line(data = original_df, aes(x = Date, y = Users), color = "black") +
  geom_line(data = forecast_df, aes(x = Date, y = Mean), color = "blue") +
  geom_ribbon(data = forecast_df, aes(x = Date, ymin = Lower95, ymax = Upper95), fill = "blue", alpha = 0.2) +
  geom_ribbon(data = forecast_df, aes(x = Date, ymin = Lower80, ymax = Upper80), fill = "blue", alpha = 0.4) +
  labs(title = "Forecast for Season Pass Users", x = "Date", y = "Number of Users") +
  theme_minimal() +
  scale_x_date(date_labels = "%Y-%m", date_breaks = "3 month") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

forecast_oneday_pass <- forecast(arima_oneday_pass, h)
forecast_df_oneday <- data.frame(
  Date = seq.Date(from = as.Date("2024-01-01"), by = "day", length.out = h),
  Mean = as.numeric(forecast_oneday_pass$mean),
  Lower80 = as.numeric(forecast_oneday_pass$lower[,1]),
  Upper80 = as.numeric(forecast_oneday_pass$upper[,1]),
  Lower95 = as.numeric(forecast_oneday_pass$lower[,2]),
  Upper95 = as.numeric(forecast_oneday_pass$upper[,2])
)

original_df_oneday <- data.frame(
  Date = seq.Date(from = as.Date("2022-01-01"), by = "day", length.out = length(ts_oneday_pass_data)),
  Users = as.numeric(ts_oneday_pass_data)
)

ggplot() +
  geom_line(data = original_df_oneday, aes(x = Date, y = Users), color = "black") +
  geom_line(data = forecast_df_oneday, aes(x = Date, y = Mean), color = "blue") +
  geom_ribbon(data = forecast_df_oneday, aes(x = Date, ymin = Lower95, ymax = Upper95), fill = "blue", alpha = 0.2) +
  geom_ribbon(data = forecast_df_oneday, aes(x = Date, ymin = Lower80, ymax = Upper80), fill = "blue", alpha = 0.4) +
  labs(title = "Forecast for One-Day Pass Users", x = "Date", y = "Number of Users") +
  theme_minimal() +
  scale_x_date(date_labels = "%Y-%m", date_breaks = "3 month") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))





# 변화점 탐지 사용 여부 미정
# change point
cov_calc <- function(dat, h) {
  n <- length(dat)
  xmean <- mean(dat)
  x1 <- dat[1:(n-h)] - xmean
  x2 <- dat[(h+1):n] - xmean
  return(sum(x1 * x2/n))
}

# long run variance
var_calc <- function(dat, max_h = 2^0.5*(log10(length(dat)))^2 ) {
  n <- length(dat)
  sd2_hat <- cov_calc(dat, 0)
  for(i in 1:max_h) {
    sd2_hat <- sd2_hat + 2*(1-i/n)*(cov_calc(dat, i)) # Bartlett kernel
  }
  return(sd2_hat)
}

CUSUM_calc <- function(dat) {
  ## return : maximum cusum test statistics and change point
  n <- length(dat)
  cusum <- abs((cumsum(dat) - (1:n)/n*sum(dat) ) / ( sqrt(n) * sqrt(var_calc(dat))))
  argmax <- which.max(cusum)
  if(max(cusum)>1.358) return(list("CUSUM_statistics" = max(cusum), "change_point"=argmax))
  else return(print("no change"))
}

CUSUM_calc(ts_season_pass_data) # season pass 의 경우 429일째에서 변화점 탐지됨
CUSUM_calc(ts_oneday_pass_data) # oneday pass 의 경우 변화점 탐지되지 않음
