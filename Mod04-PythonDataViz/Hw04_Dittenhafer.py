#
#      Author: Daniel Dittenhafer
#
#     Created: Mar 17, 2015
#
# Description: Answers to Module 4 Homework
#
#
# https://github.com/dwdii/IS602-AdvProgTech/blob/master/Lesson9/hw9_dittenhafer.py
#
__author__ = 'Daniel Dittenhafer'

#import csv
#from decimal import *
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import os.path

def top10PlacesToSwim(dSiteData, bBest, figId):
    """
    Creates the top 10 best/worst places to swim based on the specified dataset.

    :param dSiteData: the data set.
    :param bBest: true for best places to swim, false for worst.
    :param figId: integer id of figure for plotting.
    :return: none
    """

    dSiteData.set_index(keys=["Site"])
    dSiteData.sort(columns=["EnteroCountInt64"], ascending=bBest, inplace=True)
    top10PlacesToSwim = dSiteData.head(10)
    if bBest:
        title = "1a) Top 10 Best Places to Swim"
    else:
        title = "1b) Top 10 Worst Places to Swim"

    title = "{0} {1:%b %d %Y} - {2:%b %d %Y}".format(title, top10PlacesToSwim["Date"].min(), top10PlacesToSwim["Date"].max())
    print(title)
    print("=================================================================")
    print(top10PlacesToSwim[["Site", "EnteroCountInt64", "Date"]])

    fig2 = plt.figure(figId)

    plt1 = fig2.add_subplot(111)
    fig2.subplots_adjust(bottom=.3)
    plt.plot(top10PlacesToSwim["EnteroCountInt64"], 'b.')
    plt1.set_xticklabels(top10PlacesToSwim["Site"].values, rotation='25')
    plt1.set_ylabel("Entero Count")
    plt1.set_ylim(0, top10PlacesToSwim["EnteroCountInt64"].max() * 1.1)

    plt.title(title)
    plt.show()

def siteWaterTestFrequencyChart(dBySiteCounts, figId, title):

    # Extract top 10 (assuming pre-sorted).
    top10TestedSites = dBySiteCounts.head(10)

    print(title)
    print("=============================================================================")
    print(top10TestedSites)

    fig2 = plt.figure(figId)
    fig2.subplots_adjust(bottom=.3)
    ax1 = fig2.add_subplot(111)
    # Seaborn
    sns.pointplot("Site", "Date", data=top10TestedSites, join=False, ax=ax1, x_order=top10TestedSites["Site"])
    # Although seaborn call set_xticklabels for us, we need the rotation so need to call it again...
    ax1.set_xticklabels(top10TestedSites["Site"], rotation='25')
    ax1.set_ylabel("Water Tests")
    ax1.set_ylim(0, top10TestedSites["Date"].max() * 1.1)
    plt.title(title)
    plt.show()

    # Old School (Matplotlib raw)
    # fig2 = plt.figure(figId)
    #
    # fig2.subplots_adjust(bottom=.3)
    # plt.plot(top10TestedSites["Date"])
    # plt1.set_xticklabels(top10TestedSites["Site"], rotation='25')
    # plt1.set_ylabel("Water Tests")
    # plt1.set_ylim(0, top10TestedSites["Date"].max() * 1.1)
    # plt.title(title)
    # plt.show()

def cleanEnteroCount(x):
    if x[0] == "<":
        return int(eval(x[1:] + " - 1"))
    elif x[0] == ">":
        return int(eval(x[1:] + " + 1"))
    else:
        return int(x)

def DaysSinceLastTestStdevChart(theData):
    """
    This function computes the stdev on the DaysSinceLastInt column, sorts by the result
    and displays a multi faceted chart with top 10 largest and smallest stdev sites.

    :param theData: A Pandas DataFrame with the data set
    """
    d2bSiteStdevDaysSinceLast = theData.groupby(["Site"])["DaysSinceLastInt"].std()
    d2bSiteStdevDaysSinceLast.sort(inplace=True, ascending=False)

    # Typical stdev is ~60 days, with some much higher and lower.
    fig5 = plt.figure(5)
    fig5.subplots_adjust(bottom=.3, hspace=1.0)

    top10LongStdevDays = d2bSiteStdevDaysSinceLast.head(10).reset_index()
    print(top10LongStdevDays)

    ax1 = fig5.add_subplot(211)
    ax1 = sns.pointplot("Site", "DaysSinceLastInt", join=False, data=top10LongStdevDays, ax=ax1,
                        x_order=top10LongStdevDays["Site"])
    ax1.set_xticklabels(top10LongStdevDays["Site"], rotation='20')
    ax1.get_xaxis().set_label_text("")
    plt.title("Top 10 Least Regularly Tested Sites (Largest Stdev)")

    top10ShortStdevDays = d2bSiteStdevDaysSinceLast.tail(10).reset_index()
    print(top10ShortStdevDays)

    ax2 = fig5.add_subplot(212)
    ax2 = sns.pointplot("Site", "DaysSinceLastInt", join=False, data=top10ShortStdevDays, ax=ax2, x_order=top10ShortStdevDays["Site"])
    ax2.set_xticklabels(top10ShortStdevDays["Site"], rotation='20')

    plt.title("Top 10 Most Regularly Tested Sites (Smallest Stdev)")
    plt.suptitle("2c) Standard Deviation Days Since Last Water Test")
    plt.show()

def RainFallVsEnteroCountAnalysis(theData):
    """
    This function initially executes the Seaborn jointplot with linear regression enabled to
    show the relationship (if any) between FourDayRainTotal and EnteroCounts. It then goes deeper
    to examine the relationship (if any) at individual sites.

    :param theData:  A Pandas DataFrame with the data set
    :return: None
    """
    print(theData.head())

    ax1 = sns.jointplot("FourDayRainTotal", "EnteroCountInt64", theData, kind="reg")
    plt.suptitle("3) Four Day Rain Total vs Entero Count Linear Regression ")
    plt.show()

    print("Appears to be a negligible relationship overall. What about at individual sites?")

    # Appears to be a negligible relationship overall. What about at individual sites?
    #
    # Which sites at the most and least rain fall?
    rainFallSumTotals = theData.groupby(by=["Site"])["FourDayRainTotal"].sum()
    rainFallSumTotals = rainFallSumTotals.sort(inplace=False, ascending=False).reset_index()
    
    mostRain = rainFallSumTotals.head(1)["Site"].reset_index()
    leastRain = rainFallSumTotals.tail(1)["Site"].reset_index()

    mostRainSite = mostRain["Site"].item()
    print("Site w. Most  Rain: {0}".format(mostRainSite))
    leastRainSite = leastRain["Site"].item()
    print("Site w. Least Rain: {0}".format(leastRainSite))

    # Subset the data to use in the jointplot
    mostRainData = theData[theData["Site"] == mostRainSite]
    leastRainData = theData[theData["Site"] == leastRainSite]

    # Most rain jointplot with OLS
    ax1 = sns.jointplot("FourDayRainTotal", "EnteroCountInt64", mostRainData, kind="reg")
    plt.suptitle("3b) {0} Most Four Day Rain Total vs Entero Count Linear Regression".format(mostRainSite))
    plt.show()

    # Least rain jointplot with OLS
    ax1 = sns.jointplot("FourDayRainTotal", "EnteroCountInt64", leastRainData, kind="reg")
    plt.suptitle("3b) {0} Least Four Day Rain Total vs Entero Count Linear Regression".format(leastRainSite))
    plt.show()

    print("It appears that less rain may contribute to greater entero counts based on the Pearson's R values of 0.71.")

def main():
    """Our main function."""

    # Set basic Seaborn related chart properties.
    sns.set(style="whitegrid")
    sns.set_palette("deep", desat=.6)
    sns.set_context("talk") #rc={"figure.figsize": (8, 4)})

    # Use local file if available, otherwise, reference the github repo
    file = "C:\Users\Dan\SkyDrive\GradSchool\IS608-VizAnalytics\data\\riverkeeper_data_2013.txt"
    if not os.path.isfile(file):
        file = "https://github.com/jlaurito/CUNY_IS608/raw/master/lecture4/data/riverkeeper_data_2013.csv"

    # Load the data
    data = pd.read_csv(file, parse_dates=[2], infer_datetime_format=True)

    # Cleanup
    #
    # Convert to datetime data type
    data["Date"] = pd.to_datetime(data["Date"])

    # Convert to int64 (removes the greater/less than and adds/subtracts 1 so integers are reasonably sortable.
    data["EnteroCountInt64"] = data.EnteroCount.apply(cleanEnteroCount)
    #print(data.dtypes)

    #data.sort(columns=["Date", "Site"], ascending=False, inplace=True)
    #print(data.head(10))

    # Determine the most recent reading for each site
    dBySiteMaxDate = data.groupby(by=["Site"])["Date"].max()
    dBySiteMaxDate = dBySiteMaxDate.reset_index()
    #dBySiteMaxDate = dBySiteMaxDate.set_index(keys=["Site", "Date"])

    # Show me
    #print(dBySiteMaxDate)

    # Join the site most recent date to the raw data to get
    # the most recent reading for each site which helps us determine
    # best/worst current swim locations
    dSiteMaxDateEntero = pd.merge(data, dBySiteMaxDate,  how="inner")

    # Export so I can double check via excel
    dSiteMaxDateEntero.to_csv("dSiteMaxDateEntero.csv")

    # 1a. List & graph the (10) best places to swim in the data set.
    top10PlacesToSwim(dSiteMaxDateEntero, True, 1)

    # 1b. List & graph the (10) WORST places to swim in the data set.
    top10PlacesToSwim(dSiteMaxDateEntero, False, 2)

    # 2a. Which sites have been tested most regularly?
    # Hmm... As in most frequently, or on a consistent spread of days?
    #
    # First lets look at how many times each site has been tested.
    dBySiteCounts = data.groupby(by=["Site"])["Date"].count()
    dBySiteCounts.sort( ascending=False, inplace=True)
    siteWaterTestFrequencyChart(dBySiteCounts.reset_index(), 3, "2a) Top 10 Most Frequently Tested Sites")

    # 2b. Which sites have long gaps between tests?
    #
    # First we need to figure out how many days have elapsed since the prior test per site.
    data.sort(columns=["Site", "Date"], inplace=True, ascending=True)

    # http://stackoverflow.com/questions/23664877/pandas-equivalent-of-oracle-lead-lag-function
    data["Date_lagged"] = data.groupby(["Site"])["Date"].shift(1)
    data["DaysSinceLast"] = data["Date"] - data["Date_lagged"]
    data.dropna(inplace=True)

    # Continuing 2b. What is the mean days since last test?

    data["DaysSinceLastInt"] = (data["DaysSinceLast"] / np.timedelta64(1, 'D')).astype(int)
    d2bSiteMedianDaysSinceLast = data.groupby(["Site"])["DaysSinceLastInt"].mean()
    d2bSiteMedianDaysSinceLast.sort(inplace=True, ascending=False)

    top10MeanDaysSinceLast = d2bSiteMedianDaysSinceLast.head(10).reset_index()
    print(top10MeanDaysSinceLast)

    # Looks like typical median is 25-30 days with a couple much shorter.
    fig4 = plt.figure(4)
    fig4.subplots_adjust(bottom=.3)
    ax1 = fig4.add_subplot(111)
    ax1 = sns.pointplot("Site", "DaysSinceLastInt", data=top10MeanDaysSinceLast, ax=ax1,
                        x_order=top10MeanDaysSinceLast["Site"])
    ax1.set_xticklabels(top10MeanDaysSinceLast["Site"], rotation='25')
    plt.title("2b) Mean Days Since Last Water Test")
    plt.show()

    # Continueing 2c. What is standard deviation? Lower Stdev indicates more consistent elapsed days
    DaysSinceLastTestStdevChart(data)

    # 3) Is there a relationship between the amount of rain and water quality?
    RainFallVsEnteroCountAnalysis(data)

# This is the main of the program.
if __name__ == "__main__":
     main()

