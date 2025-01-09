# Portfolio Data Analysis and Forecasting

## Overview
This code is designed to fetch, analyze, and forecast data for a portfolio of financial assets. It uses historical price data for various assets (e.g., cryptocurrencies, stocks, indices, and futures) to calculate returns, construct a portfolio, and generate future price forecasts using ARIMA models. 

### Features:
1. Fetches historical data for a specified time range using the `tidyquant` package.
2. Calculates daily returns for each asset.
3. Constructs an equal-weighted portfolio and computes its daily returns.
4. Analyzes time-series stationarity and applies ARIMA modeling for forecasting future prices.

---

## Prerequisites
The code requires the following R packages:
- `quantmod`
- `tidyquant`
- `crypto2`
- `dplyr`
- `tidyr`
- `tseries`
- `forecast`

Install them using the following commands if not already installed:
```r
install.packages("quantmod")
install.packages("tidyquant")
install.packages("crypto2")
install.packages("tseries")
install.packages("forecast")
```

---

## Data Fetching
The script fetches historical price data for the following assets:
- Cryptocurrencies: Binance Coin (BNB-USD), Monero (XMR-USD), and Sandbox (SAND-USD).
- Stocks: NVIDIA (NVDA) and Taiwan Semiconductor Manufacturing Company (TSM).
- Indices: FTSE MIB (MIB) and EuroStoxx 50 (STOXX50E).
- Futures: US Treasury Bond Futures (ZN=F) and Gold Futures (GC=F).

The `tq_get()` function from the `tidyquant` package retrieves the data, which is then processed to retain only the closing prices.

---

## Portfolio Construction
1. **Data Cleaning:** Ensures each dataset has a consistent date format and removes missing values using last observation carried forward (LOCF).
2. **Daily Returns:** Calculates daily returns for each asset as:
   ```
   (Current Price / Previous Price) - 1
   ```
3. **Portfolio Returns:** Computes equal-weighted portfolio returns by averaging the daily returns of all assets.

---

## Time-Series Analysis and Forecasting
The script employs ARIMA models to forecast future prices for each asset:
1. **Stationarity Testing:**
   - Augmented Dickey-Fuller (ADF) test is applied to check if the series is stationary.
   - If non-stationary, log transformation and differencing are applied.
2. **ARIMA Model:** Uses `auto.arima()` to fit an optimal ARIMA model for the log-transformed prices.
3. **Forecasting:** Generates a 30-day price forecast and converts the log-scale predictions back to the original scale using the exponential function.

### Example Function:
```r
analyze_and_forecast <- function(ticker, start_date) {
  getSymbols(ticker, src = "yahoo", from = start_date, to = Sys.Date())
  closing_prices <- Cl(get(ticker))
  closing_prices <- na.omit(closing_prices)
  
  adf_test <- adf.test(closing_prices, alternative = "stationary")
  
  log_prices <- log(closing_prices)
  diff_log_prices <- diff(log_prices)
  diff_log_prices <- na.omit(diff_log_prices)
  
  model <- auto.arima(log_prices, seasonal = FALSE)
  forecasted_values <- forecast(model, h = 30)
  forecasted_prices <- exp(forecasted_values$mean)
  
  return(forecasted_prices)
}
```

---

## Usage
1. Define the start date for fetching historical data:
   ```r
   start_date <- "2020-01-01"
   ```
2. Run the portfolio construction and forecasting code. The function `analyze_and_forecast()` can be called for each asset individually.
3. Example usage:
   ```r
   bnb_forecast <- analyze_and_forecast("BNB-USD", start_date)
   nvda_forecast <- analyze_and_forecast("NVDA", start_date)
   ```

---

## Output
1. **Portfolio Dataset:**
   - A consolidated data frame containing historical prices, returns, and portfolio-level metrics.
2. **Plots:**
   - Historical price trends.
   - Differenced log price trends.
   - Forecasted price trends.
3. **Forecasted Values:**
   - A 30-day forward forecast for each asset, presented in its original price scale.

---

## Notes
- Ensure the `crypto2` package supports all required cryptocurrency tickers. If not, consider alternative data sources.
- Handle any API rate limits or connectivity issues during data retrieval.

---


## References
- [tidyquant documentation](https://business-science.github.io/tidyquant/)
- [ARIMA modeling with forecast](https://cran.r-project.org/web/packages/forecast/index.html)
- [Quantmod package](https://www.rdocumentation.org/packages/quantmod)
