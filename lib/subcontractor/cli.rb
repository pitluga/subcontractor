require 'optparse'
require 'pty'

module Subcontractor
  class CLI

    def run
      options = parse_options(ARGV)
      command = build_command(ARGV.dup, options)
      Dir.chdir(options[:chdir]) if options[:chdir]
      PTY.spawn(command) do |stdin, stdout, pid|
        trap("TERM") do
          options.has_key?(:rvm) ? kill_term(*child_pids(pid)) : kill_term(pid)
        end
        until stdin.eof?
          puts stdin.gets
        end
      end
    end

    def kill_term(*pids)
      pids.each { |pid| Process.kill("SIGTERM", pid) }
    end

    def child_pids(pid)
      lines = `ps axo pid,ppid`
      lines.map(&:split).select do |(child_pid, parent_pid)|
        parent_pid == pid.to_s
      end.map(&:first).map(&:to_i)
    end

    def build_command(parts, options)
      parts.unshift("rvm #{options[:rvm]} exec") if options.has_key?(:rvm)
      parts.join(' ')
    end

    def parse_options(argv)
      options = {}
      parser = OptionParser.new do |opt|
        opt.banner = "USAGE: subcontract [options] -- executable"
        opt.on('-r', '--rvm RVM', 'run in a specific RVM') do |rvm|
          options[:rvm] = rvm
        end
        opt.on('-d', '--chdir PATH', 'chdir to PATH before starting process') do |path|
          options[:chdir] = path
        end
      end

      parser.parse! argv
      options
    end

  end
end
