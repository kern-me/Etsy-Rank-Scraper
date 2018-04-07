-- Properties
set AppleScript's text item delimiters to ","

property selectorPathScores : "btn btn-lg text-white"
property selectorPathStats : "amount"
property searchButtonPath : "btn btn-flat btn-warning"

property systemDelay : 0.5
property defaultKeyDelay : 0.2
property defaultDelayValue : 0.75
property browserTimeoutValue : 60

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

property byId : "getElementById"
property byClassName : "getElementsByClassName"
property byTagName : "getElementsByTagName"
property byName : "getElementsByName"
property innerHTML : "innerHTML"
property innerText : "innerText"
property value : "value"
property stripCommas : "replace(',','')"
property stripK : "replace('k','000')"
property splitDashes : "split(' - ',1)"

property chrome : "Google Chrome"
property safari : "Safari"

property currentKeyword : ""

property newLine : "
"

-- Log Dividers
on logIt(content)
	log "------------------------------------------------"
	log content
	log "------------------------------------------------"
end logIt


on userPrompt(theText)
	logIt("userPrompt()")
	activate
	display dialog theText
end userPrompt

on userPrompt2Buttons(theText, buttonText1, buttonText2)
	logIt("userPrompt()")
	activate
	display dialog theText buttons {buttonText1, buttonText2}
end userPrompt2Buttons


-- Reading and Writing Params
on writeTextToFile(theText, theFile, overwriteExistingContent)
	logIt("writeTextToFile()")
	try
		
		set theFile to theFile as string
		set theOpenedFile to open for access file theFile with write permission
		
		if overwriteExistingContent is true then set eof of theOpenedFile to 0
		write theText to theOpenedFile starting at eof
		close access theOpenedFile
		
		return true
	on error
		try
			close access file theFile
		end try
		
		return false
	end try
end writeTextToFile


-- Write to file
on writeFile(theContent, writable)
	logIt("writeFile()")
	set this_Story to theContent
	set theFile to (((path to desktop folder) as string) & "Etsy Rank Keyword Data.csv")
	writeTextToFile(this_Story, theFile, writable)
end writeFile


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
-- Progress Dialog
-- ========================================
on progressDialog(theMessage)
	set progress description to theMessage
end progressDialog



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

-- Get the stats from the DOM
on getStat(selector, instance)
	logIt("getStat()")
	tell application "Safari"
		set input to do JavaScript "document.getElementsByClassName('" & selector & "')[" & instance & "].innerText." & stripCommas & ";" in document 1
		return input
	end tell
end getStat



-- Check the browser for DOM loaded completely
on checkIfLoaded()
	log "checkIfLoaded()"
	progressDialog("Checking to make sure the page is loaded completely.")
	tell application "Safari"
		try
			repeat
				set doJS to "document.getElementsByName('keywords')[1].value"
				set secondSearchInput to (do JavaScript doJS in document 1)
				delay systemDelay
				
				if secondSearchInput = currentKeyword then
					log loadSuccess
					delay systemDelay
					exit repeat
				end if
				delay systemDelay
			end repeat
			delay systemDelay
		end try
	end tell
end checkIfLoaded

on domEvent(theDialog, theMethod, theNode, theInstance, endMethod)
	progressDialog(theDialog)
	delay systemDelay
	tell application "Safari"
		try
			set doJS to "document." & theMethod & "('" & theNode & "')[" & theInstance & "]." & endMethod & "()"
			do JavaScript doJS in document 1
		on error
			log errorMsg
		end try
	end tell
end domEvent


-- ========================================
-- Click Login Button
-- ========================================
on clickLogin()
	log "clickLogin()"
	domEvent("Clicking the Login Button", "querySelectorAll", nodeLoginSubmit, 0, "click")
end clickLogin


-- ========================================
-- Click the Keyword Button
-- ========================================
on clickKeywordButton()
	log "clickKeywordButton()"
	domEvent("Clicking the Keyword Button", "querySelectorAll", nodeKeywordBtn, 0, "click")
end clickKeywordButton

-- ========================================
-- Click the Search Button
-- ========================================
on clickSearchButton()
	log "clickSearchButton()"
	domEvent("Clicking the Search Button", "getElementsByClassName", searchButtonPath, 0, "click")
end clickSearchButton

-- ========================================
-- Set the Search Field
-- ========================================
on setSearchField(theValue)
	log "setSearchField()"
	setNodeValue("getElementsByName", "keywords", 0, theValue)
end setSearchField

on userKeyword()
	set theKeyword to display dialog "Enter a keyword" default answer ""
	set keyword to text returned of theKeyword as text
	set firstKeyword to keyword
	return keyword as text
end userKeyword


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
				log "checkLogin() === " & loggedOut & ""
				return loggedOut
			else
				log "checkLogin() === " & loggedIn & ""
				return loggedIn
			end if
			
		on error
			log "checkLogin() === " & loggedOut & " (Error)"
			return loggedOut
		end try
		
		delay systemDelay
	end tell
end checkLogin

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
					log "initLoad() = success"
					log "theCheck === 'keywords'"
					return loadSuccess
					exit repeat
					delay systemDelay
				else
					log "initLoad() = " & loadFail & ""
					delay systemDelay
				end if
				delay systemDelay
			on error
				log "initLoad() = " & loadFail & " (error)"
				log "Error"
			end try
		end repeat
		delay systemDelay
	end tell
end initLoad

-- =======================================
-- Check Login Status
-- =======================================
on checkLoginStatus()
	log "checkLoginStatus()"
	
	progressDialog("Checking to see if you're logged in...")
	
	if checkLogin() is loggedOut then
		log "loginStatus = " & loginStatus & ""
		
		clickLogin()
		
		repeat
			set initLoadStatus to initLoad()
			log initLoadStatus
			
			if initLoadStatus is loadSuccess then
				log "initLoadStatus == " & loadSuccess & ""
				exit repeat
			else
				log "initLoadStatus == " & loadFail & ""
			end if
			
		end repeat
	end if
	return true
end checkLoginStatus

-- =======================================
-- Clear Search Fields
-- =======================================
on clearSearchFields()
	log "clearSearchFields()"
	
	try
		setNodeValue("getElementsByName", "keywords", 0, "")
		delay systemDelay
	on error
		log errorMsg
	end try
	
	try
		setNodeValue("getElementsByName", "keywords", 1, "")
		delay systemDelay
	on error
		log errorMsg
	end try
	
	log "clearSearchFields() = complete"
end clearSearchFields

-- =======================================
-- Get all the Etsy Data
-- =======================================
property headers : "Keyword, Competition, Demand, Engagement, Listings Found, Listings Analyzed, Average Price, Average Hearts, Total Views, Avg. Views, Avg. Daily Views, Avg. Weekly Views"

on theDataLoop()
	
	set theCount to -1
	
	repeat 3 times
		set updatedCount to (theCount + 1)
		set rowData to getStat(selectorPathScores, updatedCount)
		
		if rowData is false then
			log "No Results Found"
			set theCount to -1
			writeFile(currentKeyword & "," & "No Results" & newLine, false) as text
			return false
		end if
		
		set theCount to theCount + 1
		
		writeFile(rowData & ",", false) as text
	end repeat
	
	set theCount to -1
	
	repeat 8 times
		set updatedCount to (theCount + 1)
		set rowData to getStat(selectorPathStats, updatedCount)
		set theCount to theCount + 1
		writeFile(rowData & ",", false) as text
	end repeat
	
	writeFile(newLine, false) as text
	
end theDataLoop

#
## Calls
#

writeFile(headers & newLine, false) as text
repeat
	set currentKeyword to setSearchField(userKeyword())
	
	writeFile(currentKeyword & ",", false) as text
	
	clickSearchButton()
	
	checkIfLoaded()
	
	if theDataLoop() is false then
		exit repeat
	end if
end repeat



