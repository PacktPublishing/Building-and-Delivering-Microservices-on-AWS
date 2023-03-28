#!/bin/bash 
URL=CLUSTER_URL
RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null ${URL}) 
if [ $RESPONSE -ne 200] 
then 
    echo 'Application deployed failed!' 
    exit 1 
else 
echo 'Application deployed succesfully !' 
fi