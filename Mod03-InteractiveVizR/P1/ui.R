#
#     Author: Daniel Dittenhafer
#
#     Created: Feb 18, 2015
#
# Description: IS608 Hw3 Prob 1 - Shiny UI
# Question 1:
#   As a researcher, you frequently compare mortality rates from particular 
#   causes across different States. You need a visualization that will let you 
#   see (for 2010 only) the crude mortality rate, across all States, from one 
#   cause (for example, Neoplasms, which are effectively cancers). Create a 
#   visualization that allows you to rank States by crude mortality for each 
#   cause of death.
#
library(shiny)

# Load the data set
dataUrl <- "https://github.com/jlaurito/CUNY_IS608/blob/master/lecture3/data/cleaned-cdc-mortality-1999-2010.csv?raw=true"
mort <- read.csv(dataUrl, stringsAsFactors=FALSE)
mort2010 <- mort[mort$Year == 2010,]
mortData <- mort2010

# Get a unique/distinct list of states from the data.
states <- unique(mortData$State)
causeOfDeath <- unique(mortData$ICD.Chapter)


# Define UI for 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("IS608-3-1: Rank States By Mortality"),
  
  verticalLayout(
  
  mainPanel( 
    plotOutput("mortTable"),
    selectInput("causeOfDeath", "Cause of Death:", choices=causeOfDeath, width="100%")
    )
  )
))
