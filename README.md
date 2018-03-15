# README #
"Etsy Rank Keyword Scraper" is designed to help in gathering Etsy keyword data. It does all the manual work of copying and pasting keyword data from Etsy Rank into a Google Sheets spreadsheet.

# Version #
* Etsy Rank Keyword Scraper
* 1.1.0

# What does it do? #
This app automates the process of retrieving keyword data from Etsy Rank from a premade list. You will need to compile a list of keywords and put them into the first column of your Google Sheets spreadsheet (described below.)

**Note:** *This app currently uses "activate" to toggle applications and function properly. When running this, any interruption will cause the app to crash or not record the data properly. Let the app collect data and do not use your computer while running.*

# How it Works #
1. The app selects the first cell of your Google Spreadsheet in Google Chrome.
2. Copies the keyword.
3. Switches over to Safari.
4. Finds the search input in the DOM and pastes the clipboard.
5. Runs the Javascript function that executes the search.
6. The app waits for the content to be loaded and uses logic for:
* Checking that the contents are completed loaded
* Checking that Etsy Rank returns results of the keyword search
* If no results are returned, the app goes back to the Google Sheet, records "no results found" in the cell and moves down to the next row and loops.
7. Finds the DOM elements that contain the keyword data on the page and stores them as variables.
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

8. Switches over to Chrome and pastes the values across the row of your Google Sheet.
9. Arrows down to the next row, then hits the "Home" keystroke to go back to the first cell of the row.

# Setup #
** You will need MacOS 10.11+ ** and few apps running in order for "Etsy Rank Keyword Scraper" to work. See dependencies below.

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
Any questions or bugs (for now) can be sent to Nico via email: nicokillips@gmail.com