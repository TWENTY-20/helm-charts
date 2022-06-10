# Helm chart for Checkmk Server

## Features
- livestatus is supported
- tmpfs for better performance

## Supported versions
- check-mk-raw
- check-mk-free

## Livestatus
Livestatus can be enabled in values.yaml
To access livestatus from external you must add a new tcp port in your ingress-controller and link it to the checkmk-service.

## Todo
- add support for enterprise version 