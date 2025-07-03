<!-- #p100003 -->
# Creating a Docker Image for your Scanner

<!-- #p100009 -->
:::note\[Disclaimer\] This Docker documentation is provided as an example. Adapt it to your context, following the online documentation about how to run a Zeenea Scanner. :::

<!-- #p100015 -->
## Introduction

<!-- #p100021 -->
Zeenea doesn’t provide an official Scanner image, but it’s rather easy to build your own.

<!-- #p100027 -->
This article shares all the necessary information you need to define your own image.

<!-- #p100033 -->
As it is an example, feel free to adapt this recommendation to your context.

<!-- #p100039 -->
## Dockerfile example

<!-- #p100045 -->
Here is a simple Dockerfile example:

<!-- #p100051 -->
<font color="red">
Missing image
</font>

<!-- #p100063 -->
Zeenea Scanner requires Java 11 to run — the image is based on Openjdk JRE 11 Slim.

<!-- #p100069 -->
It creates a user, having only the expected privileges, as described in our Scanner documentation. You can give him a Group and User ID to ease the administration out of the container, but that’s not mandatory at all.

<!-- #p100075 -->
## Get the binary

<!-- #p100084 -->
First, let’s create a fresh new folder, named, for instance, `zeenea-docker`.

<!-- #p100090 -->
Download (or get from our support) the Zeenea Scanner you want to dockerize.

<!-- #p100105 -->
Unzip the archive into `zeenea-docker` and rename the scanner folder `zeenea-scanner-latest` (instead of `zeenea-scanner-VERSION`)

<!-- #p100111 -->
## Build your image

<!-- #p100117 -->
Before building, you’ll need a startup script you image will use to run the Scanner process.

<!-- #p100126 -->
Here is an example of such a file. Save it as `entrypoint.sh`:

<!-- #p100132 -->
<font color="red">
Missing image
</font>

<!-- #p100150 -->
Copy your Dockerfile and `entrypoint.sh`, based on the examples above, into `zeenea-docker`.

<!-- #p100156 -->
Then, build your own Docker image:

<!-- #p100165 -->
`docker build -t zeenea-scanner:latest`

<!-- #p100171 -->
## Prepare your Scanner configuration

1. <!-- #p100177 -->
   Create four folders wherever you want:

   <!-- #p100186 -->
   `mkdir -p {conf,connections,plugins,logs}`

2. <!-- #p100204 -->
   Copy the file `application.conf.template` from the previously downloaded scanner into the `conf` folder with `application.conf` as its new name.

3. <!-- #p100225 -->
   Modify `application.conf` as needed. See [Managing Scanners](zeenea-managing-scanners.md# "Managing Scanners").

4. <!-- #p100240 -->
   Copy `log4.xml` file into the `conf` folder.

5. <!-- #p100249 -->
   Modify its content if necessary.

6. <!-- #p100264 -->
   Drop your plugins into the `plugins` folder and configure your connections in the `connections` folder.

<!-- #p100276 -->
As you may have multiple scanners, each will have its own name.

<!-- #p100282 -->
This name is very important as it determines which scanner handles which connection.

<!-- #p100288 -->
This name will be provided as an env variable to the container (see below).

<!-- #p100294 -->
## Run your Dockerized Zeenea Scanner

<!-- #p100303 -->
Considering your four folders were created locally under `/opt/zee`, the startup script may be as follows:

<!-- #p100309 -->
```
SCANNER_NAME=myscanner-identifier &&
docker run \
 -d \
 -h $SCANNER_NAME \
 --name $SCANNER_NAME \
 -v /opt/zee/conf:/opt/zeenea-scanner/conf:rw \
 -v /opt/zee/connections:/opt/zeenea-scanner/connections:rw \
 -v /opt/zee/plugins:/opt/zeenea-scanner/plugins:rw \
 -v /opt/zee/logs:/opt/zeenea-scanner/logs:rw \
 -e SCANNER_IDENTIFIER=$SCANNER_NAME \
 -e JAVA_XMX=4g \
 --restart unless-stopped \
 zeenea-scanner:latest
```

<!-- #p100315 -->
Your container will share the name by which Zeenea platform knows it.

<!-- #p100324 -->
Choose a unique name and set the `SCANNER_NAME` env variable.

<!-- #p100330 -->
If you upgrade or have to destroy and recreate the container, stick with the name initially chosen so that the platform will consider the new running scanner as the one previously registered.

