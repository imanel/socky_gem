require 'optparse'
require 'yaml'
require 'erb'
require 'socky/options/config'
require 'socky/options/parser'

module Socky
  module Options
    include Socky::Options::Config
    include Socky::Options::Parser

    def prepare_options(argv)
      self.options = {
        :config_path => config_path
      }

      parse_options(argv)
      read_config_file

      self.options = {
        :port => 8080,
        :debug => false,
        :deep_debug => false,
        :log_path => log_path
      }.merge(self.options)
    end

  end
end