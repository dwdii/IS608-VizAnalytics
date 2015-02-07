# 
# Author: Daniel Dittenhafer
#
# Created: Feb 1, 2015
#
# Description: Answers to Module 1 Homework 1
#
require(plyr)
require(ggplot2)

# Load the data set
dataUrl <- "https://raw.githubusercontent.com/jlaurito/CUNY_IS608/master/lecture1/data/inc5000_data.csv"
inc5k <- read.csv(dataUrl, stringsAsFactors=FALSE)

# Show me
head(inc5k)

#######
# Q1 = Companies by State
#
countByState <- plyr::count(inc5k, c("State"))
countByState <- plyr::arrange(countByState, freq)
countByState$State <- factor(countByState$State, levels=unique(as.character(countByState$State)) )

head(countByState)

# Visualize 
g1 <- ggplot(data=countByState, aes(x=State, y=freq)) 
g1 <- g1 + theme(axis.ticks=element_blank(), 
                 panel.border = element_rect(color="gray", fill=NA),
                 panel.background=element_rect(fill="#FBFBFB"),
                 panel.grid.major.y=element_line(color="white", size=0.5),
                 panel.grid.major.x=element_line(color="white", size=0.5))
#g1 <- g1 + geom_bar(stat="identity") 
g1 <- g1 + geom_point() 
g1 <- g1 + scale_x_discrete(breaks=waiver())
g1 <- g1 + scale_y_continuous(breaks=c(seq(0,800,by=200)), minor_breaks=NULL)
g1 <- g1 + coord_flip()
g1 <- g1 + labs(title="Distribution of Companies by State", x="", y="# of Businesses") 
g1 

# Save the chart to a file.
ggsave("Figure1.png", width = 4.8, height=6.4, dpi=100)

#######
# Q2 = Employment in 3rd State
#
stateRank = 3
stateId <- countByState$State[nrow(countByState)-(stateRank-1)]
print(sprintf("Looking at employment by industry for: %s", stateId))
stateData <- dplyr::filter(inc5k, State == stateId)

# Check for and extact only 'complete' data rows.
ok <- complete.cases(stateData)
completeStateData <- stateData[ok,]

# Aggregate by industry
employmentByIndustry <- plyr::ddply(completeStateData, c("State", "Industry"), plyr::summarize, mean = mean(Employees), sd = sd(Employees), .inform=TRUE)

# Put a floor on the minimum (-1 stdev) at zero
employmentByIndustry$min <- employmentByIndustry$mean - employmentByIndustry$sd
employmentByIndustry$min[employmentByIndustry$min < 0] = 0

#employmentByIndustry <- plyr::arrange(stateData, freq)
#countByState$State <- factor(countByState$State, levels=unique(as.character(countByState$State)) )
completeStateDataMSD <- plyr::join(completeStateData, employmentByIndustry, by=c("State", "Industry"))


head(completeStateDataMSD)

#nonOutliers <- dplyr::filter(completeStateDataMSD, Employees < mean + (2 * sd))


# Visualize 
g2 <- ggplot(data=employmentByIndustry, aes(x=Industry, y=mean, color=mean)) 
g2 <- g2 + theme(axis.ticks=element_blank(), 
                 axis.text.x=element_text(angle=60,hjust=1),
                 panel.border = element_rect(color="gray", fill=NA),
                 panel.background=element_rect(fill="#FBFBFB"),
                 panel.grid.major.y=element_line(color="white", size=0.5),
                 panel.grid.major.x=element_line(color="white", size=0.5))
#g2 <- g2 + stat_smooth(method=lm,aes(group=1))
#g2 <- g2 + geom_smooth(aes(group=1))
#g2 <- g2 + geom_boxplot(outlier.shape=NA)
#g2 <- g2 + geom_bar(stat="identity") 
#g2 <- g2 + geom_point(position="jitter") 
g2 <- g2 + geom_pointrange(aes(ymin=min, ymax=mean + sd))
#g2 <- g2 + scale_x_discrete(breaks=waiver())
#g2 <- g2 + scale_y_continuous(breaks=c(seq(0,800,by=200)), minor_breaks=NULL)
#g2 <- g2 + coord_flip()
g2 <- g2 + labs(title=sprintf("Employment by Industry in %s", as.character(stateId)), x="", y="Average Employees") 
g2 

# Save the chart to a file.
ggsave("Figure2.png", width = 4.8, height=6.4, dpi=100)

# http://stackoverflow.com/questions/5677885/ignore-outliers-in-ggplot2-boxplot

#######
# Q3 = Most Revenue per Employee by Industry
#
ok <- complete.cases(inc5k)
completeData <- inc5k[ok,]
avgEmpRevByInd <- plyr::ddply(completeData, c("Industry"), plyr::summarize, totalEmployees = sum(Employees), totalRevenue = sum(Revenue), .inform=TRUE)
avgEmpRevByInd$meanRevPerEmp <- avgEmpRevByInd$totalRevenue / avgEmpRevByInd$totalEmployees
avgEmpRevByInd <- plyr::arrange(avgEmpRevByInd, meanRevPerEmp, decreasing=TRUE)
avgEmpRevByInd$Industry <- factor(avgEmpRevByInd$Industry, levels=unique(as.character(avgEmpRevByInd$Industry)) )
avgEmpRevByInd <- head(avgEmpRevByInd, n=10)


# Function to help with labeling Dollars on axis.
dollarFormat <- function(l) {  
  l <- prettyNum(l / 1000, big.mark=",", scientific = FALSE)
  return(sprintf("$%s", l))
}

# Visualize 
g3 <- ggplot(data=avgEmpRevByInd, aes(x=Industry, y=meanRevPerEmp)) 
g3 <- g3 + theme(axis.ticks=element_blank(), 
                 axis.text.x=element_text(angle=60,hjust=1),
                 panel.border = element_rect(color="gray", fill=NA),
                 panel.background=element_rect(fill="#FBFBFB"),
                 panel.grid.major.y=element_line(color="white", size=0.5),
                 panel.grid.major.x=element_line(color="white", size=0.5))
g3 <- g3 + geom_point() 
g3 <- g3 + scale_y_continuous(labels=dollarFormat)
g3 <- g3 + labs(title=sprintf("Top 10 Industries by Revenue per Employee"), x="", y="USD (thousands)") 
g3 

# Save the chart to a file.
ggsave("Figure3.png", width = 4.8, height=6.4, dpi=100)