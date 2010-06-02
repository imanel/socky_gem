require 'yaml'
require 'erb'

module Socky
  class Options
    class Config

      class NoConfigFile < Socky::SockyError #:nodoc:
      end

      class InvalidConfig < Socky::SockyError #:nodoc:
      end

      class AlreadyExists < Socky::SockyError #:nodoc:
      end

      class ConfigUnavailable < Socky::SockyError #:nodoc:
      end

      class SuccessfullyCreated < Socky::SockyError #:nodoc:
      end

      class << self
        def read(path)
          raise(NoConfigFile, "You must generate a config file (socky -g filename.yml)") unless File.exists?(path)
          result = YAML::load(ERB.new(IO.read(path)).result)
          raise(InvalidConfig, "Provided config file is invalid.") unless result.is_a?(Hash)
          result
        rescue SockyError => e
          puts e
          exit
        end

        def generate(path)
          raise(AlreadyExists, "Config file already exists. You must remove it before generating a new one.") if File.exists?(path)
          File.open(path, 'w+') do |file|
            file.write DEFAULT_CONFIG_FILE
          end rescue raise (ConfigUnavailable, "Config file is unavailable - please choose another.")
          raise(SuccessfullyCreated, "Config file generated at #{path}")
        rescue SockyError => e
          puts e
          exit
        end

        DEFAULT_CONFIG_FILE= <<-EOF
:port: 8080
:debug: false

:subscribe_url: http://localhost:3000/socky/subscribe
:unsubscribe_url: http://localhost:3000/socky/unsubscribe

:secret: my_secret_key

# :timeout: 3
EOF
      end

    end
  end
end