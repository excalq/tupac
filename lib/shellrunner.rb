require 'open4'
#From: http://pastebin.com/cFRd6Nyw

class ShellRunner
  attr_reader :output, :error, :exitstatus, :command

  def initialize( command  )
    @command = command
    @output = Array.new
    @error = Array.new
    @exitstatus=-1
  end

  def run
    begin
      pid, stdin, stdout, stderr = Open4::popen4 "#{ @command }"
      status = Process::waitpid2(pid)[1] 
      @exitstatus = ( status.to_i / 256 )
      @output += io_to_a(stdout)
      @error += io_to_a(stderr)
    rescue => ex
      @exitstatus = 1
      @output = [""]
      @error = ["Exception occured while attempting to run command: #{ex.message}"]
    end
    self.to_h
  end

  def to_h
    {
      :exitstatus => @exitstatus, 
      :output => @output,
      :error => @error
    }
  end

  def self.run(command)
    self.new(command).run
  end

  private

  def io_to_a(io)
    io.readlines.collect { |x| x.chomp }
  end

end
