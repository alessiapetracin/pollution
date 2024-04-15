# Air pollution

### Dataset ###

The dataset employed reports on the weather and the level of pollution each hour for five years (2010-2014) at the US embassy in Beijing, China.

The data includes the date-time, the pollution called PM2.5 concentration, and the weather information including dew point, temperature, pressure, wind direction, wind speed and the cumulative number of hours of snow and rain. The complete feature list in the raw data is as follows:

- date (yyyy-mm-dd hh-mm-ss)
- pollution: PM2.5 concentration
- dew: Dew Point
- temp: Temperature
- press: Pressure
- wnd_dir: Combined wind direction
- wnd_spd: Cumulated wind speed
- snow: Cumulated hours of snow
- rain: Cumulated hours of rain

 ---

 ### The project ###
 
The project includes:
- A visualization part, where the time-series is explored through various plots for trends, seasonality and cicles. Seasonality is found to be present, with pollution levels increasing during winter months and between 9 pm and 2 am. A trend plot shows that air pollution tends to increase when dew increases, whereas it tends to decrease when the wind speed decreases. A correlation plot using the Spearman coefficient confirms the relation; furthermore, looking at trend plots, it is possible to observe that periods in which it snows more (winter months) are associated to higher air pollution levels.
 
- A forecasting part, in which, given the prior pollution level, we forecast the pollution level according to different forecasting methods (average, naive, seasonal naive, drift, Holt Winters, STL, cubic spline).

![forecast](https://github.com/alessiapetracin/pollution/assets/126952273/f430127a-7df0-4143-9c6d-576b506ed6f0)


- Forecasting through linear regression

