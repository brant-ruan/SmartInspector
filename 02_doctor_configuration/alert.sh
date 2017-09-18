#!/bin/bash

USER_NAME="admin"
PASSWORD="FZKueDaeuZ72nuDHXjmzfBkzD"
CONGRESS_URL="http://192.0.2.9:1789"
KEYSTONE_URL="http://192.0.2.9:35357/v2.0"
COMPUTE_HOSTNAME = "overcloud-novacompute-0.opnfvlf.org"

curl $KEYSTONE_URL"/tokens" -X POST -H "Content-Type: application/json" -H "Accept: application/json"  -d "{\"auth\": {\"tenantName\": \"admin\", \"passwordCredentials\": {\"username\": \"admin\", \"password\": \"$PASSWORD\"}}}" > result.json
token0=$(jq .access.token.id result.json)
echo $token0
token=${token0//\"/}
echo $token
rm -f result.json

#sendtime=`date`
eventtype="compute.host.down"
date=$(date +%Y-%m-%d)
hms=$(date +%H:%M:%S)
SENDTIME=${date}T${hms}Z

curl -i -X PUT $CONGRESS_URL/v1/data-sources/doctor/tables/events/rows -H "Content-Type: application/json" -d "[{\"time\":\"$SENDTIME\",\"type\":\"compute.host.down\",\"details\":{\"hostname\":\"$COMPUTE_HOSTNAME\",\"status\":\"down\",\"monitor\":\"zabbix1\",\"monitor_event_id\":\"111\"}}]" -H "X-Auth-Token: $token"
#curl -i -X PUT $CONGRESS_URL/v1/data-sources/doctor/tables/events/rows -H "Content-Type: application/json" -d '[{"time":"2016-02-22T11:48:55Z","type":"compute.host.down","details":{"hostname":"overcloud-novacompute-0.opnfvlf.org","status":"down","monitor":"zabbix1","monitor_event_id":"111"}}]'  -H "X-Auth-Token: $token"
#curl -i -X PUT $congress_url/v1/data-sources/doctor/tables/events/rows -H "Content-Type: application/json" -d '[{\"time\":"2016-02-22T11:48:55Z",\"type\":\"compute.host.down\","details":{"hostname":"overcloud-novacompute-0.opnfvlf.org","status":"down","monitor":"zabbix1","monitor_event_id":"111"}}]'  -H "X-Auth-Token: $token"