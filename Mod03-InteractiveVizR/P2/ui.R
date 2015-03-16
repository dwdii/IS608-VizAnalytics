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
states <- unique(mortData$State)
causeOfDeath <- unique(mortData$ICD.Chapter)


# Define UI for 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("IS608-3-2: Mortality Rate Improvement - State vs National Avg"),
  
  #verticalLayout(
  sidebarLayout(
    sidebarPanel(selectInput("state", "State:", choices=states, width="100%")
                 , selectInput("causeOfDeath", "Cause of Death:", choices=causeOfDeath, width="100%"),
                 helpText("StateDeltaVsNational: Illustrates the State's change from prior year relative ",
                          "to the National Average change from prior year. Positive values indicate the ",
                          "State is improving faster than the national average for the given year, and ",
                          "negatives values indicate the State is improving slower than the national average (or getting worse)."),
                 helpText("State.Rate and NatAvg.Rate are per 100,000 population."),
                 helpText("State_delta and National_delta represent the difference for each series versus the prior year.")
    ),
    mainPanel( 
    
     htmlOutput("mortGvis")
    #, plotOutput("mortTable") # Uncomment if you want to show ggplot instead.

    )
  )
))
