require 'clash/version'
require 'colorator'
require 'find'
require 'safe_yaml'
require 'diffy'
require 'OS'

module Clash
  autoload :Tests,    'clash/tests'
  autoload :Test,     'clash/test'
  autoload :Diff,     'clash/diff'
  autoload :Helpers,  'clash/helpers'
  autoload :Scaffold, 'clash/scaffold'
end

if defined? Octopress::Docs
  Octopress::Docs.add({
    name:        "Clash",
    gem:         "clash",
    description: "Clash is an integration test framework designed for Jekyll developers",
    path:        File.expand_path(File.join(File.dirname(__FILE__), "../")),
    source_url:  "https://github.com/imathis/clash",
    version:     Clash::VERSION
  })
end
