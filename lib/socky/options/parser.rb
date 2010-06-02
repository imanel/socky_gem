require 'optparse'

module Socky
  class Options
    class Parser

      class << self
        def parse(argv)
          result = {}
          OptionParser.new do |opts|
            opts.summary_width = 25
            opts.banner = "Usage: socky [options]\n"

            opts.separator ""
            opts.separator "Configuration:"

            opts.on("-g", "--generate FILE", String, "Generate config file") do |v|
              result[:config_path] = File.expand_path(v) if v
              Config.generate(result[:config_path])
            end

            opts.on("-c", "--config FILE", String, "Path to configuration file.", "(default: #{Socky.config_path})") do |v|
              result[:config_path] = File.expand_path(v)
            end

            opts.separator ""; opts.separator "Network:"

            opts.on("-p", "--port PORT", Integer, "Specify port", "(default: 8080)") do |v|
              result[:port] = v
            end

            opts.separator ""; opts.separator "Logging:"

            opts.on("-l", "--log FILE", String, "Path to print debugging information.", "(default: #{Socky.log_path})") do |v|
              result[:log_path] = File.expand_path(v)
            end

            opts.on("--debug", "Run in debug mode") do
              result[:debug] = true
            end

            opts.on("--deep-debug", "Run in debug mode that is even more verbose") do
              result[:debug] = true
              result[:deep_debug] = true
            end

            opts.separator ""; opts.separator "Miscellaneous:"

            opts.on_tail("-?", "--help", "Display this usage information.") do
              puts "#{opts}\n"
              exit
            end

            opts.on_tail("-v", "--version", "Display version") do |v|
              puts "Socky #{VERSION}"
              exit
            end
          end.parse!(argv)
          result
        end
      end

    end
  end
end