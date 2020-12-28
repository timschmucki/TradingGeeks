# TradingGeeks
The goal of this repository is to develop a program which can backtest trading strategies.

Test 1: This is a test to check whether the intersection between RStudio and GitHub works.
Test 2: This is another test to check whether the intersection between RStudio and GitHub works.

![Overview Repository Structure](data/overview_repository.png)



### App is deployed under:
- [Trading Strategy Backtesting App](https://jan-scheidegger.shinyapps.io/TradingStrategyBacktesting/)

### Docker instruction:
Install Docker and enter the following into the command line:

- Pull Request\
docker pull jan4j/trading_strategy_backtesting:latest

- Run\
docker run --rm   -p 28787:8787   -e DISABLE_AUTH=true   jan4j/trading_strategy_backtesting:latest

- Start Local Host\
open browser and url: http://localhost:28787/

### Objective of the App

Our application has 3 main objectives. First, the trading program assists a user in analysing a stock by means of different chart types and technical indicators for a specified period. Second, the application enables the back-testing of 6 simple trading strategies and depicts their respective performances. Lastly, the ultimate purpose of the app is to facilitate the analysis of stocks and trading strategies for a broad audience. A well-arranged user interface is the foundation to achieve that, and it makes it easy to experiment with different financial securities, technical indicators, and trading strategies.

### Main Functionalities

The user interface (UI) allows the user to provide inputs to the program. The investor can (1) select an underlying, (2) define the date range, (3) select a preferred chart type, and (4) get a more detailed overview of the stock's performance with one of the predefined technical indicators. Next, (5) the user can specify one of six trading strategies for the back-testing. After clicking on the "Submit" button, the Shiny app displays a non-technical report of the results on the right side. 

The output comprises two charts. On the top, the historical performance of the underlying with the selected technical indicators is visualized. On the bottom, the cumulative return of the chosen trading strategy is depicted, including daily returns and drawdowns. Between the two charts, a short description of the chosen trading strategy is displayed.