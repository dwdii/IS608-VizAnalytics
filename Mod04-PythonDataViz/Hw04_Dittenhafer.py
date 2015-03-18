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
import pandas as pd



def main():
    """Our main function."""

    file = "https://github.com/jlaurito/CUNY_IS608/raw/master/lecture4/data/riverkeeper_data_2013.csv"

    # Load the data
    data = pd.read_csv(file, parse_dates=[2], infer_datetime_format=True)
    data["Date"] = pd.to_datetime(data["Date"])
    print(data.head(10))

    data.sort(columns=["Date", "Site"], ascending=False, inplace=True)
    print(data)

# This is the main of the program.
if __name__ == "__main__":
     main()

