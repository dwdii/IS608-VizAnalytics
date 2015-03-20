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

import csv
from decimal import *
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

def top10PlacesToSwim(dSiteData, bBest, figId):

    dSiteData.set_index(keys=["Site"])
    dSiteData.sort(columns=["EnteroCountInt64"], ascending=bBest, inplace=True)
    top10PlacesToSwim = dSiteData.head(10)
    if bBest:
        title = "Top 10 Best Places to Swim"
    else:
        title = "Top 10 Worst Places to Swim"
    print(title)
    print("=====================")
    print(top10PlacesToSwim[["Site", "EnteroCountInt64"]])

    fig2 = plt.figure(figId)

    plt1 = fig2.add_subplot(111)
    fig2.subplots_adjust(bottom=.3)
    plt.plot(top10PlacesToSwim["EnteroCountInt64"])
    plt1.set_xticklabels(top10PlacesToSwim["Site"].values, rotation='25')
    plt1.set_ylabel("Entero Count")
    plt1.set_ylim(0, top10PlacesToSwim["EnteroCountInt64"].max() * 1.1)
    plt.title(title)
    plt.show()

def siteWaterTestFrequencyChart(dBySiteCounts, figId, title):
    fig2 = plt.figure(figId)

    plt1 = fig2.add_subplot(111)
    fig2.subplots_adjust(bottom=.3)
    plt.plot(dBySiteCounts)
    plt1.set_xticklabels(dBySiteCounts.ix.obj, rotation='25')
    plt1.set_ylabel("Water Tests")
    plt1.set_ylim(0, dBySiteCounts.max() * 1.1)
    plt.title(title)
    plt.show()

def cleanEnteroCount(x):
    if x[0] == "<":
        return int(eval(x[1:] + " - 1"))
    elif x[0] == ">" :
        return int(eval(x[1:] + " + 1"))
    else:
        return int(x)

def main():
    """Our main function."""
    sns.set_palette("deep", desat=.6)
    sns.set_context(rc={"figure.figsize": (8, 4)})

    # file = "https://github.com/jlaurito/CUNY_IS608/raw/master/lecture4/data/riverkeeper_data_2013.csv"
    file = "C:\Users\Dan\SkyDrive\GradSchool\IS608-VizAnalytics\data\\riverkeeper_data_2013.txt"

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

    dBySiteMaxDate = data.groupby(by=["Site"])["Date"].max()
    dBySiteMaxDate = dBySiteMaxDate.reset_index()
    #dBySiteMaxDate = dBySiteMaxDate.set_index(keys=["Site", "Date"])

    print(dBySiteMaxDate)

    # Join the site most recent date to the raw data to get
    # the most recent reading for each site.
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
    print(dBySiteCounts.head())

    siteWaterTestFrequencyChart(dBySiteCounts, 3, "Water Test Distribution")


# This is the main of the program.
if __name__ == "__main__":
     main()

