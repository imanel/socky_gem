require 'socky/options/config'
require 'socky/options/parser'

module Socky
  class Options
    include Socky::Misc

    class << self
      def prepare(argv)
        self.options = {
          :config_path => config_path,
          :port => 8080,
          :debug => false,
          :deep_debug => false,
          :log_path => log_path
        }

        parsed_options = Parser.parse(argv)
        config_options = Config.read(parsed_options[:config_path] || config_path)

        self.options.merge!(config_options)
        self.options.merge!(parsed_options)
      end
    end

  end
end