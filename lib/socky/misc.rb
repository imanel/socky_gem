module Socky
  module Misc

    def self.included(base)
      base.extend Socky::Misc
    end

    def options
      Socky.options
    end

    def options=(ob)
      Socky.options = ob
    end

    def name
      "#{self.class.to_s.split("::").last}(#{self.object_id})"
    end

    def log_path
      Socky.log_path
    end

    def pid_path
      Socky.pid_path
    end

    def config_path
      Socky.config_path
    end

    def info(args)
      Socky.logger.info args.join(" ")
    end

    def debug(args)
      Socky.logger.debug args.join(" ")
    end

    def error(name, error)
      debug [name, "raised:", error.class, error.message]
    end

    def symbolize_keys(hash)
      return hash unless hash.is_a?(Hash)
      hash.inject({}) do |options, (key, value)|
        options[(key.to_sym if key.respond_to?(:to_sym)) || key] = value
        options
      end
    end
  end
end