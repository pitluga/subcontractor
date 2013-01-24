require 'optparse'
require 'pty'

module SafePty
  def self.spawn command, &block

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
      puts command
      Dir.chdir(options[:chdir]) if options[:chdir]
      signal = options[:signal] || "TERM"
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
        opt.on('-s', '--signal SIGNAL', 'signal to send to process to kill it, default TERM') do |signal|
          options[:signal] = signal
        end
      end

      parser.parse! argv
      options
    end

  end
end
