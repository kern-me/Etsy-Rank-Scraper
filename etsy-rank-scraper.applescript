-- Properties
set AppleScript's text item delimiters to ","

property fileName : "Etsy Rank Keyword Data.csv"

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

-- App Activate
on activateApp(theApp)
	tell application theApp to activate
	log "activate '" & theApp & "'"
end activateApp

-- Progress Dialog
on progressDialog(theMessage)
	set progress description to theMessage
end progressDialog

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



#
## FILE READING AND WRITING
#

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
	set theFile to (((path to desktop folder) as string) & fileName)
	writeTextToFile(this_Story, theFile, writable)
end writeFile

#
## DOM SETTING
#


-- Set Value to a Node
on setNodeValue(theFunction, theSelector, theInstance, theValue)
	tell application "Safari"
		try
			set theNode to do JavaScript "document." & theFunction & "('" & theSelector & "')[" & theInstance & "].value ='" & theValue & "'; " in document 1
			return theNode
		on error
			return false
		end try
	end tell
end setNodeValue

-- Interact with the DOM
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

-- Click Login Button
on clickLogin()
	log "clickLogin()"
	domEvent("Clicking the Login Button", "querySelectorAll", nodeLoginSubmit, 0, "click")
end clickLogin

-- Click the Keyword Button
on clickKeywordButton()
	log "clickKeywordButton()"
	domEvent("Clicking the Keyword Button", "querySelectorAll", nodeKeywordBtn, 0, "click")
end clickKeywordButton

-- Click the Search Button
on clickSearchButton()
	log "clickSearchButton()"
	domEvent("Clicking the Search Button", "getElementsByClassName", searchButtonPath, 0, "click")
end clickSearchButton

-- Set the Search Field
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

-- Clear Search Fields
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


#
## CHECK STATUSES
#

-- Check if Logged In
on checkLogin()
	log "checkLogin()"
	tell application "Safari"
		delay systemDelay
		
		set doJS to "document.getElementsByTagName('h3')[0].innerText;"
		
		try
			set findLogin to (do JavaScript doJS in document 1)
			
			set loginMsg to "Please Log In"
			
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


-- Check Initial Load
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


-- Check Login Status
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


#
## ETSY DATA GATHERING
#

property headers : "Keyword, Competition, Demand, Engagement, Listings Found, Listings Analyzed, Average Price, Average Hearts, Total Views, Avg. Views, Avg. Daily Views, Avg. Weekly Views"

property selectorPathScores : "btn btn-lg text-white"
property selectorPathStats : "amount"
property selectorRelatedTags : "getElementById('demo').getElementsByTagName"
property delim : ","


-- Get the stats from the DOM
on getStat(method, selector, instance, method2)
	logIt("getStat()")
	tell application "Safari"
		set input to do JavaScript "document." & method & "('" & selector & "')[" & instance & "]." & method2 & "." & stripCommas & ";" in document 1
		return input
	end tell
end getStat

-- Main Loop Data
on getDataLoop(method, selector, instance, method2, errorMsg, format)
	set theCount to instance
	set theList to {}
	set itemCounter to 0
	
	repeat
		set updatedCount to (theCount + 1)
		log "the updatedCount is " & updatedCount & ""
		
		try
			set rowData to getStat(method, selector, updatedCount, method2)
			set theList to theList & {rowData}
			log "add " & rowData & " to theList"
			log "theList = " & theList & ""
			set theCount to theCount + 1
			
		on error
			log "End of the List"
			exit repeat
		end try
	end repeat
	
	return theList
	
end getDataLoop

-- Handler for Both Tag Data Loops
on getTagData()
	set theList to {}
	set scores to getDataLoop(byClassName, selectorPathScores, -1, innerText, "Error.", 0)
	set stats to getDataLoop(byClassName, selectorPathStats, -1, innerText, "Error.", 0)
	set theList to theList & {scores, stats}
	return theList
end getTagData


-- Handler for Related Tag Loop
on getRelatedTags()
	set theList to {}
	set text item delimiters to "
"
	set relatedTags to getDataLoop(selectorRelatedTags, "a", -1, innerText, "Error.", 1)
	set theList to theList & {relatedTags}
	return theList as list
end getRelatedTags

-- Insert item into a list
on insertItemInList(theItem, theList, thePosition)
	set theListCount to length of theList
	if thePosition is 0 then
		return false
	else if thePosition is less than 0 then
		if (thePosition * -1) is greater than theListCount + 1 then return false
	else
		if thePosition is greater than theListCount + 1 then return false
	end if
	if thePosition is less than 0 then
		if (thePosition * -1) is theListCount + 1 then
			set beginning of theList to theItem
		else
			set theList to reverse of theList
			set thePosition to (thePosition * -1)
			if thePosition is 1 then
				set beginning of theList to theItem
			else if thePosition is (theListCount + 1) then
				set end of theList to theItem
			else
				set theList to (items 1 thru (thePosition - 1) of theList) & theItem & (items thePosition thru -1 of theList)
			end if
			set theList to reverse of theList
		end if
	else
		if thePosition is 1 then
			set beginning of theList to theItem
		else if thePosition is (theListCount + 1) then
			set end of theList to theItem
		else
			set theList to (items 1 thru (thePosition - 1) of theList) & theItem & (items thePosition thru -1 of theList)
		end if
	end if
	return theList
end insertItemInList

-- Main Routine

on mainRoutine()
	set currentKeyword to setSearchField(userKeyword())
	clickSearchButton()
	checkIfLoaded()
	
	writeFile(headers & newLine & currentKeyword & delim & getTagData() & newLine & " " & newLine & "Related Tags to " & "'" & currentKeyword & "'" & newLine & getRelatedTags() & newLine, false) as text
	
	userPrompt("Finished!")
end mainRoutine

#
## Calls
#


mainRoutine()
#searchRelatedTags()
#newSearchRelatedTags()


