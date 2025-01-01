#!/bin/bash 
# put your domain in this var
http="http://a9769cb67cd1543f692a2441a029fa86-199594630.us-west-1.elb.amazonaws.com/"

# save the status in some variable 
status=`curl $http -v -k -s -f -o /dev/null && echo "SUCCESS" || echo "ERROR"`    

# print results (or use it in your scripts)
echo "testing $http=$status"

echo "---------------------------------"
echo "Checking with curl -I"
curl -v -I $http/
