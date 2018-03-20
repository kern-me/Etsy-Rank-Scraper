# README #
"EtsyRank Keyword Scraper" is designed to automate the collection of Etsy keyword data. It does all the manual work of copying and pasting keyword data from EtsyRank into a Google Sheets spreadsheet.

# Version #
* Etsy Rank Keyword Scraper
* 1.1.0

# What does it do? #
This script automates the process of retrieving keyword data from EtsyRank from a premade list. You will need to compile a list of keywords and put them into the first column of your Google Sheets spreadsheet (described below.)

[See it in action!](https://drive.google.com/open?id=1kDmKdSwmjSvahgoMK_QU-3ltHFcRV77o)

# Why Tho? #
Gathering keyword data is one of the most important parts of Etsy SEO. The process of gathering the data is monotonous and time-consuming. I wrote this script so that I could gather data about keywords while I was away from my computer automatically!

Having all the metrics allows you to make decisions on what keywords are the best for your products.

**Note:** *This app currently uses "activate" to toggle applications and function properly. When running this, any interruption will cause the app to crash or not record the data properly. Let the app collect data and do not use your computer while running.*

# How it Works #
1. A dialog window asks for how many keywords you want to process.
2. The script selects the first cell of your Google Spreadsheet in Google Chrome.
3. Copies the keyword.
4. Switches over to Safari.
5. Finds the search input in the DOM and pastes the clipboard.
6. Runs the Javascript function that executes the search.

7. The script performs logic for:
* Checking to see if you are logged in
* Checking that the page has loaded completely
* Checking that Etsy Rank returns results of the keyword search
* If no results are returned, the app goes back to the Google Sheet, records "no results found" in the cell and moves down to the next row and loops.

8. Finds the DOM elements that contain the keyword data on the page and stores them as variables.
* Competition
* Demand
* Engagement
* Listings Found
* Average Price
* Average Hearts
* Total Views
* Average Views
* Average Daily Views
* Average Weekly Views

9. Switches over to Chrome and pastes the values across the row of your Google Sheet.
10. Arrows down to the next row, then hits the "Home" keystroke to go back to the first cell of the row.
11. The loop starts over.

# Setup #
** You will need MacOS 10.11+ ** and few apps running in order for "EtsyRank Keyword Scraper" to work. See dependencies below.

## Dependencies ##
* Mac OS 10.11+
* [Google Chrome](https://www.google.com/chrome/)
* [Google Docs](https://drive.google.com/drive/u/0/)
* [Google Sheets](https://docs.google.com/spreadsheets/u/0/)
* [Safari](https://support.apple.com/en_GB/downloads/safari)
* [Etsy Rank Subscription](https://etsyrank.com/)

## Instructions ##
1. Open [Google Chrome](https://www.google.com/chrome/)
2. Copy this [Google Sheet Template](https://docs.google.com/spreadsheets/d/1ZDJKoymIh9q4jmGtZfIlgbDnPqC5GbD9R7mas2KFfBk/edit#gid=2085843151) to your Google Drive: 
3. Type or paste your keywords into the first column "Keywords."
4. Open [Safari](https://support.apple.com/en_GB/downloads/safari) and [Login to your Etsy Rank account.](https://etsyrank.com/)
5. In your [Google Sheets](https://docs.google.com/spreadsheets/u/0/) document, select the keyword cell you wish to start your script.
6. Run "etsy-rank-scraper.app"
7. Step away from the computer and let it run! :)

# Contact #
Any questions or bugs (for now) can be sent to me, Nico via email: nicokillips@gmail.com