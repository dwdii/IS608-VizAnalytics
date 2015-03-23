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
import numpy as np


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

    # Extract top 10 (assuming pre-sorted).
    top10TestedSites = dBySiteCounts.head(10)

    title = "Top 10 Most Frequently Tested Sites"
    print(title)
    print("================================")
    print(top10TestedSites)

    fig2 = plt.figure(figId)
    fig2.subplots_adjust(bottom=.3)
    ax1 = fig2.add_subplot(111)
    # Seaborn
    sns.pointplot("Site", "Date", data=top10TestedSites, join=False, ax=ax1, x_order=top10TestedSites["Site"])
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

def main():
    """Our main function."""
    sns.set(style="whitegrid")
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
    siteWaterTestFrequencyChart(dBySiteCounts.reset_index(), 3, "Water Test Distribution")

    # 2b. Which sites have long gaps between tests?
    #
    # First we need to figure out how many days have elapsed since the prior test per site.
    data.sort(columns=["Site", "Date"], inplace=True, ascending=True)

    # http://stackoverflow.com/questions/23664877/pandas-equivalent-of-oracle-lead-lag-function
    data["Date_lagged"] = data.groupby(["Site"])["Date"].shift(1)
    data["DaysSinceLast"] = data["Date"] - data["Date_lagged"]

    # Continuing 2b. What is the median days since last test?
    d2bNoNaData = data.dropna()
    d2bNoNaData["DaysSinceLastInt"] = (d2bNoNaData["DaysSinceLast"] / np.timedelta64(1, 'D')).astype(int)
    d2bSiteMedianDaysSinceLast = d2bNoNaData.groupby(["Site"])["DaysSinceLastInt"].median().reset_index()

    print(d2bSiteMedianDaysSinceLast.head())

    # Looks like typical median is 25-30 days with a couple much shorter.
    ax1 = sns.pointplot("Site", "DaysSinceLastInt", data=d2bSiteMedianDaysSinceLast)
    ax1.set_xticklabels(d2bSiteMedianDaysSinceLast["Site"], rotation='25')
    plt.title("Median Days Since Last Water Test")
    plt.show()

# This is the main of the program.
if __name__ == "__main__":
     main()

