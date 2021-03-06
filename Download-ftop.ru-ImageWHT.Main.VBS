Option Explicit

Const AppTitle = "AJPapps - Download ftop.ru image WHT ver."
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
  If VarType(PictureData) <> vbByte + vbArray And _
     VarType(PictureData) <> vbString Then Exit Sub
  
  SaveJPGFile PageURL, PictureURL, PictureData
End Sub

'====================================================================
Private Function GetProxyPageURL(ByVal URL)
  Dim WHT
  Dim TXT
  
  On Error Resume Next
  
  ' Значение по умолчанию...
  GetProxyPageURL = ""
  
  Set WHT = CreateObject("WinHttp.WinHttpRequest.5.1")
  
  If Err.Number <> 0 Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Не удаётся создать объект Microsoft WinHTTP Services.", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  ' ResolveTimeout As Long, ConnectTimeout As Long, 
  ' SendTimeout As Long, ReceiveTimeout As Long
  WHT.SetTimeouts 300 * 1000, 300 * 1000, 300 * 1000, 300 * 1000
  
  ' Устанавливаем системный прокси для соединения. Прокси 
  ' настраивается через Proxycfg.exe, а не через настойки Инета.
  ' Иначе будет напрямик...
  WHT.SetProxy HTTPREQUEST_PROXYSETTING_PRECONFIG, "", ""
  
  WHT.Open "GET", URL
  WHT.SetRequestHeader "User-Agent", UserAgent
  WHT.Send
  
  If Err.Number <> 0 Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Ошибка отправки HTTP запроса (не удалось подключиться к серверу).", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  If WHT.Status <> 200 Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Сервер вернул: " & WHT.Status & " " & _
           WHT.StatusText & ".", vbCritical, AppTitle
    Exit Function
  End If
  
  TXT = ParseHTMLAndGetProxyPageURL(GetWHTResponseText(WHT))
  If TXT = "" Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось найти ссылку на промежуточную страницу.", vbCritical, AppTitle
    Exit Function
  End If
  
  GetProxyPageURL = TXT
End Function

'====================================================================
Private Function GetPictureURL(ByVal URL, ByVal PageURL)
  Dim WHT
  Dim TXT
  
  On Error Resume Next
  
  ' Значение по умолчанию...
  GetPictureURL = ""
  
  Set WHT = CreateObject("WinHttp.WinHttpRequest.5.1")
  
  If Err.Number <> 0 Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить промежуточную страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Не удаётся создать объект Microsoft WinHTTP Services.", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  ' ResolveTimeout As Long, ConnectTimeout As Long, 
  ' SendTimeout As Long, ReceiveTimeout As Long
  WHT.SetTimeouts 300 * 1000, 300 * 1000, 300 * 1000, 300 * 1000
  
  ' Устанавливаем системный прокси для соединения. Прокси 
  ' настраивается через Proxycfg.exe, а не через настойки Инета.
  ' Иначе будет напрямик...
  WHT.SetProxy HTTPREQUEST_PROXYSETTING_PRECONFIG, "", ""
  
  WHT.Open "GET", URL
  WHT.SetRequestHeader "User-Agent", UserAgent
  WHT.SetRequestHeader "Referer", PageURL
  WHT.Send
  
  If Err.Number <> 0 Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить промежуточную страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Ошибка отправки HTTP запроса (не удалось подключиться к серверу).", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  If WHT.Status <> 200 Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось получить промежуточную страницу с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Сервер вернул: " & WHT.Status & " " & _
           WHT.StatusText & ".", vbCritical, AppTitle
    Exit Function
  End If
  
  TXT = ParseHTMLAndGetPictureURL(GetWHTResponseText(WHT))
  If TXT = "" Then
    MsgBox URL & vbCrLf & vbCrLf & _
           "Не удалось найти ссылку на картинку.", vbCritical, AppTitle
    Exit Function
  End If
  
  GetPictureURL = TXT
End Function

'====================================================================
Private Function GetJPGFile(ByVal URL, ByVal PageURL)
  Dim WHT
  
  On Error Resume Next
  
  ' Значение по умолчанию...
  GetJPGFile = ""
  
  Set WHT = CreateObject("WinHttp.WinHttpRequest.5.1")
  
  If Err.Number <> 0 Then
    MsgBox PageURL & vbCrLf & vbCrLf & _
           "Не удалось получить картинку с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Не удаётся создать объект Microsoft WinHTTP Services.", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  ' ResolveTimeout As Long, ConnectTimeout As Long, 
  ' SendTimeout As Long, ReceiveTimeout As Long
  WHT.SetTimeouts 300 * 1000, 300 * 1000, 300 * 1000, 300 * 1000
  
  ' Устанавливаем системный прокси для соединения. Прокси 
  ' настраивается через Proxycfg.exe, а не через настойки Инета.
  ' Иначе будет напрямик...
  WHT.SetProxy HTTPREQUEST_PROXYSETTING_PRECONFIG, "", ""
  
  WHT.Open "GET", URL
  WHT.SetRequestHeader "User-Agent", UserAgent
  WHT.SetRequestHeader "Referer", PageURL
  WHT.Send
  
  If Err.Number <> 0 Then
    MsgBox PageURL & vbCrLf & vbCrLf & _
           "Не удалось получить картинку с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Ошибка отправки HTTP запроса (не удалось подключиться к серверу).", _
           vbCritical, AppTitle
    Exit Function
  End If
  
  If WHT.Status <> 200 Then
    MsgBox PageURL & vbCrLf & vbCrLf & _
           "Не удалось получить картинку с ftop.ru." & _
           vbCrLf & vbCrLf & _
           "Сервер вернул: " & WHT.Status & " " & _
           WHT.StatusText & ".", vbCritical, AppTitle
    Exit Function
  End If
  
  GetJPGFile = WHT.ResponseBody  ' Byte array
  'GetJPGFile = WHT.ResponseText  ' String
End Function

'====================================================================
Private Sub SaveJPGFile(ByVal PageURL, ByVal PictureURL, ByVal PictureData)
  Dim FileNameJPG
  Dim TMP
  Dim TXT
  
  On Error Resume Next
  
  ' Сохраняем картинку...
  TMP = InStrRev(PictureURL, "/")
  FileNameJPG = Mid(PictureURL, TMP + 1)
  
  ' Сохраняем файл...
  PutFileB FileNameJPG, PictureData
  If Err.Number <> 0 Then
    MsgBox FileNameJPG & vbCrLf & vbCrLf & _
           "Не удалось сохранить файл.", _
           vbCritical, AppTitle
    Exit Sub
  End If
  
  ' Описание не сохраняем - лень писать велосипед...
End Sub
