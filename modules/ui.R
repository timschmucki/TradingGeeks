# --------------------------------------------------------------
# USER INTERFACE SHINY APP -------------------------------------
# --------------------------------------------------------------

# if an error occurs, show the same error message every time
options(shiny.sanitize.errors = TRUE)

ui <- fluidPage(
  
  # Enter the title of the program
  titlePanel("Trading Strategy Backtesting"),
  
  ##### Define the layout of the shiny app ####
  sidebarLayout(position = "left",
                
                ### In the sidebar panel, inputs can be specified by the user ###
                sidebarPanel(
                  
                  ## General Information about the program
                  h3(strong("Instructions")),
                  helpText("This program allows you to analyze a financial security with various technical indicators
               and backtest different trading strategies for a specified date range,
               using data from Yahoo! Finance. Please enter the required inputs below."),
                  br(), # ads a break to increase clarity
                  
                  ## Input field to define the stock
                  h4(strong("1) Choose a Financial Security")),
                  helpText("Please enter a ticker.
               For instance, use 'AAPL' or 'MSFT' for Apple or Microsoft, respectively.
               For further examples, please visit 'www.finance.yahoo.com'."),
                  textInput(inputId = "ticker",
                            label = "Ticker (in capital letters):",
                            value = "AAPL"),
                  br(), # ads a break to increase clarity
                  
                  ## Input fields to define date range
                  h4(strong("2) Specify Date Range")),
                  dateRangeInput(inputId = "dates", 
                                 label= "Date range:",
                                 start = "2018-01-01",
                                 end =   as.character(Sys.Date())), # the most current date will be the default value
                  br(), # ads a break to increase clarity
                  
                  ## Dropdown to select chart type
                  h4(strong("3) Select Chart Type")),
                  selectInput(inputId = "chart_type",
                              label = "Chart Type:",
                              choices=list("line", "candlesticks", "matchsticks", "bars")),
                  br(), # ads a break to increase clarity
                  
                  ## Checkboxes for technical indicators
                  h4(strong("4) Analyze your Security")),
                  checkboxGroupInput(inputId = "TA_check",
                                     label=h5("Select technical indicators to analyze the security:"),
                                     choices=list(
                                       "Exponential Moving Average"="addEMA()",
                                       "Simple Moving Average"="addSMA()",
                                       "Moving Average Convergence Divergence"="addMACD()",
                                       "Bollinger Bands"="addBBands()",
                                       "Relative Strength Index"="addRSI()",
                                       "Stochastic Momentum Indicator"="addSMI()")),
                  br(), # ads a break to increase clarity
                  
                  ## Dropdown to select trading strategy
                  h4(strong("5) Backtest a Trading Strategy")),
                  selectInput(inputId = "strategy",
                              label = h5("Select your strategy:"),
                              choices = list(
                                "Strategy 1: Simple Filter Buy" = "strategy1",
                                "Strategy 2: Simple Filter Buy & Sell" = "strategy2",
                                "Strategy 3: Simple Filter Buy & RSI Sell" = "strategy3",
                                "Strategy 4: RSI Buy & Sell" = "strategy4",
                                "Strategy 5: EMA Buy & RSI Sell" = "strategy5"
                              )),
                  
                  submitButton("Submit"),
                  br(), # ads a break to increase clarity
                  
                  ## Inform the user about potential causes of errors
                  helpText(strong("Note:"), "If an error occurs, please verify that the ticker you've entered is valid
               and that the chosen trading strategy is applicable for the specified period."),
                  
                ), # sidebar panel closing bracket
                
                ### In the main panel, the charts will be displayed ###
                mainPanel(
                  
                  plotOutput("ticker"), # Chart 1: visualizes the performance of the stock including the selected technical indicators
                  br(), # ads a break to increase clarity
                  htmlOutput("strategydescriptions"), # Describes the different strategies
                  plotOutput("strategyplots") # Chart 2: visualizes the cumulative return, the daily return and drawdown of the trading strategy
                  
                  
                ) # main panel closing bracket
  ) # sidebar layout closing bracket
) # fluid page closing bracket