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
ggsave("Figure1.png", width = 4.8, height=6.4, dpi=300)

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
#employmentByIndustry <- plyr::arrange(stateData, freq)
#countByState$State <- factor(countByState$State, levels=unique(as.character(countByState$State)) )

print(employmentByIndustry)

# Visualize 
g2 <- ggplot(data=completeStateData, aes(x=Industry, y=Employees)) 
g2 <- g2 + theme(axis.ticks=element_blank(), 
                 axis.text.x=element_text(angle=45,hjust=1),
                 panel.border = element_rect(color="gray", fill=NA),
                 panel.background=element_rect(fill="#FBFBFB"),
                 panel.grid.major.y=element_line(color="white", size=0.5),
                 panel.grid.major.x=element_line(color="white", size=0.5))
#g2 <- g2 + stat_smooth(method=lm,aes(group=1))
g2 <- g2 + geom_violin()
#g2 <- g2 + geom_bar(stat="identity") 
g2 <- g2 + geom_point(position="jitter") 
#g2 <- g2 + scale_x_discrete(breaks=waiver())
#g2 <- g2 + scale_y_continuous(breaks=c(seq(0,800,by=200)), minor_breaks=NULL)
#g2 <- g2 + coord_flip()
g2 <- g2 + labs(title=sprintf("Employment by Industry in %s", as.character(stateId)), x="", y="Average Employees") 
g2 

# Save the chart to a file.
ggsave("Figure2.png", width = 4.8, height=6.4, dpi=300)