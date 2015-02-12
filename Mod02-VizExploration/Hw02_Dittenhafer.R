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
#require(plyr)

dataFile <- "all_PLUTO_data.RData"
combineAndSaveData <- FALSE
if(combineAndSaveData)
{
  path <- "C:\\Users\\Dan\\Downloads\\CUNY-IS608\\nyc_pluto_14v2"
  bk <- read.csv(sprintf("%s\\BK.csv", path))
  bx <- read.csv(sprintf("%s\\BX.csv", path))
  mn <- read.csv(sprintf("%s\\MN.csv", path))
  qn <- read.csv(sprintf("%s\\QN.csv", path))
  si <- read.csv(sprintf("%s\\SI.csv", path))
  
  # Combine
  all <- rbind(bk, bx, mn, qn, si)

  # Save
  save(all, file="all_PLUTO_data.RData")
} else
{
  # Load from the previously saved file.
  load(dataFile)
}

head(all)

