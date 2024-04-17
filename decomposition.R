# moving averages (5 MA)
autoplot(ts_data, series="Data") +
  autolayer(ma(ts_data,5), series="5-MA") +
  xlab("Year") + ylab("Pollution") +
  ggtitle("Pollution by time") +
  scale_colour_manual(values=c("Data"="grey50","5-MA"="red"),
                      breaks=c("Data","5-MA"))

# multiplicative decomposition
ts_data %>% decompose(type="multiplicative") %>%
  autoplot() + xlab("Year") +
  ggtitle("Classical multiplicative decomposition
    of pollution")

# additive decomposition
ts_data %>% decompose(type="additive") %>%
  autoplot() + xlab("Year") +
  ggtitle("Classical additive decomposition
    of pollution")


# X11 decomposition
library(seasonal)
ts_data_ts <- ts(ts_data, start = c(2010, 01), frequency = 12)
ts_data_ts %>% seas(x11= '') -> fit
autoplot(fit) +
  ggtitle('X11 decomposition of pollution')

# visualize plots for X11 decomposition together
autoplot(ts_data_ts, series="Data") +
  autolayer(trendcycle(fit), series="Trend") +
  autolayer(seasadj(fit), series="Seasonally Adjusted") +
  xlab("Year") + ylab("Pollution") +
  ggtitle("Pollution") +
  scale_colour_manual(values=c("gray","blue","red"),
                      breaks=c("Data","Seasonally Adjusted","Trend"))

# visualize variations of seasonal component over time, through seasonal sub-series plot
fit %>% seasonal() %>% ggsubseriesplot() + ylab("Seasonal")


# SEATS (seasonal extraction in ARIMA time series) decomposition
ts_data_ts %>% seas() %>%
  autoplot() +
  ggtitle("SEATS decomposition of pollution")

# STL decomposition
ts_data_ts %>%
  stl(t.window=13, s.window="periodic", robust=TRUE) %>%
  autoplot()

ts_data_ts %>%
  stl(t.window=5, s.window="periodic", robust=TRUE) %>%
  autoplot()


# forecasting with decomposition

# naive forecast on seasonally adjusted data from STL decomposition
fit <- stl(ts_data_ts, t.window=5, s.window="periodic",
           robust=TRUE)
fit %>% seasadj() %>% naive() %>%
  autoplot() + ylab("Pollution") +
  ggtitle("Pollution")

# add seasonal naive forecasts of seasonal component
fit %>% forecast(method="naive") %>%
  autoplot() + ylab("Pollution")

# shortcut
fcast <- stlf(ts_data_ts, method='naive', t.window = 13); fcast
autoplot(fcast) + ylab('Pollution') +
  ggtitle('Pollution')
