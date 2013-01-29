require 'optparse'
require 'pty'

$stdout.sync = true

module SafePty
  def self.spawn command, &block
    if Object.const_defined?('Bundler')
      Bundler.with_clean_env do
        self.spawn_internal command, &block
      end
    else
      self.spawn_internal command, &block
    end
  end

  def self.spawn_internal command, &block
    PTY.spawn(command) do |r,w,p|
      begin
        yield r,w,p
      rescue Errno::EIO
      ensure
        Process.wait p
      end
    end

    $?.exitstatus
  end
end

module Subcontractor
  class CLI

    def run
      options = parse_options(ARGV)
      command = build_command(ARGV.dup, options)
      Dir.chdir(options[:chdir]) if options[:chdir]
      signal = options[:signal] || "TERM"
      execute(command, options, signal)
    end

    def execute(command, options, signal)
      if defined?(Bundler)
        Bundler.with_clean_env do
          clear_env(options)
          spawn(command, signal)
        end
      else
        spawn(command, signal)
      end
    end

    def spawn(command, signal)
      SafePty.spawn(command) do |stdin, stdout, pid|
        trap("TERM") do
          send_kill(signal, find_pids_to_kill(pid))
        end
        trap("INT") do
          send_kill(signal, find_pids_to_kill(pid))
        end
        until stdin.eof?
          puts stdin.gets
        end
      end
    end

    def send_kill(signal, pids)
      pids.each { |pid| Process.kill(signal, pid) }
    end

    def find_pids_to_kill(*pids_to_investigate)
      pids_to_kill = pids_to_investigate
      begin
        pids_to_investigate = find_child_pids(pids_to_investigate)
        pids_to_kill = pids_to_investigate + pids_to_kill
      end until pids_to_investigate.empty?
      pids_to_kill
    end

    def find_child_pids(pids)
      lines = `ps axo pid,ppid`.lines
      child_pids = lines.map(&:split).select do |(child_pid, parent_pid)|
        pids.include?(parent_pid.to_i)
      end.map(&:first).map(&:to_i)
    end

    def build_command(parts, options)
      parts.unshift("rvm #{options[:rvm]} exec") if options.has_key?(:rvm)
      parts.unshift("env RBENV_VERSION=#{options[:rbenv]} rbenv exec") if options.has_key?(:rbenv)
      parts.join(' ')
    end

    def parse_options(argv)
      options = {}
      parser = OptionParser.new do |opt|
        opt.banner = "USAGE: subcontract [options] -- executable"
        opt.on('-r', '--rvm RVM', 'run in a specific RVM') do |rvm|
          options[:rvm] = rvm
        end
        opt.on('-b', '--rbenv RBENV', 'run in a specific RBENV') do |rbenv|
          options[:rbenv] = rbenv
        end
        opt.on('-d', '--chdir PATH', 'chdir to PATH before starting process') do |path|
          options[:chdir] = path
        end
        opt.on('-s', '--signal SIGNAL', 'signal to send to process to kill it, default TERM') do |signal|
          options[:signal] = signal
        end
      end

      parser.parse! argv
      options
    end

    def clear_env(options)
      envs = ['GEM_HOME', 'GEM_PATH', 'RUBYOPT']
      envs.push('RBENV_DIR') if options[:rbenv]
      envs.each { |e| ENV.delete(e) }
    end

  end
end
