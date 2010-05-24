require 'rubygems'
require 'logger'
require 'fileutils'
require 'em-websocket'
require 'em-websocket_hacks'
$:.unshift(File.dirname(__FILE__))

module Socky

  class SockyError < StandardError #:nodoc:
  end

  VERSION = File.read(File.dirname(__FILE__) + '/../VERSION').strip

  @@options = {}

  class << self
    def options
      @@options
    end

    def options=(val)
      @@options = val
    end

    def logger
      return @@logger if defined?(@@logger) && !@@logger.nil?
      FileUtils.mkdir_p(File.dirname(log_path))
      @@logger = Logger.new(log_path)
      @@logger.level = Logger::INFO unless options[:debug]
      @@logger
    rescue
      @@logger = Logger.new(STDOUT)
      @@logger.level = Logger::INFO unless options[:debug]
      @@logger
    end

    def logger=(logger)
      @@logger = logger
    end

    def log_path
      options[:log_path] || File.join(%w( / var run socky.log ))
    end

    def config_path
      options[:config_path] || File.join(%w( / var run socky.yml ))
    end
  end
end

require 'socky/misc'
require 'socky/options'
require 'socky/runner'
require 'socky/connection'
require 'socky/net_request'
require 'socky/server'
require 'socky/message'