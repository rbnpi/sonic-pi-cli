#!/usr/bin/env ruby

require "sonic_pi.rb"

def stdin
  unless STDIN.tty?
    $stdin.read
  end
end

def pvalue #get current listen port for Sonic Pi from log file
  value= 4557 #pre new logfile format port was always 4557
  File.open(ENV['HOME']+'/.sonic-pi/log/server-output.log','r') do |f1|
    while l = f1.gets
      if l.include?"Listen port:"
        value = l.split(" ").last.to_i
        break
      end
    end
    f1.close
  end
  return value
end

def args
  args=ARGV.join(' ')
end

def args_and_stdin
  @args_and_stdin ||= [
    args,
    stdin,
  ].join("\n").strip
end

def print_help
  puts <<-HELP
sonic-pi-cli

Usage:
  sonic_pi -p<port no> <code>
  sonic_pi -p<port no> stop
  cat music.rb | sonic_pi -p<port no>
  sonic_pi --help

Sonic Pi must be running for this utility to work.
You can pipe code to stdin to execute it.

Options:
  <code>  Run the given code.
  stop    Stop all running music.
  --help  Display this text.

Made by Nick Johnstone (github.com/Widdershin/sonic-pi-cli).
Thanks to Sam Aaron for creating Sonic Pi.
HELP
end
  
def run

  app = SonicPi.new(pvalue) #pass in port value
  
  case args_and_stdin
  when '--help', '-h', ''
    print_help
  when 'stop'
    app.test_connection!
    app.stop
  else

    app.test_connection!

    app.run(args_and_stdin)
  end
end

run
