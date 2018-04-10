###############################################
## GLOBAL PROPERTIES
#
set AppleScript's text item delimiters to ","

property fileName : "Etsy Rank Keyword Data.csv"

property chrome : "Google Chrome"
property safari : "Safari"

property noResultsMessage : "No results found for that search term."
property loadSuccess : "Loaded."
property loadFail : "Not Loaded."
property loggedOut : "Logged Out."
property loggedIn : "Logged In"
property errorMsg : "Error."
property timeoutMsg : "Timed Out."
property noResults : "No Results."
property results : "Results."

property systemDelay : 0.5
property defaultKeyDelay : 0.2
property defaultDelayValue : 0.75
property browserTimeoutValue : 60

###############################################
## OBJECT PROPERTIES
#

property searchButtonPath : "btn btn-flat btn-warning"
property loginButtonHomePath : "document.getElementsByTagName('button')[1]"
property nodeKeywordBtn : "[href=\"/keyword-tool\"]"
property nodeLoginSubmit : "[type=\"submit\"]"
property headers : "Keyword, Competition, Demand, Engagement, Listings Found, Listings Analyzed, Average Price, Average Hearts, Total Views, Avg. Views, Avg. Daily Views, Avg. Weekly Views"

property selectorPathScores : "btn btn-lg text-white"
property selectorPathStats : "amount"
property selectorRelatedTags : "getElementById('demo').getElementsByTagName"

property csvDivider : "-,-,-,-,-,-,-,-,-,-,-,-"

property delim : ","

###############################################
## JAVASCRIPT PROPERTIES
#

property byId : "getElementById"
property byClassName : "getElementsByClassName"
property byTagName : "getElementsByTagName"
property byName : "getElementsByName"
property innerHTML : "innerHTML"
property innerText : "innerText"
property value : "value"
property stripCommas : "replace(/,/g,'')"
property splitDashes : "split(' - ',1)"

property currentKeyword : ""

property newLine : "
"

###############################################
## LOGGING/SYSTEM HANDLERS
#

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

###############################################
## UI HANDLERS
#

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
	display dialog theText buttons {buttonText1, buttonText2} default button buttonText2
	if button returned of result = buttonText1 then
		return false
	else if button returned of result = buttonText2 then
		return true
	end if
end userPrompt2Buttons

on userPromptMain(theTitle, theText, buttonText1, buttonText2, buttonText3)
	logIt("userPrompt()")
	activate
	try
		set theDialog to display dialog theText with title theTitle buttons {buttonText1, buttonText2, buttonText3} default button 3 with icon note
		
		if button returned of theDialog = buttonText1 then
			return "answer1"
		else if button returned of theDialog = buttonText2 then
			return "answer2"
		else if button returned of theDialog = buttonText3 then
			return "answer3"
		else if button returned of theDialog = buttonText4 then
			return false
		end if
	on error error_text
		display dialog error_text buttons {"Quit"} with icon stop
	end try
end userPromptMain

###############################################
## LIST HANDLING
#
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

###############################################
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

-- Open a File
on openFile(theFile, theApp)
	tell application "Finder"
		open file ((path to desktop folder as text) & theFile) using ((path to applications folder as text) & theApp)
	end tell
end openFile

-- Write Headers
on writeHeaders()
	writeFile(headers & newLine, false)
end writeHeaders



on writeDivider()
	writeFile(csvDivider & newLine, false)
end


################################################
## DOM SETTING
#

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


###############################################
## SPECIFIC DOM INTERACTIONS
#

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

-- User Keyword Prompt
on userKeyword()
	set theKeyword to display dialog "Enter a keyword" default answer ""
	set keyword to text returned of theKeyword as text
	set firstKeyword to keyword
	return keyword as text
end userKeyword


on prompt1(theText)
	set theResponse to display dialog theText default answer ""
	set theResponseText to text returned of theResponse as text
	set response to theResponseText
	return response as text
end prompt1





################################################
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


################################################
## DATA GATHERING
#

-- Get the stats from the DOM
on getStat(method, selector, instance, method2)
	logIt("getStat()")
	tell application "Safari"
		set input to do JavaScript "document." & method & "('" & selector & "')[" & instance & "]." & method2 & "." & stripCommas & ";" as string in document 1
		
		return input
	end tell
end getStat

-- Main Loop Data
on getDataLoop(method, selector, instance, method2, errorMsg, delimiterSetting)
	set theCount to instance
	set theList to {}
	set text item delimiters to delimiterSetting
	set itemCounter to 0
	
	repeat
		set updatedCount to (theCount + 1)
		log "the updatedCount is " & updatedCount & ""
		
		try
			set rowData to getStat(method, selector, updatedCount, method2)
			insertItemInList(rowData, theList, 1)
			log "add " & rowData & " to theList"
			
			log "theList = " & theList & ""
			set theCount to theCount + 1
		on error
			log "End of the List"
			exit repeat
		end try
	end repeat
	
	return the reverse of theList
end getDataLoop

###############################################
## ROUTINES
#

-- Main Routine
on mainRoutine()
	set currentKeyword to setSearchField(userKeyword())
	clickSearchButton()
	checkIfLoaded()
	
	writeFile(headers & newLine & currentKeyword & delim & getTagData() & newLine & " " & newLine & "Related Tags to " & "'" & currentKeyword & "'" & newLine & getRelatedTags() & newLine, false) as text
	
	userPrompt("Finished!")
end mainRoutine

-- Process Related Tags Routine
on processRelatedKeywords()
	writeFile(headers & newLine, false)
	set currentKeyword to setSearchField(userKeyword())
	writeFile(currentKeyword & newLine, false) as text
	clickSearchButton()
	checkIfLoaded()
	
	set progress description to "Getting the list of related tags..."
	set relatedTagsList to getDataLoop(selectorRelatedTags, "a", -1, innerText, "Error.", ",") as list
	
	set theListCount to length of relatedTagsList
	set progress total steps to theListCount
	set progress completed steps to 0
	set progress description to "Preparing to process."
	
	logIt("Loop Started")
	repeat with a from 1 to the count of relatedTagsList
		
		set currentItem to item a of relatedTagsList
		set progress description to "Getting tag data for " & currentItem & " / " & a & " of " & theListCount & ""
		setSearchField(currentItem)
		
		set currentKeyword to currentItem
		
		log "clickSearchButton()"
		clickSearchButton()
		
		log "checkIfLoaded()"
		checkIfLoaded()
		
		log "Getting data for " & currentItem & ""
		set tagScores to getDataLoop(byClassName, selectorPathScores, -1, innerText, "Error.", ",")
		set tagStats to getDataLoop(byClassName, selectorPathStats, -1, innerText, "Error.", ",")
		
		log "Writing row to file"
		writeFile(currentItem & delim & tagScores & delim & tagStats & newLine, false)
		
		set progress completed steps to a
		delay 1
	end repeat
	logIt("Loop Ended")
	-- Progress Reset
	set progress total steps to 0
	set progress completed steps to 0
	set progress description to ""
	set progress additional description to ""
	
	userPrompt("Finished!")
end processRelatedKeywords


-- Get results of one keyword at a time
on getDataForOneTag()
	writeFile(headers & newLine, false)
	
	repeat
		set currentKeyword to setSearchField(userKeyword())
		clickSearchButton()
		checkIfLoaded()
		
		set tagScores to getDataLoop(byClassName, selectorPathScores, -1, innerText, "Error.", ",")
		set tagStats to getDataLoop(byClassName, selectorPathStats, -1, innerText, "Error.", ",")
		
		set writeToFile to writeFile(currentKeyword & delim & tagScores & delim & tagStats & newLine, false)
		set userResponse to userPrompt2Buttons("Search for another?", "No", "Yes")
		
		if userResponse is false then
			userPrompt("Finished!")
			exit repeat
		end if
	end repeat
end getDataForOneTag



-- Get Related Keywords
on getRelatedKeywords()
	set currentKeyword to setSearchField(userKeyword())
	writeFile(currentKeyword & newLine, false) as text
	
	clickSearchButton()
	checkIfLoaded()
	set progress completed steps to 0
	set progress description to "Loading the Page..."
	set progress total steps to checkIfLoaded()
	
	
	set progress description to "Getting Relevant Tag Data..."
	set theData to getDataLoop(selectorRelatedTags, "a", -1, innerText, "Error.", "
") as text
	set theListCount to length of theData
	set progress total steps to theData
	
	
	writeFile(theData & newLine, false) as text
	-- Progress Reset
	set progress total steps to 0
	set progress completed steps to 0
	set progress description to ""
	set progress additional description to ""
end getRelatedKeywords



-- Get tag data from a list
on getTagDataFromList()
	set theList to {}
	repeat
		set theTag to setSearchField(userKeyword())
		insertItemInList(theTag, theList, 1)
		set userResponse to userPrompt2Buttons("Add another tag?", "No", "Yes")
		
		if userResponse is false then
			exit repeat
		end if
	end repeat
	
	log "theList is - " & theList & ""
	
	set progress description to ""
	set theListCount to length of theList
	set progress total steps to theListCount
	set progress completed steps to 0
	set progress description to ""
	
	logIt("Loop Started")
	repeat with a from 1 to the count of theList
		
		set currentItem to item a of theList
		set progress description to "Getting tag data for " & currentItem & " / " & a & " of " & theListCount & ""
		setSearchField(currentItem)
		
		#currentKeyword is a global that is used in loop handlers so we *need* this
		set currentKeyword to currentItem
		
		clickSearchButton()
		checkIfLoaded()
		
		log "Getting data for " & currentItem & ""
		set tagScores to getDataLoop(byClassName, selectorPathScores, -1, innerText, "Error.", ",")
		set tagStats to getDataLoop(byClassName, selectorPathStats, -1, innerText, "Error.", ",")
		
		log "Writing row to file"
		writeFile(currentItem & delim & tagScores & delim & tagStats & newLine, false)
		
		set progress completed steps to a
		delay 1
	end repeat
	
	logIt("Loop Ended")
	-- Progress Reset
	set progress total steps to 0
	set progress completed steps to 0
	set progress description to ""
	set progress additional description to ""
	
	#prompt1("Finished!")
end getTagDataFromList


###############################################
## CALLS
#
-- Initial User Prompt
on initialPrompt()
	set option1 to "Get tag data one word at a time"
	set option2 to "Get related tags and data"
	set option3 to "I'm done!"
	
	repeat
		set userResponse to userPromptMain("What would you like to do?", "Choose a task.", option1, option2, option3)
		
		if userResponse is "answer1" then
			getDataForOneTag()
		else if userResponse is "answer2" then
			processRelatedKeywords()
		else if userResponse is "answer3" then
			exit repeat
		end if
		
	end repeat
end initialPrompt

initialPrompt()

#getTagDataFromList()
