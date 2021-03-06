Option Explicit

'====================================================================
Public Function GetPageURLFromArgs(ByVal ConsoleVersion)
  GetPageURLFromArgs = ""
  
  If WScript.Arguments.Count = 1 Then
    Select Case UCase(WScript.Arguments(0))
      Case "/?", ""
        ShowUsage ConsoleVersion
        Exit Function
      Case Else
        GetPageURLFromArgs = WScript.Arguments(0)
        Exit Function
    End Select
  End If
  
  ShowUsage ConsoleVersion
End Function

'====================================================================
Private Sub ShowUsage(ByVal ConsoleVersion)
  If ConsoleVersion Then
    ShowUsageCUI
  Else
    ShowUsageGUI
  End If
End Sub

Private Sub ShowUsageGUI()
  MsgBox AppTitle & vbCrLf & _
         AppCopyright & vbCrLf & vbCrLf & _
         "Использование: " & _
         WScript.ScriptName & " [PageURL]" & vbCrLf & vbCrLf & _
         "PageURL - адрес страницы с картинкой на сайте ftop.ru. " & _
         "Картинка будет сохранена в текущий каталог.", _
         vbInformation, AppTitle
End Sub

Private Sub ShowUsageCUI()
  WScript.Echo AppTitle & vbCrLf & _
               AppCopyright & vbCrLf & vbCrLf & _
         "Использование: " & _
         WScript.ScriptName & " [PageURL]" & vbCrLf & vbCrLf & _
         "PageURL - адрес страницы с картинкой на сайте ftop.ru. " & _
         "Картинка будет сохранена в текущий каталог."
End Sub

'====================================================================
Public Function ParseHTMLAndGetProxyPageURL(ByVal SourceString)
  Dim RE
  Dim MC
  Dim TXT
  
  On Error Resume Next
  
  ' Значение по умолчанию...
  ParseHTMLAndGetProxyPageURL = ""
  
  Set RE = New RegExp
  RE.Global = True
  RE.IgnoreCase = True
  RE.MultiLine = True
  
  RE.Pattern = "Original image:\s+<a href=""(.*?)"""
  Set MC = RE.Execute(SourceString)
  
  if MC.Count = 0 Then Exit Function
  if MC(0).SubMatches.Count = 0 Then Exit Function
  
  TXT = MC(0).SubMatches(0)
  
  If LCase(Left(TXT, 7)) = "http://" Then
    ParseHTMLAndGetProxyPageURL = TXT
  ElseIf LCase(Left(TXT, 8)) = "https://" Then
    ParseHTMLAndGetProxyPageURL = TXT
  ElseIf Left(TXT, 1) = "/" Then
    ParseHTMLAndGetProxyPageURL = "http://ftop.ru" & TXT
  Else
    ParseHTMLAndGetProxyPageURL = "http://ftop.ru/" & TXT
  End If
End Function

'====================================================================
Public Function ParseHTMLAndGetPictureURL(ByVal SourceString)
  Dim RE
  Dim MC
  Dim TXT
  
  On Error Resume Next
  
  ' Значение по умолчанию...
  ParseHTMLAndGetPictureURL = ""
  
  Set RE = New RegExp
  RE.Global = True
  RE.IgnoreCase = True
  RE.MultiLine = True
  
  RE.Pattern = "<a href=""(.*?)"" download="""
  Set MC = RE.Execute(SourceString)
  
  if MC.Count = 0 Then Exit Function
  if MC(0).SubMatches.Count = 0 Then Exit Function
  
  TXT = MC(0).SubMatches(0)
  
  If LCase(Left(TXT, 7)) = "http://" Then
    ParseHTMLAndGetPictureURL = TXT
  ElseIf LCase(Left(TXT, 8)) = "https://" Then
    ParseHTMLAndGetPictureURL = TXT
  ElseIf Left(TXT, 1) = "/" Then
    ParseHTMLAndGetPictureURL = "http://ftop.ru" & TXT
  Else
    ParseHTMLAndGetPictureURL = "http://ftop.ru/" & TXT
  End If
End Function

'====================================================================
Public Function GetUserAgent()
  GetUserAgent = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:63.0) Gecko/20100101 Firefox/63.0"
End Function
