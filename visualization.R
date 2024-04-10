# load libraries
library(fpp2)
library(tidyverse)    
library(lubridate)

# read csv
data <- read.csv('/Users/alessia/Desktop/air.pollution/LSTM-Multivariate_pollution.csv')

# as tibble
data$day <- as.Date(data$date)
pol <- data %>% select('pollution', 'dew', 'temp', 'wnd_spd', 'rain', 'snow') %>% as_tibble()
pol %>% str()
pol_ts <- ts(pol)

# trend plot
pol_ts %>%
  autoplot()

# corrplot
library(corrplot)
date.trans <- ymd_hms(data$date)
data$year <- year(date.trans)
data$month <- month(date.trans)
data$hour <- hour(date.trans)
corrplot(cor(data[-c(1, 6, 10)], method = 'pearson'), tl.col = 'black')
corrplot(cor(data[-c(1,6,10)], method = 'spearman'), tl.col = 'black')

# trend plots separated
pol_ts %>%
  autoplot(facets = T)


# seasonal plot
library(dplyr)

pollution2 <- data %>%
  group_by(year, month) %>%
  summarize(pollution = mean(pollution)) %>%
  ungroup() %>%
  mutate(year = as.factor(year),
         month = factor(month, levels = unique(month)),
         )

ggplot(data = pollution2, aes(x = month, y = pollution, group = year, colour = year)) + 
  geom_line() 


# subseries plots
pollution2
pol2 <- pollution2 %>% as_tibble()
pol2_ts <- ts(pol2)

pollution_values <- pol2_ts[, 'pollution']
ts_data <- ts(pollution_values, start = c(pol2_ts[1, "year"], pol2_ts[1, "month"]), frequency = 12)

b1 <- ts_data %>%
  autoplot()
b2 <- ts_data %>%
  ggsubseriesplot()

plot_grid(b1, b2, ncol=1, rel_heights = c(1, 1.5))


# lag plots (for randomness)
b3 <- gglagplot(ts_data, do.lines = F)
plot_grid(b1, b3, ncol = 1, rel_heights = c(1,2))


# autocorrelation function plots

# ACF: visualizes how much the most recent value of the series is correlated with past values
a1 <- ggAcf(ts_data, lag.max = 20)
# PACF: visualizes whether certain lags are good for modeling or not
a2 <- ggPacf(ts_data, lag.max = 20)
plot_grid(a1, a2, ncol = 1)
# the seasonality effect is very visible here


