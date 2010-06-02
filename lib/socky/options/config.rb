require 'yaml'
require 'erb'

module Socky
  class Options
    class Config

      class << self
        def read(path)
          if !File.exists?(path)
            puts "You must generate a config file (socky -g filename.yml)"
            exit
          end

          YAML::load(ERB.new(IO.read(path)).result)
        end

        def generate(path)
          if File.exists?(path)
            puts "Config file already exists. You must remove it before generating a new one."
            exit
          end
          puts "Generating config file...."
          File.open(path, 'w+') do |file|
            file.write DEFAULT_CONFIG_FILE
          end
          puts "Config file generated at #{path}"
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