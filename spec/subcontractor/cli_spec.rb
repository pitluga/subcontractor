require "spec_helper"

describe Subcontractor::CLI do
  before(:each) do
    Object.instance_eval{ remove_const(:ARGV) }
  end

  describe "#run" do
    it "uses rvm with --rvm" do
      ARGV = ["--rvm", ".", "test"]
      SafePty.should_receive(:spawn).with("rvm . exec test")
      Subcontractor::CLI.new.run
    end

    context "with --rbenv" do
      it "specifies a rbenv" do
        ARGV = ["--rbenv", "1.9.3", "test"]
        SafePty.should_receive(:spawn).with("env RBENV_VERSION=1.9.3 rbenv exec test")
        Subcontractor::CLI.new.run
      end

      it "uses 'rbenv local' if a '.' is given as the rbenv version" do
        ARGV = ["--rbenv", ".", "test"]
        SafePty.should_receive(:spawn).with("env RBENV_VERSION=`rbenv local` rbenv exec test")
        Subcontractor::CLI.new.run
      end
    end

    context "with --chruby" do
      it "specifies a chruby version" do
        ARGV = ["--chruby", "1.9.3", "test"]
        SafePty.should_receive(:spawn).with("chruby-exec 1.9.3 -- test")
        Subcontractor::CLI.new.run
      end
    end

    it "creates a valid command if no environment manager is specifed" do
      ARGV = ["test"]
      SafePty.should_receive(:spawn).with("test")
      Subcontractor::CLI.new.run
    end

    context "with --choose-env" do
      it "uses rbenv when rbenv is present" do
        ARGV = ["--choose-env", "1.9.3", "test"]
        SafePty.should_receive(:spawn).with("env RBENV_VERSION=1.9.3 rbenv exec test")
        command = Subcontractor::Command.any_instance
        command.should_receive(:system).with("which rbenv > /dev/null 2>&1").and_return(true)
        Subcontractor::CLI.new.run
      end

      it "uses rvm when rvm is present and rbenv isn't" do
        ARGV = ["--choose-env", ".", "test"]
        SafePty.should_receive(:spawn).with("rvm . exec test")
        command = Subcontractor::Command.any_instance
        command.should_receive(:system).with("which rbenv > /dev/null 2>&1").and_return(false)
        command.should_receive(:system).with("which rvm > /dev/null 2>&1").and_return(true)
        Subcontractor::CLI.new.run
      end

      it "uses chruby when chruby is present" do
        ARGV = ["--choose-env", ".", "test"]
        SafePty.should_receive(:spawn).with("chruby-exec . -- test")
        command = Subcontractor::Command.any_instance
        command.should_receive(:system).with("which rbenv > /dev/null 2>&1").and_return(false)
        command.should_receive(:system).with("which rvm > /dev/null 2>&1").and_return(false)
        command.should_receive(:system).with("which chruby-exec > /dev/null 2>&1").and_return(true)
        Subcontractor::CLI.new.run
      end
    end
  end
end
