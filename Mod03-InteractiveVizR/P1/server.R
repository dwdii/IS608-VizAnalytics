library(shiny)
library(ggplot2)

# Load the data set
dataUrl <- "https://github.com/jlaurito/CUNY_IS608/blob/master/lecture3/data/cleaned-cdc-mortality-1999-2010.csv?raw=true"
mort <- read.csv(dataUrl, stringsAsFactors=FALSE)
head(mort)
mort2010 <- mort[mort$Year == 2010,]
mortData <- mort2010
head(mortData)

# Get a unique/distinct list of states from the data.
states <- unique(mortData$State)
causeOfDeath <- unique(mortData$ICD.Chapter)
#causeOfDeath

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output, session) {
  
  # Compute the forumla text in a reactive expression since it is 
  # shared by the output$caption and output$mpgPlot expressions
  selectedCOD <- reactive({
    paste("Cause Of Death: ", input$causeOfDeath)
  })
  
  # Return the formula text for printing as a caption
  output$caption <- renderText({
    selectedCOD()
  })
  
  # Make the states list a reactive outgoing variable
  outCOD <- reactive(causeOfDeath)
    
  subMort <- reactive({
    subset(mortData[mortData$ICD.Chapter == input$causeOfDeath,], select=c("State", "Crude.Rate"))
  })
  #output$mortTable <- renderDataTable(subMort())
  
  outputPlot <- function(){ 
    in_cause <- input$causeOfDeath
        
    data <- subMort()
    data <- data[order(data$Crude.Rate),]
    data$State <- factor(data$State, levels=unique(as.character(data$State)) )
    print(head(data))
    
    p <- ggplot(data, aes(x=State, y=Crude.Rate)) 
    p <- p + geom_point() 
    p <- p + theme(axis.ticks=element_blank(),
                   panel.border = element_rect(color="gray", fill=NA),
                   panel.background=element_rect(fill="#FBFBFB"),
                   panel.grid.major.y=element_line(color="white", size=0.5),
                   panel.grid.major.x=element_line(color="white", size=0.5)) 
    p <- p + coord_flip()
    print(p) 
  } 
  
  output$mortTable <- renderPlot(outputPlot())

  
  # Hook the state combo box so we can populate 
  # with unique list of states from the data.
  # See Also:
  #    http://stackoverflow.com/questions/21465411/r-shiny-passing-reactive-to-selectinput-choices
  #   observe({
  #     updateSelectInput(session, "causeOfDeath",
  #                       choices = outCOD()
  #     )})
  
  
})