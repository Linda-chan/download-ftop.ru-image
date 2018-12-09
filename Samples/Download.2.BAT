@ECHO OFF
SETLOCAL

::SET SCRIPT_CMD=CScript.EXE //NoLogo "..\Download-ftop.ru-ImageHTRC.WSF"
SET SCRIPT_CMD=CScript.EXE //NoLogo "..\Download-ftop.ru-ImageWHTC.WSF"

FOR /F %%A IN (Download.LST) DO %SCRIPT_CMD% "%%A"
