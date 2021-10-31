' ********************************************************************
' ********************************************************************
' **
' **  Roku Polaris Academy Chinese Channel (BrightScript)
' **
' **  January 2015
' **  Copyright (c) 2015 George Jones. All Rights Reserved.
' ********************************************************************
' ********************************************************************

Sub Main()
	'mainurl = "http://192.168.1.14:8084"
  mainurl = "ext1:/roku"

  SetTheme()

	' Pop up start of UI for some instant feedback while we load the icon data
	poster = uitkPreShowPosterMenu()
	if poster=invalid then
		print "unexpected error in uitkPreShowPosterMenu"
		return
	end if

  poster.ShowMessage("Attempting to read data file.")
  datajson = ReadAsciiFile(mainurl + "/data.json")
  response = ParseJson(datajson)
  
	' Create an Array of AAs.
	' Each AA contains the data needed to display a Main Menu icon
  mainmenudata = [ ]
  if response = invalid then
    poster.ShowMessage("Data file not found.  Please insert USB device and restart.")    
  else
    For Each item In response.items
      path = mainurl + "/" + item.folder + "/"
      item.AddReplace("path", path)
      mainmenudata.Push({
        ShortDescriptionLine1: item.title,
        ShortDescriptionLine2: item.subtitle,
        SDPosterUrl: path + "img/title.png",
        HDPosterUrl: path + "img/title.png" })
    End For
  end if

	uitkDoPosterMenu(mainmenudata, poster, TopLevelPick, response.items)

End Sub

Sub Quit(poster)
	poster.Close()
End Sub

REM ******************************************************
REM
REM Setup theme for the application 
REM
REM ******************************************************

Sub SetTheme()
    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.BackgroundColor = "#FFFFFF"
    theme.PosterScreenLine1Text = "#AA381E"
    theme.PosterScreenLine2Text = "#AA6859"
    theme.OverhangOffsetSD_X = "0"
    theme.OverhangOffsetSD_Y = "0"    
    theme.OverhangLogoSD  = "pkg:/images/grid_top.jpg"
    theme.OverhangOffsetHD_X = "265"
    theme.OverhangOffsetHD_Y = "22"
    theme.OverhangLogoHD  = "pkg:/images/grid_top.jpg"

    app.SetTheme(theme)
End Sub

Sub TopLevelPick(items, idx)
  itm = items[idx]
  if itm.type = "tones" then
    TonePractice(itm)
  end if
end Sub

Sub TonePractice(itm)
  imgpath = itm.path + "img/"
  sndpath = itm.path + "sound/"
  audio = CreateObject("roAudioPlayer")
  fontRegistry = CreateObject("roFontRegistry")
  canvas = CreateObject("roImageCanvas")
  port = CreateObject("roMessagePort")
  canvas.SetMessagePort(port)

  'Set opaque background
  canvas.SetRequireAllImagesToDraw(true)
  words = shuffle(itm.words)

  For Each word In words
    currStep = 0 '0=show text only, 1=show pictures+play sound
    canvas.Clear()
    canvas.SetLayer(0, { Color:"#FFFFFF", CompositionMode:"Source" })
    layer1 = [
      {
        url: imgpath + word.name + ".png",
        TargetRect: { x: 350, y: 48, w: 576, h: 100 }
      },
      {
        Text: word.english,
        TextAttrs: {
          Color: "#999999",
          Font: fontRegistry.Get("Default", 60, 50, false),
          HAlign: "HCenter",
          VAlign: "VCenter",
          Direction: "LeftToRight"
        },
        TargetRect: { x: 350, y:148, w:576, h: 80 }
      }
    ]

    canvas.SetLayer(1, layer1)
    canvas.Show() 
    while (true)
      msg = wait(0,port) 
      if type(msg) = "roImageCanvasEvent" then
        if (msg.isRemoteKeyPressed()) then
          i = msg.GetIndex()
          if (i = 2) then
            ' Up - Close the screen.
            canvas.close()
          else if (i = 6) then
            if currStep = 0 then
              'show pictures
              canvas.SetLayer(2, {
                Color: "#550000",
                CompositionMode: "Source",
                TargetRect: { x: 72, y: 273, w: 1126, h: 402 }
              })
              if word.tones.Count() = 2 then
                '2 images
                t1img = imgpath + itm.img["t" + word.tones[0]]
                print t1img
                t2img = imgpath + itm.img["t" + word.tones[1]]
                layer3 = [
                  {
                    url: t1img,
                    TargetRect: { x: 80, y: 287, w: 550, h: 367 }
                  },
                  {
                    url: t2img,
                    TargetRect: { x: 640, y: 287, w: 550, h: 367 }
                  },
                ]  
              else
                'single image
                t1img = imgpath + itm.img["t" + word.tones[0]]
                layer3 = [
                  {
                    url: t1img,
                    TargetRect: { x: 405, y: 287, w: 550, h: 367 }
                  }
                ]
              end if
              canvas.SetLayer(3, layer3)
              canvas.Show()
              'play sound
              audioitem = CreateObject("roAssociativeArray")
              url = sndpath + word.name + ".mp3"
              audioitem.Url = url
              audioitem.StreamFormat = "mp3"
              audio.AddContent(audioitem)
              audio.SetLoop(false)
              audio.Play()
              currStep = 1              
            else if currStep = 1 then
              exit while
            end if
            ' Select - move on
            'canvas.ClearLayer(1)
            'tmpurl = canvasItems[0].url
            'canvasItems[0].url = canvasItems[1].url
            'canvasItems[1].url = tmpurl
            'canvas.SetLayer(1, canvasItems)
            'canvas.Show()
          end if

        else if (msg.isScreenClosed()) then
          print "Closed"
          return
        end if
      end if
    end while
  end for
end Sub

Function shuffle(a as Object) as Object
  'takes an array, returns a shuffled version of it
  t = [ ]
  r = [ ]
  'copy elements to temp list
  For Each el In a
    t.Push(el)
  End For
  While t.Count() > 0
    idx = Rnd(t.Count()) - 1
    el = t[idx]
    t.Delete(idx)
    r.Push(el)
  End While
  return r
end Function 


  'Play some chinese music
  'audio = CreateObject("roAudioPlayer")
  'item = CreateObject("roAssociativeArray")
  'url = "http://wmedia.cameroon-info.net/CINPodCast/AuDio237/Musique_Chinoise__Chinese_Musique_Tradionnelle_De_Chine,_Man_Jiang_Hong_Erhu_Concerto.mp3"

  'item.Url = url
  'item.StreamFormat = "mp3"
  'audio.AddContent(item)
  'audio.SetLoop(true)
  'audio.Play()

