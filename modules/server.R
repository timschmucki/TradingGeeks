# --------------------------------------------------------------
# SERVER FUNCTION  ---------------------------------------------
# --------------------------------------------------------------

server <- function(input, output){
  
  output$ticker <- renderPlot({ # Server Function for Chart 1 which visualizes the stock with technical indicators
    
    # First, the stock data is retrieved from Yahoo based on the user input
    getSymbols(as.character(input$ticker), # input$ticker gets the symbol of the stock which was entered by the user (e.g. AAPL)
               src="yahoo", # stock data is retrieved from Yahoo
               from = input$dates[1], # gets first input date (start date)
               to = input$dates[2]) # gets second input date (end date)
    
    # Second, there is a distinction between charts with technical indicators and charts without technical indicators
    
    if (length(input$TA_check)!=0){ # this chart will appear when the user has checked a technical indicator (input$TA_check)!=0
      chartSeries(eval(parse(text=input$ticker)), 
                  TA=paste(input$TA_check, collapse=";"), 
                  name=paste("Chart to analyze the stock:", input$ticker), 
                  type=input$chart_type, 
                  up.col='black', dn.col='red', theme="white")
    }
    
    if (length(input$TA_check)==0){ # this chart will appear when the user has NOT selected a technical indicator
      chartSeries(eval(parse(text=input$ticker)), 
                  TA=NULL, 
                  name=paste("Chart to analyze the stock:", input$ticker), 
                  type=input$chart_type, 
                  up.col='black', dn.col='red', theme="white")
    }
    
  }) # closing brackets renderPlot output$ticker
  
  output$strategydescriptions <- renderText({ # server function to render text descriptions of the chosen strategies
    
    if (input$strategy == "strategy1"){ # displays description for strategy 1
      paste("<b>Description Strategy 1:</b> The Simple Filter Buy strategy creates a buy signal when the
             price of a security increases compared to yesterday's price. The buy signal is Pt / Pt-1 > 1 + x,
             where Pt is the closing price at time t and x > 0 is the threshold. For this strategy,
             a threshold of 0.1% has been chosen. The strategy is based on day-trading, meaning that the stock
             is bought at open and sold at close.")
    }
    
    else if (input$strategy == "strategy2"){ # displays description for strategy 2
      paste ("<b>Description Strategy 2:</b> The Simple Filter Buy & Sell strategy creates buy and sell signals
             when the price of a security increases or decreases compared to yesterday's price. The buy signal is
             Pt / Pt-1 > 1 + x and the sell signal is Pt / Pt-1 < 1 - x, where Pt is the closing price at time t and
             and x is the threshold. For this strategy, a threshold of 0.1% has been chosen.")
    }
    
    
  }) # closing brackets render Text
  
  output$strategyplots <- renderPlot({ # Server function for chart 2 which visualizes the performance of the trading strategy
    
    # First, the stock data is retrieved from Yahoo based on the user input and stored in the variable data
    data <- getSymbols(input$ticker, src = "yahoo", 
                       from = input$dates[1],
                       to = input$dates[2],
                       auto.assign = FALSE)
    
    # Define first strategy   
    if (input$strategy == "strategy1"){
      
      #####################################
      ### Strategy 1: Simple Filter Buy ###
      #####################################
      # EXPLANATION:
      # a simple filter rule suggests buying when the 
      # price increases more than a certain threshold compared to yesterday's price
      # Buy Signal if: (Pt / Pt-1 > 1 + x), 
      # where Pt is the closing price at time t, 
      # and x > 0 is the threshold
      
      price <- Cl(data) # close price
      r <- price/Lag(price) - 1 # % price change
      delta <- 0.001 # threshold (0.1%)
      signal <- c(0) # first date has no signal
      
      # Loop over all trading days (except the first)
      for (i in 2: length(price)){
        if (r[i] > delta){
          signal[i]<- 1 # gives signal if r > delta
        } else
          signal[i]<- 0 # no signal if r < delta
      }
      
      # Assign time to action variable using reclass;
      signal <- reclass(signal, price)
      
      # Each point is now attached with time
      tail(signal, n=3)
      
      # Performance Summary
      trade1 <- Lag(signal,1) # trade based on yesterday signal
      ret1 <- dailyReturn(data)*trade1 # we assume day trading: buy at open, sell at close
      charts.PerformanceSummary(ret1, main="Strategy 1: Simple Filter Buy", colorset = redmono)
      
    }
    
    # Define second strategy 
    if (input$strategy == "strategy2"){
      
      ############################################
      ### Strategy 2: Simple Filter Buy & Sell ###
      ############################################
      # EXPLANATION:
      # Buy Signal: (Pt / Pt-1 > 1 + x) &
      # Sell Signal: (Pt / Pt-1 < 1 - x),
      # where Pt is the closing price at time t, 
      # and x > 0 is the threshold
      
      price <- Cl(data) # close price
      r <- price/Lag(price) - 1 # % price change
      delta <- 0.001 # threshold (0.1%)
      signal <-c(NA) # first signal is NA
      
      # Loop over all trading days (except the first)
      for (i in 2: length(Cl(data))){ 
        if (r[i] > delta){
          signal[i]<- 1
        } else if (r[i]< -delta){
          signal[i]<- -1
        } else
          signal[i]<- 0
      }
      
      # Assign time to action variable using reclass;
      signal<-reclass(signal,Cl(data))
      
      # Performance Summary
      trade2 <- Lag(signal)
      ret2 <- dailyReturn(data)*trade2
      charts.PerformanceSummary(ret2, main="Strategy 2: Simple Filter Buy & Sell", colorset = redmono)
      
    }
   
  }) # closing brackets renderPlot output$strategyplots
  
} # closing bracket server function
