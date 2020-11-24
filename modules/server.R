# --------------------------------------------------------------
# SERVER FUNCTION SHINY APP ------------------------------------
# --------------------------------------------------------------

server <- function(input, output){
  
  #load the python environment and the script code
  # py_install("openpyxl")
  # py_install("tweepy")
  # # install r_anaconda from github
  # remotes::install_github("hafen/rminiconda") # install.packages("remotes") # if not installed
  
  # reticulate::use_virtualenv('python35_env',required = TRUE) #define python version
  reticulate::source_python('Scraper_v2.py')
  
  
  # First, the stock data is retrieved from Yahoo based on the user input and stored in reactive
  yahoo_data <- reactive({
    
    try(#error handling
      getSymbols(as.character(input$ticker), # input$ticker gets the symbol of the stock which was entered by the user (e.g. AAPL)
                 src="yahoo", # stock data is retrieved from Yahoo
                 from = input$dates[1], # gets first input date (start date)
                 to = input$dates[2], # gets second input date (end date)
                 auto.assign = FALSE)
      , silent = TRUE)
  })
  
  
  # ObserveEvent is a function which observes the button submit and triggers the code below
  observeEvent(input$submit ,{
    
    
    output$ticker <- renderPlot({ # Server Function for Chart 1 which visualizes the stock with technical indicators
      
      #error = require data in the yahoo_data reactive  meaning it must be an xts object otherwise print error message
      validate(
        need(is.xts(yahoo_data()), "Ticker not found !!! Please select a valid ticker from Yahoo")
      )
      
      # There is a distinction between charts with technical indicators and charts without technical indicators
      if (length(input$TA_check)!=0){ # this chart will appear when the user has checked a technical indicator (input$TA_check)!=0
        chartSeries(yahoo_data(), 
                    TA=paste(input$TA_check, collapse=";"), 
                    name=paste("Chart to analyze the stock:", input$ticker), 
                    type=input$chart_type, 
                    up.col='black', dn.col='red', theme="white")
      }
      
      if (length(input$TA_check)==0){ # this chart will appear when the user has NOT selected a technical indicator
        chartSeries(yahoo_data(), 
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
      
      else if (input$strategy == "strategy3"){ # displays description for strategy 3
        paste ("<b>Description Strategy 3:</b> The Simple Filter Buy & RSI Sell strategy creates a buy signal
               when the price of a security increases compared to yesterday's price. The buy signal is Pt / Pt-1 > 1 + x,
               where Pt is the closing price at time t and x > 0 is the threshold. For this strategy,
               a threshold of 0.1% has been chosen. The sell signal arises when RSI > 70.")
      }
      
      else if (input$strategy == "strategy4"){ # displays description for strategy 4
        paste ("<b>Description Strategy 4:</b> The RSI Buy & Sell strategy creates a buy signal if RSI < 30 and
               a sell signal if RSI > 70. Note that the programme will display an error message if the RSI of the 
               selected stock in the specified date range was never below 30 (more likely for shorter periods).")
      }
      
      else if (input$strategy == "strategy5"){ # displays description for strategy 5
        paste ("<b>Description Strategy 5:</b> The EMA Buy & RSI Sell strategy creates a buy signal when the short-term
               EMA (10 days) crosses above the long-term EMA (50 days). The sell signal is generated when RSI > 70.
               Note that the programme will display an error message if the short-term EMA never crosses the long-term EMA
               of the selected stock in the specified date range (more likely for shorter periods).")
      }
      
    }) # closing brackets render Text
    
    output$strategyplots <- renderPlot({ # Server function for chart 2 which visualizes the performance of the trading strategy
      
      #error = require data in the yahoo_data reactive  meaning it must be an xts object otherwise print error message
      validate(
        need(is.xts(yahoo_data()), "")
      )
      
      
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
        
        price <- Cl(yahoo_data()) # close price
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
        ret1 <- dailyReturn(yahoo_data())*trade1 # we assume day trading: buy at open, sell at close
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
        
        price <- Cl(yahoo_data()) # close price
        r <- price/Lag(price) - 1 # % price change
        delta <- 0.001 # threshold (0.1%)
        signal <-c(NA) # first signal is NA
        
        # Loop over all trading days (except the first)
        for (i in 2: length(Cl(yahoo_data()))){ 
          if (r[i] > delta){
            signal[i]<- 1
          } else if (r[i]< -delta){
            signal[i]<- -1
          } else
            signal[i]<- 0
        }
        
        # Assign time to action variable using reclass;
        signal<-reclass(signal,Cl(yahoo_data()))
        
        # Performance Summary
        trade2 <- Lag(signal)
        ret2 <- dailyReturn(yahoo_data())*trade2
        charts.PerformanceSummary(ret2, main="Strategy 2: Simple Filter Buy & Sell", colorset = redmono)
        
      }
      
      # Define third strategy 
      if (input$strategy == "strategy3"){
        
        ################################################
        ### Strategy 3: Simple Filter Buy & RSI Sell ###
        ################################################
        # EXPLANATION:
        # Buy Signal: (Pt / Pt-1 > 1 + x) &
        # where Pt is the closing price at time t, 
        # and x > 0 is the threshold
        # Sell Signal: RSI > 70
        
        n <- 14 # period for RSI
        delta <-0.003 # threshold (0.3%)
        price <- Cl(yahoo_data()) # closing prices         
        r <- price/Lag(price) - 1 # % price change
        rsi <- RSI(price, n) # n-period RSI
        signal <-c()    # first signal is NA
        signal[1:n] <- 0
        
        
        # Generate Trading Signal
        for (i in (n+1):length(price)){
          if (r[i] > delta){
            signal[i]<- 1
          } else if (rsi[i] > 70){
            signal[i]<- -1
          } else
            signal[i]<- 0
        }
        
        # Assign time to action variable using reclass;
        signal<-reclass(signal,price)
        
        # Apply Trading Rule
        trade3 <- Lag(signal)
        ret3 <- dailyReturn(yahoo_data())*trade3 
        
        charts.PerformanceSummary(
          ret3, main="Strategy 3: Simple Filter Buy & RSI Sell", colorset = redmono)
        
      }
      
      # Strategy 4 
      if (input$strategy == "strategy4"){
        
        ####################################
        ### Strategy 4: RSI Buy & Sell #####
        ####################################
        # EXPLANATION:
        # Buy Signal: RSI < 30
        # Sell Signal: RSI > 70
        
        qty <- 300 #buy 300 units when buy signal is triggered
        day <- 14 # sell signal if 14-day RSI > 70
        
        signal <- c()   #trade signal
        signal[1:(day+1)] <- 0 
        
        price <- Cl(yahoo_data())
        
        stock <- c()  #stock holding
        stock[1:(day+1)] <-0
        
        cash <-c()
        cash[1:(day+1)] <- 10000 #initial wealth 10'000
        
        # Trading signal is based on simple RSI:
        rsi <- RSI(price, day)  #rsi is the lag of RSI
        for (i in (day+1): length(price)){
          if (rsi[i] < 30){  #buy if rsi < 30
            signal[i] <- 1
          } else if (rsi[i] < 70){ #no change if 30 <= RSI <= 70
            signal[i] <- 0
          } else {         #sell  if rsi > 70
            signal[i] <- -1
          }
        }
        signal<-reclass(signal,price)
        
        # Assume buying at closing price. We keep track of how cash and stock changes:
        trade <- Lag(signal)    #rsi is the lag of RSI
        for (i in (day+1): length(price)){
          if (trade[i]>=0){
            stock[i] <- stock[i-1] + qty*trade[i]
            cash[i] <- cash[i-1] - 
              qty*trade[i]*price[i]
          } else{
            stock[i] <- 0
            cash[i] <- cash[i-1] + 
              stock[i-1]*price[i]
          }
        }
        stock<-reclass(stock,price)
        cash<-reclass(cash,price)
        
        # To evaluate performance, we calculate equity using cash and stock holdings:
        equity <-c()
        equity[1:(day+1)] <- 10000 
        
        return<-c()                  
        return[1:(day+1)] <- 0
        
        for (i in (day+1): length(price)){
          equity[i] <- stock[i] * price[i] + cash[i]
          return[i] <- equity[i]/equity[i-1]-1
        }
        equity <-reclass(equity,price)
        ret4 <-reclass(return,price)
        
        # Plotting the strategy
        charts.PerformanceSummary(ret4, 
                                  main = "Strategy 4: RSI Buy & Sell", colorset = redmono)
        
      }
      
      # Strategy 5 
      if (input$strategy == "strategy5"){
        
        ######################################
        ### Strategy 5: EMA Buy & RSI Sell ###
        ######################################
        # EXPLANATION:
        # Buy signal based on EMA
        # Sell signal based on RSI
        
        n <- 14 # period for RSI
        delta <- 0.005
        price <- Cl(yahoo_data())
        S <- 10 # period for short term EMA
        L <- 50 # period for long term EMA
        r <- EMA(price, S) / EMA(price, L) - 1  
        rsi <- RSI(price, n) 
        signal <-c()    # first signal is NA
        signal[1:L] <-0
        
        
        # Generate Trading Signal
        for (i in (L+1):length(price)){
          if (r[i] > delta){ # buy if short-term EMA crosses above long-term EMA
            signal[i]<- 1
          } else if (rsi[i] > 70){ # sell if RSI > 70
            signal[i]<- -1
          } else
            signal[i]<- 0
        }
        signal <- reclass(signal,price)
        
        ## Apply Trading Rule
        trade5 <- Lag(signal)
        ret5 <- dailyReturn(yahoo_data())*trade5 
        
        charts.PerformanceSummary(
          ret5, main="Strategy 5: EMA Buy & RSI Sell", colorset = redmono)
        
      } # closing bracket strategy 5
      
      # Strategy 6 Twitter indicator strategy taken from python
      if (input$strategy == "strategy6"){
        
        
        print('load data from database which is build from python scipt and construct plot')
        
        
      }
      
    }) # closing brackets renderPlot output$strategyplots
  
  }, ignoreInit=TRUE) #closing observeEvent of submitButton
  
  
  
  #observe twitter button and trigger python script to execute
  observeEvent(input$twitter ,{
    showModal(modalDialog('execute the python script to update database', footer=NULL))
    
    start_date <- format(input$dates[1], '%d-%m-%Y')
    end_date <- format(input$dates[2], '%d-%m-%Y')
    
    show_modal_spinner(
      spin = "semipolar",
      color = "firebrick",
      text = "Please wait! Twitter data will be fetched..."
    )
    
    update_db_python(start_date, end_date)
    print('execute the python script to update database')
    
    # Sys.sleep(5)
    
    #Finish the function
    removeModal()
    
  })
  
  
  
} # closing bracket server function