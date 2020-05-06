@echo off

SET LIB_NAME=dlib

SET CALL_DIR=%CD%
SET PROJECT_DIR=%~dp0..
SET OUTPUT_HEADER=%IGE_LIBS%\%LIB_NAME%

echo Fetching %LIB_NAME% headers...

if exist "%OUTPUT_HEADER%\include" (
	rmdir /s /q %OUTPUT_HEADER%\include
)
if not exist "%OUTPUT_HEADER%" (
    mkdir %OUTPUT_HEADER%
)

xcopy /q /s /y %~dp0..\dlib\*.h?? %OUTPUT_HEADER%\include\dlib\

cd %CALL_DIR%
echo Fetching %LIB_NAME% headers DONE!