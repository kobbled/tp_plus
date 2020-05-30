@ECHO OFF
IF NOT "%~f0" == "~f0" GOTO :WinNT
@ruby "C:/Ruby25-x64/bin/tpp" %1 %2 %3 %4 %5 %6 %7 %8 %9
GOTO :EOF
:WinNT
@ruby "%~dpn0" %*
