#!/bin/bash

# Copyright 2024 HCL Technologies
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script installs CC and DAM portlets into DX Core running in a docker-compose environment

# Initialize default values
ENABLE_DAM=false
ENABLE_CC=false
ENABLE_SEARCHV2=false
ENABLE_PEOPLE_SERVICE=false

# Helper function to validate boolean values
validate_boolean() {
  if [[ "$1" != "true" && "$1" != "false" ]]; then
    echo "Invalid value for $2: $1. Allowed values are true or false."
    exit 1
  fi
}

# Process command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -enableDAM)
      ENABLE_DAM="$2"
      validate_boolean "$ENABLE_DAM" "enableDAM"
      shift # past argument
      shift # past value
      ;;
    -enableCC)
      ENABLE_CC="$2"
      validate_boolean "$ENABLE_CC" "enableCC"
      shift # past argument
      shift # past value
      ;;
    -enableSearchV2)
      ENABLE_SEARCHV2="$2"
      validate_boolean "$ENABLE_SEARCHV2" "enableSearchV2"
      shift # past argument
      shift # past value
      ;;
    -enablePeopleService)
      ENABLE_PEOPLE_SERVICE="$2"
      PEOPLE_SERVICE_WEBRESOURCES_URI="res:{war:context-root}/modules/peopleservice/js"
      PEOPLE_SERVICE_CONTEXT_ROOT_API="/dx/api/people/v1"
      PEOPLE_SERVICE_CONTEXT_ROOT_PORTLET="/wps/myportal/Practitioner/PeopleService"
      PEOPLE_SERVICE_CONTEXT_ROOT_UI="/dx/ui/people"
      validate_boolean "$ENABLE_PEOPLE_SERVICE" "enablePeopleService"
      shift # past argument
      shift # past value
      ;;
    *)
      echo "Unknown option: $key. Allowed values are -enableDAM true|false, -enableCC true|false, -enableSearchV2 true|false."
      exit 1
      ;;
  esac
done

# Display the parsed values
echo "enableDAM: $ENABLE_DAM"
echo "enableCC: $ENABLE_CC"
echo "enableSearchV2: $ENABLE_SEARCHV2"
echo "enablePeopleService: $ENABLE_PEOPLE_SERVICE"
echo "#############################################################################"
echo "Installing CC and DAM and SearchV2 and PeopleService portlets using DX_HOSTNAME=$DX_HOSTNAME"
echo "#############################################################################"
echo ""
docker exec dx-core sh -c "/opt/openliberty/wlp/usr/svrcfg/bin/manageCC.sh  -Dstatic.ui.url=http://$DX_HOSTNAME/dx/ui/content/static -DENABLE=$ENABLE_CC"
echo "#############################################################################"
echo ""
docker exec dx-core sh -c "/opt/openliberty/wlp/usr/svrcfg/bin/manageDAM.sh -Dstatic.ui.url=http://$DX_HOSTNAME/dx/ui/dam/static -DENABLE=$ENABLE_DAM"
echo "############################################################################"
echo ""
docker exec dx-core sh -c "/opt/openliberty/wlp/usr/svrcfg/bin/manageSearchV2.sh -Dsearch.input.redirect.version=2 -Dsearch.wcm.version=2 -Dsearch.middleware.ui.uri=http://dx-search-middleware:3000/dx/ui/search -DENABLE=$ENABLE_SEARCHV2"
echo "############################################################################"
echo ""
docker exec dx-core sh -c "/opt/openliberty/wlp/usr/svrcfg/bin/managePeopleService.sh -DPEOPLESERVICE_ENABLED=$ENABLE_PEOPLE_SERVICE -DPEOPLESERVICE_WEBRESOURCES_URI=$PEOPLE_SERVICE_WEBRESOURCES_URI -DPEOPLESERVICE_UI_CONTEXT=$PEOPLE_SERVICE_CONTEXT_ROOT_UI -DPEOPLESERVICE_API_CONTEXT=$PEOPLE_SERVICE_CONTEXT_ROOT_API -DPEOPLESERVICE_PORTLET_CONTEXT=$PEOPLE_SERVICE_CONTEXT_ROOT_PORTLET"
echo "############################################################################"
echo "Installed CC and DAM and SearchV2 and PeopleService portlets using DX_HOSTNAME=$DX_HOSTNAME"
echo "############################################################################"
echo ""
# echo "###############################################################"
# echo "Install DXConnect Application and restart config wizard server"
# echo "###############################################################"
# Server restart is not required
# docker exec dx-core sh -c "/opt/openliberty/wlp/bin/server stop defaultServer"
# docker exec dx-core sh -c "/opt/openliberty/wlp/bin/server start defaultServer"
# echo "##################################################################"
# echo "Installed DXConnect Application and restarted config wizard server"
# echo "##################################################################"