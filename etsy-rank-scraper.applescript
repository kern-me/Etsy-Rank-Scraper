-- Properties

property selectorPathScores : "btn btn-lg text-white"
property selectorPathStats : "amount"
property searchButtonPath : "btn btn-flat btn-warning"

property defaultKeyDelay : 0.2
property defaultDelayValue : 0.75
property browserTimeoutValue : 60

property keyRight : 124
property keyDown : 125
property keyHome : 115
property keyEnter : 36

on setClipboard(theClip)
	set the clipboard to theClip
end setClipboard


-- ========================================
-- Progress Dialog Handler
-- ========================================
on progressDialog(theMessage)
	set progress description to theMessage
end progressDialog

-- ========================================
-- Key Stroke Handlers
-- ========================================
on clipBoardActions(theKeystroke)
	tell application "System Events"
		delay defaultKeyDelay
		keystroke theKeystroke using command down
		delay defaultKeyDelay
	end tell
end clipBoardActions

on movementAction(theKeystroke)
	tell application "System Events"
		delay defaultKeyDelay
		key code theKeystroke
		delay defaultKeyDelay
	end tell
end movementAction

-- ========================================
-- Check if Logged In
-- ========================================
property loginButtonHomePath : "document.getElementsByTagName('button')[1]"

on checkLogin()
	tell application "Safari"
		set findLogin to (do JavaScript "document.getElementsByTagName('button')[0].innerHTML; " in document 1)
		if findLogin is "LOGIN" then
			log "Need to login"
			do JavaScript "document.getElementsByTagName('button')[0].click(); " in document 1
		else if findLogin is "undefined" then
			return
		end if
	end tell
end checkLogin

-- ========================================
-- Ask for Credentials
-- ========================================
on gatherCredentials()
	tell application "Safari"
		set userName to display dialog "Your Etsy Rank Username?"
		set thePassword to display dialog "Your Etsy Rank Password?" with hidden answer
	end tell
end gatherCredentials

-- ========================================
-- Find and click the search button
-- ========================================

on clickSearchButton()
	tell application "Safari"
		tell application "Safari" to activate
		do JavaScript "document.getElementsByClassName('" & searchButtonPath & "')[0].click(); " in document 1
	end tell
end clickSearchButton

-- ========================================
-- Find the Search Bar in the DOM
-- ========================================
on RemoveFromString(theText, CharOrString)
	local ASTID, theText, CharOrString, lst
	set ASTID to AppleScript's text item delimiters
	try
		considering case
			if theText does not contain CharOrString then Â
				return theText
			set AppleScript's text item delimiters to CharOrString
			set lst to theText's text items
		end considering
		set AppleScript's text item delimiters to ASTID
		return lst as text
	on error eMsg number eNum
		set AppleScript's text item delimiters to ASTID
		error "Can't RemoveFromString: " & eMsg number eNum
	end try
end RemoveFromString

on setSearchField()
	tell application "Safari"
		-- Set the search value to the clipboard
		activate
		
		delay 1
		
		set theNode to do JavaScript "document.getElementsByName('keywords')[0].value ='" & (the clipboard) & "'; " in document 1
		return theNode
		delay 1
	end tell
end setSearchField

on doSearchField(theValue, theTarget)
	tell application "Safari"
		activate
		delay 1
		set theNode to do JavaScript "document.getElementsByName('keywords')[" & theTarget & "].value ='" & theValue & "'; " in document 1
		return theNode
		delay 1
	end tell
end doSearchField



-- =======================================
-- Grab data from the DOM
-- =======================================

on getInputByClass(theClass, theInstance)
	tell application "Safari"
		delay defaultDelayValue
		log "Find the DOM node"
		set input to (do JavaScript "document.getElementsByClassName('" & theClass & "')[" & theInstance & "].innerText;" in document 1)
		delay defaultDelayValue
		return input
	end tell
end getInputByClass

-- =======================================
-- Check the browser for DOM loaded completely
-- =======================================

on checkIfLoaded()
	set browserTimeoutValue to 60
	tell application "Safari"
		delay 1
		
		repeat with i from 1 to the browserTimeoutValue
			delay 0.5
			log "1. Check for existence of the second search input"
			set secondSearchInputLength to (do JavaScript "document.getElementsByName('keywords')[1].value.length" in document 1)
			
			log "2. Find the value of the second 'keywords' input"
			set secondSearchInput to (do JavaScript "document.getElementsByName('keywords')[1].value" in document 1)
			
			log "3. +++ Keyword Inputs are found and values are stored. +++ "
			
			log "4. Trying to see if the second search input is = to what we put in the clipboard. If it is, then the page has loaded."
			
			log "============================="
			log "====== Do these Match? ======"
			log secondSearchInput
			log (the clipboard)
			log "============================="
			
			-- EtsyRank's server doesn't seem to reliably return a correct DOM 'ready state' value, so we're using a visual cue as a condition to test for if the page has completely loaded. EtsyRank populates the search query into this second search input (labeled 'Keyword Tool') when the page has loaded, so we are using this as a visual cue.
			
			-- Checks to see if what we copied to the clipboard is the same as what is displayed in the second input field. This indicates that the page has completely loaded.
			delay 0.5
			if (secondSearchInput = (the clipboard)) then
				return
				log "YAY! They match! That means the page has loaded completely."
				log "+++ Loaded! +++"
			else if i is the browserTimeoutValue then
				return "Timed out! Stopping."
			else
				log "Not loaded... Restarting the check loop."
			end if
			delay 0.5
		end repeat
	end tell
end checkIfLoaded

-- =======================================
-- Check if the search returns results
-- =======================================
on checkKeyword()
	tell application "Safari"
		log "Checking to make sure the keyword is found on Etsy."
		set noResultsCheck to (do JavaScript "document.getElementsByTagName('button')[0].innerText" in document 1)
		
		if noResultsCheck is not "No results found for that search term" then
			log "Results are found! Let's keep going."
			return "results"
		else if noResultsCheck is "No results found for that search term." then
			log ("No Results!")
			return "no results"
		else
			log ("No Results!")
			return "no results"
		end if
		return
	end tell
end checkKeyword

-- =======================================
-- Get all the Etsy Data
-- =======================================

on getData()
	progressDialog("Gathering the Data! (Competition Score)")
	set competition to getInputByClass(selectorPathScores, 0)
	
	progressDialog("Gathering the Data! (Demand Score)")
	set demand to getInputByClass(selectorPathScores, 1)
	
	progressDialog("Gathering the Data! (Engagement Score)")
	set engagement to getInputByClass(selectorPathScores, 2)
	
	progressDialog("Gathering the Data! (Listings)")
	set listings to getInputByClass(selectorPathStats, 0)
	
	progressDialog("Gathering the Data! (Average Price)")
	set avgPrice to getInputByClass(selectorPathStats, 2)
	
	progressDialog("Gathering the Data! (Average Hearts)")
	set avgHearts to getInputByClass(selectorPathStats, 3)
	
	progressDialog("Gathering the Data! (Total Views)")
	set totalViews to getInputByClass(selectorPathStats, 4)
	
	progressDialog("Gathering the Data! (Average Views)")
	set avgViews to getInputByClass(selectorPathStats, 5)
	
	progressDialog("Gathering the Data! (Average Daily Views)")
	set avgDailyViews to getInputByClass(selectorPathStats, 6)
	
	progressDialog("Gathering the Data! (Average Weekly Views)")
	set avgWeeklyViews to getInputByClass(selectorPathStats, 7)
	
	tell application "Google Chrome" to activate
	-- Set clipboard to each variable and paste them into the spreadsheet
	
	progressDialog("Pasting the values into Google Sheets!")
	
	script finalizeData
		on recordTheData(theData)
			delay defaultDelayValue
			set the clipboard to theData
			delay defaultDelayValue
			
			clipBoardActions("v")
			movementAction(keyRight)
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
	
	movementAction(keyDown)
	movementAction(keyHome)
	delay defaultDelayValue
end getData


-- =======================================
-- Primary Sequence
-- =======================================

script grabDataFromList
	set repeatCount to display dialog "How many keywords do you need?" default answer ""
	set countValue to text returned of repeatCount as number
	log "Clipboard is set to be blank."
	log "Clear the search field in Safari"
	
	doSearchField("", 0)
	doSearchField("", 1)
	
	setClipboard(" ")
	
	repeat countValue times
		progressDialog("Checking to see if you're logged in...")
		log "+++ Login Check +++"
		checkLogin()
		
		log "+++ Activate Chrome +++"
		tell application "Google Chrome" to activate
		
		log "Go to the first column of the row."
		movementAction(keyHome)
		
		log "Copy the cell contents."
		clipBoardActions("c")
		
		log "Arrow right to prepare for pasting."
		movementAction(keyRight)
		
		tell application "Safari" to activate
		log "+++ Activate Safari +++"
		progressDialog("Pasting the Keyword into the search.")
		
		-- Strip non-numeric chars from string
		set the clipboard to RemoveFromString(the clipboard, "'")
		log "+++ Strip Desired Chars from String"
		
		log "+++ Search Field Actions +++"
		setSearchField()
		
		log "+++ Click the Search Button. +++"
		progressDialog("Executing the search.")
		clickSearchButton()
		
		progressDialog("Checking to make sure the page is loaded completely.")
		
		log "+++ Check if Loaded. +++"
		log "the clipboard contents:"
		log (the clipboard)
		checkIfLoaded()
		
		log "+++ Check Keyword Results +++"
		if checkKeyword() is "no results" then
			progressDialog("No results for that keyword! Going to the next row.")
			log "No results found for that keyword."
			
			tell application "Google Chrome" to activate
			log "Activate Chrome"
			
			setClipboard("No Results Found")
			log "Set clipboard to 'No Results Found'"
			
			clipBoardActions("v")
			log "Paste 'No Results Found' into the cell."
			movementAction(keyDown)
			log "Arrow Down"
			movementAction(keyHome)
			log "Home key back to the first cell."
		else
			progressDialog("Gathering the Data! 5/5 ")
			log "Gathering the Data!"
			getData()
		end if
	end repeat
	log "DONE!"
	progressDialog("All done! :D ")
end script

-- =======================================
-- Calls
-- =======================================
run grabDataFromList

