# --------------------------------------------------------------
# SERVER FUNCTION  ---------------------------------------------
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
