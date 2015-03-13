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
head(mortData)
summary(mortData)

head(subset(mortData, ICD.Chapter == "Certain infectious and parasitic diseases" & State == "Alabama", 
     select=c(X, ICD.Chapter, State, Year, Crude.Rate)), 20)

natDeathByCause <- aggregate(cbind(Deaths, Population) ~ ICD.Chapter + Year, mortData, FUN=sum) 
natDeathByCause$Crude.Rate <- round(natDeathByCause$Deaths / natDeathByCause$Population * crudeRateFactor, 4)
head(natDeathByCause, 40)


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
    subset(mortData, ICD.Chapter == input$causeOfDeath & State == input$state, select=c(Year, Crude.Rate))
  })
  
  # A simple data table (non-visualization)
  #output$mortTable <- renderDataTable(subMort())
  
  
  # The following code produces a plot from ggplot
#   outputPlot <- function(){ 
#     in_cause <- input$causeOfDeath
#         
#     data <- subMort()
#     data <- data[order(data$Crude.Rate),]
#     data$State <- factor(data$State, levels=unique(as.character(data$State)) )
#     print(head(data))
#     
#     p <- ggplot(data, aes(x=State, y=Crude.Rate)) 
#     p <- p + geom_point() 
#     p <- p + theme(axis.ticks=element_blank(),
#                    panel.border = element_rect(color="gray", fill=NA),
#                    panel.background=element_rect(fill="#FBFBFB"),
#                    panel.grid.major.y=element_line(color="white", size=0.5),
#                    panel.grid.major.x=element_line(color="white", size=0.5)) 
#     p <- p + coord_flip()
#     print(p)  
#   } 
#   
#   output$mortTable <- renderPlot(outputPlot())
  
  preppedData <- reactive({ 
    data <- subMort()
    data <- data[order(data$Year),]
    #data <- 
    colnames(data) <- c("Year", "State.Rate")
    #print(head(data))
    return (data)
  })

  
  
  # The googleVis bar chart rendition
  output$mortGvis <- renderGvis({gvisLineChart(preppedData(), 
                                              xvar="Year", 
                                              yvar=c("State.Rate"),
                                              options=list(width="100%", 
                                                           height="800", 
                                                           chartArea="{top:'10'}",
                                                           vAxis="{textStyle: {fontSize: '10'}}"))})

  
  # Hook the state combo box so we can populate 
  # with unique list of states from the data.
  # This is not necessary for the current exercise, but
  # might be useful later for dynamically populating a dependent list.
  #
  # See Also:
  #    http://stackoverflow.com/questions/21465411/r-shiny-passing-reactive-to-selectinput-choices
  #
  # Make the causeOfDeath list a reactive outgoing variable
  #   outCOD <- reactive(causeOfDeath)
  #
  #   observe({
  #     updateSelectInput(session, "causeOfDeath",
  #                       choices = outCOD()
  #     )})
  
  
})