#!/usr/bin/env ruby
require 'prometheus/client'
require 'prometheus/client/push'
require 'puppet_forge'

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

user_names = ARGV.sort.uniq

user_names.each do |user_name|
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

Prometheus::Client::Push.new('puppetforge-exporter', '', 'http://127.0.0.1:9091').add(registry)
