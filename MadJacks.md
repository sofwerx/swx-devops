# MadJacks.md

Mad Jack's cyber range currently has the following topology:

Local

  https://kibana.bluerange0.devwerx.org:20443/
  - Steve's laptop

  range0
  range1
  range2
  range3?
   - all have HackRF SDRs and GPS units attached via USB, and are sending data to elasticsearch on redrange1

  redrange1 - Petar's laptop in the Blue Team pit
   - https://elasticsearch.redrange1.devwerx.org:51443/
   - https://kibana.redrange1.devwerx.org:51443/
   - The `gammarf` index is being populated by range0, range1, and range2

  bluerange0 - Steve's laptop in the Blue Team pit
   - https://elasticsearch.bluerange0.devwerx.org:20443/
   - https://kibana.bluerange0.devwerx.org:20443/
   - The `pcap-*` indexes are being populated from the tshark pcap container running on that machine watching the ethernet interface
   - The `logstash-*` indexes are being populated from syslog messages from wireless APs and network switches on the brange network

  bluerange1 - Laptop in the SafeHouse
   - https://bluerange1.devwerx.org:21001
     - IFTTT to ElasticSearch gateway that sends events from August smart locks over to blueteam elasticsearch
   - https://192.168.0.109:8080
   - https://192.168.0.109:8081
     - `motion` container is watching the camera at 192.168.0.164 via RTSP, and is sending ElasticSearch events over to `motion` index on blueteam elasticsearch.
   - David's `persondetect` image is running as a container, watching the same RTSP camera at 192.168.0.164, sending events over to blueteam elasticsearch.
   - http://192.168.0.109.3000
     - Domoticz notification gateway `es-domoticz-notify` sends events posted by Domoticz over to blueteam elasticsearch

  tegra-safehouse - "Wheels" - Jetson TX2 in the SafeHouse mounted to the RC wheels.
    - domoticz is running here as a systemd service, monitoring the USB zwave attached devices
      - motion sensor
      - light sensor
    - domoticz is posting notification messages for device events to the `es-domoticz-notify` gateway on bluerange1

AWS

  blueteam
    - https://elasticsearch.blueteam.devwerx.org
    - https://kibana.blueteam.devwerx.org
    - `gammarf` index is being synchronized from redrange1 in a loop every 5 minutes
    - `pcap-*` indexes are being synchronized from bluerange0 in a loop every 4 hours
    - `ifttt-*` indexes are being populated by the es-ifttt container on bluerange1
    - `domoticz-*` indexes are being populated by the es-domoticz container on bluerange1
    - `motion` index is being populated by the motion container on bluerange1


