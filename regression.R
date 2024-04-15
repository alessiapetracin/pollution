# read dataset
data <- read.csv('/Users/alessia/Desktop/air.pollution/LSTM-Multivariate_pollution.csv')

date.trans <- ymd_hms(data$date)
data$year <- year(date.trans)
data$month <- month(date.trans)
data$hour <- hour(date.trans)

# seasonal plot by month, year
pollution4 <- data %>%
  group_by(year, month) %>%
  summarize(pollution = mean(pollution), dew = mean(dew), temp = mean(temp), press = mean(press),
            wnd_spd = mean(wnd_spd), snow = mean(snow), rain = mean(rain)) %>%
  ungroup() %>%
  mutate(year = as.factor(year),
         month = factor(month, levels = unique(month))
  )

# ts object
pol <- pollution4 %>% as_tibble()
pol %>% str()
pol_ts2 <- ts(pol)

# linear regression by month
mod2 <- tslm(pollution ~ year + month + dew + temp + press + wnd_spd + snow + rain, data = pol_ts2)
summary(mod2)

# plot data vs fitted
autoplot(pol_ts2[,'pollution'], series="Data") +
  autolayer(fitted(mod2), series="Fitted") +
  xlab("Time") + ylab("Pollution") +
  ggtitle("Pollution") +
  guides(colour=guide_legend(title=" "))

# actual vs predicted values
cbind(Data = pol_ts2[,"pollution"],
      Fitted = fitted(mod2)) %>%
  as.data.frame() %>%
  ggplot(aes(x=Data, y=Fitted)) +
  geom_point() +
  ylab("Fitted (predicted values)") +
  xlab("Data (actual values)") +
  ggtitle("Pollution") +
  geom_abline(intercept=0, slope=1)
# the fitted values follow the data closely enough, as also shown by the previous plot

# evaluate model
checkresiduals(mod2)
# autocorrelation is detected

df <- as.data.frame(pol_ts2)
df[,"Residuals"]  <- as.numeric(residuals(mod2))
p1 <- ggplot(df, aes(x=dew, y=Residuals)) +
  geom_point()
p2 <- ggplot(df, aes(x=temp, y=Residuals)) +
  geom_point()
p3 <- ggplot(df, aes(x=press, y=Residuals)) +
  geom_point()
p4 <- ggplot(df, aes(x=rain, y=Residuals)) +
  geom_point()
p5 <- ggplot(df, aes(x=snow, y=Residuals)) +
  geom_point()
p6 <- ggplot(df, aes(x=month, y=Residuals)) +
  geom_point()
p7 <- ggplot(df, aes(x=year, y=Residuals)) +
  geom_point()
p4 <- ggplot(df, aes(x=wnd_spd, y=Residuals)) +
  geom_point()
gridExtra::grid.arrange(p1, p2, p3, p4, p5, p6, p7, nrow=2)


# transform the variables to more normal distributions
# create dataframe with transformed variables
new.data <- data.frame(pollution4$year, pollution4$month, pollution4$pollution)

# transform variables through Box-Cox
library(car)
par(mfrow = c(1, 2))

for (var in colnames(pollution4)[4:9]){
  if (min(pollution4[[var]]) <= 0){
    constant <- abs(min(pollution4[[var]])) + 0.00000001
    pollution4[[var]] <- pollution4[[var]] + constant
  }
  bc <- boxCox(pollution4[[var]] ~ 1) # also gives the log-likelihood plot  
  
  lambdah <- bc$x[which.max(bc$y)]
  cat("lambda", var, 'is:', lambdah, "\n")
  
  # transform 
  trans <- bcPower(pollution4[[var]], lambdah)
  qqnorm(trans, main = var)
  
  x <- shapiro.test(trans)$p.value
  
  cat("p-value of", var, 'is:', x, "\n")
  
  if (x > 0.05){
    print('Cannot reject normality assumption')
  }
  
  new.data <- data.frame(new.data, trans) 
} 


# rename transformed variables
library(tidyverse)
data.trans <- new.data %>%
  rename(year = pollution4.year,
         month = pollution4.month,
         pollution = pollution4.pollution,
         dew = trans,
         temp = trans.1,
         press = trans.2,
         wnd_spd = trans.3,
         snow = trans.4,
         rain = trans.5)

# ts object
pol <- data.trans %>% as_tibble()
pol %>% str()
pol_ts3 <- ts(pol)

# linear regression by month (transformed variables)
mod3 <- tslm(pollution ~ year + month + dew + temp + press + wnd_spd + snow + rain, data = pol_ts3)
summary(mod3)

# plot data vs fitted
autoplot(pol_ts3[,'pollution'], series="Data") +
  autolayer(fitted(mod3), series="Fitted") +
  xlab("Time") + ylab("Pollution") +
  ggtitle("Pollution") +
  guides(colour=guide_legend(title=" "))

# actual vs predicted values
cbind(Data = pol_ts3[,"pollution"],
      Fitted = fitted(mod3)) %>%
  as.data.frame() %>%
  ggplot(aes(x=Data, y=Fitted)) +
  geom_point() +
  ylab("Fitted (predicted values)") +
  xlab("Data (actual values)") +
  ggtitle("Pollution") +
  geom_abline(intercept=0, slope=1)
# the fitted values follow the data closely enough, as also shown by the previous plot

# evaluate model
checkresiduals(mod3)
# autocorrelation is detected

# view residuals
df <- as.data.frame(pol_ts3)
df[,"Residuals"]  <- as.numeric(residuals(mod2))
p1 <- ggplot(df, aes(x=dew, y=Residuals)) +
  geom_point()
p2 <- ggplot(df, aes(x=temp, y=Residuals)) +
  geom_point()
p3 <- ggplot(df, aes(x=press, y=Residuals)) +
  geom_point()
p4 <- ggplot(df, aes(x=rain, y=Residuals)) +
  geom_point()
p5 <- ggplot(df, aes(x=snow, y=Residuals)) +
  geom_point()
p6 <- ggplot(df, aes(x=month, y=Residuals)) +
  geom_point()
p7 <- ggplot(df, aes(x=year, y=Residuals)) +
  geom_point()
p4 <- ggplot(df, aes(x=wnd_spd, y=Residuals)) +
  geom_point()
gridExtra::grid.arrange(p1, p2, p3, p4, p5, p6, p7, nrow=2)
# now there is no obvious pattern

# residuals vs fitted plot
cbind(Fitted = fitted(mod3),
      Residuals=residuals(mod3)) %>%
  as.data.frame() %>%
  ggplot(aes(x=Fitted, y=Residuals)) + geom_point()
