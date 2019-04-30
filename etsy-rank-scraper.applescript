###############################################
## GLOBAL PROPERTIES
#
set AppleScript's text item delimiters to ","

# Script Files
property script_file_read_and_write : "file_read_and_write.scpt"
property script_dom_interactions : "dom_interactions.scpt"
property script_ui_prompts : "ui_prompts.scpt"
property script_getData_handlers : "getData_handlers.scpt"
property script_getScores : "getScores.scpt"
property script_check_loaded : "check_loaded.scpt"
property script_getCurrentKeyword : "get_current_keyword.scpt"



property chrome : "Google Chrome"
property safari : "Safari"
property noResultsMessage : "No results found for that search term."
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


property loginButtonHomePath : "document.getElementsByTagName('button')[1]"
property nodeKeywordBtn : "[href=\"/keyword-tool\"]"

property headers : "Keyword, Comp, Demand, Engage, Total Listings, # Analyzed, Avg Price, Avg Hearts, Total Views, Avg Views, Daily Views, Weekly Views"

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

property splitDashes : "split(' - ',1)"
property stripWhitespace : "trim();"

property currentKeyword : ""

property newLine : "\n"


###############################################
# GLOBAL HANDLERS
###############################################

# Load Script
on load_script(_scriptName)
	tell application "Finder"
		set scriptsPath to "scripts:" as string
		set _myPath to container of (path to me) as string
		set _loadPath to (_myPath & scriptsPath & _scriptName) as string
		load script (alias _loadPath)
	end tell
end load_script

# Run Single Script
on runScript(_scriptName)
	set _script to load_script(_scriptName)
	set a to run _script
	return
end runScript

# Trim String
on trim(theText)
	return (do shell script "echo \"" & theText & "\" | xargs")
end trim

# App Activate
on activateApp(theApp)
	tell application theApp to activate
	log "activate '" & theApp & "'"
end activateApp

-- Write Headers
on writeHeaders()
	writeFile(headers & newLine, false)
end writeHeaders


on writeDivider()
	writeFile(csvDivider & newLine, false)
end writeDivider





###############################################
# CONSTRUCTOR HANDLERS

on writeFile(content)
	set a to load_script(script_file_read_and_write)
	tell a to writeFile(content, false)
end writeFile

on setSearchField(var)
	set a to load_script(script_dom_interactions)
	tell a to setSearchField(var)
end setSearchField

on clickSearchButton()
	set a to load_script(script_dom_interactions)
	tell a to clickSearchButton()
end clickSearchButton

on userKeyword()
	set a to load_script(script_dom_interactions)
	tell a to userKeyword()
end userKeyword

on checkIfLoaded(currentKeyword)
	set a to load_script(script_check_loaded)
	tell a to checkIfLoaded(currentKeyword)
end checkIfLoaded

on getRelatedTagsList()
	set a to load_script(script_getData_handlers)
	tell a
		set relatedTagsList to getDataLoop(selectorRelatedTags, "a", -1, innerText, "Error.", ",") as list
		return relatedTagsList
	end tell
end getRelatedTagsList

on getScores()
	set a to load_script(script_getScores)
	tell a to set b to getScores()
	return b
end getScores

on getStats()
	set a to load_script(script_getData_handlers)
	tell a to set b to getDataLoop(byClassName, selectorPathStats, -1, innerText, "Error.", ",")
	return b
end getStats

on userPrompt(a)
	set b to load_script(script_ui_prompts)
	tell b to userPrompt(a)
end userPrompt

on userPromptMain(a, b, c, d, e)
	set _script to load_script(script_ui_prompts)
	tell _script to userPromptMain(a, b, c, d, e)
end userPromptMain

on getCurrentKeyword()
	set a to load_script(script_getCurrentKeyword)
	tell a to set b to getCurrentKeyword()
	return b
end getCurrentKeyword

on getSearchQuery()
	set a to load_script(script_getCurrentKeyword)
	tell a to set b to getSearchQuery()
	return b
end getSearchQuery

###############################################
# PROCESS RELATED KEYWORDS

on processRelatedKeywords()
	set theDelay to 1
	
	writeFile(headers & newLine)
	set initialKeyword to userKeyword() as string
	setSearchField(initialKeyword)
	clickSearchButton()
	
	checkIfLoaded(getSearchQuery())
	
	set progress description to "Getting the list of related tags..."
	delay theDelay
	
	set relatedTagsList to getRelatedTagsList()
	delay theDelay
	log relatedTagsList
	
	set theListCount to length of relatedTagsList
	delay theDelay
	
	set progress total steps to theListCount
	set progress completed steps to 0
	set progress description to "Preparing to process."
	
	repeat with a from 1 to the count of relatedTagsList
		delay theDelay
		set currentItem to item a of relatedTagsList
		set progress description to "Getting tag data for " & currentItem & " / " & a & " of " & theListCount & ""
		
		setSearchField(currentItem)
		delay theDelay
		
		clickSearchButton()
		delay theDelay
		
		checkIfLoaded(currentItem)
		delay theDelay
		
		writeFile(currentItem & delim & getScores() & delim & getStats() & newLine)
		
		set progress completed steps to a
		delay theDelay
	end repeat
	
	-- Progress Reset
	set progress total steps to 0
	set progress completed steps to 0
	set progress description to ""
	set progress additional description to ""
	
	userPrompt("Finished!")
end processRelatedKeywords

###############################################
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


###############################################
-- Get Related Keywords

on getRelatedKeywords()
	set currentKeyword to setSearchField(userKeyword())
	writeFile(currentKeyword & newLine, false, userKeyword & ".csv") as text
	
	clickSearchButton()
	checkIfLoaded()
	
	set progress completed steps to 0
	set progress description to "Loading the Page..."
	set progress total steps to checkIfLoaded()
	set progress description to "Getting Relevant Tag Data..."
	
	set theData to getDataLoop(selectorRelatedTags, "a", -1, innerText, "Error.", "\n") as text
	
	set theListCount to length of theData
	set progress total steps to theData
	
	writeFile(theData & newLine, false) as text
	
	-- Progress Reset
	set progress total steps to 0
	set progress completed steps to 0
	set progress description to ""
	set progress additional description to ""
end getRelatedKeywords


###############################################
-- Get tag data from a list

on getTagDataFromList()
	set theList to {}
	
	repeat
		set theTag to setSearchField(userKeyword())
		set fileName to theTag & ".csv"
		
		insertItemInList(theTag, theList, 1)
		
		set userResponse to userPrompt2Buttons("Add another tag?", "No", "Yes")
		
		if userResponse is false then
			exit repeat
		end if
		
		set theList to reverse of theList
	end repeat
	
	set progress description to ""
	set theListCount to length of theList
	set progress total steps to theListCount
	set progress completed steps to 0
	set progress description to ""
	
	repeat with a from 1 to the count of theList
		set currentItem to item a of theList
		set progress description to "Getting tag data for " & currentItem & " / " & a & " of " & theListCount & ""
		setSearchField(currentItem)
		
		#currentKeyword is a global that is used in loop handlers so we *need* this
		set currentKeyword to currentItem
		
		clickSearchButton()
		checkIfLoaded()
		
		set tagScores to getDataLoop(byClassName, selectorPathScores, -1, innerText, "Error.", ",")
		set tagStats to getDataLoop(byClassName, selectorPathStats, -1, innerText, "Error.", ",")
		
		writeFile(currentItem & delim & tagScores & delim & tagStats & newLine, false)
		
		set progress completed steps to a
		delay 1
	end repeat
	
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

###############################################
-- Initial User Prompt

on initialPrompt()
	set a to "Get tag data one word at a time"
	set b to "Get related tags and data"
	set c to "I'm done!"
	
	repeat
		set userResponse to userPromptMain("What would you like to do?", "Choose a task.", a, b, c)
		
		if userResponse is "answer1" then
			getTagDataFromList()
		else if userResponse is "answer2" then
			processRelatedKeywords()
		else if userResponse is "answer3" then
			exit repeat
		end if
		
	end repeat
end initialPrompt

-- Read from File
on readFromList()
	set theList to paragraphs of (read POSIX file filePath)
end readFromList

###############################################
## ROUTINES
#

###############################################
-- Main Routine
on mainRoutine()
	set currentKeyword to setSearchField(userKeyword())
	clickSearchButton()
	checkIfLoaded()
	
	writeFile(headers & newLine & currentKeyword & delim & getTagData() & newLine & " " & newLine & "Related Tags to " & "'" & currentKeyword & "'" & newLine & getRelatedTags() & newLine, false) as text
	
	userPrompt("Finished!")
end mainRoutine


initialPrompt()
#getRelatedTagsList()



