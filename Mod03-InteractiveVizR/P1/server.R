library(shiny)

# Load the data set
dataUrl <- "https://github.com/jlaurito/CUNY_IS608/blob/master/lecture3/data/cleaned-cdc-mortality-1999-2010.csv?raw=true"
mort <- read.csv(dataUrl, stringsAsFactors=FALSE)

head(mort)

# Get a unique/distinct list of states from the data.
states <- unique(mort$State)

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output, session) {
  
  # Compute the forumla text in a reactive expression since it is 
  # shared by the output$caption and output$mpgPlot expressions
  selectedState <- reactive({
    paste("State: ", input$state)
  })
  
  # Return the formula text for printing as a caption
  output$caption <- renderText({
    selectedState()
  })
  
  # Make the states list a reactive outgoing variable
  outStates <- reactive(states)
  
  # Hook the state combo box so we can populate 
  # with unique list of states from the data.
  # See Also:
  #    http://stackoverflow.com/questions/21465411/r-shiny-passing-reactive-to-selectinput-choices
  observe({
    updateSelectInput(session, "state",
                      choices = outStates()
    )})
  
  
})