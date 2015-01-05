require 'clash/version'
require 'colorator'
require 'find'
require 'safe_yaml'
require 'diffy'

module Clash
  autoload :Tests,   'clash/tests'
  autoload :Test,    'clash/test'
  autoload :Diff,    'clash/diff'
  autoload :Helpers, 'clash/helpers'
end

if defined? Octopress::Docs
  Octopress::Docs.add({
    name:        "Clash",
    gem:         "clash",
    description: "A super simple testing framework for static sites.",
    path:        File.expand_path(File.join(File.dirname(__FILE__), "../")),
    source_url:  "https://github.com/imathis/clash",
    version:     Clash::VERSION
  })
end
