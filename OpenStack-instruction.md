# OpenStack instruction


## Aodh

### Create Alarm

    常用alarm type： 
        composite、event、

        Threshold based alarm

        Composite alarm

        Event based alarm

    常用event type：

    常用
        alarm action
    
        ok-action  
        
            An action to invoke when the alarm state transitions to ok.
        
        insufficient-data-action

            An action to invoke when the alarm state transitions to insufficient data.


        webhooks  

            an HTTP POST request being sent to an endpoint, with a request body containing a description of the state transition encoded as a JSON fragment.

        log actions

            These are a lightweight alternative to webhooks, whereby the state transition is simply logged by the alarm-notifier, and are intended primarily for testing purposes.

    Alarm state : 
        ok 、 alarm、 insufficient-data



    aodh alarm create \
    --name meta \
    --type composite \
    --composite-rule '{"or": [{"threshold": 0.8, "metric": "cpu_util", \
    "type": "gnocchi_resources_threshold", "resource_id": INSTANCE_ID1, \
    "resource_type": "instance", "aggregation_method": "last"}, \
    {"threshold": 0.8, "metric": "cpu_util", \
    "type": "gnocchi_resources_threshold", "resource_id": INSTANCE_ID2, \
    "resource_type": "instance", "aggregation_method": "last"}]}' \
    --alarm-action 'http://example.org/notify'


    aodh alarm create \
    --name meta \
    --type composite \
    --composite-rule '{"or": [ALARM_1, {"and": [ALARM_2, ALARM_3]}]}' \
    --alarm-action 'http://example.org/notify'



    aodh alarm create \
    --type event \
    --name instance_off \
    --description 'Instance powered OFF' \
    --event-type "compute.instance.power_off.*" \
    --enable True \
    --query "traits.instance_id=string::INSTANCE_ID" \
    --alarm-action 'log://' \
    --ok-action 'log://' \
    --insufficient-data-action 'log://'


    aodh alarm create \
    --name cpu_hi \
    --type gnocchi_resources_threshold \
    --description 'instance running hot' \
    --metric cpu_util \
    --threshold 70.0 \
    --comparison-operator gt \
    --aggregation-method mean \
    --granularity 600 \
    --evaluation-periods 3 \
    --alarm-action 'log://' \
    --resource-id INSTANCE_ID \
    --resource-type instance





### Update Alarm

        aodh alarm update --enabled False ALARM_ID

### Delete Alarm

        aodh alarm delete ALARM_ID

### Show Alarm

        aodh alarm list

### Show Alarm History

        aodh alarm-history show ALARM_ID

### Get Alarm State

        openstack alarm state get ALARM_ID

### Set Alarm State

        openstack alarm state set --state ok ALARM_ID



## Nova



## Congress


## Celiometer