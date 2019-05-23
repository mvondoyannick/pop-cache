require 'spec_helper'

describe Dragonfly::Shell do

  let(:shell){ Dragonfly::Shell.new }

  it "returns the result of the command" do
    shell.run("echo 10").strip.should == '10'
  end

  it "should raise an error if the command isn't found" do
    lambda{
      shell.run "non-existent-command"
    }.should raise_error(Dragonfly::Shell::CommandFailed)
  end

  it "should raise an error if the command fails" do
    lambda{
      shell.run "ls -j"
    }.should raise_error(Dragonfly::Shell::CommandFailed)
  end

  unless Dragonfly.running_on_windows?

    # NOTE: every \\ translates to a single \ on the command line
    describe "escaping args" do
      {
        %q(hello there) => %q(hello there),
        %q('hello' 'there') => %q(hello there),
        %q(he\\'llo there) => %q(he\\'llo there),
        %q(he\\ llo there) => %q(he\\ llo there),
        %q("he'llo" there) => %q(he\\'llo there),
        %q('he'\\''llo' there) => %q(he\\'llo there),
        %q(hel$(lo) there) => %q(hel\\$\\(lo\\) there),
        %q(hel\\$(lo) > there) => %q(hel\\$\\(lo\\) \\> there),
        %q('hel$(lo) > there') => %q(hel\\$\\(lo\\)\\ \\>\\ there),
        %q(hello -there) => %q(hello -there),
      }.each do |args, escaped_args|
        it "should escape #{args} -> #{escaped_args}" do
          shell.escape_args(args).should == escaped_args
        end
      end
    end

    it "escapes commands by default" do
      shell.run("echo `echo 1`").strip.should == "`echo 1`"
    end

    it "allows running non-escaped commands" do
      shell.run("echo `echo 1`", :escape => false).strip.should == "1"
    end

  end

end
