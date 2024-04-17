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

# select most informative variables

# R2
library(leaps)
pol$month <- as.numeric(as.factor(pol$month))
pol$year <- as.numeric(as.factor(pol$year))
subs <- regsubsets(pollution ~ ., data = pol, nbest = 1)
numvar <- as.numeric(row.names(summary(subs)$which))
rsq <- summary(subs)$rsq
plot(numvar, rsq, pch = 19, xlab = 'Number of variables', ylab = 'R^2', main = 'R2')
plot(subs, scale = 'r2', col = 'purple', main = 'R2')

# adjusted R2
adjrsq <- summary(subs)$adjr2
plot(numvar, adjrsq, pch = 19, xlab = 'Number of variables', ylab = 'Adjuster R^2', main = 'Adjusted R2')
plot(subs, scale = 'adjr2', col = 'blue', main = 'Adjusted R2')

# AIC
model.initial <- lm(pollution ~ 1, data = pol)
model.full <- lm(pollution ~ ., data = pol)
library(MASS)
model.step <- stepAIC(model.initial, list(upper = model.full, lower = model.initial), direction = 'both')

# retain variables dew, temp, press and wnd_spd
mod3 <- tslm(pollution ~ dew + temp + press + wnd_spd, data = pol_ts3)
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

# residuals vs fitted plot
cbind(Fitted = fitted(mod3),
      Residuals=residuals(mod3)) %>%
  as.data.frame() %>%
  ggplot(aes(x=Fitted, y=Residuals)) + geom_point()


# forecasting on new data
new <- read.csv('/Users/alessia/Desktop/air.pollution/pollution_test_data1.csv')

# select variables to use in final model
new.set <- new[, c('dew', 'temp', 'press', 'wnd_spd')]

fin.data <- data.frame(new$pollution)
# transform variabels on new set
par(mfrow = c(1, 2))

for (var in colnames(new.set)){
  if (min(new.set[[var]]) <= 0){
    if (abs(min(pollution4[[var]])) > abs(min(new.set[[var]]))){
    constant <- abs(min(pollution4[[var]])) + 0.00000001
    pollution4[[var]] <- pollution4[[var]] + constant
    new.set[[var]] <- new.set[[var]] + constant
    } else {
      constant <- abs(min(new.set[[var]])) + 0.00000001
      pollution4[[var]] <- pollution4[[var]] + constant
      new.set[[var]] <- new.set[[var]] + constant
    }
  }
  bc <- boxCox(pollution4[[var]] ~ 1) # also gives the log-likelihood plot  
  
  lambdah <- bc$x[which.max(bc$y)]
  cat("lambda", var, 'is:', lambdah, "\n")
  
  # transform 
  trans <- bcPower(new.set[[var]], lambdah)
  qqnorm(trans, main = var)
  
  fin.data <- data.frame(fin.data, trans) 
} 

# rename transformed variables
data.final <- fin.data %>%
  rename(pollution = new.pollution,
         dew = trans,
         temp = trans.1,
         press = trans.2,
         wnd_spd = trans.3)

# regression on new predictors
par(mfrow = c(1,1))
mod3 <- lm(pollution ~ dew + temp + press + wnd_spd, data = pol)
confs <- predict(mod3, newdata = data.final, interval = 'confidence', alpha = 0.99) # confidence interval
preds <- predict(mod3, newdata = data.final, interval = 'prediction') # prediction interval
confs <- as.data.frame(confs)
preds <- as.data.frame(preds)
row_numbers <- seq_len(nrow(data.final))



# confidence intervals
plot_data <- data.frame(
  index = row_numbers,
  actual = data.final$pollution,
  fitted = confs$fit,
  upper = confs$upr,
  lower = confs$lwr
)

# plot confidence intervals
ggplot(plot_data, aes(x = index)) +
  geom_line(aes(y = actual), color = "blue", linetype = "solid") +
  geom_line(aes(y = fitted), color = "red", linetype = "solid") +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "green", alpha = 0.3) +
  labs(title = "Actual vs Predicted Pollution Levels with Confidence Intervals",
       x = "Index of Data",
       y = "Pollution Level") +
  scale_color_manual(values = c("blue", "red")) +
  theme_minimal()


# prediction intervals
plot_data <- data.frame(
  index = row_numbers,
  actual = data.final$pollution,
  fitted = preds$fit,
  upper = preds$upr,
  lower = preds$lwr
)

# plot prediction intervals
ggplot(plot_data, aes(x = index)) +
  geom_line(aes(y = actual), color = "blue", linetype = "solid") +
  geom_line(aes(y = fitted), color = "red", linetype = "solid") +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "green", alpha = 0.3) +
  labs(title = "Actual vs Predicted Pollution Levels with Prediction Intervals",
       x = "Index of Data",
       y = "Pollution Level") +
  scale_color_manual(values = c("blue", "red")) +
  theme_minimal()
