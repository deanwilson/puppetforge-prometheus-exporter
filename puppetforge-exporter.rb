#!/usr/bin/env ruby
require 'ostruct'
require 'optparse'
require 'prometheus/client'
require 'prometheus/client/push'
require 'puppet_forge'

APP_NAME = File.basename $PROGRAM_NAME

options = OpenStruct.new({})

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

total_modules = Prometheus::Client::Gauge.new(:puppetforge_user_modules, docstring: '...TODO...', labels: [:name])
registry.register(total_modules)

latest_downloads = Prometheus::Client::Gauge.new(
  :puppetforge_module_latest_downloads_total,
  docstring: '...TODO...', labels: %i[name module]
)
registry.register(latest_downloads)

total_download_count = Prometheus::Client::Counter.new(
  :puppetforge_module_downloads_total,
  docstring: '...TODO...',
  labels: %i[name module]
)
registry.register(total_download_count)

quality = Prometheus::Client::Gauge.new(
  :puppetforge_module_quality_score,
  docstring: '...TODO...',
  labels: %i[name module]
)
registry.register(quality)

options.user_names.each do |user_name|
  user = PuppetForge::User.find(user_name)

  # puppetforge_user_modules{name="deanwilson"} $N  # gauge as modules can be removed.
  total_modules.set(user.module_count, labels: { name: user_name })

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

Prometheus::Client::Push.new('puppetforge-exporter', '', gateway_address).add(registry)
