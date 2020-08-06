# Puppetforge Prometheus Pushgateway Exporter
Puppetforge Prometheus Pushgateway Exporter - Fetch and export module details

## Introduction

A Puppetforge Prometheus Pushgateway Exporter for fetching details about your
[Puppet Forge](https://forge.puppet.com/) account and modules and pushing them to
a Prometheus Pushgateway.

This is implemented as a push gateway client rather than a standard
exporter to be a good API client and reduce the traffic against the
Puppet Forge service. In most cases you won't need to collect metrics
more than once a day, possibly with an extra run once you've pushed a
new module or release.

## Usage

    puppetforge-exporter.rb deanwilson

![Metrics Gateway with Puppetforge Prometheus Pushgateway Exporter metrics](/images/puppetforge-exporter-metrics-webui.png "Metrics Gateway with Puppetforge Prometheus Pushgateway Exporter metrics")

## Configuration

### Pushgateway
You can configure the remote pushgateway to send the metrics to via
commandline switches or environment variables. If both are specified the
switches take precedence.

Environment variables:

    export PUPPETFORGE_EXPORTER_HOST=http://10.10.100.100
    export PUPPETFORGE_EXPORTER_PORT=99999
    puppetforge-exporter.rb deanwilson

Or using the switches:

    puppetforge-exporter.rb deanwilson --host http://10.10.100.100 --port 99999

### Users

You can specify which Puppet Forge users to query in three different ways

    PUPPETFORGE_EXPORTER_USERS=deanwilson
    puppetforge-exporter.rb

Is overridden by

    puppetforge-exporter.rb deanwilson

which are both overridden by

    puppetforge-exporter.rb --users deanwilson

In the first and last case you can specify multiple users as comma seperated strings.

    export PUPPETFORGE_EXPORTER_USERS=deanwilson,notdeanwilson
    puppetforge-exporter.rb --users deanwilson,notdeanwilson
    puppetforge-exporter.rb deanwilson notdeanwilson # no comma

## Author

 * [Dean Wilson](https://www.unixdaemon.net)
