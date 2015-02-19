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

# Define UI for 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("IS608-3-1: Rank States By Mortality"),
  
  sidebarLayout(
  
    sidebarPanel(
      selectInput("causeOfDeath", "Cause of Death:", list())
      )
    ,
  
  mainPanel(
    h3(textOutput("caption")),
    
    dataTableOutput("mortTable")
    )
  )
))
