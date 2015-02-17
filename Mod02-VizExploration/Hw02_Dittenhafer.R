# 
# Author: Daniel Dittenhafer
#
# Created: Feb 11, 2015
#
# Description: Answers to Module 2 Homework 2
#
# install.packages("devtools")
# require(devtools)
# devtools::install_github("bigvis", username="hadley")

require(bigvis)
require(ggplot2)
#require(plyr)

# First loading the data
dataFile <- "all_PLUTO_data.csv"
combineAndSaveData <- FALSE
if(combineAndSaveData)
{
  #
  # Data downloaded from 
  # http://www.nyc.gov/html/dcp/html/bytes/dwn_pluto_mappluto.shtml
  #
  path <- "C:\\Users\\Dan\\Downloads\\CUNY-IS608\\nyc_pluto_14v2"
  bk <- read.csv(sprintf("%s\\BK.csv", path))
  bx <- read.csv(sprintf("%s\\BX.csv", path))
  mn <- read.csv(sprintf("%s\\MN.csv", path))
  qn <- read.csv(sprintf("%s\\QN.csv", path))
  si <- read.csv(sprintf("%s\\SI.csv", path))
  
  # Combine
  allData <- rbind(bk, bx, mn, qn, si)

  # Save
  write.csv(allData, file=dataFile)
} else
{
  # Load from the previously saved file, but only 
  # if not previously loaded in this session.
  if(!exists("allData"))
  {
    allData <- read.csv(dataFile)
  }
}

head(allData)

##### Question 1 #####
# Build a graph to help the city determine when most buildings were constructed.
# Is there anything in the results that causes you to question the accuracy of the data?
#   A: Many (44198) entries with a YearBuilt=0. When were these building constructed?
since1850 <- subset(allData, YearBuilt > 1850)
dist_s <- condense(bin(since1850$YearBuilt, 10))
autoplot(dist_s)

#dist_s

##### Question 2 #####
# Create a graph that shows how many buildings of a certain 
# number of floors where build in each year.
#floorsYear <- condense(bin(since1850$NumFloors, 2), z=since1850$YearBuilt)
#autoplot(floorsYear)

floorsYear <- plyr::count(since1850, vars = c("NumFloors", "YearBuilt"))
floorsYearBV <- condense(bin(floorsYear$NumFloors,width=10, origin=5), z=floorsYear$YearBuilt)
head(floorsYearBV)

g2 <- ggplot(data=floorsYear, aes(x=YearBuilt, y=freq))
g2 <- g2 + geom_point(data=floorsYear[0  <= floorsYear$NumFloors && floorsYear$NumFloors < 10,])
g2 <- g2 + geom_point(data=floorsYear[10 <= floorsYear$NumFloors && floorsYear$NumFloors < 20,])
g2 <- g2 + geom_point(data=floorsYear[20 <= floorsYear$NumFloors && floorsYear$NumFloors < 30,])
g2 <- g2 + geom_point(data=floorsYear[30 <= floorsYear$NumFloors && floorsYear$NumFloors < 40,])
g2 <- g2 + scale_y_log10()
g2 <- g2 + scale_color_gradient(limits=c(3, 100))
#g2 <- g2 + facet_grid(NumFloors ~ freq, margins=TRUE)
g2
#

