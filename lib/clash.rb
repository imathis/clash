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
