#!/bin/bash
URL=http://45.33.82.63/
RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null ${URL})
if [ $RESPONSE -ne 200 ]
then
    echo 'Application deployed failed !'
    exit 1
else
 echo 'Application deployed succesfully !'
fi