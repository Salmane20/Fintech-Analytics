# Install required packages
install.packages("quantmod")
install.packages("tidyquant")
install.packages("crypto2")



# Load required libraries
library(quantmod)
library(tidyquant)
library(crypto2)
library(dplyr)
library(tidyr)

# Fetch data for each asset
bnb_data <- tq_get("BNB-USD", from = "2020-01-01", to = "2025-01-06")
monero_data <- tq_get("XMR-USD", from = "2020-01-01", to = "2025-01-06")
sandbox_data <- tq_get("SAND-USD", from = "2020-01-01", to = "2025-01-06")
nvda_data <- tq_get("NVDA", from = "2020-01-01", to = "2025-01-06")
tsmc_data <- tq_get("TSM", from = "2020-01-01", to = "2025-01-06")
jpm_data <- tq_get("JPM", from = "2020-01-01", to = "2025-01-06")
mib_data <- tq_get("^FTSE", from = "2020-01-01", to = "2025-01-06")  # Updated asset
eurostoxx_data <- tq_get("^STOXX50E", from = "2020-01-01", to = "2025-01-06")
yield_futures_data <- tq_get("ZN=F", from = "2020-01-01", to = "2025-01-06")
gold_futures_data <- tq_get("GC=F", from = "2020-01-01", to = "2025-01-06")

# Ensure that each dataset has a Date column
bnb_data <- bnb_data %>% select(Date = date, BNB = close)
monero_data <- monero_data %>% select(Date = date, Monero = close)
sandbox_data <- sandbox_data %>% select(Date = date, Sandbox = close)
nvda_data <- nvda_data %>% select(Date = date, NVDA = close)
tsmc_data <- tsmc_data %>% select(Date = date, TSMC = close)
jpm_data <- jpm_data %>% select(Date = date, JPM = close)
mib_data <- mib_data %>% select(Date = date, MIB = close)  # Updated asset
eurostoxx_data <- eurostoxx_data %>% select(Date = date, EuroStoxx = close)
yield_futures_data <- yield_futures_data %>% select(Date = date, Yield_Futures = close)
gold_futures_data <- gold_futures_data %>% select(Date = date, Gold_Futures = close)

# Merge datasets by Date
buy_portfolio <- bnb_data %>%
  full_join(monero_data, by = "Date") %>%
  full_join(sandbox_data, by = "Date") %>%
  full_join(nvda_data, by = "Date") %>%
  full_join(tsmc_data, by = "Date") %>%
  full_join(jpm_data, by = "Date") %>%
  full_join(mib_data, by = "Date") %>%
  full_join(eurostoxx_data, by = "Date") %>%
  full_join(yield_futures_data, by = "Date") %>%
  full_join(gold_futures_data, by = "Date")

# Fill missing values with the last observation carried forward
buy_portfolio <- buy_portfolio %>%
  fill(everything(), .direction = "downup")

# Preview the buy_portfolio
head(buy_portfolio)

# Calculate daily returns for the buy_portfolio
buy_portfolio <- buy_portfolio %>%
  mutate(
    BNB_return = (BNB / lag(BNB)) - 1,
    Monero_return = (Monero / lag(Monero)) - 1,
    Sandbox_return = (Sandbox / lag(Sandbox)) - 1,
    NVDA_return = (NVDA / lag(NVDA)) - 1,
    TSMC_return = (TSMC / lag(TSMC)) - 1,
    JPM_return = (JPM / lag(JPM)) - 1,
    MIB_return = (MIB / lag(MIB)) - 1,  # Updated asset
    EuroStoxx_return = (EuroStoxx / lag(EuroStoxx)) - 1,
    Yield_Futures_return = (Yield_Futures / lag(Yield_Futures)) - 1,
    Gold_Futures_return = (Gold_Futures / lag(Gold_Futures)) - 1
  )

# Calculate buy_portfolio returns (equal-weighted)
buy_portfolio <- buy_portfolio %>%
  mutate(
    Portfolio_return = rowMeans(select(buy_portfolio, ends_with("_return")), na.rm = TRUE)
  )

# View the buy_portfolio
head(buy_portfolio)


 ############################## ARIMA FORCAST ###################################

# Install and load the required packages
install.packages("quantmod")
install.packages("tidyquant")
install.packages("crypto2")
install.packages("tseries")
install.packages("forecast")

library(quantmod)
library(tidyquant)
library(crypto2)
library(tseries)
library(forecast)

# Function to perform the analysis and forecasting
analyze_and_forecast <- function(ticker, start_date) {
  # Fetch data
  getSymbols(ticker, src = "yahoo", from = start_date, to = Sys.Date())
  
  # Extract closing prices and handle missing values
  closing_prices <- Cl(get(ticker))
  closing_prices <- na.omit(closing_prices)
  
  # Plot the cleaned prices
  plot(closing_prices, main = paste(ticker, "Prices (Cleaned)"), ylab = "Price (USD)", xlab = "Date")
  
  # Check for stationarity using Augmented Dickey-Fuller Test
  adf_test <- adf.test(closing_prices, alternative = "stationary")
  print(adf_test)
  
  # If non-stationary, apply log transformation and differencing
  log_prices <- log(closing_prices)  # Log transformation to stabilize variance
  diff_log_prices <- diff(log_prices)  # Differencing to stabilize the mean
  diff_log_prices <- na.omit(diff_log_prices)  # Remove NAs introduced by differencing
  
  # Plot the differenced log prices
  plot(diff_log_prices, main = paste("Differenced Log", ticker, "Prices"), ylab = "Log Difference", xlab = "Date")
  
  # Perform ADF test again on the differenced series
  adf_test_diff <- adf.test(diff_log_prices, alternative = "stationary")
  print(adf_test_diff)
  
  # Fit the ARIMA model using auto.arima()
  model <- auto.arima(log_prices, seasonal = FALSE)
  print(model)
  
  # Forecast the next 30 days
  forecasted_values <- forecast(model, h = 30)
  plot(forecasted_values, main = paste(ticker, "Price Forecast"), xlab = "Date", ylab = "Log Price")
  
  # Convert the forecasted values back to the original scale (from log)
  forecasted_prices <- exp(forecasted_values$mean)
  print(forecasted_prices)
  
  return(forecasted_prices)
}

# Define the start date
start_date <- "2020-01-01"

# Analyze and forecast for each of the specified assets
bnb_forecast <- analyze_and_forecast("BNB-USD", start_date)
monero_forecast <- analyze_and_forecast("XMR-USD", start_date)
sandbox_forecast <- analyze_and_forecast("SAND-USD", start_date)
nvda_forecast <- analyze_and_forecast("NVDA", start_date)
tsmc_forecast <- analyze_and_forecast("TSM", start_date)
