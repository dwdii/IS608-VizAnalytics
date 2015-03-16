# 
#     Author: Daniel Dittenhafer 
# 
#     Created: Mar 12, 2015 
# 
# Description: Module 3 - Interactive Visualization
# 
library(shiny)
library(ggplot2)
library(googleVis)


# Load the data set from github repo
crudeRateFactor <- 100000 # I'm assuming the data from URL below is at same factor.
dataUrl <- "http://github.com/jlaurito/CUNY_IS608/blob/master/lecture3/data/cleaned-cdc-mortality-1999-2010.csv?raw=true"
mort <- read.csv(dataUrl, stringsAsFactors=FALSE)
mortData <- mort
#head(mortData)
#summary(mortData)

#head(subset(mortData, ICD.Chapter == "Certain infectious and parasitic diseases" & State == "Alabama", 
#     select=c(X, ICD.Chapter, State, Year, Crude.Rate)), 20)

natDeathByCause <- aggregate(cbind(Deaths, Population) ~ ICD.Chapter + Year, mortData, FUN=sum) 
natDeathByCause$NatAvg.Rate <- round(natDeathByCause$Deaths / natDeathByCause$Population * crudeRateFactor, 4)
#head(natDeathByCause, 40)


# Get a unique/distinct list of states from the data.
#states <- unique(mortData$State) # unused
# causeOfDeath <- unique(mortData$ICD.Chapter)

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output, session) {
  
  # Compute the forumla text in a reactive expression since it is 
  # shared by the output$caption and output$mpgPlot expressions
  selectedCOD <- reactive({
    paste("Cause Of Death: ", input$causeOfDeath)
  })
  
  # Return the formula text for printing as a caption
  output$caption <- renderText({
    print(input$causeOfDeath)
    selectedCOD()
  })
    
  subMort <- reactive({
    subset(mortData, ICD.Chapter == input$causeOfDeath & State == input$state, select=c(Year, Crude.Rate, ICD.Chapter))
  })
  
  # A simple data table (non-visualization)
  #output$mortTable <- renderDataTable(subMort())
  
  preppedData <- reactive({ 
    data <- subMort()
    # Sort by year (is this necessary?)
    data <- data[order(data$Year),]
    # Update column names so "State" is more obvious
    colnames(data) <- c("Year", "State.Rate", "ICD.Chapter")
    
    # Merge in the national data so we can include it as 
    # another series in the visualization
    data <- merge(data, natDeathByCause, by=c("Year", "ICD.Chapter"))
    data = dplyr::mutate(data, State_delta = lag(State.Rate) - State.Rate)
    data = dplyr::mutate(data, National_delta = lag(NatAvg.Rate) - NatAvg.Rate)
    data = dplyr::mutate(data, StateDeltaVsNational = (State_delta - National_delta))
    print(head(data))
    return (data)
  })
  
  # The googleVis bar chart rendition
  output$mortGvis <- renderGvis({gvisMerge(gvisLineChart(preppedData(), 
                                              xvar="Year", 
                                              yvar=c("StateDeltaVsNational"),
                                              options=list(width="800", 
                                                           height="400", 
                                                           chartArea="{top:'10'}",
                                                           vAxis="{textStyle: {fontSize: '18'}}",
                                                           legend="{ position: 'bottom' }")),
                                           gvisLineChart(preppedData(), 
                                              xvar="Year", 
                                              yvar=c("State.Rate", "NatAvg.Rate", "State_delta", "National_delta"),
                                              options=list(width="800", 
                                                           height="400", 
                                                           chartArea="{top:'7'}",
                                                           vAxis="{textStyle: {fontSize: '18'}}",
                                                           legend="{ position: 'bottom' }")), 
                                          tableOptions="width=\"850\""
                                          )}) 
})