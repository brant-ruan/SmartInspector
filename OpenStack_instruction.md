# OpenStack instruction

## Nova

### Restart nova service after modify nvoa.conf
Restart controller nodes
```shell
ansible controller -m shell -a "service openstack-nova-api restart
&& service openstack-nova-cert restart
&& service openstack-nova-consoleauth restart
&& service openstack-nova-scheduler restart
&& service openstack-nova-conductor restart
&& service openstack-nova-novncproxy restart" --sudo 
```
Restart compute nodes
```shell
ansible compute -m shell -a "service openstack-nova-compute restart" --sudo 
```

### Unpause VM
```shell
nova unpause server_name_or_id
```
### Boot VM on specific compute node
Firstly, list all of your avaliable zone
```shell
nova hypervisor-list
```
Boot VM
```shell
nova boot --flavor 4 --image 7ebd2a4b-437f-4017-83b5-0f054149a540 --key-name newbie_test --availability-zone nova:overcloud-novacompute-2.opnfvlf.org your_VM_name
```
### Reset compute node state 
```shell
nova service-force-down --unset overcloud-novacompute-0.opnfvlf.org nova-compute
```
This will set compute node state from down to up
### Reset VM state
```shell
nova reset-state --active a7614957-0674-4898-833f-0251059f5f3b
```
This will set VM state from error to active

## Neutron

Show detailed information of external-net subnet
```shell
neutron subnet-show external-net
```
- Delete subnet
```shell
neutron subnet-delete external-net 
```
- Create new subnet
```shell
neutron subnet-create external 192.168.32.0/24  --name  external-net --dns-nameserver 8.8.8.8 --gateway 192.168.32.1 --allocation-pool start=192.168.32.191,end=192.168.32.250  
```

## Aodh

### Alarm create
```shell
aodh alarm create --name test_alarm --type event --alarm-action "http://127.0.0.1:12346/" --repeat-actions false --event-type compute.instance.update --query "traits.state=string::error"
```
### Delete alarm 
```shell
        aodh alarm delete ALARM_ID
```
### Show alarm 
```shell
        aodh alarm list
```

### Show alarm history
```shell
        aodh alarm-history show ALARM_ID
```
### Get alarm state
```shell
        openstack alarm state get ALARM_ID
```
### Set alarm state
```shell
        openstack alarm state set --state ok ALARM_ID
```

## Ceilometer

## Alarm list
```shell
ceilometer alarm-list
```
## Alarm delete
```shell
ceilometer alarm-delete  5cb446ae-20a9-4010-bda0-3d403ccf6200
```

## Congress

### Create policy rule
```shell
openstack congress policy rule create \
    --name host_down classification \
    'host_down(host) :-
        doctor:events(hostname=host, type="compute.host.down", status="down")'
```
### Delete policy rule
```shell
openstack congress policy rule delete classification host_down
```
## Celiometer