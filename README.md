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
- A visualization part, where the time-series is explored through various plots
![trend_plot](https://github.com/alessiapetracin/pollution/assets/126952273/e5bdb09f-aec7-4df2-866c-e7e0ec8d482b)

![correlation_plot_pearson](https://github.com/alessiapetracin/pollution/assets/126952273/0fee1103-469b-414d-8dfa-fb26592a5126)

![seasonal_plot](https://github.com/alessiapetracin/pollution/assets/126952273/fe6b5f0d-4b46-4426-bd5f-a0f7f69fe4bc)

![autocorrelation_plot](https://github.com/alessiapetracin/pollution/assets/126952273/a9b5a7ef-f02c-4728-b7c9-d0e2d29177fa)

- A simple forecasting part, in which, given the prior pollution level, we forecast the pollution level according to different forecasting methods (average, naive, seasonal naive, drift and Holt Winters forecasting

![forecasting](https://github.com/alessiapetracin/pollution/assets/126952273/1a600a37-65ac-4254-9402-2d93fa7e2d9a)

