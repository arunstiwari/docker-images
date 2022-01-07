#!/usr/bin/env sh
rm /data/index.html
echo "<h1>Welcome from Docker compose!</h1>" >> /data/index.html
echo "<img src='http://bit.ly/mobylogo' />" >> /data/index.html