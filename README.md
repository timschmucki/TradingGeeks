# TradingGeeks
The goal of this repository is to develop a program which can backtest trading strategies.

Test 1: This is a test to check whether the intersection between RStudio and GitHub works.
Test 2: This is another test to check whether the intersection between RStudio and GitHub works.

### App is deployed under:
- [Trading Strategy Backtesting App](https://jan-scheidegger.shinyapps.io/TradingStrategyBacktesting/)

### Docker instruction:
Install Docker and enter the following into the command line:

- Pull Request
docker pull jan4j/trading_strategy_backtesting:latest

- Run
docker run --rm   -p 28787:8787   -e DISABLE_AUTH=true   jan4j/trading_strategy_backtesting:latest

- Start Local Host
open browser and url: http://localhost:28787/
