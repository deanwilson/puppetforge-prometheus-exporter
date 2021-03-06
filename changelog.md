# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.3] 2020-08-09
### Added
- Allow username specification via ARGV, --users switch or PUPPETFORGE_EXPORTER_USERS environment variable PR#10
- Add user level release count metric PR#11
- Add exporter metadata - direct to master (A mistake)
- Fix TODOs and replace them with metric descriptions - PR#12
- Allow the `instance` label to be configured via environment variable or cli flag - PR#13
- Added Dockerfile - PR#15

### Changed
- PUPPETFORGE_EXPORTER_USERS wasn't being honoured. - PR#14

## [0.0.2] - 2020-08-06
### Added
- Added validation score metric - PR#7
- Added command line and environment variable config for push gateway host and port PR#8

## [0.0.1] - 2020-08-04
### Added
- Initial release - just enough code to push a module count to a pushgateway PR#1
- Add dependabot to ensure dependencies are updated PR#2
- Add rubocop and cleanup the violations PR#3 PR#4
- Add puppetforge_module_downloads_total gauge to show the total downloads for a module PR#5
- Add puppetforge_module_latest_downloads_total gauge to show downloads for the latest release PR#5
