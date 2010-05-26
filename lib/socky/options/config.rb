module Socky
  module Options
    module Config

      def read_config_file
        if !File.exists?(config_path)
          puts "You must generate a config file (socky -g filename.yml)"
          exit
        end

        self.options = YAML::load(ERB.new(IO.read(config_path)).result).merge!(self.options)
      end

      def generate_config_file
        if File.exists?(config_path)
          puts "Config file already exists. You must remove it before generating a new one."
          exit
        end
        puts "Generating config file...."
        File.open(config_path, 'w+') do |file|
          file.write DEFAULT_CONFIG_FILE
        end
        puts "Config file generated at #{config_path}"
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