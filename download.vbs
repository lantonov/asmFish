'
' Download and unzip script.
'

URL_BASE = WScript.Arguments(0)
ZIP_FILE = WScript.Arguments(1)
SRC_FILE = WScript.Arguments(2)
DST_FILE = WScript.Arguments(3)
MSG_TEXT = WScript.Arguments(4)

' Globals
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

' Download a file from HTTP
Sub DownloadHttp(Url, File)
  Const BINARY = 1
  Const OVERWRITE = 2
  Set xHttp = createobject("Microsoft.XMLHTTP")
  Set bStrm = createobject("Adodb.Stream")
  Call xHttp.Open("GET", Url, False)
  ' Disable caching for downloads
  Call xHttp.SetRequestHeader("If-None-Match", "some-random-string")
  Call xHttp.SetRequestHeader("Cache-Control", "no-cache,max-age=0")
  Call xHttp.SetRequestHeader("Pragma", "no-cache")
  Call xHttp.Send()
  If Not xHttp.Status = 200 Then
    Call WScript.Echo("Unable to access file - Error " & xHttp.Status)
    Call WScript.Quit(1)
  End If
  With bStrm
    .type = BINARY
    .open
    .write xHttp.responseBody
    .savetofile File, OVERWRITE
  End With
End Sub

' Unzip a specific file from an archive
Sub Unzip(Archive, File)
  Const NOCONFIRMATION = &H10&
  Const NOERRORUI = &H400&
  Const SIMPLEPROGRESS = &H100&
  unzipFlags = NOCONFIRMATION + NOERRORUI + SIMPLEPROGRESS
  Set objShell = CreateObject("Shell.Application")
  Set objSource = objShell.NameSpace(fso.GetAbsolutePathName(Archive)).Items()
  Set objTarget = objShell.NameSpace(fso.GetAbsolutePathName("."))
  ' Only extract the file we are interested in
  For i = 0 To objSource.Count - 1
    If objSource.Item(i).Name = File Then
      Call objTarget.CopyHere(objSource.Item(i), unzipFlags)
    End If
  Next
End Sub

' Fetch the file, unzip it and rename it
If Not fso.FileExists(DST_FILE) Then
  Call WScript.Echo(vbCrLf & MSG_TEXT & " is being downloaded from: " &_
    vbCrLf & URL_BASE & "/" & ZIP_FILE & vbCrLf &_
    "Note: This only updates the Windows binary.")
  Call DownloadHttp(URL_BASE & "/" & ZIP_FILE, ZIP_FILE)
End If
If Not fso.FileExists(ZIP_FILE) And Not fso.FileExists(DST_FILE) Then
  Call WScript.Echo("There was a problem downloading the file.")
  Call WScript.Quit(1)
End If
If fso.FileExists(ZIP_FILE) Then
  Call Unzip(ZIP_FILE, SRC_FILE)
  Call fso.MoveFile(SRC_FILE, DST_FILE)
  Call fso.DeleteFile(ZIP_FILE)
End If
If Not fso.FileExists(DST_FILE) Then
  Call WScript.Echo("There was a problem unzipping the file.")
  Call WScript.Quit(1)
End If
