#!/bin/bash

#!/usr/bin/env bash

cat >/etc/motd <<EOL
    __ __          __      __    _ __
   / //_/_  _ ____/ /_  __/ /   (_) /____
  / ,< / / / / __  / / / / /   / / __/ _ \

 / /| / /_/ / /_/ / /_/ / /___/ / /_/  __/
/_/ |_\__,_/\__,_/\__,_/_____/_/\__/\___/


DEBUG CONSOLE | AZURE APP SERVICE ON LINUX

Documentation: http://aka.ms/webapp-linux
Kudu Version : 1.0.0.7
Commit       : `cat /kudu_commit.log`

EOL

cat /etc/motd

if [ $# -ne 5 ]; then
	echo "Missing parameters; exiting"
	exit 1
fi

if [ -z "${PORT}" ]; then
        export PORT=8181
fi

GROUP_ID=$1
GROUP_NAME=$2
USER_ID=$3
USER_NAME=$4
SITE_NAME=$5

mkdir -p /tmp/BuildScriptGenerator

groupadd -g $GROUP_ID $GROUP_NAME
useradd -u $USER_ID -g $GROUP_NAME $USER_NAME
#chown -R $USER_NAME:$GROUP_NAME /tmp/oryx
#chown -R $USER_NAME:$GROUP_NAME /tmp/BuildScriptGenerator
#chown -R $USER_NAME:$GROUP_NAME /tmp/zipdeploy
mkdir -p /home/LogFiles/webssh

/bin/bash -c "pm2 start /opt/webssh/index.js -o /dev/null -e /home/LogFiles/webssh/pm2.err &"
sed -i "s/webssh-port-placeholder/$KUDU_WEBSSH_PORT/g" /opt/webssh/config.json

export KUDU_RUN_USER="$USER_NAME"
export HOME=/home
export WEBSITE_SITE_NAME=$SITE_NAME
export APPSETTING_SCM_USE_LIBGIT2SHARP_REPOSITORY=0
export KUDU_APPPATH=/opt/Kudu
export APPDATA=/opt/Kudu/local


# Get environment variables to show up in SSH session
eval $(printenv | awk -F= '{print "export " $1"="$2 }' >> /etc/profile)

service ssh restart

cd /opt/Kudu

echo $(date) running .net core
ASPNETCORE_URLS=http://0.0.0.0:"$PORT" runuser -p -u "$USER_NAME" -- benv dotnet=2.2.8 dotnet Kudu.Services.Web.dll
