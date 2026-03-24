@echo off
echo Download HCL DX-Compose container images from HCL Harbor...
echo Please enter your HCL Harbor login username/id:
set /p inputUsername=
echo Please enter your HCL Harbor CLI secrete:
set /p inputPassword=
echo Logging in into HCL Harbor...
call docker login --username %inputUsername% --password %inputPassword% https://hclcr.io/
echo Creating harbor directory, if it does not exist...
if not exist ./harbor md harbor
echo ------------------------------------------------
:: Configure here all containers that need to be pulled.
call:GetContainerFromHCLHarbor dx-compose webengine DX_DOCKER_IMAGE_WEBENGINE
call:GetContainerFromHCLHarbor dx-compose ringapi DX_DOCKER_IMAGE_RING_API
call:GetContainerFromHCLHarbor dx-compose digital-asset-manager DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER
call:GetContainerFromHCLHarbor dx-compose image-processor DX_DOCKER_IMAGE_IMAGE_PROCESSOR
call:GetContainerFromHCLHarbor dx-compose dx-file-processor DX_DOCKER_IMAGE_FILE_PROCESSOR
call:GetContainerFromHCLHarbor dx-compose content-composer DX_DOCKER_IMAGE_CONTENT_COMPOSER
call:GetContainerFromHCLHarbor dx-compose persistence-node DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER
call:GetContainerFromHCLHarbor dx-compose persistence-connection-pool DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER
call:GetContainerFromHCLHarbor dx-compose haproxy DX_DOCKER_IMAGE_HAPROXY
call:GetContainerFromHCLHarbor dx-compose dx-opensearch DX_DOCKER_IMAGE_OPENSEARCH
call:GetContainerFromHCLHarbor dx-compose dx-search-middleware DX_DOCKER_IMAGE_SEARCH_MIDDLEWARE
call:GetContainerFromHCLHarbor dx-compose people-service DX_DOCKER_IMAGE_PEOPLE_SERVICE
call:setPropertiesFile 

:GetContainerFromHCLHarbor
if "%1" NEQ "" (
    if "%2" NEQ "" ( 
        if "%3" NEQ "" ( goto getFromHCLHarbor %1 %2 %3 )))
EXIT /B 0

:getFromHCLHarbor
echo Processing %1-%2 container...
echo Finding %1-%2-tags on https://hclcr.io...
curl "https://hclcr.io/api/v2.0/projects/%1/repositories/%2/artifacts?page=1&page_size=10&with_tag=true" -s -u "%inputUsername%:%inputPassword%" -H "Accept: application/json" -H "Content-type: application/json" > ./harbor/harbor_result.json
echo Extract tags using jq-windows-amd64.exe (need to be downloaded from URL https://jqlang.org/)...
jq-windows-amd64.exe -r ".[] .tags .[] .name" ./harbor/harbor_result.json > ./harbor/%1-%2-tags.txt
set "tags="
for /F "delims=" %%i in (./harbor/%1-%2-tags.txt) do if not defined tags set tags=%%i
echo Pulling images...
docker pull hclcr.io/%1/%2:%tags%
echo Pulling %1-%2 container finished.
echo Cleanup temp files...
cd harbor
del "harbor_result.json"
cd ..
echo cleanup finished.
set arg1=%3
set arg2=hclcr.io/dx-compose/%2:%tags%
echo Set variable: %arg1%=%arg2%
set "%arg1%=%arg2%"
echo ------------------------------------------------
EXIT /B 0

:setPropertiesFile 
echo Updating properties file with image tags...
(for /f "tokens=1* delims==" %%m in (dx.properties) do (
IF %%m==DX_DOCKER_IMAGE_WEBENGINE  (
    IF %DX_DOCKER_IMAGE_WEBENGINE%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_WEBENGINE%)
) ELSE IF %%m==DX_DOCKER_IMAGE_IMAGE_PROCESSOR (
    IF %DX_DOCKER_IMAGE_IMAGE_PROCESSOR%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_IMAGE_PROCESSOR%)	
) ELSE IF %%m==DX_DOCKER_IMAGE_CONTENT_COMPOSER (
    IF %DX_DOCKER_IMAGE_CONTENT_COMPOSER%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_CONTENT_COMPOSER%)	
) ELSE IF %%m==DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER (
    IF %DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_DATABASE_NODE_DIGITAL_ASSET_MANAGER%)
) ELSE IF %%m==DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER (
    IF %DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_DATABASE_CONNECTION_POOL_DIGITAL_ASSET_MANAGER%)
) ELSE IF %%m==DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER (
    IF %DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_DIGITAL_ASSET_MANAGER%)
) ELSE IF %%m==DX_DOCKER_IMAGE_RING_API (
    IF %DX_DOCKER_IMAGE_RING_API%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_RING_API%)
) ELSE IF %%m==DX_DOCKER_IMAGE_HAPROXY (
    IF %DX_DOCKER_IMAGE_HAPROXY%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_HAPROXY%)
) ELSE IF %%m==DX_DOCKER_IMAGE_OPENSEARCH (
    IF %DX_DOCKER_IMAGE_OPENSEARCH%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_OPENSEARCH%)	
) ELSE IF %%m==DX_DOCKER_IMAGE_FILE_PROCESSOR (
    IF %DX_DOCKER_IMAGE_FILE_PROCESSOR%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_FILE_PROCESSOR%)	
) ELSE IF %%m==DX_DOCKER_IMAGE_SEARCH_MIDDLEWARE (
    IF %DX_DOCKER_IMAGE_SEARCH_MIDDLEWARE%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_SEARCH_MIDDLEWARE%)	
) ELSE IF %%m==DX_DOCKER_IMAGE_PEOPLE_SERVICE (
    IF %DX_DOCKER_IMAGE_PEOPLE_SERVICE%=="" ( echo %%m=%%n) ELSE ( echo %%m=%DX_DOCKER_IMAGE_PEOPLE_SERVICE%)	
) else ( echo %%m)
))>result.properties
DEL dx.properties
rename result.properties dx.properties
echo Task completed.
EXIT /B 0
