module Subcontractor
  class Command
    def self.build(parts, options)
      new(parts.dup, options).build
    end

    def initialize(parts, options)
      @parts = parts
      @options = options
    end

    def build
      if _use_command?(:rbenv)
        @parts.unshift("#{_set_rbenv_version} rbenv exec")
      elsif _use_command?(:rvm)
        @parts.unshift("rvm #{_env_specifier(:rvm)} exec")
      end

      @parts.join(" ")
    end

    def _use_command?(command)
      @options.has_key?(command) || _choose_env_and_command_present?(command)
    end

    def _choose_env_and_command_present?(command)
      @options.has_key?(:choose_env) && system("which #{command} > /dev/null 2>&1")
    end

    def _set_rbenv_version
      env_specifier = _env_specifier(:rbenv)
      env_specifier = "`rbenv local`" if env_specifier == "."
      "env RBENV_VERSION=#{env_specifier}"
    end

    def _env_specifier(command)
      @options[command] || @options[:choose_env]
    end
  end
end
