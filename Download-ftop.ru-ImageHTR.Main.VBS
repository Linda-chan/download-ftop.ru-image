Option Explicit

Const AppTitle = "AJPapps - Download ftop.ru image HTR ver."
Const AppCopyright = "Линда Кайе 2014-2018. Посвящается Ариэль"

Dim PageURL
Dim ProxyPageURL
Dim PictureURL
Dim PictureData
Dim UserAgent

'====================================================================
Public Sub Main()
  ' Заранее получаем юзерагент, чтобы он не менялся при запросах...
  UserAgent = GetUserAgent()
  
  PageURL = GetPageURLFromArgs(False)
  If PageURL = "" Then Exit Sub
  
  ProxyPageURL = GetProxyPageURL(PageURL)
  If ProxyPageURL = "" Then Exit Sub
  
  PictureURL = GetPictureURL(ProxyPageURL, PageURL)
  If PictureURL = "" Then Exit Sub
  
  PictureData = GetJPGFile(PictureURL, ProxyPageURL)
  If PictureData = "" Then Exit Sub
  
  SaveJPGFile PageURL, PictureURL, PictureData
End Sub

'====================================================================
Private Function GetProxyPageURL(ByVal URL)
  Dim HTR 'As ajpHTTPRequest
  Dim Proxy 'As ProxySettings
  Dim Protocol
  Dim Host
  Dim Port
  Dim SearchObject
  Dim TXT
  
  On Error Resume Next
  
  ' Значение по умолчанию...
  GetProxyPageURL = ""
  
  Set HTR = CreateObject("CmnFuncs0301.ajpHTTPRequest")
  Set Proxy = CreateObject("CmnFuncs0301.ProxySettings")
  
  If Err.Number <> 0 Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Не удаётся создать объект ajpHTTPRequest.", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  On Error Goto 0
  
  If Not CrackURL(URL, Protocol, Host, Port, SearchObject) Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Ошибка парсинга URL.", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  Proxy.HTTP_AccessType = 0 ' psatPreconfigByIE
  Set HTR.ProxySettings = Proxy
  
  HTR.Execute Host, Port, , _
              SearchObject, , , , , , _
              UserAgent, , , True, True, True
  
  If HTR.ErrorCode <> 0 Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Ошибка отправки HTTP запроса (не удалось подключиться к серверу).", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  If HTR.ResponseCode <> 200 Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Сервер вернул: " & HTR.ResponseCode & " " & _
           HTR.ResponseText & ".", vbCritical, AppTitle
    Exit Function
  End If
  
  TXT = ParseHTMLAndGetProxyPageURL(Utf8ToChar(HTR.ReceivedData))
  If TXT = "" Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось найти ссылку на жуточную страницу.", vbCritical, AppTitle
    Exit Function
  End If
  
  GetProxyPageURL = TXT
End Function

'====================================================================
Private Function GetPictureURL(ByVal URL, ByVal PageURL)
  Dim HTR 'As ajpHTTPRequest
  Dim Proxy 'As ProxySettings
  Dim Protocol
  Dim Host
  Dim Port
  Dim SearchObject
  Dim TXT
  
  On Error Resume Next
  
  ' Значение по умолчанию...
  GetPictureURL = ""
  
  Set HTR = CreateObject("CmnFuncs0301.ajpHTTPRequest")
  Set Proxy = CreateObject("CmnFuncs0301.ProxySettings")
  
  If Err.Number <> 0 Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить промежуточную страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Не удаётся создать объект ajpHTTPRequest.", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  On Error Goto 0
  
  If Not CrackURL(URL, Protocol, Host, Port, SearchObject) Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить промежуточную страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Ошибка парсинга URL.", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  Proxy.HTTP_AccessType = 0 ' psatPreconfigByIE
  Set HTR.ProxySettings = Proxy
  
  HTR.Execute Host, Port, , _
              SearchObject, , PageURL, , , , _
              UserAgent, , , True, True, True
  
  If HTR.ErrorCode <> 0 Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить промежуточную страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Ошибка отправки HTTP запроса (не удалось подключиться к серверу).", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  If HTR.ResponseCode <> 200 Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить промежуточную страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Сервер вернул: " & HTR.ResponseCode & " " & _
           HTR.ResponseText & ".", vbCritical, AppTitle
    Exit Function
  End If
  
  TXT = ParseHTMLAndGetPictureURL(Utf8ToChar(HTR.ReceivedData))
  If TXT = "" Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось найти ссылку на картинку.", vbCritical, AppTitle
    Exit Function
  End If
  
  GetPictureURL = TXT
End Function

'====================================================================
Private Function GetJPGFile(ByVal URL, ByVal PageURL)
  Dim HTR 'As ajpHTTPRequest
  Dim Proxy 'As ProxySettings
  Dim Protocol
  Dim Host
  Dim Port
  Dim SearchObject
  
  On Error Resume Next
  
  ' Значение по умолчанию...
  GetJPGFile = ""
  
  Set HTR = CreateObject("CmnFuncs0301.ajpHTTPRequest")
  Set Proxy = CreateObject("CmnFuncs0301.ProxySettings")
  
  If Err.Number <> 0 Then
    MsgBox PageURL & vbCrLf & vbCrLf & _
           "Не удалось получить картинку с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Не удаётся создать объект ajpHTTPRequest.", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  On Error Goto 0
  
  If Not CrackURL(URL, Protocol, Host, Port, SearchObject) Then
    MsgBox PageURL & vbCrLf & vbCrLf & _
           "Не удалось получить картинку с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Ошибка парсинга URL.", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  Proxy.HTTP_AccessType = 0 ' psatPreconfigByIE
  Set HTR.ProxySettings = Proxy
  
  HTR.Execute Host, Port, , _
              SearchObject, , PageURL, , , , _
              UserAgent, , , True, True, True
  
  If HTR.ErrorCode <> 0 Then
    MsgBox PageURL & vbCrLf & vbCrLf & _
           "Не удалось получить картинку с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Ошибка отправки HTTP запроса (не удалось подключиться к серверу).", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  If HTR.ResponseCode <> 200 Then
    MsgBox PageURL & vbCrLf & vbCrLf & _
           "Не удалось получить картинку с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Сервер вернул: " & HTR.ResponseCode & " " & _
           HTR.ResponseText & ".", vbCritical, AppTitle
    Exit Function
  End If
  
  GetJPGFile = HTR.ReceivedData
End Function

'====================================================================
Private Sub SaveJPGFile(ByVal PageURL, ByVal PictureURL, ByVal PictureData)
  Dim FileNameJPG
  Dim TMP
  Dim TXT
  Dim FSO
  
  On Error Resume Next
  
  ' Сохраняем картинку...
  TMP = InStrRev(PictureURL, "/")
  FileNameJPG = Mid(PictureURL, TMP + 1)
  
  ' Создаём объект...
  Set FSO = CreateObject("FileIOSupport0102.ajpFSO")
  
  ' Сохраняем файл...
  FSO.PutFile2 FileNameJPG, PictureData, True, feANSI
  If Err.Number <> 0 Then
    MsgBox FileNameJPG & vbCrLf & vbCrLf & _
           "Не удалось сохранить файл.", _
           vbCritical, AppTitle
    Exit Sub
  End If
  
  ' Сохраняем описание...
  FSO.SetFileDescription FileNameJPG, PageURL & " | " & PictureURL
End Sub
