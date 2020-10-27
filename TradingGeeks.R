### TradingGeeks ###
### Software Engineering for Economists###

# --------------------------------------------------------------
# PRELIMINARIES ------------------------------------------------
# --------------------------------------------------------------

#get relevant libraries
library(shiny) # to build interactive web apps straight from R
library(quantmod) # for quantitative financial modelling
library(PerformanceAnalytics) # economic tool for performance analysis 

# --------------------------------------------------------------
# USER INTERFACE SHINY APP -------------------------------------
# --------------------------------------------------------------

ui <- fluidPage(
  
  # Enter the title of the program
  titlePanel("Trading Strategy Backtesting"),
  
  ##### Define the layout of the shiny app ####
  sidebarLayout(position = "left",
                
                ### In the sidebar panel, inputs can be specified by the user ###
                sidebarPanel(
                  
                  ## General Information about the program
                  h3(strong("Instructions")),
                  helpText("Placeholder for an adequate program description"),
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
                  
                  submitButton("Submit"),
                  br(), # ads a break to increase clarity
                  
                  
                ), # sidebar panel closing bracket
                
                ### In the main panel, the charts will be displayed ###
                mainPanel(
                  
                  plotOutput("ticker"), # visualizes the performance of the stock
                  br(), # ads a break to increase clarity
                  
                ) # main panel closing bracket
  ) # sidebar layout closing bracket
) # fluid page closing bracket

# --------------------------------------------------------------
# SERVER FUNCTION SHINY APP ------------------------------------
# --------------------------------------------------------------

server <- function(input, output){
  
  output$ticker <- renderPlot({ # Server Function which visualizes the stock price development
    
    # First, the stock data is retrieved from Yahoo based on the user input
    getSymbols(as.character(input$ticker), # input$ticker gets the symbol of the stock which was entered by the user (e.g. AAPL)
               src="yahoo", # stock data is retrieved from Yahoo
               from = input$dates[1], # gets first input date (start date)
               to = input$dates[2]) # gets second input date (end date)
    
    chartSeries(eval(parse(text=input$ticker)), 
                name=paste("Chart to analyze the stock:", input$ticker), 
                type=input$chart_type, 
                up.col='black', dn.col='red', theme="white")
    
  }) # closing brackets renderPlot output$ticker
  
  
} # closing bracket server function

# --------------------------------------------------------------
# COMBINATION OF UI & SERVER -----------------------------------
# --------------------------------------------------------------

shinyApp(ui = ui, server = server)