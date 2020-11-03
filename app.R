### TradingGeeks ###
### Software Engineering for Economists###

# --------------------------------------------------------------
# Source the R Packages, UI & SERVER ---------------------------
# --------------------------------------------------------------

source('modules/packages.R')
source('modules/ui.R')
source('modules/server.R')

# run the app
shinyApp(ui = ui, server = server)