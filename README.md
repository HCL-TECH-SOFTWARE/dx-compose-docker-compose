# HCL DX Compose docker-compose

This little scripting enables you to run a fully fledged DX Compose environment with minimal footprint on your local machine.
It uses docker-compose to start/stop and manage Docker containers.
Docker-compose an addon on top of Docker.
On Mac OS Docker desktop docker-compose is available out of the box.
On other OS, you might need to manually install docker-compose even if you have docker installed already.
For installation instructions see: <https://docs.docker.com/compose/install/>

## Setup your environment

Start by cloning this repository locally and cd into the `dx-compose-docker-compose` directory.

All you need to do is to load the HCL DX Compose docker images into your local docker repository and set up your local environment with some environment variables.

### Loading DX Compose docker images

The load.sh script expects a path to a directory containing the docker image archives as a command line argument <docker-image-archives-directory>.

> **_NOTE:_** If you already loaded the DX Compose docker images into a docker repository of your choice, you may skip executing `load.sh` or `load.bat`.
Please make sure to update the image names in the `dx.properties` file appropriately.

Linux/MAC:

```bash
cd ./dx-compose-docker-compose
bash load.sh <docker-image-archives-directory>
```

Windows:

```bash
cd ./dx-compose-docker-compose
load.bat <docker-image-archives-directory>
```

### Set up local environment variables

If the docker compose is not running on local, then DX_HOSTNAME value in set.sh/set.bat needs to be modified accordingly.

Linux/MAC:

```bash
cd ./dx-compose-docker-compose
source ./set.sh
```

Windows:

```bash
cd ./-compose-docker-compose
set.bat
```

> **_NOTE:_** The second command is **source ./set.sh** and not just executing set.sh directly.

If you want to unset your DX Compose docker-compose environment, you can do so by running `unset.sh`:

Linux/MAC:

```bash
cd ./dx-compose-docker-compose
source ./unset.sh
```

Windows:

```bash
cd ./dx-compose-docker-compose
unset.bat
```

> **_NOTE:_** By applying the above change, any change you apply in DX Compose WebEngine will not be persisted. All your changes will be lost as soon as the container is stopped.

## Create the correct certificates
```
source ./createCerts.sh
```

## Starting the environment

After setting your environment, you can start the DX Compose docker-compose environment by running. **Important** is that you need to be using a minimum version `1.27.4` for `docker-compose`.

```bash
docker-compose up
```

This will start all services defined in `dx.yaml` and logs will be printed directly go to your bash.
You can stop docker-compose in this situation by pressing `CTRL+C`.

If your user does not have permission to write to the persistent volumes location (folder `dx-compose-docker-compose/volumes`) specified in the docker-compose file dx.yaml, you will see errors and the system will not start properly. If necessary, change the permissions of this folder so that the user running the docker process can read from and write to it.

Here are some useful command line arguments to run `docker-compose up`:

- `-d, --detach`: detached mode
- `--remove-orphans`: this cleans up orphaned containers

For more information on startup parameters for `docker-compose up`, please see <https://docs.docker.com/compose/reference/up/>.

## Stopping the environment

If you didn't start docker-compose in detached mode, you can stop by pressing `CTRL+C`.
If you started docker-compose in detached mode, you can stop your environment by issuing

```bash
docker-compose stop
```

This will securely stop all running docker containers.
If you want to properly clean up your system and even purge stopped docker containers, you can do so by issuing

```bash
docker-compose down
```

## Looking at logs and metrics

### Logs

If you want to look at logs for all of the DX Compose services, you can easily do so by running

```bash
docker-compose logs
```

This will show you all system out logs of all services of all running containers (might be quite a lot - see tips and tricks below).

### Metrics

You can also look at CPU, memory and network consumption using

```bash
docker stats
```

Example output:

```bash

NAME                    CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O         PIDS
dx-haproxy              0.00%     7.008MiB / 31.21GiB   0.02%     11.1MB / 10.8MB   0B / 0B           9
dx-dam                  0.27%     493.4MiB / 31.21GiB   1.54%     263MB / 381MB     8.19kB / 19.5kB   78
dx-dam-db-pool          0.05%     116.8MiB / 31.21GiB   0.37%     586MB / 659MB     0B / 1.44MB       36
dx-ringapi              0.17%     104.2MiB / 31.21GiB   0.33%     1.45MB / 1.2MB    0B / 24.1kB       23
dx-dam-db-node-0        0.07%     63.26MiB / 31.21GiB   0.20%     414MB / 233MB     0B / 15.6MB       14
dx-webengine                 0.80%     2.137GiB / 31.21GiB   6.85%     1.62MB / 6.71MB   436MB / 563MB     375
dx-cc                   0.19%     71.73MiB / 31.21GiB   0.22%     7.7kB / 0B        0B / 11.3kB       58
dx-image-processor      0.17%     426.3MiB / 31.21GiB   1.33%     17.5MB / 4.27MB   0B / 23kB         23
dx-peopleservice        0.00%     139.8MiB / 11.67GiB   1.17%     416kB / 86.2kB    70.9MB / 12.1MB   24
dx-fileprocessor        0.43%     236.2MiB / 31.21GiB   0.01%     18.6kB / 17.5kB   73.7MB / 143kB    67
dx-search-middleware    0.59%     120.8MiB / 31.21GiB   0.01%     644kB / 356kB     70MB / 8.19kB     43
dx-opensearch-manager   0.69%     1.531GiB / 31.21GiB   0.04%     294kB / 272kB     179MB / 16.6MB    169

```

To get an overview of running docker-compose services, you can run

```bash
docker-compose ps
```

Example output:

```bash
IMAGE                                                             COMMAND                     CREATED     STATUS               PORTS                                                                                              NAMES
hcl/dx-compose/haproxy:v1.21.0_20250203-2240                      "/bin/bash entrypoin…"      3 days ago  Up 3 days            0.0.0.0:80->8081/tcp                                          dx-haproxy
hcl/dx-compose/digital-asset-manager:v1.37.0_20250203-2300        "/opt/app/start_all_…"      3 days ago  Up 3 days            0.0.0.0:4001->3001/tcp                                       dx-dam
hcl/dx-compose/persistence-connection-pool:v1.35.0_20250203-2301  "/scripts/entrypoint…"      3 days ago  Up 3 days (healthy)  0.0.0.0:5432->5432/tcp                                       dx-dam-db-pool
hcl/dx-compose/ringapi:v1.38.0_20250203-2244                      "/opt/app/start_all_…"      3 days ago  Up 3 days            0.0.0.0:4000->3000/tcp                                       dx-ringapi
hcl/dx-compose/persistence-node:v1.25_20250203-2242               "/start_postgres.sh"        3 days ago  Up 3 days (healthy)  0.0.0.0:5433->5432/tcp                                       dx-dam-db-node-0
hcl/dx-compose/webengine:CF225_20250204-1935                      "sh -c /opt/app/entr…"      3 days ago  Up 3 days            7777/tcp, 0.0.0.0:9080->9080/tcp, 9091/tcp, 10033/tcp, 0.0.0.0:9443->9443/tcp  dx-webengine
hcl/dx-compose/content-composer:v1.38.0_20250203-2223             "/opt/app/start_all_…"      3 days ago  Up 3 days            0.0.0.0:5001->3000/tcp                                       dx-cc
hcl/dx-compose/image-processor:v1.38.0_20250203-2244              "/home/dx_user/start…"      3 days ago  Up 3 days            0.0.0.0:3500->8080/tcp                                       dx-image-processor
hcl/dx-compose/people-service:v1.0.0_20250203-2223                "/home/dx_user/entry…"      3 days ago  Up 3 days            0.0.0.0:7001->3000/tcp                                       dx-peopleservice
hcl/dx-compose/dx-file-processor:v2.0.0_20250203-2240             "/bin/sh -c 'exec ja…"      3 days ago  Up 3 days            0.0.0.0:9998->9998/tcp                                       dx-fileprocessor
hcl/dx-compose/dx-search-middleware:v2.0.0_20250207-1433          "/home/dx_user/start…"      3 days ago  Up 3 days            0.0.0.0:3000->3000/tcp                                       dx-search-middleware
hcl/dx-compose/dx-opensearch:v2.0.0_20250207-1432                 "./opensearch-docker…"      3 days ago  Up 3 days            9300/tcp, 9600/tcp, 0.0.0.0:9200->9200/tcp, 9650/tcp         dx-opensearch-manager
```

## Tips and tricks

### Docker-compose services and load balancing

The core of a docker-compose environment are its services.
In the case of DX Compose, each of the different DX Compose components (WebEngine, CC, DAM, ...) is a individual docker-compose service.
The services are all described and configured in `dx.yaml`.
Amongst other configurations, each service has a external port defined.

Inside a docker-compose environment all containers of a particular service are reachable via their service name.
If you connect into a docker container running in docker-compose, you'll be able to resolve the service name via dns. You could do so by just pinging the image processor (service name "image-processor") from any other container.
See below on how to bash into a docker-compose container.

###  Databases and DAM startup issue

In few machines, permissions for volumes on database seems to be causing issues with the startup. Couple of workarounds for this issue is:

1. Provide appropriate permissions `chmod 750 -R volumes`.
2. If permissions do not help, then remove the (volumes) following lines for `db-node-0` service in `dx.yaml`
```yaml
      volumes:
        - ./volumes/dam/db:/var/lib/pgsql/11/data
```
Execute `docker-compose down` and `docker-compose up -d` again. If all the instances are not up, then execute `docker-compose watch` to restart the failed containers and verification.

In addition to the above, if `db-node-0` or `db-pool` or `dam` is down, verify and start the services in the sequence.

1. start `db-node-0` manually using `docker-compose start db-node-0`. Ensure the Database is up and running by verifying the logs. If the process is exited, try restarting it again.
2. Once the `db-node-0` is up, start `db-pool` using `docker-compose start db-pool`. Verify the logs and ensure `db-pool` is able to connect to the `db-node-0`.
3. Start `dam` if the `db-pool` is up using `docker-compose start dam`. Verify the logs to see if DAM is running.


### Running DX Compose docker-compose in a hybrid setup

In the case that you already have a fully configured DX Compose WebEngine (e.g. an on premise installation) up and running, you can choose to configure docker-compose to connect to the on premise environment.
The below mentioned changes in `dx.yaml` need to be applied to make this work.

> **_NOTE:_** You will also have to configure your DX Compose WebEngine environment to connect to the services running docker-compose (e.g. configuration of DAM and Content Composer portlets). Please have a look in the official HCL DX Compose Help Center to understand which changes need to be done, if necessary.

Update the Ring API service configuration as described:

1. Disable the `depends_on` parameter.

```yaml
ringapi:
  # depends_on:
  #   - webengine
```

2. Update the `PORTAL_HOST` parameter values.

```yaml
environment:
  - PORTAL_HOST=example.com
```

The result of the changes to the `ringapi` service should look similar to the snippet below:

```yaml
ringapi:
  # depends_on:
  #   - dx-webengine
  image: ${DX_DOCKER_IMAGE_RINGAPI:?'Missing docker image environment parameter'}
  environment:
    - DEBUG=ringapi-server:*
    - PORTAL_PORT=10039
    - PORTAL_HOST=example.com
  ports:
    - "4000:3000"
  networks:
    - default
```

Update the Content Composer service configuration as described:

```yaml
environment:
  - PORTAL_HOST=example.com
```

### Starting and stopping individual services

#### Docker-compose up

`docker-compose up` allows you to start only individual services.
To only start the DAM service, you could run

```bash
docker-compose up -d dam
```

For more information see <https://docs.docker.com/compose/reference/up/>

#### Docker-compose stop

`docker-compose stop` allows you to stop only individual services.
To only stop the DAM service, you could run

```bash
docker-compose stop dam
```

For more information see <https://docs.docker.com/compose/reference/down/>

#### Docker-compose logs

To only look at logs for an individual service you can run

```bash
docker-compose logs dam
```

For more information see <https://docs.docker.com/compose/reference/logs/>

### Installing Applications CC and DAM and SearchV2 and PeopleService in DX Compose WebEngine
#### Prerequisites
```bash
sudo mkdir /var/log/liberty
sudo chown -R  $USER:$USER  /var/log/liberty
```

To install CC and DAM and SearchV2 and PeopleService applications in DX Compose WebEngine and to enable , 
##### Arguments
- -enableDAM: if set true/false need to enable/disable DAM in the DX Compose WebEngine respectively.
- -enableCC: if set true/false need to enable/disable CC in the DX Compose WebEngine respectively.
- -enableSearchV2: if set true/false need to enable/disable SearchV2 in the DX Compose WebEngine respectively.
- -enablePeopleService: if set true/false need to enable/disable PeopleService in the DX Compose WebEngine respectively.


Linux/MAC:

```bash
cd ./dx-compose-docker-compose
source ./installApps.sh -enableDAM true -enableCC false -enableSearchV2 true -enablePeopleService true
```

Windows:

```bash
cd ./dx-compose-docker-compose
installApps.bat -enableDAM true -enableCC false -enableSearchV2 true -enablePeopleService true
```

> **_NOTE:_** For any change in Search, you need to restart the webengine to ensure Search page, theme, and portlet have no caching issues.

> **_NOTE:_** For any change in DAM, you need to restart the webengine, otherwise DAM Picker will not work as expected

> **_NOTE:_** For any change in DX_HOSTNAME it's a must to restart dx-webengine and re-execute installApps.sh / installApps.bat

### Integrating Search API and UI in DX WebEngine

To install Search applications in DX WebEngine and to enable ,

#### Arguments

- -DENABLE: if set true/false need to enable/disable Search in the DX WebEngine respectively.
- -Dsearch.middleware.ui.uri: URL of search middleware, for eg: `http://dx-search-middleware:3000/dx/ui/search`
- -Dsearch.input.redirect.version: search version for input, eg: 2
- -Dsearch.wcm.version: search version for WCM, eg: 2

```bash
cd ./dx-compose-docker-compose
source /opt/openliberty/wlp/usr/svrcfg/bin/manageSearchV2.sh -DENABLE=true -Dsearch.middleware.ui.uri=http://dx-search-middleware:3000/dx/ui/search -Dsearch.input.redirect.version=2 -Dsearch.wcm.version=2
```

NOTE: For any change in Search need to restart the webengine container

Check that the search-middleware API is up and running
```bash
http://localhost/dx/api/search/v2/explorer
```

Check that the searchCenter UI is up and running
```bash
http://localhost/wps/portal/Practitioner/SearchCenter
```

### Using Search API and UI in DX WebEngine

#### Create JWT token
Open the `search-middleware` API explorer (http://localhost/dx/api/search/v2/explorer). Do an authentication via the `/admin/authenticate` endpoint with the `searchadmin` user. The JWT token is now needed for the authorization. Do authorization with `Bearer JWT_TOKEN`.

#### Create a content source
To create a `WCM` content source, use the POST `contentsources` endpoint with the following example payload.
```
{
  "name": "MyWCM",
  "type": "wcm",
  "aclLookupHost": "http://dx-webengine:9080",
  "aclLookupPath": "/wps/mycontenthandler"
}
```

The `aclLookupPath` is using this pattern - `<CONTEXT-ROOT>/mycontenthandler/<VP-CONTEXT>`.

The response `id` would then be needed to create its specific WCM crawler. The `dx-webengine` container will be used as WCM data source.


#### Create a crawler
To create a crawler for the `WCM` content source, use the POST `crawlers` endpoint. Please replace the `<CONTENT-SOURCE-ID>` with the correct `id`. The following payload can be used to create the `WCM` crawler. 

```
{
  "contentSource": "<CONTENT-SOURCE-ID>",
  "type": "wcm",
  "configuration": {
    "targetDataSource": "http://dx-webengine:9080/wps/seedlist/server?SeedlistId=&Source=com.ibm.workplace.wcm.plugins.seedlist.retriever.WCMRetrieverFactory&Action=GetDocuments",
    "schedule": "*/5 * * * *",
    "security": {
      "type": "basic",
      "username": "wpsadmin",
      "password": "wpsadmin"
    },
    "maxCrawlTime": 0,
    "maxRequestTime": 0
  }
}
```
http://dx-webengine/wps/seedlist/server?SeedlistId=&Source=com.ibm.workplace.wcm.plugins.seedlist.retriever.WCMRetrieverFactory&Action=GetDocuments

The crawler needs a bit of time to collect all the WCM data. It also depends on the `schedule` parameter (for example, in the sample payload above, schedule is every 5 minutes). Check the middleware logs to get info if the crawler is done. You can also use the GET `crawlers` endpoint to check on the crawler status.

When the crawler status is finished, you can now use the Search UI to query.

```bash
http://localhost/wps/portal/Practitioner/SearchCenter
```


### Connecting to your DX Compose and applications.

To access your DX Compose environment, navigate to _http://<PORTAL_HOST>/wps/portal_

Example: http://example.com/wps/portal

To access DX Compose admin console, navigate to _https://<PORTAL_HOST>:9443/adminCenter/login.jsp

Example: https://example.com:9443/adminCenter/login.jsp

### Connecting into a docker-compose service via bash

To bash into a docker container of a service, you can directly connect using the service name

```bash
docker-compose exec dam bash
```

To connect into a specific container of a service (if there is multiple containers running for a service), you have to look up the name of the container e.g. using `docker-compose ps` and then run

```bash
docker exec -it dx_dam bash
```

### Running Prerequisite Checks to your DX Compose and applications.

To perform checks to the mounted volumes, you can directly connect using the dx-prereqs-checker container

```bash
docker-compose exec prereqs-checker /bin/bash /usr/local/sbin/run_test.sh
```

To display the logs of the check results, run

```bash
docker-compose logs prereqs-checker
```
    
### Access DX on Liberty at default HTTPS port 443

Steps for configuring SSL to access Digital Experience (DX) on Liberty at the default HTTPS port 443 through HAProxy.

Begin by generating a self-signed certificate. Use the following command to create the certificate:
```
openssl req -x509 -newkey rsa:2048 -keyout tls.key -out tls.crt -days 365 -nodes
```
Next, copy the generated certificate files (tls.key and tls.crt) into the HAProxy container. Use the docker cp command for this task:
```
docker cp <path to file>/tls.key dx-haproxy:/etc/ssl/certs/
docker cp <path to file>/tls.crt dx-haproxy:/etc/ssl/certs/
```

Update the dx.yaml file to include the necessary port mappings for HAProxy. Ensure the following mapping is added:
```
ports:
  - "443:8083"
```

Edit the haproxy.cfg file to add frontend and backend configurations. Include the following configuration:
```
frontend dx-https
  bind :8083 ssl crt /etc/ssl/certs/tls
  use_backend dam if { path -m reg ^/dx/(api|ui)/dam/ }
  use_backend content if { path_beg /dx/ui/content/ }
  use_backend image-processor if { path_beg /dx/api/image-processor/ }
  use_backend ring-api if { path_beg /dx/api/core/ }
  default_backend webengine-dx-home-ssl
backend webengine-dx-home-ssl
  server webengine-ssl dx-webengine:9443 check resolvers nameserver init-addr none
```

Finally, restart the HAProxy Docker container to apply the new configuration:
```
docker restart dx-haproxy
```
