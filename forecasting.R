# forecast by month (average of the pollution level by month, 60 time intervals in total)

# average, naive, seasonal, drift and Holt Winters forecasting methods
plot(meanf(ts_data, h = 8)) # average forecasting
plot(naive(ts_data, h = 8)) # naive forecasting
plot(snaive(ts_data, h = 8)) # seasonal naive forecasting
plot(rwf(ts_data, h = 8, drift = T)) # drift forecasting
plot(forecast(HoltWinters(ts_data), h = 8)) # Holt Winters forecasting

# all forecasting methods on the same plot
autoplot(ts_data) +
  autolayer(meanf(ts_data, h = 11),
            series = 'Mean', PI = FALSE) +
  autolayer(naive(ts_data, h = 11),
            series = 'Naive', PI = FALSE) +
  autolayer(snaive(ts_data, h = 11),
            series = 'Seasonal Naive', PI = FALSE) +
  autolayer(rwf(ts_data, h = 11, drift = TRUE),
            series = 'Drift', PI = FALSE) +
  autolayer(hw(ts_data, h = 11),
            series = 'Holt Winters', PI = FALSE) +
  ggtitle('Forecasts for pollution') +
  xlab('Year') +
  ylab('Pollution') +
  guides(colour = guide_legend(title = 'Forecast'))

# residuals from naive method
res <- residuals(naive(ts_data))
autoplot(res) + xlab("Year") + ylab("") +
  ggtitle("Residuals from naive method")

gghistogram(res) + ggtitle("Histogram of residuals from naive method")

ggAcf(res) + ggtitle("ACF of residuals from naive method")

checkresiduals(naive(ts_data)) # pack plots and check Ljung-Box test


# residuals from seasonal naive method
res <- residuals(snaive(ts_data))
autoplot(res) + xlab("Year") + ylab("") +
  ggtitle("Residuals from seasonal naive method")

gghistogram(res) + ggtitle("Histogram of residuals from seasonal naive method")

ggAcf(res) + ggtitle("ACF of residuals from seasonal naive method")

checkresiduals(snaive(ts_data))
# autocorrelation is detected

# residuals from drift forecasting method
res <- residuals(rwf(ts_data, drift = T))
autoplot(res) + xlab("Year") + ylab("") +
  ggtitle("Residuals from drift forecasting method")

gghistogram(res) + ggtitle("Histogram of residuals from drift method")

ggAcf(res) + ggtitle("ACF of residuals from drift method")

checkresiduals(rwf(ts_data, drift = T))


# residuals from Holt Winters method
res <- residuals(hw(ts_data))
autoplot(res) + xlab("Year") + ylab("") +
  ggtitle("Residuals from Holt Winters forecasting method")

gghistogram(res) + ggtitle("Histogram of residuals from Holt Winters method")

ggAcf(res) + ggtitle("ACF of residuals from Holt Winters method")
# residuals may not be normal: long tail

checkresiduals(hw(ts_data))
# autocorrelation is detected


# training and test set
test <- subset(ts_data, start = length(ts_data) - 12) # extract observations from the last year
train <- subset(ts_data, start = 1, end = length(ts_data)-12) 


# Train the models on data excluding the fifth year
avg.fit1 <- meanf(train, h = 12)
naive.fit1 <- naive(train, h = 12)
snaive.fit1 <- snaive(train, h = 12)
drift.fit1 <- rwf(train, h = 12, drift = TRUE)
stlf.fit1 <- stlf(train, h = 12)
splinef.fit1 <- splinef(train, h = 12)
hw.fit1 <- hw(train, h = 12)

# Plot forecasted values
forecast_plot <- autoplot(window(ts_data, start = 1)) +
  autolayer(avg.fit1, series = 'Mean', PI = F) +
  autolayer(naive.fit1, series = "Naive", PI = FALSE) +
  autolayer(snaive.fit1, series = "Seasonal Naive", PI = FALSE) +
  autolayer(drift.fit1, series = "Drift", PI = FALSE) +
  autolayer(hw.fit1, series = "Holt-Winters", PI = FALSE) +
  autolayer(stlf.fit1, series = 'STL', PI = F) +
  autolayer(splinef.fit1, series = 'Splinef', PI = F) +
  xlab("Year") + ylab("Pollution") +
  ggtitle("Pollution by time") +
  guides(colour = guide_legend(title = "Forecast"))

forecast_plot

# average method
accuracy(avg.fit1, test)
# RMSE 33.19787
# MAE 26.10841
# MAPE (mean absolute percentage error) 27.57026
# MASE (mean absolute scaled error) 1.0385349

# naive method
accuracy(naive.fit1, test)
# RMSE 33.02440
# MAE 26.27955
# MAPE 28.45260
# MASE 1.0453421

# seasonal naive
accuracy(snaive.fit1, test)
# RMSE 34.91951
# MAE 28.21485
# MAPE 29.86521
# MASE 1.122324

# drift method
accuracy(drift.fit1, test)
# RMSE 33.40014
# MAE 26.86833
# MAPE 29.64274
# MASE 1.0687628

# holt-winters method
accuracy(hw.fit1, test)
# RMSE 26.50625
# MAE 22.06728
# MAPE 25.06838
# MASE 0.8777873

# STL method
accuracy(stlf.fit1, test)
# RMSE 26.11926
# MAE 19.95815
# MAPE 21.39515
# MASE 0.7938910

# splinef method
accuracy(splinef.fit1, test)
# RMSE 33.13088
# MAE 26.21353
# MAPE 28.17563
# MASE 1.0427162

# As shown previously by the plot, and later confirmed by looking at various
# measurements of errors, the STL method for forecasting yields the
# best results on this dataset.


# Prediction intervals (95% confidence)
avg.fit1 # lower bound 40.50055, upper bound 146.4655
naive.fit1
snaive.fit1
drift.fit1
hw.fit1
stlf.fit1
splinef.fit1


# visualize STL with prediction interval of 95% confidence
stl_forecast <- forecast(stlf.fit1, h = 12)
forecast_plot.2 <- autoplot(window(ts_data, start = 1)) +
  autolayer(stlf.fit1, series = "STL", PI = FALSE) +
  autolayer(stl_forecast, series = "Forecast", PI = TRUE) +
  xlab("Year") + ylab("Pollution") +
  ggtitle("Pollution by time") +
  guides(colour = guide_legend(title = "Forecast"))
last_year <- window(ts_data, start = end(time(ts_data)) - 11)
forecast_plot.2 <- forecast_plot.2 + 
  autolayer(last_year, series = "Actual", alpha = 0.5)

forecast_plot.2
