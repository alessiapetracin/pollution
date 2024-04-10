# average, naive, seasonal, drift and Holt Winters forecasting methods

plot(meanf(ts_data, h = 8)) # average forecasting
plot(naive(ts_data, h = 8)) # naive forecasting
plot(snaive(ts_data, h = 8)) # seasonal naive forecasting
plot(rwf(ts_data, h = 8, drift = T)) # drift forecasting
plot(forecast(HoltWinters(ts_data), h = 8)) # Holt Winters forecasting


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


