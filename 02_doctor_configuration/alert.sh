#!/bin/bash
#author: zang yuan
#send notification to congress

username="admin"
password="4MbCBXaqHJmARqpWzFNJFQF2T"
congress_url="http://192.168.37.12:1789"
keystone_url="http://192.168.37.12:5000/v2.0"

curl $keystone_url"/tokens" -X POST -H "Content-Type: application/json" -H "Accept: application/json"  -d "{\"auth\": {\"tenantName\": $username, \"passwordCredentials\": {\"username\": $username, \"password\": $password}}}" > result.json
token0=$(jq .access.token.id result.json)
echo $token0
token=${token0//\"/}
echo $token

rm result.json
#overcloud-novacompute-0.opnfvlf.org

#sendtime=`date`
eventtype="compute.host.down"
hostname="overcloud-novacompute-0.opnfvlf.org"
date=$(date +%Y-%m-%d)
hms=$(date +%H:%M:%S)
sendtime=${date}T${hms}Z 
curl -i -X PUT $congress_url/v1/data-sources/doctor/tables/events/rows -H "Content-Type: application/json" -d "[{\"time\":$sendtime,\"type\":$eventtype,\"details\":{\"hostname\":$hostname,\"status\":\"down\",\"monitor\":\"zabbix1\",\"monitor_event_id\":\"111\"}}]"  -H "X-Auth-Token: $token"


#Linux date format Thu Aug 31 03:06:58 UTC 2017

#congress accept time format "2016-02-22T11:48:55Z"