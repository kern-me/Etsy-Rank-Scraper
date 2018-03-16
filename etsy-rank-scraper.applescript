-- Properties

property selectorPathScores : "btn btn-lg text-white"
property selectorPathStats : "amount"
property searchButtonPath : "btn btn-flat btn-warning"

property defaultKeyDelay : 0.2
property defaultDelayValue : 0.75
property browserTimeoutValue : 60

-- ========================================
-- Copy the first cell of the spreadsheet
-- ========================================
on copyData() -- Copy the first cell of data
	tell application "System Events"
		delay defaultDelayValue
		log "Copy the first cell."
		keystroke "c" using command down
		delay defaultDelayValue
		log "Arrow to the right."
		key code 124 -- Arrow Right
		delay defaultDelayValue
		log "First cell of Google Sheets is Copied!"
	end tell
end copyData

-- ========================================
-- Paste the clipboard and right arrow
-- ========================================
on pasteValues()
	tell application "System Events"
		delay defaultDelayValue
		log "Pasting the clipboard"
		keystroke "v" using command down
		delay defaultDelayValue
		log "Arrow right"
		key code 124 -- Arrow Right
		delay defaultDelayValue
	end tell
end pasteValues

-- =======================================
-- Make a new row in Google Sheets
-- =======================================
on nextRow()
	tell application "System Events"
		delay defaultDelayValue
		key code 125 -- Arrow Down
		log "Arrow Down"
		delay defaultDelayValue
		key code 115 -- Back to the First Cell
		log "Home Key to go back to the first cell of next row"
		delay defaultDelayValue
	end tell
end nextRow

-- ========================================
-- Find the Etsy Rank search bar in the DOM
-- and paste the clipboard
-- ========================================
on clickSearchButton()
	tell application "Safari"
		tell application "Safari" to activate
		do JavaScript "document.getElementsByClassName('" & searchButtonPath & "')[0].click(); " in document 1
	end tell
end clickSearchButton

on setSearchField()
	tell application "Safari"
		-- Set the search value to the clipboard
		tell application "Safari" to activate
		delay 1
		set theNode to do JavaScript "document.getElementsByName('keywords')[0].value ='" & (the clipboard) & "'; " in document 1
		delay 1
		log "Found the node."
		log theNode
		
	end tell
end setSearchField

-- =======================================
-- Grab data from specific IDs in the DOM
-- =======================================
on getInputByClass(theClass, theInstance)
	tell application "Safari"
		delay defaultDelayValue
		log "Find the DOM node"
		set input to do JavaScript "document.getElementsByClassName('" & theClass & "')[" & theInstance & "].innerText;" in document 1
		delay defaultDelayValue
		return input
	end tell
end getInputByClass

-- =======================================
-- Check the browser to make sure the DOM
-- is loaded
-- =======================================
on checkIfLoaded()
	set browserTimeoutValue to 60
	tell application "Safari"
		delay 1
		repeat with i from 1 to the browserTimeoutValue
			tell application "Safari"
				delay 1
				log " +++ Checking if still loading. +++ "
				-- Select the input value to check against the clipboard
				set firstSearchInput to (do JavaScript "document.getElementsByName('keywords')[0].value" in document 1)
				set secondSearchInput to (do JavaScript "document.getElementsByName('keywords')[1].value" in document 1)
				set secondSearchInputLength to (do JavaScript "document.getElementsByName('keywords')[1].value.length" in document 1)
				delay 1
				if secondSearchInput = (the clipboard) then
					log "Loaded!"
					return
				else if i is the browserTimeoutValue then
					return "Timed out! Stopping."
				else
					log "Not Loaded..."
				end if
			end tell
		end repeat
	end tell
end checkIfLoaded

-- =======================================
-- Check if the keyword is found
-- =======================================
on checkKeyword()
	tell application "Safari"
		log "Checking if there are results for the keyword."
		set noResultsCheck to (do JavaScript "document.getElementsByClassName('alert')[0].innerText" in document 1)
		if noResultsCheck is "No results found for that search term." then
			log "No Results Were Found."
			return "no results"
		else
			log "Results are found! Let's keep going."
			return "results"
		end if
		return
	end tell
end checkKeyword


-- =======================================
-- Get the Etsy Data
-- =======================================

on getData()
	progressDialog("Gathering the Data! (Competition Score) Step: 5/5 ")
	set competition to getInputByClass(selectorPathScores, 0)
	
	progressDialog("Gathering the Data! (Demand Score) Step: 5/5 ")
	set demand to getInputByClass(selectorPathScores, 1)
	
	progressDialog("Gathering the Data! (Engagement Score) Step: 5/5 ")
	set engagement to getInputByClass(selectorPathScores, 2)
	
	progressDialog("Gathering the Data! (Listings) Step: 5/5 ")
	set listings to getInputByClass(selectorPathStats, 0)
	
	progressDialog("Gathering the Data! (Average Price) Step: 5/5 ")
	set avgPrice to getInputByClass(selectorPathStats, 2)
	
	progressDialog("Gathering the Data! (Average Hearts) Step: 5/5 ")
	set avgHearts to getInputByClass(selectorPathStats, 3)
	
	progressDialog("Gathering the Data! (Total Views) Step: 5/5 ")
	set totalViews to getInputByClass(selectorPathStats, 4)
	
	progressDialog("Gathering the Data! (Average Views) Step: 5/5 ")
	set avgViews to getInputByClass(selectorPathStats, 5)
	
	progressDialog("Gathering the Data! (Average Daily Views) Step: 5/5 ")
	set avgDailyViews to getInputByClass(selectorPathStats, 6)
	
	progressDialog("Gathering the Data! (Average Weekly Views) Step: 5/5 ")
	set avgWeeklyViews to getInputByClass(selectorPathStats, 7)
	
	tell application "Google Chrome" to activate
	-- Set clipboard to each variable and paste them into the spreadsheet
	
	progressDialog("Pasting the values into Google Sheets! Step: 5/5 ")
	script finalizeData
		on recordTheData(theData)
			delay defaultDelayValue
			set the clipboard to theData
			delay defaultDelayValue
			pasteValues()
		end recordTheData
		
		
		recordTheData(competition)
		recordTheData(demand)
		recordTheData(engagement)
		recordTheData(listings)
		recordTheData(avgPrice)
		recordTheData(avgHearts)
		recordTheData(totalViews)
		recordTheData(avgViews)
		recordTheData(avgDailyViews)
		recordTheData(avgWeeklyViews)
	end script
	
	run script finalizeData
	delay defaultDelayValue
	progressDialog("Done! On to the next keyword. Step: 5/5 ")
	nextRow()
	delay defaultDelayValue
end getData

-- =======================================
-- Primary Sequence Handler
-- =======================================
on progressDialog(theMessage)
	set progress description to theMessage
end progressDialog


on grabDataFromList()
	set repeatCount to display dialog "How many keywords do you need?" default answer ""
	set countValue to text returned of repeatCount as number
	repeat countValue times
		log "Step 1/5"
		progressDialog("Copying the first keyword. Step 1/5")
		tell application "Google Chrome" to activate
		copyData()
		log "Step 2/5"
		tell application "Safari" to activate
		progressDialog("Pasting the Keyword into the search. Step 2/5")
		setSearchField()
		progressDialog("Executing the search. Step 3/5")
		clickSearchButton()
		log "Step 3/5"
		progressDialog("Checking to make sure the page is loaded completely. Step 4/5")
		checkIfLoaded()
		log "Step 4/5"
		progressDialog("Checking to make sure the keyword is found on Etsy. Step 5/5")
		if checkKeyword() is "no results" then
			log "No results were found. going back to step 1..."
			progressDialog("No results for that keyword! Going to the next row.")
			tell application "Google Chrome" to activate
			set the clipboard to "No Results Found"
			pasteValues()
			nextRow()
		else
			log "Step 5/5"
			progressDialog("Gathering the Data! 5/5 ")
			getData()
		end if
	end repeat
end grabDataFromList

-- =======================================
-- Handler Calls
-- =======================================
grabDataFromList()

