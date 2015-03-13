#
#     Author: Daniel Dittenhafer
#
#     Created: Mar 12, 2015
#
# Description: IS608 Hw3 Prob 2 - Shiny UI
#
# Question 2:
#   Often you are asked whether particular States are improving their
#   mortality rates (per cause) faster than, or slower than, the national 
#   average. Create a visualization that lets your clients see this for 
#   themselves for one cause of death at the time. Keep in mind that the 
#   national average should be weighted by the national population.
#
library(shiny)

# Load the data set from github repo
dataUrl <- "http://github.com/jlaurito/CUNY_IS608/blob/master/lecture3/data/cleaned-cdc-mortality-1999-2010.csv?raw=true"
mort <- read.csv(dataUrl, stringsAsFactors=FALSE)
mortData <- mort

# Get a unique/distinct list of states from the data.
# states <- unique(mortData$State) # Unused
causeOfDeath <- unique(mortData$ICD.Chapter)


# Define UI for 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("IS608-3-2: Mortality Rate - State vs National Avg"),
  
  verticalLayout(
  
  mainPanel( 
    selectInput("causeOfDeath", "Cause of Death:", choices=causeOfDeath, width="100%")
    , htmlOutput("mortGvis")
    #, plotOutput("mortTable") # Uncomment if you want to show ggplot instead.

    )
  )
))
