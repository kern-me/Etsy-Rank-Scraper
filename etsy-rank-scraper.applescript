-- Properties

property selectorPathScores : "btn btn-lg text-white"
property selectorPathStats : "amount"
property searchButtonPath : "btn btn-flat btn-warning"

property systemDelay : 0.5
property defaultKeyDelay : 0.2
property defaultDelayValue : 0.75
property browserTimeoutValue : 60

property keyRight : 124
property keyDown : 125
property keyHome : 115
property keyEnter : 36

property noResultsMessage : "No results found for that search term."
property loginButtonHomePath : "document.getElementsByTagName('button')[1]"
property nodeKeywordBtn : "[href=\"/keyword-tool\"]"
property nodeLoginSubmit : "[type=\"submit\"]"


property loadSuccess : "Loaded."
property loadFail : "Not Loaded."
property loggedOut : "Logged Out."
property loggedIn : "Logged In"
property errorMsg : "Error."
property timeoutMsg : "Timed Out."
property noResults : "No Results."
property results : "Results."
property noString : "No string in the clipboard."

property chrome : "Google Chrome"
property safari : "Safari"

property pasteIt : "v"
property copyIt : "c"

-- ========================================
-- Refresh Browser
-- ========================================
on refresh(theApp)
	tell application "Safari"
		set docUrl to URL of document 1
		set URL of document 1 to docUrl
	end tell
end refresh

-- ========================================
-- App Activate
-- ========================================
on activateApp(theApp)
	tell application theApp to activate
	log "activate '" & theApp & "'"
end activateApp

-- ========================================
-- Set the Clipboard
-- ========================================
on setClipboard(theClip)
	log "setClipboard()"
	delay systemDelay
	set the clipboard to theClip
	delay systemDelay
end setClipboard

-- ========================================
-- Progress Dialog
-- ========================================
on progressDialog(theMessage)
	set progress description to theMessage
end progressDialog

-- ========================================
-- Key Strokes
-- ========================================

on clipBoardActions(theKeystroke)
	log "clipBoardActions()"
	tell application "System Events"
		delay defaultKeyDelay
		if theKeystroke is keyHome then
			key code theKeystroke
		else if theKeystroke is pasteIt then
			keystroke theKeystroke using command down
		else if theKeystroke is copyIt then
			keystroke theKeystroke using command down
		else
			keystroke theKeystroke using command down
		end if
		delay defaultKeyDelay
	end tell
end clipBoardActions

on movementAction(theKeystroke)
	log "movementAction()"
	tell application "System Events"
		delay defaultKeyDelay
		key code theKeystroke
		delay defaultKeyDelay
	end tell
end movementAction

-- ========================================
-- DOM Events
-- ========================================
on domEvent(theDialog, theMethod, theNode, theInstance, endMethod)
	delay systemDelay
	progressDialog(theDialog)
	delay systemDelay
	activateApp(safari)
	delay systemDelay
	tell application "Safari"
		try
			set doJS to "document." & theMethod & "('" & theNode & "')[" & theInstance & "]." & endMethod & "()"
			do JavaScript doJS in document 1
			delay systemDelay
		on error
			log errorMsg
		end try
		delay systemDelay
	end tell
end domEvent


-- ========================================
-- Check Initial Load
-- ========================================
on initLoad()
	log "initLoad()"
	tell application "Safari"
		repeat
			try
				delay systemDelay
				set doJS to "document.getElementsByName('keywords')[0].name;"
				delay systemDelay
				set theCheck to (do JavaScript doJS in document 1)
				delay systemDelay
				if theCheck is "keywords" then
					return loadSuccess
				else
					return loadFail
				end if
				delay systemDelay
			on error
				log "Error"
			end try
		end repeat
		delay systemDelay
	end tell
end initLoad

-- ========================================
-- Strip ASCII Characters
-- ========================================
on RemoveFromString(theText, CharOrString)
	log "RemoveFromString(x,y)"
	delay systemDelay
	local ASTID, theText, CharOrString, lst
	set ASTID to AppleScript's text item delimiters
	try
		delay systemDelay
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
	delay systemDelay
end RemoveFromString

-- ========================================
-- Set Value to a Node
-- ========================================
on setNodeValue(theFunction, theSelector, theInstance, theValue)
	activateApp(safari)
	tell application "Safari"
		try
			delay systemDelay
			
			set theNode to do JavaScript "document." & theFunction & "('" & theSelector & "')[" & theInstance & "].value ='" & theValue & "'; " in document 1
			return theNode
		on error
			return false
		end try
		delay systemDelay
	end tell
end setNodeValue

-- =======================================
-- Grab data from the DOM
-- =======================================
on getInputByClass(theClass, theInstance)
	tell application "Safari"
		delay systemDelay
		try
			delay systemDelay
			set input to (do JavaScript "document.getElementsByClassName('" & theClass & "')[" & theInstance & "].innerText;" in document 1)
			delay systemDelay
			return input
		on error
			return noResults
			log noResults
		end try
	end tell
	delay systemDelay
end getInputByClass

-- =======================================
-- Check Clipboard
-- =======================================
on checkClipboard()
	log "checkClipboard()"
	tell application "System Events"
		delay systemDelay
		set theValue to (the clipboard)
		delay systemDelay
		if theValue contains text then
			return true
		else
			return false
		end if
		delay systemDelay
	end tell
end checkClipboard

-- =======================================
-- Check the browser for DOM loaded completely
-- =======================================

on checkIfLoaded()
	log "checkIfLoaded()"
	progressDialog("Checking to make sure the page is loaded completely.")
	tell application "Safari"
		try
			repeat
				set doJS to "document.getElementsByName('keywords')[1].value"
				set secondSearchInput to (do JavaScript doJS in document 1)
				delay systemDelay
				
				if secondSearchInput = (the clipboard) then
					exit repeat
					log loadSuccess
				end if
				
				delay systemDelay
			end repeat
			delay systemDelay
		end try
	end tell
end checkIfLoaded

-- =======================================
-- Check if the search returns results
-- =======================================
on checkForResults()
	log "checkForResults()"
	tell application "Safari"
		try
			delay systemDelay
			set doJS to "document.getElementsByClassName('alert')[0].innerText"
			delay systemDelay
			
			set checkResults to (do JavaScript doJS in document 1)
			
			delay systemDelay
			
			if checkResults is noResultsMessage then
				return noResults
			else
				return results
			end if
			
		on error
			return results
		end try
		
		delay systemDelay
	end tell
end checkForResults

-- ========================================
-- Click Login Button
-- ========================================
on clickLogin()
	domEvent("Clicking the Login Button", "querySelectorAll", nodeLoginSubmit, 0, "click")
end clickLogin


-- ========================================
-- Click the Keyword Button
-- ========================================
on clickKeywordButton()
	domEvent("Clicking the Keyword Button", "querySelectorAll", nodeKeywordBtn, 0, "click")
end clickKeywordButton

-- ========================================
-- Click the Search Button
-- ========================================
on clickSearchButton()
	domEvent("Clicking the Search Button", "getElementsByClassName", searchButtonPath, 0, "click")
end clickSearchButton

-- ========================================
-- Set the Search Field
-- ========================================
on setSearchField()
	setNodeValue("getElementsByName", "keywords", 0, (the clipboard))
end setSearchField


-- ========================================
-- Check if Logged In
-- ========================================
on checkLogin()
	log "checkLogin()"
	tell application "Safari"
		delay systemDelay
		set doJS to "document.getElementsByTagName('h3')[0].innerText;"
		try
			delay systemDelay
			set findLogin to (do JavaScript doJS in document 1)
			set loginMsg to "Please Log In"
			delay systemDelay
			if findLogin is loginMsg then
				return loggedOut
			else
				return loggedIn
			end if
		on error
			return loggedOut
		end try
		delay systemDelay
	end tell
end checkLogin




-- =======================================
-- Check Login Status
-- =======================================
on checkLoginStatus()
	log "checkLoginStatus()"
	progressDialog("Checking to see if you're logged in...")
	delay systemDelay
	set loginStatus to checkLogin()
	log loginStatus
	
	delay systemDelay
	
	if loginStatus is loggedOut then
		log loginStatus
		clickLogin()
		set repeatCount to 1
		repeat repeatCount times
			delay systemDelay
			set initLoadStatus to initLoad()
			log initLoadStatus
			
			if initLoadStatus is loadSuccess then
				log initLoadStatus
				log loadSuccess
				set repeatCount to 0
			else
				set repeatCount to 1
			end if
			
			delay systemDelay
		end repeat
		
	else if loginStatus is loggedIn then
		log loggedIn
		delay systemDelay
		
	end if
	delay systemDelay
end checkLoginStatus



-- =======================================
-- Clear Search Fields
-- =======================================
on clearSearchFields()
	log "clearSearchFields()"
	delay systemDelay
	try
		setNodeValue("getElementsByName", "keywords", 0, "")
		delay systemDelay
	on error
		log errorMsg
	end try
	delay systemDelay
	try
		setNodeValue("getElementsByName", "keywords", 1, "")
		delay systemDelay
	on error
		log errorMsg
	end try
	delay systemDelay
end clearSearchFields

-- =======================================
-- Process: Next Row
-- =======================================
on nextRow()
	log "nextRow()"
	activateApp(chrome)
	setClipboard("No Results.")
	clipBoardActions(pasteIt)
	movementAction(keyDown)
	movementAction(keyHome)
end nextRow

-- =======================================
-- Process: Copy Tag
-- =======================================
on copyTag()
	log "copyTag()"
	setClipboard("")
	activateApp(chrome)
	movementAction(keyHome)
	clipBoardActions(copyIt)
	movementAction(keyRight)
end copyTag

-- =======================================
-- Process: Paste 'No Results'
-- =======================================

on pasteNoResults()
	log "pasteNoResults()"
	progressDialog("No results. Pasting 'No Results' into Google Sheets")
	setClipboard("No Results.")
	activateApp(chrome)
	clipBoardActions(pasteIt)
	movementAction(keyDown)
	movementAction(keyHome)
end pasteNoResults

-- =======================================
-- Get all the Etsy Data
-- =======================================

on getData()
	log "getData()"
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
	
	activateApp(chrome)
	
	progressDialog("Pasting the values into Google Sheets!")
	
	script finalizeData
		on recordTheData(theData)
			delay systemDelay
			setClipboard(theData)
			delay systemDelay
			clipBoardActions(pasteIt)
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
	log "run script finalizeData"
	
	progressDialog("Done! On to the next keyword. Step: 5/5 ")
	movementAction(keyDown)
	movementAction(keyHome)
end getData

-- =======================================
-- =======================================
-- Primary Sequence
-- =======================================
-- =======================================
script grabDataFromList
	set repeatCount to display dialog "How many keywords do you need?" default answer ""
	set countValue to text returned of repeatCount as number
	clearSearchFields()
	
	repeat countValue times
		copyTag()
		if setSearchField() is false then
			pasteNoResults()
		else
			clickSearchButton()
			checkIfLoaded()
			checkLoginStatus()
			
			if checkForResults() is noResults then
				pasteNoResults()
			else
				getData()
			end if
		end if
	end repeat
		
	progressDialog("All done! :D ")
end script

-- =======================================
-- Calls
-- =======================================
run grabDataFromList

