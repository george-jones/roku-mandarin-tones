
' ******************************************************
' ******************************************************
' **
' **  Roku DVP User Interface Helper Functions 
' **
' **  march 2009
' ******************************************************
' ******************************************************




'  uitkDoPosterMenu
'
'    Display "menu" items in a Poster Screen.   
'
'    if "onselect_callback" is valid, it is an Array.
'	 there are two options on the format of data in callback array
'	 entry 0 is an "array format type" integer
'    if type is 0
'		entry 1 is a this pointer.
'       entry 2...n are text names of functions to callback on the this pointer
'       like this: this[onselect_callback[msg.Index+2]]()
'    if type is 1
'		entry 1 & 2 are userdata
'       entry 3 is the callback function reference.  
'		like this: 	f(userdata1, userdata2, msg.Index)
'
'	 in each type:
'		returns when UP or HOME selected

'    else if onselect_callback is not valid
'		returns when UP or HOME or Menu Item selected
'		returns Integer of Menu Item index, or negative if home or up selected
'
' pass in "posterdata", an array of AAs with these entries:
'   HDPosterUrl As String - URI to HD Icon Image
'   SDPosterUrl As String - URI to SD Icon Image
'   ShortDescriptionLine1 As String - the text name of the menu item
'	ShortDescriptionLine1 As String - more text
'   
'  ******************************************************

function uitkPreShowPosterMenu(breadA=invalid, breadB=invalid) As Object
	port=CreateObject("roMessagePort")
	screen = CreateObject("roPosterScreen")
	screen.SetMessagePort(port)
	if breadA<>invalid and breadB<>invalid then
		screen.SetBreadcrumbText(breadA, breadB)
	end if
	screen.SetListStyle("arced-landscape") 'flat-category
	screen.Show()

	return screen
end function


function uitkDoPosterMenu(posterdata, screen, onselect_callback=invalid, onselect_udata=invalid) As Integer

	if type(screen)<>"roPosterScreen" then
		print "illegal type/value for screen passed to uitkDoPosterMenu()" 
		return -1
	end if
	
	screen.SetContentList(posterdata)

    while true
        msg = wait(0, screen.GetMessagePort())
		
		'print "uitkDoPosterMenu | msg type = ";type(msg)
		
		if type(msg) = "roPosterScreenEvent" then
			' print "Event.GetType()=";msg.GetType(); " Event.GetMessage()="; msg.GetMessage()
			if msg.isListItemSelected() then
				if onselect_callback<>invalid then
					onselect_callback(onselect_udata, msg.GetIndex())
				else
					return msg.GetIndex()
				end if
			else if msg.isScreenClosed() then
				return -1
			end if
		end If
	end while
end function

