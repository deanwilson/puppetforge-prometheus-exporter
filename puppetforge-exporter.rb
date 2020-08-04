#!/usr/bin/env ruby
require 'prometheus/client'
require 'prometheus/client/push'
require 'puppet_forge'

PuppetForge.user_agent = 'PuppetForge-Prometheus-Exporter/0.0.1'
registry = Prometheus::Client.registry

total_modules = Prometheus::Client::Gauge.new(:puppetforge_user_modules, docstring: '...TODO...', labels: [:name])
registry.register(total_modules)

user_names = ARGV.sort.uniq

user_names.each do |user_name|
  user = PuppetForge::User.find(user_name)

  # puppetforge_user_modules{name="deanwilson"} $N  # gauge as modules can be removed.
  total_modules.set(user.module_count, labels: { name: user_name })
end

Prometheus::Client::Push.new('puppetforge-exporter', '', 'http://127.0.0.1:9091').add(registry)
