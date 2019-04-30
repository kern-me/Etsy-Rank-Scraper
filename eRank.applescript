# Replace String
on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars

############################
# File Read/Write
############################
property fileName : "eRank Keyword Data.csv"


-- Reading and Writing Params
on writeTextToFile(theText, theFile, overwriteExistingContent)
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
	set this_Story to theContent
	
	tell application "Finder"
		set a to container of (path to me) as string
		set b to (a & fileName) as string
		log b
	end tell
	
	writeTextToFile(this_Story, b, writable)
end writeFile


-- Open a File
on openFile(theFile, theApp)
	tell application "Finder"
		open file ((path to desktop folder as text) & theFile) using ((path to applications folder as text) & theApp)
	end tell
end openFile


############################
# Data Gathering Handlers
############################

on getStat(a)
	tell application "Safari"
		try
			set b to do JavaScript "document.querySelector('" & a & "').innerText.trim()" in document 1
			return b
		on error
			return false
		end try
	end tell
end getStat


########

on get_searches()
	set x to "#er-page-content-wrapper > div > div > div > div > div:nth-child(2) > div:nth-child(6) > div > div"
	set a to getStat(x)
	set b to replace_chars(a, " searches per month", "") as string
	set c to replace_chars(b, ",", "") as number
	return c
end get_searches

on get_competition()
	set x to "#er-page-content-wrapper > div > div > div > div > div:nth-child(2) > div.col-lg-4.col-md-6.col-sm-6.col-xs-12.m-b-0.p-l-0 > div > div"
	set a to getStat(x)
	set b to replace_chars(a, " listings", "") as string
	set c to replace_chars(b, ",", "") as number
	return c
end get_competition

on get_engagement()
	set x to "#er-page-content-wrapper > div > div > div > div > div:nth-child(2) > div:nth-child(8) > div > div"
	set a to getStat(x)
	return a
end get_engagement

on get_listings()
	set x to "#er-page-content-wrapper > div > div > div > div > div:nth-child(2) > div:nth-child(11) > div > div > div.col-xs-9.text-left > div:nth-child(2) > div > div > div > span"
	set a to getStat(x)
	return a as number
end get_listings

on get_avg_price()
	set x to "#er-page-content-wrapper > div > div > div > div > div:nth-child(2) > div:nth-child(13) > div > div > div.col-xs-9.text-left > div:nth-child(2) > div > div > div > span"
	set a to getStat(x)
	return a as number
end get_avg_price

on get_avg_hearts()
	set x to "#er-page-content-wrapper > div > div > div > div > div:nth-child(2) > div:nth-child(14) > div > div > div.col-xs-9.text-left > div:nth-child(2) > div > div > div > span"
	set a to getStat(x)
	return a as number
end get_avg_hearts

on get_avg_daily_views()
	set x to "#er-page-content-wrapper > div > div > div > div > div:nth-child(2) > div:nth-child(17) > div > div > div.col-xs-9.text-left > div:nth-child(2) > div > div > div > span"
	set a to getStat(x)
	return a as number
end get_avg_daily_views

on get_avg_weekly_views()
	set x to "#er-page-content-wrapper > div > div > div > div > div:nth-child(2) > div:nth-child(18) > div > div > div.col-xs-9.text-left > div:nth-child(2) > div > div > div > span"
	set a to getStat(x)
	return a as number
end get_avg_weekly_views

############################
# Write to file
############################
property newLine : "\n"

on writeToFile()
	set a to get_searches() as string
	set b to get_competition() as string
	set c to get_engagement() as string
	set d to get_listings() as string
	set e to get_avg_price() as string
	set f to get_avg_hearts() as string
	set g to get_avg_daily_views() as string
	set h to get_avg_weekly_views() as string
	
	writeFile(a & "," & b & "," & c & "," & d & "," & e & "," & f & "," & g & "," & h & newLine, false) as string
end writeToFile

############################
# Calls
############################
writeToFile()
