:: Copyright 2018 Amazon
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::     http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.

@ECHO OFF

REM THIS BATCH FILE TAKES THE PROJECT SETTINGS FOR THE UNITY PROJECT FROM THE NORMAL LOCATION (%ABS_ROOT%\ProjectSettings)
REM AND SAVES IT AS A NAMED CONFIGURATION IN %ABS_ROOT%\Configurations\<NAME>\ProjectSettings
REM THE NAME COMES FROM THE COMMAND LINE PARAMETER OR FROM INTERACTIVE QUESTION. THIS IS DESIGNED TO BE USED INTERACTIVELY
REM DURING DEVELOPMENT. THE SERVER BUILD AND THE CLIENT BUILD HAVE A SLIGHTLY DIFFERENT CONFIGURATION. THESE NAMED
REM CONFIGURATIONS ARE BUILT USING BUILDCONFIG.BAT, WHICH IS CALLED FROM BUILD.BAT.
REM
REM THE PROJECT SETTINGS CONTAIN THE 'DEVELOPMENT BUILD' SETTING AND ANY INITIAL #define MACROS FOR THE UNITY PROJECT SO WE WILL
REM NEED TO CHANGE THOSE FOR EACH DIFFERENT BUILD

SETLOCAL ENABLEDELAYEDEXPANSION

REM ------- FIND MY ABSOLUTE ROOT -------
SET REL_ROOT=..\
SET ABS_ROOT=
PUSHD %REL_ROOT%
SET ABS_ROOT=%CD%
POPD

REM ------- TEST FOR EXISTING CONFIGURATION -------
IF EXIST %ABS_ROOT%\ProjectSettings\configname GOTO SAVEEXISTING


REM ------- USE COMMAND LINE PARAMETER FOR NEW NAME? -------
IF NOT "%1" == "" (
	SET CONFIGNAME=%1
	GOTO OVERWRITEQUESTION
)


REM ------- PROMPT FOR NEW NAME -------
:ASKCONFIGNAME
SET /P CONFIGNAME=THIS IS A NEW CONFIGURATION. PLEASE ENTER A NAME: 
IF "%CONFIGNAME%" EQU "" GOTO ASKCONFIGNAME
GOTO OVERWRITEQUESTION


:SAVEEXISTING
REM THIS CONFIGURATION WAS SAVED BEFORE
IF NOT "%1" == "" (
    REM AND WE ARE RENAMING IT
	SET CONFIGNAME=%1
	GOTO OVERWRITEQUESTION
)

SET /P CONFIGNAME=<%ABS_ROOT%\ProjectSettings\configname
REM REMOVE LEADING/TRAILING WHITESPACE
FOR /F "TOKENS=* DELIMS= " %%A IN ("%CONFIGNAME%") DO SET CONFIGNAME=%%A
FOR /L %%A IN (1,1,100) DO IF "!CONFIGNAME:~-1!"==" " SET CONFIGNAME=!CONFIGNAME:~0,-1!


:EXISTQUESTION
set /P c=DO YOU WANT TO UPDATE CONFIGURATION %CONFIGNAME% [Y/N]? 
if /I "%c%" EQU "Y" GOTO UPDATEEXISTING
if /I "%c%" EQU "N" EXIT /B 1
GOTO :EXISTQUESTION


:UPDATEEXISTING
DEL %ABS_ROOT%\ProjectSettings\configname
REM Delete the old version.
IF EXIST %ABS_ROOT%\Configurations\%CONFIGNAME% RMDIR /S /Q %ABS_ROOT%\Configurations\%CONFIGNAME%


:OVERWRITEQUESTION
IF NOT EXIST %ABS_ROOT%\Configurations\%CONFIGNAME% GOTO SAVENEW
set /P c=DO YOU WANT TO OVERWRITE CONFIGURATION %CONFIGNAME% [Y/N]? 
if /I "%c%" EQU "Y" GOTO UPDATEEXISTING
if /I "%c%" EQU "N" EXIT /B 1
GOTO :OVERWRITEQUESTION


:SAVENEW
MKDIR %ABS_ROOT%\Configurations\%CONFIGNAME%\ProjectSettings
ECHO %CONFIGNAME% > %ABS_ROOT%\ProjectSettings\configname
COPY %ABS_ROOT%\ProjectSettings\*.* %ABS_ROOT%\Configurations\%CONFIGNAME%\ProjectSettings\ > NUL