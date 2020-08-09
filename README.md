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

### Command line

    puppetforge-exporter.rb deanwilson

![Metrics Gateway with Puppetforge Prometheus Pushgateway Exporter metrics](/images/puppetforge-exporter-metrics-webui.png "Metrics Gateway with Puppetforge Prometheus Pushgateway Exporter metrics")

### Docker image

To run `puppetforge-exporter.rb` with docker, using all the default values including
only checking my PuppetForge user name:

    docker run --net host --rm deanwilson/puppetforge-prometheus-exporter:latest

The minumum configuration you will probably need is to change
`PUPPETFORGE_EXPORTER_USERS` to point at your own use. This can be done
by rebuilding the docker images, specifying the `--users` flag or passing
a custom `PUPPETFORGE_EXPORTER_USERS` environment variable.

    docker run --net host --env PUPPETFORGE_EXPORTER_USERS=cnafsd --rm deanwilson/puppetforge-prometheus-exporter:latest

    docker run --net host --rm deanwilson/puppetforge-prometheus-exporter:latest --users cnafsd

The Configuration section contains more information on which settings you can change.

## Configuration

### Pushgateway

You can configure which remote pushgateway to send metrics to via
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
