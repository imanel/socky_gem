require 'rubygems'
require 'logger'
require 'fileutils'
require 'em-websocket'
$:.unshift(File.dirname(__FILE__))
require 'em-websocket_hacks'

module Socky

  class SockyError < StandardError; end #:nodoc:

  VERSION = File.read(File.dirname(__FILE__) + '/../VERSION').strip

  class << self
    def options
      @options ||= {}
    end

    def options=(val)
      @options = val
    end

    def logger
      return @logger if defined?(@logger) && !@logger.nil?
      path = log_path
      FileUtils.mkdir_p(File.dirname(path))
      prepare_logger(path)
    rescue
      prepare_logger(STDOUT)
    end

    def logger=(logger)
      @logger = logger
    end

    def log_path
      options[:log_path] || nil
    end

    def pid_path
      options[:pid_path] || File.join(%w( / var run socky.pid ))
    end

    def config_path
      options[:config_path] || File.join(%w( / var run socky.yml ))
    end

    private

    def prepare_logger(output)
      @logger = Logger.new(output)
      @logger.level = Logger::INFO unless options[:debug]
      @logger
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