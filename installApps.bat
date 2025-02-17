@echo off

:: Copyright 2024 HCL Technologies
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

:: This script installs CC and DAM portlets and Remote search into WebEngine running in a docker-compose environment


setlocal

set ENABLE_DAM=false
set ENABLE_CC=false
set ENABLE_SEARCHV2=false
set ENABLE_PEOPLE_SERVICE=false
GOTO:MAIN

:validate_boolean
if "%~1" neq "true" if "%~1" neq "false" (
  echo Invalid value for %2: %~1. Allowed values are true or false.
  exit /b 1
)
exit /b 0

:MAIN
REM Process command line arguments
REM Check if arguments are provided
if "%1"=="" (
    echo No arguments provided.
    exit /b 1
)

REM Loop through all arguments
:loop
if "%1"=="" goto end

echo Processing argument: %1

REM Example: Check if argument matches a certain value
if /i "%1"=="-enableDAM" (
    echo Argument -enableDAM found!
    set ENABLE_DAM=%~2
    call :validate_boolean %ENABLE_DAM% ENABLE_DAM
)
if /i "%1"=="-enableCC" (
    echo Argument -enableCC found!
    set ENABLE_CC=%~2
    call :validate_boolean %ENABLE_CC% ENABLE_CC
)
if /i "%1"=="-enableSearchV2" (
    echo Argument enableSearchV2 found!
    set ENABLE_SEARCHV2=%~2
    call :validate_boolean %ENABLE_SEARCHV2% ENABLE_SEARCHV2
)
if /i "%1"=="-enablePeopleService" (
    echo Argument -enablePeopleService found!
    set ENABLE_PEOPLE_SERVICE=%~2
    set PEOPLE_SERVICE_WEBRESOURCES_URI=res:{war:context-root}/modules/peopleservice/js
    set PEOPLE_SERVICE_CONTEXT_ROOT_API=/dx/api/people/v1
    set PEOPLE_SERVICE_CONTEXT_ROOT_PORTLET=/wps/myportal/Practitioner/PeopleService
    set PEOPLE_SERVICE_CONTEXT_ROOT_UI=/dx/ui/people
)

REM Shift to the next argument
shift
shift
goto loop

:end
echo Done processing arguments.

REM Display the parsed values
echo ENABLE_DAM=%ENABLE_DAM%
echo ENABLE_CC=%ENABLE_CC%
echo ENABLE_SEARCHV2=%ENABLE_SEARCHV2%
echo ENABLE_PEOPLE_SERVICE=%ENABLE_PEOPLE_SERVICE%
echo "#############################################################################"
echo "Installing CC and DAM and SearchV2 and PeopleService portlets using DX_HOSTNAME=%DX_HOSTNAME%"
echo "#############################################################################"
echo ""
 docker exec dx-webengine sh -c "/opt/openliberty/wlp/usr/svrcfg/bin/manageCC.sh  -Dstatic.ui.url=http://%DX_HOSTNAME%/dx/ui/content/static -DENABLE=%ENABLE_CC%"
echo "#############################################################################"
echo ""
docker exec dx-webengine sh -c "/opt/openliberty/wlp/usr/svrcfg/bin/manageDAM.sh -Dstatic.ui.url=http://%DX_HOSTNAME%/dx/ui/dam/static -DENABLE=%ENABLE_DAM%"
echo "############################################################################"
echo ""
docker exec dx-webengine sh -c "/opt/openliberty/wlp/usr/svrcfg/bin/manageSearchV2.sh -Dsearch.input.redirect.version=2 -Dsearch.wcm.version=2 -Dsearch.middleware.ui.uri=http://dx-search-middleware:3000/dx/ui/search -DENABLE=%ENABLE_SEARCHV2%"
echo "############################################################################"
echo ""
docker exec dx-webengine sh -c "/opt/openliberty/wlp/usr/svrcfg/bin/managePeopleService.sh -DPEOPLESERVICE_ENABLED=%ENABLE_PEOPLE_SERVICE% -DPEOPLESERVICE_WEBRESOURCES_URI=%PEOPLE_SERVICE_WEBRESOURCES_URI% -DPEOPLESERVICE_UI_CONTEXT=%PEOPLE_SERVICE_CONTEXT_ROOT_UI% -DPEOPLESERVICE_API_CONTEXT=%PEOPLE_SERVICE_CONTEXT_ROOT_API% -DPEOPLESERVICE_PORTLET_CONTEXT=%PEOPLE_SERVICE_CONTEXT_ROOT_PORTLET%"
echo "############################################################################"
echo "Installed CC and DAM and SearchV2 and PeopleService portlets using DX_HOSTNAME=%DX_HOSTNAME%"
echo "############################################################################"
echo ""
