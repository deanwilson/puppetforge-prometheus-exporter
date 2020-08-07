#!/usr/bin/env ruby
require 'ostruct'
require 'optparse'
require 'prometheus/client'
require 'prometheus/client/push'
require 'puppet_forge'

APP_NAME = File.basename $PROGRAM_NAME

options = OpenStruct.new({})

options.instance = ENV['PUPPETFORGE_EXPORTER_INSTANCE'] || ''
options.gateway_port = ENV['PUPPETFORGE_EXPORTER_PORT'] || 9091
options.gateway_host = ENV['PUPPETFORGE_EXPORTER_HOST'] || 'http://127.0.0.1'

# username precedence - take the values from the env var, override them
# with any raw command line args and then possibly with the cli switch
# in OptionParser
options.user_names = ENV['PUPPETFORGE_EXPORTER_USERS='] || []
options.user_names = ARGV.sort.uniq

OptionParser.new do |opts|
  opts.banner = <<-ENDOFUSAGE
    #{APP_NAME} queries the given users puppetforge account and sends metrics to a prometheus pushgateway
      $ #{APP_NAME} deanwilson
      ...
      TODO
      ...
  ENDOFUSAGE

  opts.on('--host HOST',
          'The pushgateway host. Defaults to http://127.0.0.1',
          '') { |host| options.gateway_host = host }

  opts.on('--instance INSTANCE',
          'The pushgateway instance label. Defaults to \'\'',
          '') { |instance| options.instance = instance }

  opts.on('--port PORT',
          'The pushgateway port. Defaults to 9091',
          '') { |port| options.gateway_port = port.to_i }

  opts.on('--users USERS',
          'The PuppetForge users. comma separated - deanwilson,notdeanwilson',
          '') { |users| options.user_names = users.split(',') }

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end.parse!

PuppetForge.user_agent = 'PuppetForge-Prometheus-Exporter/0.0.1'
registry = Prometheus::Client.registry

total_modules = Prometheus::Client::Gauge.new(
  :puppetforge_user_modules,
  docstring: 'The number of PuppetForge modules owned by this user.',
  labels: [:name]
)
registry.register(total_modules)

## Metadata about the exporter itself
exporter_info = Prometheus::Client::Gauge.new(
  :puppetforge_exporter,
  docstring: 'A metric with a constant "1" value labeled by version',
  labels: %i[version]
)
registry.register(exporter_info)
exporter_info.set(1, labels: { version: '0.0.3' })

latest_downloads = Prometheus::Client::Gauge.new(
  :puppetforge_module_latest_downloads_total,
  docstring: 'The total downloads for this version of the module.',
  labels: %i[name module]
)
registry.register(latest_downloads)

total_release_count = Prometheus::Client::Gauge.new(
  :puppetforge_user_release_total,
  docstring: 'The total number of releases made by this user over all their modules.', labels: %i[name]
)
registry.register(total_release_count)

total_download_count = Prometheus::Client::Counter.new(
  :puppetforge_module_downloads_total,
  docstring: 'The combined total downloads for all versions of this module.',
  labels: %i[name module]
)
registry.register(total_download_count)

quality = Prometheus::Client::Gauge.new(
  :puppetforge_module_quality_score,
  docstring: 'The PuppetForge quality score for this module.',
  labels: %i[name module]
)
registry.register(quality)

options.user_names.each do |user_name|
  user = PuppetForge::User.find(user_name)

  # puppetforge_user_modules{name="deanwilson"} $N  # gauge as modules can be removed.
  total_modules.set(user.module_count, labels: { name: user_name })
  total_release_count.set(user.release_count, labels: { name: user_name })

  user.modules.each do |forge_module|
    releases = forge_module.releases

    downloads = releases[0].downloads
    latest_downloads.set(downloads, labels: { name: user_name, module: forge_module.name })

    total_downloads = releases.map { |r| r.downloads }.sum
    total_download_count.increment(by: total_downloads, labels: { name: user_name, module: forge_module.name })

    quality_score = forge_module.current_release.validation_score
    quality.set(quality_score, labels: { name: user_name, module: forge_module.name })
  end
end

gateway_address = "#{options.gateway_host}:#{options.gateway_port}"

Prometheus::Client::Push.new('puppetforge-exporter', options.instance, gateway_address).add(registry)
