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
    #load("all_PLUTO_data.RData")
    #allData <- all
  }
}

head(allData)

##### Question 1 #####
# Build a graph to help the city determine when most buildings were constructed.
# Is there anything in the results that causes you to question the accuracy of the data?
#   A: Many (44198) entries with a YearBuilt=0. When were these building constructed?
since1850 <- subset(allData, YearBuilt > 1850)
dist_s <- condense(bin(since1850$YearBuilt, 10))
autoplot(dist_s) + labs(title="How many buildings were built each year?") + theme(axis.ticks=element_blank(),
                 panel.border = element_rect(color="gray", fill=NA),
                 panel.background=element_rect(fill="#FBFBFB"),
                 panel.grid.major.y=element_line(color="white", size=0.5),
                 panel.grid.major.x=element_line(color="white", size=0.5))

# Save the chart to a file.
ggsave("lecture1\\Figure21.png", width = 4.8, height=4.8, dpi=100)

##### Question 2 #####
# Create a graph that shows how many buildings of a certain 
# number of floors where build in each year.

# Aggregate counts by year and number of floors
floorsYear <- plyr::count(since1850, vars = c("NumFloors", "YearBuilt"))

# Add a column for rounded tens of stories
Stories <- round(floorsYear$NumFloors, -1)
floorsYear <- cbind(floorsYear, Stories)
#head(floorsYear[floorsYear$NumFloors > 10,])

# Subset to only include 20-70 story buildings when at least one building
sub <- floorsYear[10 < floorsYear$Stories & floorsYear$Stories <= 70 & floorsYear$freq > 0, ]

# Using ggplot to create this faceted chart
g2 <- ggplot(data=sub, aes(x=YearBuilt, y=freq, color=freq))
#g2 <- g2 + geom_point()
g2 <- g2 + geom_line()
g2 <- g2 + scale_y_log10()
g2 <- g2 + scale_color_continuous()
g2 <- g2 + facet_wrap(~ Stories)
g2 <- g2 + theme(axis.ticks=element_blank(),
                 axis.text.x=element_text(angle=60,hjust=1),
                 panel.border = element_rect(color="gray", fill=NA),
                 panel.background=element_rect(fill="#FBFBFB"),
                 panel.grid.major.y=element_line(color="white", size=0.5),
                 panel.grid.major.x=element_line(color="white", size=0.5))
g2 <- g2 + labs(title="When were N-Story Buildings built?")
g2

# Save the chart to a file.
ggsave("lecture1\\Figure22.png", width = 4.8, height=4.8, dpi=100)


##### Question 3 #####
#  Chart showing assessed value per floor around WWII.
#
#  - Seems like there is not a relationship. Rather, there is a
#    spike in early 1930s (depression era), but WWII is fairly similar 
#    to surrounding time.
aroundWWII <- subset(allData, 1930 < allData$YearBuilt & allData$YearBuilt < 1955 & allData$NumFloors > 0)

# Compute assessed value per floor excluding land assessment so focus is on building materials
AssessedValPerFloor <- (aroundWWII$AssessTot - aroundWWII$AssessLand)/ aroundWWII$NumFloors
aroundWWII <- cbind(aroundWWII, AssessedValPerFloor)
head(aroundWWII)

# Compute mean assessed value per floor for each year.
meanAssessedValPerFloorByYear <- plyr::ddply(aroundWWII, "YearBuilt", plyr::summarise, meanAssesedValFl = mean(AssessedValPerFloor), sd=sd(AssessedValPerFloor))

# And include 95% confidence interval for use in plot.
meanAssessedValPerFloorByYear$ucl <- meanAssessedValPerFloorByYear$mean + (1.96 * meanAssessedValPerFloorByYear$sd)
meanAssessedValPerFloorByYear$lcl <- meanAssessedValPerFloorByYear$mean - (1.96 * meanAssessedValPerFloorByYear$sd)

# Capture outliers that are above the level we want to show
outliersValue <- meanAssessedValPerFloorByYear$ucl[meanAssessedValPerFloorByYear$ucl > 2500000]
outliersYear <-  meanAssessedValPerFloorByYear$YearBuilt[meanAssessedValPerFloorByYear$ucl > 2500000]
outliers <- data.frame(Value=round(outliersValue, 0), YearBuilt=outliersYear)
outliers <- rbind(outliers, c("95% CI outliers", 1943))
outliers

# reduce size of upper confidence level
meanAssessedValPerFloorByYear$ucl[meanAssessedValPerFloorByYear$ucl > 2500000] <- 2500000
meanAssessedValPerFloorByYear$lcl[meanAssessedValPerFloorByYear$lcl < 0] <- 0
head(meanAssessedValPerFloorByYear, 15)

# Function to help with labeling Dollars on axis.
dollarFormat <- function(l) {  
  l <- prettyNum(l / 1000, big.mark=",", scientific = FALSE)
  return(sprintf("$%s", l))
}
                                             
# Create the plot 
g3 <- ggplot(data=meanAssessedValPerFloorByYear, aes(x=YearBuilt, y=meanAssesedValFl))
g3 <- g3 + geom_smooth(aes(ymin = lcl, ymax = ucl), stat="identity")
g3 <- g3 + labs(title="Mean Assessed Value/Floor By Year\r\nwith 95% Confidence Interval", 
                x="Year Built", y="Mean Assessed Value/Floor (Thousands USD)")
g3 <- g3 + theme(axis.ticks=element_blank(),
                 panel.border = element_rect(color="gray", fill=NA),
                 panel.background=element_rect(fill="#FBFBFB"),
                 panel.grid.major.y=element_line(color="white", size=0.5),
                 panel.grid.major.x=element_line(color="white", size=0.5),
                 axis.text.y=element_text(angle=60,hjust=1))
g3 <- g3 + scale_y_continuous(labels=dollarFormat)
g3 <- g3 + annotate("text", label = c("128,265,717", "<-- 95% CI Outlier"), 
                    x = c(1933, 1940), 
                    y = rep(2600000, 2), 
                    size = rep(3, 2))
g3

# Save the chart to a file.
ggsave("lecture1\\Figure23.png", width = 4.8, height=4.8, dpi=100)
